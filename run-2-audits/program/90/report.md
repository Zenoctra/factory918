# Report: ticket #90, owner lane

PR #99 adds the design-hole route to the review (a `spec:` line on every counted finding, a `hole:` mark that prints `restart`, a round reset read from the PR's comments, the return to architect in the Ticket playbook, and three new `cites:` forms), and its own round one found two holes in its scenario table and restarted itself through that route before ending at round two with nothing to act on. The branch is pushed and review-ready; CI cannot run on the head until the root rebases it, because `feat/shellcheck` was rebased onto `feat/design-artifact-on-ticket` after this branch was cut and GitHub runs no `pull_request` workflow on a conflicting PR.

## Status

STACK-READY, with one item for the root (below): head `384bb43a872c1bca7b63a27aab2590ac37d46fae` from both `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/design-hole-restart`; branch `feat/design-hole-restart`; PR https://github.com/Zenoctra/factory918/pull/99 (ready, not draft); PR base branch `feat/shellcheck`; patch base `69bd41230e0f62e0824403196243c013118fb302` (`origin/feat/shellcheck` at step 1); intended parent PR #96 (ticket #88). The base has since been rebased by the root to `070c1fa` (its history now includes #94's commits), so PR #99 reads `mergeable: CONFLICTING` and no CI run exists for the last two heads; I did not rebase.

## Overlap

Step 1, `.claude/skills/poteto-mode/scripts/overlap.sh 90` (exit 0):

```
go: autopilot-stack
#96 feat/shellcheck: tests/spec-review/fake-gh.sh tests/spec-review/layout.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
base: origin/feat/shellcheck
```

The root expected #94 to print; the check found #94's own commits touch none of the paths #90 names, so the base was #96 and the branch was cut from its head 69bd412.

Step 8, `.claude/skills/poteto-mode/scripts/overlap.sh 90 --diff` (exit 0), at head 52ccd8e:

```
go: autopilot-stack
#94 feat/design-artifact-on-ticket: AGENTS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh
#96 feat/shellcheck: .github/shellcheck.sh .github/workflows/factory-ci.yml AGENTS.md CODING_STANDARDS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md factory918.sh patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh template/.claude/hooks/delegation.sh template/.github/shellcheck.sh template/.github/workflows/ci.yml template/AGENTS.md template/CODING_STANDARDS.md template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh tests/shellcheck/gate.sh tests/spec-review/fake-gh.sh tests/spec-review/layout.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
```

At that run `origin/feat/shellcheck` (2360707 then) was no longer an ancestor of the head, so the own-paths diff ran from `origin/main` and the #96 line lists #96's own files too. Both outputs are in the PR body's `## Overlap` section.

## Criteria

1. The definition in `spec-review` step 5 and `docs/agents/review-ladder.md`: `template/.agents/skills/spec-review/SKILL.md` step 5 (through its patch) and `template/docs/agents/review-ladder.md` rung 1 carry it; the Spec reviewer's walk (rounds one and two) confirms both; `no-stale-wording.sh` retires "Three trailing fields".
2. `spec:` lines, written into both briefs and refused when missing: `spec_rule` asserted in both briefs and in SKILL.md step 4, and absent from a no-ticket run's Standards brief (`tests/spec-review/review-brief.sh`, 422 assertions); a counted item with no, a malformed, or a fenced `spec:` line refused with the message naming the three forms; with no Spec brief the same item accepted and a `hole:` on it refused (`tests/spec-review/review-comment.sh`, 148 assertions); run end to end by both writers. The criterion was amended on the ticket (dated line) after round one: in a review with a spec; a review with no spec writes no rule and refuses a hole.
3. `hole:` mark, refused without a `spec:` reference, left out of the count, `restart` printed: table B columns D to G asserted (exact stdout with `restart` between the summary and `round:`, count without the hole; refusals for placement, form with the value shown as written, mismatch, no `spec:` line, no spec); exercised for real on this PR's round one (comment 5780539782 carries `restart`, `act-on items: 0`).
4. Never fixed on the PR; Ticket playbook returns to architect Phase B; `review-brief.sh` reads the restart and refuses nothing it did before: `ticket.md` step 8 pointer and `### Design hole` section; table A rows 5 to 8 and 11 to 13 asserted through the fake `gh` (restart as second and third comment gives `restart:` and `round: 1 of 3`, three post-restart rounds still refuse a fourth with the unchanged message, prose/fenced/trailing/anchorless `restart` resets nothing, `--round 4` refusal unchanged); the real script printed `restart:` and `round: 1 of 3` then `round: 2 of 3` on this PR; the hole re-run ran with two runners and a cross-judge (they diverged on hole 1), and the ticket carries the dated amendments.
5. `cites: #N table/design/criterion` carry as settled: table A rows 14 to 17 asserted (each form carried, five malformed dropped and counted).
6. `tests/spec-review/` coverage: the six named cases are among the 148 and 422 assertions, mapped to cells in the writers' reports.
7. Babysit unchanged for a PR with no hole: the diff of both babysit files is a new paragraph and a new bullet, the existing merge-ready sentences byte-identical; every pre-existing `accept` case passes unchanged. Note for the human: this criterion passed at HEAD by construction (falsifiability pass); it is proven by the diff, not by a failing test.

## Reviews

- Round 1 (head 52ccd8e, fixed point 69bd412): https://github.com/Zenoctra/factory918/pull/99#issuecomment-5780539782, `restart`, `act-on items: 0`. Two holes: `hole: table 1/A` (the term "a `hole:` field" undefined) and `hole: criterion 2` (no row for a review with no ticket). Returned to architect scoped to both: two runners converged on hole 2, diverged on hole 1, cross-judge picked A's rule (loud refusal over a keyword gate that would silently count a near-miss mark as a fix); amendments posted on the ticket; fix commits 096954b, 53ca502, 32978fa.
- Restarted round 1 (head 32978fa): https://github.com/Zenoctra/factory918/pull/99#issuecomment-5781120649, `round: 1 of 3`, `act-on items: 4` (MANUAL merge-read clause, P20 and P21 stale, refused value shown with an inserted space); fixed by 785b158, 831f4b4, 384bb43.
- Round 2 (head 384bb43): https://github.com/Zenoctra/factory918/pull/99#issuecomment-5781309601, `round: 2 of 3`, `act-on items: 0`; one Consider (a stale-wording grep for the grammar's prose copies, a later two-line follow-up), three Noted.

## CI

Run 35756050493, head 52ccd8e, conclusion success (the only run: it ran at PR open). No run for 32978fa or 384bb43: `gh api runs?head_sha=` returns 0 and `gh pr checks` reports none, because the PR is CONFLICTING against the rebased base and GitHub creates no `pull_request` run for a conflicting PR (pushes to `feat/shellcheck` itself did get runs). Every CI step was run locally at 384bb43, all exit 0: ShellCheck gate (20 files, clean), `tests/shellcheck/gate.sh` (10), `tests/hooks/delegation.sh` (55), `tests/spec-review/review-comment.sh` (148), `tests/spec-review/review-brief.sh` (422), `no-stale-wording.sh`, `tests/poteto-mode/overlap.sh` (56), `check_knowledge.py` (118 files), `build_knowledge.py` and `./factory918.sh sync` each leaving `git status --porcelain` empty. After the root rebases, CI runs on the new head.

## Records

Commit 384bb43: `docs/knowledge/core/DECISIONS.md` Provisional row P26 "A design hole restarts the review", with inline "Amended 2026-09-22 (#90)" clauses on P20 and P21; `docs/knowledge/core/MANUAL.md` step 2 of the merge read gains "and that comment carries no `restart` line ..."; `docs/agents/ledger.md` two lines dated 2026-09-22 (the worktree guard's refusals; the PR's own review finding two holes in its table); generated copies rebuilt. No `docs/M0-findings.md` line: nothing was verified against a tool version.

## Decided

- Base: the check printed #96, not the #94 the root expected; I followed the check.
- The scenario table went on the ticket with two tables (comment history for `review-brief.sh`, report item by mark for `review-comment.sh`); `restart` prints between the summary and `round:` so `act-on items:` stays last; a restart drops every settled item; `hole:` must equal the report item's `spec:` word for word; the return-to-architect text is a `### Design hole` section in `ticket.md` with a pointer in step 8; babysit gets one new sentence as its own paragraph and bullet; the judge-skip rule lives there, not in `arena`.
- The two round-one holes were treated as holes, not fixes, and the mechanism was run on its own PR; a `hole:` field is the text from the last `hole:` on a judgment line not ending in `fixed:`/`ticket:`, refused with the value shown when malformed; the `spec:` rule and `hole:` mark exist only in a review with a spec, and criterion 2 was re-derived to say so.
- Proceeding to the review without a CI run on the head, on the local run of every CI step, because the base drift is the root's to absorb and the review's purpose (no review of a red commit) was met.
- The MANUAL's merge-read sentence, outside the ticket's files, was fixed in the records commit because criterion 4's intent covers the human's read.
- Not cross-cutting, so `blast-radius` was not run; the PR body still carries a Blast Radius section.

## Blocked

Nothing for Manuel. For the root: rebase `feat/design-hole-restart` onto the rebased `feat/shellcheck` (070c1fa, which now carries #94's commits), which will trigger CI; expect conflicts in `tests/spec-review/review-brief.sh` and `review-comment.sh` (the #96 shellcheck `disable=` lines) and in `docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md`, `SOURCES.md` (appended lines). Ticket #91 stacks on this PR.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/90/decisions.tsv`. Design and lane artifacts beside it: `how/`, `architect/` (frame, two candidates, judge, design, hole candidates, hole judge), `writer-brief.md`, `writer-fix1-brief.md`, `writer-fix2-brief.md`, the three writer reports, `review-round-1/` and `review-round-2/` (reports and judgments), `pr-body.md`, `todo.md`.

## Chain rebase

Done on the root's instruction, in this worktree, nothing pushed. After `git fetch origin feat/shellcheck feat/design-artifact-on-ticket main`, `git rev-parse origin/feat/shellcheck` printed `070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42`; then `git rebase --onto 070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42 69bd41230e0f62e0824403196243c013118fb302 feat/design-hole-restart`. New local tip from `git rev-parse feat/design-hole-restart`: `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`, nine commits on 070c1fa (f9a767c, 0b8e257, ae85a15, 43dc844, b248f8b, 90b76f7, 13fd190, 3278b9b, 0ff73f0), same subjects and order as before. `git ls-remote origin refs/heads/feat/design-hole-restart` still prints `384bb43a872c1bca7b63a27aab2590ac37d46fae`; the PR base was not touched.

Conflicts, in two of the nine commits, both sides kept:

- 52ccd8e (the prose commit): `SOURCES.md` only. Item 12 is HEAD's text plus my `restart` sentence; item 13 is HEAD's, which carries #89's delegation clause; items 14 and 15 (#94's) kept. The `# shellcheck disable=` lines #96 added to `review-brief.sh`, `review-comment.sh` and `tests/spec-review/*.sh`, and #94's cell in `tests/poteto-mode/overlap.sh`, merged without conflict.
- 384bb43 (the records commit): `docs/agents/ledger.md`, HEAD's four #88 and #89 lines kept, my two #90 lines appended, my copy of the #88 line dropped because HEAD carries it; `docs/knowledge/core/DECISIONS.md`, HEAD's P24, P25 (#94, the design artifact) and P26 (#96, the shell gate) kept, my row renumbered to P27, P20's amended clause now reads "a design hole, P27", P21's clause unchanged, and no other file names the row (the MANUAL line and the ledger lines do not); `docs/knowledge/INDEX.md` and `template/docs/factory918/DECISIONS.md` rebuilt with `python3 tools/build_knowledge.py` (119 files), not by hand.

Gates at 0ff73f0, every line of AGENTS.md "Verifying", all exit 0: `bash .github/shellcheck.sh ...` (ShellCheck 0.11.0, 20 files, no findings); `bash tests/shellcheck/gate.sh` `ok 17 assertions`; `bash tests/hooks/delegation.sh` `ok 55 assertions`; `bash tests/spec-review/review-comment.sh` `ok 148 assertions`; `bash tests/spec-review/review-brief.sh` `ok 422 assertions`; `bash tests/spec-review/no-stale-wording.sh` `ok: no stale wording`; `bash tests/poteto-mode/overlap.sh` `ok 57 assertions`; `python3 tools/build_knowledge.py` then `git status --porcelain` empty and `python3 tools/check_knowledge.py` `knowledge ok: 119 files`; `./factory918.sh sync` then `git status --porcelain` empty. The fixture flow, run as CI's job runs it, all exit 0: `(cd /tmp && vp create vite:monorepo --directory fx-90 --no-interactive --git --hooks --no-agent)`, an initial commit, `factory918.sh apply` (the doctor's two day-0 FAILs, labels and slots, as in CI), the project's `bash .github/shellcheck.sh`, `review-brief.sh HEAD~1 --ticket 1 --blast-radius` inside the project with the fake `gh` (both briefs exist, carry the hard-finding definition and `## Fails open`, no `## Latent`, the walk only in the Spec brief, and the spec rule once each), `vp check`, `vp test run`, `pnpm sg:test`, `pnpm sg`, then in `python/demo` `uv sync --frozen`, `uv run ruff format --check .`, `uv run ruff check .`, `uv run pyright`, `uv run pytest`, `uv audit`, and both rules fire on the probe file. The fixture was removed afterwards.

One thing seen on the way, outside this ticket: the AGENTS.md Verifying line spells the create as `--directory /tmp/fx`, and vp 0.3.1 refuses it ("Absolute path is not allowed"); CI's `(cd /tmp && ... --directory fx)` form is the one that works. A one-line fix for a later PR.

## Body corrections

PR #99 body edited in place after the gates verifier at 0ff73f0 (no commit, no other PR): the Scope bullet now names the decision row as P27 (the committed row, matching P20's amendment text) and the comment test's count as 148 (the measured count, as the Verification section already said); the final Verification paragraph now quotes `ok 17 assertions` for `tests/shellcheck/gate.sh`, `ok 57 assertions` for `tests/poteto-mode/overlap.sh` and `knowledge ok: 119 files`, the counts at 0ff73f0 after the rebase onto #94 and #96. `Closes #90` stays the last line before the attribution, the signature after it.
After the audit slice: the Verification paragraph's commit-order receipt now names the post-rebase commits `f9a767c` tests, `0b8e257` scripts, `ae85a15` prose (confirmed with `git log --reverse --format='%h %s' 070c1fa..0ff73f0`), replacing `cc36280`, `8b3de0a`, `52ccd8e`, which are no longer ancestors of 0ff73f0; body edit only, no commit, no other PR.
