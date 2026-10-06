"""Score variants' runs against the labels, with intervals clustered by session group.

    python3 moment-detector/scoring/report.py VARIANT ... --split dev
        [--at VARIANT=THRESHOLD ...] [--fpr-target 0.10] [--compare A:B ...] [--reps N] [--write NAME]

Every variant is put on one 0 to 10 scale: a graded answer keeps its score, a
yes or no answer maps by its stated confidence (yes: high 10, medium 8, low 6;
no: low 5, medium 3, high 1), and a skipped, failed or unparseable check scores
0. Repeated runs are averaged. A variant fires at its threshold, 6 unless
`--at` sets another; `--fpr-target` also picks, on this split, the lowest
threshold whose false-alarm rate stays under the target (on dev that is a
choice; on test, pass the dev choice with --at instead).

Reported: recall on all, overt and quiet corrections; the false-alarm rate on
all other messages and on near misses; precision at the rate corrections occur
among all of Manuel's messages; AUROC; invalid answers; latency and cost per
check. `--compare A:B` gives B minus A on the same items, with intervals from
resampling session groups; an interval that excludes 0 is a real difference.
`--write NAME` saves the aggregate tables (no ids, no text) to results/NAME.md
and results/NAME.json.
"""

from __future__ import annotations

import argparse
import json
import statistics
from dataclasses import dataclass
from pathlib import Path

from prepare import OUT
from run import RUNS, load_jsonl, load_variants
from stats import auroc, cluster_bootstrap, clustered_rate, ppv

HERE = Path(__file__).resolve().parent
YES = {"high": 10, "medium": 8, "low": 6}
NO = {"low": 5, "medium": 3, "high": 1}


@dataclass
class Pred:
    item: dict
    score: float
    invalid: int
    calls: int
    wall_ms: list[int]
    cost: list[float]
    cost_uncached: list[float]
    input_tokens: list[int]
    output_tokens: list[int]


def invalid(rec: dict) -> bool:
    """An error, or a score off the 1 to 10 scale (runs made before the hook checked the range)."""
    v = rec.get("verdict") or {}
    return bool(rec.get("error")) or ("score" in v and not 1 <= v["score"] <= 10)


def record_score(rec: dict) -> float:
    v = rec.get("verdict")
    if rec.get("skipped") or invalid(rec) or not v:
        return 0.0
    if "score" in v:
        return float(v["score"])
    table = YES if v["moment"] else NO
    return float(table.get(v.get("confidence", "").lower(), 6 if v["moment"] else 4))


def uncached_cost(rec: dict) -> float:
    """What the check costs with the hook's prompt caching off. The CLI's figure prices a cache write
    at twice the input rate, a cache read at a tenth, and output at five times (Haiku 4.5, Sonnet 5.5
    and Opus 5.5 alike), so the input rate falls out of the record and the uncached cost follows."""
    t = rec["tokens"]
    weight = t["input"] + 2 * t["cache_write"] + 0.1 * t["cache_read"] + 5 * t["output"]
    if not weight:
        return 0.0
    rate = rec["cost_usd"] / weight
    return rate * (t["input"] + t["cache_write"] + t["cache_read"] + 5 * t["output"])


def predictions(variant: str, items: list[dict], reps: int | None = None) -> dict[str, Pred]:
    by_item: dict[str, list[dict]] = {}
    for r in load_jsonl(RUNS / f"{variant}.jsonl"):
        if reps is None or r["rep"] < reps:
            by_item.setdefault(r["item"], []).append(r)
    out = {}
    for i in items:
        recs = by_item.get(i["id"])
        if not recs:
            continue
        # A rerun appends the retried check after its failed one; the last record for a rep stands.
        last = {r["rep"]: r for r in recs}.values()
        called = [r for r in last if not r.get("skipped")]
        out[i["id"]] = Pred(
            item=i,
            score=statistics.fmean(record_score(r) for r in last),
            invalid=sum(invalid(r) for r in called),
            calls=len(called),
            wall_ms=[r["latency_ms"]["model_wall"] for r in called if r.get("latency_ms", {}).get("model_wall")],
            cost=[r["cost_usd"] for r in called if r.get("cost_usd") is not None],
            cost_uncached=[uncached_cost(r) for r in called if r.get("cost_usd") is not None],
            input_tokens=[sum(r["tokens"][k] for k in ("input", "cache_read", "cache_write")) for r in called if r.get("tokens")],
            output_tokens=[r["tokens"]["output"] for r in called if r.get("tokens")],
        )
    return out


def base_rate() -> dict:
    """Corrections among all of Manuel's messages in the library, unclear ones by the labeller's verdict,
    and among the clean ones alone."""
    items = load_jsonl(OUT / "items.jsonl")
    clean = [i for i in items if not i["unclear"]]
    return {"all": sum(i["correction"] for i in items) / len(items),
            "clean": sum(i["correction"] for i in clean) / len(clean)}


def rate(preds: list[Pred], t: float) -> dict:
    return clustered_rate([(p.item["group"], p.score >= t) for p in preds])


def curve(preds: list[Pred]) -> list[dict]:
    pos = [p for p in preds if p.item["correction"]]
    neg = [p for p in preds if not p.item["correction"]]
    out = []
    for t in sorted({p.score for p in preds} | {6.0}):
        out.append({"t": t, "recall": sum(p.score >= t for p in pos) / len(pos),
                    "fpr": sum(p.score >= t for p in neg) / len(neg)})
    return out


def pick_threshold(preds: list[Pred], target: float) -> float:
    ok = [c for c in curve(preds) if c["fpr"] <= target]
    return min(c["t"] for c in ok) if ok else 11.0


def metrics(preds: dict[str, Pred], t: float, rates: dict) -> dict:
    ps = list(preds.values())
    pos = [p for p in ps if p.item["correction"]]
    neg = [p for p in ps if not p.item["correction"]]

    def auc(sample: list[Pred]) -> float | None:
        return auroc([p.score for p in sample if p.item["correction"]], [p.score for p in sample if not p.item["correction"]])

    def prec(sample: list[Pred], r: float) -> float | None:
        sp = [p for p in sample if p.item["correction"]]
        sn = [p for p in sample if not p.item["correction"]]
        if not sp or not sn:
            return None
        return ppv(sum(p.score >= t for p in sp) / len(sp), sum(p.score >= t for p in sn) / len(sn), r)

    rec, fa = rate(pos, t), rate(neg, t)
    walls = [w for p in ps for w in p.wall_ms]
    costs = [c for p in ps for c in p.cost_uncached]
    calls = sum(p.calls for p in ps)
    return {
        "threshold": t, "items": len(ps), "corrections": len(pos), "others": len(neg),
        "groups": len({p.item["group"] for p in ps}),
        "calls": calls, "invalid": sum(p.invalid for p in ps),
        "auroc": auc(ps), "auroc_ci": cluster_bootstrap(ps, lambda p: p.item["group"], auc),
        "recall": rec,
        "recall_overt": rate([p for p in pos if p.item["surface"] == "overt"], t),
        "recall_quiet": rate([p for p in pos if p.item["surface"] == "quiet"], t),
        "fpr": fa,
        "fpr_near_miss": rate([p for p in neg if p.item["near_miss"]], t),
        "fpr_other": rate([p for p in neg if not p.item["near_miss"]], t),
        "fired_share": sum(p.score >= t for p in ps) / len(ps),
        "precision": {k: prec(ps, r) for k, r in rates.items()},
        "precision_ci": cluster_bootstrap(ps, lambda p: p.item["group"], lambda s: prec(s, rates["all"])),
        "wall_ms": {"median": statistics.median(walls) if walls else None,
                    "p90": statistics.quantiles(walls, n=10)[-1] if len(walls) > 9 else None,
                    "max": max(walls) if walls else None,
                    "over_20s": sum(w > 20000 for w in walls)},
        "cost_per_check": statistics.fmean(costs) if costs else None,
        "cost_per_message": sum(costs) / len(ps) if ps else None,
        "input_tokens": statistics.median([x for p in ps for x in p.input_tokens]) if calls else None,
        "output_tokens": statistics.median([x for p in ps for x in p.output_tokens]) if calls else None,
    }


def compare(a: dict[str, Pred], b: dict[str, Pred], ta: float, tb: float) -> dict:
    """B minus A on the items both saw."""
    ids = sorted(set(a) & set(b))
    pairs = [(a[i], b[i]) for i in ids]

    def diff(sample: list[tuple[Pred, Pred]], what: str) -> float | None:
        pos = [(x, y) for x, y in sample if x.item["correction"]]
        neg = [(x, y) for x, y in sample if not x.item["correction"]]
        if not pos or not neg:
            return None
        if what == "auroc":
            return auroc([y.score for _, y in pos], [y.score for _, y in neg]) - \
                auroc([x.score for x, _ in pos], [x.score for x, _ in neg])
        sub = pos if what == "recall" else neg
        return (sum(y.score >= tb for _, y in sub) - sum(x.score >= ta for x, _ in sub)) / len(sub)

    out = {"items": len(ids)}
    for what in ("auroc", "recall", "fpr"):
        out[what] = diff(pairs, what)
        out[what + "_ci"] = cluster_bootstrap(pairs, lambda p: p[0].item["group"], lambda s, w=what: diff(s, w))
    for cls, keep in (("corrections", True), ("others", False)):
        sub = [(x, y) for x, y in pairs if x.item["correction"] == keep]
        out[f"only_a_fires_{cls}"] = sum(x.score >= ta and y.score < tb for x, y in sub)
        out[f"only_b_fires_{cls}"] = sum(y.score >= tb and x.score < ta for x, y in sub)
    return out


def pct(r: dict) -> str:
    return "n/a" if r["p"] is None else f"{r['p']:.0%} [{r['lo']:.0%}, {r['hi']:.0%}]"


def table(results: dict[str, dict]) -> str:
    head = ("| Variant | Thr | AUROC | Recall | Quiet recall | False alarms | On near misses | Precision | "
            "Invalid | Wall, median (p90) | Cost per check |")
    lines = [head, "|" + "---|" * (head.count("|") - 1)]
    for name, m in results.items():
        lo, hi = m["auroc_ci"]
        plo, phi = m["precision_ci"]
        w = m["wall_ms"]
        lines.append(
            f"| {name} | {m['threshold']:g} | {m['auroc']:.3f} [{lo:.3f}, {hi:.3f}] | {pct(m['recall'])} | "
            f"{pct(m['recall_quiet'])} | {pct(m['fpr'])} | {pct(m['fpr_near_miss'])} | "
            f"{'n/a' if m['precision']['all'] is None else format(m['precision']['all'], '.0%')} "
            f"[{plo:.0%}, {phi:.0%}] | {m['invalid']}/{m['calls']} | "
            f"{w['median'] / 1000:.2f} s ({w['p90'] / 1000:.2f} s) | ${m['cost_per_check']:.4f} |")
    return "\n".join(lines)


def compare_table(comps: dict[str, dict]) -> str:
    lines = ["| B minus A | AUROC | Recall | False alarms | Corrections only A / only B catches | Others only A / only B flags |",
             "|---|---|---|---|---|---|"]
    for key, c in comps.items():
        def cell(w: str) -> str:
            lo, hi = c[w + "_ci"]
            mark = "" if lo is None or lo <= 0 <= hi else " (real)"
            return f"{c[w]:+.3f} [{lo:+.3f}, {hi:+.3f}]{mark}"
        lines.append(f"| {key} | {cell('auroc')} | {cell('recall')} | {cell('fpr')} | "
                     f"{c['only_a_fires_corrections']} / {c['only_b_fires_corrections']} | "
                     f"{c['only_a_fires_others']} / {c['only_b_fires_others']} |")
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("variants", nargs="+")
    ap.add_argument("--split", choices=["dev", "test"], default="dev")
    ap.add_argument("--at", action="append", default=[], help="VARIANT=THRESHOLD")
    ap.add_argument("--fpr-target", type=float)
    ap.add_argument("--compare", action="append", default=[], help="A:B")
    ap.add_argument("--reps", type=int, help="use only the first N runs of each variant")
    ap.add_argument("--write")
    args = ap.parse_args()

    spec = load_variants()
    items = [i for i in load_jsonl(OUT / "items.jsonl") if i["split"] == args.split and not i["unclear"]]
    at = {k: float(v) for k, v in (a.split("=") for a in args.at)}
    rates = base_rate()
    preds = {v: predictions(v, items, args.reps) for v in args.variants}
    missing = {v: len(items) - len(p) for v, p in preds.items() if len(p) < len(items)}
    if missing:
        print(f"incomplete runs (items missing): {missing}")
    results, thresholds = {}, {}
    for v, p in preds.items():
        t = at.get(v, spec["formats"][spec["variants"][v]["format"]]["threshold"] or 6.0)
        if args.fpr_target is not None and v not in at:
            t = pick_threshold(list(p.values()), args.fpr_target)
        thresholds[v] = t
        results[v] = metrics(p, t, rates)
    comps = {}
    for c in args.compare:
        a, b = c.split(":")
        comps[f"{b} − {a}"] = compare(preds[a], preds[b], thresholds[a], thresholds[b])
    curves = {v: curve(list(p.values())) for v, p in preds.items()}

    text = [f"Split {args.split}; precision at {rates['all']:.1%} corrections among all messages "
            f"({rates['clean']:.1%} among the clean ones).", "", table(results)]
    if comps:
        text += ["", compare_table(comps)]
    print("\n".join(text))
    if args.write:
        out = HERE / "results"
        out.mkdir(exist_ok=True)
        (out / f"{args.write}.md").write_text("\n".join(text) + "\n")
        (out / f"{args.write}.json").write_text(json.dumps(
            {"split": args.split, "base_rate": rates, "results": results, "compare": comps, "curves": curves},
            indent=1) + "\n")


if __name__ == "__main__":
    main()
