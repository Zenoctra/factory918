#!/usr/bin/env bash
# Greps template/ and docs/knowledge/core/ for retired wording, so a rename that leaves the old
# words behind fails here: #81's `## Latent` heading and the definition sentence that began "A hard
# finding is wrong behavior in normal use", #90's "Three trailing fields", the judgment's field
# count before `hole:`, and #93's "at most three rounds", the cap before a Would-break fix earned
# a fourth and fifth, #105's "table unchanged", the reason a later round once gave for skipping
# the Spec axis, #106's "From round four on both briefs carry", from before round three could
# be fix-only, and the tail of the risk sentence before #108 asked whether the diff honors each
# risk's disposition, and #137's wording that led a reviewer: the expected count of findings, the
# word cap, the limits on reading and running, and the judge's heuristics on nits and on more than
# five Act on items. Prints each hit as file:line and exits 1 on any; prints `ok: no stale wording`
# otherwise.
set -euo pipefail
cd "$(dirname "$0")/../.."
hits="$(grep -rnF -e '## Latent' -e 'A hard finding is wrong behavior in normal use' -e 'Three trailing fields' -e 'at most three rounds' -e 'table unchanged' -e 'From round four on both briefs carry' -e 'each naming the risk and saying what the diff does at that risk;' -e 'Zero items is the expected result' -e 'Read nothing beyond this brief unless' -e 'read that one function or section, not the file' -e 'Run nothing.' -e 'reads one file and runs nothing' -e 'read nothing beyond the brief but the code around a hunk' -e 'Under 400 words' -e 'under 400 words' -e 'a report that is all nits means' -e 'more than five Act on items' -e 'zero items is the expected result' template docs/knowledge/core | cut -d: -f1,2 || true)"
if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  exit 1
fi
echo "ok: no stale wording"
