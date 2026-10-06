"""Join the moments with their labels into the library a scoring script reads,
and collect the cases to look at again.

    python3 moment-detector/moments/library.py [--primary opus55-r2] [--revision sonnet55-r3] [--second opus5-r2] [--dir DIR]

Writes DIR/library.jsonl (one row per moment: where to find it, the label,
and the second labeller's label) and DIR/review.jsonl (rows that are unclear,
where the two labellers disagree, or where the label goes against Manuel's
ruling on its kind). DIR/overrides.jsonl, one line per moment, holds what
Manuel decided or left open by hand: {"id": ..., "ruled": true|false, "why": ...}
is his own verdict on that message and replaces the labeller's;
{"id": ..., "held": "why"} keeps it unclear for him; {"id": ..., "drop": "why"}
leaves the message out of the library (test data he would throw away). A
correction he was mistaken about is held as well. The revision labels
(labels-REVISION.jsonl, made after a ruling changed) replace the primary's for
the ids they hold, and the second labeller's label for those ids, made under
the old ruling, is left out. Prints the counts, and the scoring set by class.
"""

from __future__ import annotations

import argparse
import collections
import json
from pathlib import Path

from label import DEFAULT_DIR, HARD_CASES, ruled_label


def load(path: Path) -> dict[str, dict]:
    return {r["id"]: r for r in map(json.loads, open(path))} if path.exists() else {}


def held_reason(label: dict, override: dict) -> str:
    if "ruled" in override:
        return ""
    if override.get("held"):
        return override["held"]
    if label["label"] == "correction" and label["agent_erred"] == "no" and ruled_label(label) is None:
        return "a correction Manuel was mistaken about; not ruled yet"
    return ""


def scoring_rows(rows: list[dict], include_unclear: bool = False) -> list[dict]:
    """The scoring set: a re-sent message and its earlier copies count once, as the latest copy;
    unclear rows are left out unless asked for."""
    by_id = {r["id"]: r for r in rows}

    def first_copy(r: dict) -> str:
        while r["resend_of"] in by_id:
            r = by_id[r["resend_of"]]
        return r["id"]

    latest: dict[str, dict] = {}
    for r in rows:
        k = first_copy(r)
        if k not in latest or r["timestamp"] > latest[k]["timestamp"]:
            latest[k] = r
    kept = {r["id"] for r in latest.values()}
    return [r for r in rows if r["id"] in kept and (include_unclear or not r["unclear"])]


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--primary", default="opus55-r2")
    ap.add_argument("--revision", default="sonnet55-r3", help="labels that replace the primary's for the ids they hold")
    ap.add_argument("--second", default="opus5-r2")
    ap.add_argument("--dir", type=Path, default=DEFAULT_DIR)
    args = ap.parse_args()

    overrides = load(args.dir / "overrides.jsonl")
    dropped = {i for i, o in overrides.items() if o.get("drop")}
    moments = [m for m in map(json.loads, open(args.dir / "moments.jsonl")) if m["id"] not in dropped]
    first, second = load(args.dir / f"labels-{args.primary}.jsonl"), load(args.dir / f"labels-{args.second}.jsonl")
    revised = load(args.dir / f"labels-{args.revision}.jsonl")
    first.update(revised)
    second = {i: b for i, b in second.items() if i not in revised}
    missing = [m["id"] for m in moments if m["id"] not in first]
    if missing:
        raise SystemExit(f"{len(missing)} moments have no {args.primary} label; run label.py --name {args.primary}")

    rows = []
    for m in moments:
        a, b = first[m["id"]], second.get(m["id"])
        override = overrides.get(m["id"], {})
        held = held_reason(a, override)
        manuel = override.get("ruled")
        correction = manuel if manuel is not None else a["label"] == "correction"
        ruled = ruled_label(a)
        rows.append({
            "id": m["id"], "project": m["project"], "session_id": m["session_id"], "uuid": m["uuid"],
            "line": m["line"], "timestamp": m["timestamp"], "delivery": m["delivery"],
            "starts_session": m["context"]["starts_session"], "resend_of": m["resend_of"],
            "correction": correction, "ruled_by_manuel": manuel is not None,
            "labelled_by": a["labeller"], "kind": a["kind"], "surface": a["surface"], "near_miss": a["near_miss"], "hard_case": a["hard_case"],
            "agent_erred": a.get("agent_erred"),
            "confidence": a["confidence"], "unclear": (a["unclear"] and manuel is None) or bool(held), "held": held,
            "against_ruling": manuel is None and ruled is not None and ruled != correction,
            "second_correction": (b["label"] == "correction") if b else None,
            "reason": a["reason"], "evidence": a["evidence"], "other_reading": a["other_reading"],
        })
    with open(args.dir / "library.jsonl", "w") as fh:
        for r in rows:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
    review = [r for r in rows if r["unclear"] or r["against_ruling"]
              or (r["second_correction"] is not None and r["second_correction"] != r["correction"])]
    with open(args.dir / "review.jsonl", "w") as fh:
        for r in review:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")

    corr = [r for r in rows if r["correction"]]
    paired = [r for r in rows if r["second_correction"] is not None]
    agree = sum(r["second_correction"] == r["correction"] for r in paired)
    print(f"dropped {len(dropped)}; labels revised {len(revised)}")
    print(f"moments {len(rows)}; corrections {len(corr)} (quiet {sum(r['surface'] == 'quiet' for r in corr)}); "
          f"near misses {sum(r['near_miss'] for r in rows)}; unclear {sum(r['unclear'] for r in rows)} "
          f"(held {sum(bool(r['held']) for r in rows)})")
    scoring = scoring_rows(rows)
    print(f"scoring set {len(scoring)}: corrections {sum(r['correction'] for r in scoring)} "
          f"(quiet {sum(r['surface'] == 'quiet' for r in scoring if r['correction'])}), "
          f"others {sum(not r['correction'] for r in scoring)} (near misses {sum(r['near_miss'] for r in scoring)}); "
          f"re-sent copies left out {len(rows) - len(scoring_rows(rows, include_unclear=True))}")
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
            print(f"kind {h}: {len(members)}, labelled correction {sum(r['correction'] for r in members)}, "
                  f"unclear {sum(r['unclear'] for r in members)}, against the ruling {sum(r['against_ruling'] for r in members)}, "
                  f"labellers disagree {sum(r['second_correction'] is not None and r['second_correction'] != r['correction'] for r in members)}")
    print(f"review.jsonl: {len(review)} rows")


if __name__ == "__main__":
    main()
