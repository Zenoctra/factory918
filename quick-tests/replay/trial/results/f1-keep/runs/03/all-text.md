Posting your answers to the ticket was blocked, so I haven't posted anything. I've saved them word for word in my scratchpad and will put them on the ticket with the resolution. If you'd like them posted sooner, say so.

## Q1 again, in practice

Think of hiring a contractor through a foreman.

- **Binding:** what you want built, and anything that isn't the crew's call. You approve the final inspection. The neighbour owns the shared wall. The city issues the permits.
- **Not binding:** which tools to use and in what order. If the foreman adds "use hand saws only" on his own, that's his advice, not your rule.

The test asks two things about a rule:
1. Is it about what to deliver, or about who gets to decide something?
2. Did the person who owns that decision set it?

If both are yes, the reader can't break it. Otherwise it's advice with a reason: the reader may take another route and says so in its report.

Here are factory rules run through the test:

| Rule | About | Set by | Result |
|---|---|---|---|
| Never push to main | who merges (you) | you | binds |
| The orchestrator never writes the code | who does which job | you | binds |
| Don't edit files another subagent is working on | who owns those files right now | the orchestrator, which made the assignment | binds |
| Read only the diff | how the reviewer works | the orchestrator | goes; the reviewer needs to follow side effects |
| Read knowledge files 150 lines at a time | how to read | nobody recorded why | goes, or becomes advice with a reason |
| Run the tests before handing back | how to work | (rewrite it) | becomes the goal: "done means the tests pass" |
| Cite a `spec:` line or it isn't a bug | when to report | the orchestrator | moves to the filter step (your Q3) |

The last two rows show the most common move: the rule doesn't vanish, it gets restated as what done means.

## On your other answers

**Q2.** I'll pin your micro-genre point: one well-chosen term can carry many rules at once. It belongs with "Decide how we'll know the writing works" as an experiment. How many rules does a model actually follow? Does one dense term carry several rules? Which ones still need stating on their own? It also goes to "Decide what the writing standard is and what carries it" as a principle. I'll add pointers to both when I close this ticket.

**Q3.** Your worry about focus is right, and I overstated the evidence. The "it still gets found" result applies to report bars: a reader told "only report severe ones" still finds the rest and leaves them out. Focus is different. In the gorilla study, what the observers were told to count decided what they saw. So the "slight push toward certain bug types" you considered is exactly what hides the other types. That makes it a question of its own, Q8 below.

**Q5.** Settled as you said. In `safe` (that's the tier's name), budget never touches the process, and it's measured only afterward. In `eco` and Let It Rip, a budget exists only if you set it. You're asked how binding it is before it goes into any brief. When in doubt, it isn't mentioned at all. If it's mentioned without asking you, it's information, not a limit, and a binding budget needs your approval. Wall-clock time is a second budget in Let It Rip, under the same rule. Your example of a guessed "cuts token use in half" becoming a requirement to close the ticket is the same failure as the "at most" list on the eco ticket. I'll pass this to the map "Design Let It Rip as the third mode" as well.

---

❓ **Q6 - Does the table sort correctly?** Is there a rule in it that you'd put in a different row? Or is there a rule you know of that the test would get wrong?

➡️ I think it sorts correctly. The row most worth checking is "Don't edit files another subagent is working on". It lets the orchestrator make a binding rule, but only about something it actually controls.

---

❓ **Q4, again - the five ways the factory currently handles a rule that fights the task:**

1. **Say so loudly and get a sign-off before breaking it** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). It only works when a person is there to sign off. A subagent has nobody to ask, and no text says what it should do instead.
2. **Follow the file, then explain why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default: obey first, explain afterward.
3. **Make the call and record it as a Provisional decision you can overrule.** This applies where the spec says nothing (`DECISIONS.md`, the Ticket playbook).
4. **Skip a step visibly, with `skip: <reason>`** (poteto-mode). Delegation is the exception, where skipping is forbidden.
5. **Send it back up to the person or the artifact.** A writer that can't build a table cell as written stops and reports it. Writer flags must end `fixed:` or `accepted: <reason>`. A design hole amends the ticket with a dated line.

They give conflicting answers to the same situation. Mechanism 1 says ask first, 2 says obey first, 3 and 4 say decide and record it. My proposal keeps what 3, 4 and 5 already do well:

- **Advice about the route:** the reader uses its own judgment. Its report always says where it took a different route and why, or that it took none.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest. This is 5, extended to every binding rule.
- **Never:** quietly shrinking the goal to fit a rule.

Mechanisms 1 and 2 would be replaced. Mechanism 1 stays only for the person-in-the-loop conversation, where a sign-off is actually possible.

➡️ Adopt it.

---

❓ **Q7 - How are the binding rules worded and enforced?** The research says three things. Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule. A rule with its reason is followed better and more sensibly. A bare "don't" keeps the forbidden idea active without saying what to do instead. The factory already has a fourth option: a hook that refuses at the moment of the action, gives the reason, and names a way forward. The git guard does this.

The options:
- (a) Binding rules are stated plainly, once, with their reason. Where a hook can hold a rule, the hook's refusal message carries the reason and the way forward, and briefs don't restate it.
- (b) Briefs restate every binding rule, for safety.

➡️ (a). Repeating a rule in every brief adds to the rule count you flagged in Q2. Repeated text also gets read as boilerplate.

---

❓ **Q8 - What if you want a particular kind of problem found?** Security bugs are an example. A push in the brief toward them is a focus, and focus hides other kinds of problem. The options:
- (a) Never push. Rely on open passes and on the verifier sorting what they find.
- (b) Give that kind its own dedicated reader, always alongside a reader with an open brief, never in place of one. In the 2026 preprint, a narrow pass missed critical findings and the open pass recovered them.
- (c) Add a light push to the open brief.

➡️ (b). (c) is the headache you predicted.

---

❓ **Q9 - Where does designing the review system go?** That means multiple passes, measuring how many known bugs a review catches rather than just its false alarms, and replacing interrogate's leading. This map already covers how review briefs are written, under "Prototype brief templates for the recurring lane jobs". The process itself is a bigger design than this map's destination, which is about the writing. The options:
- (a) Its own map, opened after this one, built on this map's decisions.
- (b) A fog item on this map.
- (c) Fold it into the brief-templates ticket.

➡️ (a). Meanwhile I'd list it under this map's Out of scope with a pointer, so it doesn't get lost.