# Factory918: the manual

How to run a project through the system, from an empty directory to a merged pull request, and what the human does at each point. Written for whoever runs a project on it and for any agent that needs to know what "now" means. The last section says where everything else is and when it is worth reading. Skill names are slash commands in Claude Code; file paths are relative to the project.

## The loop in one screen

```
Machine    clone factory918  →  factory918 install  →  PATH line  →  Vite+ installer  →  gh auth login      [once]
Day 0      factory918 init  →  /factory-start (interview)  →  /factory-doctor
Plan       /wayfinder (big, foggy)  or  /grill-with-docs (one feature)  →  /to-spec  →  /to-tickets     [human decides]
Tickets    GitHub issues, label ready-for-agent, "Blocked by" edges; the frontier = tickets with no open blockers
Execute    /poteto-mode "#N"  →  Ticket playbook  →  how/why → design → build → prove → PR "Closes #N"   [agent proceeds]
Gates      on write: format · on commit: format · on PR: CI (lint, types, tests, build) + size label
Review     spec-review (always) → external bot (if configured) → interrogate (if contested) → human   [human merges]
Retro      weekly: /reflect; promote recurring corrections to lint rules or AGENTS.md lines; delete rules that never fire
```

If you do not know what to do next, or you are new here, `/factory918`: it runs the doctor, gives the next step, and once everything passes maps the situation to the entry point. `factory918 doctor` is the checklist itself; every failing line says how to fix it.

## Day 0: a new machine

Once per computer. You need `bash`, `git`, `jq` and `python3` (macOS: `brew install jq`; Debian and Ubuntu: `sudo apt install jq python3`; Windows: WSL, or Git Bash with the four on its PATH; Windows is untested). `git clone https://github.com/Zenoctra/factory918.git` anywhere, then from the clone:

1. `./factory918.sh install`. It links `~/.factory918` to the clone (the `knowledge` skill and `$FACTORY918_HOME` default to it), puts `factory918` in `~/.local/bin`, and writes pstack's role sheet `~/.claude/pstack-models.md` with its include line in `~/.claude/CLAUDE.md` if they are missing. Add `~/.local/bin` to `PATH` if it prints that line.
2. Install Vite+: `curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh` (macOS and Linux; on Windows PowerShell, `irm https://vite.plus/ps1 | iex`), then open a new terminal. Vite+ then selects the Node and pnpm version each project declares; `vp env doctor` shows the state. Do not `npm install -g vite-plus`: the global prefix is root-owned on a stock macOS Node, and 0.3.1 needs a newer Node than the stock installer ships.
3. Install `gh` and `uv` (macOS: `brew install gh uv`; Debian and Ubuntu: `sudo apt install gh` and `curl -LsSf https://astral.sh/uv/install.sh | sh`; Windows: `winget install GitHub.cli astral-sh.uv`), then `gh auth login`. Python tooling needs nothing else; `uv run` resolves ruff, pyright and pytest per project. `ast-grep` is a per-project devDependency, not a global tool.
`factory918 doctor` on any project reports the machine state on its first lines.

## Day 0: a new project

1. `factory918 init <dir> [vite:monorepo|vite:application|vite:library]` (`vite:monorepo` is the default shape for a multi-surface product). This runs `vp create` with the default branch set to `main` and Vite+'s own `AGENTS.md` suppressed, applies the template, installs dependencies, formats, creates the private GitHub repo and its labels, and prints the human-only steps.
2. Open Claude Code in the project and run `/factory-start`. It interviews you, using Matt's grilling primitive, over the decisions the template cannot make for you: the one-paragraph description, the surfaces, the toolchain profiles in play (Vite+ web, React Native, Python), uncommon dependencies to vendor into `.repos/`, review bots, model tiers, repo visibility. It writes the `AGENTS.md` slots, `docs/adr/0001-toolchain.md`, `.repos/sources.json` and the review-ladder bot list. Until this has run, `factory918 doctor` reports the project as unconfigured.
3. Do the human-only steps it lists, such as secrets. `/wizard` will generate a click-by-click script for them. The PR page is the merge gate: CI must be green and you read the Verification section before merging (decision P3 leaves branch protection off).
4. `/factory-doctor` until every line is PASS or NOTE.

You are now in planning. A greenfield project has no code to grill against, so the first session is `/grill-me` or `/wayfinder` on the idea; the second is `/grill-with-docs` on the first feature once the scaffold exists.

## Day 0: an existing project

If the project is not on Vite+ yet, run `vp migrate` first: `apply` merges Vite+ scripts and a devDependency into `package.json` and runs `vp install`, so the toolchain has to be there before it. Then `factory918 apply`. It is additive: it never overwrites a file you already have. If the repo came from `vp create` moments ago, `factory918 apply --scaffold` replaces the four files Vite+ scaffolds and Factory918 owns (`AGENTS.md`, `CLAUDE.md`, `vite.config.ts`, `.vite-hooks/pre-commit`); `init` does this for you. A Python package or a mobile app comes from `factory918 apply --profile python --name <pkg>` or `--profile react-native`; profile files are written once and are yours after that. Expect CI to fail on old code and use debt ceilings (`maxOccurrences` in `vite.config.ts` overrides, `per-file-ignores` in `pyproject.toml`) so new rules are absolute for new code and a ratchet for old code. Build the glossary with `/grill-with-docs help me document this repo`; expect fifty questions and answer them yourself, because an agent-authored glossary you do not understand is worse than none. Generate the verification skill with `/create-verification-skill` as soon as the app runs.

## Planning

**When to use which.** `/wayfinder` when the work is bigger than one session and you cannot yet state the questions; it produces a map of decision tickets on GitHub and resolves them one per session. `/grill-with-docs` for one feature in a repo; it writes the glossary and ADRs as it goes. `/grill-me` when there is no repo yet. Then `/to-spec` (synthesis only, no new questions) and `/to-tickets` (tracer bullets with blockers), in the same context window as the grilling. Then `/clear`.

**What you do.** Answer the decisions; let the agent find the facts. Confirm the test seams when `/to-spec` asks; those become the pre-agreed seams `tdd` uses in execution. Approve the ticket breakdown; push back on over-decomposition (the most-reported friction). Create nothing by hand on GitHub; the skills publish.

**Model choice.** Grill on Opus 5 (long sessions). Switch to Fable 5.1 with `/model` for `/to-spec` and `/to-tickets`, then switch back: synthesis is short and high-value, and the context carries across the switch. In execution, run the interactive session on Fable whenever tickets or PR bodies are being written: that prose is the handoff, and no delegate writes it.

**Phase guard.** Typing a planning command sets the phase to planning; a hook prints "PHASE: planning" every turn and poteto-mode stays out. `/mode-build` or a ticket reference flips it back.

## Tickets

A ticket is a GitHub issue with `## What to build`, `## Acceptance criteria` (checkboxes), `## Blocked by`, a `## Parent` pointing at the spec, and the `ready-for-agent` label. The frontier is every ticket whose blockers are closed. A PR based on another PR's branch shows no link to its ticket until it retargets to `main`; the link appears once it retargets. A quick fix you describe in conversation gets a ticket too, if it will end in a PR: the agent files one with your words quoted, tells you the number, and proceeds; edit the issue if the words are wrong. Nothing runs on its own: you name the next ticket, or you hand the agent a list (see Execution). Tickets close when their PR merges (the PR says `Closes #N`); never close one by hand.

## Execution

`/poteto-mode "#42"` (or paste the issue URL). The Ticket playbook reads the issue and its parent spec, refuses to start if a blocker is open, and runs a falsifiability pass over the acceptance criteria: for each one it names the command or observation that would fail it today, and sends back any criterion that already passes, that another ticket owns, or that merely restates the request. Answer those notes, then it runs the matching pstack playbook (Feature, Bug fix, Refactoring, Perf issue) from step 1: `how` and `why` over the subsystem, design, delegated build with a reviewed diff, verification on the real surface, then Opening a PR and Babysit.

**Safe and eco.** A run has a tier. `safe`, the default, is every playbook as written. `eco` keeps in fresh context every lane whose job is finding someone else's mistakes (the writer, blast radius, both reviewers every round, the architect judge and the trail review) and has the owner do the rest itself: its own `how` reading, one architect runner instead of two, the review without a wrapper lane, its small fixes and records, and a one-page report. The table-first, tests-first design step is the same in both. `echo eco > .claude/state/tier` in the main checkout sets it; `rm .claude/state/tier` goes back to `safe`. A ticket reads the tier when it starts, and each autopilot-stack owner's brief carries it, so a change reaches only tickets started after it. `safe` is the fallback: when a model struggles in `eco` (a restart, a fifth review round, a verifier finding what the owner missed), run the next ticket, or this one again, in `safe`. The delegation hook guards the session you type into the same way in both tiers, so in a ticket you run directly a small fix still goes to a fix lane; an autopilot-stack owner writes its own. The full list is Ticket step 0, "The tier", and `DECISIONS.md` P109.

**Several at once.** One ticket per `/poteto-mode "#N"` is the default, and a fresh session per ticket keeps the orchestrator's context clean. Two unblocked tickets relate three ways. A dependent ticket lists the other under `## Blocked by` and stays off the frontier until it merges. Two independent tickets disjoint in files each branch from `main`, in any order. Two independent tickets that overlap in files are sequenced. The first goes to merge-ready, you merge, the next starts. Overlap is not coupling. Coupled work is a ticket that needs code an open PR introduces, and only that stacks, only on your go. The Ticket playbook checks before it branches (`overlap.sh` compares each open PR's own commits, its diff from the PR under it or from `main`, with the paths the ticket names) and on overlap stops and names the PR to merge first, unless your go opened a program that names the ticket.

**Draining the frontier.** `/poteto-mode "autopilot-stack #4 #5 #8"` is for coupled work. pstack's autopilot-stack runs one owner lane per ticket in its own context and worktree, swarm-verifies each PR, keeps the chain rebased as `main` moves, and hands you one bottom-to-top list of verified PRs to land one at a time; it never merges (`playbooks/autopilot-stack.md` is the full procedure). It states its plan first and starts on your go, then runs without you; each owner runs the Ticket playbook for its ticket, so every unit needs a ticket and quick tickets come first. Your go opens a program, a line the agent appends with `overlap.sh go`, naming its tickets (this run, or a sweep run as one chain), and stands for every stack the program builds. A line covers only stacks among the tickets it names, so it needs no removal. An overlap inside it is recorded in the PR body (`## Overlap`) and the ticket stacks on the PR it overlaps. A rebase re-reviews only a PR whose `git patch-id` changed, so a fix low in the chain costs one re-review, not one per PR above it. Its sibling `autopilot-full` is not used here: its merge step is blocked by the git guard.

**What you do.** Not much until the PR exists. The agent proceeds on anything reversible and asks only before irreversible actions. If it goes wrong, note what you would have said earlier; that note is a ledger entry, and the ledger is where rules come from.

**Evidence.** `.artifacts/<task>/` holds the proof: numbered screenshots named after the assertion, `assertions.md`, command outputs. It is uploaded to the PR and never committed; CI rejects committed evidence.

## Pull requests, review and merge

From a pull request to a merge, in order. Every rung runs without asking you; you enter at the end. The full ladder is `docs/agents/review-ladder.md`; missing rungs are skipped, never failed.

1. **Before the PR.** A hook formats every file the agent writes, and each commit runs the formatter on the staged files and nothing else (decision 5: agent-authored repos commit often, so the commit hook stays thin and CI is the one full gate). The agent verifies on the real surface and files its proof under `.artifacts/<task>/`: numbered screenshots named after the assertion, an `assertions.md`, command outputs with exit codes. Evidence is uploaded to the PR and never committed; CI rejects a commit that contains it.
2. **The PR itself.** A conventional plain-language title; the problem, then the fix; a Verification section quoting each acceptance criterion with its evidence; before/after media for anything visible; the model and harness that did the work. Ticket work says `Closes #N`, so the ticket closes itself on merge. One concern per PR.
3. **Rung 0, CI.** The `Check` job rejects committed evidence, runs `vp check` (format, lint including the project's own rules, types), `pnpm sg` (the cross-language rules) and the build; the `Test` job runs the whole suite; `pr-size.yml` labels the size. This is the only place everything runs, which is why local checks stay targeted. Green here proves the code is well-formed and the tests pass. It proves nothing about whether it is the right change.
4. **Rung 1, `spec-review`.** The agent runs round one at the first push, while CI runs, in a fresh context so the reviewer is not the author. CI must be green before the PR is merge-ready, not before round one. Two axes: Standards, against `CODING_STANDARDS.md` (the taste the implementer was deliberately not loaded with, so that review imposes it rather than the writer); Spec, against the originating ticket and its parent spec, the only check that the change is what was asked for. Act-on items get fixed; the rest are recorded in the PR body.
5. **Rung 2, an external review bot**, only if one is listed in the ladder file; none is by default. Findings are verified against the source and fixed, or dismissed with a written reason; the agent asks by default on security, auth, data, billing and migrations.
6. **Rung 3, `interrogate`**, a multi-tier review across models, only when the design is contested or the diff touches an invariant named in `CONTEXT.md`. It is the expensive rung, so it is conditional.
7. **Babysit.** The agent polls checks and comments newer than its last push until everything is green on the latest commit, then stops at merge-ready.
8. **Rung 4, you.** Read the conversation and the Verification section against its evidence. Reading every line is optional; reading the claims and their proof is not. Merge. The agent never merges.

**Your merge, step by step.** You never need the git syntax for any of this; say the words and the agent runs the commands.

1. Ask for a read, not a diff: "where does PR N stand?" or "is PR N safe to merge?". The agent reads the checks, the comments and the Verification section, runs `spec-review` if it has not run, and answers with what changed, what proved it, what is unresolved, and a recommendation.
2. It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0` and that comment carries no `restart` line (a design hole returned to `architect`; the PR is ready only when a later review comment without one reads `act-on items: 0`) and no `would-break fixed after` line (a hard-bug fix owed one more round, or at `round: 5 of 5` a PR the agent marked unfinished for your report) and no `next round owed:` line (a round-one or round-two comment whose fixes were marked before posting; the next round reviews them); every claim in the Verification section points at evidence you could open; no comment is unresolved; and it does one thing. If any of those is missing, say "fix that and come back".
3. Merge on GitHub: the PR page's green **Merge** button. That click is the human act, and the git guard makes sure it stays yours: `gh pr merge` is blocked for the agent.
4. If PRs are stacked (one based on another), merge them in order. GitHub retargets the next one to `main` by itself only when the merged branch is deleted; `init` turns that on for repositories it creates, and elsewhere delete the branch after merging (GitHub offers the button on the merged PR).
5. Nothing, unless you want it now. At the start of the next ticket the agent fetches and starts the ticket's branch from an up-to-date `main` on its own, so bringing your copy up to date is no longer something you have to remember to say. "We merged PR N, bring my copy up to date" is still there for when you want open branches re-stacked right now, between tickets.

Where your judgment sits: before the work, in the ticket; after it, at the merge. In between, nothing asks you except an irreversible action: a force-push, a deletion, a deploy, a message outside the repo (decision 6). That is what "never block on the human" means here: the rungs are the safeguard, so the agent does not have to be.

## Retro and the ledger

Whenever an agent surprises you, add one line to `docs/agents/ledger.md`: date, model, what it did, what you wanted. Saying "note that for the ledger" to the agent is enough. Once a week, or after a hard task, `/factory-retro`: it reads the ledger, groups the corrections that recur, and proposes for each the strongest rung that can hold it (a type, a lint rule in `oxlint-plugin-project/` or `ast-grep/rules/` with a debt ceiling if old code violates it, a banned API, a helper, a test, or one line in `AGENTS.md`), then writes the ones you confirm and proves each one fires. A correction seen once waits. Delete rules that never fire. `/reflect` is pstack's complement: it mines the session you just had for learnings and routes them into skill edits; use it after a session that went unusually well or badly. The retro is the step that turns copied opinions into yours.

## Maintenance

Work you start without a ticket, on a cadence:

- After any session that surprised you: one line in `docs/agents/ledger.md`. The phase hook reminds you when unreviewed lines exist and a week has passed since the last retro.
- Weekly: `/factory-retro`. It reads the ledger and the week's transcripts, groups what recurred, proposes a rule for each and encodes what you confirm.
- After a session that went unusually well or badly: `/reflect`, which turns that transcript into skill edits.
- After UI changes land: `/maintain-verification-skill` keeps `verify-<app>` honest.
- Before a large feature, or monthly: `/thermo-nuclear-code-quality-review` on the area you are about to touch, or `/architect` to reshape it before code.
- When the factory publishes a version: `git -C ~/.factory918 pull`, then `factory918 update` and `factory918 doctor` in each project.
- Scratch: `.artifacts/`, `.scratch/` and `.plans/` are git-ignored and nothing deletes them. `factory918 doctor` prints a NOTE naming `.artifacts/<task>/` directories older than two weeks; delete one once its PR is merged.

## Multi-surface products

The default is one monorepo per product: `apps/web`, `apps/mobile`, `apps/admin`, `packages/shared`, `scripts/`, `python/` as needed, one `vite.config.ts`, one CI, one deterministic layer. Vite+ manages the TypeScript surfaces; the React Native profile adds Expo/EAS for mobile builds and simulator verification; the Python profile adds `uv`, `ruff`, `pyright` and `pytest` for Python packages and maps `*.py` to `ruff format` in the same commit hook. Separate repos only when deployment or ownership forces it; then each repo gets the factory and a `system` repo holds the wayfinder maps and a `CONTEXT-MAP.md` pointing at each repo's `CONTEXT.md`.

## Models and cost

You are on the $200 Claude plan; the limit is shared across models and Fable 5.1 spends it fastest. Decision 18: Fable writes the code. `factory918 install` writes `~/.claude/pstack-models.md` from the `fable` preset; when Fable's quota runs out a lane drops out and the orchestrator says so, and `factory918 models opus` switches to the Opus preset (`factory918 models fable` switches back). A machine that ran `install` before decision 18 keeps its old sheet until `factory918 models fable` is run once. One file, two presets:

| Role | fable preset | opus preset |
|---|---|---|
| Your interactive session | Fable when tickets or PRs are being written; Opus for casual turns | Opus |
| Writers: feature, refactoring, bug fix, perf, hillclimb | Fable 5.1 high | Opus 5 high |
| Judgment and prose, hardest tasks | Fable 5.1 high | Opus 5 xhigh |
| Panels: `how` critics, `architect`, `arena` runners | Fable + Opus | Opus high + Opus medium |
| `interrogate` reviewers, `arena` cross-judge | Fable + Opus xhigh, Astra when wired | Opus xhigh + Opus high |
| Juniors: `how` explorers, swarm workers, `standards reviewer` (the `spec-review` Standards axis) | Opus 5 medium | Opus 5 medium |
| `spec reviewer` (the `spec-review` Spec axis; the orchestrator judges its findings) | Opus 5 high | Opus 5 high |
| `arena` | off by default | off by default |

The tier (Execution, **Safe and eco.**) decides how many of these roles a ticket launches; `eco` drops the explorer, explainer, review wrapper, fix and records lanes.

Rough cost order of the skills, highest first: `arena`, autopilot-stack (one owner per ticket plus a swarm per PR), `swarm`, `interrogate`, `how` in critique mode, `/wayfinder` with parallel research, `/to-tickets` on a large spec (one user reported 1.5M tokens for 14 tickets), then everything else. Check the usage page weekly; if Fable is over a third of spend, move a role down.

## Updating the factory

`git -C ~/.factory918 pull`, then `factory918 update` in the project. It performs a three-way merge per managed file: template-unchanged files keep your edits; locally-untouched files take the new template; files you deleted stay deleted; files changed on both sides are merged with `git merge-file`, and a real collision is written beside the file as `<file>.factory-merge` with the usual conflict markers while your file is left alone. Resolve it, delete the `.factory-merge`, and run `factory918 doctor`. `factory918 sync` re-vendors the upstream skills from the pins in `SOURCES.md` and re-applies the patches. Run `factory918 doctor` after either.

## Troubleshooting

- **"PHASE: planning" but I want to build.** `/mode-build`, or give it a ticket reference.
- **A skill says it cannot be invoked.** A vendored skill still carries `disable-model-invocation: true`; that flag blocks the model in Claude Code. Only the planning entry points and the mode switches should carry it.
- **`gh issue create --label ready-for-agent` fails.** Labels are missing; `factory918 labels`.
- **A hook blocked a git command.** By design: no pushes to `main`, no force-push, no destructive resets. Use `--force-with-lease` on your own branch or ask.
- **CI red on old code after apply.** Add a debt ceiling for the file, then lower it as you migrate.
- **`vp check` reports only formatting, but you expected lint or type errors too.** It stops at the first stage that fails. Run `vp fmt`, then `vp check` again to see the rest.
- **A `.factory-merge` file appeared.** `factory918 update` found a line changed both by you and by the template. Merge it by hand into the real file, delete the `.factory-merge`.
- **The agent claims verification it did not do.** Ask for the artifact path. If there is none, it did not verify. Add the case to the ledger.
- **Something feels wrong and you cannot name it.** `/knowledge` with the question; it searches this corpus without reading files whole.

## Where to read more

Everything below lives in the factory clone (`~/.factory918`); a project carries only the first five, under `docs/factory918/`.

- `MANUAL.md` (this file): how the loop runs and what you do at each point. Read before the first project; return to "Troubleshooting".
- `PHILOSOPHY.md`: why it is built this way, in twelve ordered beliefs, and how to decide when nothing else answers. Read once whole; read again when a rule fights you.
- `DECISIONS.md`: every settled choice with its reason, and the provisional ones an agent made. Read before overriding a vendored skill or asking for a change; decisions beat every source.
- `GLOSSARY.md`: the terms (ticket, spec, map, surface, rung, ledger). Open when a word in `AGENTS.md` or a playbook is unclear.
- `SCENARIO-TABLE.md`: the design artifact for anything with state (a file, exit codes, rounds, more than one actor), its shape, and why it is a rule. Open when a ticket carries a table under `## Testing decisions` or an agent has to write one.
- `docs/knowledge/INDEX.md`: the map of the whole corpus, every file with its size and when to read it. `/knowledge <question>` searches it for you without reading files whole; that is the fastest way to learn how any one part works.
- `docs/knowledge/pages/`: the research behind the four sources (what Matt, Theo, pstack and Ras Mic each do), the deterministic layer explained from zero, and the evidence on planning with agents. Read for background, a section at a time.
- `docs/FACTORY-SPEC-v2.md` and `docs/M0-findings.md`: the design and what was actually verified against real tools. Only if you are changing the factory itself.
- `template/AGENTS.md`: the letter every agent in a project reads on every turn. Read it once to know what the agents have been told.
