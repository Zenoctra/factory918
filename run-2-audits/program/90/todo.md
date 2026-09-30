# Todo, ticket #90 (owner lane)

Legend: [ ] open, [x] done, [s] skip: <reason>

## Ticket playbook

- [x] T1. Up-to-date main (`git fetch origin`; `origin/main` = ab47eb9), porcelain clean, `overlap.sh 90` exit 0, `base: origin/feat/shellcheck` (#96). Branched `feat/design-hole-restart` from 69bd412. Parent = PR #96 (ticket #88). Output kept for the report.
- [x] T2. Read ticket #90; no Parent. Read #42 Testing decisions and PR #92 (body + three review comments) per Run under.
- [x] T3. Blocked by #42: CLOSED 2026-09-22T03:50:22Z.
- [x] T4. Falsifiability pass: `spec:`, `hole:`, `restart` absent from scripts, tests, skill, ladder; `cites:` grammar (review-brief.sh:151) has no table/design/criterion form; no test names them. Criterion 7 (babysit unchanged) passes at HEAD by construction: noted for the human in the report, proven by the diff leaving babysit's merge-ready text and the round/act-on tests untouched.
- [x] T5. Select playbook: new behavior -> Feature. Cross-cutting predicate (review-brief.sh:189): hooks, settings.json, factory918 skill; this diff touches none -> blast-radius skill not required; the PR body still carries a `## Blast Radius` section.
- [x] T6. Testing decisions = the scenario table (Run under rule 2); tests from the table first (cc36280).
- [x] T7. Verified: shellcheck gate 20 files, gate 10, delegation 55, comment 134, brief 414, stale ok, overlap 56, knowledge 118, sync clean; CI run 35756050493 success on 52ccd8e.
- [x] T8. `overlap.sh 90 --diff` exit 0 -> `## Overlap` in the PR body; Opening a PR done: PR #99 on feat/shellcheck, ready.
- [x] T9. Review-ready: round 2 of the new series `act-on items: 0`; CI on the head blocked by the root's rebase of the base (PR CONFLICTING), reported; never merged.
- [x] R3, R4, R8 held by the writers' reports; R5 exercised on this PR (restart at round 1); R6 n/a (not cross-cutting); R7 n/a (no Would-break fix past round three; #93's rule).
- [x] F4 to F8, O1 to O8 done; records commit 384bb43 last.

## Run under (by hand)

- [x] R1. `how` run; `blast-radius` not required (not cross-cutting, T5).
- [x] R2. Scenario table under `## Testing decisions` on #90, first line "Posted by the agent 2026-09-22", posted before any code (gh issue edit 90 --body-file).
- [ ] R3. Tests from the table before the implementation; commit order shows it.
- [ ] R4. Writer stops on a cell it cannot implement.
- [ ] R5. Design hole in review -> architect Phase B, restart comment. Round 1 on PR #99: S1 (`hole: table 1/A`, the undefined term "hole: field") and P1 (`hole: criterion 2`, no row for a no-ticket review); comment carries `restart`; scoped re-run: two runners (hole-a.md, hole-b.md) converged on hole 2, cross-judge (hole-judge.md) picked A's rule for hole 1; both amendments posted on #90 (dated lines); fix writer `wt/90-fix1` launched from 52ccd8e; next: take the fix, push, CI, review from round one.
- [ ] R6. Spec reviewer's walk: one line per blast-radius risk (only if cross-cutting).
- [ ] R7. Would-break fix -> one more round past three, up to five.
- [ ] R8. shellcheck on every changed shell file before the PR opens.

## Feature playbook

- [x] F1. `how` over the affected subsystem: three explorers, one explainer; `.scratch/program/90/how/explanation.md`.
- [x] F2. `architect` Phase B as an arena: two runners (fable, opus), cross-judge (opus), base A with grafts from B; `.scratch/program/90/architect/design.md`.
- [x] F3. Throughput checkpoint:
  - Blocking first steps: the scenario table posted on #90 (gate before any code); the tests written from it and committed before the implementation; the writer stops on a cell it cannot implement.
  - Independent workstreams: n/a: the scripts' rule strings and `SKILL.md` step 4/5 are pinned equal by `tests/spec-review/review-brief.sh`, and the patch and template copy of `SKILL.md` must move together, so prose and code are one workstream; one writer.
  - Shared mutable state: the writer alone writes the branch in its own worktree; the owner never edits it in parallel; every lane writes only its own file under `.scratch/program/90/`.
  - Smallest safe decomposition: one writer, two ordered commits (tests, then implementation), a third for prose if the writer prefers; fixes after review are new commits by a fresh fix lane.
- [ ] F4. Delegate writing: writer lane, worktree, fable@high.
- [ ] F5. Verify on matching surface.
- [ ] F6. Small ordered commits (tests first).
- [ ] F7. `interrogate` if contested.
- [ ] F8. Opening a PR.

## Opening a PR

- [ ] O1. Worktree: own worktree, branch feat/design-hole-restart.
- [ ] O2. Commits: small, ordered; tests before implementation.
- [ ] O3. `/deslop` over the diff before commit; `bash .github/shellcheck.sh` on changed shell files.
- [ ] O4. Title: plain sentence (AGENTS.md overrides Conventional Commits here); `/technical-writing` then `/unslop`.
- [ ] O5. Body: Why, Scope, Tradeoffs, Blast Radius, Overlap (before Verification), Verification, `Closes #90`, attribution.
- [ ] O6. Forge: gh, `--repo Zenoctra/factory918`, `--base feat/shellcheck`.
- [ ] O7. Draft first (Verification evidence rule), `gh pr ready` once evidence is in.
- [ ] O8. spec-review: round 1 found two holes (restart, comment 5780539782); redesign at 32978fa; restarted round 1: Spec 0, Standards 4 Act on (MANUAL clause, P20, P21, message space), fix lane `wt/90-fix2` launched; CI cannot run on 32978fa (base rebased by the root, PR CONFLICTING); local CI steps green.

## Owner-brief extras

- [ ] decisions.tsv started (main checkout path).
- [ ] Early draft PR within ~15 min of first push, `--base feat/shellcheck`.
- [ ] Records commit (DECISIONS Provisional, ledger, M0) last.
- [ ] Report at `.scratch/program/90/report.md` (main checkout).
