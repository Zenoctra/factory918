I tried to post your answers word for word as a comment on the ticket so they're saved now and not only at the end. That was declined, so nothing is posted yet. Unless you want them posted sooner, they'll go into the closing comment on the ticket, word for word.

Before the next round, two of my earlier statements need correcting.

**On Q3, the evidence does not say both kinds of bug get found.** It says two separate things:
- **A bar on what to report changes what gets said, not what gets found.** Your choice (a) handles this: report everything, filter afterward.
- **What the reviewer is told to look for changes what it finds.** That's the gorilla study, and Shin's preprint shows it in models. Saying nothing isn't neutral either. Different models give answers that are 71–82% alike, so a reviewer with no focus falls back on the same defaults as every other model, and those defaults may be the input edge cases you're worried about.

So your worry is real, and (a) alone doesn't fix it. Q7 below takes it up.

**On Q4, I said whatever you picked would replace all five mechanisms.** That was too strong. Q9 lists all five and shows what would actually change.

### Q1 in practice

When an agent writes instructions for another agent, it asks two questions about each rule:

1. **Who said this must happen?** If you said it, in AGENTS.md, a ticket you approved, DECISIONS.md, or this conversation, it can bind. If the agent thought of it itself, it never binds. It goes in as "here's what I know, and why", and the reader may do otherwise.
2. **Is it about how the work gets done?** This is the question you ask when you make a rule binding. Rules about what's wanted, what done means, or who decides something are natural to make binding. A rule about how the work gets done needs evidence that agents' own judgment fails there.

Some real rules run through both questions:

| Rule | Who said it | What it's about | Result |
|---|---|---|---|
| Never push to main | You | Who decides (you merge) | Binds |
| The orchestrator never writes the code | You | How, with evidence: an agent broke it knowingly, so a hook now holds it | Binds |
| Run the trail review every time | You | How, with evidence: it caught the owner's errors 3 times out of 3 | Binds |
| Reviewer reads only the diff | An agent, to save tokens | How | Never binds. At most it's a fact the reader can use |
| Only report high-severity bugs | An agent | What done means | Never binds, and Q3 already moves bars out of the brief |

### Notes from this round

- **Your point about a single microgenre term (Q2).** One word that pulls in many rules at once could replace a long list of rules, but it has to be tested. It belongs with two later tickets: "Decide how we'll know the writing works" for the experiment, and "Decide what the writing standard is and what carries it" for how it gets used.
- **Q5.** The first mode is called `safe`. Your answer is recorded as you gave it:
  - In `safe`, a budget never shapes how the work is done. It is only measured afterward.
  - In `eco` and Let It Rip, a token budget, and in Let It Rip also wall-clock time, is put to you first to find out how much it should bind.
  - When in doubt, the budget isn't mentioned at all.
  - If an agent thinks it matters but can't ask, it goes in as information.
  - It binds only with your approval.

---

❓ **Q6 - Is the table above what you picked in Q1?** The second question is guidance for whoever makes a rule binding, mostly you. The first question is the one every brief-writing agent applies.

➡️ Yes, if the table matches your intent. If any row lands wrong, that row is where we slow down.

---

❓ **Q7 - How does "we're especially wary of X" reach a reviewer?** This is your Q3 worry. In Shin's study, a reviewer told to focus on one thing missed critical findings outside that focus, and a second reviewer with an open brief recovered every one of them. The options:
- (a) Never put a focus in a brief. Coverage comes from running several reviewers and from a verifier that sorts what they find.
- (b) Put the focus in the single open brief as information with its reason, for example: "this touches money handling; the last two bugs here were rounding errors."
- (c) A focus may go to a reviewer of its own. There is always at least one reviewer with no focus at all, and a focus never goes into that reviewer's brief.

➡️ (c), with the focus worded as in (b). For this ticket the rule is that a focus is never the only lens. How many reviewers run, and which ones, is for Q8.

---

❓ **Q8 - Where does your own review system get designed?** You described it in Q3:
- several passes;
- better briefs;
- spec-review looks mostly for bugs, while interrogate covers a wider range, including security, but leads the witness;
- recall on planted bugs as the honest measure.

That's bigger than how things are written: it covers how many passes run, who verifies, and what spec-review and interrogate become. The options:
- (a) A sixth wayfinder map of its own, built on this map's decisions.
- (b) A ticket on this map.
- (c) Fold it into the ticket "Prototype brief templates for the recurring lane jobs".

➡️ (a). This map's destination is writing, and a review system would stretch it. The review map would start with your Q3 words quoted in full, and its measuring would share the planted-bug idea with "Decide how we'll know the writing works".

---

❓ **Q9 - The five ways an agent may currently depart from a rule, and what to do with them.**

1. **Say so loudly and get a sign-off before breaking it.** This is in [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20), which says "These are good defaults, not hard rules", and it was taken from Theo. It works when you're in the conversation. A subagent has nobody to ask, and no text says how it would.
2. **Follow the file first, then tell me why your instinct differed.** This comes from your note at [template/AGENTS.md:16](template/AGENTS.md:16). It's the opposite default to #1: comply first. Its purpose is learning from where instinct differs.
3. **Where the spec says nothing, decide, and record a Provisional decision you can overrule** ([PHILOSOPHY.md:55](docs/knowledge/core/PHILOSOPHY.md:55)). This covers silence, not conflict.
4. **A playbook step you skip stays in the list as `skip: <reason>`.** This is upstream pstack ([poteto-mode SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113)). Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) allows no skip there.
5. **Stop and send it back up.**
   - Writer flags must end `fixed:` or `accepted: <reason>` before review can start.
   - A writer that can't build a test as written stops and reports it.
   - A hole in the design gets a dated line added to the ticket.

What the proposal does to each:
- **#1 becomes the rule for binding rules.** The reader stops that part and reports to whoever gave it the rule, who passes it up to you. It carries on with the rest and never shrinks the goal to fit.
- **#2 is the real change.** For anything not marked binding, the reader uses its own judgment and reports where it departed and why. It doesn't follow first. The report keeps the learning your note was after. Your files would say which of their rules bind, so "good defaults, not hard rules" stops contradicting "follow the file".
- **#3, #4 and #5 stay.** They already fit: #3 covers a different case, #4 is the departure report in a playbook's form, and #5 is stop-and-report.

The options:
- (a) Take all of the above.
- (b) The same, but keep #2's "follow first" for your own files, and use judge-and-report only for what agents write to each other.

➡️ (a). "Follow first" is the one place the factory tells a capable reader to set its judgment aside before it knows whether the rule fits. The reason you gave for it still holds through the report.

---

❓ **Q10 - Does your Q5 rule cover any predicted number, not just budgets?** Your example wasn't really a budget. "Might cut token burn in half" was a prediction that an agent turned into a requirement for closing the ticket. The same thing happened with the "at most N lanes" list ruled on in decision P109. The options:
- (a) Any number an agent didn't get from you (a predicted saving, a count, a cap, a threshold) is information. It becomes a condition for closing only after you've been asked how much it matters.
- (b) Only budgets.

➡️ (a). It's the same failure: a guess hardens into a requirement, and the work gets bent to meet it.

---

After this round, the remaining questions are how binding rules should be worded and held, and whether a hook's refusal message, which arrives at the moment of use, does more than repeating the rule in every brief. Then we test all the answers against real cases, including the `spec:` gate.