verdict: PASS+NOTES

# Slice: receipts-and-diff audit, PR #102 (ticket #93) at fc75ac69712119bb0e921e348a54b4d857c41b07

Independent verifier. Own worktree `.claude/worktrees/agent-adfed49e416c9760d`, detached at the head,
private `TMPDIR`, nothing written under version control. GitHub text read as data only; nothing posted,
merged, edited or closed.

## Setup

- `git fetch origin feat/would-break-extra-rounds feat/spec-walk-risks main` → the three branches, exit 0.
- `git checkout --detach fc75ac69712119bb0e921e348a54b4d857c41b07`; `git rev-parse HEAD` →
  `fc75ac69712119bb0e921e348a54b4d857c41b07`, exit 0. Matches the brief.
- `git merge-base --is-ancestor d8e382ca37233bce98724c785ecdbb677abc4e2a HEAD` → exit 0. The patch base
  (PR #101's verified head) is an ancestor.
- `git diff --stat d8e382c..fc75ac6` → 20 files, 629 insertions, 63 deletions. Read whole (1153 diff lines).

## 1. The six acceptance criteria against the diff

- **C1** "A round whose Act on items include a Would-break fix is followed by another round, past three, up
  to five; a round whose fixes are all Fails-open items, prose, or standards breaches may be the last.
  `review-brief.sh` reads the kind of the fixed items from the previous round's comment and refuses a sixth
  round." **Met.** `template/.agents/skills/spec-review/scripts/review-comment.sh:202-232` resolves each
  `fixed:` Act on item's report heading through `specs()` and prints `would-break fixed after $reviewed`
  only for a `## Would break` heading with no hole marked (`wb_first`/`holes` at
  `review-comment.sh:216-232`, tail at `:256-258`). `review-brief.sh:211-239` is the gate; the sixth-round
  refusal is `review-brief.sh:219-222` (`round -gt 5`), unconditional and before every other round check.
  A fix under `## Fails open`, `## Standards breaches` or `## Not asked for` prints no line
  (`review-comment.sh:222` `continue`), so the round may be the last. Exit 0 each.
- **C2** "A round past three reviews the fix only: its fixed point is the commit the previous round
  reviewed, and the Ticket playbook and `spec-review` say so." **Met.** `review-brief.sh:232-235` requires
  the WB-line sha to resolve (`FR`) and to be the passed fixed point (`FP`);
  `review-brief.sh` adds `## The fix under review` from round four in `common()`, after `## Changed files`
  and before `## Blast radius`/`## Diff`. Prose: `template/.agents/skills/spec-review/SKILL.md:25`
  (step 1) and `template/.agents/skills/poteto-mode/playbooks/ticket.md:36-42` (the new `### Would-break fix`
  section), plus `ticket.md:12` step 8's routing line.
- **C3** "No rule compares hard-finding counts between rounds … the two stops." **Met.**
  `SKILL.md:133` (step 5, the new paragraph after the design-hole paragraph) carries both stops verbatim:
  round three look-for-the-cause, round five fix-mark-post-report-`gh pr ready --undo`-continue-wait. No
  script reads or compares a hard count, and the summary line is byte-identical in every `accept`
  expectation in the comment test (no would-break count is printed anywhere).
- **C4** "`babysit`'s merge-ready condition reads the same comment lines and is unchanged for a PR that ends
  at round three." **Met.** `template/.agents/skills/babysit/SKILL.md:40` and
  `template/.agents/skills/poteto-mode/playbooks/babysit.md:16` carry one byte-identical sentence, pinned by
  `tests/spec-review/review-brief.sh` (`babysit_rule`, two `has` calls). `cap=3; [ "$round" -le 3 ] || cap=5`
  keeps `round: 3 of 3` for every PR that ends at three, and the `F4` string is byte-identical
  (`review-brief.sh:227`). Proven by the 476 base assertions passing at the head (see Regression).
- **C5** "`tests/spec-review/` covers a round four with a fix-only fixed point and the round-five stop."
  **Met.** `tests/spec-review/review-brief.sh` cells 3A (round four), 9A (round five), 4A/5A/10A (refused
  fixed points), 11A/11B (the sixth refused); `tests/spec-review/review-comment.sh` cells 3C/3D.
- **C6** "P20 amended; `docs/agents/review-ladder.md` says the same in one sentence." **Met.**
  `docs/knowledge/core/DECISIONS.md:87` P20 gains "Amended 2026-09-22 (#93): …" in both the Choice and the
  Reason cells; `template/docs/agents/review-ladder.md:6` rung 1 carries one sentence. P30 added as a new
  Provisional row (`DECISIONS.md:98`).

## 2. The `## Testing decisions` tables, one assertion per cell

- Commit order, `git log --reverse --format='%h %ad %s' --date=iso-strict d8e382c..HEAD`:
  `41ce420` tests (15:03:46), `27c43af` scripts (15:06:49), `1998c69` prose (15:10:35), `7b01fd6` records
  (15:19:02), `fc75ac6` round-one fix (15:32:19). `git show --stat 41ce420` touches only the three test
  files; `git show --stat 27c43af` touches only the two scripts. Tests strictly before implementation.
- **Red before green, run, not claimed.** Detached at `41ce420`: `bash tests/spec-review/review-comment.sh`
  → exit 1, `FAIL an Act on item fixed on this PR is not counted, round 3`, the diff being the missing
  `would-break fixed after 0123…4567` line. `bash tests/spec-review/review-brief.sh` → exit 1,
  `FAIL: the reviewed file does not hold HEAD (20)`. The tests fail at the tests-only commit for exactly
  the behavior the scripts then add.
- **Table A**: every cell the ticket's `### Tests, one assertion per cell` list names has an assertion,
  labelled by row and column: 1B (`--round 5`→`F5`, `--round 6`→`F6`), 2B, 3A/3B/3C, 4A (two refs), 5A, 6A,
  7A, 8A/8B, 9A, 10A, 11A (two histories)/11B, 12A, 13A/13C, 14A (four forms), 15A (three placements), 16C,
  17A, 18A, 19A (both orders), 20 (round one and the sweep form).
- **Table B**: 1C, 1D, 2B (Fails-open and Standards-breaches), 2C, 3B×2 (Standards and Spec), 3C, 3D,
  3E (four contents), 3F, 5B, 5E, 6B, 7B, 8, 9, plus the rerun-from-dir after 3B. The three assertions the
  ticket says move are exactly the three that move, each relabelled with its cell: "an Act on item fixed on
  this PR is not counted, round 3" (3B), "a counted item with a spec line, fixed (1B; #93 3A…)" (3A), "a
  hole before a trailing fixed field counts as fixed" (4A). No other pre-existing expectation changed.
- **No assertion the table does not say.** Every new assertion maps to a cell or to an anti-drift pin the
  ticket's Tests paragraph names (`fragment()` holding `cap=3;`, `has $fix_rule` on `SKILL.md`, the babysit
  sentence in both copies). Cells with no assertion: see Issues.
- **The amendment.** Ticket #93 carries one dated line, "Amended 2026-09-22 by #93 (review round 1,
  Standards item 1, no hole)", recording three changes: (a) `ticket.md`'s `### Would-break fix` section now
  scopes the fix-only command to a line on a round-three or round-four comment, a line on a round-one or
  round-two comment only marking the PR not review-ready; (b) the ladder's rung 1 says `round: N of 3`
  (`of 5` from round four); (c) the deciding-comment awk matches `fixed: [0-9a-f]+$` rather than an
  interval expression. **Neither a design hole nor a criterion re-derivation, and no restart was owed.**
  Table A row 12 already said a round-one or round-two line changes nothing before round four; the cell
  stood and the prose in `ticket.md` failed it, which the ticket's own preamble classes as "a finding that
  leaves the tables standing while the code fails a cell … an implementation bug fixed on the PR". P27's
  hole triggers are a cell, a term the cells use, a signature/usage, or an acceptance criterion; the
  Contract's per-file prose list is none of those. (b) and (c) are plainly prose and implementation. The
  owner's "no restart happened" is correct; no `restart` comment exists on the PR and none was owed. The
  dated amendment also brought the Contract's prose list back in line with row 12, which is more than the
  rule required and keeps the artifact honest.

## 3. Scope

Every file the diff touches, grouped:

- **Scripts** (ticket's list): `template/.agents/skills/spec-review/scripts/review-brief.sh`,
  `…/review-comment.sh`.
- **Skill and playbook prose** (ticket's list): `template/.agents/skills/spec-review/SKILL.md`,
  `…/poteto-mode/playbooks/ticket.md`, `…/poteto-mode/playbooks/babysit.md`, `…/babysit/SKILL.md`,
  `template/docs/agents/review-ladder.md`.
- **Patches and provenance** (ticket's list): `patches/mattpocock/spec-review.SKILL.md.patch`,
  `patches/pstack/babysit/SKILL.md.patch`, `patches/pstack/poteto-mode/playbooks/babysit.md.patch`,
  `SOURCES.md` items 4, 6, 12.
- **Tests** (ticket's list): `tests/spec-review/review-brief.sh`, `…/review-comment.sh`,
  `…/no-stale-wording.sh`.
- **Records**: `docs/knowledge/core/DECISIONS.md` (P20 amendment, P30 new),
  `docs/knowledge/core/MANUAL.md` (merge checklist), `docs/agents/ledger.md` (one appended line).
- **Generated**: `docs/knowledge/INDEX.md`, `template/docs/factory918/DECISIONS.md`,
  `template/docs/factory918/MANUAL.md` — all rebuilt, see 6.

`docs/agents/ledger.md` is the only file outside the ticket's `### Files touched` list. It is one appended
line about the killed architect lane, which `AGENTS.md` "Pull requests" requires ("a surprise goes to
`docs/agents/ledger.md`"). Not a scope breach.

- **#99's restart logic unchanged beyond need.** `review-comment.sh`'s `holes="$(holed "Act on" | grep -c .
  || true)"` moves from the count block up to `:216`, so the WB check can read it; the printed behavior is
  identical (`[ "$holes" -eq 0 ] || echo restart` becomes `if [ "$holes" -gt 0 ]; then echo restart; elif …`,
  `review-comment.sh:256-257`). `review-brief.sh`'s restart slicing, `restarted`, and the `restart:` line are
  untouched. Table A 13A/13C and table B 5B/5E assert restart still outranks the new line.
- **#101's walk rule unchanged.** `risk_rule`, the `## Walk` bullet, the `## Risks` heading search and the
  `## Blast radius` section are byte-identical in the diff; the fix section is inserted before them, not
  inside them.
- **Not a cross-cutting diff.** No path under a `.claude/hooks/` directory, no `settings.json`, nothing under
  `.agents/skills/factory918/` — the predicate `review-brief.sh` itself holds. The PR body says so and still
  supplies a `## Blast Radius` section; harmless.

## 4. Receipts

- `gh pr view 102 --repo Zenoctra/factory918 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`
  → `headRefOid fc75ac69712119bb0e921e348a54b4d857c41b07`, `baseRefName feat/spec-walk-risks`,
  `mergeable MERGEABLE`, `isDraft false`, `closingIssuesReferences` = **#93 only**. Exit 0.
- Two review comments, both by the author's account `Zenoctra` (the PR author), no strangers' comments:
  - Round one, `issuecomment-5783722681`: `round: 1 of 3`, `act-on items: 0`, `hard findings: 0` on both
    axes, three Standards items each ending `fixed: fc75ac6`, one smell Noted, signed
    "Claude Fable 5.1 on Claude Code". No `would-break fixed after` line — correct: all three items sit
    under `## Standards breaches`, not `## Would break`.
  - Round two, `issuecomment-5783855182`: `round: 2 of 3`, `act-on items: 0`, `hard findings: 0` on both
    axes, three Standards points Noted, reviewed the latest commit `fc75ac6` (named in its opening
    sentences), signed the same way. No WB line, no `restart`.
- CI at both heads, `gh run list --branch feat/would-break-extra-rounds`:
  `35779526784` on `7b01fd6` → completed/success; `35781166757` on `fc75ac6` → completed/success.
  Round one briefed `7b01fd6`, its fixes landed in `fc75ac6`, round two reviewed `fc75ac6`; both are green.
- **The round-one/round-two judgment call.** Round one marked three non-hard Act on items `fixed: fc75ac6`
  and its closing sentences said the review could end there; round two ran from the same fixed point and
  reviewed the fixes. **That is the rule applied correctly.** Manuel's Decision quote on #93 lets an
  unreviewed fix stand only at round three ("only if its already review 3"), and this PR's own
  `SKILL.md` step 5 says "From round three on … the round may be the last". Ending at round one would have
  shipped three unreviewed fixes; round two reviewed them and reached `act-on items: 0` on the latest
  commit. The correction is recorded in round two's own opening sentences and in the owner's report, so the
  record is honest. See Issue 3 for the machine gap this exposes.

## 5. PR body shape, per `AGENTS.md` "Pull requests" at the SHA

- Plain-sentence title: "A Would-break fix gets another review round, and five rounds of them stop for a
  report" — a sentence, not `type(scope):`. OK
- Problem then fix: `## Why`, two paragraphs, problem first. OK
- `## Blast Radius` present though the diff is not cross-cutting (no hooks file, no `settings.json`, no
  `factory918` skill file); it says so in its first sentence. OK (not required, correctly labelled)
- `## Overlap` (line 41) before `## Verification` (line 53), the check output verbatim in a fence. OK
- Verification with outcomes: each criterion quoted with how it was proven, plus a run list with the
  printed outcome of each command. OK — every outcome it claims I reproduced (see Verification runs).
- `Closes #93` last before the attribution (line 70), then `🤖 Generated with [Claude Code]` (72), then
  `Claude Fable 5.1 on Claude Code` (74). OK
- One concern. OK

## 6. Forbidden edits and generated files

- Nothing under `docs/knowledge/spec/`, `docs/knowledge/pages/`, `docs/knowledge/notes/` or `research/` is
  in the diff (full 20-file list above).
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, then `git status
  --porcelain` prints nothing. The generated copies (`docs/knowledge/INDEX.md`, `core/DECISIONS.md`'s
  `<!-- lines: 98 -->` header, `template/docs/factory918/DECISIONS.md`, `…/MANUAL.md`) match a rebuild.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `./factory918.sh sync` → `vendored: 72 skills`, all patches `applied`, then `git status --porcelain`
  prints nothing. The three changed patches regenerate their vendored files exactly.

## Verification runs (all from this worktree at fc75ac6)

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh'
  'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, exit 0.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash -n factory918.sh` → exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 648 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- **Regression**, detached at the base `d8e382c`: `bash tests/spec-review/review-brief.sh` → `ok 476
  assertions`; `bash tests/spec-review/review-comment.sh` → `ok 150 assertions`. The PR body's
  "476 to 648" and "150 to 192" are exact.
- Tree clean at the head after every run (`git status --porcelain` silent).

## Issues

1. Table A row 13 column B has no assertion: a `--round N` run on a history whose last comment is a restart
   after a `(3W s)` comment (`X`, `R(N)`, no FIX / 0). `grep -n '(13B)' tests/spec-review/review-brief.sh`
   → no hit. The ticket's own `### Tests` list omits it too (it labels the `--previous` case 13A while the
   test labels it 13C), so this is a gap in the approved list, not a deviation from it; the composing paths
   (`--round` and the restart slice) are each pinned by #90's assertions.
2. Table B row 5 columns C and D have no assertion: a hole beside a Would-break fix at `<dir>/round` 4 and 5
   (`restart`, `round: 4 of 5` / `round: 5 of 5`, no WB line). `grep -n '(5C)\|(5D)' tests/spec-review/review-comment.sh`
   → only #90's and #91's identically-named cells. Same shape: the ticket's Tests list names only 5B and 5E;
   the cap at rounds four and five is pinned by 1C/1D and the restart-outranks-line rule by 5B, so the
   composition is covered by implication, not directly. Table A row 14 column C and table B rows 1E/2E/6E
   ("as A to D: the file is not read") are omitted the same way.
3. Round one of this PR's own review reached `act-on items: 0` with three Act on items marked `fixed:` at
   round one, which `babysit`'s condition reads as review-ready. Nothing in the machine stops a round-one or
   round-two judgment from ending a review with unreviewed non-hard fixes; only `SKILL.md` step 5's prose
   ("From round three on … the round may be the last") carries Manuel's "only if its already review 3". The
   orchestrator caught it by hand and ran round two. Criterion 1 as worded does not ask for a machine check,
   and table B rows 1A/2A say rounds one and two behave "as today", so this is not a defect against #93 —
   but it is the same class of failure #93 exists to close, one round earlier, and it happened on this PR.

## Notes

- The Contract's `FM` sketch on the ticket guards the check with `case "$wb" in "") ;; *) …`, which would
  skip the refusal when the words are followed by nothing; table A row 14 says that case is `FM`. The
  implementation follows the cell, guarding on `[ -n "$wb_line" ]` (`review-brief.sh:216`) and matching
  `$0 == "would-break fixed after"` in the line awk, and test 14A asserts the empty rest → `FM`. The cell
  wins over the sketch; the owner's report lists the `wb_first`/`wb_line` naming among nine accepted
  deviations, so it was seen.
- Refusal order in `review-brief.sh` is `FM` (216-218), `F6` (219-222), `F4`/`F5` (223-231), `FR` (232),
  `FP` (233), `FT` (234-238), all before `cap=`/`round:` at 240-241, `mkdir -p "$dir"` at 261, the empty-diff
  refusal at 275 and the blast-radius refusal at 301. Matches the contract's stated order, and the test's
  `refused()` helper asserts no `.scratch/review` and no `.claude/state/review` for every one.
- `F5` for the no-comment case prints "the last review comment is round 0" (test `f5 5 0`). The owner names
  this as an accepted wart on an input outside the path; it reads oddly but refuses correctly.
- P20's row title still reads "Three review rounds at most" and its first sentence still says "refuses a
  fourth round" / "not reviewed again", now contradicted by the amendment appended to the same cell. This
  follows the house pattern (the #90 amendment sits the same way) and the retired-wording grep targets the
  exact phrase "at most three rounds", which the title's word order does not hit. Worth a future tidy, not
  a finding here.
- Criterion 4 was already true at the base; the lane kept it as a regression guard rather than sending the
  ticket back. Recorded in the owner's report, consistent with the diff.

## The owner's `## Decided` and `## Blocked` items

- **P30 (the draft as the round-five mark via `gh pr ready --undo`, not exercised on a real PR): a judgment
  for Manuel, not a defect.** The command exists and is usable here: `gh --version` → 2.100.0 (2026-09-03);
  `gh pr ready --help` → `--undo   Convert a pull request to "draft"`, with the caveat "If supported by your
  plan"; `gh repo view Zenoctra/factory918 --json visibility` → `PUBLIC`, so draft PRs are available. The
  guard hook permits it: `grep -rn 'gh pr' template/.claude/hooks/*.sh` → one entry, `'gh pr merge'`. Two
  things for Manuel: (a) P30 is a Provisional row he may overrule, which is exactly where `AGENTS.md` says a
  decision the lane had to make belongs; (b) `docs/M0-findings.md` gained no dated line for
  `gh pr ready --undo` at gh 2.100.0, while `AGENTS.md` "Verifying" says anything verified against a tool
  version gets one, and the #91 ledger lesson says a contract that reads forge state is checked against
  M0-findings first. P30 writes forge state. A one-line M0 entry would close it; low risk either way, since
  the command is prose an orchestrator runs, not code under test.
- **The other Decided items check out against the diff and the receipts:** the design choices (one
  conditional line, the cap by round only, the line never beside `restart`, the reviewed commit recorded
  once, the sweep form refused by the existing fixed-point check) are each visible in the scripts and
  asserted; criterion 4 kept as a guard; round one's correction recorded honestly in round two's comment;
  interrogate skipped with a stated reason.
- **The base-branch item is worth the root's eye, not a defect here:** the PR is based on
  `feat/spec-walk-risks`, not opened against trunk and retargeted as P29 says. The owner says the program's
  root instructed this and did the one retarget through `main` that created the `Closes #93` link, which the
  `closingIssuesReferences` result confirms. P29 and the root's topology rule want reconciling; that is the
  root's call, not this PR's.
- **Blocked: nothing waits on Manuel for this lane** — consistent with what I can see (no `restart`, no Ask
  items outstanding, `act-on items: 0` on the latest commit, CI green at both heads, `mergeable MERGEABLE`).
