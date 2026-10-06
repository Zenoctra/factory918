"""Score the saved predictions again against another set of labels, with no model calls.

    python3 moment-detector/scoring/rescore.py --old items-r2.jsonl [--new items.jsonl] [--write NAME]

For the detectors that ran on the dev split, and for the finalists that ran once
on test, prints recall, false alarms and AUROC under the old and the new labels
(the same predictions, the same thresholds, the same session-group intervals),
what moved and why (the messages whose label changed, and what each detector did
with them), and, for the four context slices, whether Haiku and Sonnet moved the
same way. `--write NAME` saves the aggregate tables (no ids, no text) to
results/NAME.md.
"""

from __future__ import annotations

import argparse
import dataclasses
from collections import Counter
from pathlib import Path

from prepare import OUT
from report import base_rate, metrics, pct, predictions
from run import load_jsonl, load_variants
from stats import auroc, cluster_bootstrap

HERE = Path(__file__).resolve().parent
DEV = ["ship0", "h0-a", "h0-b", "h0-c", "h0-d", "hthink-b", "hwhy-b", "slow-a", "slow-b", "slow-c", "slow-d",
       "smed-b", "shigh-b", "olow-b", "snotes-b", "salt-b", "sneutral-b", "sbool-b", "sex-b"]
TEST = {"ship0": 6.0, "slow-b": 6.0, "olow-b": 6.0, "snotes-b": 6.0}
TEST_AT_5 = {"slow-b": 5.0, "snotes-b": 5.0}


def threshold(name: str) -> float:
    spec = load_variants()
    return float(spec["formats"][spec["variants"][name]["format"]]["threshold"] or 6.0)


def load(path: Path, split: str) -> list[dict]:
    return [i for i in load_jsonl(path) if i["split"] == split and not i["unclear"]]


def line(m: dict) -> str:
    lo, hi = m["auroc_ci"]
    return (f"{m['items']} ({m['corrections']}/{m['others']}) | {m['auroc']:.3f} [{lo:.3f}, {hi:.3f}] | "
            f"{pct(m['recall'])} | {pct(m['recall_quiet'])} | {pct(m['fpr'])} | {pct(m['fpr_near_miss'])}")


def before_after(split: str, variants: dict[str, float], old: Path, new: Path, reps: int | None) -> list[str]:
    rows = ["| Detector | Labels | Scored (corr/other) | AUROC | Recall | Quiet recall | False alarms | On near misses |",
            "|---|---|---|---|---|---|---|---|"]
    for v, t in variants.items():
        for tag, path in (("old", old), ("new", new)):
            items = load(path, split)
            rates = base_rate(load_jsonl(path))
            m = metrics(predictions(v, items, reps), t, rates)
            rows.append(f"| {v} @{t:g} | {tag} | {line(m)} |")
    return rows


def moved(old: Path, new: Path, split: str, variants: list[str], reps: int | None) -> list[str]:
    """Where each message that was scored under the old labels went, and what the detectors did with the ones whose label flipped."""
    o = {i["id"]: i for i in load_jsonl(old) if i["split"] == split}
    n = {i["id"]: i for i in load_jsonl(new) if i["split"] == split}
    c = Counter()
    flips_down, flips_up = [], []
    for i, a in o.items():
        if a["unclear"]:
            c["unclear before, clean now" if i in n and not n[i]["unclear"] else "unclear before and now" if i in n else "unclear before, dropped"] += 1
            continue
        if i not in n:
            c["clean before, dropped"] += 1
        elif n[i]["unclear"]:
            c["clean before, unclear now"] += 1
        elif a["correction"] != n[i]["correction"]:
            c["correction -> not" if a["correction"] else "not -> correction"] += 1
            (flips_down if a["correction"] else flips_up).append(i)
        else:
            c["unchanged"] += 1
    out = [f"{split}: " + "; ".join(f"{k} {v}" for k, v in sorted(c.items()))]
    for v in variants:
        t = threshold(v)
        p = predictions(v, [n[i] for i in n if not n[i]["unclear"]], reps)
        d = [p[i] for i in flips_down if i in p]
        u = [p[i] for i in flips_up if i in p]
        out.append(f"  {v} @{t:g}: of {len(d)} corrections now ruled not, it fired on {sum(x.score >= t for x in d)} "
                   f"(now counted as false alarms); of {len(u)} others now corrections, it fired on {sum(x.score >= t for x in u)}")
    return out


def slice_effects(items: list[dict], reps: int | None) -> list[str]:
    """Each model's change from slice b to the other slices, and the models' difference of those changes."""
    ids = {i["id"] for i in items}
    preds = {v: predictions(v, items, reps) for v in ("h0-a", "h0-b", "h0-c", "h0-d", "slow-a", "slow-b", "slow-c", "slow-d")}
    common = sorted(ids.intersection(*[set(p) for p in preds.values()]))
    rows = [(preds["h0-a"][i], preds["h0-b"][i], preds["h0-c"][i], preds["h0-d"][i],
             preds["slow-a"][i], preds["slow-b"][i], preds["slow-c"][i], preds["slow-d"][i]) for i in common]
    T = 6.0

    def stat(sample: list[tuple], what: str, model: int, sl: int) -> float | None:
        # model 0 Haiku, 1 Sonnet; slice index 0 a, 1 b, 2 c, 3 d; value of `what` on the sample
        def metric(k: int) -> float | None:
            ps = [r[model * 4 + k] for r in sample]
            pos = [p for p in ps if p.item["correction"]]
            neg = [p for p in ps if not p.item["correction"]]
            if not pos or not neg:
                return None
            if what == "auroc":
                return auroc([p.score for p in pos], [p.score for p in neg])
            if what == "recall":
                return sum(p.score >= T for p in pos) / len(pos)
            return sum(p.score >= T for p in neg) / len(neg)
        a, b = metric(sl), metric(1)
        return None if a is None or b is None else a - b

    def ci(f) -> tuple[float | None, float | None]:
        return cluster_bootstrap(rows, lambda r: r[0].item["group"], f)

    names = "abcd"
    out = ["| Slice vs b | Metric | Haiku change | Sonnet change | Same direction | Haiku minus Sonnet |", "|---|---|---|---|---|---|"]
    for sl in (0, 2, 3):
        for what in ("auroc", "recall", "fpr"):
            h = stat(rows, what, 0, sl)
            s = stat(rows, what, 1, sl)
            hci = ci(lambda x, w=what, k=sl: stat(x, w, 0, k))
            sci = ci(lambda x, w=what, k=sl: stat(x, w, 1, k))
            dci = ci(lambda x, w=what, k=sl: None if stat(x, w, 0, k) is None or stat(x, w, 1, k) is None
                     else stat(x, w, 0, k) - stat(x, w, 1, k))
            sign = "yes" if h * s > 0 else "no" if h * s < 0 else "one is flat"
            unit = (lambda v: f"{v:+.3f}") if what == "auroc" else (lambda v: f"{v * 100:+.1f} pts")
            fmt = lambda v, c: f"{unit(v)} [{unit(c[0])}, {unit(c[1])}]"
            out.append(f"| {names[sl]} | {what} | {fmt(h, hci)} | {fmt(s, sci)} | {sign} | {fmt(h - s, dci)} |")
    out.insert(0, f"{len(common)} messages scored by all eight cells; threshold {T:g}.\n")
    return out


def label_shift(old: Path, new: Path, reps: int | None) -> list[str]:
    """What the new labels do to each slice cell, on the dev messages clean under both (so only the flipped labels differ)."""
    o = {i["id"]: i for i in load(old, "dev")}
    n = {i["id"]: i for i in load(new, "dev")}
    shared = [i for i in n if i in o]
    T = 6.0
    out = [f"{len(shared)} dev messages clean under both; {sum(o[i]['correction'] != n[i]['correction'] for i in shared)} change label; threshold {T:g}.\n",
           "| Cell | AUROC old to new, change | Recall change | False alarms change |", "|---|---|---|---|"]

    def shift(rows: list[tuple], what: str) -> float | None:
        def m(k: int) -> float | None:
            pos = [r[k] for r in rows if r[k].item["correction"]]
            neg = [r[k] for r in rows if not r[k].item["correction"]]
            if not pos or not neg:
                return None
            if what == "auroc":
                return auroc([p.score for p in pos], [p.score for p in neg])
            return (sum(p.score >= T for p in pos) / len(pos)) if what == "recall" else (sum(p.score >= T for p in neg) / len(neg))
        a, b = m(0), m(1)
        return None if a is None or b is None else b - a

    for v in ("h0-a", "h0-b", "h0-c", "h0-d", "slow-a", "slow-b", "slow-c", "slow-d", "ship0", "olow-b"):
        p = predictions(v, [o[i] for i in shared], reps)
        rows = [(p[i], dataclasses.replace(p[i], item=n[i])) for i in shared if i in p]
        cells = []
        for what in ("auroc", "recall", "fpr"):
            d = shift(rows, what)
            lo, hi = cluster_bootstrap(rows, lambda r: r[0].item["group"], lambda x, w=what: shift(x, w))
            f = (lambda x: f"{x:+.3f}") if what == "auroc" else (lambda x: f"{x * 100:+.1f} pts")
            cells.append(f"{f(d)} [{f(lo)}, {f(hi)}]")
        out.append(f"| {v} | " + " | ".join(cells) + " |")
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--old", type=Path, required=True)
    ap.add_argument("--new", type=Path, default=OUT / "items.jsonl")
    ap.add_argument("--reps", type=int, default=1, help="first N runs of each variant (the first run, as the stage 1 tables)")
    ap.add_argument("--write")
    args = ap.parse_args()

    text = []
    text += ["## Dev, every scored variant, at its stated threshold", ""]
    text += before_after("dev", {v: threshold(v) for v in DEV}, args.old, args.new, args.reps)
    text += ["", "## Test, the finalists, at 6 and at the dev thresholds for a 5% target", ""]
    text += before_after("test", TEST | {f"{k}": v for k, v in {}.items()}, args.old, args.new, None)
    text += [""] + before_after("test", TEST_AT_5, args.old, args.new, None)[2:]
    text += ["", "## What moved", ""]
    for split in ("dev", "test"):
        text += moved(args.old, args.new, split, ["ship0", "slow-b", "olow-b"], args.reps if split == "dev" else None)
    text += ["", "## Haiku and Sonnet across the four slices, old labels", ""]
    text += slice_effects(load(args.old, "dev"), args.reps)
    text += ["", "## Haiku and Sonnet across the four slices, new labels", ""]
    text += slice_effects(load(args.new, "dev"), args.reps)
    text += ["", "## What the new labels do to each cell, Haiku against Sonnet", ""]
    text += label_shift(args.old, args.new, args.reps)
    print("\n".join(text))
    if args.write:
        (HERE / "results").mkdir(exist_ok=True)
        (HERE / "results" / f"{args.write}.md").write_text("\n".join(text) + "\n")


if __name__ == "__main__":
    main()
