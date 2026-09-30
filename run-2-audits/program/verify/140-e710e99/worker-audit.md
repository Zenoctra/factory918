verdict: PASS+NOTES

Slice: receipts-and-diff audit. PR #140, head `e710e99ce4293ff2d057b7c9d639a82e97c88f04`, patch base
`6e5c539` (`git merge-base --is-ancestor 6e5c539 HEAD` → 0). Read `git diff 6e5c539..e710e99` whole
(10 files, +105/-32). All commands run in my own worktree at the detached head.

## 1. Criteria, line by line

- **Line 1, "Zero items is the expected result for a clean change."** Gone everywhere, with nothing
  in its place. `template/.agents/skills/spec-review/scripts/review-brief.sh:483` (`definition=`),
  `template/.agents/skills/spec-review/SKILL.md:80`, `patches/mattpocock/spec-review.SKILL.md.patch`
  (the same bullet), `docs/knowledge/core/DECISIONS.md:87` (P18 decision cell) and its generated copy
  `template/docs/factory918/DECISIONS.md:79`, `template/docs/agents/review-ladder.md:6` (dropped
  "and zero items is the expected result for a clean change"). The ticket also names
  `docs/agents/review-ladder.md`; that file does not exist in this repository (`ls docs/agents/` →
  `domain.md issue-tracker.md ledger.md triage-labels.md`), and it does not exist at `6e5c539`
  either. Nothing unmet.
- **Line 2, the read-and-run ban.** `common()` at `review-brief.sh:506` now prints `read_rule`,
  "You may open any file in the repository and run read-only commands, such as grep or the test
  suite.", as each brief's first line. The two item-form repeats are gone (`review-brief.sh:601`,
  `:637`). `SKILL.md:74` adds the reading sentence as the first "Both briefs" bullet, `:75` drops
  "so a reviewer reads one file and runs nothing", `:100` and `:111` drop "read nothing beyond the
  brief but the code around a hunk". All three land in the patch too.
- **Line 3, the reading-pack tail.** `pack_rule` at `review-brief.sh:509` now ends "open the
  repository for what the pack does not carry."; `SKILL.md:87` and the patch match. This is the
  audit's own proposed replacement (audit 1.4), word for word.
- **Line 4, "Under 400 words."** Gone from both item-form echoes (`review-brief.sh:601`, `:637`),
  from `SKILL.md:100` and `:111`, and from the patch.
- **Line 5, the judge heuristics.** `SKILL.md:119` and the patch now read "sort each item on its
  merits; the Dismissed list is shown so the human can overrule you." Both clauses removed. This is
  the audit's proposal (audit section 3), word for word.
- **Manuel's quote + the fails-open line.** `quotes[4]` unchanged, and
  ``edge_rule='An edge case that proceeds silently fails open: file it under `## Fails open`.'``
  (`review-brief.sh:491`) is printed by `report_rules()` two lines after the fifth quote. That is
  the ticket's text verbatim, not the audit's longer proposal. Criterion met.
- **Criterion 3, later rounds stay blind.** The 21 changed lines in `review-brief.sh` touch only
  `definition`, `pack_rule`, the two new variables, `common()`'s first echo, `report_rules()` and
  the two item-form echoes. Nothing touches the `## Settled in earlier rounds` or `## The fix under
  review` code. The test now pins both a round-two and a round-five fix-only brief to an exact
  `## ` heading list (`tests/spec-review/review-brief.sh:692-711, 835-839, 857-861`).
- **Criterion 4, P18.** `docs/knowledge/core/DECISIONS.md:87` carries "Amended 2026-09-23 (#137):",
  names the four removals, says later rounds stay as blind as before, and quotes Manuel three times.
- **Criterion 5, the test.** `tests/spec-review/review-brief.sh` gains `blind_rules()` (edge line two
  after the fifth quote, the reading sentence, and `lacks` for "Under 400 words", "Read nothing
  beyond this brief", "Run nothing", "Zero items", "not the file") applied to both briefs of the main
  run and to all four row-27 pack briefs, plus SKILL.md assertions for the edge line, the reading
  sentence and the absence of "all nits", "more than five Act on items", "under 400 words", "runs
  nothing".
- **`no-stale-wording.sh`** adds ten phrases covering all five lines, both capitalizations of the
  word cap and the zero-items sentence, and both judge heuristics.

## 2. Scope and forbidden edits

Files touched: `.github/workflows/factory-ci.yml`, `SOURCES.md`, `docs/knowledge/core/DECISIONS.md`,
`patches/mattpocock/spec-review.SKILL.md.patch`, `template/.agents/skills/spec-review/SKILL.md`,
`template/.agents/skills/spec-review/scripts/review-brief.sh`, `template/docs/agents/review-ladder.md`,
`template/docs/factory918/DECISIONS.md`, `tests/spec-review/no-stale-wording.sh`,
`tests/spec-review/review-brief.sh`.

- `patches/pstack/**`: `git diff --name-only 6e5c539..e710e99 -- patches/pstack/` → 0 files. Upstream
  pstack wording untouched, as Manuel ruled. The vendored `spec-review/SKILL.md` was changed through
  `patches/mattpocock/`, the required route.
- `.github/workflows/factory-ci.yml` (outside the ask): necessary and correct. The fixture step
  grepped the old definition as a substring; without the change CI would fail. It now uses
  `grep -qxF` on the new definition as a whole line, which is strictly tighter (a re-added trailing
  sentence fails it), plus three positive greps (edge line, reading sentence, `## Fails open`) and
  two negative greps (word cap, reading ban). Judged: in scope, no concern.
- `SOURCES.md` item 6 (outside the ask): the sentence "each brief says to read nothing beyond it"
  became false with this change; it now reads "each brief says the reviewer may open any file and run
  read-only commands." SOURCES.md documents the patch's delta, so leaving it would have been a stale
  record. Judged: in scope, no concern.
- No edit under `docs/knowledge/spec|pages|notes`, `research/`, or `tools/bootstrap/`.
  `template/docs/factory918/DECISIONS.md` is generated, but it is generated *and committed*: I ran
  `python3 tools/build_knowledge.py` (→ `knowledge files: 119 → docs/knowledge`) and
  `./factory918.sh sync` (exit 0), and `git status --porcelain` was empty after each. The generated
  copy matches a rebuild, and the patch re-applies cleanly.

## 3. The replacement sentences, strict no-leading test

- `read_rule` — "You may open any file in the repository and run read-only commands, such as grep or
  the test suite." A permission with no direction, no count, no cap. Passes. Placed first in every
  brief, so it governs everything after it.
- `edge_rule` — "An edge case that proceeds silently fails open: file it under `## Fails open`." A
  routing rule for an item the reviewer already has; it names no expectation. Passes, and it is the
  ticket's text word for word.
- `pack_rule` tail — "open the repository for what the pack does not carry." Mild residual framing
  ("the code to read" / "for what the pack does not carry"), but it sets no limit once `read_rule`
  has granted any file, and it is the audit's own proposed replacement. Passes.
- Judge step — "sort each item on its merits". Passes.
- `SKILL.md:75` — "the brief hands the path `<dir>/diff` to read it from." Drops "runs nothing".
  Passes. The script's own message at `review-brief.sh:543` ("read it from `<dir>/diff`.") was
  already neutral and is unchanged.
- **The two audit proposals the owner rejected: I agree with both rejections.**
  - Audit 1.1's replacement, "…the report's length follows from the diff, not from any expected
    count", still names a count and still speaks about report length. #137 says "delete it. Say
    nothing about how many items to expect." Deleting outright is the compliant reading.
  - Audit 1.6's replacement, "Keep each item's body under about 80 words…", is a cap. #137 says
    "delete the cap on the report and on the number of items." Rejecting it is correct.
  - The owner also passed over audit 1.3's longer narrower form in favour of a plain permission
    sentence. That is a wording choice, not a criterion; the plain form is less leading, not more.

## 4. Receipts

- **Round one**, https://github.com/Zenoctra/factory918/pull/140#issuecomment-5802644824:
  `reviewed: e710e99ce4293ff2d057b7c9d639a82e97c88f04`, `round: 1 of 3`, `act-on items: 0`, two Noted
  items, no `restart`, no `next round owed:` line. The reviewed SHA is the head under verification.
- **Is a round two owed?** No. `review-comment.sh:279` sets `owed` only when `fixed_here -ne 0`; the
  judgment has zero Act on items and zero fixed, so no `next round owed:` line is emitted, and
  `review-ladder.md:6` says the review stops earlier at `act-on items: 0`. I could not run
  `review-brief.sh` over the real comment history via a fake gh: the worktree guard refuses a clone
  to a temp path outside this worktree, and running it in place would write `.scratch/review/` state
  into a read-only verification. The round-two and fix-only paths are covered instead by
  `tests/spec-review/review-brief.sh` (1836 assertions, including the new exact `## ` heading lists
  for both), which I ran green. See Notes.
- **CI green at the head.** `gh pr checks 140` → Factory pass, Fixture pass. Run 35917215163:
  `head_sha e710e99ce4293ff2d057b7c9d639a82e97c88f04`, `conclusion success`, `status completed`.
- **`closingIssuesReferences`**: exactly one, #137.
- **Base**: `feat/risk-dispositions` (PR #136), `mergeable: MERGEABLE`, `state: OPEN`, not a draft.

Checks I ran, all from `AGENTS.md` "Verifying":

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 24`, exit 0.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`.
- `bash tests/spec-review/review-comment.sh` → `ok 298 assertions`.
- `bash tests/spec-review/review-brief.sh` → `ok 1836 assertions`.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, `git status` clean.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `./factory918.sh sync` → exit 0, `git status` clean.
- The fixture flow: not re-run locally; CI's Fixture job passed at this head, and the changed fixture
  assertions are in that job.

## 5. PR body

Against `AGENTS.md` "Pull requests": plain-sentence title "Stop our review briefs from leading the
witness" (no `type(scope):`) ✓; `## Problem` then `## Fix` ✓; `## Overlap` before `## Verification` ✓;
Verification names each check with its outcome, not only the command ✓; one concern ✓; last three
lines are `Closes #137`, the Claude Code attribution, and `Claude Opus 5.5 on Claude Code` ✓. The
opening is two plain sentences for a person ✓. The `## Overlap` block is fenced, so no `## ` line
leaks into a section. There is no `## Blast Radius` section — see Notes.

## 6. Generated files

Covered in section 2: `build_knowledge.py`, `check_knowledge.py` and `factory918.sh sync` all leave
`git status` clean at this head.

## 7. The owner's Decided items

- Rejecting the two audit proposals: agreed, reasons in section 3. Nothing.
- Adding `.github/workflows/factory-ci.yml`: correct and necessary. Nothing.
- Fixing `SOURCES.md` item 6: correct; the sentence was false without it. Nothing.
- `docs/agents/review-ladder.md` does not exist: confirmed. The ticket's file list is wrong, not the
  PR. Nothing.
- Leaving P107's history, which mentions the old sentences as a rejected option: correct. It is a
  record of what was decided, not brief text, and `no-stale-wording.sh` uses the `...unless` form so
  it does not trip. Nothing.
- Leaving the frozen eval rounds: the claim checks out. `tests/eval/reviewer/rebuild.sh:3` runs
  `review-brief.sh` "as it stood at the recipe's `script_at`", from `git archive "$script_at"`, so a
  change to the live script cannot make a frozen round differ. Rebuilding them is #138's. Nothing.
- **The eval runner prompt `tests/eval/reviewer/reviewer.py:642`, left unchanged — does it lead?**
  No. It is: "Read `<checkout>/<round>/<axis>-brief.md` whole and follow it. You are working in
  `<checkout>`; every relative path in the brief is relative to it." No expected count, no length or
  item cap, no limit on reading or running; it delegates entirely to the brief, which this PR
  unleads. The audit counted it among the three "ours" templates but flagged only two of them (the
  two briefs), so leaving it is consistent with the audit and with #137. Nothing.

## Issues

None.

## Notes

1. **No `## Blast Radius` section in the PR body.** The poteto `opening-a-pr` playbook lists it, and
   the parent PR #136 carries one, but the factory's own `AGENTS.md` "Pull requests" line does not
   require it (it asks for title, problem then fix, Verification), the playbook says to drop an empty
   section, and recent merged factory PRs are split both ways (#136 and #126 have it; #129 and #125
   do not). The diff is not cross-cutting — no `.claude/hooks/` file, no `.claude/settings.json`, no
   `.agents/skills/factory918/` file — so `review-brief.sh` did not demand a grounding and round one
   ran without refusing. Judgment for the root, not a defect. Likewise there is no `## Records`
   section, which #136, #129 and #125 carry; P18's amendment is described in the `## Fix` bullets and
   in the owner's report.
2. **The judge is still pointed at leading text, through upstream.** `SKILL.md:119` keeps "following
   [`lead-judgment.md`]", and `template/.agents/skills/interrogate/references/lead-judgment.md:20`
   still carries the nit-inflation paragraph our step 5 used to paraphrase. Removing our paraphrase
   while the link stands means the judge can still read the heuristic one hop away. Manuel ruled
   upstream pstack wording stays, and the audit confirms that file is upstream verbatim, so this is
   correct as shipped — flagged as a judgment for Manuel, not a defect.
3. **The retired-wording ban list now lives in three files in four forms** (`no-stale-wording.sh`,
   the CI fixture step, and two `for w in ...` loops in `tests/spec-review/review-brief.sh`). Round
   one noted the same thing [S1]. Each list does refuse the phrases #137 names, so nothing is unmet;
   it is a duplication cost if the ban grows.
4. **The frozen eval fixtures under `tests/eval/reviewer/rounds/` still carry every retired phrase**,
   correctly: `no-stale-wording.sh` scans only `template` and `docs/knowledge/core`, and
   `rebuild.sh` pins each round to its own `script_at`. Regenerating them is #138's job, as the PR
   body says. No false pass: the live brief text is inside the scanned trees.
5. **I could not exercise a round-two brief against the real PR comment history.** The worktree guard
   refused `git clone` to a temp path outside this worktree, and running `review-brief.sh` in place
   would have written review state into a read-only verification. Criterion 3 is verified from the
   diff (no line touches the settled or fix sections) and from the new exact-heading assertions in
   the test, which I ran green. Round one already concluded `act-on items: 0` with no `next round
   owed:` line, and `review-comment.sh:279` emits that line only when an Act on item was fixed, so
   no round two is owed.
