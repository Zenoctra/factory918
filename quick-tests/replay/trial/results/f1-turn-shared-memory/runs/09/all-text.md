Before round two: I tried to post your round-one answers word for word as a comment on "Decide how the writing treats rules that bound how a task is pursued", and the permission was declined. I didn't retry. Your Q2 note about dense terms and your Q5 budget ruling are already saved in my memory. Do you want the comment posted, either now or with the resolution when the ticket closes?

## Q1, explained again in plain terms

From here on, every rule in a brief gets one of two labels:

- **A must** binds. Only someone who owns the decision can make one: you, a ticket you approved, AGENTS.md, or an orchestrator about something it actually controls, like which files another subagent is editing right now. A must states its reason.
- **Advice** is everything else. It's written as "here's what I know, and why". The reader may take another route, and its report says that it did.

The main consequence is that an agent writing a brief can't promote its own guess about how the work should go into a must. That's where "read only the diff" came from. Most musts are about what's wanted, what done means, or whose call something is. You can still make a must about how the work is done, because the factory's process is yours. An agent can't do that for another agent's work. Q6 below runs this on real rules, which should make it more concrete.

## Q3: I overstated something

I said a bar changes what gets reported, not what gets found. That's true of thresholds and caps. It isn't true of focus, and focus is what you're worried about. In the gorilla study, what people were counting decided what they saw. So a reviewer told to "report everything" still has a focus and can read past a whole kind of bug.

A "slight push" toward some bug types would also be a focus. The list studies say that naming types pulls readers toward them and away from everything else. So your sense that it would cause headaches is backed by the evidence.

The fix the evidence supports is structural. In Shin's preprint, a second pass with an open-ended brief recovered everything the narrow pass hid. That's your "multiple passes", and it's a question for the review system, not this ticket. Your choice of (a) still holds for bars and caps.

## Q5

Recorded as you said it. The first mode is called `safe` and the second is `eco`.

---

Round two. I'll use "must" and "advice" from here on.

❓ **Q4 - Replace the five ways a reader departs from a rule?** Here are the five that exist today:

| # | What it tells the reader | Where |
|---|---|---|
| 1 | **Ask first.** "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." | [AGENTS.md:26](AGENTS.md:26), and your note at [template/AGENTS.md:20](template/AGENTS.md:20) |
| 2 | **Obey, then explain.** "Follow the file and tell me why your instinct differed." | Your note, [template/AGENTS.md:16](template/AGENTS.md:16) |
| 3 | **Decide and record.** Where the spec is silent, the agent decides and writes a Provisional decision you can overrule. | PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30) |
| 4 | **Skip and say so.** A step it won't do gets `skip: <reason>`. Skipping delegation is forbidden. | pstack's poteto-mode; [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) |
| 5 | **Stop and send it back.** A writer that can't build a step as written stops and reports it. Flags must end `fixed:` or `accepted:`. Bad criteria go back to you. | feature.md, spec-review, ticket.md |

So the same situation gets five answers: ask, obey, decide, skip, stop. Number 1 also fails for a subagent, which has nobody to ask, and it fights "never block on the human", which sits two lines above it in your note.

Numbers 1 and 2 are your own words. Replacing them means rewriting your note, so that part is explicitly your call.

My proposal:
- **For advice**, the reader uses its judgment, and its report says where it went another way and why. This keeps 3 and 4.
- **For a must that fights the goal**, the reader stops that part, tells the must's owner, and carries on with the rest. This is 5. In your own window the owner is you, so this becomes 1 again.
- **Number 2 survives for musts only**: obey it, and report the conflict.
- **In every case, the reader never shrinks the goal to fit a rule.**

The options:
- (a) Adopt the proposal and rewrite your note to match.
- (b) Keep all five and say which applies where.
- (c) Something else.

➡️ (a).

---

❓ **Q6 - Do these verdicts match what you mean?** These are real factory rules run through Q1–Q3. This only checks the test. Actually reworking the files belongs to the ticket "Decide the scope and order of reworking existing files". If any verdict feels wrong, the test is wrong.

| Rule | Verdict | Why |
|---|---|---|
| Never push to main (guard hook) | Must | Merging is your call, and you set it. |
| The orchestrator never writes code (delegation hook) | Must | It's about how, but the process is yours. You set it with evidence: an agent broke it knowingly. |
| The trail review is mandatory ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)) | Must | It's about how, but you made it mandatory after it caught the owner's errors three times out of three. |
| `knowledge`: never read more than 150 lines in one call | Advice | No reason or owner decision on record. It becomes "the files are long; the index lets you jump to a section." |
| Review briefs' "read nothing beyond this brief" limits | Gone | Agents added them for cost, and nobody asked for them. The brief gives context instead. |
| The `spec:` gate: a hard bug needs a ticket line to cite (`review-brief.sh:494`) | Moves (Q3) | The reviewer reports every bug, and matching bugs to the spec happens in a later step. |
| Subagents never launch their own dev servers ([template/AGENTS.md:68](template/AGENTS.md:68)) | Split | Ports and processes are shared with other subagents, so that part is a must, and its dropped reason comes back. How to test is advice. |
| Any token or wall-clock budget | Advice, or left out | Per your Q5: a must only when you approved it. |

➡️ Yes to all eight, unless one of them sits wrong with you.

---

❓ **Q7 - How is a must worded and held?** The research points four ways:
- Current Claude models over-apply rules written emphatically.
- A bare "don't" names the forbidden thing and doesn't say what to do instead.
- A line repeated everywhere gets read past.
- Each added rule costs attention, which is your Q2 point.

There's one cost on the other side: the worktree guard cost subagents turns because they hit it without warning.

The options:
- (a) Write each must once, plainly, with its reason and what to do instead, where the reader first meets the system. Where a hook or script can hold it, the hook's refusal carries the reason and the way forward. Briefs don't restate musts a hook already holds.
- (b) Restate every must in every brief, to be safe.
- (c) Hook only, with no prose.

➡️ (a).

---

❓ **Q8 - Where does your review-system idea live?** That idea covers:
- several passes, each with its own focus;
- an open-ended pass;
- a verifier that rates bugs;
- interrogate's wider range;
- recall measured against planted bugs, not just "no false positives".

The options:
- (a) A ticket on this map.
- (b) Its own map later, with a pointer from this map's "Not yet specified". The wording of review briefs stays here, under "Prototype brief templates for the recurring lane jobs". Recall against planted bugs and your dense-terms experiment go to "Decide how we'll know the writing works".

➡️ (b). How many passes there are and who rates what is process design, which is bigger than how the writing works. The wording of each pass's brief still comes from here.