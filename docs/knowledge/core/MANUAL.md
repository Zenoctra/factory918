<!-- lines: 111 | source: core/MANUAL.md | part 1/1 | title: Factory918: the manual -->

## Contents (line numbers are for the Read tool's offset)
- L21: The loop in one screen
- L35: Day 0: a new project
- L45: Day 0: an existing project
- L49: Planning
- L59: Tickets
- L63: Execution
- L71: Pull requests, review and merge
- L75: Retro and the ledger
- L79: Multi-surface products
- L83: Models and cost
- L99: Updating the factory
- L103: Troubleshooting

# Factory918: the manual

How to run a project through the system, from an empty directory to a merged pull request, and what the human does at each point. Written for Manuel and for any agent that needs to know what "now" means. Skill names are slash commands in Claude Code; file paths are relative to the project.

## The loop in one screen

```
Day 0      factory918 init  →  /factory-start (interview)  →  /factory918 doctor  →  /setup-pstack once per machine
Plan       /wayfinder (big, foggy)  or  /grill-with-docs (one feature)  →  /to-spec  →  /to-tickets     [human decides]
Tickets    GitHub issues, label ready-for-agent, "Blocked by" edges; the frontier = tickets with no open blockers
Execute    /poteto-mode "#N"  →  Ticket playbook  →  how/why → design → build → prove → PR "Closes #N"   [agent proceeds]
Gates      on write: format · on commit: format · on PR: CI (lint, types, tests, build) + size label
Review     spec-review (always) → external bot (if configured) → interrogate (if contested) → human   [human merges]
Retro      weekly: /reflect; promote recurring corrections to lint rules or AGENTS.md lines; delete rules that never fire
```

If you do not know what to do next, `/factory918`: it maps the situation to the entry point.

## Day 0: a new project

1. `factory918 init <dir> --template vite:application` (or `vite:monorepo` for a multi-surface product, which is the default shape for Manuel's projects). This runs `vp create`, applies the template, creates the GitHub repo (private) and its labels, and prints the human-only steps.
2. Open Claude Code in the project and run `/factory-start`. It interviews you, using Matt's grilling primitive, over the decisions the template cannot make for you: the one-paragraph description, the surfaces, the toolchain profiles in play (Vite+ web, React Native, Python), uncommon dependencies to vendor into `.repos/`, review bots, model tiers, repo visibility. It writes the `AGENTS.md` slots, `docs/adr/0001-toolchain.md`, `.repos/sources.json` and the review-ladder bot list. Until this has run, `factory918 doctor` reports the project as unconfigured.
3. Do the human-only steps it lists: branch protection on `main` requiring `Check` and `Test`, any secrets. `/wizard` will generate a click-by-click script for them.
4. `/setup-pstack` once per machine. It writes `~/.claude/pstack-models.md` (the role-to-model table; defaults in the "Models and cost" section below).
5. `factory918 doctor` until every line is PASS.

You are now in planning. A greenfield project has no code to grill against, so the first session is `/grill-me` or `/wayfinder` on the idea; the second is `/grill-with-docs` on the first feature once the scaffold exists.

## Day 0: an existing project

`factory918 apply` is additive: it never overwrites a file you already have. Then: `vp migrate` if the project is not on Vite+; expect CI to fail on old code and use debt ceilings (`maxOccurrences` in `vite.config.ts` overrides, `per-file-ignores` in `pyproject.toml`) so new rules are absolute for new code and a ratchet for old code. Build the glossary with `/grill-with-docs help me document this repo`; expect fifty questions and answer them yourself, because an agent-authored glossary you do not understand is worse than none. Generate the verification skill with `/create-verification-skill` as soon as the app runs.

## Planning

**When to use which.** `/wayfinder` when the work is bigger than one session and you cannot yet state the questions; it produces a map of decision tickets on GitHub and resolves them one per session. `/grill-with-docs` for one feature in a repo; it writes the glossary and ADRs as it goes. `/grill-me` when there is no repo yet. Then `/to-spec` (synthesis only, no new questions) and `/to-tickets` (tracer bullets with blockers), in the same context window as the grilling. Then `/clear`.

**What you do.** Answer the decisions; let the agent find the facts. Confirm the test seams when `/to-spec` asks; those become the pre-agreed seams `tdd` uses in execution. Approve the ticket breakdown; push back on over-decomposition (the most-reported friction). Create nothing by hand on GitHub; the skills publish.

**Model choice.** Grill on Opus 5 (long sessions). Switch to Fable 5.1 with `/model` for `/to-spec` and `/to-tickets`, then switch back: synthesis is short and high-value, and the context carries across the switch.

**Phase guard.** Typing a planning command sets the phase to planning; a hook prints "PHASE: planning" every turn and poteto-mode stays out. `/mode-build` or a ticket reference flips it back.

## Tickets

A ticket is a GitHub issue with `## What to build`, `## Acceptance criteria` (checkboxes), `## Blocked by`, a `## Parent` pointing at the spec, and the `ready-for-agent` label. The frontier is every ticket whose blockers are closed. You pick which one runs next; the system never auto-dispatches. Tickets close when their PR merges (the PR says `Closes #N`); never close one by hand.

## Execution

`/poteto-mode "#42"` (or paste the issue URL). The Ticket playbook reads the issue and its parent spec, refuses to start if a blocker is open, and runs a falsifiability pass over the acceptance criteria: for each one it names the command or observation that would fail it today, and sends back any criterion that already passes, that another ticket owns, or that merely restates the request. Answer those notes, then it runs the matching pstack playbook (Feature, Bug fix, Refactoring, Perf issue) from step 1: `how` and `why` over the subsystem, design, delegated build with a reviewed diff, verification on the real surface, then Opening a PR and Babysit.

**What you do.** Not much until the PR exists. The agent proceeds on anything reversible and asks only before irreversible actions. If it goes wrong, note what you would have said earlier; that note is a ledger entry, and the ledger is where rules come from.

**Evidence.** `.artifacts/<task>/` holds the proof: numbered screenshots named after the assertion, `assertions.md`, command outputs. It is uploaded to the PR and never committed; CI rejects committed evidence.

## Pull requests, review and merge

The agent opens the PR with a conventional plain-language title, a body that states the problem then the fix, a Verification section quoting each acceptance criterion with its evidence, before/after media for anything visible, and the model and harness that did the work. Then the review ladder in `docs/agents/review-ladder.md`: CI must be green; `spec-review` runs in a fresh context against the ticket and `CODING_STANDARDS.md`; an external bot is triaged only if one is listed; `interrogate` runs only when the design is contested. Babysit stops at merge-ready. You read the conversation and the Verification section, then merge. Reading every line is optional; reading the claims and their evidence is not.

## Retro and the ledger

Once a week, or after a hard task: `/reflect`. Read the ledger (`docs/agents/ledger.md`, one line per surprise: date, model, what it did, what you wanted). A correction that has recurred becomes a rule at the strongest rung that can hold it: a lint rule in `oxlint-plugin-project/` or `ast-grep/rules/` (with a debt ceiling if old code violates it), a banned API, a line in `AGENTS.md`. Delete rules that never fire. This is the step that turns copied opinions into yours.

## Multi-surface products

The default is one monorepo per product: `apps/web`, `apps/mobile`, `apps/admin`, `packages/shared`, `scripts/`, `python/` as needed, one `vite.config.ts`, one CI, one deterministic layer. Vite+ manages the TypeScript surfaces; the React Native profile adds Expo/EAS for mobile builds and simulator verification; the Python profile adds `uv`, `ruff`, `pyright` and `pytest` for Python packages and maps `*.py` to `ruff format` in the same commit hook. Separate repos only when deployment or ownership forces it; then each repo gets the factory and a `system` repo holds the wayfinder maps and a `CONTEXT-MAP.md` pointing at each repo's `CONTEXT.md`.

## Models and cost

You are on the $200 Claude plan; the limit is shared across models and Fable 5.1 spends it fastest. Defaults written by `/setup-pstack` (edit `~/.claude/pstack-models.md` to change; one file):

| Role | Model | Why |
|---|---|---|
| Your interactive session (execution) | Opus 5 | strong, cheaper than Fable, the default worker |
| Your interactive session (grilling) | Opus 5, switch to Fable for `/to-spec` + `/to-tickets` | judgment where it is the product, briefly |
| Feature and refactoring delegates, `how` explorers, `why` investigators, swarm workers | Sonnet 5 | mechanical and read-only bulk |
| Bug fix, perf issue, hillclimb | Opus 5 | needs reasoning, runs often |
| Strongest judgment, prose, synthesis | Opus 5; Fable on request | override per ticket when the design is hard |
| Panels (`how` critics, `architect` runners, `interrogate` reviewers) | Opus 5 + Sonnet 5; add Fable only for `interrogate` on a contested design | panels multiply cost by their size |
| `arena` | off by default | the token burner; enable for a specific bake-off |

Rough cost order of the skills, highest first: `arena`, `swarm`, `interrogate`, `how` in critique mode, `/wayfinder` with parallel research, `/to-tickets` on a large spec (one user reported 1.5M tokens for 14 tickets), then everything else. Check the usage page weekly; if Fable is over a third of spend, move a role down.

## Updating the factory

`factory918 update` performs a three-way merge per managed file: template-unchanged files keep your edits; locally-untouched files take the new template; files you deleted stay deleted; files changed on both sides are merged with `git merge-file`, and conflicts are written beside the file for you to resolve. `factory918 sync` re-vendors the upstream skills from the pins in `SOURCES.md` and re-applies the patches. Run `factory918 doctor` after either.

## Troubleshooting

- **"PHASE: planning" but I want to build.** `/mode-build`, or give it a ticket reference.
- **A skill says it cannot be invoked.** A vendored skill still carries `disable-model-invocation: true`; that flag blocks the model in Claude Code. Only the planning entry points and the mode switches should carry it.
- **`gh issue create --label ready-for-agent` fails.** Labels are missing; `factory918 labels`.
- **A hook blocked a git command.** By design: no pushes to `main`, no force-push, no destructive resets. Use `--force-with-lease` on your own branch or ask.
- **CI red on old code after apply.** Add a debt ceiling for the file, then lower it as you migrate.
- **The agent claims verification it did not do.** Ask for the artifact path. If there is none, it did not verify. Add the case to the ledger.
- **Something feels wrong and you cannot name it.** `/knowledge` with the question; it searches this corpus without reading files whole.
