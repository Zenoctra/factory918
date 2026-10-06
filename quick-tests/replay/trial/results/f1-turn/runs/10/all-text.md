I saved two memories. One holds your budget rule as you stated it. The other replaces the old "protect the world" test in my memory with the Q1 answer. I also tried to post your answers word for word as a comment on this ticket, and the post was blocked. The text is ready in my scratchpad. Do you want me to post it?

## Q1 in practice

For each rule, ask one question: **whose call is this?**

- **If the call belongs to the reader**, the brief can advise but can't order. Advice comes with its reason (your Q2 answer).
- **If the call belongs to someone else** (you, the ticket, another lane), the brief passes the rule on with its reason, and the rule binds.

Here are real factory rules sorted that way. Q6 below asks whether you'd sort them the same.

| Rule | Whose call? | Result |
|---|---|---|
| "Never push to main" | Merging is yours | Binds. The hook holds it. |
| "The orchestrator never writes the code; a lane does" (P11) | How to split the work would normally be the reader's call. You took it away on purpose, with evidence. | Binds |
| "Read nothing beyond this brief. Run nothing." (old reviewer brief) | What a reviewer reads is the reviewer's call. A lane added the rule to save cost, and nobody with authority asked for it. | Doesn't bind. At most it becomes information: "the diff changes X; Y calls it." |
| "Never read more than 150 lines in one call" (`knowledge` skill) | The reader's. No reason was recorded. | Doesn't bind. If the reason is that context fills up, it becomes information: "files here are long; the index gives line ranges." |
| "That is the scope; nothing wider is redesigned" (design-hole repair) | The scope belongs to the ticket, so it isn't the reader's call | Binds. Anything wider that the reader notices still gets reported (your Q3 answer). |
| "A finding with no `spec:` line from the ticket is sent back" | A lane designed this gate to decide what counts as a bug | A finishing rule, so it falls under Q3: report everything, filter afterward. |

## Q2: your note on dense terms

I've pinned it. When I close this ticket I'll link it to two others: "Decide what the writing standard is and what carries it" as a technique, and "Decide how we'll know the writing works" as an experiment. Your experiment design: how many rules get followed, how many rules one term carries, and which of those still need saying.

One caution for that test, from the research. A micro-genre term works because it pulls in the genre's defaults. That's exactly what you want for a style. For an open-ended search, the same pull is the pull toward where every model already looks: different models' answers to open questions were 71–82% similar. So a dense term may suit route information and fixed facts best, and may narrow an open goal.

## Q3: a correction

You wrote "if you are saying the evidence says both get found". It doesn't say that, and I should have been clearer. It shows two separate ways findings get lost:

1. **A bar on what to report loses findings the reviewer already made.** Your answer (a) fixes this: report everything, filter afterward. That's settled.
2. **What the reviewer is told to look for decides what it sees.** This is the gorilla study, and your worry is this case. A push like "we're especially wary of X" narrows attention the same way. An open brief has a blind spot too, though: models drift toward the same default places. In the one model study of this, a second reviewer with an open-ended brief recovered everything the focused one missed. So the evidence points to more than one pass with different focus. One brief can't point everywhere.

That shapes Q7 and Q8.

---

❓ **Q4 - Departures, now with the five mechanisms named.** What exists today:

1. **Say so loudly and get a sign-off before breaking the rule** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). The reader asks first. A subagent running alone can't reach you to ask.
2. **Follow the file, then tell me why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). The reader complies, then explains. It comes from your note about learning by copying professional patterns.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule** (the philosophy, [DECISIONS.md:67](docs/knowledge/core/DECISIONS.md:67)). The reader acts, then records.
4. **Skip a step visibly:** `skip: <reason>` stays in the todo list (upstream poteto-mode). Delegation is the exception, where skipping is forbidden.
5. **Disposition lines that a script checks.** Writer flags and blast-radius risks must end `fixed: <sha>` or `accepted: <reason>`, or the review is refused. A writer that can't build a cell as written stops and reports it, and never fills it in. The departure goes back into the artifact.

They conflict on timing. (1) says ask before. (2) says obey, then explain. (3) and (4) say act, then record.

Seen through Q1, they mostly cover different cases, so I'm revising my earlier "replace all five":
- (1) stays for a reader who can reach you, which means the session you're in.
- (2) stays. It's your own rule about how to treat copied patterns, so it binds by Q1.
- (3) stays. A silent spec is a gap in the goal, not a rule fighting it.
- (4) widens to every route the reader chose differently. The report always says where it departed and why, or says it didn't, stated as a fact and not as an invitation.
- (5) widens to every binding rule. When a binding rule fights the goal and the owner can't be reached, the reader stops that part, reports the conflict to the owner, and carries on with the rest.
- Every case gets one line: never shrink the goal to fit a rule.

➡️ Keep all five, each assigned to its own case as above, with (4) and (5) widened. The standard states the cases in one place, so a reader never has to choose between them.

---

❓ **Q5 - Did I get your budget rule right?**

- **`safe`:** budget never affects process. It's only measured afterward, to look for optimizations.
- **`eco`:** a budget counts only after you set one, and only after you've been asked how much priority it has over the process.
- **Let It Rip:** the same rule, with wall-clock time as a second budget. Your overall goal for the mode isn't automatically told to lanes, and it never overrides processes you require.
- **Everywhere:** when in doubt, leave the budget out of the brief. If it seems important and nobody can ask you, it goes in as information. It goes in as binding only if you approved it.

➡️ Yes as written. For this ticket, the standard carries the last line. The per-mode details belong to the map "Design Let It Rip as the third mode" and to the `eco` tier's text. I'll point both there.

---

❓ **Q6 - Does the table above match how you'd sort these?** The two rows I'm least sure of:
- **The scope rule.** It binds, but reporting what lies outside the scope stays open.
- **The delegation rule.** It binds only because you took that choice away, so a lane could never invent a rule like it.

➡️ Yes to both. If you'd sort any row differently, that tells me the test is wrong, not the row.

---

❓ **Q7 - May a brief say what the owner most cares about finding?** Under Q1, what's wanted is the owner's call, so "the bugs that matter most here are behaviour bugs, because …" states the goal. It doesn't limit the route. The gorilla evidence says it still narrows attention. The options:
- (a) Allowed when the priority is yours or the ticket's, carries its reason, and never says "only". A pass that runs focused like this always runs alongside one with an open brief.
- (b) Never in a brief. Priority is applied only at the filter step.
- (c) Allowed freely.

➡️ (a). It's honest about the goal, and the open pass covers the blind spot the focus creates. The pairing is a design decision about review, so this ticket only states the writing rule and leaves "always alongside an open pass" to Q8's answer.

---

❓ **Q8 - Where does the factory's own review system get designed?** You described a review system of our own: several passes, better briefs, `interrogate`'s wider range, and recall against planted bugs rather than celebrating zero false positives. The options:
- (a) A new map beside the other five. It's a process design (passes, verifiers, models, measurement), and this map supplies its writing rules.
- (b) A ticket on this map. The destination covers templates for recurring lane jobs, but not how many passes run or who verifies them.
- (c) Fold it into "Prototype brief templates for the recurring lane jobs".

➡️ (a). Review is most of the measured harm and most of the measured leverage, and it's bigger than writing. "Prototype brief templates for the recurring lane jobs" still drafts the review briefs here, under this ticket's rules, and the new map picks them up. Until the new map exists, I'd add a line under this map's Not yet specified, quoting you.