# #139 fix4 report

The writer flags guard in review-brief.sh now counts per heading line. A list hidden by a fence or quote refuses even when another list on the ticket is readable.

Branch: wt/139-fix4, on origin/feat/unreadable-writer-flags at 30bdcae. Not pushed. Worktree: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aeeb4469f589590d9

## Commits

- 197c676 tests first. D10 now expects a refusal naming `### Writer-flags 2026-09-24`, relabelled `(D10, per heading)`. New D17 has two readable lists and briefs with empty stderr. New D18 has a fenced first list and a readable second one. It is refused, naming `### Writer flags 2026-09-23` only. The table D comment and the header comment say per heading.
- 659f508 script. `disposed` gets `-v at=1`: the item rule prints `NR` instead of the record (`print (at ? NR : field($0) US $0)`). Only the guard passes it, so undisposed's records and every existing stderr are unchanged. The guard collects the read line numbers. A second awk walks the body with the unchanged heading match and attributes each read line to the latest heading line at or above it. It prints every heading line with no read flag attributed, in text order, under the unchanged rz8 header. A body with no heading line prints nothing. The guard comment and the header comment (line 34) say per heading.
- 3d183e8 SKILL.md step 1 now reads "under which no flag is read (a read flag belongs to the nearest such line at or above it)". The patch is regenerated with the given diff -u command, the suite's `has` pin is updated word for word, and SOURCES.md patch 6 says "no flag is read under it (#139)" instead of "from it".

## Failed before the script change

- (D10, per heading): exit 0, wanted the refusal naming `### Writer-flags 2026-09-24`.
- (D18): exit 0, wanted the refusal naming `### Writer flags 2026-09-23`. Seen by running a copy of the suite with the D10 line removed.
- (D17) passed before the change, as expected. It guards against over-refusal and cannot fail under the old whole-body count, since both lists are read.

## Verification (all at 3d183e8)

- `bash tests/spec-review/review-brief.sh`: exit 0, ok 1876 assertions. D1, A8, C7/f (#108's body shape), D9 and D12 keep their outcomes.
- `bash .github/shellcheck.sh ... 'tests/*/*/*.sh'`: exit 0, ShellCheck 0.11.0, 26 files.
- `bash tests/spec-review/no-stale-wording.sh`: exit 0, "ok: no stale wording".
- `bash tests/spec-review/review-comment.sh`: exit 0, ok 298 assertions.
- `./factory918.sh sync` alone: exit 0, 72 skills. Then `git status --porcelain` was empty.
- `python3 tools/check_knowledge.py`: exit 0, knowledge ok, 119 files.
- The guard by hand, extracted from the committed script, over the live bodies of #90 #93 #103 #105 #106 #107 #108 #109 #110 #111 #137 #139: no refusal. #108 has 1 heading line and 15 read flags. The rest have no heading line. No body has a P108 offender.

## Act-on list

1. Attribution is "at or above", not strictly "above". Your brief said the nearest heading line above the flag. The parser can read a deeper heading inside a list as an item, for example `#### Writer's flag note ... accepted: x` under `### Writer flags <date>`. That item is itself a heading line. With a strict "above" it would refuse for having no flag of its own, while its own disposition sits on the same line. "At or above" attributes it to itself. It is the same rule for every other flag, since no other read flag sits on a heading line. The script, SKILL.md and SOURCES.md all say "at or above". To make it strict, change `k && (NR in read)` to test before the heading rule and reword the three places.
2. The refusal header still says "no flag could be read from its body", as you asked (rz8 unchanged). With per-heading counting that wording is loose when another list was read. If you want it exact, it is a follow-up that touches every rz8 cell.
3. Not touched: docs/knowledge/core/DECISIONS.md and docs/agents/ledger.md. If P109/P139 wording in DECISIONS.md says whole body, it is yours to amend.

Claude Opus 5.5, Claude Code lane
