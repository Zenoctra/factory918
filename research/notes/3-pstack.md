# pstack (Lauren Tan / @poteto) — System & Skills

Research notes for Manuel (Claude Code user, new to software development and to agentic coding). Compiled 2026-09-04 from a full read of the upstream plugin at `research/3-pstack/upstream-cursor-plugin/` (v0.14.8, last commit 2026-09-02) plus the three community ports cloned alongside it, plus web sources. Every substantive claim carries a local path or URL. Quotations are verbatim. Where I could not verify something, it says "unverified".

Conventions: "upstream" means Lauren's plugin in `cursor/plugins`. "Local path" citations are relative to `research/3-pstack/upstream-cursor-plugin/` unless otherwise stated. X/Twitter pages could not be fetched from this environment (robots.txt), so her X articles are cited through secondary write-ups that quote them, and post dates are decoded from the X snowflake IDs.

---

## Who she is and why it exists (sourced)

**Identity.** The README opens in her voice: "i'm poteto. i'm not a president or ceo, but i've worked with millions of lines of code at Meta, Netflix, and Cursor. i'm also on the react core team where i help build and maintain react compiler." (`README.md`, line 3). Corroboration: the react.dev team page lists Lauren Tan as "Engineer at Cursor" in the Compiler working group (https://react.dev/community/team); her GitHub bio reads "Software Engineer @cursor & @react compiler core team" (https://github.com/poteto); the LICENSE is "Copyright (c) 2026 Lauren Tan", MIT (`LICENSE`). Her older handle was `sugarpirate` (npm `~sugarpirate`, keybase.io/sugarpirate, and EmberConf 2016/2017 talks on speakerdeck under `poteto`), i.e. she was an Ember/Elixir community figure before React.

**Timeline of employers.** Per Leslie Li's close reading of her X article "How I Use Cursor" (published 2026-05-25, https://x.com/poteto/article/2058975157503570132; summary at https://leslieli.dev/notes/go-deep-first-pstack/): at Meta she paid for a personal Claude Code plan, "had started wrapping it in her own orchestrator", interviewed at Cursor, and joined "at the end of March" 2026 to work on Cursor 3's Agent Window. Cursor was then acquired by SpaceXAI (deal completed 2026-08-14 per https://9to5mac.com/2026/08/14/spacex-lands-deal-to-likely-purchase-claude-code-and-openai-codex-competitor/), which is why the current plugin defaults to Grok models and ships a "make-bot-ui" skill for "Grok Bot". Her LinkedIn headline surfaces in search as "Building Grok Bot and Cursor @ SpaceXAI" (https://www.linkedin.com/in/laurenelizabethtan/; page itself not fetchable, headline unverified beyond the search snippet). A third-party post (https://coursiv.io/blog/grok-bot, 2026-08-26) describes her as a "SpaceXAI engineer" who "previously built software at Cursor, Meta, and Netflix".

**Why pstack exists (her words).** "there's a growing sense that ai writes too much slop code. i agree. i don't want to ship like a team of twenty slop artists. throughput without quality is not a goal i aspire to. if you want to go fast, go deep first." (`README.md`, line 5). "pstack is my answer. these are the same skills i use everyday to ship high quality code at Cursor. this turns cursor into a real engineering team. the goal is not to maximize loc, in fact it's the opposite. pstack helps you write less, but higher quality code." (line 7). From "How I Use Cursor" (via leslieli.dev): "Agents are like new hires in a constant state of amnesia and idiocy. They don't remember what you tell them, and they never really learn anything new." and "Naive parallelization just makes them write slop faster." Rules, skills, tools and memory are her substitute for the team memory a new hire lacks.

**Public history.** First commit "Add pstack plugin" on 2026-05-22 (git log of `cursor/plugins`, 79 commits touching `pstack/`, 76 authored by "lauren"). Launch had 29 skill directories and seven named playbooks; today there are 45 skill directories (24 workflow skills + 21 principles), 22 playbooks plus the shared "Opening a PR" playbook, 2 subagents, and a dormant automation pack. Version bumps: 0.4.0 (05-27), 0.9.0 with `/setup-pstack` (06-06), Benny automation (06-23), sticky mode (07-09), verification-skill generator (07-12), public tutorial (07-22), swarm (07-30), autopilots/no-comments/technical-writing 0.13.0 (08-01), babysit/shipping/orchestrate/bro 0.14.0 (08-02), make-bot-ui (08-26), "Fable 5.1 defaults" (09-01), 0.14.8 logo fix (09-02). Flavio Copes reports "At launch, Lauren showed that her skills had been used 9,000 times inside Cursor in one week" (https://flaviocopes.com/pstack/, 2026-08-21). On 2026-08-19 she posted "I shipped 1000 PRs last month and am on track to doubling that this month, all thanks to cloud agents." (https://x.com/poteto/status/2090141955695198633, quoted at https://www.bestxbuilds.com/builds/pstack). She gave a Maven workshop "How Cursor Turned AI Agents Into Better Engineers" on 2026-08-12 with Colin Matthews of Lenny's Newsletter (https://maven.com/p/e23d9c/how-cursor-turned-ai-agents-into-better-engineers), and began an X article series "The Complete Guide to pstack Pt. 1" on 2026-08-31 (https://x.com/poteto/article/2094457600259842065; content not fetchable, presumably overlapping `docs/guide/`, unverified).

---

## Philosophy: the 21 principles

Each principle is its own skill folder (`skills/principle-*/SKILL.md`), grouped by the poteto-mode index into core / architecture / verification / delegation / meta (`skills/poteto-mode/SKILL.md`, lines 37–75). The one-liner below is the verbatim `description:` from each SKILL.md frontmatter, then one paragraph on what it means in practice.

**Core**

1. **Laziness Protocol** — "Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem." The body's prime directive: "If a human developer would find the code exhausting to maintain, it is a bad solution. Be lazy. Stay simple." It is the anti-over-engineering rule: prefer deletion, flat call hierarchy (flatten anything that takes more than three files to trace), minimize the diff.

2. **Foundational Thinking** — "Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious." Data structures first; scaffold (CI, tests, shared types) before features; "Subtraction comes before scaffolding".

3. **Redesign from First Principles** — "Apply when integrating a new requirement into an existing design. Redesign as if the requirement had been a foundational assumption from day one, instead of bolting it on." Ask "if we were writing this from scratch with this new requirement, what would we build?" then deliver incrementally.

4. **Subtract Before You Add** — "Apply when sequencing an addition, refactor, or rewrite. Remove dead weight, redundant validators, and stub references first, then build on the simpler base." "Cut before you polish"; no speculative validators or guards.

5. **Minimize Reader Load** — "Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope." The test: "Can a new reader answer 'where does X come from?' and 'what can change X?' in under 30 seconds?"

6. **Outcome-Oriented Execution** — "Apply during planned rewrites and migrations with explicit phase boundaries. Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code." Planned, scoped breakage mid-migration is fine; full verification at the end is mandatory.

7. **Experience First** — "Apply when product, UX, or feature-scope tradeoffs come up. Choose user delight over implementation convenience; ship fewer polished features over more rough ones." Notably it widens "user" to "the colleague who imports it" and "the engineer who maintains the code next".

8. **Exhaust the Design Space** — "Apply when facing a novel UI interaction or architectural decision with no precedent in the codebase. Build 2-3 competing prototypes and compare side by side before committing." "Design it twice is this rule by another name. A second flavor of the first shape does not count." This is what `/arena` and `/architect` mechanize.

9. **Build the Lever** — "Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand. The tool is the artifact a reviewer can rerun." Hard rule: "Applying this principle produces a file. If you cited it and there is no codemod, script, generator, or delegate skill in the diff, you didn't apply it." (added 2026-05-26)

**Architecture**

10. **Model the Domain** — "Apply when writing stateful logic, or when code branches a lot or repeats a shape assumption across files. Encode the domain in a structure instead of scattered conditionals." State machine over scattered booleans, table/registry over branching, reducer over ad hoc mutation. "The tell that you skipped this is a new feature that grows an existing if/else chain by one more branch". (added 2026-07-11)

11. **Boundary Discipline** — "Apply when wiring validation, error handling, or framework adapters. Concentrate guards at system boundaries (CLI, config, network, external APIs); trust internal types and keep business logic in pure functions." "Is this data crossing a system boundary right now? If not, validation is redundant."

12. **Type System Discipline** — "Apply when designing types, reviewing a function signature, or writing code in any statically-typed language. Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, refuse to lie to the compiler, exhaust variants, derive from authoritative schemas." "The type checker is a proof assistant." Includes the nuance "Strengthen a type only where partiality appears" (don't over-precise types).

13. **Make Operations Idempotent** — "Apply when designing commands, lifecycle steps, or processing loops that run amid crashes, restarts, and retries. Converge to the same end state regardless of partial prior runs." The test: "What happens if this runs twice? What happens if the previous run crashed halfway?"

14. **Migrate Callers Then Delete Legacy APIs** — "Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers." Scoped to internal APIs with no external consumers.

15. **Separate Before Serializing Shared State** — "Apply when concurrent actors might write to the same file, branch, key, or state object. Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant." "Instructions and conventions are not concurrency control." This is why every parallel skill insists on one worktree per worker.

**Verification**

16. **Prove It Works** — "Apply after completing a task, before declaring done. Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.'" "Delegation: trust artifacts, not self-reports." and "Script the check when you can."

17. **Fix Root Causes** — "Apply when debugging. Trace each symptom to its root cause and fix it there; reproduce first, ask why until you reach it, resist nil-check guards that silence crashes." Adds "Restart bugs: suspect state before code" and "If a workaround needs a paragraph-long comment to justify it, the code is wrong".

18. **Sequence Work into Verifiable Units** — "Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break work into small units that each end in a verifiable state, check each before the next, and order delivery so the sequence proves itself to a reviewer." Canonical shape: failing test commit first, fix on top ("watch it go red, then green"). (added 2026-06-06)

**Delegation**

19. **Guard the Context Window** — "Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads." "The context window is finite and non-renewable within a session."

20. **Never Block on the Human** — "Apply when tempted to ask 'should I do X?' on reversible work. Proceed, present the result, let the human course-correct after the fact; reserve confirmation for irreversible actions." "Code is cheap. Waiting is expensive." Boundaries: force-push, deleting production data, sending external messages still require confirmation; "Product direction comes from the human; execution should not block."

**Meta**

21. **Encode Lessons in Structure** — "Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text." "The instruction IS the symptom." Pick the strongest rung: unrepresentable state > lint/banned API > canonical helper > runtime check.

How they are enforced: poteto-mode's first non-negotiable is "Start every multi-step task with a todolist whose first item is to read the Principles section below in full ... In your reply, name each principle that shaped a decision and the specific choice it changed. A citation with no decision behind it means you skipped its leaf skill" (`skills/poteto-mode/SKILL.md`, line 15). The guide adds that you steer with the names: "You don't invoke principles. You use their names to steer." (`docs/guide/08-principles.md`).

---

## The workflow

```
 you: "/poteto-mode <goal + how you'll know it's done>"
   │
   ▼
 poteto-mode (router; sticky across turns)
   ├─ todo #1: read the Principles index in full
   ├─ match task → ONE playbook; copy its steps verbatim into the todo list
   │     (skipped step stays listed as `skip: <reason>`)
   ├─ large / cross-cutting / "trust it when i'm back" → figure-it-out designs a bespoke playbook
   └─ standing multi-day program → Orchestrate
   │
   ▼
 UNDERSTAND   how (+ why for history)            ← read-only explorers on cheap model
   │
   ▼
 DESIGN       name the data shape (model-the-domain)
              crosses a function boundary? → architect → arena (N runners, cross-judge, graft)
              throughput checkpoint (what blocks, what parallelizes, what state is shared)
   │
   ▼
 BUILD        delegate to subagent (poteto-agent, explicit model per role), review its diff yourself
              tdd when a cheap failing test exists; typescript-best-practices auto-loads on .ts
   │
   ▼
 VERIFY       prove-it-works on the real surface (control-ui / control-cli / verify-<app> skill)
              blast-radius for scary small diffs; swarm to fan verification lanes out
   │
   ▼
 REVIEW/CLEAN interrogate (multi-model adversarial) if contested
              /deslop diff → /no-comments (Comment Sicko) → technical-writing + unslop on prose
   │
   ▼
 SHIP         Opening a PR (worktree, small ordered commits, Conventional Commits, evidence in body)
              Babysit (conflicts → threads → CI, stops at merge-ready)  →  Shipping (independent
              per-PR verdict, land only the contiguous verified run from the bottom)
   │
   ▼
 REPLY        short declarative sentences, principle citations tied to decisions, framed for the
              consumer and the maintainer; show-me-your-work trail + cross-model "Attention" section
              for unattended runs
```

Where the human sits: at the front (goal + finish condition), at the back (auditing evidence, decision log, PR), and at hard gates only. Per the Autonomy section: "Just do it. Use any MCP tool. Reversible work and external actions ... proceed without asking. Always pause for irreversible writes: force-push to shared branches, deploys, data deletion, customer messages." (`skills/poteto-mode/SKILL.md`, lines 79–81). Even design forks are not the human's to answer if an experiment can settle them: "If the answer is a fact you could observe by running something ... it is not the human's to answer. Sketch it via the Prototype playbook" (line 20). Babysit "never merges, even with everything green, because merging is a different decision" (`docs/guide/06-verify-and-ship.md`). The one explicit "stop and show me" is opt-in: "/architect with checkpoint" (`skills/architect/SKILL.md`, Phase C).

Sources: `skills/poteto-mode/SKILL.md`; `docs/guide/02-poteto-mode.md` (mermaid of the router); `docs/guide/07-overnight.md` (loop diagram).

---

## The six axes

### 1. Team/development architecture

**Solo operator, agent "team".** pstack is one person's private workflow published as a plugin: "this turns cursor into a real engineering team" (`README.md`). The team is made of subagents with assigned roles, not humans. Every `Task` (Cursor's subagent call) defaults to "run_in_background: true, agent mode (readonly strips MCP), file pointers not inlined context, explicit model per role" (`skills/poteto-mode/SKILL.md`, line 91). Code-writing delegates spawn as `subagent_type: "poteto-agent"`, a six-line wrapper whose only job is to read `poteto-mode` in full before working (`agents/poteto-agent.md`); the README warns "substituting generalPurpose skips that read and drifts".

**Model-role delegation.** Roles, not tasks, get models. Current upstream defaults (`skills/setup-pstack/SKILL.md`, lines 39–56): `feature, refactoring`, `how explorer`, `why investigators`, `swarm workers` → `grok-4.6-fast-xhigh`; `bug-fix`, `perf-issue`, `hillclimb`, `judgment and prose`, `hardest tasks` → `claude-fable-5-1-thinking-max`; the five panels (`how critics`, `arena runners`, `arena cross-judge pool`, `architect runners`, `interrogate reviewers`) → `claude-fable-5-1-thinking-max, gpt-5.6-sol-max, grok-4.6-fast-xhigh, claude-opus-5-thinking-xhigh`. Rationale: "precisely-specified code, prose, and judgment go to fable 5.1, while fast mechanical code goes to grok" (`README.md`, line 30). These defaults have churned with the market: launch used `composer-2.5-fast` and `claude-opus-4-7-thinking-xhigh` (git show `24bd6eb`); grok-4.5 + fable-5 on 2026-07-08; Opus 5 added 07-26; grok 4.6 on 08-13; "solo defaults to Fable 5.1" on 09-01 (`23a56e2`). `inherit-parent`/`auto` means "omit the subagent model field, so the subagent inherits your parent chat model" (`docs/guide/01-setup.md`).

**Parallel agents: arena vs swarm.** "/arena take my prompt to the arena verbatim" runs N candidates at the same brief in separate worktrees, a read-only cross-judge "on a different model family", then "Pick a base ... Graft ... Verify" (`skills/arena/SKILL.md`). "/swarm" is coverage or races: "Fan out N parallel cloud workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report", each worker reports `PASS`, `ISSUES`, or `BLOCKED` (`skills/swarm/SKILL.md`). The guide's pitfall list: "Using /arena for coverage. /arena repeats one design or code brief, then picks a base and grafts the best parts. /swarm partitions slices or declared race arms and aggregates one report." (`docs/guide/10-recipes-and-pitfalls.md`). The concurrency rule under both is one writer per worktree (principle 15).

**Overnight loops.** The overnight contract (`docs/guide/07-overnight.md`): goal + "done means..." predicate + fresh worktree + "don't ask me before committing" + `/loop until done` + escape hatch. `/loop` is Cursor's built-in wake mechanism, "not a pstack skill". The Autonomous run playbook: "State the exit condition as a checkable predicate before the first iteration ... commits if it advanced, discards changes that didn't help ... A plateau is not a stop" (`playbooks/autonomous-run.md`). Scaling up: Autopilot-full (one owner agent per independent PR, root swarm-verifies each head before the owner merges), Autopilot-stack (same loop, but "nothing auto-ships"), and Orchestrate (a standing coordinator that "never authors or edits code", a TSV/JSON store driven by `scripts/orch/orch.ts`, briefs with GOAL/SCOPE/CONTEXT/ACCEPTANCE/VERIFY/TIMEBOX/FORBIDDEN/REPORT/STANDING fields, and the warning that "this playbook's ceremony turned a half-hour 12-unit job into 1 landed unit while a plain agent landed all 12"). Her reported "1000 PRs last month ... all thanks to cloud agents" (2026-08-19) is the end state of this architecture, not the starting point.

**For Manuel:** the "team" is subagents under one human. Nothing in pstack addresses multi-human process (code owners, review rotation, RFC sign-off); the Babysit/Shipping playbooks assume GitHub PRs, CI, review bots ("Bugbot") and stacks.

### 2. Brownfield handling (understand before changing)

This is the strongest axis for someone new to a codebase. "if you want to go fast, go deep first" (`README.md`). The guide: "Editing code you don't understand is how subtle regressions ship ... An agent that starts editing without a traced model tends to fix the symptom at the first plausible spot. /how first is cheaper than the second bug." (`docs/guide/03-understand.md`).

- **`/how`**: Explain mode spawns 2–4 read-only explorers for a complex subsystem, each with "a specific exploration angle" (`skills/how/references/explorer-prompt.md`), then an explainer that writes Overview / Key Concepts / How It Works / Where Things Live / Gotchas "at the level of a senior engineer onboarding onto a subsystem". Critique mode explains first, then spawns one critic per panel model against an architectural rubric (Abstraction Fit, Data Model, Boundary Discipline, Evolution Readiness, Complexity vs Value, Consistency) and sorts findings into Act on / Consider / Noted / Dismissed. Placement questions ("where should this live") are explicitly `/how` territory.
- **`/why`**: "Companion to the how skill. how answers what the code does and how it works. why answers what forces led to its shape." It anchors in `git blame` / `git log --follow -p` / `gh pr view`, then "enumerates available MCPs at run time", one investigator per evidence category (source control, issue tracker, docs, chat, observability, error tracking, analytics), and a synthesizer bound by `references/epistemics.md`: five confidence tiers (Direct / Supported / Inferred / Speculative / Unknown), "Prefer 'appears to' over 'because'", "Null results from searched categories are first-class evidence", and the "Sycophancy Trap" (a user's guessed reason "is a prompt for investigation, not a conclusion to validate").
- **`/teach`**: runs how + why and "weaves what they find into one clear explanation", built "diagram by diagram" ("to teach a flow from A to B to C, draw it three times"), no quizzes, "Keep it a conversation, not a lecture". Best single skill for a beginner.
- **`/recall`**: rebuilds "your recent working context from your own chat history, live state, and the shared record" into a Capsule / Threads (`[merged #N]`, `[open PR #N]`, ...) / Problems / Next move brief.
- **`/blast-radius`**: "Listing the callers is not the job. The agent can grep those in a second. The job is the breakage grep won't show you." Five-rung evidence ladder ("1. You said so. Worthless on its own ... 4. You ran it ... 5. You reproduced it in the running app").
- **Investigation playbook** (read-only, "No PR, no babysit, no architect unless the investigation precedes a code change") and **Session pickup** ("A pickup is inheritance ... Resist the urge to re-derive; read.").

Bug fix and Refactoring both begin with understanding: Bug fix step 2 "Seed them with how over the affected subsystem and the why skill for regression history"; Refactoring step 1 "Pin the behavior contract first ... Type check and lint are not a pin." (`skills/poteto-mode/playbooks/`).

### 3. Adding new code & handling changes/contributions

- **Design first, but code is the spec.** "Any code → name the data shape first" and "Code crossing a function boundary → the architect skill" (`skills/poteto-mode/SKILL.md`, lines 21–22). `/architect`: Ground (how/why) → Sketch (arena over "at least two structurally distinct candidates", screened against `references/design-red-flags.md`: shallow module, information leakage, temporal decomposition, pass-through method; each candidate writes "the caller's usage written first, then the type sketch") → Agree (opt-in checkpoint) → Implement → Scrap when "the same shape of workaround appearing repeatedly". The README on planning: "personally, i don't believe in planning. the best spec is code."
- **Feature playbook** (`playbooks/feature.md`): how → architect (a skip must be logged) → four-item "throughput checkpoint" (blocking first steps, independent workstreams, shared mutable state, smallest safe decomposition) → delegate to a subagent with "file paths, named data shape ... and success criteria; review its diff yourself" (delegation is "Mandatory: no skip-with-reason escape ... the gain is review separation") → verify on the matching surface → small ordered commits → interrogate if contested → Opening a PR.
- **Verification is the gate.** "'It compiles' is not evidence" (`docs/guide/06-verify-and-ship.md`): CLI changes run the real command, UI changes walk the flow in the running app, parsers replay a saved input, perf compares profiles, storage reads back the value. `/create-verification-skill` "interviews the repository, not you" and writes `.cursor/skills/verify-<app>/` (Launch / Doctor / Drive / Evidence / Cleanup + feature map); "A generated skill that was never executed is a draft, not a deliverable." `/maintain-verification-skill` ends in `clean`, `changed` (one PR), or `blocked` and "never edits product code". `/tdd` applies only with "an obvious cheap local test target"; "Prefer no new test over a bad test."
- **Adversarial review.** `/interrogate` sends the same intent + diff + rubric (Correctness, Root Causes vs Symptoms, Structural Integrity, Verification, Complexity Budget, Security) and a strict code-quality lens ("code judo" moves; "Do not let a PR push a file from under 1k lines to over 1k lines") to four reviewers on different model families: "The adversarial signal comes from model diversity, not assigned personas." The lead filters ("If your 'Act On' list has more than 5 items, you're probably not filtering hard enough") and "Do NOT auto-apply changes."
- **Decision logging.** `/show-me-your-work`: six-column TSV (ts, phase, decision, why, evidence, result), "Append-only", local by default, committed "only when the work is ambitious enough that a reviewer needs the trail to trust the result", audited against the transcript, then reviewed by "a subagent on a different model family" whose flags become an "Attention" section.
- **Cleanup before review.** Opening a PR: "Run /deslop from cursor-team-kit over the diff before commit. Run /no-comments before review. Write every PR title, PR description, and commit body with /technical-writing, then apply /unslop." Conventional Commits titles; `## Why` / `## Scope` / `## Tradeoffs` / `## Blast Radius` / `## Verification` sections; "Prefer five narrow PRs to one large PR."; PRs open "never as a draft".
- **Shipping safely.** Babysit works "the merge frontier and nothing above it", in the order "conflicts, then review threads, then CI", "Never mutate stack topology", "One retry only" for flake, and triages review bots "skeptically, always" per `references/bugbot-triage.md` (fix / dismiss / ask; "Ask by default" for security, auth, billing, data, migrations). Shipping: "Green is not safe ... Safe means a verdict from an agent that did not write the code", lands "only the contiguous verified run rooted at the bottom", re-checks `git patch-id` before each merge.

### 4. Tools / harness

- **Cursor-first, by design.** The manifest is `.cursor-plugin/plugin.json` (name `pstack`, version `0.14.8`, `"skills": "./skills/"`, `"agents": "./agents/"`); install is `/add-plugin pstack`; the README's third pillar is "cursor gives you the best of all worlds ... use any model with pstack." Cursor primitives assumed throughout: the `Task` tool with `subagent_type: generalPurpose`, `readonly`, `environment: "cloud"`; `AskQuestion`; `/loop`; `/goal`; sticky-mode frontmatter (`mode: true`, `reminder:`); `~/.cursor/rules/*.mdc`; `~/.cursor/projects/<slug>/agent-transcripts/`; built-in `/create-skill` and `/babysit`; cloud agents; Bugbot; Cursor Automations.
- **Not shipped here** (README): `/deslop`, `control-cli`, `control-ui` live in the sibling `cursor-team-kit` plugin (`https://github.com/cursor/plugins/blob/7314f72/cursor-team-kit/skills/`); `/create-skill` and `/babysit` are Cursor built-ins. Upstream pstack alone is incomplete even on Cursor.
- **Scripts** (`skills/poteto-mode/scripts/`, ~6.6k lines): `watch-pr/` (Bun/TypeScript PR watcher emitting `READY` / `WAITING` / `ADVANCE` / `COMPLETE` for Babysit/Shipping), `orch/` (Orchestrate store CLI), `check-plan.mjs` (validates the multi-phase plan skeleton), `worktree-audit.sh`, `bootstrap.ts` (self-installing `bun install`). Needs `bun`, `gh`, optionally `origin` (Origin forge CLI); `gt` only for Orchestrate. Upstream is now "forge-neutral": "GitHub CLI (gh) is the default ... Never require Graphite (gt)." (`playbooks/opening-a-pr.md`).
- **Agents dir**: `agents/poteto-agent.md` (routing target, `is_background: true`) and `agents/comment-sicko.md` ("A deranged comment-hater that savors deletion and condemns workaround code"; first output is literally "Yes... Ha ha ha... Yes!"; read-only; keeps only license headers, external-dependency gotchas, `// prettier-ignore`, public-API doc comments, issue/RFC links; marks the rest `MUST KILL`).
- **Automations**: `automations/benny/` is "a dormant benny automation pack ... benny triages slack issue reports, then reproduces and fixes confirmed bugs with real ui evidence. its files are not registered as slash skills." Setup via `FOR_AGENTS.md` copies the pack into `.cursor/automations/benny/`, needs Slack + a tracker adapter + a control adapter + a feature map, "fail[s] closed", and opens "draft pull requests only". Lauren calls Benny a work in progress (via leslieli.dev).
- **Assets**: `assets/logo.png` (512×512) and six illustrative JPEGs in `docs/guide/images/`.
- **Model assignment via `/setup-pstack`**: the only skill without `disable-model-invocation: true`. It "Enumerate[s] the model slugs you can pass to a Task subagent", writes `~/.cursor/rules/pstack-models.mdc` with `alwaysApply: true`, "Never write a real slug you have not confirmed is available", and offers `/create-verification-skill` once.
- **Auto-loading**: 44 of 45 skills carry `disable-model-invocation: true`, so the model will not self-trigger them by description; poteto-mode invokes them by name. `typescript-best-practices` additionally has `paths: ["**/*.ts", "**/*.tsx"]` and "loads whenever the agent touches a .ts or .tsx file" (`docs/guide/05-build-and-clean.md`).

**Community ports and how they differ** (all cloned at `research/ (the pinned upstream copies; see research/README.md)`):

| Port | What it is | Key differences from upstream |
|---|---|---|
| `michael-denyer/pstack-claude` (v0.9.18, 2026-09-02; synced to upstream 0.14.2) | Claude Code marketplace plugin; same tree also serves Codex, Prime Agent, opencode, Gemini CLI | "Editorial, not mechanical": `Task`→`Agent`, `generalPurpose`→`general-purpose`, `AskQuestion`→`AskUserQuestion`, `/loop`→Claude's `loop` skill, `/create-skill`→`plugin-dev:skill-development`, `control-cli`/`control-ui`→Claude's `run`/`verify` skills, cloud agents→local background subagents in worktrees, `/goal`→standing orders, `~/.cursor/rules/pstack-models.mdc`→`~/.claude/pstack-models.md` included from `CLAUDE.md`, `Comment Sicko`→`comment-sicko`. Adds a `SessionStart` hook that auto-routes non-trivial work into `pstack:poteto-mode`, a standalone `/babysit`, and seven `cursor-team-kit` imports (`deslop`, `thermo-nuclear-code-quality-review`, `make-pr-easy-to-review`, `fix-ci`, `fix-merge-conflicts`, `get-pr-comments`, `what-did-i-get-done`). Panels collapse to Claude-only (`claude-opus-5`, `claude-fable-5`, `claude-sonnet-5`): "Cross-vendor model diversity ... What's lost in translation." Not ported: Benny, `docs/guide/`, sticky mode, `make-bot-ui`. (`pstack-claude/README.md`, `CHANGES.md`, `plugins/pstack/models.json`) |
| `ericlitman/open-pstack` (v1.3.0, 2026-09-03; synced to upstream 0.14.7) | Fork of pstack-claude aiming "to stay as close to her original work as possible" | Restores the cross-vendor panel: "Provider dispatch restores the upstream frontier quad: claude:fable@max, codex:gpt-5.6-sol@max, grok:grok-4.6@xhigh, claude:opus@xhigh. Same-provider lanes stay native; external lanes use the bundled runner" (a Bun script that shells out to the Codex and Grok Build CLIs, which must be installed and signed in). Ships `pstack-fable-<effort>` / `pstack-opus-<effort>` native agents. Keeps `bug-fix`/`perf-issue`/`hillclimb` on Sol "because Fable costs much more per task." Keeps `README-UPSTREAM.md` verbatim. Not ported: Benny, guide, `make-bot-ui`, sticky mode. (`open-pstack/README.md`, `docs/reference.md`, `UPSTREAM.md`, `references/provider-dispatch.md`) |
| `IgorKhramtsov/pstack-skills` (2026-08-11; synced to upstream 0.13.0) | "host-neutral" skills tree for Claude Code and Oh My Pi, symlinked into `~/.claude/skills/` | Adds a `pstack-runtime` contract skill; validator "rejects leaked Cursor-only runtime constructs"; no plugin, hook, or cursor-team-kit imports; predates `bro`/babysit/shipping/orchestrate. (`pstack-skills/PORTING.md`) |
| `backnotprop/pstack` (2026-08-19) | Plain mirror of upstream | Unmodified Cursor references; for reading, not running in Claude Code. |

Also seen but not audited: `v1truv1us/ai-eng-system` and `Evan-Kim2028/agent-fleet` (described by pstack-claude as ports that "stop at namespacing"), `kkgogogo17/pi-pstack`, and the mcpmarket "Poteto Mode (pstack)" listing, which is a third-party repackage by `v1truv1us`, not Lauren's (https://mcpmarket.com/tools/skills/poteto-mode-pstack-1).

### 5. Preferences / opinions

- **Less code, higher quality.** "the goal is not to maximize loc, in fact it's the opposite" (README). Laziness Protocol: "Writing code is cheap for you, which makes over-engineering easy. Counter it by borrowing a human maintainer's fatigue."
- **Comments are a smell.** "Keep a comment only for a non-obvious *why* the code can't show" (`poteto-mode/SKILL.md`, Comments section); `/no-comments` hands the diff to Comment Sicko because "Authoring agents defend comments."
- **Unslop everything.** The `unslop` skill's description is literally "Cut AI tells from any writing. Must always apply." Its 31 patterns include the em dash ban ("Avoid em dashes entirely"), no mid-sentence colons, no "Not just X, but Y", no rule of three, no chatbot phrases, plus "Adding soul": "Have opinions ... Let some mess in." The reply rules in poteto-mode go further: "The long-dash character is banned outright" and "Write the reply clean as you draft it. The cleanup-afterward pass has been measured to fail".
- **Type-system discipline** (principle 12) grounded by `typescript-best-practices` (discriminated unions, branded types, `unknown` over `any`, "No `as` casts", exhaustiveness with `never`, `satisfies`, schemas before hand-written guards, "Real tests. Don't mock what you can run.", no `console.log` in shipped code).
- **Never block on the human** (principle 20) and, in the router, the rule to classify questions before asking: "The ask is the slow path. A throwaway probe usually answers faster".
- **Guard the context window** (principle 19): subagents carry bulk; the parent keeps summaries; "You own every subagent's work. Review the diff and write your own summary, don't pass through what it said."
- **Candor over agreement.** "No is an acceptable answer ... A recommendation is a judgment, not a validation. Agreement is not the default, candor over sycophancy." (`poteto-mode/SKILL.md`, line 85).
- **No planning ceremony.** "cursor already has a great plan mode which works great with pstack. but personally, i don't believe in planning. the best spec is code." (README).
- **Multi-model by conviction.** "every frontier model has its strengths and weaknesses ... many of my skills use multi-model workflows" (README); model diversity is the whole basis of `/interrogate`.
- **Prose standards.** `/technical-writing` layers Diátaxis, Google developer style, ASD-STE100, and Kohl's Global English; "The goal is writing a tired engineer understands on the first read."
- **Cost awareness (hers and others').** In a follow-up to "How I Use Cursor" she noted that "Multiple agents, especially frontier ones, burn expensive tokens" (paraphrased at leslieli.dev). Flavio Copes: "The machinery has a cost".

### 6. How the skills fit the workflow

Three layers (Kayvane's framing, https://www.kayvane.com/posts/building-a-multi-skill-system, 2026-05-28): a router skill on top, playbooks in the middle, principle leaf skills at the bottom. What makes it stick is mechanical: "Playbook steps get copied verbatim into the agent's working todolist before it reasons about the task", and `disable-model-invocation: true` on nearly everything so "Rules only apply through explicit routing."

- **Router**: `/poteto-mode` (sticky; `reminder: New task? Playbook match or rigor needed -> apply /poteto-mode. Casual turn or user opts out -> don't.`). Say "new task" to force a re-match; "don't change any code yet" pins Investigation (`docs/guide/02-poteto-mode.md`).
- **Playbooks** (22 + Opening a PR): task-shaped recipes; the router "matches your task to a playbook and copies the steps in verbatim" and "routes to the other skills as the steps fire" (README).
- **Understanding skills**: `how`, `why`, `teach`, `recall`, `blast-radius` — fire in Investigation, Bug fix step 2, Feature step 1, Refactoring step 1, Architect Phase A, Session pickup.
- **Design/parallelism skills**: `architect` (fires on any boundary-crossing code), `arena` (inside architect, or when "the implementation admits multiple valid shapes"), `swarm` (verification lanes in Autopilots, coverage matrices, Shipping's per-PR verifiers).
- **Verification skills**: `create-verification-skill` / `maintain-verification-skill` (project-local `verify-<app>`), `tdd` (Bug fix step 5 when cheap), `blast-radius` (small scary diffs), `show-me-your-work` (any unattended/multi-phase run), `interrogate` (contested designs, before shipping).
- **Prose skills**: `unslop` (every reply, every PR body, every log row), `technical-writing` (docs, PR descriptions, commit messages), `bro` (restate the last reply plainly), `no-comments` (before review).
- **Meta skills**: `reflect` (three reviewers + synthesizer → Accepted/Rejected/Backlog, applied only after user approval), `automate-me` (mines transcripts to draft `<you>-mode`), `figure-it-out` (designs a bespoke playbook), `setup-pstack` (models), `make-bot-ui` (Grok Bot webhook dashboards; unrelated to the core loop).
- **Principles** (21): read as an index at task start; cited in replies by name; steerable by name mid-task.

---

## Skill catalog

Format: **name** | kind | trigger | what it does | chains to | verbatim | notes. All paths under `skills/<name>/SKILL.md`.

**poteto-mode** | router / sticky mode | `/poteto-mode`, "poteto", any non-trivial task; auto-reapplies across turns | Reads principles, matches a playbook, copies steps verbatim into a todo list, delegates by model role, writes an unslopped reply | every other skill | "Start every multi-step task with a todolist whose first item is to read the Principles section below in full." / "A step you choose not to do stays in the list with a one-line `skip: <reason>`; skipping silently is not allowed." | Frontmatter `mode: true`, `icon: crown`, `color: yellow`. Bundles `playbooks/`, `references/bugbot-triage.md`, and `scripts/`.

**how** | action (understanding) | "how does X work", walkthroughs, placement/ownership questions | Explain mode (2–4 explorers + explainer) or Critique mode (explain, then one critic per panel model) | why, interrogate-style lead judgment | "Enough to build a working mental model, not annotated source code." / "If the architecture is sound, say so. An empty critique is a valid outcome." (critic prompt) | Explorer default grok, explainer fable, critics = the four-model panel.

**why** | action (understanding) | "why does X work this way", regressions, postmortems, thresholds | Code anchor via git/gh, one investigator per available MCP category, synthesizer with confidence tiers | how (companion), recall, blast-radius | "Prefer 'appears to' over 'because'." / "Confident storytelling ... A bullet with no citation goes in 'inferred' or 'hypotheses,' not 'what we found.'" | Investigators run in agent mode because "readonly ... strips MCP access". Seven source playbooks in `references/sources/`.

**teach** | action (understanding) | "teach me this", "help me really understand X" | Runs how + why, blends into one plain explanation built diagram by diagram | how, why, unslop | "Listing functions and constants is reference, not teaching." / "Three small growing diagrams beat one crowded diagram." | Uses an image-generation tool for spatial ideas (Cursor-side capability).

**recall** | action (context) | "catch me up", "where did I leave off" | Mines your own transcripts in parallel subagents plus the shared record via why's investigators; returns Capsule/Threads/Problems/Next move | why, session-pickup playbook, automate-me | "A transcript or a stale ticket is history, not current truth" | Transcript path is Cursor-specific.

**blast-radius** | verification | "what could this break", small diffs you don't trust | Finds the one safety fact and proves it by running code | why (step 2), arena for wide changes, unslop | "A blast-radius writeup that sounds right is worthless." / "Any safety fact you can't get to step 4, say so out loud." | Five-rung evidence ladder.

**architect** | action (design) | `/architect`, boundary-crossing code | Ground → Sketch (arena) → Agree (opt-in) → Implement → Scrap | how, why, arena, interrogate | "Design it twice. Require at least two structurally distinct candidates before synthesis" / "Default: proceed directly to implementation with the synthesized design. No human checkpoint." | References: design-red-flags, rationale-template, runner-prompt.

**arena** | action (parallelism) | `/arena`, bakeoffs | N candidates → cross-judge → pick base → graft → verify | architect, eval playbook, blast-radius | "When N candidates converge on the same shape, that is a strong agreement signal ... When N candidates wildly diverge, Phase A was under-specified." | Candidates each get a worktree; "The arena does not earn you a pass."

**swarm** | action (parallelism) | `/swarm`, coverage, races, gauntlets | Frame → fan out cloud workers → aggregate → one report (`PASS`/`ISSUES`/`BLOCKED`) | autopilots, shipping, maintain-verification-skill | "Do not paste raw worker dumps." | Upstream spawns `environment: "cloud"`; ports use local background agents.

**interrogate** | verification (review) | "adversarial review", "tear this apart", contested designs | One reviewer per panel model, same rubric + code-quality lens; lead sorts Act on / Consider / Noted / Dismissed | how (critique shares the framework), opening-a-pr | "The adversarial signal comes from model diversity, not assigned personas." / "Do NOT auto-apply changes." | Rubric includes idempotency and "Instructions where structure would be better".

**setup-pstack** | config | `/setup-pstack` | Detects models, writes `~/.cursor/rules/pstack-models.mdc`, offers a verification skill | create-verification-skill | "A rule pointing at a model the user cannot use breaks every delegation that reads it." | Only skill without `disable-model-invocation`.

**tdd** | verification | explicit TDD request, or a cheap local test path | Failing test first, then fix, then rerun | bug-fix playbook | "Prefer no new test over a bad test." | Reports "the failing-before test ... and the failure it produced".

**bro** | prose | `/bro` | Restates the last message plainly | none | "Stop using jargon and speak coherently." | One paragraph long; handy for a beginner.

**unslop** | prose | any prose surface; "Must always apply" | Removes 31 AI-tell patterns and "adds soul" | everything that writes text | "Em dashes are an AI tell, and reaching for parentheses instead just trades one tell for another." | Theo's favorite (see below).

**no-comments** | verification (cleanup) | before review | Spawns Comment Sicko, fixes accepted flags at the root cause, offers to encode claimed constraints as types/tests/lints | comment-sicko agent, architect, how, why | "Authoring agents defend comments. Defer to Comment Sicko's fresh perspective." | Two rejected reports = the skill fails loudly.

**figure-it-out** | router (bespoke) | no playbook fits; large migrations; "trust it when i'm back" | Frame (falsifiable done predicate) → design phases → hypothesis loop → audit trail → verify | architect, arena, show-me-your-work | "Bias toward more rigor. The cost of building the wrong thing dwarfs the cost of being careful." | Verdicts are VERIFIED / NOT VERIFIED / INCONCLUSIVE.

**show-me-your-work** | verification (audit) | unattended or multi-phase work | Append-only TSV decision log + transcript audit + cross-model reviewer | figure-it-out, autonomous-run, hillclimb, orchestrate | "Fix the log, not the story." / "Self-review is not a substitute" | Helper `scripts/log.sh` escapes spreadsheet formula characters.

**automate-me** | meta | "automate me", "update my -mode skill" | Mines recent transcripts, asks structured questions, drafts `<handle>-mode` via `create-skill`, unslops, opens a PR | create-skill (Cursor), unslop, poteto-mode | "Don't overfit to one conversation." | Output routes through pstack underneath.

**make-bot-ui** | action (integration) | a page whose buttons wake a Grok Bot over a webhook | Creates a webhook routine, hosts a local server on `0.0.0.0`, optionally exposes it on Tailscale | none | "Do not put the sender key in the browser, in chat, or in this skill." | Cursor/Grok-Bot specific; ports skip it.

**reflect** | meta | "/reflect" after a hard task | Judgment/Tooling/Divergent reviewers → synthesizer → Accepted/Rejected/Backlog → user approval → skill edits | create-skill, encode-lessons-in-structure | "Skill changes affect every future agent in the org; do not auto-apply." | Reviewer prompts treat transcripts as untrusted (prompt-injection aware).

**technical-writing** | prose | docs, RFCs, readmes, PR descriptions, commit messages | Diátaxis mode → Google style → STE → Global English, with a review checklist | unslop | "Cut every word that does no work." / "Use periods, not semicolons. Replace an em dash with a new sentence." | Sources fetched 2026-07-18 per the file.

**typescript-best-practices** | principle grounding (auto by path) | any `.ts`/`.tsx` file | 16-row rule table grounding type-system-discipline | principle-type-system-discipline, boundary-discipline | "Every `as` is a runtime crash waiting. Cast only after validation." | `references/patterns.md` has examples.

**create-verification-skill** | verification (generator) | no scripted way to prove app behavior | Interviews the repo, writes `.cursor/skills/verify-<app>/` + feature map, proves it once | maintain-verification-skill, swarm | "Interview the repo, not the user" / "A generated skill that was never executed is a draft, not a deliverable." | Worked example in `references/feature-map-example/`.

**maintain-verification-skill** | verification (upkeep) | feature map drift | Index hygiene → source wave → reconcile → live pass → triage → ship one PR or stop | create-verification-skill | "Never edit product code during a run" | Outcomes: clean / changed / blocked.

**principle-*** (21) | principle leaves | cited by poteto-mode index; steerable by name | one rule each | see Philosophy section | (verbatim one-liners above) | All `disable-model-invocation: true`; the ports mark them `user-invocable: false`.

**Subagents** (`agents/`): **poteto-agent** ("Reads the poteto-mode skill's SKILL.md in full before any work"), **Comment Sicko** (read-only comment reviewer; "I do not touch the code.").

---

## Playbooks list (name + when it's chosen)

From `skills/poteto-mode/SKILL.md` (lines 112–140) and the files in `skills/poteto-mode/playbooks/`:

1. **Investigation** — read-only: "how does X work, why was Y built this way, are we sure about Z, should we do X or Y." No PR.
2. **Bug fix** — "A reported defect to reproduce, root-cause, and fix with runtime evidence." Reproduce yourself first; binary-search the cause; failing repro lands before the fix in history.
3. **Perf issue** — "A measured slowness to trace and improve against a baseline." Eight strategy families (elimination, divide and conquer, caching, indirection, batching, redundancy, lazy evaluation, scheduling) as hypothesis generators.
4. **Hillclimb** — "Sustained, scientific improvement of one metric against a target ... one commit per accepted win." Frozen harness, decision.tsv, "a plateau means pivot, not stop".
5. **Runtime forensics** — "Diagnose a runtime symptom (leak, idle-CPU spin, glitch) from live instrumentation. The deliverable is a diagnosis, not a fix."
6. **Trace forensics** — a dropped `.cpuprofile`, trace, spindump or heap snapshot; "the artifact is a fixed dataset, read it, don't re-run it."
7. **Feature** — "New or changed behavior, built from a named data shape."
8. **Refactoring** — "A behavior-preserving change to structure or shape (rename, extract, inline, dedupe, move)." Pin behavior first; "If the diff does not lower reader load somewhere, revert it."
9. **Prototype** — throwaway sketch to settle a design or "an empirical fork by observing it instead of asking the human"; "The one playbook where the Laziness Protocol's 'smallest change' and the verification bar invert."
10. **Visual parity** — "Pixel-exact UI equivalence"; image diff, baseline is the spec, "/loop per component until the diff is zero."
11. **Authoring or modifying a skill** — writing/editing a SKILL.md via Cursor's `create-skill`; "prose earns its keep by changing a decision."
12. **Eval** — blinded test of a skill/prompt change; "No `eval`, `test`, `judge` ... in any directory, file, or prompt the candidate sees."
13. **Babysit** — "Driving a PR or a stack to merge-ready: conflicts, review threads, CI." Modes `drive` / `background` / `threads-only` / `check`. Never merges.
14. **Shipping** — "Independently verifying a green stack, then landing the contiguous verified run bottom-up".
15. **Autonomous run** — "run until done", "/loop until X"; predicate first.
16. **Orchestrate** — "A standing project handed to one coordinator chat: multi-day, many stacked PRs, dozens to hundreds of subagents". Explicitly not for anything one agent could finish in a session.
17. **Autopilot-full** — "A queue of independent PRs run to merged with full autonomy: one owner per PR ... the root swarm-verifies each merge-ready head before its owner merges".
18. **Autopilot-stack** — same owner loop, "delivered as one linear reviewed base-branch stack the operator lands herself".
19. **Session pickup** — resuming a prior agent's work from a transcript, cloud-agent URL, or pushed branch.
20. **Pause safely** — explicit pause / going offline / imminent context compaction; `wip:` commit plus a resume note.
21. **Multi-phase or multi-PR plan** — "The plan is the deliverable. Do not implement." Validated by `check-plan.mjs`; mandates ten live verification lanes per PR.
22. **Worktree and simulator cleanup** — "what's using my disk"; audit script, human gate on uncommitted work.
23. **Opening a PR** — "Invoked at the end of every other playbook."

Routing rules that sit above the list: large/cross-cutting work or "work the user steps away from to trust later" → `figure-it-out` "even when a narrower playbook like Feature fits"; standing programs → Orchestrate; any PR-status phrasing ("check on PR X") → Babysit, never Cursor's built-in; "land"/"ship" → Shipping.

---

## Running it in Claude Code

**Upstream support: none, by design.** Upstream is a Cursor plugin; its own guide says "In a Cursor chat, run: /add-plugin pstack" (`docs/guide/01-setup.md`) and the README never mentions Claude Code. The concepts port (SKILL.md is a shared format), but the skill bodies reference Cursor's `Task` tool, `generalPurpose`, `readonly`, `environment: "cloud"`, `AskQuestion`, `/loop`, `/goal`, `/deslop`, `control-ui`/`control-cli`, `create-skill`, `~/.cursor/...`, Bugbot, and Cursor cloud agents. Copying the raw tree into `~/.claude/skills/` would leave dozens of dangling references (Flavio Copes: with the Claude Code port "You lose the Cursor-only pieces" such as per-task model assignment and `/loop`).

**Recommended path for Manuel (Claude Code): open-pstack** (closest to upstream, most recently synced, keeps the multi-model idea). Steps from `open-pstack/README.md` and `docs/reference.md`:

1. Inside Claude Code: `/plugin marketplace add ericlitman/open-pstack`, then `/plugin install pstack@open-pstack`, then `/reload-plugins`.
2. Install system tools the playbooks call: `gh` (GitHub CLI, `gh auth login`), `bun` (for `watch-pr`, `orch`, the external runner), `node` (for `check-plan.mjs`); optionally `jq` and `rg` for the worktree audit. `gt` only if you use Orchestrate.
3. Optional companion: `/plugin marketplace add anthropics/claude-plugins-official` and `/plugin install plugin-dev@claude-plugins-official` (only the skill-authoring routes need it).
4. Run `/pstack:setup-pstack`. It writes `~/.claude/pstack-models.md` and adds `@~/.claude/pstack-models.md` to `~/.claude/CLAUDE.md`. The first-run panel is "Fable max, GPT-5.6 Sol max, Grok 4.6 xhigh, and Opus xhigh". Sol and Grok lanes run through their own signed-in CLIs (Codex CLI, Grok Build CLI) via the bundled `pstack-runner`; "Open Pstack does not quietly replace a failed model with a weaker one." If you only have Claude, set the non-Claude roles to `inherit-parent`/`auto` or to Claude models; multi-model review then degrades to Claude-only diversity.
5. Start a new session. The `SessionStart` hook injects a ~0.3k-token mandate ("Before responding to any non-trivial engineering task ... invoke the pstack:poteto-mode skill"), so you can just talk; or type `/pstack:poteto-mode <goal>`, `/pstack:how ...`, `/pstack:teach ...`, `/pstack:unslop`. Opt out of auto-fire by deleting `hooks/hooks.json` from the installed copy under `~/.claude/plugins/cache/open-pstack/pstack/<version>/`.

**Alternative: pstack-claude** (`/plugin marketplace add michael-denyer/pstack-claude`, `/plugin install pstack@pstack-claude`). Simpler and Claude-only: panels are `claude-opus-5` / `claude-fable-5` / `claude-sonnet-5`, the "harsher pass" is the bundled `thermo-nuclear-code-quality-review` skill instead of another vendor. Also installable without a plugin via `npx skills add https://github.com/michael-denyer/pstack-claude/tree/main/plugins/pstack/skills --skill "*" --agent "*" --yes`, or symlinked into `~/.agents/skills/` (which Codex, opencode, Gemini CLI, Prime Agent also read). Synced only to upstream 0.14.2 (missing the 0.14.7 forge-neutral and Fable 5.1 changes).

**Lightest option: IgorKhramtsov/pstack-skills**: symlink each `skills/*` dir into `~/.claude/skills/` and invoke `/poteto-mode`; adds a `pstack-runtime` contract skill; older (0.13.0), no hook, no cursor-team-kit imports.

**What changes or breaks in Claude Code, whichever port you pick** (from `pstack-claude/README.md` "What's substituted", `open-pstack/docs/reference.md`, `pstack-skills/PORTING.md`):

- No sticky mode; the SessionStart hook is the analog (or invoke the skill each task).
- No Cursor cloud agents: `/swarm`, the autopilots, and Shipping's per-PR verifiers run as local background subagents isolated by worktree; your machine does all the work.
- No `/loop` or `/goal`: Claude's built-in `loop` skill replaces `/loop`; `/goal` becomes standing orders in the todo list. Long unattended runs are less robust than on Cursor.
- No `control-ui` / `control-cli`: replaced by Claude Code's `verify` / `run` skills. `/create-verification-skill` still works and matters more here.
- No `/deslop` upstream; both plugin ports import it from cursor-team-kit.
- `Comment Sicko`→`comment-sicko`; `AskQuestion`→`AskUserQuestion`; transcripts live at `~/.claude/projects/<encoded-cwd>/*.jsonl` (affects `recall`, `reflect`, `automate-me`, the `show-me-your-work` audit).
- Model diversity: real cross-vendor panels only with open-pstack plus extra CLIs and subscriptions; otherwise `interrogate`/`arena`/`architect` are one vendor at several tiers.
- Not available outside Cursor: Benny, `make-bot-ui`, the `docs/guide/` tutorial (read it upstream), Bugbot integration (the triage rubric still applies to whatever review bots you have).
- Cost: every panel is four frontier calls; `arena` adds a judge and grafting (Theo's word: "token burners").

---

## What Theo said about it

**Primary source located.** YouTube video "So I tried Matt's skills..." by "Theo - t3․gg" (https://www.youtube.com/@t3dotgg), video ID `0oXOOlqVu5M`, https://www.youtube.com/watch?v=0oXOOlqVu5M, published 2026-08-19, about 38 minutes (title/channel confirmed via YouTube oEmbed through noembed.com; date and length from the daily.dev mirror https://daily.dev/posts/so-i-tried-matt-s-skills--0f5yy5jlx). The video compares Matt Pocock's skills repo with pstack; per a daily.dev commenter, Lauren's skills occupy "All the rest of the video" after the Pocock section. I could not play the video from this environment; the verbatim lines below come from an auto-transcript served by youtubetotranscript.com (https://youtubetotranscript.com/transcript?v=0oXOOlqVu5M) and should be treated as near-verbatim (auto-captions).

What he said (transcript-derived):

- Introduction: "PA stack created by Lauren, otherwise known as Potato, one of my old favorite React core team members, who is now at Cursor" ("PA stack" is the caption's rendering of "pstack").
- On unslop: "This skill has fundamentally changed my willingness to read the things that my agents say to me." and "I think everyone should have unslop at this point."
- On blast-radius: "This one is great and has cpped [sic; likely 'capped' or 'caught'] a couple things that would have been miserable if I didn't have it. It also calls out that you can't trust your own writeup."
- On arena: "This has been a very fun skill for those of us who are uh token burners because we have a bunch of usage to get through."
- On technical-writing/"writing for agents": "I've mostly been using this for prompting sub aents and it's been very helpful there." On teach: "Teach is one I've heard really good things about."
- On how he tried them (no plugin install): "you copy the text, go to your agent...and then you paste it." and "I did all of this in a thread in T3 code in a repo that I already made called fleet where I manage all of my like skill files and things."
- His main criticism: the skills are "tied to cursor specifically, which is the biggest issue", and he would "be pumped if somebody like cloned all the Pstack skills in a generic not cursor specific way." (The ports in the Tools section are exactly that; pstack-claude predates the video, open-pstack's current release is from 2026-09-03.)
- Verdict: "I find Pstack writing to be a lot more readable and also the behaviors from these skills to be a lot more applicable for my day-to-day...I am much more philosophically aligned with what Potato is cooking." The daily.dev summary's phrasing: pstack's skills are "more philosophically aligned and readable, though some tie specifically to the Cursor platform."
- Contrast with Pocock's set: "He also has disable model invocation on for a lot of his skills, which means the model won't enable it itself." (pstack does the same, though he does not say so in the quoted passage.)

Other summaries agree: youtubesummary.com calls pstack "fun but surprisingly powerful" and says the skills highlighted were Teach, Arena, Blast radius, Show your work, unslop, and that the recommended approach is "auditing actual usage patterns and selectively testing skills through copy-paste evaluation before full adoption."

**Adoption evidence.** Unslop is the skill he says he uses. Circumstantial: T3 Code's own test fixtures use `unslop` as the example skill name (`https://github.com/pingdotgg/t3code/blob/f559fe0b/apps/web/src/components/chat/composerSlashCommandSearch.test.ts`, lines 161–220, and `apps/web/src/providerSkillSearch.test.ts`, line 75), which suggests it was installed on a maintainer's machine when those tests were written (unverified which maintainer). T3 Code's `AGENTS.md` does not import pstack or its principles; it has its own "note from Theo" ("fight for the smallest model that makes the correct behavior unsurprising") and a babysitting rule that reads like a compressed Babysit playbook ("verify each bot finding against the source, fix real ones, dismiss false positives with a written reason"), but there is no citation, so treat any influence as unproven.

**Context that matters for Manuel.** Theo's praise is selective and sits inside a longer skepticism about skill packs. In "How I code with AI changed a lot" (~May 2026, https://finance.biggo.com/podcast/c7c3cb2193d150d2): "You don't need all of that bullshit. I have almost zero skills installed. Just talk to the fucking model. They're smart enough now." In "My AGENTS.md & SKILLS.md Breakdown (Don't copy them)" (2026-08-11, https://finance.biggo.com/news/63e17fcb23548c16): "Less context is best as long as it has the context it needs." So his pstack take is: take the good individual skills (unslop, blast-radius, teach, arena when you have tokens to burn), be wary of the Cursor coupling, and copy-paste rather than install wholesale. I found no evidence he adopted `/poteto-mode` as a router, the 21 principles as a system, or the overnight playbooks. His post "It does have one problem though: It is slop ..." (2026-08-14, https://x.com/theo/status/2088127851929423990) surfaced in searches but could not be read; unverified whether it concerns pstack.

---

## What's opinionated / friction for a beginner (honest)

- **It is one senior engineer's private style, published.** poteto-mode's own frontmatter says "poteto's agent style"; the README says "`poteto-mode` is my style. you may not want exactly that." Leslie Li's read: "pstack itself looks like Lauren's private style dumped into a plugin". Everything from em-dash bans to "never open a draft PR" is her taste.
- **Assumes Cursor and, increasingly, the SpaceXAI/Grok stack.** Defaults name Grok and Fable/Sol/Opus slugs; `make-bot-ui` is Grok-Bot-only; Benny needs Cursor Automations. In Claude Code you depend on a volunteer port that lags upstream by days to weeks and rewrites skill bodies.
- **Token and subscription cost.** Panels are four frontier models; `arena` adds a judge and grafting; Autopilots add swarms of verifiers per PR. Lauren herself flagged that frontier fan-out "burn[s] expensive tokens" (via leslieli.dev); Copes: "The machinery has a cost"; Theo: "token burners". A beginner on one Claude plan should set most roles to `inherit-parent` and use the single-agent skills.
- **Vocabulary load.** 45 skills, 22 playbooks, 21 named principles, plus terms like "throughput checkpoint", "merge frontier", "patch-id", "forge", "gauntlet lanes", "stack". The guide says "Don't memorize the list", but the router expects you to phrase goals with checkable finish conditions, which is itself a skill.
- **"Never block on the human" cuts both ways.** By default it proceeds on anything reversible, uses any MCP tool, posts to team chat and tickets without asking, and prototypes instead of asking design questions. For someone who cannot yet judge a diff, review-after-the-fact is riskier than it is for her. Pair it with a small scope, worktrees, and no merge rights at first. open-pstack's README says as much: "Start with supervised work. Let it run more work in parallel only after its checks have earned that trust in your own repositories."
- **Anti-comment and anti-planning stances.** `/no-comments` deletes explanatory comments a learner might want, and "i don't believe in planning. the best spec is code" removes a step many beginners lean on. You can simply not run those skills.
- **Git-heavy assumptions.** Worktrees per agent, stacked PRs, Conventional Commits, `gh`, rebases, `git patch-id`, merge queues. Manageable for a solo repo, but the shipping half assumes GitHub PR flow with CI and review bots.
- **Verification needs plumbing you must build.** "Prove it works" only bites if the agent can drive your app; that means running `/create-verification-skill` early and keeping the feature map honest.
- **Volatility.** Model defaults changed six times in three months; playbook count went 7 → 22; the router file is 141 dense lines. Expect churn.
- **What is genuinely beginner-friendly:** `/teach`, `/how`, `/why`, `/bro`, `/unslop`, `/blast-radius`, and `/tdd`, each usable standalone, plus the ten-chapter `docs/guide/` (read upstream; not ported). Leslie Li's advice fits: take "the sequence, not the slash-command catalog": understand, require a real artifact of the problem, verify on the real thing, only then parallelize.

---

## Sources

Local (primary):
- `research/3-pstack/upstream-cursor-plugin/README.md`, `LICENSE`, `.cursor-plugin/plugin.json`
- `research/3-pstack/upstream-cursor-plugin/docs/guide/README.md`, `01-setup.md` … `10-recipes-and-pitfalls.md`
- `research/3-pstack/upstream-cursor-plugin/skills/poteto-mode/SKILL.md`, `playbooks/*.md` (23 files), `references/bugbot-triage.md`, `scripts/` (`watch-pr/`, `orch/`, `check-plan.mjs`, `worktree-audit.sh`, `bootstrap.ts`)
- `research/3-pstack/upstream-cursor-plugin/skills/{how,why,teach,recall,blast-radius,architect,arena,swarm,interrogate,setup-pstack,tdd,bro,unslop,no-comments,figure-it-out,show-me-your-work,automate-me,make-bot-ui,reflect,technical-writing,typescript-best-practices,create-verification-skill,maintain-verification-skill}/SKILL.md` and their `references/`
- `https://github.com/cursor/plugins/blob/7314f72/pstack/skills/principle-*/SKILL.md` (21 files)
- `research/3-pstack/upstream-cursor-plugin/agents/poteto-agent.md`, `agents/comment-sicko.md`
- `research/3-pstack/upstream-cursor-plugin/automations/benny/{README.md,FOR_AGENTS.md,skills/*/SKILL.md,templates/*}`
- `research/3-pstack/upstream-cursor-plugin/assets/logo.png`, `docs/guide/images/*.jpg`
- `git log` of `https://github.com/cursor/plugins/blob/7314f72/` (unshallowed; commits `24bd6eb` 2026-05-22 through `7314f72` 2026-09-02)
- `https://github.com/cursor/plugins/blob/7314f72/cursor-team-kit/skills/` (deslop, control-cli, control-ui)
- `https://github.com/michael-denyer/pstack-claude/blob/273d217/{README.md,CHANGES.md,CONTEXT.md,plugins/pstack/models.json,plugins/pstack/hooks/*}`
- `research/3-pstack/open-pstack-claude-code-port/{README.md,UPSTREAM.md,docs/reference.md,plugins/pstack/skills/poteto-mode/references/provider-dispatch.md,plugins/pstack/skills/setup-pstack/SKILL.md}`
- `https://github.com/IgorKhramtsov/pstack-skills/blob/ce47cec/{README.md,PORTING.md,UPSTREAM}`
- `https://github.com/backnotprop/pstack/blob/18e0e90/README.md` (backnotprop mirror)
- `research/2-theo-t3code-excerpts/AGENTS.md`, `apps/web/src/components/chat/composerSlashCommandSearch.test.ts`, `apps/web/src/providerSkillSearch.test.ts`

Web (secondary; X pages were not fetchable and are cited through the write-ups that quote them):
- Lauren Tan, "How I Use Cursor", X article, 2026-05-25: https://x.com/poteto/article/2058975157503570132 (quoted via https://leslieli.dev/notes/go-deep-first-pstack/)
- Lauren Tan, "new pstack principle" post, 2026-05-28: https://x.com/poteto/status/2059870196559700428 (content unverified; likely build-the-lever, added 2026-05-26)
- Lauren Tan, "1000 PRs" post, 2026-08-19: https://x.com/poteto/status/2090141955695198633 (quoted at https://www.bestxbuilds.com/builds/pstack)
- Lauren Tan, "The Complete Guide to pstack Pt. 1", 2026-08-31: https://x.com/poteto/article/2094457600259842065 (not fetchable)
- Maven workshop, 2026-08-12: https://maven.com/p/e23d9c/how-cursor-turned-ai-agents-into-better-engineers ; recap https://www.skool.com/start-my-ai/lauren-tan-on-pstack?p=b4e13358
- Denis Labelle interview reference (via open-pstack README): https://x.com/DenisLabelle/status/2091337807939706928 (2026-08-23; not fetchable)
- react.dev team page: https://react.dev/community/team ; GitHub profile: https://github.com/poteto ; older handle evidence: https://www.npmjs.com/~sugarpirate , https://keybase.io/sugarpirate
- SpaceXAI–Cursor acquisition: https://9to5mac.com/2026/08/14/spacex-lands-deal-to-likely-purchase-claude-code-and-openai-codex-competitor/ ; https://coursiv.io/blog/grok-bot (2026-08-26)
- Flavio Copes, "A deep dive into pstack", 2026-08-21: https://flaviocopes.com/pstack/ (mirror https://daily.dev/posts/a-deep-dive-into-pstack-evqbnto9j)
- Leslie Li, "Go Deep First: Notes on Lauren Tan's pstack", 2026-08-27: https://leslieli.dev/notes/go-deep-first-pstack/
- Kayvane, "Skill orchestrations, and what I like about pstack", 2026-05-28: https://www.kayvane.com/posts/building-a-multi-skill-system
- DeepWiki pstack page: https://deepwiki.com/cursor/plugins/3.4-pstack-plugin ; Cursor marketplace: https://cursor.com/marketplace/skills/poteto-mode ; guided tour: https://hustlecoding.github.io/pstack-explained/
- mcpmarket third-party listing: https://mcpmarket.com/tools/skills/poteto-mode-pstack-1 ; EpiLogos issue on adopting pstack: https://github.com/EpiLogos/ai-kit/issues/110
- Ports: https://github.com/michael-denyer/pstack-claude , https://github.com/ericlitman/open-pstack , https://github.com/IgorKhramtsov/pstack-skills , https://github.com/backnotprop/pstack
- Theo, "So I tried Matt's skills...", 2026-08-19: https://www.youtube.com/watch?v=0oXOOlqVu5M ; mirror/description https://daily.dev/posts/so-i-tried-matt-s-skills--0f5yy5jlx ; transcript https://youtubetotranscript.com/transcript?v=0oXOOlqVu5M ; summary https://youtubesummary.com/summary/0oXOOlqVu5M ; Chinese-language recap post https://x.com/chenchengpro/status/2090042073583927318 (not fetchable)
- Theo, "How I code with AI changed a lot" (~May 2026): https://finance.biggo.com/podcast/c7c3cb2193d150d2
- Theo, "My AGENTS.md & SKILLS.md Breakdown (Don't copy them)", 2026-08-11: https://finance.biggo.com/news/63e17fcb23548c16
- Theo, "Coding Is Solved, Software Engineering Is Not", 2026-08-24: https://finance.biggo.com/news/3c4173f0fe65eff9 (no pstack mention)
- Theo post, 2026-08-14 (subject unverified): https://x.com/theo/status/2088127851929423990
