# Model roles

pstack reads `~/.claude/pstack-models.md`, one line per role in the form `role: provider:model@effort` (or `inherit-parent`). `factory918 install` writes it once per machine from the `fable` preset in the factory clone's `machine/`; `factory918 models fable|opus` switches presets, because pstack never falls back on its own: when a lane drops out on quota, the orchestrator reports it and you switch. The vendored `/setup-pstack` cannot write it on a Claude-only machine, because it refuses to save unless Codex and Grok lanes also answer a probe.

pstack's matrix has four families: `claude:fable`, `claude:opus`, `codex:gpt-5.6-sol`, `grok:grok-4.6`; Astra joins as a review lane once the Codex CLI reports its slug. Decision 18: Fable writes the code and does the judgment; Opus is the junior. Native lanes exist for every effort of both Claude families (`.claude/agents/pstack-<fable|opus>-<effort>.md`); the two non-Claude families have no lane here and no role uses them.

| Role | fable preset | Why |
| --- | --- | --- |
| feature, refactoring, bug-fix, perf-issue, hillclimb | `claude:fable@high` | the writers; Fable's code is what gets merged |
| judgment and prose, hardest tasks | `claude:fable@high` | judgment is the product |
| how critics, architect runners, arena runners | `claude:fable@high, claude:opus@high` | a senior and a junior lane; panels multiply cost by their size |
| interrogate reviewers, arena cross-judge pool | `claude:fable@high, claude:opus@xhigh` (Astra to be added) | the contested path; model diversity is the point |
| how explorer, swarm workers | `claude:opus@medium` | read-only bulk and mechanical fan-out: the junior |
| how explainer | `claude:opus@high` | |
| why and reflect roles | `inherit-parent` | they need the parent session's MCP surface |

The `opus` preset puts the writers on `claude:opus@high` and the judgment on `claude:opus@xhigh`, for when Fable's quota is spent.

Interactive session: Opus 5 for execution and for grilling; switch to Fable 5.1 with `/model` for `/to-spec` and `/to-tickets`, then switch back. Check the usage page weekly; if Fable is over a third of spend, move a role down.
