<!-- lines: 179 | source: pages/four-skill-systems.md | part 5/9 | title: Four Skill Systems (reference page) — pstack (Lauren Tan, @poteto) -->

## Contents (line numbers are for the Read tool's offset)
- L14: pstack (Lauren Tan, @poteto)
- L18: Why it exists, in her words
- L28: Router → playbook → skills
- L64: The 21 principles
- L92: The action skills
- L127: The six axes, briefly
- L141: Running it in Claude Code
- L158: What Theo said about it (2026-08-19) secondary
- L169: Friction for a beginner

## pstack (Lauren Tan, @poteto)

"i'm poteto. i'm not a president or ceo, but i've worked with millions of lines of code at Meta, Netflix, and Cursor. i'm also on the react core team where i help build and maintain react compiler." She joined Cursor at the end of March 2026 to work on its Agent Window; Cursor was acquired by SpaceXAI in August, which is why the plugin now defaults to Grok models for fast mechanical work. pstack is her personal workflow, published as a Cursor plugin on 2026-05-22; on 2026-08-19 she reported "I shipped 1000 PRs last month... all thanks to cloud agents."

### Why it exists, in her words

> "there's a growing sense that ai writes too much slop code. i agree. i don't want to ship like a team of twenty slop artists. throughput without quality is not a goal i aspire to. if you want to go fast, go deep first."
>
> "pstack is my answer. these are the same skills i use everyday to ship high quality code at Cursor. this turns cursor into a real engineering team. the goal is not to maximize loc, in fact it's the opposite. pstack helps you write less, but higher quality code."
>
> README.md primary

Her model of the agent, from her X article "How I Use Cursor" (2026-05-25, quoted via a close reading) secondary: "Agents are like new hires in a constant state of amnesia and idiocy. They don't remember what you tell them, and they never really learn anything new," and "Naive parallelization just makes them write slop faster." Rules, skills, tools and memory substitute for the team memory a new hire lacks. On planning: "cursor already has a great plan mode which works great with pstack. but personally, i don't believe in planning. the best spec is code."

### Router → playbook → skills

Three layers. A sticky router skill (/poteto-mode) starts every multi-step task with a todo list whose first item is to read the 21-principle index, matches the task to one of 23 playbooks, copies that playbook's steps verbatim into the todo list (a skipped step stays listed as `skip: <reason>`), and delegates to subagents by model role. Action skills do the work; principle skills are leaves the router cites by name. 44 of the 45 skills carry `disable-model-invocation: true`, so "Rules only apply through explicit routing." primary

**Goal + finish condition**"/poteto-mode <goal + how you'll know it's done>"

→

**Understand**/how /whyread-only explorers on a cheap model; history from git and MCPs

→

**Design**/architect → /arenaname the data shape; two structurally different candidates; cross-judge on another model

→

**Build**delegate to `poteto-agent` with an explicit model; "review its diff yourself"

→

**Verify**/blast-radius /swarmprove it works on the real surface; a generated `verify-<app>` skill

→

**Review & clean**/interrogate /no-comments /unslopfour reviewers on different model families; Comment Sicko; prose hygiene

→

**Ship**Opening a PR → Babysit (never merges) → Shipping (an agent that did not write the code gives the verdict)

→

**Audit**evidence, decision log (/show-me-your-work), PR

Where the human sits: at the front (goal and finish condition), at the back (auditing), and at hard gates only. "Just do it... Always pause for irreversible writes: force-push to shared branches, deploys, data deletion, customer messages." Even design forks are not yours to answer if an experiment can settle them: "If the answer is a fact you could observe by running something... it is not the human's to answer." The one explicit checkpoint is opt-in: "/architect with checkpoint."

### The 21 principles

Each is its own skill file; the router reads the index at task start and replies must "name each principle that shaped a decision and the specific choice it changed." You steer with the names. One-liners are the verbatim frontmatter descriptions, trimmed. primary

| Group | Principle | The rule |
| --- | --- | --- |
| Core | Laziness Protocol | "Bias toward deletion and the smallest change that solves the problem." "If a human developer would find the code exhausting to maintain, it is a bad solution. Be lazy. Stay simple." |
| Core | Foundational Thinking | "Get the data structures right so downstream code becomes obvious." Scaffold (CI, tests, shared types) before features. |
| Core | Redesign from First Principles | "Redesign as if the requirement had been a foundational assumption from day one, instead of bolting it on." |
| Core | Subtract Before You Add | "Remove dead weight, redundant validators, and stub references first, then build on the simpler base." |
| Core | Minimize Reader Load | "Can a new reader answer 'where does X come from?' and 'what can change X?' in under 30 seconds?" |
| Core | Outcome-Oriented Execution | In planned migrations, "Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code." |
| Core | Experience First | "Choose user delight over implementation convenience; ship fewer polished features over more rough ones." "User" includes the colleague who imports it. |
| Core | Exhaust the Design Space | "Build 2-3 competing prototypes and compare side by side before committing." "A second flavor of the first shape does not count." |
| Core | Build the Lever | "Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand." If you cited it and there is no tool in the diff, you did not apply it. |
| Architecture | Model the Domain | "Encode the domain in a structure instead of scattered conditionals." The tell you skipped it: a feature that grows an if/else chain by one branch. |
| Architecture | Boundary Discipline | "Concentrate guards at system boundaries... trust internal types and keep business logic in pure functions." |
| Architecture | Type System Discipline | "Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, refuse to lie to the compiler." "The type checker is a proof assistant." |
| Architecture | Make Operations Idempotent | "What happens if this runs twice? What happens if the previous run crashed halfway?" |
| Architecture | Migrate Callers Then Delete Legacy APIs | "Migrate callers and delete the old API in the same wave instead of preserving compatibility layers." Internal APIs only. |
| Architecture | Separate Before Serializing Shared State | "Eliminate the sharing first." "Instructions and conventions are not concurrency control." Hence one worktree per worker. |
| Verification | Prove It Works | "Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.'" |
| Verification | Fix Root Causes | "reproduce first, ask why until you reach it, resist nil-check guards that silence crashes." "Restart bugs: suspect state before code." |
| Verification | Sequence Work into Verifiable Units | "Break work into small units that each end in a verifiable state." Canonical shape: the failing test commit first, the fix on top. |
| Delegation | Guard the Context Window | "Route bulk to subagents; keep summaries in the main thread, not raw payloads." "The context window is finite and non-renewable within a session." |
| Delegation | Never Block on the Human | "Proceed, present the result, let the human course-correct after the fact; reserve confirmation for irreversible actions." "Code is cheap. Waiting is expensive." |
| Meta | Encode Lessons in Structure | "Encode the rule as a lint, metadata flag, runtime check, or script instead of more text." "The instruction IS the symptom." |

### The action skills

The 24 non-principle skills. The last column is my read of which ones stand alone in Claude Code for someone at your stage. primary

Action, verification and prose skills 24 skills

| Skill | Kind | What it does | Representative line | Beginner? |
| --- | --- | --- | --- | --- |
| /poteto-mode | router | Reads principles, matches a playbook, copies its steps into a todo list, delegates by model role, writes an unslopped reply. Sticky across turns. | "A step you choose not to do stays in the list with a one-line skip: <reason>; skipping silently is not allowed." | Later |
| /how | understanding | Explain mode: 2–4 read-only explorers plus an explainer writing Overview / Key Concepts / How It Works / Where Things Live / Gotchas. Critique mode adds one critic per panel model. | "Enough to build a working mental model, not annotated source code." | **Yes** |
| /why | understanding | Companion to how: git blame and log, one investigator per available evidence source, a synthesizer bound to five confidence tiers (Direct / Supported / Inferred / Speculative / Unknown). | "Prefer 'appears to' over 'because'." A user's guessed reason "is a prompt for investigation, not a conclusion to validate." | **Yes** |
| /teach | understanding | Runs how and why and weaves them into one explanation built diagram by diagram, no quizzes. | "to teach a flow from A to B to C, draw it three times." | **Yes** |
| /recall | context | Rebuilds your working context from your own transcripts, live state and the shared record. | "A transcript or a stale ticket is history, not current truth." | Later (transcript paths differ per harness) |
| /blast-radius | verification | Finds the one safety fact a scary small diff depends on and proves it by running code, up a five-rung evidence ladder. | "Listing the callers is not the job... The job is the breakage grep won't show you." "You said so. Worthless on its own." | **Yes** |
| /architect | design | Ground (how/why) → Sketch (arena over two structurally distinct candidates, screened for shallow modules, information leakage, pass-through methods) → optional Agree checkpoint → Implement → Scrap. | "Design it twice." "Default: proceed directly to implementation with the synthesized design. No human checkpoint." | Later; use "with checkpoint" |
| /arena | parallelism | N candidates at the same brief in separate worktrees, a read-only cross-judge on a different model family, pick a base, graft, verify. | "When N candidates wildly diverge, Phase A was under-specified." | No (Theo: "token burners") |
| /swarm | parallelism | Fan out N workers for coverage or races; each reports PASS / ISSUES / BLOCKED; the parent aggregates one report. | "Do not paste raw worker dumps." | No |
| /interrogate | review | Same intent, diff and rubric (correctness, root causes, structure, verification, complexity budget, security) to four reviewers on different model families; the lead filters. | "The adversarial signal comes from model diversity, not assigned personas." "Do NOT auto-apply changes." | Later; single-vendor in Claude Code |
| /tdd | verification | Failing test first, then fix, only when a cheap local test target exists. | "Prefer no new test over a bad test." | **Yes** |
| /unslop | prose | Removes 31 AI tells from any writing (em dashes, "Not just X, but Y," rule of three, chatbot phrases) and "adds soul." | "Cut AI tells from any writing. Must always apply." | **Yes** (Theo: "everyone should have unslop") |
| /bro | prose | Restates the last reply plainly. | "Stop using jargon and speak coherently." | **Yes** |
| /no-comments | cleanup | Hands the diff to the Comment Sicko subagent; keeps only license headers, external gotchas, public-API docs and issue links. | "Authoring agents defend comments." | Maybe not; a learner may want the comments |
| /technical-writing | prose | Diátaxis → Google developer style → Simplified Technical English → Global English, with a checklist. | "The goal is writing a tired engineer understands on the first read." | Yes |
| /show-me-your-work | audit | Append-only TSV decision log (ts, phase, decision, why, evidence, result) audited against the transcript by a reviewer on another model. | "Fix the log, not the story." | Later |
| /figure-it-out | router | Designs a bespoke playbook when none fits: falsifiable done predicate, phases, hypothesis loop, audit trail. | "The cost of building the wrong thing dwarfs the cost of being careful." | Later |
| /setup-pstack | config | Enumerates available model slugs and writes the role → model rules file. The only skill without `disable-model-invocation`. | "Never write a real slug you have not confirmed is available." | First step if you install a port |
| /create-verification-skill · /maintain-verification-skill | verification | Interviews the repository and writes a project-local `verify-<app>` skill (Launch / Doctor / Drive / Evidence / Cleanup) with a feature map; upkeep ends clean, changed, or blocked. | "Interview the repo, not the user." "A generated skill that was never executed is a draft, not a deliverable." | Yes, once you have an app to drive |
| /reflect · /automate-me | meta | Reflect: three reviewers propose skill edits after a hard task, applied only after your approval. Automate-me: mines transcripts to draft your own `<you>-mode`. | "Skill changes affect every future agent in the org; do not auto-apply." | Later |
| /typescript-best-practices | grounding | Auto-loads on any `.ts`/`.tsx` file: discriminated unions, branded types, `unknown` over `any`, no `as` casts, exhaustiveness. | "Every as is a runtime crash waiting." | Yes if you write TypeScript |
| /make-bot-ui | integration | Grok Bot webhook dashboards. |  | No (Cursor/Grok only) |

Playbooks 22 + Opening a PR

Investigation (read-only; "No PR, no babysit"). Bug fix (reproduce yourself first; the failing repro lands before the fix in history). Perf issue (against a baseline; eight strategy families). Hillclimb (one metric, one commit per accepted win, "a plateau means pivot, not stop"). Runtime forensics and Trace forensics (a diagnosis, not a fix). Feature (how → architect → a four-item throughput checkpoint → delegate → verify → commits → PR). Refactoring ("Pin the behavior contract first... Type check and lint are not a pin"). Prototype (the one playbook where "smallest change" and the verification bar invert). Visual parity (pixel diffs to zero). Authoring a skill. Eval (blinded). Babysit (drive a PR to merge-ready; never merges). Shipping (independent verification, then land the contiguous verified run bottom-up). Autonomous run (predicate first; "A plateau is not a stop"). Orchestrate (a standing coordinator that "never authors or edits code"; her own warning: its ceremony once "turned a half-hour 12-unit job into 1 landed unit while a plain agent landed all 12"). Autopilot-full and Autopilot-stack. Session pickup ("A pickup is inheritance... Resist the urge to re-derive; read."). Pause safely. Multi-phase or multi-PR plan ("The plan is the deliverable. Do not implement."). Worktree and simulator cleanup. Opening a PR ("Invoked at the end of every other playbook": worktree, small ordered commits, Conventional Commits, Why / Scope / Tradeoffs / Blast Radius / Verification sections, "Prefer five narrow PRs to one large PR," never a draft).

### The six axes, briefly

**Team architecture.** One human plus subagents whose roles get models: at the snapshot, feature and refactoring work, explorers and swarm workers on `grok-4.6-fast-xhigh`; bug fixes, judgment, prose and the hardest tasks on `claude-fable-5-1-thinking-max`; every review panel on four models (Fable, GPT-5.6 Sol, Grok 4.6, Opus 5), with the rationale "precisely-specified code, prose, and judgment go to fable 5.1, while fast mechanical code goes to grok." These defaults changed six times in three months. Every delegate reads poteto-mode in full before working. Nothing addresses multi-human process. primary

**Brownfield.** The strongest axis, and the one Leslie Li summarized as "Go deep first." The guide: "An agent that starts editing without a traced model tends to fix the symptom at the first plausible spot. /how first is cheaper than the second bug." Bug fix and Refactoring playbooks both begin with understanding. primary

**Adding code.** "Any code → name the data shape first"; "Code crossing a function boundary → the architect skill." Delegation is mandatory in the Feature playbook because "the gain is review separation." Verification is the gate: "'It compiles' is not evidence." Shipping's rule: "Green is not safe... Safe means a verdict from an agent that did not write the code." primary

**Tools.** Cursor's `Task` tool, cloud agents, `/loop`, `/goal`, sticky-mode frontmatter, and three sibling skills (`/deslop`, `control-cli`, `control-ui`) that live in another Cursor plugin, so upstream pstack is incomplete even on Cursor. Scripts (~6.6k lines) need `bun` and `gh`. primary

**Preferences.** Less code; comments are a smell ("Keep a comment only for a non-obvious why the code can't show"); unslop everything, including "The long-dash character is banned outright"; candor over agreement ("No is an acceptable answer... Agreement is not the default"); multi-model by conviction; "The ask is the slow path. A throwaway probe usually answers faster." primary

**How skills fit.** "Playbook steps get copied verbatim into the agent's working todolist before it reasons about the task," and because nearly everything is `disable-model-invocation: true`, "Rules only apply through explicit routing." "You don't invoke principles. You use their names to steer." primary

### Running it in Claude Code

Upstream has no Claude Code support, by design; its skill bodies reference Cursor primitives throughout, and copying the tree into `~/.claude/skills/` leaves dozens of dangling references. Two maintained ports exist. primary

**open-pstack** (ericlitman; v1.3.0, synced to upstream 0.14.7 on 2026-09-03) stays "as close to her original work as possible" and restores the four-model review panel by shelling out to the Codex and Grok CLIs, which you must install and sign into; if you only have Claude, set the non-Claude roles to `inherit-parent` and the panels become one vendor at several tiers. **pstack-claude** (michael-denyer; synced to 0.14.2) is Claude-only and simpler; its panels are Opus 5 / Fable 5 / Sonnet 5 and its "harsher pass" is a bundled review skill. Both add a `SessionStart` hook that routes non-trivial work into poteto-mode automatically, and both import `/deslop` from the sibling plugin. Not ported by anyone: the Benny automation, make-bot-ui, sticky mode, and the ten-chapter `docs/guide/` tutorial (read it upstream).

```
/plugin marketplace add ericlitman/open-pstack
/plugin install pstack@open-pstack
/reload-plugins
# tools the playbooks call: gh (authenticated), bun, node
/pstack:setup-pstack            # writes ~/.claude/pstack-models.md and imports it from ~/.claude/CLAUDE.md
/pstack:teach how does <subsystem> work      # or /pstack:how, /pstack:why, /pstack:unslop, /pstack:blast-radius
```

**What changes in Claude Code, whichever port:** no sticky mode (the hook is the analog); no cloud agents, so swarms and autopilots run as local background subagents in worktrees on your machine; no `/loop` or `/goal` (Claude's own loop skill and standing orders substitute, less robust for overnight runs); transcripts live at `~/.claude/projects/`, which affects recall, reflect and automate-me; real model diversity only with extra subscriptions. Cost: every panel is four frontier calls and /arena adds a judge and grafting. Delete `hooks/hooks.json` from the installed copy if you would rather invoke skills by hand.

### What Theo said about it (2026-08-19) secondary

* "PA stack created by Lauren, otherwise known as Potato, one of my old favorite React core team members, who is now at Cursor."
* On unslop: "This skill has fundamentally changed my willingness to read the things that my agents say to me." "I think everyone should have unslop at this point."
* On blast-radius: "This one is great and has [caught] a couple things that would have been miserable if I didn't have it. It also calls out that you can't trust your own writeup."
* On arena: "This has been a very fun skill for those of us who are token burners because we have a bunch of usage to get through."
* The criticism: the skills are "tied to cursor specifically, which is the biggest issue," and he would "be pumped if somebody like cloned all the Pstack skills in a generic not cursor specific way." (That is what the ports above are.)
* Verdict: "I find Pstack writing to be a lot more readable and also the behaviors from these skills to be a lot more applicable for my day-to-day."

He copy-pasted individual skills into his fleet repo rather than installing the router; there is no evidence he adopted /poteto-mode, the 21 principles as a system, or the overnight playbooks. Circumstantially, T3 Code's own test fixtures use `unslop` as the example skill name. His praise sits inside a longer skepticism about skill packs, so the honest reading is: take the good individual skills, be wary of the coupling, copy-paste rather than install wholesale.

### Friction for a beginner

* **It is one senior engineer's private style, published.** "poteto-mode is my style. you may not want exactly that." Everything from em-dash bans to "never open a draft PR" is her taste.
* **Cursor and, increasingly, Grok coupling.** In Claude Code you depend on a volunteer port that lags upstream by days to weeks.
* **Token cost.** Four-model panels, arenas with judges, swarms of verifiers per PR. Lauren herself notes frontier fan-out "burn[s] expensive tokens."
* **Vocabulary load.** 45 skills, 23 playbooks, 21 named principles, plus "throughput checkpoint," "merge frontier," "patch-id," "gauntlet lanes." The guide says "Don't memorize the list," but the router expects goals phrased with checkable finish conditions.
* **"Never block on the human" cuts both ways.** By default it proceeds on anything reversible and prototypes instead of asking design questions. For someone who cannot yet judge a diff, review-after-the-fact is riskier than it is for her. open-pstack's README says as much: "Start with supervised work."
* **Anti-comment and anti-planning stances.** You can simply not run those skills.
* **What is beginner-friendly:** /teach, /how, /why, /bro, /unslop, /blast-radius, /tdd, each usable standalone, plus the guide. Leslie Li's advice fits: take "the sequence, not the slash-command catalog": understand, require a real artifact of the problem, verify on the real thing, only then parallelize.

System 4 of 4 · [michaelshimeles/skills](https://github.com/michaelshimeles/skills) · 2026-09-03 · no license stated
