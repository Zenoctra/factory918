I've recorded your answers to Q2, Q3 and Q5. I also saved your budget rule as a memory, so it applies outside this map too: in `safe` (the first mode's real name), budget never shapes process. In `eco` and Let It Rip, a budget binds only after you've said how much it matters. When in doubt, it stays out of the brief.

I tried to post your answers word for word on the ticket, as we did for the charting rounds, and that post was declined. Do you want it posted? I'd also like to pin your micro-genre point in the map's "Not yet specified" section as an experiment for the ticket "Decide how we'll know the writing works". That experiment would test whether one dense term carries several rules at once, how many rules a model actually follows, and when a rule still needs its own sentence. Nothing on GitHub has changed yet.

## Q1 again, in plain terms

The test comes down to two questions about any rule in a brief:

1. **Whose call is this?**
2. **If it's not the reader's call, did the person whose call it is actually make it?**

If it's the reader's call, the rule turns into advice with its reason, and the reader may do otherwise as long as it says so. If it's someone else's call and they made it, the rule binds. Here is the test run on real rules:

| Rule | Whose call | Verdict |
|---|---|---|
| Never push to `main` | Yours: you merge | Binds. You made it. |
| The orchestrator never writes the code | Yours: how the factory splits work | Binds. You made it, with evidence. |
| `eco` runs no writer arena | Yours: how much ceremony a tier pays (P109) | Binds, and should state its reason. |
| "Don't edit `src/auth`, another lane is in it" | The orchestrator's: it assigns the lanes | Binds, with the reason. |
| "Read only the diff" (an old reviewer brief) | The reviewer's: how it looks for bugs | Doesn't bind. It becomes "the change is in these files." |
| The `knowledge` skill's "never read more than 150 lines in one call" | The reader's, and no reason is recorded | Doesn't bind. It becomes a fact ("files here are long; the lookup finds the section") or it goes. |
| "Subagents never launch their own dev servers" | Half and half | The part that protects other lanes' running servers binds. How the subagent checks its own work is its call. |
| "Cite a `spec:` line or it isn't a bug" | A rule about finishing | Covered by your Q3 answer: it moves to the filter step. |

If those verdicts match what you'd say, you've got the test. If any row looks wrong to you, that row is the part to dig into.

## Your Q3 worry

The evidence doesn't say one reviewer reliably finds both kinds of bug. It splits into two parts:

- **Q3's answer fixes one failure: the reviewer finds a bug and doesn't report it** because it falls under a bar. Radiologists did this, and so did Opus 4.8.
- **Your worry is a different failure: the reviewer never finds the bug**, because its attention went elsewhere. That one is real too (the gorilla study, and Shin's 2026 preprint).
  - A "slight push" toward a bug type is the gorilla instruction itself: telling a reader what to look for also tells it what not to see.
  - What recovered the missed findings in Shin's study was a second reader with an open-ended brief.

So the answer to your worry is in how review is set up, not in what a brief says: more than one reader, at least one with an open brief. That leads to Q7.

---

❓ **Q4 - Which way of departing from a rule replaces the five?** Here are the five the factory has now:

1. **Say so loudly and get a sign-off before breaking the rule** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)).
   - It works when you're in the conversation.
   - A subagent has nobody to sign off, and no text says what it should do instead.
   - It also pulls against "never block on the human on reversible work".
2. **Follow the file, then tell me why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default to 1: obey first, report afterward.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule** (PHILOSOPHY, DECISIONS, the Ticket playbook). This covers gaps, not conflicts.
4. **Skip a step with a visible `skip: <reason>` line** (poteto-mode, upstream).
   - It applies to steps of a playbook.
   - [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) bans it for delegation.
5. **Hand the problem back up instead of working around it.**
   - A writer flag has to end `fixed:` or `accepted: <reason>`.
   - A writer that can't implement a table cell stops and reports the cell.
   - A design hole amends the ticket with a dated line.

I'd make it one rule with two cases:

- **The reader goes against advice about the route:** it uses its own judgment, and its report says where it went its own way and why, or says it didn't. This absorbs 2 and 4.
- **A binding rule fights the goal:** the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest. It never shrinks the goal to fit the rule.
  - When the owner is right there in the conversation, that report *is* asking for sign-off. So 1 becomes the live case of this rule, not a separate mechanism.
  - 5 is already this rule, applied to the review scripts.

3 stays as it is, because it covers silence, not conflict.

➡️ Adopt that. Delegation keeps its ban on skipping, because it binds: you made it.

---

❓ **Q6 - How does a binding rule read?** This round is only about wording. Where rules live and when they reach the writer belongs to the ticket "Decide where each piece lives and when it reaches the writer". The research points one way:

- Emphatic wording ("NEVER", "CRITICAL") makes current Claude over-apply the rule.
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- A reason lets the model handle the case the writer didn't foresee.

Your Q2 point applies here too: every rule restated in a brief takes attention from the others.

The options:
- (a) A binding rule says what it is, why, and what to do instead, in plain words. A rule a hook already enforces isn't repeated in briefs; the hook's refusal message carries the reason and a way forward (the git guard already says "Use --force-with-lease on your own branch, or ask").
- (b) Restate binding rules everywhere they could matter, to be safe.

➡️ (a).

---

❓ **Q7 - Is the review system its own map?** Your own data backs the 50% point. On #103, the best reviewer found 7 to 9 of 16 planted bugs. Two pooled Opus 5 runs reached about 0.50, and P103 concluded that "a second reviewer run buys more recall than any Claude model change". Designing review means deciding:

- how many readers there are, and with what briefs;
- what verifies their findings;
- recall measured against planted bugs;
- what to do about `interrogate` leading its reviewers.

That's a process design, bigger than writing.

The options:
- (a) This map covers how review briefs are written. The review system becomes its own map, opened now with your Q3 words in full so they aren't lost.
- (b) Fold the whole review system into this map.
- (c) Leave it as fog here until the rework ticket reaches review briefs.

➡️ (a), sequenced after this map's writing standard exists, since every review brief will be written to it.