# Writer report, round-one redesign of ticket #90 (PR #99)

Branch `wt/90-fix1`, created from `52ccd8e` (`feat/design-hole-restart`). Head: `32978fa675e82300bbed01b323011da49d135b0e`. Nothing pushed; the three earlier commits are untouched. Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-ac4de1a6beb6630d6`.

## Commits (`git log --oneline 52ccd8e..HEAD`)

```
32978fa Say what a hole: field is and that a review with no spec marks none
53ca502 Show a malformed hole's value and refuse a hole in a review with no spec
096954b Test the round-one amendments to ticket #90's tables before the scripts
```

Commit 1 the two test files; commit 2 the two scripts; commit 3 the prose (`SKILL.md` through template and regenerated patch, `SOURCES.md` item 6).

## Diff stat (`git diff --stat 52ccd8e..HEAD`)

```
 SOURCES.md                                         |  2 +-
 patches/mattpocock/spec-review.SKILL.md.patch      |  6 +-
 template/.agents/skills/spec-review/SKILL.md       |  6 +-
 .../skills/spec-review/scripts/review-brief.sh     | 10 ++-
 .../skills/spec-review/scripts/review-comment.sh   | 53 ++++++++++------
 tests/spec-review/review-brief.sh                  | 19 +++++-
 tests/spec-review/review-comment.sh                | 72 ++++++++++++++++++----
 7 files changed, 125 insertions(+), 43 deletions(-)
```

Only the seven files the brief lists. `docs/`, `AGENTS.md`, `research/`, generated files, the playbooks, babysit and the ladder are untouched.

## Tests

Against the unchanged scripts (commit 1 alone) each suite passes every existing assertion and stops at its first new one: the comment suite at 7A (the counted item with no `spec:` line and no Spec brief is refused with the "has no 'spec:' line" message instead of being counted); the brief suite at "no spec: the Standards brief carries no spec rule" (the no-ticket Standards brief still carries `$spec_rule`). After commit 2 both suites pass in full; commit 3 changes only prose the suites already asserted unchanged.

### `tests/spec-review/review-comment.sh`: `ok 146 assertions` (was 134; +6 per layout)

Moved (eight, the message text only; fixture and cell unchanged):

| Cell | Assertions moved |
|---|---|
| 1E | 4, the loop over `hole: table 2`, `hole: cell 12A`, `hole: criterion 0`, `hole: table 2/D trailing`; each now shows its own value |
| 1G | 1 (`'hole: criterion 3'` shown) |
| G before E order | 1 (the 1G message) |
| 5E | 1 (`'hole: cell 12A'` shown) |
| 5G | 1 (`'hole: table 9/Z'` shown) |

Added (six):

| Cell | Assertion |
|---|---|
| 1E, a reason | Act on reason `Not a design hole: the table stands.` refused, `'hole: the table stands.'` shown |
| 1G, a reason | the same reason under Noted refused with the amended G message, `'hole: the table stands.'` shown |
| 1A, no colon | reason `Not a design hole; the table stands.` accepted, `act-on items: 2` |
| 7A | a counted Standards item with no `spec:` line, no Spec brief: accepted, `Spec: no spec` in the summary, `act-on items: 1` |
| 7D | the same item marked ` hole: table 2/D`: the no-spec refusal |
| 7D, order | the same item marked ` hole: table 2`: the same no-spec refusal, pinning it before the form check |

Fixture change (no assertion moved): the rows 2 to 4 block gains `echo brief > "$dir/spec-brief.md"` after its `reset`, so its seven refusals still fire (they fire inside the Standards report's check, so no Spec report is needed). Every other existing assertion and its expected text is kept; `act-on items:` stays last and the summary line is unchanged.

### `tests/spec-review/review-brief.sh`: `ok 422 assertions` (was 414; +4 per layout)

The brief said "at the no-ticket run", but the current suite has no such run: every run passes `--ticket 7` or follows a commit naming `#7` (candidate A's `:550` pointed at an older layout). I added one after the first-round assertions, before the `previous.md` block: a run of `HEAD~1` with no ticket named anywhere (the two commits name none). Four assertions: the printed output (`round: 1 of 3`, the Standards brief path, `no spec: Standards axis only`), the Standards brief carries `$step_rule`, lacks `$spec_rule`, and `$count_rule` sits three lines after `$step_rule`. Every with-spec assertion is unchanged, including the existing layout loop over both briefs.

## Verification, on the committed head

| Command | Result | Exit |
|---|---|---|
| `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` | `ShellCheck 0.11.0, files checked: 20`, no findings, no new `disable=` | 0 |
| `bash tests/shellcheck/gate.sh` | `ok 10 assertions` | 0 |
| `bash tests/hooks/delegation.sh` | `ok 55 assertions` | 0 |
| `bash tests/spec-review/review-comment.sh` | `ok 146 assertions` | 0 |
| `bash tests/spec-review/review-brief.sh` | `ok 422 assertions` | 0 |
| `bash tests/spec-review/no-stale-wording.sh` | `ok: no stale wording` | 0 |
| `bash tests/poteto-mode/overlap.sh` | `ok 56 assertions` | 0 |
| `python3 tools/check_knowledge.py` | `knowledge ok: 118 files` | 0 |
| `./factory918.sh sync` | every patch applied, `vendored: 72 skills` | 0 |
| `git status --porcelain` after sync | empty | 0 |

The patch was regenerated as the previous writer did: `diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md template/.agents/skills/spec-review/SKILL.md`, checked first to reproduce the committed patch byte for byte before any edit.

## End-to-end run

The real scripts in a throwaway project repo (`tests/spec-review/layout.sh`, the tests' fake `gh` on PATH, two commits naming no ticket), in the scratchpad, removed afterwards; the worktree was not touched.

```
$ review-brief.sh HEAD~1        (no ticket named anywhere)
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
no spec: Standards axis only
exit 0

$ tail -4 standards-brief.md    (step rule, then the report path and the count rule; no spec rule)
Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quo

Write your report to `.scratch/review/HEAD_1/standards-report.md` and reply with only that
End the report with exactly one line `hard findings: N`, where N is the number of items un

$ review-comment.sh             (a counted Standards item with no spec: line, no Spec brief)

Standards: 1 would break, 0 fail open, of 1; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point HEAD~1.
round: 1 of 3
act-on items: 1
exit 0

$ review-comment.sh .scratch/review/HEAD_1   (the same item marked hole: table 2/D)
review-comment: .scratch/review/HEAD_1/judgment.md item '1. [S1] **Unquoted path.**' carries a 'hole:' field, but this review has no spec (.scratch/review/HEAD_1/spec-brief.md is missing): a hole names an artifact on the ticket the work was built against, and this review has none. Fix the finding on this PR, or rerun scripts/review-brief.sh <fixed-point> --ticket N and judge again
exit 1

$ review-brief.sh HEAD~1 --ticket 7   (a review with a spec)
ticket: #7
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md
exit 0
$ review-comment.sh             (an Act on reason reading "Not a design hole: the table stands.")
review-comment: .scratch/review/HEAD_1/judgment.md item '1. [S1] **Unquoted path.**' has a 'hole:' field that fits no form, 'hole: the table stands.' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded
exit 1

$ review-comment.sh             (the same reason with a semicolon)
Standards: 1 would break, 0 fail open, of 1; Spec: 0 would break, 0 fail open, of 0; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point HEAD~1.
round: 1 of 3
act-on items: 1
exit 0
```

## Cells I could not implement as written

None. Every amended cell is implemented with its expected outcome and its message verbatim.

## Things in the amendments or the brief I found wrong or ambiguous, and what I did

None of these changes a cell's outcome or a message.

1. **The no-spec message's placeholders.** The amendment's message ends `rerun scripts/review-brief.sh <fixed-point> --ticket N and judge again`. The script knows the fixed point (`<dir>/fixed-point`) and could print it, but the message is asserted verbatim, so `<fixed-point>` and `N` are printed as written. If the owner wants the real fixed point in the message, one line in the script and three assertions change, not a cell.

2. **"Leading blanks stripped."** The amendment says `<value>` is the text after `hole:` with leading blanks stripped; the brief gives the extraction `value="${line##*hole:}"; value="${value# }"`, which strips one space. I used the brief's extraction, in a `value()` helper shared by the E and G refusals, and wrote the comment honestly ("the space after it stripped"). A mark written `hole:  table 2/D` (two spaces) fails the form check and is shown as `'hole:  table 2/D'`, which is what the judge needs to see; stripping every blank would hide the fault. No test covers it.

3. **The no-spec refusal's reach.** The amendment says "in a review with no spec every `hole:` field is refused first" and row 7 gives columns D to G one refusal, so the check runs over every judgment heading before the placement check: in a no-spec review, a Noted reason that says `hole:` gets the no-spec message, whose correction ("fix the finding on this PR, or rerun with the ticket") is not the one that item needs ("reword"). Candidate A had rejected this ordering for that reason; the amendment overrode it, and I followed the amendment. Flagged so the owner knows the message a no-spec prose collision under Noted gets.

4. **The anchor wording in `SKILL.md`.** The brief says the contract's sentence that the `$` anchor is on the value, not on detection, goes into the script's comment above `holed()` and into `SKILL.md`'s bullet. The amendment gives the bullet one sentence ("The text from the last `hole:` on an Act on line is the field, so a reason does not write `hole:`; a value in no form is refused with the value shown."), which states the same rule in the skill's terms; a `$`-anchor sentence in a skill would be implementation detail its reader cannot act on. The bullet gains the amendment's sentence verbatim and nothing more; the script comment carries the anchor sentence and the direction-of-failure reason. If the owner reads the brief as asking for a second sentence in the bullet, that is one sentence in the template and the patch.

5. **Placement inside the `hole:` bullet.** The amendment says the bullet "gains" two sentences and does not say where. The hole-1 sentence sits after "prints the line `restart`." (beside the field's grammar); the hole-2 sentence sits last, after the Design hole return (the no-spec case is the exception to it).

6. **The brief test's no-ticket run did not exist** (see the test section). Added; the placement, after the first-round assertions and before the `previous.md` block, keeps `$std` and `$spec` pointing at with-spec briefs for every assertion that existed.

7. **`holed()` gained an optional heading.** The no-spec refusal needs every judgment item with a `hole:` field, so `holed` with no argument runs over every heading (`items` with an empty `want` already does). The signature for the existing callers is unchanged.

8. **`has_spec` and `report()`.** `report()` reads the global `has_spec` and returns before the `spec:` scan when it is empty; `has_spec` is set from `[ -f "$dir/spec-brief.md" ]` before the Standards report's existence check, as the amendment's contract says. The old `has_spec=yes` inside the Spec block is gone.

9. **Header comments of both test files** were updated to say what the suites now assert (the no-spec brief, the field term, the no-spec refusal). Not asked for by name; they described the old rule.
