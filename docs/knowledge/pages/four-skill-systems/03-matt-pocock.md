<!-- lines: 215 | source: pages/four-skill-systems.md | part 3/9 | title: Four Skill Systems (reference page) — Matt Pocock -->

## Contents (line numbers are for the Read tool's offset)
- L15: Matt Pocock
- L19: Philosophy
- L39: The flow: idea → ship
- L89: The six axes
- L115: Skill catalog
- L162: How it evolved, and why community guides are stale
- L166: Install in Claude Code
- L179: Friction for a beginner, from his own docs
- L189: Does the planning half actually work? The evidence
- L201: What Theo said about this set (2026-08-19)

## Matt Pocock

Creator of Total TypeScript and AI Hero; a teacher first, which shows. His repo, "Skills for Real Engineers. Straight from my .agents directory," is one of the most-installed skill collections in existence (241.8k stars and 20.3M skills.sh installs as fetched 2026-09-04). It packages decades-old engineering practice as prompts: tracer bullets from The Pragmatic Programmer, Kent Beck's red→green loop, Eric Evans's ubiquitous language, John Ousterhout's deep modules, Michael Feathers's seams, Martin Fowler's smells.

### Philosophy

The whole repo is positioned against process-owning frameworks and against vibe coding at once:

> "Developing real applications is hard. Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control and make bugs in the process hard to resolve. These skills are designed to be small, easy to adapt, and composable. They work with any model. They're based on decades of engineering experience. Hack around with them. Make them your own."
>
> README.md primary

He organizes the skills around four failure modes he sees in agent-assisted work, each with one fix. *The agent didn't do what I want* is a communication gap, fixed by a grilling session. *The agent is way too verbose* is missing shared vocabulary, fixed by a glossary file (`CONTEXT.md`) that he calls "the single coolest technique in this repo." *The code doesn't work* is missing feedback loops, fixed by types, browser access and a red→green test loop. *We built a ball of mud* is accelerated entropy, fixed by caring about design: "The best modules are deep." His summary line: "Software engineering fundamentals matter more than ever."

Three ideas underneath everything are worth knowing by name. **Smart zone:** plan around the first ~150k tokens of a session, not the window, because recall degrades after that ("Plan around the smart zone, not the window"). **Facts vs decisions:** "Finding facts is your job, never the user's... The decisions are the user's: put each to them and wait." **Config is death:** skills stay opinionated; your preferences go in `CLAUDE.md` as plain instructions, which every skill already reads.

The one structural axis is who can invoke a skill:

> "**User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you or reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one."
>
> README.md primary

He prefers user-invoked for predictability: "Every model-invoked skill has a cost in unpredictability: the model may choose not to follow the context pointer." secondary Mechanically, user-invoked means `disable-model-invocation: true` in the frontmatter (and `policy.allow_implicit_invocation: false` in the Codex sidecar).

### The flow: idea → ship

The router skill /ask-matt is the canonical map: "Most paths run along one main flow, and two on-ramps merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath." Dashed boxes are human decision points.

**Setup, once per repo**/setup-matt-pocock-skillstracker (GitHub, GitLab, local markdown), triage labels, doc layout

→

**Grill**/grill-with-docsrounds of numbered questions; writes `CONTEXT.md` and ADRs as it goes

→

**Small change?**yes → /implement in the same window

→

**Spec**/to-spec"no interview, just synthesis"; confirm test seams; publish to tracker

→

**Tickets**/to-ticketstracer-bullet slices with blocking edges; you approve the breakdown

→

**`/clear`**fresh context per ticket

→

**Implement**/implementdrives /tdd at pre-agreed seams; ends with /code-review (two parallel reviewers); commits to current branch

→

**You close the ticket**and open a PR if you want one; repeat per ticket

Context rule: "Keep steps 1–3 in one unbroken context window (don't compact or clear until after `/to-tickets`) so the grilling, spec, and tickets all build on the same thinking. Each `/implement` then starts fresh, working from the ticket."

**On-ramp: incoming issues**/triage moves issues and outside PRs through `needs-triage → needs-info | ready-for-agent | ready-for-human | wontfix`, verifies the claim, writes an agent brief. "Triage is only for issues you didn't create."

**On-ramp: a huge foggy effort**/wayfinder maps decision tickets on the tracker and resolves them one per session; "it hands off, it doesn't build," merging onto the main flow at /to-spec.

**Standalone: something is broken**/diagnosing-bugs: build a feedback loop, minimize, 3–5 hypotheses, instrument one variable at a time, regression test before the fix. "Build the right feedback loop, and the bug is 90% fixed."

**Escape hatch: an ungrillable question**/handoff out, /prototype in a fresh session ("throwaway code that answers a question"), /handoff back.

**Upkeep**/improve-codebase-architecture "every few days": a subagent walks the code, an HTML report lists deepening candidates, you pick one and it grills you toward an idea for the main flow.

**Vocabulary layer (model-invoked)**grilling, domain-modeling, codebase-design, tdd, writing-for-agents: the disciplines the orchestrators call with "Call the Skill tool with…"

At every phase boundary there is a written decision tree (`PHASE-BOUNDARIES.md`): can you continue in this session; is the context irrelevant to what comes next (`/clear`); does something have to travel (/handoff, "narrow by design"); can it be done AFK (send it to a subagent); otherwise `/compact`, which is "the default, not the first reach." His line on why: "Every move except Continue turns a primary source into a secondary source."

### The six axes

#### Team architecture

The default shape is one human, one interactive session, subagents for scoped work: grilling dispatches subagents to find facts, /code-review runs Standards and Spec reviewers in parallel "so they don't pollute each other's context," /research runs a background agent, /wayfinder fires a research subagent per research ticket. Parallelism between tickets is manual: "look at the board, count the tickets with no open blockers, and open that many agent sessions. One ticket per fresh context, cleared between them." The docs are blunt that running several /implement sessions in one checkout is "worse than unsupported... The sessions share one working directory, one index, and one HEAD." The direction of travel is the beta implement-spec (implementer subagents in their own worktrees, a merger subagent, a draft PR) and his separate Sandcastle project (agents in sandboxed worktrees). The human's job, in his words, cannot be delegated: alignment and QA. "The human is the index." primary

#### Brownfield

There is no onboarding skill; you point the domain-modeling discipline at an existing repo on purpose. "`/grill-with-docs help me scaffold my existing repo with a CONTEXT.md` is the documented route; expect a long interrogation: one user reported 50+ questions." What comes out is deliberately narrow: "`CONTEXT.md` should be totally devoid of implementation details... It is a glossary and nothing else," plus ADRs offered only when a decision is hard to reverse, surprising without context, and the result of a real trade-off. The brownfield-aware move inside domain-modeling is cross-referencing: "When the user states how something works, check whether the code agrees. If you find a contradiction, surface it." /improve-codebase-architecture is offered for a "Brownfield audit" with the counterweight in his own docs: users with out-of-control projects report it "helped a little but still doesn't seem to cut it." Two warnings matter for you specifically: "an unreviewed, agent-authored glossary is worse than none," and "A domain language you do not understand yourself becomes meaningless drivel once written down." primary

#### Adding code and handling changes

The spec is a decision record ("Anything the spec asserts that you never actually said is a defect") and is throwaway once the work ships; `CONTEXT.md` and ADRs are what outlive it. It contains no file paths or code snippets because "They may end up being outdated very quickly." Tickets are tracer bullets: "Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer... Each slice is sized to fit in a single fresh context window." Prefactoring comes first ("Make the change easy, then make the easy change"). /implement is six lines: implement, TDD at pre-agreed seams, typecheck and test regularly, full suite once at the end, /code-review, commit to the current branch. It does not open PRs, close tickets, or act on review findings; "People override it in the invocation ('commit to a branch and open a PR')." TDD is red→green only; the refactor step "was dropped in June 2026 because agents essentially never performed it." Review is two-axis and never merged into one verdict: "Don't pick a single winner across axes." Incoming contributions go through /triage, where "a PR is an issue with attached code" and every posted comment starts with "This was generated by AI during triage." primary

#### Tools and harness

Two install routes and you pick one: the Claude Code plugin ("a managed, read-only bundle that updates when I ship") or skills.sh ("copies editable skill files into your project"). Everything is verified on Claude Code; Codex works through `agents/openai.yaml` sidecars beside every `SKILL.md`; there is no Matt statement comparing Cursor. Plan mode is explicitly off for grilling: "Plan mode primes the agent to rush toward producing a plan, which is the opposite of staying in inquiry." Trackers are configured once by /setup-matt-pocock-skills and "Local markdown is a first-class option, not a fallback." Hooks exist only in an unpromoted skill (git-guardrails-claude-code, which blocks `git push`, `reset --hard`, `clean -f`, `branch -D`). Worktrees appear only in the beta and in Sandcastle. primary

#### Preferences

Grill every time ("Use them every time you want to make a change"), with the smartest model you have ("A dumb model won't give you good ideas"). Deep modules with his own twist: he rejects Ousterhout's lines-of-implementation ratio ("rewards padding the implementation") for "depth-as-leverage," and the memorable tests are "the deletion test" and "One adapter means a hypothetical seam. Two adapters means a real one." Domain modeling is DDD-lite: "the payoff is upstream, in naming and concept alignment, not in aggregates and layer ceremony... On a one-day build, skip it." Writing for agents has its own vocabulary: context pointers, leading words, progressive disclosure, pruning no-ops, and "Prompt the positive" because negation fails. He is against: config knobs, hard caps on questions, file paths in tickets and briefs, horizontal slicing, mocking your own modules, `/compact` as a reflex, `--abort` on conflicts, barrel files, and generic review skills that do not know your standards. The repo bans em dashes in all prose. primary

#### How the skills fit

Entry points: /grill-with-docs for anyone with a repo ("No I think that will remain the easy entry point. /wayfinder for intermediate/advanced users"), /ask-matt when you forget which skill fits. Chaining is by an explicit instruction to "Call the Skill tool with 'grilling'" rather than prose, because "A skill that names another skill in prose... does not reliably cause it to load," which is the most-reported bug behind /grill-with-docs. Model-invoked descriptions keep trigger phrasing ("Use when the user wants…, mentions…") so auto-invocation fires; user-invoked descriptions are human-facing. primary

### Skill catalog

Read from the 2026-08-24 snapshot. Invocation tags: user you type it; model the agent may reach for it. The plugin ships the 25 promoted skills; misc and beta skills are skills.sh-only.

Engineering skills, promoted 18 skills

| Skill | Inv. | What it does | Chains to / reads & writes | Note |
| --- | --- | --- | --- | --- |
| /ask-matt | user | Router: hand-written map of the main flow, on-ramps, vocabulary layer and phase boundaries. "You don't remember every skill, so ask." | Names every skill; fires none | "Where the router and a SKILL.md disagree, the SKILL.md is right." |
| /grill-with-docs | user | Head of the main flow. The entire body is one line: call grilling and domain-modeling. | Writes `CONTEXT.md`, `docs/adr/` | Most-reported problem: dependencies fail to load and you get "an undifferentiated question dump." |
| /to-spec | user | Synthesizes the thread into a spec (problem, solution, numbered user stories, implementation and testing decisions, out of scope); confirms test seams; publishes with `ready-for-agent`. | Reads `CONTEXT.md`/ADRs; writes a tracker issue or `.scratch/<feature>/spec.md` | Only on the multi-session branch. Renamed from `to-prd` in v1.1. |
| /to-tickets | user | Vertical tracer-bullet tickets with blocking edges, blockers first; quizzes you on granularity before publishing. | Writes tracker issues with native blocking links, or `.scratch/<feature>/issues/NN-slug.md` | Over-decomposition is the most-reported friction; GitHub sub-issue links sometimes not created. |
| /implement | user | Six lines: implement from spec/tickets, /tdd at pre-agreed seams, typecheck and test regularly, /code-review, commit to current branch. | /tdd, /code-review | No PR mode, no ticket closing, no batch mode. Pass full refs (`owner/repo#2`) in a fresh session. |
| /wayfinder | user | Plans work bigger than one session as a `wayfinder:map` issue with decision tickets (research, prototype, grilling, task), each labeled HITL or AFK. "Plan, don't do." | grilling, domain-modeling, research (subagents), prototype | "the most cognitively demanding flow here." Failure mode: the agent starts writing production code mid-map. |
| /triage | user | State machine for issues and outside PRs; verifies the claim first; writes durable agent briefs without file paths; records rejected ideas in `.out-of-scope/`. | grilling, domain-modeling; reads `docs/agents/triage-labels.md` | "The main use is open-source repos taking issues from external contributors." |
| /improve-codebase-architecture | user | Subagent survey for deepening candidates; HTML report with before/after diagrams; then grills you through the one you pick. | codebase-design, grilling, domain-modeling | Loudest complaint: it grills for an hour instead of showing the report. Report needs CDN access. |
| /setup-matt-pocock-skills | user | Explore → present → confirm → write: tracker, triage labels, domain-doc layout, an `## Agent skills` block in `CLAUDE.md`. | Writes `docs/agents/issue-tracker.md`, `docs/agents/domain.md` | Does not create GitHub labels; make them by hand. No global mode. |
| prototype | model | "throwaway code that answers a question": a single HTML file for logic questions, 3–5 radically different variants on one route for UI questions. No tests. | Ends on a `prototype/<name>` branch with a context pointer | The "ungrillable question" escape hatch. |
| diagnosing-bugs | model | Six gated phases: feedback loop, reproduce and minimize, falsifiable hypotheses shown to you, instrument one variable at a time, regression test before the fix, cleanup. | Ships `scripts/hitl-loop.template.sh` | Over-fires on quick questions, especially on some non-Claude models. |
| research | model | Background agent; primary sources only; one cited Markdown file. | Writes one `.md` | Known self-nesting bug (one report ~450k tokens). No stopping criterion. |
| tdd | model | Reference-only: what a good test is, seams, anti-patterns. "Test only at pre-agreed seams." "Refactoring is not part of the loop." | codebase-design; `tests.md`, `mocking.md` | Seam prompt lists names only; a beginner should ask for trade-offs first. |
| domain-modeling | model | Challenge terms, sharpen fuzzy language, cross-reference code, update `CONTEXT.md` inline, offer ADRs sparingly. | Writes `CONTEXT.md`/`CONTEXT-MAP.md`, `docs/adr/` | Most-reported problem: `CONTEXT.md` bloats into a spec. |
| codebase-design | model | Shared vocabulary for deep modules: module, interface, depth, seam, adapter, leverage, locality. Design-it-twice spawns 3+ subagents for radically different interfaces. | Called by others; writes nothing | "It is a reference, not a process." Most-asked: how to do this in TypeScript (beta answer: dependency-cruiser). |
| code-review | model | Diff since a fixed point on two axes (Standards, Spec) in two parallel subagents; Fowler smell baseline; reports side by side. | Reads `CODING_STANDARDS.md`, `CONTRIBUTING.md`, the tracker | Name collides with Claude Code's built-in `/code-review`. Prefer fresh context: "Same context reviewing itself isn't review." |
| resolving-merge-conflicts | model | Hunk by hunk by intent, from primary sources per side. "Always resolve; never `--abort`." | Git state | Standalone. |
| wizard | model | Generates an interactive bash wizard for steps only a human can do (credentials, dashboards, cutovers). | Writes a `.sh` from a 204-line template | Theo: "I can think of like four things I should have used it for yesterday." |

Productivity skills, promoted 7 skills

| Skill | Inv. | What it does | Note |
| --- | --- | --- | --- |
| /grill-me | user | One line: call grilling. Stateless; for when you are not in a repo. | "Leave plan mode off." Opt into one question at a time with a `CLAUDE.md` line. |
| /handoff | user | Compacts the conversation into a handoff document in the OS temp dir, with a "suggested skills" section for the next agent. | "You need it only when something has to travel." Was "oversold" as a general bridge. |
| /teach | user | A stateful teaching workspace (mission, resources, HTML lessons, learning records). "Never trust your parametric knowledge." | His composition for being grilled about something you do not understand: /handoff to a teaching workspace, /teach, come back. |
| /to-questionnaire | user | Turns a decision that lives in someone else's head into an async Markdown questionnaire. "Grill the send, not the subject." | One recipient; no delivery. |
| /wait-what | user | Three lines: re-pitch the last message in Simplified Technical English using the `CONTEXT.md` vocabulary. | "The mechanism is the name." Works inside any other skill. |
| grilling | model | The primitive: design tree → rounds of the whole frontier in a fixed question format; facts via subagents, decisions to you; ends when the frontier is empty and you confirm. | Under grill-me, grill-with-docs, triage, wayfinder, improve-codebase-architecture. |
| writing-for-agents | model | Reference for writing skills and `CLAUDE.md`: context pointers, the two loads, information hierarchy, completion criteria, leading words, pruning. | The meta-skill the whole repo is written against. |

Misc and beta (skills.sh only) 4 + 8 skills

**Misc** ("kept around but rarely used, not promoted"): git-guardrails-claude-code (a `PreToolUse` hook that blocks destructive git; note it blocks `git push` outright), setup-pre-commit (Husky + lint-staged + Prettier + typecheck + tests), migrate-to-shoehorn and scaffold-exercises (his own tooling; not transferable).

**Beta** ("public on purpose, feedback wanted, not shipped in the plugin"); each one is a direction signal. implement-spec: the answer to the repeated request for parallel implementation; tickets become a task graph, implementer subagents work in their own worktrees, a merger subagent folds them back, a draft PR closes the spec. claude-handoff: hand off to a background `claude --bg` agent. retro: a stub that reviews session logs and proposes environment improvements; notable line: `CLAUDE.md`/`AGENTS.md` "should be used incredibly sparingly, usually only for navigation pointers to other files." setup-ts-deep-modules: wires dependency-cruiser so "Public vs private is decided by depth." loop-me: grilling that outputs workflow specs, with the vocabulary trigger, checkpoint, "push right." Three writing-\* skills apply grilling to prose.

Install a beta skill directly: `npx skills@latest add mattpocock/skills --skill=implement-spec`.

### How it evolved, and why community guides are stale

The repo started around February 2026 ("Straight from my .claude directory"), hit v1.0.0 on 2026-06-17 (the user/model-invoked taxonomy; grilling exposed as a primitive; `caveman` and `zoom-out` removed), v1.1.0 on 2026-07-08 (`to-prd` → to-spec; `to-plan` + `to-issues` → to-tickets; `review` → code-review; `decision-mapping` → wayfinder; refactor dropped from TDD), and v1.2.0 on 2026-08-05 (official Claude Code plugin; Codex sidecars; wait-what; `writing-great-skills` → writing-for-agents; phase boundaries; prototypes kept on branches). Minor releases land roughly monthly. Any guide that mentions `/caveman`, `/diagnose`, `to-prd`, `to-issues` or "28 skills" describes the pre-1.0 repo, including the DeepLearningAI fork; the CHANGELOG is the translation key. The pattern in the removals: nothing was removed for being wrong; things were removed for being duplicated, unused, personal, or better folded into a shared reference skill. primary

### Install in Claude Code

```
claude plugins install mattpocock-skills      # or, in a session:  /plugin install mattpocock-skills
# then, once per repo:
/setup-matt-pocock-skills                     # choose GitHub / GitLab / local markdown; confirm what it drafts
# first real run, in a fresh session, plan mode off:
/grill-with-docs                              # answer the rounds; stay in the same window
# small change → /implement here.  multi-session → /to-spec → /to-tickets → /clear → /implement owner/repo#N
```

Do not also run the skills.sh installer ("installing both leaves you with every skill twice"). Plugin skills are namespaced (`/mattpocock-skills:grill-with-docs`), though the unqualified name usually resolves, which is how Claude Code's own `/code-review` gets shadowed. Prerequisites: `gh` authenticated if you choose GitHub Issues; nothing for local markdown. primary

### Friction for a beginner, from his own docs

* **It assumes you can make engineering decisions.** "Passivity allows agents to overwhelm you with excessive questions and scope explosion"; "what comes out tracks the quality of your answers, not the number of questions asked." The seam prompt in /tdd lists candidates by name only. Workaround he documents: /handoff to a /teach workspace, learn, come back.
* **Question volume and cost.** "Forty-six questions across four rounds is an ordinary session." Caps are refused by design (`.out-of-scope/question-limits.md`). A single /implement ticket over 100k tokens "is normal rather than a sign something broke."
* **Model dependency.** Weaker models skip the confirmation gate and start building; grilling "requires models with substantial parametric knowledge."
* **What it will not do.** Open PRs, close tickets, act on review findings, dispatch tickets, create labels, or take global config.
* **Open bugs at the snapshot.** /grill-with-docs dependencies failing to load; code-review name clash and recursive subagents; research self-nesting; /teach writing into the skills folder; wayfinder agents writing production code mid-map.
* **Ceremony tax on small changes.** His own docs: "the spec earns its step only on multi-session work... Go grilling → `/implement`."
* **TypeScript lean** in the misc skills and in the deep-module enforcement answer; the core spine is language-agnostic.

### Does the planning half actually work? The evidence

Three companion pages go deeper than this one, and the last is the one to implement: [The Factory](https://claude.ai/code/artifact/4cfb7dca-61de-4b7c-9856-f6b802c5f7f4) is the implementation spec for Manuel's own system (Matt for planning, pstack for execution, a Theo-derived deterministic layer, a loader CLI). The other two: [Pocock Planning Evidence](https://claude.ai/code/artifact/304aae27-803b-4dab-a10e-722f23a763ea) (below) and [The Deterministic Layer](https://claude.ai/code/artifact/2aa30d5f-d9b7-48e3-9979-03f721f35c02), which covers the lint, CI, hooks, review-bot and verification machinery under all four systems, with Theo's gates in order. The evidence brief collects real artifacts rather than opinions: verbatim specs and ticket sets from Matt's own `course-video-manager` and from third-party repos, real `CONTEXT.md` files with their sizes over time, wayfinder maps, his workshop build, every counted failure report in the issue tracker, and a structural comparison with BMAD. The short version, all verified against the live pages on 2026-09-05:

**Demonstrated.** The pipeline produces dense, template-conforming artifacts that agents build and merge the same day. Spec #1579 (26 user stories) became a four-ticket diamond (#1580 → #1582 and #1583 → #1584) and a 12-commit PR co-authored by Claude Opus 5, merged two hours and ten minutes after the spec was filed. Spec #1567 (29 stories) became 8 tickets and a 44-commit PR merged the next day. A wayfinder map became a 42-story spec and a bot-authored PR that merged the same day and honestly listed its own three deviations from the spec. A third-party 40-story spec became 16 tickets and a 24-commit PR with 492 tests green, with four items deferred to follow-ups rather than silently dropped. Matt dogfoods hard: 110 specs and 8 maps in one repo since January. Adoption on public GitHub is in the tens of thousands of template specs. measured

**Also demonstrated, against it.** A user ran a 26-ticket stack and counted "~20 agent runs per closed ticket, and roughly three quarters of those are repair-loop rework," traced to model-written acceptance criteria that graded nothing (#595). An 85-story spec produced 16 tickets, grew to 27, and orphaned a critical invariant that surfaced only in a test environment (#924). One /to-tickets run consumed 1.5M tokens for 14 tickets and left ~70 open decisions for the human (#826). A long-running map body was silently truncated and 59 index lines were lost (#944). Two open issues (#341, #1015) report precise grill answers softening into weaker spec prose, which is the BMAD failure at a lower dose. And Matt's own `CONTEXT.md` grew five-fold in five months, from a 65-term glossary to a 63 KB file, and he filed the issue himself: "Implementation detail in a glossary goes stale silently. Nothing compiles against it, so it drifts from the code and then misleads whoever reads it, which is an agent, most of the time" (#1589). His own specs and tickets name file paths, against his own template rule. measured

**Absent.** Any controlled comparison against no framework or against BMAD; any regression or defect-rate data; any written BMAD-to-Pocock migration with numbers. The one reviewer claiming "20–40% lower" time-to-correct-PR gave no methodology. self-reported

**The structural difference from BMAD** is real but narrower than the marketing: one human-sourced summarization hop (conversation → spec) instead of four model-to-model hops (brief → PRD → architecture → shards → stories); decisions made by you in the interview rather than by persona agents in documents; a human-run pipeline (every planning skill is user-invoked, dispatch is manual) rather than a model-run one; tickets that fail loudly at the first tracer bullet rather than an epic that fails at the end. What it does not do is remove the failure: the field reports say the remaining hop still drops invariants and still writes unfalsifiable criteria unless a human reads them. The system's answer is that the human is the safeguard, by design. That is the opposite of BMAD's claim to "eliminate context loss," and it is the honest position.

### What Theo said about this set (2026-08-19)

In "So I tried Matt's skills..." Theo copy-pasted skills into a thread in T3 Code rather than installing the plugin, and had agents audit which ones fit his machines. His reactions, from the auto-transcript secondary:

* On grill-me after running it: "I'm annoyed. Now, this skill is on all my machines."
* On the invocation axis: "He also has disable model invocation on for a lot of his skills, which means the model won't enable it itself... which I think is a very good call."
* On diagnosing-bugs: it "helped with a lot of my debugging stuff over the last few days, and it's been pretty solid." On wizard: "I can think of like four things I should have used it for yesterday." On writing-for-agents: "I've mostly been using this for prompting sub agents and it's been very helpful there."
* The central objection: "I don't necessarily want this much prescription on how I go step by step. Like I've been building my own workflows and they don't map quite as well to traditional stuff."
* On em dashes: "Why is he using M dashes in his skills? Matt. Matt. How many are on this? There's nine M dashes in this page." (The repo has since removed them.)
* Verdict: "There's a ton of good things that I'm grabbing from here," followed by the pivot to pstack: "I did not intend for it to be that at all, but I am much more philosophically aligned with what Potato is cooking over here."
* His standing rule, said in the same video: "Don't just blindly install all the skills here... if you just blindly copy my exact setup, it's like paying a bunch of money for a code template. It's cringe and bad."

Read that as an experienced practitioner who already has a workflow finding the spine too prescriptive, while still taking individual disciplines. For someone who does not yet have a workflow, the prescription is the point; you can loosen it later, and his own advice is to write your own once you know why.

System 2 of 4 · [pingdotgg/t3code](https://github.com/pingdotgg/t3code) · reconstructed · MIT (T3 Code)
