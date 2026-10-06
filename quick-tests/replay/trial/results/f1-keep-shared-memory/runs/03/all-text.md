Before round two, a note on saving your answers. I tried to post them word for word as a comment on "Decide how the writing treats rules that bound how a task is pursued", the way the map keeps your earlier answers. The post was declined, so I didn't retry. They're saved in my scratchpad for now, which won't outlast this session. Should I post them? The budget rule from your Q5 answer is already in my memory.

## What's settled

- **Q2: (b).** What the writer knows about the route goes in as a resource with its reason. Context goes in freely; method goes in only when it carries a lesson the reader couldn't easily find. Your point about rule count gets pinned for every decision on this map. So does the dense-term idea: one well-chosen word that carries most of a cluster of rules, plus only what that word wouldn't carry. Both need an experiment before anything rests on them.
- **Q3: (a).** On your worry, the evidence doesn't say one open reviewer finds every kind of bug. It shows two separate effects:
  - a bar ("only high severity") makes a reviewer hold back what it found;
  - a focus ("look especially for X") makes it miss what it wasn't told to look for. That's the gorilla study.

  A "slight push" toward certain bugs is a focus, so it carries the second effect. Your worry about a reviewer drifting to the wrong kind of bug on its own is real too: models drift to the same defaults as each other. The research's answer is the one you reached: several independent passes, each with an open brief, rather than one pass with a push. That design belongs to the review system you described, not to this ticket.
- **Q5: your answer, as you gave it.** In `safe`, a budget never shapes process; it's only measured afterwards. In `eco` and Let It Rip, a budget you set is interviewed first to find out how much it weighs against your other goals. When in doubt, it's left out. If it seems important and nobody can ask you, it goes in as information. It's written as binding only when you approved that.

Two ideas from your answers don't fit this ticket. I'd add both to the map's "Not yet specified" section:
- a review system of the factory's own, which may turn out to be its own map;
- the dense-term experiment.

Should I add them?

---

❓ **Q6 - Do these cases match what you meant by (c)?** Here is (c) in plain terms. How to do the job is the reader's call by default. A piece of "how" becomes an order only when whoever owns that call takes it back on purpose, with a reason. You own how the factory runs, so you can do that. An orchestrator writing a brief doesn't own the reader's route, so its guesses about the route can't become orders. It can only bind what it owns itself.

Real rules from the factory, sorted under (c). They illustrate the test; they don't mark its edge.

| Rule | Who set it | Under (c) |
|---|---|---|
| Never push to `main` | You | **Binds.** Merging is your call. |
| The orchestrator never writes the code itself | You, after an agent broke it knowingly; a hook holds it | **Binds.** You took that piece of "how" back on purpose. |
| Every ticket runs the trail review | You, after it caught the owner's errors 3 times out of 3 | **Binds.** Same reason. |
| Don't edit this file, another lane is writing it | The orchestrator, which owns who works where | **Binds.** It isn't the reader's to decide. |
| A reviewer may "read nothing beyond this brief" | A lane, to save tokens, unasked | **Doesn't bind.** At most "the change is in these files", given as information. |
| `knowledge`: never read more than 150 lines in one call | Nobody recorded, no reason given | **Doesn't bind.** It becomes advice with a reason, or it goes. |
| Cite a `spec:` line or the bug isn't hard | A lane, in the review script | **Goes**, under Q3: it's a bar on reporting. |
| Subagents never start their own dev servers | Theo, adopted without his reason | **Split.** Not stopping other agents' running servers binds, because those servers are theirs. The rest is advice. |

➡️ These are the verdicts I'd defend. Mark any you'd call differently. Each one you change sharpens the test.

---

❓ **Q4 - One way to depart from a rule, in place of five.** Here are the five the factory has now:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "say so loudly and get a sign-off before breaking it." This works when you're in the conversation. A subagent has nobody to ask, and no text says what it does instead.
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16), in your own note: "follow the file and tell me why your instinct differed." This is the opposite of 1.
3. **Decide and record.** Where the spec is silent, the agent makes the call and writes a Provisional row in DECISIONS that you can overrule.
4. **Skip visibly.** In poteto-mode, which is upstream, a step not done stays in the list as `skip: <reason>`. Delegation is the exception: it forbids skipping.
5. **Stop and send it back.** A writer that can't implement a test as written stops and reports it. Writer flags must end `fixed:` or `accepted:`. A design hole is written into the ticket. Criteria that can't be tested go back to you.

They disagree on the basic question: when a rule and the task clash, does the agent ask, obey, or decide?

➡️ Proposal:
- **For advice about the route:** the reader decides. Its report always says where it went its own way and why, or says it didn't. This is 3 and 4 merged and applied everywhere.
- **For a binding rule that fights the goal:** if you're in the conversation, ask you (that's 1). Running unattended, stop that part, report it to the rule's owner, and carry on with the rest (that's 5).
- **Mechanism 2 goes.** Under (c), a binding rule is obeyed anyway, and advice shouldn't be obeyed against the task. It's your note, so removing it is your call.
- **The reader never shrinks the goal to fit a rule.**

---

❓ **Q7 - How binding rules are worded and held.** Now that the binding rules are few, the question is how they reach the reader. The research says three things:
- Plain wording works better than emphatic wording: current Claude models over-apply "CRITICAL" and "MUST".
- A rule with its reason gets applied more sensibly.
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead. The git guard already does better: its refusal message names a way forward.

Options:
- (a) Each binding rule is stated once, in plain words, with its reason and what to do instead. Where a hook can hold it, the hook's refusal message carries the reason and the way forward, arriving at the moment it matters, and briefs don't restate it.
- (b) As (a), but every brief also restates the binding rules that apply.
- (c) Decide rule by rule.

➡️ (a). Restating every rule in every brief adds to the rule count you just pinned. A refusal message that arrives when the rule is about to be broken is the "reminder at the moment of use" that worked in the theory-of-mind studies. One caveat: this rests on vendor guidance and on studies of older models, so it's another candidate for the map's ticket "Decide how we'll know the writing works".