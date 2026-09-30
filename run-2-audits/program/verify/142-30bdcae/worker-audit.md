verdict: PASS+NOTES

# Receipts-and-diff audit, PR #142 (ticket #139) at 30bdcae

Setup confirmed: `git rev-parse HEAD` = `30bdcae4913d0911e3aec2b2902611c2cf89c443`;
`git merge-base --is-ancestor origin/main HEAD` exit 0 with `origin/main` =
`9846844d838403b8d0c0f9b4686852965dba6a40`. Diff is 9 files, +57/-15.

## 1. #139's acceptance criteria

- **Criterion 1** (a heading anywhere with zero flags read is refused: exit 1, the heading named, no
  state) — **met**. `template/.agents/skills/spec-review/scripts/review-brief.sh:447-454`: the `heads`
  awk over the raw `$spec`, then `[ -n "$heads" ] && [ -z "$(... awk -v mode=flags -v w="writer flags"
  "$disposed")" ]` → `rm -rf "$dir"`, the refusal on stderr with each heading line indented two
  spaces, `exit 1`. It sits inside the `if [ -n "$spec" ]` block opened at line 434, before
  `reading-pack.sh` (line 458) and before any `.claude/state/review` write, so nothing is written.
  Asserted by `refused8`, which checks exit 1, byte-exact stderr, and the absence of both
  `.claude/state/review` and `.scratch/review/<id>` (`tests/spec-review/review-brief.sh:1916-1921`).
- **Soundness of the "zero read" test** — **holds**. The new block re-runs `$disposed` in flags mode
  and treats *any* record as a read flag. That is only correct because the P108 check immediately
  above (`review-brief.sh:435-441`, via `undisposed flags` at line 435) already exits on every `none`,
  `near`, `fence` and reasonless-`accepted` record, and on a `fixed:` value that is not a commit in
  HEAD's history (`review-brief.sh:189-208`). Past line 441 every remaining record is a settled flag.
  The script's own comment states this invariant.
- **Criterion 2** (a body with no heading briefs byte for byte) — **met by construction**. The script
  diff is exactly two hunks: a header-comment rewrite and the new `if` block. When `heads` is empty
  the `[ -n "$heads" ]` test short-circuits, the second awk never runs, and no other line executes,
  so the no-heading path is bit-identical to #140's head. See Note 2 on the owner's empirical run.
- **Criterion 3** (a readable list behaves as at #136's head) — **met**. D1 and D10 brief; the guard
  runs only after the P108 check printed nothing, so every body #136 refuses keeps its exact stderr
  (D8 asserts `rf8`, unchanged). Suite green at 1872 assertions.
- **Criterion 4** (no shape-specific parsing) — **met**. One anchored line match plus a record count.
  No fence, quote or list state is tracked anywhere in the new block.

**The C6/f move — judged correct.** #108's cell C6/f is a closed fence holding `### Writer flags
2026-09-23` and `1. bare`: one heading line, zero flags read. #139's criterion 1 says "inside a fence
or a quote or not", and the ticket's own table D row D3 spells the cell out as "RZ (was B)". The
ticket is the later spec and carries Manuel's "go ahead". The root's "keep every cell" brief and the
ticket conflict in this one cell only, and the owner followed the ticket, recording it in P139
(`docs/knowledge/core/DECISIONS.md:109`), in the PR's `## Tradeoffs` and in the report's `## Decided`.
That is the right call and it is visible to a reviewer in three places.

## 2. The table on #139: one assertion per cell, tests first

- Every row has one assertion, named `(D<k>)`, at `tests/spec-review/review-brief.sh:2026-2048`:
  D1 `briefed8`, D2-D7 `rz8`, D8 `rf8` (unchanged), D9 `briefed8 ""`, D10 `briefed8`, D11 and the
  extra D11b `rz8`, D12 `briefed8`, D13-D16 `rz8`. C6/f moved to `refused8 "(C6/f, #139)"` at line
  2026. Outcomes match the table cell for cell; D11b is an extra shape, not a missing one.
- **Tests first in every round**: `956cba3` (table D) before `d98c3ca` (script); `175a358` before
  `731e404`; `bb5eb0b` before `6f17c22`; `2d4b289` before `44b4880`. Four test-then-script pairs.

## 3. Scope, vendoring, upstream wording

- 9 files, all in scope: the script, its test, `SKILL.md` + its patch, `SOURCES.md`, the two DECISIONS
  copies, `INDEX.md`, `ledger.md`. Nothing under `research/`.
- The vendored `template/.agents/skills/spec-review/SKILL.md` edit goes through
  `patches/mattpocock/spec-review.SKILL.md.patch`, listed in `series` and described in `SOURCES.md`
  item 6. Proof: `./factory918.sh sync` re-applied all 34 patches and left `git status --porcelain`
  empty.
- No pstack patch or upstream wording touched. `template/docs/agents/ledger.md` is the template's
  3-line starter and correctly stayed untouched while this repo's own log gained two lines.

## 4. Receipts

- **Three rounds, ending zero.** `round: 1 of 3` / `act-on items: 3`; `round: 2 of 3` /
  `act-on items: 5`; `round: 3 of 3` / `act-on items: 0` with all four Act on items marked `fixed:`.
  Three comments, no `restart`, no `would-break fixed after`.
- **Round three's fix, unreviewed under the three-round rule.** It is the loosening of the heading
  match at `template/.agents/skills/spec-review/scripts/review-brief.sh:448`:

  ```
  # round two:   ^([ \t>]|[-*+]|[0-9]+[.)])*##+[^a-z]*writer[^a-z]*flags?([^a-z]|$)
  # round three: ^([ \t>]|[-*+]|[0-9]+[.)])*##+.*writer.*flag
  ```

  **It cannot fail open.** The round-three pattern is strictly broader than the round-two one: every
  `[^a-z]*` is subsumed by `.*` and `flags?([^a-z]|$)` by `flag`. Verified differentially, not by
  reading alone: 200,000 generated lines built from heading atoms (hashes, quote and list markers,
  `writer`/`Writer's`/`writers`, `flag`/`flags`/`flagship`, decoration, dates) run through both
  patterns under this machine's awk gave **0 lines matching the old pattern and not the new**, and
  1,648 the other way. Since the guard fires only when `heads` is non-empty, a broader match can only
  add refusals. The exposure it does add is the documented one: `## The writer should flag risks` and
  `### Writer flagship review` now refuse in a body with no readable list. P139 records both as
  accepted, and the refusal message names the one form that is read.
- **CI green on the reviewed head itself.** `gh api .../commits/30bdcae/check-runs`: `Fixture success
  30bdcae...`, `Factory success 30bdcae...`. `gh pr view 142 -q .headRefOid` = 30bdcae, so the checks
  ran on this exact tree, not on the owner's pre-rebase 7505ee5.
- **`Closes #139` linked**: `closingIssuesReferences` = issue 139. **Base**: `main`.
- Re-ran locally at 30bdcae: `tests/spec-review/review-brief.sh` ok 1872; `review-comment.sh` ok 298;
  `tests/hooks/delegation.sh` ok 76; `tests/shellcheck/gate.sh` ok 17; `tests/poteto-mode/overlap.sh`
  ok 57; `tests/spec-review/no-stale-wording.sh` ok; `.github/shellcheck.sh` over the AGENTS.md set,
  ShellCheck 0.11.0, 24 files, exit 0; `build_knowledge.py` → 119 files with `git status` clean, then
  `check_knowledge.py` ok; `./factory918.sh sync` clean. The fixture flow is the green `Fixture` job.

## 5. PR body

Plain-sentence title ("Refuse a review when a writer flags heading yields no flag"), problem in the
opening paragraph then `## Why`, `## Scope`, `## Tradeoffs`, `## Blast Radius`, `## Overlap`,
`## Review`, `## Verification` naming what ran. One concern. Last three lines are exactly
`Closes #139`, the `🤖 Generated with [Claude Code]` line, and `Claude Opus 5.5 on Claude Code`.
Conforms to `AGENTS.md` "Pull requests".

## 6. Leading-witness check on the SKILL.md sentence

The added sentence (`template/.agents/skills/spec-review/SKILL.md:29`) is: "A ticket body that holds a
line of two or more `#` whose text holds `writer` and, after it, `flag` (in any case, fenced, quoted
or after a list marker) and from which no flag is read is refused the same way, naming each such
line: ...". **Clean.** It sits in step 1, which describes to the orchestrator what `review-brief.sh`
does; it is not reviewer-brief text, and the briefs are built from the script's own templates, not
from SKILL.md. It states behavior only: no expected finding count, no length cap, no limit on what a
reviewer may read. #137's four `lacks` assertions ("all nits", "more than five Act on items", "under
400 words", "runs nothing") still pass in the suite.

## 7. The owner's Decided and Blocked items

- **Decided, C6/f** — judgment already made and recorded correctly (see 1). Nothing further.
- **Decided, the rest** (guard runs after #136's check; one `#` never counts; `ticket.md:15`
  unchanged; the refusal is orchestrator-facing) — all verified above or in 6. Nothing.
- **Blocked, "the root must rebase and confirm green CI"** — **done**. Base is `main`, both checks
  pass on 30bdcae, `git merge-base --is-ancestor origin/main HEAD` is true, and both ledger lines
  survived the conflict resolution (`docs/agents/ledger.md:40-41`).
- **Blocked, "for Manuel: the round-3 match was fixed unreviewed"** — **a real judgment for Manuel**,
  and the only one. My differential run above shows it cannot fail open, so the decision is purely
  about the accepted false positives, which P139 states in full. Not a defect.

## Issues

None.

## Notes

1. **Criterion 2's literal wording is narrower than what shipped, by design.** The criterion says "a
   ticket body with no `### Writer flags` text briefs exactly as before", but rows D6, D7, D13, D14,
   D15 and D16 of the ticket's own table refuse bodies that contain no such literal text. The three
   dated amendments on #139 widened the legend without amending the criteria, so criterion 2 and
   table D now disagree on their face. The table is the later statement and P139 records the
   broadening as accepted; nothing to fix in the code, but a reader of the criteria alone is misled.
2. **The byte-for-byte run was not repeated at the head.** The PR body says so plainly ("the harness
   was not rerun at the head"); the `cmp`/`diff -r` against #140's script was done at 5f0c725, before
   the three widenings. I consider criterion 2 proven anyway, because the script diff is confined to
   the header comment and one `if` block guarded by `[ -n "$heads" ]`, so an empty `heads` leaves the
   path bit-identical. What the widenings changed is *which* bodies have an empty `heads`, which is
   Note 1, not a byte-level difference.
3. **Two shapes still pass silently, and P139 states the rule honestly.** The match needs `writer`
   *then* `flag` in that order, so `### Flags from the writer 2026-09-23` and `### Flags, writer
   2026-09-23` over an unreadable list are neither counted nor read (verified against the shipped
   pattern under this machine's awk; `### Writer's flags`, `### Writers flags`, `###Writer flags`,
   `### **Writer flags**`, indented, quoted and list-marked forms all match). P139's prose says
   "holds `writer` and, later on the line, `flag`", so this is a documented narrowing rather than a
   misstatement — worth Manuel's eye next to the round-3 item, since round 3's own finding was that
   the surrounding prose says "a writer's flags" and a writer copies the phrasing they read.
4. **Two counts in the PR body and the owner's report are superseded by the rebase, not wrong.** Both
   say `delegation.sh` "ok 55"; at 30bdcae it is ok 76, and both say ShellCheck covered "26 files"
   where the current set is 24. `8442f1c` ("Assert the delegation hook answers the same under every
   tier file") is not an ancestor of the owner's head 7505ee5 and arrived with the rebase onto main,
   which accounts for the difference exactly. Everything else in the Verification section reproduced
   number for number (1872, 298, 57, 119).
5. **The accepted D10 hole is real and recorded.** One readable list in a body lets a second,
   unreadable list pass, because the rule counts the body and not each heading. Asserted as
   `briefed8 "(D10)"` and stated in P139, the PR's Tradeoffs and the ticket's Contract.
