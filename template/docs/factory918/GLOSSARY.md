# Factory918: glossary

Terms as this system uses them. Where a term belongs to one of the four sources, the source is named.

**Acceptance criterion.** A checkbox line on a ticket that says what must be true when it is done. Objective when a command can fail it. The Ticket playbook's falsifiability pass rejects criteria that already pass at HEAD, that another ticket owns, or that restate the request.

**ADR.** Architecture decision record: one to three sentences in `docs/adr/NNNN-slug.md` recording a decision that was hard to reverse, surprising without context, and the result of a real trade-off. (Matt)

**Babysit.** The loop after filing a PR: watch checks and comments newer than the last push, verify each finding against the source, fix real ones, dismiss false ones with a written reason, stop when green. Never merges. (pstack playbook; Theo's rule says the same.)

**Blocked by.** A ticket's list of tickets that must close first. The frontier is every ticket with no open blockers. (Matt)

**CI.** Continuous integration: a hosted machine runs the checks on every PR and push to `main`; results appear on the PR; branch protection makes named checks required to merge.

**CONTEXT.md.** The project glossary: terms defined by what they are, never how they are built. Written by `grill-with-docs`, read by every skill. Bloats into a spec if not policed. (Matt)

**Debt ceiling.** A per-file maximum for occurrences of a banned pattern (`maxOccurrences` in the oxlint plugin, `per-file-ignores` in ruff) so a new rule is absolute for new code and a ratchet for old code. Numbers only go down. (Theo)

**Deterministic layer.** Everything that decides what code must pass without a model reading it: formatter, linter, type checker, tests, hooks, CI, labels, review bots.

**Evidence.** An artifact a reviewer can inspect instead of trusting a sentence: a failing-then-passing test, a numbered screenshot, a read-back, a command with its exit code. Lives in `.artifacts/`, uploaded to the PR, never committed.

**Grilling.** Matt's interview primitive: rounds of numbered questions; facts are the agent's to find, decisions the human's to make; ends when the frontier of questions is empty and the human confirms.

**Hook (git).** A script git runs at a moment such as pre-commit; ours runs the formatter only.

**Hook (harness).** A script Claude Code runs at one of its lifecycle events (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`); the harness runs it whether the agent likes it or not. Ours: the session mandate, the phase guard, the git guard, format-on-write.

**Ladder (of rungs).** Where a rule should live, strongest first: unrepresentable state, lint or banned API that fails CI, canonical helper, runtime check, test at a seam, `AGENTS.md` line, skill. (pstack's principle, Theo's practice.)

**Ledger.** `docs/agents/ledger.md`: one line per time an agent surprised you. Rules are promoted from it, never invented ahead of it. (Theo)

**Map.** A `wayfinder:map` issue holding decision tickets for work bigger than one session. "Plan, don't do." (Matt)

**Mode / phase.** `planning` or `execute`, stored in `.claude/state/mode`, printed every turn by the phase hook. Planning commands and `/mode-plan` set planning; a ticket reference, pstack commands and `/mode-build` set execute.

**Playbook.** A task-shaped recipe inside `poteto-mode/playbooks/`; the router copies its steps verbatim into the todo list. Ours adds `ticket.md`. (pstack)

**Principle.** One of pstack's 21 leaf skills that constrain decisions; cited by name, never "run."

**Profile.** A per-language set of commands and files for the deterministic layer: `vite-plus` (default, TypeScript), `react-native` (Expo on top of vite-plus), `python` (`uv`, `ruff`, `pyright`, `pytest`).

**Review ladder.** CI, then `spec-review`, then an external bot if configured, then `interrogate` if contested, then the human. Rungs without a precondition are skipped, never failed.

**Router.** A skill that maps a situation to an entry point. Matt has `ask-matt`, pstack has `poteto-mode`; Factory918 has `/factory918` above both.

**Seam.** The public boundary you test at; the interface where you observe behaviour without reaching inside. Pre-agreed seams are the spec's Testing decisions. (Matt, from Michael Feathers)

**Smell.** A named pattern that usually indicates a design problem, never a hard violation; `spec-review` labels twelve of Fowler's. Comments are not one of ours.

**Spec.** The issue `/to-spec` writes from a grilling session: problem, solution, user stories, implementation decisions, testing decisions, out of scope. A decision record, throwaway once shipped. (Matt)

**spec-review.** Matt's two-axis code review, renamed: Standards (against `CODING_STANDARDS.md`) and Spec (against the originating ticket), in two fresh subagents.

**System boundary.** The edge where your code meets something you do not control (external APIs, time, randomness, the filesystem, sometimes the database). The only place mocks are allowed.

**Ticket.** A GitHub issue produced by `/to-tickets`: `What to build`, `Acceptance criteria`, `Blocked by`, `Parent`, label `ready-for-agent`. The unit of work that gets a fresh context and a PR.

**Tracer bullet.** A ticket that cuts a narrow but complete path through every layer, demoable on its own, sized for one context window. (Matt, from The Pragmatic Programmer)

**Vendored (`.repos/`).** Read-only checkouts of dependencies the agent must imitate correctly, with their agent guides; pointed at from `AGENTS.md`. Never edited or imported. (Theo)

**Verification skill (`verify-<app>`).** A project-local skill generated by `create-verification-skill`: Launch, Doctor, Drive, Evidence, Cleanup, plus a feature map; executed once before it counts. (pstack; Theo's `test-t3-app` is the exemplar.)

**Worktree.** A second checkout of the repo in another folder so branches can be worked in parallel; the isolation primitive for parallel agents. Does not isolate ports, databases or lockfiles.
