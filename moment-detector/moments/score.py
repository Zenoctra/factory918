"""Score a detector's firings against the library.

    python3 moment-detector/moments/score.py PREDICTIONS.jsonl [--library DIR/library.jsonl] [--include-unclear]

PREDICTIONS.jsonl holds one row per moment the detector saw: {"id": ..., "fired": true|false}.
Moments the detector did not see are left out of the score and counted.
Unclear moments are left out unless --include-unclear.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from label import DEFAULT_DIR


def rate(hits: int, n: int) -> str:
    return f"{hits}/{n} = {hits / n:.0%}" if n else "0/0"


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("predictions", type=Path)
    ap.add_argument("--library", type=Path, default=DEFAULT_DIR / "library.jsonl")
    ap.add_argument("--include-unclear", action="store_true")
    args = ap.parse_args()

    lib = {r["id"]: r for r in map(json.loads, open(args.library))}
    fired = {r["id"]: bool(r["fired"]) for r in map(json.loads, open(args.predictions))}
    unknown = set(fired) - set(lib)
    if unknown:
        raise SystemExit(f"{len(unknown)} prediction ids are not in the library, e.g. {sorted(unknown)[:3]}")
    rows = [r for r in lib.values() if r["id"] in fired and (args.include_unclear or not r["unclear"])]
    pos = [r for r in rows if r["correction"]]
    neg = [r for r in rows if not r["correction"]]
    print(f"scored {len(rows)} of {len(lib)} moments ({len(lib) - len(fired)} unseen, "
          f"{sum(r['unclear'] for r in lib.values() if r['id'] in fired) if not args.include_unclear else 0} unclear left out)")
    print("recall, all corrections:   ", rate(sum(fired[r["id"]] for r in pos), len(pos)))
    for s in ("overt", "quiet"):
        sub = [r for r in pos if r["surface"] == s]
        print(f"recall, {s} corrections: ".ljust(28), rate(sum(fired[r["id"]] for r in sub), len(sub)))
    print("false alarms, all others:  ", rate(sum(fired[r["id"]] for r in neg), len(neg)))
    nm = [r for r in neg if r["near_miss"]]
    print("false alarms, near misses: ", rate(sum(fired[r["id"]] for r in nm), len(nm)))
    fp = sum(fired[r["id"]] for r in neg)
    tp = sum(fired[r["id"]] for r in pos)
    print("precision:                 ", rate(tp, tp + fp))


if __name__ == "__main__":
    main()
