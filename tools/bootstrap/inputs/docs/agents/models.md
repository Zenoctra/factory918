# Model roles (defaults for `/setup-pstack`)

Copy the table below into `~/.claude/pstack-models.md` when `/setup-pstack` asks, or accept these when it offers them. One file; change a role by editing a line. Reason for the shape: the $200 plan's limit is shared across models and Fable 5.1 spends it fastest, so Fable is reserved for judgment that is the product.

| Role (pstack) | Model | Effort |
|---|---|---|
| feature, refactoring (code-writing delegates) | claude-sonnet-5 | high |
| how explorer, why investigators, swarm workers | claude-sonnet-5 | medium |
| bug-fix, perf-issue, hillclimb | claude-opus-5 | high |
| judgment and prose, hardest tasks | claude-opus-5 (override to claude-fable-5-1 per ticket) | high |
| how critics, architect runners, arena runners | claude-opus-5, claude-sonnet-5 | high |
| arena cross-judge pool | claude-opus-5 | xhigh |
| interrogate reviewers | claude-opus-5, claude-sonnet-5; add claude-fable-5-1 only when the design is contested | high |

Interactive session: Opus 5 for execution and for grilling; switch to Fable 5.1 with `/model` for `/to-spec` and `/to-tickets`, then switch back.

Slugs must match what the harness actually exposes; `/setup-pstack` enumerates them and refuses to write a slug it cannot confirm. Adjust after the first week using the usage page: if Fable is over a third of spend, move a role down.
