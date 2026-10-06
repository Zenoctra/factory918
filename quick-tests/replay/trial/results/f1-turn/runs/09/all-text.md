I've answered your questions on the round, and round two starts below. Two housekeeping items first:

- **Your answers aren't on the ticket yet.** I tried to post them word for word as a comment on "Decide how the writing treats rules that bound how a task is pursued", following your standing request that your notes get saved. The post was blocked. The draft is ready at `scratchpad/round1.md`. Should I post it?
- **I saved your budget answer to memory**, so it carries into other sessions.

## On your answers

**Q2, terms that pull many rules at once.** Your microgenre idea runs on the same force as leading the witness. A term that pulls in ten rules also pulls in whatever else sits near it. So it's the cheapest lever we have, and also a way to lead the reader without noticing. That's a good reason to run the experiment you describe: how many rules get followed, and whether one term carries several of them. I'll put it on "Decide how we'll know the writing works".

**Q3, your worry.** I need to correct what I implied: the evidence does not say both kinds of bug get found.
- A reporting bar mostly changes what gets reported. The reviewer still finds the bug and then leaves it out. Moving the bar to a later step fixes that.
- Focus changes what gets seen. That's the gorilla result. Your "slight push toward the bugs we're most wary of" is that kind of focus, so it would cost us the bugs outside the push.

What fixed it in the one model study was structure, not wording: a second reviewer with an open-ended brief recovered everything the focused one missed. That points at more than one review pass, which is your review-system point. Q8 below asks where that work should live.

**Q5.** I've recorded it this way:
- In `safe`, budget never shapes process. It's only measured afterward.
- In `eco` (tokens) and Let It Rip (tokens and wall clock), a budget reaches a brief only after you've been asked how much it weighs.
- When in doubt, leave it out.
- If it can't wait for an answer, it goes in as information, never as a rule.
- Anything passed on as binding is something you approved.

## Q1, more slowly, with a correction

Ask two questions of any rule: who wrote it, and is the thing it controls theirs?

- **You can make any rule bind**, whether it's about what the job is or about how to do it. Two of your rules are about how: the orchestrator never writes the code, and the trail review is mandatory. They still bind, because you set them and you had a reason.
- **An agent writing a brief or a template owns only the job it hands out.** That covers what's wanted, what done means, and which files other subagents hold right now. It owns nothing about how the reader works. So anything it says about how is advice with a reason, never a rule.

The correction: last round I said a rule needs both conditions. The delegation rule breaks that: it's about how the work is done, and it binds anyway. The version above is the one I mean.

## Round two

❓ **Q4 again, with the five listed.** These are what a reader is told today when a rule fights the task:

1. **Ask first.** "Say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent has nobody to ask.
2. **Obey first, explain after.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. **Skip it in the open.** poteto-mode lets a step stay in the list marked `skip: <reason>`. The delegation step is the exception: it can't be skipped.
4. **Fill the gap and record it.** Where the spec says nothing, the agent decides and logs a Provisional decision you can overrule.
5. **Hand it back.**
   - A writer's flag must end `fixed` or `accepted: <reason>` before review.
   - A writer that can't build a test case as written stops and reports it.
   - A hole found in a design is written back onto the ticket.

They conflict: on the same rule, 1 says stop and ask, 2 says comply, 3 says skip it and say so.

➡️ My proposal maps onto them like this:
- **Advice on how to work:** the reader uses its judgment, and its report always says where it went its own way and why. That's 3, widened to every report.
- **A binding rule that fights the goal:** the reader stops that part, hands it back to the rule's owner, and carries on with the rest. That's 5. In the main session the owner is you and you're reachable, so there it reads as 1.
- **2 goes.**
- **4 stays**, because it covers gaps, not conflicts.

---

❓ **Q6 - Does the test give the answer your gut gives?** Here it is applied to six real rules. Where a verdict feels wrong, the test is wrong.

| Rule | Who set it | What it controls | Verdict |
|---|---|---|---|
| Never push to main; never merge | You | Merging, which is yours | Binds. A hook already holds it. |
| The orchestrator never writes the code | You (#74), with evidence | How the work is done | Binds, because it's yours |
| Subagents never start their own dev servers ([template/AGENTS.md:68](template/AGENTS.md:68)) | Taken from Theo's AGENTS.md; his reason was dropped | A machine other subagents share | Binds if you confirm it, with the reason put back |
| Never read more than 150 lines at once (`knowledge` skill) | An agent; no reason recorded | How the reader reads | Advice at most; probably deleted |
| A bug counts only if it cites a `spec:` line (`review-brief.sh`) | Not traced yet | How the review is finished | Goes, per your Q3 answer: everything is reported, and the citation becomes a field the filter step uses |
| "Execute only the task and path scope the parent assigns" (pstack wrapper, vendored) | Upstream | Both | Splits: other subagents' files bind; "only the task" doesn't. It needs a patch, since it's vendored. |

➡️ I'd confirm all six. Tell me any row that feels wrong.

---

❓ **Q7 - Does merging a PR make its rules yours?** The run-2 audit found that subagents added reading caps to the review brief to save cost, in #33, #93 and #107. Nobody asked for them, and you merged all three PRs. If merging counts as setting a rule, those caps bind as yours.

The options:
- (a) A rule in factory text binds only if it points to where you set it: a DECISIONS row, a ticket, or your own words. Without that pointer it's advice. A check can enforce the pointer.
- (b) Anything merged counts as yours.
- (c) Sort them case by case in the rework.

➡️ (a). It makes "who set it" something you can look up rather than guess, and it's how a rule like the 150-line cap gets caught.

---

❓ **Q8 - Where does "a review system of our own" go?** Part of it is writing: review briefs and templates. That fits "Prototype brief templates for the recurring lane jobs" on this map. The bigger part is process:
- how many passes;
- what each pass is open to;
- how the verifier ranks and filters findings;
- recall measured against planted bugs, not just a count of false positives.

That goes past a map about writing.

The options:
- (a) Add all of it to this map's Not yet specified.
- (b) Keep the brief side here, and chart the process side as its own map once this map's templates ticket is done, with your words from Q3 quoted on it.
- (c) A new ticket on this map now.

➡️ (b). You called review possibly the most important step, and that deserves its own destination rather than living as fog on a writing map.