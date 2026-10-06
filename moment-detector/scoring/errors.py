"""Write a variant's misses and false alarms on a split, with the words, for error analysis.

    python3 moment-detector/scoring/errors.py VARIANT [--split dev] [--at THRESHOLD]

The output holds Manuel's words, so it goes to
.scratch/moment-detector/scoring/errors/VARIANT-SPLIT.md and is never committed.
Each entry: the labels, the detector's score and cue, the labeller's reason, and
the case the detector read.
"""

from __future__ import annotations

import argparse
import json

from prepare import OUT
from label import DEFAULT_DIR
from report import predictions
from run import RUNS, load_jsonl, load_variants


def why(raw: str) -> str:
    try:
        return str(json.JSONDecoder().raw_decode(raw[raw.index("{"):])[0].get("why", ""))
    except ValueError:
        return ""


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("variant")
    ap.add_argument("--split", choices=["dev", "test"], default="dev")
    ap.add_argument("--at", type=float)
    args = ap.parse_args()
    spec = load_variants()
    t = args.at or spec["formats"][spec["variants"][args.variant]["format"]]["threshold"] or 6.0
    items = [i for i in load_jsonl(OUT / "items.jsonl") if i["split"] == args.split and not i["unclear"]]
    preds = predictions(args.variant, items)
    lib = {r["id"]: r for r in load_jsonl(DEFAULT_DIR / "library.jsonl")}
    recs = {}
    for r in load_jsonl(RUNS / f"{args.variant}.jsonl"):
        recs[r["item"]] = r
    out = [f"# {args.variant} on {args.split} at threshold {t:g}\n"]
    for title, keep in (("False alarms", lambda p: not p.item["correction"] and p.score >= t),
                        ("Misses", lambda p: p.item["correction"] and p.score < t)):
        sel = [p for p in preds.values() if keep(p)]
        out.append(f"\n## {title} ({len(sel)})\n")
        for p in sorted(sel, key=lambda p: -p.score):
            i, r, lb = p.item, recs[p.item["id"]], lib[p.item["id"]]
            v = r.get("verdict") or {}
            out.append(f"\n### {i['id']} score {p.score:g}\n")
            out.append(f"label: kind {i['kind']}, surface {i['surface']}, near miss {i['near_miss']}, "
                       f"hard case {i['hard_case']}; skipped: {i['skip']}; error: {r.get('error')}\n")
            out.append(f"detector cue: {v.get('cue', '')!r}; why: {why(r.get('raw') or '')!r}\n")
            out.append(f"labeller's reason: {lb['reason']}\n")
            case = r.get("case") or {}
            for k in ("previous_user", "last_reply", "actions", "prompt"):
                if k in case:
                    body = "\n".join(case[k]) if isinstance(case[k], list) else case[k]
                    out.append(f"\n<{k}>\n{body[-1500:]}\n</{k}>\n")
    path = OUT / "errors" / f"{args.variant}-{args.split}.md"
    path.parent.mkdir(exist_ok=True)
    path.write_text("".join(out))
    print(path)


if __name__ == "__main__":
    main()
