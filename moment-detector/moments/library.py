"""Join the moments with their labels into the library a scoring script reads,
and collect the cases for Manuel to rule on.

    python3 moment-detector/moments/library.py [--primary opus55] [--second opus5] [--dir DIR]

Writes DIR/library.jsonl (one row per moment: where to find it, the label,
and the second labeller's label) and DIR/review.jsonl (rows where the two
labellers disagree or the primary flagged the case unclear). Prints the counts.
"""

from __future__ import annotations

import argparse
import collections
import json
from pathlib import Path

from label import DEFAULT_DIR, HARD_CASES


def load(path: Path) -> dict[str, dict]:
    return {r["id"]: r for r in map(json.loads, open(path))} if path.exists() else {}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--primary", default="opus55")
    ap.add_argument("--second", default="opus5")
    ap.add_argument("--dir", type=Path, default=DEFAULT_DIR)
    args = ap.parse_args()

    moments = [json.loads(line) for line in open(args.dir / "moments.jsonl")]
    first, second = load(args.dir / f"labels-{args.primary}.jsonl"), load(args.dir / f"labels-{args.second}.jsonl")
    missing = [m["id"] for m in moments if m["id"] not in first]
    if missing:
        raise SystemExit(f"{len(missing)} moments have no {args.primary} label; run label.py --name {args.primary}")

    rows = []
    for m in moments:
        a, b = first[m["id"]], second.get(m["id"])
        rows.append({
            "id": m["id"], "project": m["project"], "session_id": m["session_id"], "uuid": m["uuid"],
            "line": m["line"], "timestamp": m["timestamp"], "delivery": m["delivery"],
            "starts_session": m["context"]["starts_session"],
            "correction": a["label"] == "correction",
            "kind": a["kind"], "surface": a["surface"], "near_miss": a["near_miss"], "hard_case": a["hard_case"],
            "agent_erred": a.get("agent_erred"),
            "confidence": a["confidence"], "unclear": a["unclear"],
            "second_correction": (b["label"] == "correction") if b else None,
            "reason": a["reason"], "evidence": a["evidence"], "other_reading": a["other_reading"],
        })
    with open(args.dir / "library.jsonl", "w") as fh:
        for r in rows:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
    review = [r for r in rows if r["unclear"] or (r["second_correction"] is not None and r["second_correction"] != r["correction"])]
    with open(args.dir / "review.jsonl", "w") as fh:
        for r in review:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")

    corr = [r for r in rows if r["correction"]]
    paired = [r for r in rows if r["second_correction"] is not None]
    agree = sum(r["second_correction"] == r["correction"] for r in paired)
    print(f"moments {len(rows)}; corrections {len(corr)} (quiet {sum(r['surface'] == 'quiet' for r in corr)}); "
          f"near misses {sum(r['near_miss'] for r in rows)}; unclear {sum(r['unclear'] for r in rows)}")
    if paired:
        both = sum(r["correction"] and r["second_correction"] for r in paired)
        print(f"{args.second} agrees on {agree}/{len(paired)}; corrections by both {both}, "
              f"only {args.primary} {sum(r['correction'] and not r['second_correction'] for r in paired)}, "
              f"only {args.second} {sum(r['second_correction'] and not r['correction'] for r in paired)}")
    print("kind:", dict(collections.Counter(r["kind"] for r in rows).most_common()))
    print("delivery (corrections/all):", {d: f"{sum(r['correction'] for r in rows if r['delivery'] == d)}/{n}"
                                          for d, n in collections.Counter(r["delivery"] for r in rows).items()})
    for h in HARD_CASES:
        members = [r for r in rows if r["hard_case"] == h]
        if members:
            print(f"hard case {h}: {len(members)}, labelled correction {sum(r['correction'] for r in members)}, "
                  f"labellers disagree {sum(r['second_correction'] is not None and r['second_correction'] != r['correction'] for r in members)}")
    print(f"review.jsonl: {len(review)} rows")


if __name__ == "__main__":
    main()
