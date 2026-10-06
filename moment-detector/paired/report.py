"""Aggregate the paired runs: delivery, uptake, the blind judge's answers by arm,
and the pooled difference with what the numbers can and cannot separate.
Called by `paired.py report`. Writes results/paired.json and results/paired.md
beside this file (counts only, no transcript text) and, under the data folder,
declines.jsonl (which holds the runs' words)."""
from __future__ import annotations

import json
import math
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
QUESTIONS = {"correction": ["restates", "meaning_right", "repeats_failure", "anecdote_rule"],
             "false_alarm": ["restates", "answers", "derailed"]}


def verdicts_of(data: Path, moments: list[dict], judge: str) -> tuple[dict, dict]:
    """(moment, arm, run) -> {question: answer}, and moment -> the judge's groups mapped to arms."""
    verdicts, groups = {}, {}
    for m in moments:
        jdir = data / "judged" / judge / m["name"]
        if not (jdir / "verdicts.json").exists():
            continue
        key = json.loads((jdir / "key.json").read_text())
        res = json.loads((jdir / "verdicts.json").read_text())
        answered = 0
        for item in res["runs"]:
            k = key.get(item["id"])
            if k:
                verdicts[(m["name"], k["arm"], k["run"])] = {q: v["answer"] for q, v in item.items() if q != "id"}
                answered += 1
        if answered != len(key):
            print(f"warning: {judge} answered {answered} of {len(key)} runs of {m['name']}", file=sys.stderr)
        groups[m["name"]] = [[key[i]["arm"] for i in g["ids"] if i in key] for g in res.get("groups") or []]
    return verdicts, groups


def load(data: Path, moments: list[dict], judge: str) -> tuple[list[dict], dict]:
    runs = [json.loads(x) for x in open(data / "runs.jsonl")]
    verdicts, groups = verdicts_of(data, moments, judge)
    for r in runs:
        r["judge"] = verdicts.get((r["moment"], r["arm"], r["run"]))
    return runs, groups


def mh_risk_difference(strata: list[tuple[int, int, int, int]]) -> float | None:
    """Mantel-Haenszel risk difference over strata of (yes_d, n_d, yes_s, n_s)."""
    num = den = 0.0
    for yd, nd, ys, ns in strata:
        if nd and ns:
            w = nd * ns / (nd + ns)
            num += w * (yd / nd - ys / ns)
            den += w
    return num / den if den else None


def answers_by_moment(runs: list[dict], keep, q: str) -> dict[str, list[tuple[str, int]]]:
    """moment -> [(arm, 1 if the judge said yes)], over the runs `keep` admits that got a yes or no on q."""
    per = defaultdict(list)
    for r in runs:
        if keep(r) and r["judge"] and r["judge"].get(q) in ("yes", "no"):
            per[r["moment"]].append((r["arm"], int(r["judge"][q] == "yes")))
    return per


def stratum(rows: list[tuple[str, int]]) -> tuple[int, int, int, int]:
    """(yes with delivery, runs with delivery, yes in shadow, runs in shadow)."""
    return (sum(y for a, y in rows if a == "deliver"), sum(a == "deliver" for a, _ in rows),
            sum(y for a, y in rows if a == "shadow"), sum(a == "shadow" for a, _ in rows))


def permutation_p(per_moment: dict[str, list[tuple[str, int]]], observed: float, alternative: str = "two-sided",
                  reps: int = 20000, seed: int = 7) -> float:
    """P for the MH difference under shuffling arm labels within each moment.
    `alternative` is "two-sided", "less" (delivery lowers the rate) or "more"."""
    rng = random.Random(seed)
    hits = 0
    for _ in range(reps):
        strata = []
        for rows in per_moment.values():
            labels = [a for a, _ in rows]
            rng.shuffle(labels)
            strata.append(stratum([(a, y) for a, (_, y) in zip(labels, rows)]))
        d = mh_risk_difference(strata)
        if d is None:
            continue
        if {"two-sided": abs(d) >= abs(observed) - 1e-12, "less": d <= observed + 1e-12,
                "more": d >= observed - 1e-12}[alternative]:
            hits += 1
    return (hits + 1) / (reps + 1)


def cluster_ci(per_moment: dict[str, list[tuple[str, int]]], reps: int = 5000, seed: int = 11) -> tuple:
    """95% interval for the MH difference, resampling moments, then runs within each arm."""
    rng = random.Random(seed)
    names = list(per_moment)
    stats = []
    for _ in range(reps):
        strata = []
        for name in (rng.choice(names) for _ in names):
            rows = per_moment[name]
            d = [y for a, y in rows if a == "deliver"]
            s = [y for a, y in rows if a == "shadow"]
            if not d or not s:
                continue
            bd = [rng.choice(d) for _ in d]
            bs = [rng.choice(s) for _ in s]
            strata.append((sum(bd), len(bd), sum(bs), len(bs)))
        v = mh_risk_difference(strata)
        if v is not None:
            stats.append(v)
    stats.sort()
    return (stats[int(0.025 * len(stats))], stats[int(0.975 * len(stats)) - 1]) if stats else (None, None)


def detectable(per_moment: dict[str, list[tuple[str, int]]]) -> float | None:
    """The smallest true difference these run counts would detect with 80% power at
    a two-sided 5% level, from the pooled rate held within 0.1 to 0.9 (normal
    approximation, stratified)."""
    num = den = 0.0
    ys = [y for rows in per_moment.values() for _, y in rows]
    if not ys:
        return None
    p = min(max(sum(ys) / len(ys), 0.1), 0.9)
    for rows in per_moment.values():
        nd = sum(a == "deliver" for a, _ in rows)
        ns = sum(a == "shadow" for a, _ in rows)
        if nd and ns:
            w = nd * ns / (nd + ns)
            num += w * w * p * (1 - p) * (1 / nd + 1 / ns)
            den += w
    return round(2.8 * math.sqrt(num) / den, 3) if den else None


def purity(groups: list[list[str]]) -> float:
    return sum(Counter(g).most_common(1)[0][1] for g in groups if g) / sum(len(g) for g in groups)


def purity_test(groups: list[list[str]], reps: int = 20000, seed: int = 3) -> tuple[float, float, float]:
    """Observed purity, its mean when the arms are shuffled over the same group sizes, and
    the share of shuffles at least as pure."""
    rng = random.Random(seed)
    observed = purity(groups)
    arms = [a for g in groups for a in g]
    total = hits = 0.0
    for _ in range(reps):
        rng.shuffle(arms)
        it = iter(arms)
        v = purity([[next(it) for _ in g] for g in groups])
        total += v
        hits += v >= observed - 1e-12
    return observed, total / reps, (hits + 1) / (reps + 1)


def qcell(ans: Counter | dict) -> str:
    yes, no, unclear = ans.get("yes", 0), ans.get("no", 0), ans.get("unclear", 0)
    return f"{yes}/{yes + no}" + (f" +{unclear}?" if unclear else "")


# extension-plan.md, fixed before the extension ran: the tests read only runs after batch one's five.
EXTENSION = [("H1", ["m01"], "anecdote_rule", "less"), ("H2", ["m05", "m06"], "repeats_failure", "less"),
             ("H3", ["m10"], "derailed", "more")]
BATCH_ONE_RUNS = 5


def fisher_one_sided(yd: int, nd: int, ys: int, ns: int, direction: str) -> float:
    """P of a deliver count at least this extreme in `direction`, margins fixed."""
    total, k = nd + ns, yd + ys

    def pmf(x: int) -> float:
        return math.comb(nd, x) * math.comb(ns, k - x) / math.comb(total, k)
    xs = range(max(0, k - ns), min(k, nd) + 1)
    return sum(pmf(x) for x in xs if (x <= yd if direction == "less" else x >= yd))


def extension_tests(runs: list[dict]) -> tuple[list[str], dict]:
    lines = ["", "## Extension tests (new runs only; extension-plan.md)", "",
             "| Test | Moments | Question | Deliver yes | Shadow yes | Difference | One-sided p |",
             "|---|---|---|---|---|---|---|"]
    out = {}
    for name, ms, q, direction in EXTENSION:
        per = answers_by_moment(runs, lambda r: r["moment"] in ms and int(r["run"]) > BATCH_ONE_RUNS, q)
        if not per:
            continue
        strata = [stratum(rows) for rows in per.values()]
        yd, nd, ys, ns = (sum(s[i] for s in strata) for i in range(4))
        d = mh_risk_difference(strata)
        p = (fisher_one_sided(yd, nd, ys, ns, direction) if len(per) == 1
             else permutation_p(per, d, direction))
        out[name] = {"moments": ms, "question": q, "direction": direction, "deliver": [yd, nd], "shadow": [ys, ns],
                     "difference": d, "p_one_sided": p}
        lines.append(f"| {name} | {', '.join(ms)} | {q} ({direction} with delivery) | {yd}/{nd} | {ys}/{ns} | "
                     f"{fmt(d)} | {p:.3f} |")
    return lines, out


def fmt(x, pct=True):
    if x is None:
        return "n/a"
    return f"{x * 100:+.0f} pts" if pct else f"{x:.3f}"


def main(data: Path, moments: list[dict], arms: dict, judge: str, second: str | None) -> None:
    runs, groups = load(data, moments, judge)
    label = {m["name"]: m["label"] for m in moments}
    out = {"moments": {}, "pooled": {}, "uptake": {}, "cost": {}}
    lines = ["# Paired replays: results", ""]

    # Per moment and arm
    lines += ["## Per moment", "",
              "| Moment | Label | Arm | Runs | Fired | Delivered | Reached transcript | Taken | Declined | No trace | "
              + " | ".join(sorted({q for qs in QUESTIONS.values() for q in qs})) + " |",
              "|" + "---|" * (10 + len({q for qs in QUESTIONS.values() for q in qs}))]
    allq = sorted({q for qs in QUESTIONS.values() for q in qs})
    for m in moments:
        for arm in arms:
            rs = [r for r in runs if r["moment"] == m["name"] and r["arm"] == arm]
            if not rs:
                continue
            up = Counter(r["uptake"] for r in rs)
            cell = {"runs": len(rs), "fired": sum(r["fired"] for r in rs), "delivered": sum(r["delivered"] for r in rs),
                    "reached_transcript": sum(r["reached_transcript"] for r in rs),
                    "uptake": dict(up), "judge": {}}
            for q in allq:
                ans = Counter((r["judge"] or {}).get(q) for r in rs if r["judge"] and q in r["judge"])
                if ans:
                    cell["judge"][q] = dict(ans)
            out["moments"].setdefault(m["name"], {"label": m["label"], "id": m["id"]})[arm] = cell
            qcells = [qcell(cell["judge"][q]) if q in cell["judge"] else "" for q in allq]
            lines.append(f"| {m['name']} | {m['label']} | {arm} | {len(rs)} | {cell['fired']} | {cell['delivered']} | "
                         f"{cell['reached_transcript']} | {up.get('taken', 0)} | {up.get('declined', 0)} | "
                         f"{up.get('no_trace', 0)} | " + " | ".join(qcells) + " |")
    lines += ["", "Judge columns are yes out of yes-or-no answers, with unclear answers counted after a plus. "
              "Fired counts the detector's verdict in both arms; the shadow arm logs it and delivers nothing.", ""]

    # Pooled, by label and question
    lines += ["## Pooled by arm (Mantel-Haenszel difference, deliver minus shadow, stratified by moment)", "",
              "| Label | Question | Deliver yes | Shadow yes | Difference | 95% interval (moments, then runs, resampled) | "
              "Permutation p | Detectable at 80% power |", "|---|---|---|---|---|---|---|---|"]
    notes = ["", "The interval resamples moments and then runs within each arm, which counts within-moment "
             "variation twice: it is conservative, and with three false-alarm moments it has few distinct "
             "resamples. The permutation p shuffles arm labels within each moment."]
    for lab, qs in QUESTIONS.items():
        for q in qs:
            per = answers_by_moment(runs, lambda r: label.get(r["moment"]) == lab, q)
            if not per:
                continue
            strata = [stratum(rows) for rows in per.values()]
            d = mh_risk_difference(strata)
            lo, hi = cluster_ci(per)
            p = permutation_p(per, d) if d is not None else None
            yd, nd = sum(s[0] for s in strata), sum(s[1] for s in strata)
            ys, ns = sum(s[2] for s in strata), sum(s[3] for s in strata)
            mde = detectable(per)
            out["pooled"][f"{lab}.{q}"] = {"deliver": [yd, nd], "shadow": [ys, ns], "difference": d, "ci95": [lo, hi],
                                          "p": p, "detectable": mde, "moments": len(per)}
            p_text = f"{p:.3f}" if p is not None else "n/a"
            lines.append(f"| {lab} | {q} | {yd}/{nd} | {ys}/{ns} | {fmt(d)} | [{fmt(lo)}, {fmt(hi)}] | "
                         f"{p_text} | {fmt(mde)} |")
    lines += notes
    lines += ["", "Good handling is `meaning_right` yes, `repeats_failure` and `anecdote_rule` no on corrections; "
              "`answers` yes and `derailed` no on false alarms. `restates` is the behaviour the suggestion asks for.",
              ""]

    # Uptake on delivered runs
    dl = [r for r in runs if r["delivered"]]
    up = Counter((label[r["moment"]], r["uptake"]) for r in dl)
    out["uptake"] = {f"{k[0]}.{k[1]}": v for k, v in up.items()}
    lines += ["## Uptake where the suggestion was delivered", "",
              "| Label | Delivered | Taken | Declined | No trace | Attachment missing |", "|---|---|---|---|---|---|"]
    for lab in QUESTIONS:
        n = sum(1 for r in dl if label[r["moment"]] == lab)
        lines.append(f"| {lab} | {n} | {up.get((lab, 'taken'), 0)} | {up.get((lab, 'declined'), 0)} | "
                     f"{up.get((lab, 'no_trace'), 0)} | {up.get((lab, 'attachment_missing'), 0)} |")
    # Restatement by uptake, delivered runs only: did the marker go with the behaviour?
    cross = Counter((r["uptake"], (r["judge"] or {}).get("restates")) for r in dl)
    out["uptake_by_restates"] = {f"{a}.{b}": v for (a, b), v in cross.items()}
    lines += ["", "Judge's `restates` by uptake, delivered runs: "
              + ", ".join(f"{a} with restates={b}: {v}" for (a, b), v in sorted(cross.items(), key=str)), ""]

    # Declines, with whether each was right by outcome (written with the words to the data folder)
    with open(data / "declines.jsonl", "w") as f:
        for r in dl:
            if r["uptake"] == "declined":
                j = r["judge"] or {}
                if label[r["moment"]] == "false_alarm":
                    right = j.get("derailed") != "yes"
                else:
                    right = j.get("meaning_right") == "yes" and j.get("repeats_failure") == "no"
                f.write(json.dumps({**{k: r[k] for k in ("moment", "arm", "run", "decline_reason")},
                                    "label": label[r["moment"]], "judge": j, "right_by_outcome": right}) + "\n")

    # Cost and time
    for arm in arms:
        rs = [r for r in runs if r["arm"] == arm]
        out["cost"][arm] = {"runs": len(rs), "main_usd": round(sum(r["main_cost_usd"] or 0 for r in rs), 2),
                            "detector_usd": round(sum(r["detector_cost_usd"] or 0 for r in rs), 3),
                            "hook_ms": sorted(r["hook_ms"] for r in rs if r["hook_ms"] is not None),
                            "wall_s": round(sum(r["wall_s"] or 0 for r in rs))}
    lines += ["## Cost and time", ""]
    for arm, c in out["cost"].items():
        h = c["hook_ms"]
        med = h[len(h) // 2] if h else None
        lines.append(f"- {arm}: {c['runs']} runs, main sessions ${c['main_usd']}, detector ${c['detector_usd']}, "
                     f"hook median {med} ms (max {h[-1] if h else None}), {c['wall_s'] // 60} run-minutes.")
    ext_lines, out["extension"] = extension_tests(runs)
    lines += ext_lines

    # The judge's own grouping of each moment's runs, compared with the arms it never saw
    lines += ["", "## Did the blind judge's grouping follow the arms?", "",
              "For each moment the judge was asked whether the runs fall into distinct groups by how they respond. "
              "Purity is the share of grouped runs whose group's majority arm is their own arm. Chance is the "
              "mean purity when the arms are shuffled over the judge's groups, and p the share of shuffles at least "
              "as pure.", "", "| Moment | Groups | Grouped runs | Purity | Chance | p |", "|---|---|---|---|---|---|"]
    out["groups"] = {}
    for m in moments:
        gs = groups.get(m["name"])
        if gs is None:
            continue
        grouped = sum(len(g) for g in gs)
        if not grouped:
            out["groups"][m["name"]] = {"groups": 0}
            lines.append(f"| {m['name']} | 0 | 0 | n/a | n/a | n/a |")
            continue
        observed, chance, p = purity_test(gs)
        out["groups"][m["name"]] = {"groups": len(gs), "grouped": grouped, "purity": round(observed, 2),
                                    "chance": round(chance, 2), "p": round(p, 3),
                                    "arms_by_group": [dict(Counter(g)) for g in gs]}
        lines.append(f"| {m['name']} | {len(gs)} | {grouped} | {observed:.2f} | {chance:.2f} | {p:.3f} |")

    # A second judge, same packet, another model: agreement per question
    if second and (data / "judged" / second).exists():
        v2, _ = verdicts_of(data, moments, second)
        lines += ["", f"## Agreement with a second judge ({second}, same packets)", "",
                  "| Question | Both answered yes/no | Agree | Cohen's kappa |", "|---|---|---|---|"]
        out["second_judge"] = {"model": second}
        for q in sorted({q for qs in QUESTIONS.values() for q in qs}):
            pairs = [(r["judge"][q], v2[k][q]) for r in runs if r["judge"] and q in r["judge"]
                     for k in [(r["moment"], r["arm"], r["run"])] if k in v2 and q in v2[k]
                     and r["judge"][q] in ("yes", "no") and v2[k][q] in ("yes", "no")]
            if not pairs:
                continue
            agree = sum(a == b for a, b in pairs) / len(pairs)
            pa = sum(a == "yes" for a, _ in pairs) / len(pairs)
            pb = sum(b == "yes" for _, b in pairs) / len(pairs)
            pe = pa * pb + (1 - pa) * (1 - pb)
            kappa = (agree - pe) / (1 - pe) if pe < 1 else None
            out["second_judge"][q] = {"n": len(pairs), "agree": round(agree, 3),
                                      "kappa": round(kappa, 3) if kappa is not None else None}
            lines.append(f"| {q} | {len(pairs)} | {agree:.0%} | {kappa:.2f} |" if kappa is not None
                         else f"| {q} | {len(pairs)} | {agree:.0%} | n/a |")
    (HERE / "results").mkdir(exist_ok=True)
    (HERE / "results" / "paired.json").write_text(json.dumps(out, indent=1) + "\n")
    (HERE / "results" / "paired.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
