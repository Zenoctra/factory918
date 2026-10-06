I saved your answers word for word, and they'll go on the ticket when it closes. Your budget rule is already in my memory: in `safe` (the mode you called Safety Mode), a budget never shapes the process; in `eco` and Let It Rip, I ask you how binding a budget is before it goes in a brief; when in doubt, it stays out. The co-pull idea will go on the map as an open question for the writing-standard ticket and the measurement ticket.

One correction on Q3 before the next round. You asked whether the evidence says a reviewer finds both kinds of bug. It doesn't, and your worry is right. The research shows two separate things:

- **A bar on what to report** makes a reviewer hold back bugs it already found. Moving the bar to a later step fixes that.
- **A focus on what to look for** changes what the reviewer sees in the first place. The gorilla study and Shin's preprint are this case. A later step can't recover a bug that was never seen.

So a "slight push" toward one bug type is still a focus, and it would hide other types. Your own words are already in the review brief: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct" ([review-brief.sh:489](template/.agents/skills/spec-review/scripts/review-brief.sh:489)). Q8 below is about where words like those belong.

---

❓ **Q6 - Do these calls on real rules match your instinct?** This is the Q1 test applied to rules from the factory. The test has two parts:

- A rule binds when it is about the job itself: what's wanted, what done means, and what belongs to someone else.
- Only the owner of that decision can make a rule bind.

Everything else becomes information with its reason, or is removed. If any call below feels wrong to you, that tells us the test is wrong.

| Rule as written today | Call | Why |
|---|---|---|
| Never push to `main`; you merge | **Binds** | Merging is your decision. The hook already holds it. |
| The orchestrator never writes the code itself (delegation) | **Binds** | It's about method, but you set it with evidence after it was broken knowingly. It binds because it's yours. |
| `knowledge`: "Hard rule: never read more than 150 lines in one call" | **Information** | It's method, and there's no owner or reason on record. It becomes: "these files are long; reading by section keeps your context clear." |
| "Subagents never launch their own dev servers, simulators or emulators" | **Split** | The shared simulator and ports belong to everyone, so that part binds, with the reason written. How a subagent checks its own work is method, so that part is information. |
| eco: "briefs one writer, never an arena" | **Binds, but needs a reason** | You approved the eco package (P109), so it's yours. It carries no reason, though, so a reader can't tell when it fights the job. |
| Review: "an item without a `spec:` line is sent back" | **Not a rule on the reviewer** | It's a bar on what gets reported (Q3). The reviewer reports everything and fills `spec:` when it can. The later step uses the field. |

➡️ If these match your instinct, the test holds. The eco row is the case I'm least sure of. A bundle of an agent's choices that you approved together may not be the same as a rule you set on purpose.

---

❓ **Q7 - What replaces the five ways a reader can depart from a rule?** Here they are as the factory has them now:

1. **"Say so loudly and get a sign-off before breaking it."** This is in both AGENTS.md files and came from Theo. A subagent has nobody to ask. It also pulls against "don't block on the human; proceed on anything reversible."
2. **"Follow the file and tell me why your instinct differed."** This is in your voice in [template/AGENTS.md:16](template/AGENTS.md:16). It's the opposite default to #1: comply first, explain afterwards.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule.** This is in DECISIONS and PHILOSOPHY.
4. **Skip a step visibly, with `skip: <reason>`.** This comes from pstack. Feature step 4 forbids it for delegation.
5. **Hand it back up.** Writer flags end in `fixed:` or `accepted: <reason>`. A writer that can't build a cell as written stops and reports it. A design hole goes back to the ticket.

#3, #4 and #5 already work the way I'm proposing: the reader acts and the departure shows up in the record. The conflict is between #1 and #2.

➡️ One rule, of which #3, #4 and #5 are instances:
- **On method,** the reader uses its judgment, and its report always says where it departed and why, or that it didn't.
- **On a binding rule that fights the goal,** the reader stops that part, reports to the rule's owner, and carries on with the rest.
- **The goal is never shrunk** to fit a rule.

#1 and #2 are retired as written. #2 is in your voice, so it changes only if you say so.

---

❓ **Q8 - Where do your priorities about what matters go?** An example is your happy-path line in the review brief. Under Q3, the reviewer reports everything it finds. The later step ranks the findings by your priorities and decides what blocks a merge or what you see first. If you want one bug type hunted especially hard, a separate lane gets that as its whole job, and the open reviewer stays open. That's your "multiple passes", and it's what recovered the missed findings in Shin's study.

➡️ Your priorities go to the ranking step, and any special hunt goes to its own lane. Neither goes into the open reviewer's brief.

---

❓ **Q9 - Where does the review system you described go?** This map's destination is the writing. It covers review briefs through the brief-templates ticket. What you described is bigger: which passes run, what each one looks for, verifiers, how the factory measures recall against planted bugs, and replacing or reworking `interrogate`. The options:

- (a) A new map, for example "Build the factory's own review system", opened with your Q3 words verbatim. This map's decisions feed into it.
- (b) A ticket on this map.
- (c) Part of the map "Optimize token use and wall-clock time without losing reliability".

➡️ (a). It's a process redesign, not a writing decision. This map should hand it the rules for writing briefs, not try to hold the whole review system.

---

One question is held for the next round: how binding rules are worded and enforced. One option is a hook's refusal message that arrives with the reason at the moment the rule matters, instead of the rule repeated in every brief. It depends on which rules turn out to bind, which is what Q6 settles.