# Todo for ticket #93 (owner lane)

Legend: `[ ]` open, `[x]` done, `skip: <reason>` kept in place.

## Non-negotiable

- [x] Read the poteto-mode Principles section in full.

## Ticket playbook (verbatim)

- [x] T1. Start from an up-to-date `main` (`git fetch origin`; `origin/main` is trunk in a linked worktree). `git status --porcelain` empty. Run `.claude/skills/poteto-mode/scripts/overlap.sh 93`; record its output; branch per the root's decision (`origin/feat/spec-walk-risks`, patch base SHA recorded). Exit 1 or 2: stop.
- [x] T2. (no Parent, no CONTEXT.md, no ADRs here) Read the ticket (`gh issue view 93`), its Parent if any, `CONTEXT.md` and ADRs in the area. Body shape per `docs/agents/issue-tracker.md`.
- [x] T3. Check Blocked by: every listed issue closed (#42).
- [x] T4. Falsifiability pass: for each criterion, the command or observation that fails it at HEAD.
- [x] T5. (Feature; not cross-cutting: no blast-radius file; architect never skipped) Select the playbook by content (Feature) and run it verbatim. `how` and `why` first. Cross-cutting predicate check (`review-brief.sh` holds it); if cross-cutting, `blast-radius` to `.scratch/93/blast-radius.md` and never skip `architect`.
- [ ] T6. Testing decisions are the pre-agreed seams; `tdd` there.
- [ ] T7. Verify on the matching surface per `docs/agents/evidence.md`.
- [ ] T8. `overlap.sh 93 --diff`; output verbatim as `## Overlap` before `## Verification`. Then Opening a PR. Last line before attribution `Closes #93`.
- [ ] T9. Babysit to merge-ready per `playbooks/babysit.md`. Never merge.

## Run under (ticket's rules, followed by hand)

- [x] R0. Read ticket #42 `## Testing decisions` and PR #92 (description, three review comments).
- [x] R1. (how done; blast-radius n/a: not cross-cutting)
- [ ] R2. Scenario table before any code; appended to ticket body under `## Testing decisions`, first line "Posted by the agent 2026-09-22".
- [ ] R3. Tests written from the table before the implementation, one assertion per cell; commit order shows it.
- [ ] R4. Writer that cannot implement a cell stops and reports it.
- [ ] R5. Design hole in review returns to architect; review count restarts with a "restart" comment.
- [ ] R6. Spec reviewer's walk: one line per blast-radius risk.
- [ ] R7. Would-break fix gets another round past three, up to five; fix-only fixed point.
- [ ] R8. `shellcheck` on every changed shell file before the PR opens; plus `bash .github/shellcheck.sh` at 0.11.0.

## Feature playbook (verbatim)

- [x] F1. (opus lane, simple mode, how.md)
- [~] F2. (two runners running) `architect` for parallel design exploration.
- [x] F3. Throughput checkpoint, four items:
  - [ ] Blocking first steps.
  - [ ] Independent workstreams.
  - [ ] Shared mutable state.
  - [ ] Smallest safe decomposition.
- [ ] F4. Delegate code-writing (claude:fable@high, general-purpose, model fable, worktree isolation) with file paths, data shape, organizing structure, success criteria; review the diff myself. Mandatory.
- [ ] F5. Verify on the matching surface.
- [ ] F6. Rebase into small, ordered commits.
- [ ] F7. `interrogate` if the design is contested.
- [ ] F8. Opening a PR.

## Opening a PR (verbatim, with AGENTS.md overrides)

- [ ] O1. Worktree: own worktree; writers get their own.
- [ ] O2. Commits: small, ordered; `/deslop` before commit; `Co-Authored-By` trailer.
- [ ] O3. Title: plain sentence (AGENTS.md P14 overrides Conventional Commits here).
- [ ] O4. Description: Why, Scope, Tradeoffs, Blast Radius (no `## ` inside), Overlap, Verification; `Closes #93`; attribution line.
- [ ] O5. Forge: `gh`, `--repo Zenoctra/factory918`, base `feat/spec-walk-risks`.
- [ ] O6. Readiness: draft early (within 15 minutes of first push), `gh pr ready` once evidence is in the body.
- [ ] O7. After CI green: `spec-review` in a fresh lane; `review-comment.sh` gates every comment; rounds per R7.
- [ ] O8. `/technical-writing` then `/unslop` over title, body, commit messages.

## Records and report

- [ ] Records commit: Provisional in DECISIONS.md, ledger, M0 line if a tool version fact.
- [ ] decisions.tsv audited; cross-model review of the trail.
- [ ] report.md written; reply with its path.

## F3 throughput checkpoint (written 2026-09-22 before fan-out)

- Blocking first steps: `how` (running), then `architect` Phase B (two runners, judge only on divergence), then the scenario table appended to the ticket; no code before the table. Then the writer's first commit is the tests from the table (red), the second the scripts (green), the third the prose and patches.
- Independent workstreams: none worth a second writer. The test pins the skill text word for word and the scripts' exact messages, so scripts, tests and prose are one coupled unit in one worktree. My records commit (the Provisional row, ledger line and any M0 line) comes last on my branch.
- Shared mutable state: `.claude/state/review` and `.scratch/review` are per repository and the tests use temp repos, so nothing is shared. The vendored files (`spec-review/SKILL.md`, two babysit copies) change through their patches; the writer edits the template copy and regenerates the patch in the same commit so `sync` stays clean. Sibling lanes append to `DECISIONS.md` and `ledger.md`; the root resolves that at chain time.
- Smallest safe decomposition: one writer lane (claude:fable@high, worktree isolation) with the table as its spec, because the diff is small (two scripts, one or two test files, prose in six places) and splitting it would put the word-for-word pins in two hands.
