# Writer report, ticket #90

Branch `wt/90-writer`, created from `69bd412` (`feat/design-hole-restart`, equal to `origin/feat/shellcheck`). Head: `52ccd8eb509a2871260827a8514c3a1fcaac4d5d`. Nothing pushed. Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-ac6e09d026a1bd69c`.

## Commits

```
52ccd8e Say where a design hole goes, in the skill, the ladder and the playbooks
8b3de0a Return a design hole to architect and restart the review rounds
cc36280 Test the design-hole restart from ticket #90's tables before the scripts
```

Commit 1 is the tests, commit 2 the two scripts, commit 3 the prose (SKILL.md through its patch and template, the ladder, ticket.md, both babysit files through their patches and templates, SOURCES.md items 4, 6 and 12, and the stale-wording entry lands in commit 1 with the tests).

## Diff stat, 69bd412..HEAD

```
 SOURCES.md                                         |   6 +-
 patches/mattpocock/spec-review.SKILL.md.patch      |  17 ++-
 patches/pstack/babysit/SKILL.md.patch              |   3 +-
 .../pstack/poteto-mode/playbooks/babysit.md.patch  |   6 +-
 template/.agents/skills/babysit/SKILL.md           |   1 +
 .../skills/poteto-mode/playbooks/babysit.md        |   2 +
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  13 +-
 template/.agents/skills/spec-review/SKILL.md       |  15 +-
 .../skills/spec-review/scripts/review-brief.sh     |  64 ++++++--
 .../skills/spec-review/scripts/review-comment.sh   |  92 +++++++++---
 template/docs/agents/review-ladder.md              |   2 +-
 tests/spec-review/no-stale-wording.sh              |  11 +-
 tests/spec-review/review-brief.sh                  | 157 ++++++++++++++++++-
 tests/spec-review/review-comment.sh                | 166 ++++++++++++++++++++-
 14 files changed, 483 insertions(+), 72 deletions(-)
```

Only the files the brief lists are touched. `docs/knowledge/`, `docs/agents/ledger.md`, `docs/M0-findings.md`, `AGENTS.md`, `research/`, generated files, `arena` and `architect` are untouched.

## Tests

Against the unchanged scripts (commit 1 alone), each suite stops at its first new assertion: the comment suite passes all 82 existing assertions and fails at table B row 2 (the `spec:` refusal, "judgment.md is missing" printed instead); the brief suite fails at the `spec_rule` anti-drift assertion against `SKILL.md`; `no-stale-wording.sh` hits `template/.agents/skills/spec-review/SKILL.md:130`. After commit 2 the comment suite passes; the brief suite still stops at the `SKILL.md` spec-rule assertion, which is prose, and passes with the scripts alone when that one line is removed (412). After commit 3 everything passes.

### `tests/spec-review/review-comment.sh`: `ok 134 assertions` (was 82; +26 per layout)

Every existing assertion and its expected text is kept. Existing fixtures with counted items (lines 114-115, the two heredocs at 171-217, `fenced_twin`) gained a `spec:` line so their expected texts hold; the old scripts ignore the line, so those cases pass on both.

| Table B cell | Assertions |
|---|---|
| Row 2, all columns (no `spec:`, before the judgment is read) | 1 refuse, no judgment file present, state kept |
| Row 3 (malformed `spec:`) | 4 refuses, one per listed form (`cell 12A`, `table 12A`, `criterion 0`, trailing text) |
| Row 3 (fenced `spec:`) | 1 refuse |
| Row 4 (`spec:` present, no `Documented step:`) | 1 refuse, the existing step message |
| Row 1A and row 6 (walk lines carrying `spec:` and `hole:` text) | 1 accept, as today |
| Row 1B (`fixed:`) | 1 accept |
| Row 1C (`ticket:`) | 1 accept |
| Row 1D (`hole:` equal to `spec:`) | 1 accept: summary unchanged, `restart`, `round:`, count minus the hole |
| Notes: rerun from the dir with the hole still marked | 1 accept, same output |
| Notes: two holes | 1 accept, one `restart`, both left out |
| Notes: `hole:` before a trailing `fixed:` | 1 accept, counted as fixed, no `restart` |
| Row 1E | 4 refuses, one per listed form |
| Row 1F | 1 refuse |
| Row 1G | 1 refuse |
| Order: G before E | 1 refuse |
| Row 5A | 1 accept |
| Row 5D | 1 refuse |
| Row 5E | 1 refuse (as 1E) |
| Row 5F | 1 refuse (as 5D) |
| Row 5G | 1 refuse (as 1G) |

### `tests/spec-review/review-brief.sh`: `ok 414 assertions` (was 334; +40 per layout)

| Item | Assertions |
|---|---|
| `spec_rule` in `SKILL.md` step 4 | 1 |
| `spec_rule` in each brief, two lines after `step_rule`, the count rule three lines after it | 3 per brief, 6 |
| `fragment()` holds `fenced` and the `ref=` line of both scripts together; the `ref=` line exists | 1 (the existing equality, now over both) + 1 new |
| Row 5A (`X`, `round: 1 of 3`, no `settled:` line, paths), round file, no settled section, row 13 (the cited items of the restart comment and the one before it dropped) | 1 + 1 + 2 per brief = 6 |
| Row 5B (`--round 2`) | 2 |
| Row 5C (`--previous` file holding both comments with the RS byte) | 1 |
| Row 6A (restart in round three, not refused) | 2 |
| Row 7A (refused after three post-restart comments, exact message, no state) | 1 |
| Row 7B (`--round 3`, settled over the new series only) | 4 |
| Row 8A (two restarts) | 2 |
| Row 11A (prose, fenced, trailing-text `restart`) | 1 |
| Row 12A (through `pr me me:<file>`, the jq filter) | 1 |
| Row 12C (`--previous` trusted) | 1 |
| Rows 14, 15, 16 (each form carried: the exact `settled:` line and the pasted line in both briefs) | 3 each, 9 |
| Row 17 (five malformed cites dropped and counted) | 2 |
| `--round 4` refusal on a PR with no restart | existing assertion, unchanged |

### `tests/spec-review/no-stale-wording.sh`

`Three trailing fields` added to the blacklist; `ok: no stale wording`.

## Verification (rule 8), on the committed head

| Command | Result | Exit |
|---|---|---|
| `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` | `ShellCheck 0.11.0, files checked: 20`, no findings, no new `disable=` | 0 |
| `bash tests/shellcheck/gate.sh` | `ok 10 assertions` | 0 |
| `bash tests/hooks/delegation.sh` | `ok 55 assertions` | 0 |
| `bash tests/spec-review/review-comment.sh` | `ok 134 assertions` | 0 |
| `bash tests/spec-review/review-brief.sh` | `ok 414 assertions` | 0 |
| `bash tests/spec-review/no-stale-wording.sh` | `ok: no stale wording` | 0 |
| `bash tests/poteto-mode/overlap.sh` | `ok 56 assertions` | 0 |
| `python3 tools/check_knowledge.py` | `knowledge ok: 118 files` | 0 |
| `./factory918.sh sync` | all patches applied, `vendored: 72 skills` | 0 |
| `git status --porcelain` after sync | empty | 0 |

The three patches were regenerated by reverse-applying the committed patch to the committed template file and diffing forward (the method reproduces all three existing patches byte for byte, checked before any edit); the regenerated spec-review patch round-trips the same way.

## End-to-end run

Real scripts, throwaway dir `.scratch/review/69bd412` in the worktree, the tests' fake `gh` on PATH, `--previous` holding a round-one comment with a `restart` line; cleaned up afterwards (no review dir, no state, tree clean).

```
$ review-brief.sh 69bd412 --ticket 90 --previous restart.md
ticket: #90
restart: the round and the settled items count from the last restart comment
round: 1 of 3
.scratch/review/69bd412/standards-brief.md
.scratch/review/69bd412/spec-brief.md
exit 0

$ grep -n "spec:" .scratch/review/69bd412/standards-brief.md | head -2
105:The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticke

$ review-comment.sh   (reads .claude/state/review/dir; S1 marked hole: table 1/D)

Standards: 1 would break, 0 fail open, of 1; Spec: 0 would break, 1 fail open, of 1; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point 69bd412.
restart
round: 1 of 3
act-on items: 1
exit 0

$ review-comment.sh .scratch/review/69bd412   (the hole now reads criterion 9)
review-comment: .scratch/review/69bd412/judgment.md item '1. [S1] **Cut at the wrong comment.**' is marked 'hole: criterion 9' but [S1] rests on 'table 1/D'; the mark repeats the report item's 'spec:' line word for word
exit 1

$ review-comment.sh .scratch/review/69bd412   (the spec line now reads cell 1D)
review-comment: .scratch/review/69bd412/standards-report.md item '1. **Cut at the wrong comment.**' under '## Would break' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it
exit 1
```

## Cells I could not implement as written

None. Every cell is implemented with its expected outcome and message.

## Things in the design I found wrong or ambiguous, and what I did

None of these changes a cell's expected outcome. Each is flagged for the owner to confirm or take back to architect.

1. **The `'<N. **Title.**>'` placeholder for a judgment item.** A judgment item reads `1. [S1] **Title.** reason`; the design writes the refusal as `item '<N. **Title.**>'`. I render it as the line's opening through the closing `**`, reference included: `'1. [S1] **Hook exits 0 on a miss.**'`. That is what one `title()` helper gives for both report and judgment items (the report form is unchanged, `'2. **Open, silently.**'`). Stripping `[S1]` out of the middle would be a second rule for no reader benefit. The tests pin my rendering; if the owner wants the reference stripped, four messages and their assertions change, not a cell.

2. **The note "each grep is `$`-anchored, so at most one matches and the count cannot go negative" is not true for the `design` form.** `design <signature>` takes the rest of the line, so `... hole: design x fixed: abc1234` matches both `hole: design .*$` and `fixed: <sha>$`. The rule the note states, "only the field that ends the line is a field", is implementable and I implemented it: a `hole:` on a line that ends with a `fixed:` or `ticket:` field is text, for the count and for the three refusals alike (`holed()` in `review-comment.sh`). The cell's outcome, "counted per the last field", holds; the note's reasoning does not. The last-field test uses the `table` form the note describes. Costs code the note said it would not.

3. **The `cites:` bullet in `SKILL.md` step 5.** The design's prose list for `SKILL.md` names the step 1 sentence, the step 4 spec rule, the step 5 paragraph, the "Four trailing fields" lead, the `hole:` bullet and the step 6 changes, but not the `cites:` bullet, which ends "Nothing else counts." With the fourth form in `review-brief.sh` that sentence would be false, so I added the form to the bullet (`#N <reference>`, with the three spellings). One sentence beyond the design's list; criterion 5 asks for the form.

4. **`ref` was already a variable in `review-comment.sh`.** The existing reference-set loop used `ref` for each judgment item's `[S<n>]`, which overwrote the grammar before the `hole:` checks ran (the first test run caught it: a well-formed hole was refused as fitting no form). The design pins the name `ref=` for both scripts and the test's `fragment()`, so I renamed the loop variable to `ref_id`. No behavior change to that loop.

5. **Refusal order inside the `hole:` checks.** The design says three refusals "in this order": G, then E, then F. I run them as three passes over the judgment, so a G on item 4 is refused before an E on item 1 (one assertion pins G before E). A per-item pass would give a different first message when two kinds of fault sit on different items; no cell combines them.

6. **More than one assertion for some cells.** Row 3 lists four malformed `spec:` forms and column E lists four malformed `hole:` forms; I assert each listed form (4 + 1 fenced, and 4), rather than one representative. Row 6 shares its accept with row 1A (the walk lines carry `spec:` and `hole:` text in the shared fixture). Row 17 puts all five malformed cites in one comment and asserts the count and the absence once each.

7. **Where the brief suite fails at commit 2.** The suite's `SKILL.md` spec-rule anti-drift assertion is prose, so the brief suite is fully green only from commit 3; the scripts' own assertions all pass at commit 2 (412 with that one line removed). Recorded above under Tests.

8. **Portability of the grammar.** `ref` uses POSIX classes (`[^[:space:]/]`) as a dynamic regex in awk (`-v want=`), in `sed -E` and in `grep -E`. Verified on this machine (macOS awk, BSD sed and BSD grep 2.6.0; the tests run the scripts under `bash`, so the shell's ugrep wrapper is not involved). CI's ubuntu runner (mawk, GNU sed and grep) supports the classes too, but that run is the owner's to see. Not a design matter and no M0-findings line was written, since that file is outside my files.

9. **An edge outside the table.** A Noted, Dismissed, Ask or Consider item whose one-line reason contains the text `hole:` mid-sentence is refused as column G (`holed()` matches `hole:` anywhere on a line that does not end in `fixed:`/`ticket:`). Judgment reasons are one line and the word is a field name, so I left it; noting it so nobody is surprised.

## What the design got right that I leaned on

The `$`-anchored fields, `stepless()` as the template for the `spec:` check, the RS-separated `--previous` file for multi-comment histories, and the slice-before-derivations shape all landed as described; both derivations after the slice needed no change, and the fourth-round refusal fires on a restarted series exactly as on a fresh one (row 7A pins it, with no stdout and no state).
