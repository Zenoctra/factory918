Here's where round one landed and what's still open. I've reworked Q1 in concrete terms, as you asked.

**Settled:**
- **Q2 (b).** What the writer knows about how to do the job goes in as information with its reason, never as an order. Your point about related terms goes to two places: "Decide how we'll know the writing works", as an experiment, and "Decide what the writing standard is and what carries it". One precise term can pull in most of what a dozen rules would say, which cuts the number of rules competing for attention. Only the unusual parts then need saying.
- **Q3 (a), with a correction to what I told you.** You worried a reviewer would look for the wrong kind of bug and read past the kind you want. The research distinguishes two things:
  - A **bar** ("only report high severity") changes what gets *reported*, not what gets found. Reviewers still find the bugs and then keep quiet about them.
  - A **focus** ("look for X") does change what gets *found*. In the gorilla study, what people were counting decided what they saw. In the 2026 preprint, a narrow instruction hid findings, and a second reviewer with an open brief recovered them.

  So your "slight push" toward certain bug types would cost the other types, and you were right to sense trouble there. What the evidence supports is separate passes: one open-ended, any focused ones separate, and a verifier that sorts the findings afterward. That's a design for the review process, which is Q6.
- **Q5.** In `safe` mode, budget never shapes the work; it's only measured afterward to look for savings. In `eco` and Let It Rip, a budget reaches a brief only after you've been asked how much it matters. When in doubt, leave it out. If an agent thinks a budget matters but can't ask you, it goes in as information. It's binding only if you approved that. Wall-clock time in Let It Rip follows the same rule. I'll also post this on "Design Let It Rip as the third mode", since it shapes that design.

---

❓ **Q1, again in concrete terms.** Everything in a brief is one of three things:

- **The job:** what's wanted, and how anyone knows it's done.
- **Fences:** things the reader may not decide, because someone else owns them.
- **Tips:** everything else the writer knows about how to do the job.

The job and the fences bind. Tips never do. Ownership decides what can be a fence:
- An agent writing a brief can pass down fences from their owners (you, AGENTS.md, the ticket).
- It can fence off what it owns itself.
- It can't turn its own opinion about how to do the job into a fence.
- You can, and you have.

How that sorts real rules in the factory:

| Rule | What it is | Binds? |
|---|---|---|
| Never push to `main` | Fence. Merging is yours. | Yes |
| The orchestrator never writes the code | A method rule you made a fence, with evidence (it was broken knowingly, and a hook now holds it) | Yes |
| The trail review is mandatory | A method rule you made a fence (it caught the owner's errors three times out of three) | Yes |
| Don't edit files another lane is writing; don't rewrite a live parent branch | Fence. Another agent owns them. | Yes |
| "Read only the diff and the brief" (old review brief) | Tip, and a bad one. A lane added it to save cost, and nobody asked for it. | No |
| `knowledge`: "never read more than 150 lines in one call" | Tip with no reason recorded | No |
| "Every finding needs a `spec:` line or it's sent back" | A bar on finishing. By Q3, it moves out of the reviewer's brief and into the step that sorts findings. | Not in the brief |

A correction: when I wrote "(c) binding needs both" last round, it contradicted the delegation row, which is a method rule and still binds. The table is what I actually mean. Ownership decides, and the job/fence/tip sort tells an agent which rules it can never invent on its own. Does the table match your intuition row by row?

➡️ Yes, as the table shows. Tell me any row you'd move.

---

❓ **Q4, with the five mechanisms listed.** These are the factory's current answers to "a rule is in my way":

1. **Ask first.** Both AGENTS.md files say: "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and nothing says how it would. In `template/AGENTS.md` this line sits two sentences after "Proceed on anything reversible."
2. **Obey, then explain.** In your note in `template/AGENTS.md:16`: "follow the file and tell me why your instinct differed." This is the reverse of #1, in the same note.
3. **Decide and record.** Where the spec is silent, the agent decides and adds a Provisional row to DECISIONS.md for you to overrule. This covers gaps, not conflicts.
4. **Skip visibly.** In poteto-mode (upstream), a step you choose not to do stays in the list as `skip: <reason>`. Delegation is the exception: `feature.md:12` forbids skipping it.
5. **Send it back up.** Writer flags must end `fixed: <sha>` or `accepted: <reason>`, or a script refuses the review. A writer that can't implement a test cell as written stops and reports it. A hole found in the design amends the ticket with a dated line. Bad acceptance criteria go back to you.

The conflicts: #1 against #2, #1 against "don't block on the human", and #4 against `feature.md`.

My proposal, in the terms of Q1:

| Situation | What happens | What it replaces |
|---|---|---|
| A tip doesn't fit | The reader does it its own way, and its report says where and why, or says it followed every tip. | #2 and #4, for tips |
| A fence fights the job | The reader doesn't cross it. It stops that part, tells the fence's owner, and carries on with the rest. In your own session that's #1: you're right there. A subagent tells whoever briefed it, which takes the question to you if the fence is yours. | #1 for subagents; generalizes #5 |
| The spec is silent | #3, unchanged | Nothing |
| Any situation | The reader never shrinks the job to fit a rule. | New |

#2 is your own words, so the plan would propose a rewording for you to approve, not change it.

➡️ Adopt the proposal.

---

❓ **Q6 - Where does the review overhaul go?** You raised several review problems:
- `spec-review` mostly looks for bugs.
- `interrogate` looks more widely, but it leads the witness too.
- Studies celebrate zero false positives while missing half the planted bugs.
- One pass isn't enough.

That's more than how reviewers are briefed. It's how review is built: how many passes, focused or open, who sorts the findings, and how recall is measured. The options:

- (a) A new ticket on this map.
- (b) Its own wayfinder map, opened later. Your words get saved on it now. This map keeps the part about wording review briefs, which "Prototype brief templates for the recurring lane jobs" already covers.
- (c) Leave it as fog on this map.

➡️ (b). Building the review process doesn't fit this map's destination, which is writing. It would also be the first big user of everything decided here, so it should come after this map, not inside it.

---

❓ **Q7 - How are fences worded and held?** The research points one way on three things:
- Emphatic wording ("NEVER", "CRITICAL") makes current Claude models apply a rule where it doesn't belong.
- A bare "don't" keeps the forbidden idea active without saying what to do instead.
- A reminder at the moment of use beats standing guidance.

Proposal: every fence is written plainly, with its reason, its owner and what to do instead. Where a hook holds a fence, the hook's refusal message carries all three, so briefs don't have to repeat it. A brief restates a hook-held fence only when the reader would otherwise waste turns walking into it. This also cuts the rule count you flagged under Q2.

The options:
- (a) The proposal above.
- (b) Restate every fence in every brief, to be safe.

➡️ (a). Your related-terms idea and the question of how many rules a reader can actually follow go to the measurement ticket as experiments, so this choice can be revisited with numbers.