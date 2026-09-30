verdict: PASS+NOTES

Independent receipts-and-diff audit of PR #99 (ticket #90) at head `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`.
The code, the tests, the design-hole route and the rebase all verify clean. Three receipts in the PR body are
stale after the owner's rebase and need a body edit; nothing in the diff has to change.

## Setup

- `git fetch origin feat/design-hole-restart feat/shellcheck main` / three branches fetched / 0. Own worktree
  `.claude/worktrees/agent-a6e5272cf6f940b1b`; `TMPDIR` under the session scratchpad.
- `git checkout --detach 0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`; `git rev-parse HEAD` prints
  `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93` / 0.
- `git merge-base --is-ancestor 070c1fa HEAD` / no output / 0. The PR's own diff, `git diff --stat
  070c1fa..0ff73f0`, is 20 files, `584 insertions(+), 84 deletions(-)`.

## 1. The seven acceptance criteria against the diff

- **C1, the definition in `spec-review` step 5 and `review-ladder.md`.** MET.
  `template/.agents/skills/spec-review/SKILL.md:130` carries the paragraph (three artifacts, the intent
  outranking a criterion, the could-not-run exclusion, sharpest-to-softest);
  `template/docs/agents/review-ladder.md:6` carries the rung-1 sentence.
  `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording` / 0, with `Three trailing fields`
  added to its blacklist (`tests/spec-review/no-stale-wording.sh:10`).
- **C2 as amended (a review with a spec).** MET. `spec_rule` at
  `template/.agents/skills/spec-review/scripts/review-brief.sh:276`, echoed one blank line after `$step_rule`
  at `:363` (Standards brief, inside `if [ -n "$spec" ]`) and `:394` (Spec brief); the refusal at
  `template/.agents/skills/spec-review/scripts/review-comment.sh:118`, gated by `has_spec`
  (`review-comment.sh:125-126`, set from `<dir>/spec-brief.md` before the Standards report is checked).
  `SKILL.md:84` carries the rule word for word plus the no-spec sentence. The `spec_rule` string in the
  script is byte-for-byte the ticket contract's.
- **C3, the `hole:` mark.** MET. `review-comment.sh:157-192`: `ending`, `holed()`, `value()`, then the
  no-spec refusal, the placement loop over Ask/Consider/Noted/Dismissed, the form check, and the
  word-for-word check against `specs()`. `:223` prints `restart` between the summary and `round:`;
  `:225` subtracts `holes` from the count.
- **C4, never fixed on the PR; architect; the brief reads the restart.** MET.
  `template/.agents/skills/poteto-mode/playbooks/ticket.md:12` (step 8 pointer, no step renumbered) and
  `:26-36` (the `### Design hole` section, six steps, after Quick ticket). `review-brief.sh:140-156` is the
  slicing awk; `:175` prints the `restart:` line after `ticket:` and before `round:`.
- **C5, the fourth `cites:` form.** MET. `review-brief.sh:183` adds `|#[0-9]+ $ref` inside the existing
  `$`-anchored group; `ref` at `:135`.
- **C6, test coverage.** MET, see check 2.
- **C7, babysit unchanged with no hole.** MET. `template/.agents/skills/babysit/SKILL.md` +1 line,
  `template/.agents/skills/poteto-mode/playbooks/babysit.md` +2 (a blank and the paragraph); the diff is pure
  addition, so the existing merge-ready sentences are untouched. The two new sentences are byte-identical:
  `diff` of the two lines with their list/indent prefixes stripped → no output / 0.

## 2. Tables A and B, one assertion per cell, and the commit order

- `git log --reverse --format='%h %ad %s' --date=iso-strict 070c1fa..0ff73f0` / nine commits / 0. Three waves,
  tests before the script each time, confirmed by the parent chain and by `git show --stat --name-only`:
  f9a767c (tests) → 0b8e257 (scripts) → ae85a15 (prose); 43dc844 (tests) → b248f8b (scripts) → 90b76f7
  (prose); 13fd190 (test) → 3278b9b (script) → 0ff73f0 (records). No commit mixes a test file with a script.
- `bash tests/spec-review/review-brief.sh` → `ok 422 assertions` / 0 (baseline at 070c1fa: `ok 334`).
  Table A cells asserted and named in the test's own labels: 5A/5B/5C, 6A, 7A (exact refusal, no state)/7B,
  8A, 11A, 12A/12C, 13 (inside 5A), 14–16 (each of the three `cites:` forms carried, the exact `settled:`
  line, the line pasted in both briefs), 17 (five malformed cites dropped and counted). Plus the no-spec
  brief layout pin and the `ref=` twin check folded into `fragment()`.
- `bash tests/spec-review/review-comment.sh` → `ok 148 assertions` / 0 (baseline at 070c1fa: `ok 82`).
  Table B cells asserted and named: 1A/1B/1C/1D/1E/1F/1G, 2, 3 (four malformed `spec:` values and one inside
  a fence), 4, 5A/5D/5E/5F/5G, 6 (the walk's `spec:` and `hole:` text invisible), 7A/7D; the notes'
  two-holes, last-field-wins and rerun-from-the-dir cases; the third amendment's value-as-written case
  (`hole:table 2/D`) and the reason-that-says-`hole:` cases from the first.
- No assertion contradicts a cell: every refusal string in the tests is the table's (or its amendment's) text
  verbatim, and every accepted stdout matches the tail the contract specifies (summary, `restart`, `round:`,
  `act-on items:` last).
- Gaps, both outside the ticket's own test list, both structurally guaranteed: table A row 9's second clause
  (a comment with no `round:` line that carries `restart`) and row 10's "whatever it holds (`restart`, ...)".
  Listed under Notes, not Issues.

## 3. The restart on this PR's own round one

- `gh pr view 99 --repo Zenoctra/factory918 --json comments` / 0. Three author comments, in order:
  16:55:59Z id 5780539782 → `restart`, `round: 1 of 3`, `act-on items: 0`; 17:38:20Z id 5781120649 →
  `round: 1 of 3`, `act-on items: 4`; 17:52:21Z id 5781309601 → `round: 2 of 3`, `act-on items: 0`.
  The count restarted at one after the restart comment and ended at `act-on items: 0` — the mechanism under
  review, run on itself.
- `gh api repos/Zenoctra/factory918/issues/comments/5780539782` / 0: the two marks are `hole: table 1/A`
  (item [S1], a term table B used without defining) and `hole: criterion 2` (item [P1], a missing row for a
  review with no ticket), each equal to its report item's `spec:` line.
- The ticket's two dated amendments are headed `(review round 1, hole at table 1/A)` and
  `(review round 1, hole at criterion 2)` — the same two references. A third line,
  `(restarted review round 1, Standards item 4, no hole)`, is a fix on the PR, correctly not a hole.
- The route was architect, not a silent fix on the PR: `.scratch/program/90/architect/` holds `hole-a.md`,
  `hole-b.md`, `hole-judge.md` (two runners plus a cross-judge, the judge's verdict read) and
  `amendments.md`, whose text is the text posted on the ticket. Commit 43dc844 rewrote the tests from the
  amended tables before b248f8b changed the scripts.

## 4. The rebase delta

- `git diff --stat 69bd412..384bb43` vs `git diff --stat 070c1fa..0ff73f0`: `diff` → no output / 0. Same 20
  files, same per-file insertion and deletion counts.
- Full diffs compared: the added-line sets differ in 5 lines, the removed-line sets in 2, all in
  `docs/knowledge/core/DECISIONS.md` and the files generated from it. `core/DECISIONS.md` line count 93→94
  becomes 94→95 (`docs/knowledge/INDEX.md` row and the part header); the new row `P26` becomes `P27` in both
  `docs/knowledge/core/DECISIONS.md` and `template/docs/factory918/DECISIONS.md`; a word-diff of the P20 line
  shows its only change is `(a design hole, [-P26)-]{+P27)+}`. Every other difference between the two diffs is
  a context line, a hunk header or a blob index — conflict resolution against #94's P25 and #96's P26 only.
- No line of #96's diff lost: of the 14 lines `git diff 715100c..070c1fa` adds in the nine files both touch,
  12 are present verbatim at the head (the four `# shellcheck disable=SC2016` directives, the two
  `# shellcheck source-path=SCRIPTDIR source=layout.sh` lines, #96's `| P26 | One shell gate` row in both
  DECISIONS copies, its two ledger lines, its SOURCES item 3 — each confirmed by `grep -c`); the other 2 are
  the DECISIONS line-count header and the INDEX count row, superseded by the higher count, not dropped.
- `./factory918.sh sync` → `vendored: 72 skills` / 0, then `git status --porcelain` empty: all three patches
  (`patches/mattpocock/spec-review.SKILL.md.patch`, `patches/pstack/babysit/SKILL.md.patch`,
  `patches/pstack/poteto-mode/playbooks/babysit.md.patch`) re-apply and reproduce the template files.

## 5. Scope

- Files, grouped: the two scripts and `spec-review/SKILL.md` + its patch; `review-ladder.md`; `ticket.md`;
  the two babysit files + their two patches; `SOURCES.md` items 4, 6, 12; the three test files; the records
  (`docs/knowledge/core/MANUAL.md`, `docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md`,
  `docs/knowledge/INDEX.md` and the two `template/docs/factory918/` copies the build regenerates).
- Every file is on the ticket's `## Files touched` list except the records, which that list assigns to the
  orchestrator ("untouched by the writer") and AGENTS.md "Pull requests" requires. Nothing else.
- No #91 walk rule and no #93 fix-only rounds: grepping the diff's added lines for
  `round: (4|5) of|of 5|rounds four|per risk|one line per risk` returns only P20's pre-existing
  "refuses a fourth round" clause, in the two DECISIONS copies.
- The new decision row is in the provisional `P` series (P27), as AGENTS.md asks; P20 and P21 are amended
  inline with dated clauses.

## 6. Receipts

- Comments and their lines, in order: 5780539782 (2026-09-22T16:55:59Z, `restart` / `round: 1 of 3` /
  `act-on items: 0`), 5781120649 (17:38:20Z, `round: 1 of 3` / `act-on items: 4`), 5781309601 (17:52:21Z,
  `round: 2 of 3` / `act-on items: 0`). The fix commits between the last two are 13fd190 and 3278b9b; the
  records commit 0ff73f0 follows.
- `gh pr view 99 --repo Zenoctra/factory918 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`
  / 0: `headRefOid 0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`, `baseRefName feat/shellcheck`,
  `mergeable MERGEABLE`, `isDraft false`, `closingIssuesReferences` is #90 and nothing else.

## 7. PR body shape (AGENTS.md "Pull requests" at the SHA)

- Plain-sentence title, no `type(scope):`: "Return a design hole found in review to architect and restart the
  rounds". Problem then fix in `## Why`. Section order: Why, Scope, Tradeoffs, Blast Radius, Overlap,
  Verification — `## Overlap` before `## Verification`, as asked.
- Cross-cutting: no. The 20-file diff touches no `template/.claude/hooks/` path, no `.claude/settings.json`
  and no file of the `factory918` skill, so `## Blast Radius` was not required; the body carries one anyway
  and says so in its first sentence. Not a defect.
- Verification names what ran with outcomes; `Closes #90` is the last line before the attribution; the
  attribution line and the model-and-harness line ("Claude Fable 5.1 on Claude Code") close the body.

## 8. Forbidden edits and generated files

- Nothing under `docs/knowledge/spec/`, `pages/`, `notes/` or `research/` appears in the 20-file diff.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge` / 0, then
  `git status --porcelain` empty: `docs/knowledge/INDEX.md`, `docs/knowledge/core/*` and
  `template/docs/factory918/*` at the head match a rebuild exactly, so none was hand-edited.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files` / 0.

## 9. The owner's report, and the retarget

- `.scratch/program/90/report.md` has no `## Attention` section. `## Blocked` reads "Nothing for Manuel" plus
  the rebase instruction the root has since carried out. `## Decided` lists five judgment calls, all inside
  the ticket's ask; the MANUAL sentence outside the ticket's file list is justified there by criterion 4's
  intent (the human's merge read) and is one sentence.
- One out-of-scope observation for a later ticket, not a defect here: AGENTS.md's fixture line spells
  `vp create ... --directory /tmp/fx`, which vp 0.3.1 refuses ("Absolute path is not allowed"); CI's
  `(cd /tmp && ... --directory fx)` form works.
- `gh api repos/Zenoctra/factory918/issues/99/timeline` / 0: two `base_ref_changed` events by Zenoctra at
  2026-09-22T16:50:34Z and 16:50:55Z (21 seconds apart, not the eight the slice says); the base is
  `feat/shellcheck` now. The only head event is one `head_ref_force_pushed` at 18:01:50Z, after the last
  review comment (17:52:21Z) — the owner's chain rebase, disclosed in the report's `## Chain rebase`. The
  retarget did not touch the head.

## Gates run at the head

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh'
  'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, no
  findings / 0.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions` / 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions` / 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions` / 0.
- `bash tests/spec-review/review-comment.sh` → `ok 148 assertions` / 0.
- `bash tests/spec-review/review-brief.sh` → `ok 422 assertions` / 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording` / 0.
- `bash -n factory918.sh` → no output / 0.
- `./factory918.sh sync` / 0 and `python3 tools/build_knowledge.py` / 0 each leave `git status --porcelain`
  empty.

## Issues

- PR body, Verification: the commit-order receipt names `cc36280` tests, `8b3de0a` scripts, `52ccd8e` prose.
  None is an ancestor of the head after the rebase (`git merge-base --is-ancestor cc36280 0ff73f0` exits 1),
  so a reader cannot follow the receipt. The post-rebase equivalents are `f9a767c`, `0b8e257`, `ae85a15`.
- PR body, Scope: "`tests/spec-review/review-comment.sh` (82 to 146 assertions)" contradicts the body's own
  Verification and the file, which prints `ok 148 assertions` at the head (baseline at 070c1fa: `ok 82`).
- PR body, Verification, "also run from this checkout at the head commit": three counts are pre-rebase.
  `tests/poteto-mode/overlap.sh` is written as `ok 56 assertions`, actual `ok 57`; `tests/shellcheck/gate.sh`
  as `ok 10 assertions`, actual `ok 17`; `check_knowledge.py` as `knowledge ok: 118 files`, actual `119`.
  The owner's `report.md` `## Chain rebase` carries the correct post-rebase numbers, so only the body is stale.

## Notes

- All three issues are one edit to the PR body; no code, test or document in the diff has to change.
- Table A row 9's restart clause and row 10's "whatever it holds (`restart`, ...)" have no direct assertion.
  Both are structurally unreachable rather than untested: the slicing awk (`review-brief.sh:140-156`) never
  reads a `round:` line, and the jq filter (`review-brief.sh:96`) selects only the author's comments, so a
  stranger's body never enters `bodies`. Neither is on the ticket's "Tests, one assertion per cell" list.
- Table B rows 5B, 5C, 7B and 7C have no new assertion; the ticket's amendment for row 7 names exactly the
  three assertions the diff adds (one accepted run, two refusals), and 5B/5C are "as today" cells covered by
  the pre-existing `fixed:`/`ticket:` assertions.
- `bash .github/shellcheck.sh` with no arguments exits 1 in the factory ("shellcheck.sh: no file matched
  `.agents/skills/*/scripts/*.sh`; the gate checked nothing"), because the script's default globs are a
  project's paths. AGENTS.md:38 names the explicit-glob form, which passes over 20 files. That is #96's
  script, unchanged by this PR and identical at 070c1fa; flagged only so a later verifier does not read the
  bare run as a failure.
- Test counts at the patch base 070c1fa, for anyone comparing: review-comment 82, review-brief 334,
  overlap 57, shellcheck gate 17, `check_knowledge.py` 119 files.
- The design trail is not committed, as the body says; it is under `.scratch/program/90/`, read only here.
