# Model roles

Work is split between two tiers. **Frontier** is judgment and the code that gets merged. **Supporting** is everything a lesser model can be trusted with: exploration, fan-out, finding. Today both tiers run Opus 5.5 (decision 20). Frontier roles run at `xhigh` effort; Supporting roles keep the effort their role sets, `medium` to `xhigh`, as in the table. A role belongs to a tier; the model behind a tier can change without the role moving.

pstack reads `~/.claude/pstack-models.md`, one line per role in the form `role: provider:model@effort` (or `inherit-parent`). `factory918 install` writes it once per machine from the `default` preset in the factory clone's `machine/`; `factory918 models <preset>` switches to another preset in `machine/`, because pstack never falls back on its own: when a lane drops out, the orchestrator reports it and you switch. The vendored `/setup-pstack` cannot write it on a Claude-only machine, because it refuses to save unless Codex and Grok lanes also answer a probe.

The sheet names Claude's rolling alias `opus`, never a version, so it follows the latest Opus release without an edit (the alias resolved to Opus 5.5 when probed, 2026-09-22). Native lanes exist for every effort of both Claude families (`.claude/agents/pstack-<fable|opus>-<effort>.md`). pstack's matrix also has `codex:gpt-5.6-sol` and `grok:grok-4.6`; they have no lane here and no role uses them.

| Role | Tier | Sheet | Why |
| --- | --- | --- | --- |
| feature, refactoring, bug-fix, perf-issue, hillclimb | Frontier | `claude:opus@xhigh` | the writers; their code is what gets merged |
| judgment and prose, hardest tasks | Frontier | `claude:opus@xhigh` | judgment is the product |
| how critics, architect runners, arena runners | both | `claude:opus@xhigh, claude:opus@high` | one Frontier lane and one Supporting lane |
| interrogate reviewers | both | `claude:opus@xhigh, claude:opus@xhigh` | the contested path; Astra joins here (#29) |
| arena cross-judge pool | both | `claude:opus@xhigh, claude:opus@xhigh` | a judge from a different lane than the base candidate |
| how explorer, swarm workers | Supporting | `claude:opus@medium` | read-only bulk and mechanical fan-out |
| how explainer | Supporting | `claude:opus@high` | |
| standards reviewer | Supporting | `claude:opus@medium` | the Standards axis of `spec-review` matches a pasted diff against pasted rule sections |
| spec reviewer | Supporting | `claude:opus@high` | the Spec axis of `spec-review` is a finder: its context matters more than its model, a well-built brief carries everything it reads, and the orchestrator judges what it finds (step 5) |
| why and reflect roles | the session's | `inherit-parent` | they need the parent session's MCP surface |

`standards reviewer` and `spec reviewer` are the factory's own roles, not pstack's. `/setup-pstack` step 2 treats an unknown role row as inconsistent state, one more reason `/setup-pstack` is not used here (decision P5).

Interactive session: Opus 5.5, at `xhigh` whenever specs, tickets or PR bodies are being written, since that prose is the handoff and no delegate writes it, and at `high` for casual turns and long grilling.
