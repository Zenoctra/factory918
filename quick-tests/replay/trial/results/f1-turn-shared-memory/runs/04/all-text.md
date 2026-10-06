I couldn't post your answers to the ticket because the comment was declined. The draft is saved and I'll come back to it. Now I'm writing two memory notes, then round two.

---

I've saved two memory notes:

- **Budgets:** your Q5 rule. Another session had already written a near-identical note at the same moment, so I kept that one and deleted mine.
- **The binding test:** the old note still had the "protect the world" wording, so I rewrote it to the test you picked in Q1.

I tried to post your answers on the ticket word for word, the way the map does it, but the comment was declined. The draft is at `round1.md` in my scratchpad. Should I post it, or would you rather post it yourself?

## What I took from your answers

**Q2, one rich term instead of many rules.** The research has a close parallel. Examples of foods that people would think of anyway barely moved their answers; unusual examples moved them most. That matches your method: name the micro-genre, then add only what the genre wouldn't carry. The risk is that a dense term pulls in everything it carries, including what you didn't want. It's the same pull as a list, in fewer words. So your experiment should measure both what a term brings in and what it pushes out. That belongs in the ticket "Decide how we'll know the writing works", and I'll add it to that ticket when I close this one.

**Q3, your worry is right, and I overstated the evidence.** The evidence shows that a bar hides findings the reader already made. It does not show that an open reviewer looks at every kind of bug equally. The gorilla study shows the opposite: whatever you point a reader at is what it sees. People counting the black team's passes noticed the black gorilla 58% of the time. People counting the white team's passes noticed it 27% of the time. So your "slight push" would work, for the kind of bug you push toward, at a cost to every other kind. The fix the research points to is a second pass. In the one study that tested this on models, a separate reviewer with an open brief recovered everything the narrow one had missed. Q7 below picks this up.

**Q5** is recorded as you said it. For reference, the first tier is called `safe`.

## Q1 in plain terms

You can put the test as one question: **could the reader point to who decided this rule, and is the rule about the job rather than the way of doing it?**

In practice that comes to two points:
- **Binding rules come from you:** you directly, a ticket you approved, the AGENTS.md you own, or a rule that protects another lane's files.
- **Everything else is advice.** That covers whatever the writing agent adds on its own about how to do the work. Advice comes with its reason, and the reader may use its own judgment instead.

You can still make part of the way of working binding, but only you can. When you do, it becomes part of the job. Q6 runs real rules through this test so you can see whether it sorts them the way you would.

---

❓ **Q6 - Does the test sort these real rules the way you would?**

1. **"Never push to main."** You decide what merges. *Binds.* A hook already enforces it.
2. **"The orchestrator never writes the code inside a playbook."** This is about the way of working, but you made it part of the job on purpose, with evidence. An agent broke it while knowing the rule, and now a hook holds it. *Binds,* because you decided it, not because of what it's about.
3. **"Never read more than 150 lines in one call"** (the `knowledge` skill). A model wrote this, and nothing records why 150. *It becomes advice:* "files here are split into sections with line numbers in a table of contents, so read the section you need". Or it goes.
4. **"Subagents never launch their own dev servers"** (your template AGENTS.md). This is the hard case. It's in your file, so by the test it binds. But its reason was lost when it was copied from Theo's file. Your own note in the same file also says "These are good defaults, not hard rules", so I can't tell whether you meant it as a rule or as a default you'd let an agent break. *Binds only if you say so, and it needs its reason back either way.*
5. **"A review finding without a `spec:` line is sent back."** This is a bar on what gets reported, so Q3 covers it. *It moves out of the reviewer's brief:* the reviewer reports everything, and the filter step after it does the sorting.

➡️ My calls are the ones above. I'd like your call on case 4. That file's rules may fall into two groups, the ones you mean as rules and the ones you mean as defaults, and the standard would need to mark which is which.

---

❓ **Q7 - What does this ticket decide about review, and where does the rest go?** You said review may be the most important step and the one that needs the most work. I agree it's bigger than this ticket. The options:
- (a) **This ticket sets the principle; review gets its own map.** The principle: when you especially care about one kind of problem, it gets its own pass with its own brief, never a push or a list inside a general reviewer's brief. Measuring review by how many planted bugs it catches, as well as by false positives, belongs to the new map. So do the redesign of `spec-review` and `interrogate`, and the leading in `interrogate` that you noticed. That map is charted after this one, because it depends on the writing standard.
- (b) Design the review passes here.
- (c) Put review in this map's "Not yet specified" list and decide later.

➡️ (a). Your "misses 50% of planted bugs" point is the research's own recommendation: judge a reviewer by recall, meaning the share of known bugs it finds. Doing that properly is a whole effort. This ticket only needs the principle, so the new map doesn't inherit the push-in-the-brief habit.

---

❓ **Q4 again - what happens when the reader goes another way, or a rule fights the goal?** These are the five mechanisms the factory has now:

1. **Ask first.** "If a rule fights the task, say so loudly and get a sign-off before breaking it." This is in both AGENTS.md files. A subagent has nobody to ask, and the rule pulls against "never block on the human."
2. **Obey, then explain.** "Follow the file and tell me why your instinct differed." This is in your note in the template AGENTS.md.
3. **Decide and record.** Where the spec says nothing, the agent decides and writes a Provisional entry in DECISIONS.md so you can overrule it.
4. **Skip with a visible reason.** In poteto-mode's step list, a skipped step stays listed with `skip: <reason>`. Delegation can't be skipped this way.
5. **Send it back up.** Examples:
   - A writer's flags must each end as `fixed` or `accepted: <reason>`.
   - A writer that can't build a test case as written stops and reports, and never fills it in.
   - A gap in the design gets written into the ticket.

They conflict in two ways. 1 says ask before breaking a rule, while 2 says obey first and explain afterwards. And 1 assumes someone is there to ask.

➡️ Keep 2, 3 and 5 as they are; they don't conflict once binding rules are told apart from advice. Change 1 and 4:
- **Advice the reader didn't follow:** the reader uses its own judgment, and its report always has a line saying where it went another way and why, or "none". This replaces `skip:` and covers every brief, not only poteto-mode's steps.
- **A binding rule that fights the goal:**
  - In your own session, 1 stays, because you're there to sign off.
  - In a subagent, it stops that part, reports the conflict to whoever owns the rule, and carries on with the rest.
- **Either way, the reader never shrinks the goal to fit a rule.**

---

Next round covers how binding rules are worded and enforced: plain wording with the reason, versus a hook whose refusal message carries the reason when the agent actually hits the rule.