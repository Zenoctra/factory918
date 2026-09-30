verdict: PASS+NOTES

Receipts-and-diff audit of PR #101 (ticket #91) at `7956c6964cea8088e02ae8798102ce36b3c15cad`, patch base
`52ccd8eb509a2871260827a8514c3a1fcaac4d5d`. I read the diff and the ticket rather than the PR body, re-ran every
gate in my own worktree, and checked the receipts against GitHub. Every acceptance criterion is met with a
file:line, every named table cell has an assertion, the tests precede the script and were red without it, and no
file outside the ticket's ask carries behaviour. What is left is record-keeping and wording, listed under Notes.

## Setup

- `git fetch origin feat/spec-walk-risks feat/design-hole-restart main` — three branches fetched, exit 0.
- `git checkout --detach 7956c696...`; `git rev-parse HEAD` → `7956c6964cea8088e02ae8798102ce36b3c15cad`, exit 0.
- `git merge-base --is-ancestor 52ccd8e HEAD` — exit 0. `52ccd8e` is also an ancestor of
  `origin/feat/design-hole-restart` (PR #99's head), so this branch did leave from #99's head.

## 1. Acceptance criteria against the diff

- **Criterion 1** (Walk rule requires one numbered line per risk after the steps). Met.
  `template/.agents/skills/spec-review/scripts/review-brief.sh:296` defines `risk_rule`; `:403` builds the Walk
  bullet unchanged; `:404` `[ -z "$grounding" ] || walk="$walk $risk_rule"` appends it on the same line, Spec
  brief only (the Standards brief is built at `:370`–`:384` and never sees `risk_rule`).
  `template/.agents/skills/spec-review/SKILL.md:101` carries the sentence word for word, and
  `patches/mattpocock/spec-review.SKILL.md.patch` carries the same line. Checked independently that the sentence's
  phrase "the `## Blast radius` section above" is accurate: `common()` emits `## Blast radius` at
  `review-brief.sh:310`, before `report_rules` at `:400`. Exit 0.
- **Criterion 2** (both heading forms found; rule written only with a grounding; test asserts both forms and the
  absent case). Met. `review-brief.sh:248` `$0 == "## Risks" || $0 == "### Risks"`, inside the
  `[ -n "$crossing" ]` block at `:229`, after the empty-grounding refusal at `:238`–`:242` and before
  `state=.claude/state/review` at `:259`; on a miss `:250` `rm -rf "$dir"`, `:251`–`:252` pick the source name,
  `:253` the message, `:254` `exit 1`. The scan reuses the shared `fenced` fragment (`:126`–`:132`); I verified
  `fenced`'s `/^## /` rule cannot swallow `### Risks`, because `^## ` requires a space in position 3.
  "Only when a grounding is present" holds because `grounding` is assigned only inside the cross-cutting block.
  Both forms and the absent case are asserted (see check 2).
- **Criterion 3** (`review-comment.sh` still counts walk lines as steps). Met. `review-comment.sh` is untouched by
  the diff (`git diff --name-status` lists only `tests/spec-review/review-comment.sh`), and
  `tests/spec-review/review-comment.sh:262`–`:281` inserts two risk lines after step 3 of a round-two Spec report
  and asserts the byte-identical comment, `act-on items: 3`, `round: 2 of 3`.
  `bash tests/spec-review/review-comment.sh` → `ok 136 assertions`, exit 0.
- **Criterion 4** (Opening a PR bullet, through its patch, says the headings are demoted). Met.
  `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:18` and the matching hunk of
  `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`. `./factory918.sh sync` then
  `git status --porcelain` printed nothing, exit 0, so the patch and the template agree byte for byte.

## 2. The `## Testing decisions` table, one assertion per cell, and the commit order

- Every cell the ticket's Contract enumerates has a named assertion in `tests/spec-review/review-brief.sh`:
  1A, 1B, 2A, 3A, 3B, 4A (both halves), 5A, 6A, 7A, 8A, 9A, 9B, 10 — a grep of the cell labels returns each
  exactly once as a section comment, and the assertion labels carry the same tags. The remaining column-B cells
  (2B, 4B, 5B, 6B, 7B, 8B, 10B) are defined in the table by reference ("as 1B", "as 3B", "as 10A") and the
  Contract does not ask for separate tests for them; their referents are asserted. No cell is uncovered.
- No assertion tests something the table does not say. The additions I checked one by one: 1A's numbered-risk
  line and the Walk-plus-sentence pin, 3A's `### Risks` heading in the brief, 1B/3B/9B's absence of the sentence,
  5A/6A/4A's refusal text with no state and no briefs, 2A/7A/8A's acceptance, 10's usage block. All correspond to
  a cell.
- Commit order shows tests first: `git log --reverse --format='%h %ad %s' --date=iso-strict 52ccd8e..7956c69` →
  `ccf5bf6` tests 12:09:58, `c0761dd` script 12:11:30, `6add1e3` prose 12:13:07, `469f78d` records 12:26:54,
  `7956c69` CI fixture 12:31:56. `git show --name-only ccf5bf6` touches only the two test files; `c0761dd`
  touches only `review-brief.sh`, `SKILL.md` and its patch.
- I checked the tests were actually red, not merely earlier: `git checkout --detach ccf5bf6` then
  `bash tests/spec-review/review-brief.sh` → `FAIL SKILL.md step 4 carries the risk sentence`, exit 1. At the same
  commit `bash tests/spec-review/review-comment.sh` → `ok 136 assertions`, exit 0, which is consistent with the PR
  body's own statement that criterion 3 was already true at the base and its fixture is a regression check.
  Returned to `7956c69`; `git status --porcelain` empty.

## 3. Scope

Fifteen files, grouped:

- Mechanism (3): `template/.agents/skills/spec-review/scripts/review-brief.sh`,
  `template/.agents/skills/spec-review/SKILL.md`, `patches/mattpocock/spec-review.SKILL.md.patch`.
- Playbooks (3): `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` and its patch,
  `template/.agents/skills/poteto-mode/playbooks/ticket.md`.
- Vendor bookkeeping (1): `SOURCES.md` items 3 and 6, one sentence each, exactly as the Contract asked.
- Tests (2): `tests/spec-review/review-brief.sh` (414 → 468 assertions), `tests/spec-review/review-comment.sh`
  (134 → 136).
- CI fixture (1): `.github/workflows/factory-ci.yml`.
- Records (5): `docs/knowledge/core/DECISIONS.md` (P26, P27, under `## Provisional`), `docs/knowledge/INDEX.md`
  (93 → 95 lines), `template/docs/factory918/DECISIONS.md`, `docs/agents/ledger.md` (two lines),
  `docs/M0-findings.md` (one dated line).

Nothing outside the ticket's ask carries behaviour. The two groups the Contract's Files list does not name are
the CI fixture and the records; both are accounted for (see Notes 1 and 2).

The diff does not re-implement or alter #90's round logic. `review-brief.sh` has exactly four hunks — the header
comment, the Risks detection inside the existing cross-cutting block, the `risk_rule` variable beside
`blast_rule`, and the Walk bullet — and none touches round counting, the `restart` reading or the state file.

## 4. Receipts

- Review comment: one, `https://github.com/Zenoctra/factory918/pull/101#issuecomment-5781207159`, author
  `Zenoctra` (the PR author's account), 2026-09-22T17:44:23Z, ending `round: 1 of 3` then `act-on items: 0` then
  `Claude Fable 5.1 on Claude Code`. The fixed point in its summary line is `52ccd8eb...`, matching the patch
  base. Both axes `hard findings: 0`; judgment has two Noted items, nothing under Act on.
- CI: `gh api repos/Zenoctra/factory918/commits/7956c696.../check-runs` → `Fixture | completed | success` and
  `Factory | completed | success`, run 35761775682, `event: pull_request`, `headSha` 7956c696..., conclusion
  `success`.
- `gh pr view 101 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` → headRefOid
  `7956c6964cea8088e02ae8798102ce36b3c15cad`, baseRefName `feat/design-hole-restart`, mergeable `CONFLICTING`,
  isDraft `false`, closingIssuesReferences exactly `[#91]`. CONFLICTING is expected and stated in the brief; the
  root resolves it by rebasing the chain.

## 5. PR body shape (AGENTS.md "Pull requests" at the SHA, plus the Opening a PR playbook)

- Title "Make the Spec walk cover every blast-radius risk": a plain sentence, no `type(scope):` form. Correct for
  this repository (P14).
- `## Why` gives the problem (two reviews that missed a risk for a round) then the fix. Correct.
- Sections in the playbook's order: Why, Scope, Tradeoffs, Blast Radius, Overlap, Verification.
- `## Blast Radius` is present, in prose, with a `Risks:` paragraph and no demoted inner headings. **The demotion
  is not required here**:
  `git diff --name-only 52ccd8e..7956c69 | grep -E '\.claude/hooks/|\.claude/settings\.json|\.agents/skills/factory918/'`
  matches nothing (exit 1), so the diff is not cross-cutting under `review-brief.sh:225`'s predicate, no
  blast-radius grounding is required, and the demotion rule at `opening-a-pr.md:18` applies only to a
  cross-cutting diff. The body says this itself and gives the reach anyway.
- `## Overlap` is present and placed before `## Verification`, which is what `ticket.md:12` step 8 requires.
- `## Verification` quotes each of the four criteria with its evidence, then names the runs and their outcomes.
- `Closes #91` is the last line before the attribution; then `🤖 Generated with [Claude Code](...)`; then
  `Claude Fable 5.1 on Claude Code`. Correct order.

## 6. Forbidden edits and generated files

- `git diff --name-status 52ccd8e..7956c69` names nothing under `docs/knowledge/spec/`, `docs/knowledge/pages/`,
  `docs/knowledge/notes/` or `research/`.
- `python3 tools/build_knowledge.py` → `knowledge files: 118 → docs/knowledge`, then `git status --porcelain`
  printed nothing, exit 0; `python3 tools/check_knowledge.py` → `knowledge ok: 118 files`, exit 0. So
  `docs/knowledge/INDEX.md`, the `<!-- lines: 95 -->` header of `core/DECISIONS.md` and
  `template/docs/factory918/DECISIONS.md` match a rebuild.
- `./factory918.sh sync` applied 17 patches, vendored 72 skills, and `git status --porcelain` printed nothing,
  exit 0. Both edited vendored files reach the template only through their patches.

### Gates I ran at the head commit, all exit 0

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, no findings.
- `bash tests/shellcheck/gate.sh` → `ok 10 assertions`.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`.
- `bash tests/spec-review/review-comment.sh` → `ok 136 assertions`.
- `bash tests/spec-review/review-brief.sh` → `ok 468 assertions`.
- `bash tests/spec-review/layout.sh` → exit 0; `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`.
- `bash tests/poteto-mode/overlap.sh` → `ok 56 assertions`.
- `bash -n factory918.sh` → exit 0.

## 7. Process facts for the root's record

Stated as facts, confirmed against GitHub, not as a verdict.

- The owner branched from PR #99's head although the overlap check printed `base: origin/feat/shellcheck`. The
  PR body's `## Overlap` says so in its own words ("printed `base: origin/feat/shellcheck`... This branch stacks
  on PR #99"), `docs/agents/ledger.md` line 27 records it, and `52ccd8e` is an ancestor of
  `origin/feat/design-hole-restart`, confirming the branch point.
- The owner retargeted PR #99, another lane's PR, to `main` and back so GitHub would link `Closes #90`.
  `gh api repos/Zenoctra/factory918/issues/99/timeline` shows two `base_ref_changed` events at 2026-09-22
  16:50:34Z and 16:50:55Z, both by `Zenoctra`, twenty-one seconds apart. PR #99's `closingIssuesReferences` is
  now `[#90]`.
- **PR #99's base is `feat/shellcheck` now** (`gh pr view 99 --json baseRefName` → `feat/shellcheck`, state OPEN,
  head `feat/design-hole-restart`), so the retarget was reverted as described.
- Ticket #100 was filed and is OPEN: "A stacked PR never links its ticket, so the go covers nothing", with three
  acceptance criteria and `Blocked by: None`.
- For the root's awareness: PR #101's own timeline shows `base_ref_changed` at 17:25:40Z, `base_ref_changed`
  17:36:03Z, `closed` 17:36:05Z, `reopened` 17:36:07Z, `base_ref_changed` 17:38:07Z — the retarget-to-`main`,
  close and reopen the body says were needed to make Actions build a run for a conflicting PR.

## 8. The owner's `## Attention` items

I read all seven in `.scratch/program/91/report.md`. None is a defect in this PR's code.

- Items 1 and 4 (nothing has built or reviewed this branch on top of #99's current head) are **a judgment for the
  root, and larger than the report says**: #99 has gained **six** commits since `52ccd8e`, not three
  (`git log --oneline 52ccd8e..origin/feat/design-hole-restart | wc -l` → 6), all touching `review-brief.sh` and
  `tests/spec-review/review-brief.sh`. The rebase and re-verification the root plans is what this PASS is
  conditional on.
- Item 2 (editing another lane's PR base) is a judgment for Manuel, already recorded as P27 and a ledger line.
- Item 3 (cells 4A and 8A came from one runner with no judge) is a judgment for Manuel; both cells have an
  assertion and both pass, and I checked their behaviour matches the table's text.
- Items 5, 6 and 7 are process notes, not defects. Item 7's numbers I reproduced independently (468 and 136).

## Issues

None. No acceptance criterion is unmet, no table cell is unasserted, no assertion contradicts the table, no file
is outside the ticket's ask, no forbidden or hand-edited generated file, every gate passes, and every receipt the
slice asked for exists.

## Notes

1. `.github/workflows/factory-ci.yml` is not in the ticket Contract's Files list, but the change to it was forced
   by the work: the fixture's `/tmp/blast.md` was the bullet hand-back, which cell 5A now refuses. The PR body
   names the run it broke (35760574314). The gap is in the ticket's design, not in the diff; the edit is in scope.
2. `DECISIONS.md` P27, the two ledger lines and the M0-findings line record the stacked-PR linking surprise,
   which is ticket #100's subject rather than #91's. Against "one concern per PR" this is a second subject, but
   `AGENTS.md` requires a decision to go under Provisional and a surprise to the ledger, and no behaviour in the
   diff serves it. I read it as required record-keeping, and flag it so the root can judge.
3. The assertions are grouped by fixture, not laid out in the table's order (9B appears in the non-cross-cutting
   loop near the top; the cross-cutting run is 1A, 2A, 7A, 8A, 5A, 6A, 9A, 3A, 4A, 4A, 10, 1B, 3B). The ticket
   asks for one assertion per cell "named by row and column in a comment", which is satisfied; it does not ask
   for the table's order. Grouping by fixture is what lets each cell reuse one fixture file.
4. Round one's two Noted items stand and I concur with both. [S1] `ticket.md` step 5 now asks for a heading shape
   the vendored `blast-radius/SKILL.md:43` does not hand back, so a lane that follows that skill literally is
   refused at review time; the ticket's "Open, with the default taken" accepted exactly this rather than patch a
   vendored skill. [S2] `SKILL.md` and the script header read as source-restricted ("`## Risks` in a file or
   `### Risks` in a PR body") while `review-brief.sh:248` accepts either line from either source, which cell 2A
   pins on purpose and `DECISIONS.md` P26 states correctly. Neither costs a correct grounding a refusal.
5. The review comment opens with two plain sentences but without the `For a person:` label that
   `template/AGENTS.md:78` requires of a comment over about forty lines. `spec-review/SKILL.md:149` tells the
   author to write "the two plain sentences for a person" with no label, so the divergence is between two
   documents and predates this PR. Not a finding here; worth a ticket if the label is meant to be universal.
6. The PR body says "PR #99 gained three commits after this branch left it". Three more landed at 12:39–12:41
   local, after the body was posted at 17:38Z, so the sentence was true when written and is stale now. It feeds
   the note under item 8 rather than being an error in the body.
7. My first ShellCheck run used the script's project-shaped defaults and reported 6 files; the repository's own
   invocation, quoted in `AGENTS.md` "Verifying", reports 20, matching the PR body. No discrepancy.
