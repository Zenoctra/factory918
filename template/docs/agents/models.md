# Model roles

pstack reads `~/.claude/pstack-models.md`, one line per role in the form `role: provider:model@effort` (or `inherit-parent`). `factory918 install` writes it once per machine from `machine/pstack-models.md` in the factory clone; edit either file by hand to change a role. The vendored `/setup-pstack` cannot write it on a Claude-only machine, because it refuses to save unless Codex and Grok lanes also answer a probe.

pstack's matrix has four families: `claude:fable`, `claude:opus`, `codex:gpt-5.6-sol`, `grok:grok-4.6`. Sonnet is not one of them, so the cost lever is effort, not family: mechanical delegates run `claude:opus@medium`, reasoning roles `claude:opus@high`, and Fable appears only where judgment is the product. Native lanes exist for every effort of both Claude families (`.claude/agents/pstack-<fable|opus>-<effort>.md`); the two non-Claude families have no lane here and no role uses them.

| Role | Descriptor | Why |
| --- | --- | --- |
| feature, refactoring, how explorer, swarm workers | `claude:opus@medium` | mechanical and read-only bulk |
| bug-fix, perf-issue, hillclimb, how explainer, judgment and prose | `claude:opus@high` | needs reasoning, runs often |
| hardest tasks | `claude:fable@high` | judgment that is the product |
| how critics, architect runners, arena runners | `claude:opus@high, claude:opus@medium` | one provider, two efforts; panels multiply cost by their size |
| interrogate reviewers | `claude:opus@xhigh, claude:fable@high` | interrogate is the contested path, where Fable earns its cost |
| arena cross-judge pool | `claude:fable@high, claude:opus@xhigh` | `arena` is off by default; the pool must still exist |
| why and reflect roles | `inherit-parent` | they need the parent session's MCP surface |

Interactive session: Opus 5 for execution and for grilling; switch to Fable 5.1 with `/model` for `/to-spec` and `/to-tickets`, then switch back. Check the usage page weekly; if Fable is over a third of spend, move a role down.
