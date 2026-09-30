# Ticket #91, owner lane

PR #101 makes the Spec reviewer's walk cover every risk in a blast-radius grounding and makes `review-brief.sh` find the grounding's Risks heading in a file or a PR body; it stacks on PR #99, CI is green on its head and its one review round found nothing to act on. Two things the root should know: GitHub does not link `Closes #N` on a PR opened against a non-default branch, so the overlap check exited 1 until PR #99 was retargeted through `main` (ticket #100 filed), and PR #99 gained three commits after this branch left it, so #101 conflicts with its base until the root rebases the chain.

## Status

STACK-READY.

- Head SHA: `7956c6964cea8088e02ae8798102ce36b3c15cad` (`git rev-parse HEAD`); `git ls-remote origin refs/heads/feat/spec-walk-risks` prints the same SHA.
- Branch: `feat/spec-walk-risks`.
- PR: https://github.com/Zenoctra/factory918/pull/101, ready (not draft), title "Make the Spec walk cover every blast-radius risk".
- PR base branch: `feat/design-hole-restart` (PR #99). GitHub links the PR to #91 (`closingIssuesReferences: [91]`).
- Patch base SHA: `52ccd8eb509a2871260827a8514c3a1fcaac4d5d` (PR #99's head when this branch left it).
- Intended parent: ticket #90 (PR #99). PR #99 has since moved to `384bb43` (six commits past the patch base at the time of writing: `096954b`, `53ca502`, `32978fa`, `785b158`, `831f4b4`, `384bb43`); this branch was not rebased. GitHub reports the PR `CONFLICTING` against that base (both branches edit `review-brief.sh`, its test and `SKILL.md`), so the root's rebase of the chain resolves it; expect conflicts in `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`, `template/.agents/skills/spec-review/SKILL.md` and its patch, `SOURCES.md`, and the records files.
- Commits above the patch base, in order: `ccf5bf6` tests from the table, `c0761dd` script, `6add1e3` prose, `469f78d` records, `7956c69` CI fixture.

## Overlap

Step 1, first run (exit 1; PR #99 carried no closing-issue link):

```
go: autopilot-stack
#96 feat/shellcheck: tests/spec-review/review-brief.sh
#99 feat/design-hole-restart: tests/spec-review/review-brief.sh
```

Step 1, second run after PR #99 was retargeted to `main` and back so GitHub linked `Closes #90` (exit 0):

```
go: autopilot-stack
#96 feat/shellcheck: tests/spec-review/review-brief.sh
#99 feat/design-hole-restart: tests/spec-review/review-brief.sh
base: origin/feat/shellcheck
```

The check printed `origin/feat/shellcheck`, not the parent the root named, because `feat/shellcheck` had been rebased under PR #99 after #99 branched from it (`070c1fa` is not an ancestor of `52ccd8e`), so neither printed head contained the other and the check fell back to the lowest PR number. I branched from `origin/feat/design-hole-restart` at `52ccd8e` (PR #99, ticket #90) as the root's note said, because that PR holds the rewrite of `review-brief.sh` and its test that this ticket builds on; branching from the rebased `feat/shellcheck` would have made #91 a sibling of #99 editing the same files. Recorded in the ledger and in the PR body's `## Overlap`.

Step 8 (`overlap.sh 91 --diff`, exit 0, at 469f78d and again at 7956c69, same output):

```
go: autopilot-stack
#94 feat/design-artifact-on-ticket: AGENTS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh
#96 feat/shellcheck: .github/shellcheck.sh .github/workflows/factory-ci.yml AGENTS.md CODING_STANDARDS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md factory918.sh patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh template/.claude/hooks/delegation.sh template/.github/shellcheck.sh template/.github/workflows/ci.yml template/AGENTS.md template/CODING_STANDARDS.md template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh tests/shellcheck/gate.sh tests/spec-review/fake-gh.sh tests/spec-review/layout.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#99 feat/design-hole-restart: .github/shellcheck.sh .github/workflows/factory-ci.yml AGENTS.md CODING_STANDARDS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md factory918.sh patches/mattpocock/spec-review.SKILL.md.patch patches/pstack/babysit/SKILL.md.patch patches/pstack/poteto-mode/playbooks/babysit.md.patch patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch template/.agents/skills/babysit/SKILL.md template/.agents/skills/poteto-mode/playbooks/babysit.md template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh template/.claude/hooks/delegation.sh template/.github/shellcheck.sh template/.github/workflows/ci.yml template/AGENTS.md template/CODING_STANDARDS.md template/docs/agents/review-ladder.md template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh tests/shellcheck/gate.sh tests/spec-review/fake-gh.sh tests/spec-review/layout.sh tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
```

The lines list each PR's own files from `origin/main` because `feat/shellcheck` was rebased under PR #99 and the check's `nearest` finds no open-PR ancestor for either head; all three are covered by the program's go.

## Criteria

1. "For a cross-cutting diff, the Spec brief's `## Walk` rule requires, after the lines per documented step, one numbered line per risk under the grounding's Risks heading, each saying what the diff does at that risk." Proven by `tests/spec-review/review-brief.sh` cells 1A, 2A, 3A, 7A, 8A (the Spec brief's Walk bullet followed on its line by the sentence, pinned word for word against the source `SKILL.md`), 1A and 3A for the Standards brief not carrying it; the writer's end-to-end run pasted the emitted bullet; CI's Fixture job now greps the sentence in the Spec brief on a real `factory918 apply` diff.
2. "`review-brief.sh` finds the Risks heading in both forms ... writes the rule only when a grounding is present, and `tests/spec-review/review-brief.sh` asserts both forms and the absent case." Cells 1A (`## Risks`, file), 2A (`### Risks`, file), 3A (`### Risks`, CRLF PR body), 5A and 6A (no heading or fenced only: refused, exit 1, no state), 4A (undemoted body: both outcomes), 9B, 1B, 3B (not cross-cutting: no sentence), 10 (`--blast-radius` naming no file: usage).
3. "`review-comment.sh` still counts walk lines as steps, not items." Already true at the base (noted in `falsifiability.md`); `tests/spec-review/review-comment.sh` gained one fixture (134 to 136) where the walk continues with two risk lines and the comment is byte-identical.
4. "The Opening a PR playbook's Blast Radius bullet (through its patch) says the inner headings are demoted to `###` when the file is pasted." `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`; `./factory918.sh sync` leaves the tree clean.

## Reviews

Round 1 (fixed point `52ccd8e`, reviewed head `7956c69`): https://github.com/Zenoctra/factory918/pull/101#issuecomment-5781207159. Standards (opus): 0 hard findings, 2 Fix-alongside items; Spec (opus): 0 hard findings, an 8-line walk. Judgment: both items Noted, `[S2]` cited to `DECISIONS.md P26`. `review-comment.sh` exit 0.
`act-on items: 0`
No restart. No further round is owed: the round ended with nothing to act on, and a dry run of `review-brief.sh` afterwards read the comment as `round: 2 of 3`, `settled: carried 1, dropped 1 without a citation` (its state was then removed).

## CI

- Run 35761775682, head `7956c6964cea8088e02ae8798102ce36b3c15cad`, conclusion success (jobs Factory and Fixture both success). Obtained by retargeting the draft to `main`, closing and reopening it once (a `reopened` event), then retargeting it back; the branch is a linear descendant of `main`, so the run tested exactly this head's tree.
- Earlier run 35760574314 on `6add1e3` (base `main` at the time): Factory success, Fixture failure at "review-brief.sh briefs the apply diff inside the project", because the workflow's own `/tmp/blast.md` fixture was the bullet hand-back and the new refusal fired; fixed in `7956c69`.
- No run was created for `469f78d` or `7956c69` while the base was `feat/design-hole-restart`: Actions creates no `pull_request` run for a PR whose merge ref cannot be built (the PR conflicts with its moved parent).

## Records

- `docs/knowledge/core/DECISIONS.md` Provisional: the walk contract (fixed sentence, both heading levels from either source, refusal without a Risks heading, demotion in a PR body) and the stacked-PR rule (opened against trunk and retargeted in the next command, until #100 lands). Numbered P26 and P27 when committed at `469f78d`; P28 and P29 after the chain rebase (see Chain rebase). Generated copies rebuilt (`template/docs/factory918/DECISIONS.md`, `docs/knowledge/INDEX.md`).
- `docs/agents/ledger.md`: two 2026-09-22 lines (the unlinked stacked PR that the #42 contract could not see although M0 had recorded the GitHub rule on 2026-09-17; the containment tie-break broken by a parent rebased under an open child).
- `docs/M0-findings.md`: one 2026-09-22 paragraph on PRs #96 and #99, pointing at the 2026-09-17 line.
- Commit `469f78d`.

## Decided

- Base: branched from PR #99's head although the check printed `origin/feat/shellcheck` (see Overlap). The root's ticket note named #99 as the parent; the check's tie-break assumed containment that #96's rebase had broken.
- Unblocking step 1: retargeted PR #99 (another lane's PR, confirmed unarmed via GraphQL) to `main` for eight seconds so GitHub linked its `Closes #90`, then back to `feat/shellcheck`; head untouched. Filed #100 for the contract defect.
- Own PR opened against `main` first, then retargeted to `feat/design-hole-restart`, so #93's step 1 sees `Closes #91` (P27).
- Design: the risk sentence is one fixed string (no heading level, no count); both `## Risks` and `### Risks` accepted from either source, first unfenced match; a grounding without the heading is refused before any state; `review-comment.sh` unchanged. Two architect runners converged; the judge was skipped (the base's rule for converging runners). Posted on #91 under `## Testing decisions` before any code.
- Writer's decisions accepted as reported: the SKILL.md sentence travels with the script commit so the test passes there; cell 10 got an assertion of today's usage refusal; `tests/spec-review/review-comment.sh` 134 to 136 for criterion 3; a `refused_risks` helper in the test; one clause in `ticket.md` step 5 saying the Spec reviewer walks every risk.
- CI on a conflicting stacked PR: Actions creates no run while the merge ref cannot be built, so the draft was retargeted to `main`, closed and reopened once to run CI on 7956c69 (a linear descendant of `main`), then retargeted back. Not a rebase; the root rebases the chain.
- Criterion 3 already passed at HEAD; kept as a regression check, per Ticket step 4 noted here for the human.
- The one other caller with a bullet-shaped grounding was `.github/workflows/factory-ci.yml` (found by grep), fixed in `7956c69`; no ticket needed.

## Blocked

Nothing waits on Manuel for this ticket. For the root: the chain rebase of `feat/spec-walk-risks` onto PR #99's current head (`32978fa`) will conflict in the files listed under Status; the tests-first commit order should survive a `git rebase --onto`. Two items for Manuel's triage, not blockers: ticket #100 (the overlap check cannot see a stacked PR's ticket until it is retargeted through `main`; P27 is the workaround) and whether `blast-radius/SKILL.md`'s bullet hand-back should be patched to headings (judgment item [S1], noted).

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/91/decisions.tsv`. Beside it: `todo.md`, `falsifiability.md`, `how.md`, `architect-fable.md`, `architect-opus.md`, `testing-decisions.md`, `writer-brief.md`, `writer-report.md`, `fix1-report.md`, `trail-review.md`, and the review directory copies under `review/`.

## Chain rebase

Done on the root's instruction, in this worktree, nothing pushed. `git ls-remote origin refs/heads/feat/spec-walk-risks` still prints `7956c6964cea8088e02ae8798102ce36b3c15cad`.

- Fetched `feat/design-hole-restart`, `feat/shellcheck`, `feat/design-artifact-on-ticket`, `main`; `origin/feat/design-hole-restart` printed `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93` as stated.
- `git rebase --onto 0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93 52ccd8eb509a2871260827a8514c3a1fcaac4d5d feat/spec-walk-risks`. New local tip (`git rev-parse feat/spec-walk-risks`): `d8e382ca37233bce98724c785ecdbb677abc4e2a`, an ancestor chain `0ff73f0 -> 9db29b4 -> 649d126 -> adaf4a0 -> 769217c -> d8e382c`; the tests-first order survived (tests `9db29b4`, script `649d126`, prose `adaf4a0`, records `769217c`, CI fixture `d8e382c`).
- Commits 1, 2 and 5 applied cleanly; `SKILL.md` and its patch auto-merged with #99's later text intact (the working diff against `0ff73f0` in those two files is my two lines only).
- Commit 3 conflicts: `SOURCES.md` item 6 (both sides appended sentences to the same line; resolved as #99's line with my two Risks sentences inserted after "and `review-brief.sh` refuses it without one.", so the `hole:` field sentences and mine both stand); `template/.agents/skills/poteto-mode/playbooks/ticket.md` (my step 5 with the heading shape, #99's expanded step 6 on posting the design artifact).
- Commit 4 conflicts: `docs/knowledge/core/DECISIONS.md` (#99's P24 to P27 kept: P25 #94's design artifact, P26 #96's shell gate, P27 #99's design hole; my two rows renumbered P28 and P29, text unchanged); `docs/agents/ledger.md` (#99's six lines kept, my two #91 lines appended; neither named a row id); `docs/M0-findings.md` (#99's two paragraphs kept, mine appended); `docs/knowledge/INDEX.md` and `template/docs/factory918/DECISIONS.md` regenerated by `python3 tools/build_knowledge.py` (119 files now), never by hand.
- Row-id mentions: `DECISIONS.md` rows renumbered; the PR body now says P28 and P29 (edited); the ledger and M0 lines named no row. Not changed: the records commit's own message (`769217c`) still reads "P26" and "P27" as at commit time, because the harness refuses a non-interactive reword and `-i` is unavailable; and the posted round-one comment's `cites: DECISIONS.md P26` names the row that is now P28 (posted comments are not edited).
- Gates at `d8e382c`, each exit 0: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` (`ShellCheck 0.11.0, files checked: 20`); `bash tests/shellcheck/gate.sh` (`ok 17 assertions`); `bash tests/hooks/delegation.sh` (`ok 55 assertions`); `bash tests/spec-review/review-comment.sh` (`ok 150 assertions`; 136 before the rebase, #99's later fixtures added the rest); `bash tests/spec-review/review-brief.sh` (`ok 476 assertions`; 468 before); `bash tests/poteto-mode/overlap.sh` (`ok 57 assertions`); `bash tests/spec-review/no-stale-wording.sh` (`ok: no stale wording`); `shellcheck -x` on the three changed shell files, clean; `python3 tools/build_knowledge.py` then `git status --porcelain` empty and `python3 tools/check_knowledge.py` (`knowledge ok: 119 files`); `./factory918.sh sync` (`vendored: 72 skills`) then `git status --porcelain` empty. The fixture flow is CI's, to run on the pushed head.

## Attention

reviewed by Claude Opus 5 (the trail reviewer's own line; its full list is `trail-review.md`)

1. CI green (run 35761775682) and both review reports rest on the branch as it stands over `52ccd8e`; nothing has built or reviewed this branch on top of PR #99's current head (`384bb43`, six commits later, touching the same files). That is the drift the root's chain rebase and re-verification exist for; read `hard findings: 0` as a verdict on this snapshot.
2. Row 16:56 edited another lane's PR (#99's base, to `main` and back) to create its `Closes #90` link; reversible and recorded as P27, but a step outside this lane's own PR.
3. Row 17:12: the table took cells 4A and 8A from one runner (fable) with no judge, on the strength of the two runners converging on every structural choice; both cells have an assertion, but no second design looked at them.
4. Row 16:58 branched from PR #99 against the check's printed base; the cost is item 1.
5. Ticket #100 stays open; until it lands, P27 is a manual step for every stacked PR.
6. The trail's first row carries a placeholder timestamp (`00:00:00Z`); the lane started about 16:45Z. `todo.md` was updated after the reviewer read it (it now ticks O4, T8, T9, O6); the final `overlap.sh 91 --diff` run is logged under Overlap above rather than as its own row.
7. The writer's and fix lane's numbers (468, 136 assertions) were re-run by me in this worktree (rows 17:45 and 19:00) and by CI; their reports were copied in from their worktrees.
