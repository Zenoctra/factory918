Your budget answer is already saved as a memory. Next I'll post your round-one answers word for word on the ticket, so they're kept with it the same way your earlier answers are kept on the map.

---

I couldn't post your answers to the ticket because the permission was declined, so they aren't on GitHub yet. If you want them kept with the ticket like your earlier answers, say so and I'll post them. Otherwise they go into the resolution comment when the ticket closes.

## Q1 in practice

You asked for a plainer version if you need one, and the next questions build on it. Here it is through rules the factory already has.

**The working test is who said it.** A rule binds only if it came from someone entitled to set it, and it says what's wanted or what's off-limits. Anything an agent works out for itself about how to do the job is advice. The reader may use that advice or ignore it.

| Rule | Who set it | Result |
|---|---|---|
| Never push to main | You | Binds. Merging is your call. |
| The orchestrator delegates writing code | You, after it was broken | Binds, even though it's about method, because it's yours. |
| A ticket's acceptance criteria | You approved them | Binds, as "what done means". |
| Don't edit the files lane B is editing | The orchestrator, which assigned those files | Binds. It owns that assignment. |
| Read only the diff | An orchestrator, to save tokens | Advice at most. In practice it's dropped. |
| Token burn must halve | A model turning a prediction into a requirement | Not a rule. At most information, as your budget answer says. |

The "what it's about" half of (c) exists for one reason: it stops an agent from presenting its own guess about method as a rule. Who set the rule is the main gate.

## The five mechanisms you asked about

These are the places where the factory currently says what to do when a rule gets in the way. They give different answers:

1. **Ask first.** "Say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent has nobody to ask. The rule also pulls against "never block on the human".
2. **Obey first, explain after.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. **Decide and record.** Where the spec says nothing, the agent makes the call and writes a Provisional decision you can overrule.
4. **Skip with a reason.** poteto-mode lets a step be skipped with a visible `skip: <reason>`, but never for delegation.
5. **Send it back up.** A writer that can't build a test cell as written stops and reports it. The writer's flags must end `fixed` or `accepted: <reason>`. A design hole amends the ticket. Bad criteria go back to you.

No text says which of the five applies when. One and two even disagree on whether to act before speaking up.

---

❓ **Q4 (asked again)** - **Which of these survive?** My proposal keeps two of the five and gives each a clear place:

- **When a reader leaves advice behind, it decides and records (mechanisms 3 and 4).** Every report has a line saying where the reader took a different route and why, or saying it took none. The line is always there as a fact, so it never reads as an invitation to depart.
- **When a binding rule fights the goal, the reader sends it back up (mechanism 5).** It stops that part, reports the conflict to the person or lane that owns the rule, and carries on with the rest. It never shrinks the goal to fit the rule.
- **Ask first (1) survives only in the session you're typing into,** where asking costs you a few seconds.
- **Obey first, explain after (2) is retired.** A binding rule is obeyed or sent up. Advice is used or departed from, and the departure is recorded.

➡️ Adopt that.

---

❓ **Q6** - **How are the rules that do bind written and held?** Three things point the same way:
- The research says emphatic wording ("CRITICAL", "MUST") gets over-applied by current Claude models.
- A bare "don't" keeps the forbidden idea active without saying what to do instead.
- Every added rule dilutes the others, as you noted under Q2.

Options:
- (a) Plain wording, one reason, and each rule stated once where it applies. Where a hook holds a rule, the hook's refusal message carries the reason and a way forward, and briefs don't repeat the rule.
- (b) Repeat binding rules in every brief, to be safe.

➡️ (a). The refusal arrives at the moment the rule matters, which is where the theory-of-mind study found that reminders work. Your idea about terms that carry many rules at once fits here too: one well-chosen term might replace several stated rules. That needs testing, which belongs in "Decide how we'll know the writing works".

---

❓ **Q7** - **Your worry about the wrong kind of bug.** You worried that a reviewer might chase edge cases and read past the kind of bug you actually want, and asked about a "slight push" toward the kinds that matter.

The research cuts both ways:
- Naming kinds narrows what a reader sees.
- A list also reminds readers of things they'd count but wouldn't think of. In one study, "invention of the computer" went from 1–2% of answers to 30% once it was listed.
- In the 2026 preprint, a separate reviewer with an open brief recovered every finding the focused one had hidden.

Options:
- (a) Never push inside one brief. When a kind of bug matters enough, give it its own pass, run beside an open pass that names nothing. You keep the reminder benefit without fencing in the open search.
- (b) A light "we're especially wary of X" line in the one brief.
- (c) Neither.

➡️ (a). It's the "multiple passes" you described. How many passes there are and which kinds get one is a question about how review works, which brings up Q8.

---

❓ **Q8** - **Where does the review system you described live?** No existing ticket covers it. The nearest are "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers". Both are narrow. Designing review as a whole is a process question: how many passes, what each looks for, how findings are judged, and how misses are measured (recall, not only false positives). That is bigger than the writing.

Options:
- (a) A map of its own, opened after this one, with this ticket's answers as its starting rules. On this map I'd record it under Out of scope with a link, and reviewer briefs stay here in "Prototype brief templates for the recurring lane jobs".
- (b) A ticket on this map.
- (c) A note in this map's Not yet specified.

➡️ (a). It's probably the biggest of the remaining efforts, and you called review possibly the most important step. If you agree, I'll open it once we've talked through its destination with you, not on my own.

---

**What already follows from your answers, without new questions:**
- Under Q3, the `spec:` citation gate stops deciding whether a finding gets reported. It becomes a label applied afterward, so a real bug with no ticket line to cite still gets reported.
- Under Q5, the budget rules are in memory exactly as you gave them. Safe never lets a budget shape the work. Eco and Let It Rip ask you how much a budget weighs before it reaches any brief. When in doubt, the budget stays out.