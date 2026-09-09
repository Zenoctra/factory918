<!-- lines: 73 | source: notes/1-matt-pocock.md | part 4/10 | title: Research note: Matt Pocock — The end-to-end flow (step by step; text diagram; where the human is) -->

## Contents (line numbers are for the Read tool's offset)
- L11: The end-to-end flow (step by step; text diagram; where the human is)
- L15: Step 0 — once per repo
- L18: The main flow: idea → ship
- L28: On-ramps (merge onto the main flow)
- L33: Codebase health
- L36: Text diagram of the chain (arrows = "produces input for"; `[H]` = human decision point)

## The end-to-end flow (step by step; text diagram; where the human is)

The router skill `ask-matt` is the canonical map ([skills/engineering/ask-matt/SKILL.md](research/1-matt-pocock/skills-repo/skills/engineering/ask-matt/SKILL.md)): "A **flow** is a path through the skills. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath."

### Step 0 — once per repo
`/setup-matt-pocock-skills` writes `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, (optionally) `docs/agents/triage-labels.md`, and an `## Agent skills` block into `CLAUDE.md`/`AGENTS.md`. "This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write." ([setup SKILL.md](research/1-matt-pocock/skills-repo/skills/engineering/setup-matt-pocock-skills/SKILL.md))

### The main flow: idea → ship
1. **`/grill-with-docs`** — "sharpens the idea by interview. Start here whenever you are **working in a working directory**: it's stateful, retaining what it learns in `CONTEXT.md` and ADRs." (No repo? `/grill-me`.) Human answers rounds of numbered questions; the agent looks up facts itself and writes glossary terms/ADRs inline.
2. **Branch: can every question be settled in conversation?** If not: "`/handoff` out, then open a fresh session against that file, `/prototype` to answer the question with throwaway code, `/handoff` back what you learned."
3. **Branch: is this a multi-session build?**
   - Yes → **`/to-spec`** (synthesises the thread into a spec; no new interview; publishes to the tracker) → **`/to-tickets`** (tracer-bullet tickets with blocking edges) → **`/implement`** per ticket, "**`/clear`ing context between each one**".
   - No → **`/implement`** "right here, in the same context window."
4. **`/implement`** "builds each issue by driving **`/tdd`** internally (one red-green slice at a time), then closes out by running **`/code-review`**, a two-axis review (Standards + Spec) of the diff, before committing."

**Context hygiene rule:** "Keep steps 1–3 in **one unbroken context window** (don't compact or clear until after `/to-tickets`) so the grilling, spec, and tickets all build on the same thinking. Each `/implement` then starts fresh, working from the ticket." ([ask-matt SKILL.md](research/1-matt-pocock/skills-repo/skills/engineering/ask-matt/SKILL.md))

### On-ramps (merge onto the main flow)
- **Bugs/requests piling up** → `/triage` → produces `ready-for-agent` issues with agent briefs → `/implement`. "Triage is only for issues **you didn't create**."
- **Something's broken** → `/diagnosing-bugs` (standalone loop).
- **A huge foggy effort** → `/wayfinder` → when the map clears, "**it hands off, it doesn't build**: merge onto the main flow at **`/to-spec`**".

### Codebase health
- `/improve-codebase-architecture` "runs whenever you have a spare moment... picking one _generates an idea_ you can take into the main flow at `/grill-with-docs`."

### Text diagram of the chain (arrows = "produces input for"; `[H]` = human decision point)

```
                    /setup-matt-pocock-skills  (once per repo, [H] confirms tracker/labels/docs)
                                 |
   /triage [H] ─────────────┐    |     ┌──────── /wayfinder [H] (decision tickets; research subagents)
   (incoming issues → briefs)│    v     │              |  map clears
                             │  IDEA    │              v
                             │    |     │         /to-spec #<map>
                             │    v     │
   /research (bg agent) ──▶ /grill-with-docs [H]  ◀── /improve-codebase-architecture [H] (survey → idea)
                            (= grilling + domain-modeling; writes CONTEXT.md + docs/adr/)
                                 |          \
                                 |           ── ungrillable? → /handoff → /prototype → /handoff back
                                 v
                    small? ──── /implement ──────────────────────────────┐
                                 |                                       |
                        multi-session?                                   |
                                 v                                       |
                             /to-spec [H confirms seams] ── publishes spec issue (ready-for-agent)
                                 v
                             /to-tickets [H approves breakdown] ── tickets w/ blocking edges
                                 v            (local .scratch/<feature>/issues/NN-slug.md or tracker)
                     /clear, then per ticket: /implement [H types it; never auto-fired]
                                 |  drives /tdd (red→green at pre-agreed seams)
                                 |  runs /code-review (2 parallel subagents: Standards + Spec)
                                 |  commits to current branch  [H closes ticket, opens PR if wanted]
                                 v
                         (repeat per frontier ticket; /clear between)

Vocabulary layer underneath (model-invoked, reached by other skills):
   /grilling   /domain-modeling   /codebase-design   /tdd   /writing-for-agents
Standalones: /diagnosing-bugs /resolving-merge-conflicts /wizard /wait-what /teach /to-questionnaire /handoff
```

**Where the human is in the loop.** Every user-invoked step is typed by the human and nothing else can fire it ([.agents/invocation.md](research/1-matt-pocock/skills-repo/.agents/invocation.md)). Inside the steps, the human: answers grilling rounds (decisions), confirms seams in `/to-spec`, approves the ticket breakdown in `/to-tickets`, picks a candidate in `/improve-codebase-architecture`, re-ranks hypotheses in `/diagnosing-bugs` Phase 3, closes tickets after `/implement` (it "has no completion step" — [docs/engineering/implement.md](research/1-matt-pocock/skills-repo/docs/engineering/implement.md)), and decides at every **phase boundary** between Continue / `/clear` / `/handoff` / subagent / `/compact` ([PHASE-BOUNDARIES.md](research/1-matt-pocock/skills-repo/skills/engineering/ask-matt/PHASE-BOUNDARIES.md)). Wayfinder makes this explicit with a HITL/AFK label on every ticket: "A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this)." ([wayfinder SKILL.md](research/1-matt-pocock/skills-repo/skills/engineering/wayfinder/SKILL.md))

---
