Your answers are saved word for word, and I'll post them on the ticket when it resolves. Before round two, here are the things I'm noting and an honest answer to your Q3 worry.

**Noted, to carry forward:**
- **Q2, rules that pull other rules along.** Your microgenre point: one dense term may bring a cluster of rules with it, and a few added lines can then push what the term doesn't cover. Your two experiments: how many rules a model actually follows, and whether a term that pulls several rules along still needs some of them stated. Both belong to the ticket "Decide how we'll know the writing works". I'll add them there when this ticket closes.
- **Q3, a review system of our own.** This doesn't fit any current ticket. I'll add it to the map's "Not yet specified" section in your words: spec-review mostly hunts bugs, interrogate looks wider but leads the witness too, and published AI review results report few false positives while missing about half of the planted bugs.
- **Q5, my reading of your answer.** Correct me if any of this is wrong:
  - In `safe`, no budget ever shapes the process. Budgets are measured afterward, to look for savings.
  - In `eco` and Let It Rip, a budget reaches a brief only after you've been asked how binding it is. In Let It Rip, that covers both tokens and wall clock.
  - When in doubt, leave the budget out.
  - If it seems important and nobody can ask you, it goes in as information, not as a limit. It binds only with your approval.
  - A predicted saving never becomes a condition for closing the ticket.

**Your Q3 worry is real, and (a) doesn't cover it.** I overstated the evidence earlier, and it actually describes two different effects:
- **A reporting bar.** "Only report high severity" leaves the finding intact and suppresses the reporting. Moving the bar to a later filter step fixes that.
- **Focus.** What the reader is pointed at decides what it notices. That's the gorilla study, and the 2026 preprint where a narrow instruction hid findings the same model otherwise reported. Models also drift toward the same default answers, so a reviewer left alone may well settle on input edge cases, as you fear. A filter can't recover something that was never noticed. Q6 below is about this.

---

## What answer (c) looks like in practice

Answer (c) comes down to two questions the writer asks about each rule before putting it in a brief:
1. **Is the rule about what the work must deliver, or about how to do the work?**
2. **If it's about how, did you (or the ticket, or AGENTS.md) say it must be so?** If yes, it binds. If the writer came up with it, it's a tip and carries its reason, or it's left out.

Here it is applied to real rules in the factory today:

| Rule as written today | What it's about | Who set it | Under (c) |
|---|---|---|---|
| Never push to main | Who merges: you | You | **Binds.** It's about your authority, not about how to work. |
| The orchestrator never writes the code; a lane does | How to work | You, after an agent broke it knowingly ([ledger.md:16](docs/agents/ledger.md:16)) | **Binds**, because you set it. |
| `eco` owner: "Read no brief and no diff while the review state exists" ([ticket.md:13](template/.agents/skills/poteto-mode/playbooks/ticket.md:13)) | How to work | You, on #109: the reviewers stay the fresh context | **Binds.** |
| Run git in two plain commands, because the worktree guard refuses git inside `$(...)` ([ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10)) | How to work | A lesson from a run | **A tip with its reason.** The reader keeps it because it's useful. |
| `knowledge`: "never read more than 150 lines in one call" ([SKILL.md:20](template/.agents/skills/knowledge/SKILL.md:20)) | How to work | No recorded reason or owner | **Doesn't bind.** It becomes a tip if someone finds the reason, otherwise it goes. |
| A reviewer files a bug as hard only with a `spec:` line ([review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494)) | How the work is finished | A lane, not you | **Goes, under Q3.** The reviewer reports everything, and the filter step decides what blocks a merge. |
| "Under 400 words" (removed in #137) | How the work is finished | A lane, for cost | **Goes, under Q3 and Q5.** |

---

❓ **Q4 - What does the reader do when it disagrees with a rule?** These are the five ways the factory handles it today:

1. **Ask first.** "If one fights the task in front of you, say so loudly and get a sign-off before breaking it" ([template/AGENTS.md:20](template/AGENTS.md:20), [AGENTS.md:26](AGENTS.md:26)). This works in a conversation with you. A subagent has nobody to ask, and the line sits two sentences after "Proceed on anything reversible."
2. **Obey, then explain.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. **Decide and record.** Where the spec says nothing, the agent makes the call and writes a Provisional decision for you to overrule.
4. **Skip with a reason.** poteto-mode lets a step stay in the list as `skip: <reason>`, except delegation, which [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) says may never be skipped.
5. **Send it back up.**
   - A writer's flags must end `fixed: <sha>` or `accepted: <reason>`, and the review script refuses to run until each one does.
   - A writer that can't build a test cell as written stops and reports the cell.
   - A design hole gets a dated line on the ticket.

Nobody has audited these, and I found no record of the first one ever being used.

I said earlier that one mechanism should replace all five. That overstated it. Most of them answer different situations, and they only conflict because nothing says which applies when. My revised proposal:

| Situation | What the reader does | Where it comes from |
|---|---|---|
| A tip, not a binding rule, and the reader sees a better way | Takes the better way. Its report always has a line "where I took a different route, and why", or "none" | Replaces 4. It's a report field, not a permission. |
| A binding rule it only disagrees with | Follows it and says why its instinct differed | 2, unchanged |
| A binding rule that blocks the goal, with you present | Says so loudly and waits for your sign-off | 1, unchanged |
| The same, with nobody to ask (a subagent, or an unattended run) | Stops that part, reports the conflict to the rule's owner, finishes the rest | 5, extended to every lane |
| The spec says nothing | Decides and records a Provisional decision | 3, unchanged |

In no situation does the reader shrink the goal to fit a rule.

➡️ Take the table as written.

---

❓ **Q6 - How does a writer point a reader at one kind of problem without blinding it to the rest?** This is your worry from Q3. The options:

- **(a) One open pass only.** The filter sorts the findings afterward. Simple, but the reader's default focus decides what gets noticed.
- **(b) An open brief, plus a line saying what we're especially wary of.** That's your "slight push". The survey evidence says it works, at a cost you can't see. Listing "invention of the computer" raised it from 1–2% of answers to about 30%. But four listed problems took 60% of the answers, against 2% when the question was open. Naming part of a set also suppresses recall of the rest.
- **(c) Separate passes.** One reader gets the open brief. Each focus gets its own reader, in its own context, told to hunt for that one kind. The focus can't suppress the open pass, because they never share a brief. In the 2026 preprint, a separate open-ended critic recovered every finding the focused instruction had hidden. The cost is more lanes.

➡️ (c), as a principle: a focus never rides inside an open brief; it gets its own pass. Each focused pass still has Q3's room to report what it noticed outside its focus. Which passes a review runs, and which focuses, is for the review-system work I'm adding to the map.

---

❓ **Q7 - How is a binding rule worded, and is it repeated where a hook already holds it?** The evidence:
- Current Claude over-applies emphatic wording.
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- Every added rule lowers how many get followed.
- A reminder at the moment of use beat a general one.

Today the git guard and the delegation hook each have their rule restated in prose in several places, and the hook's refusal message already gives the reason and a way forward.

The options:
- **(a) Plain, positive, with its reason, stated once.** Say what to do, not only what not to do: "Open a PR; Manuel merges." Where a hook holds a rule, the hook's message is where it speaks, and briefs don't repeat it.
- **(b) As today:** restated wherever it might matter, for safety.
- **(c) Plain and positive, but still repeated in briefs.**

➡️ (a). Two parts belong to other tickets: where the words physically live goes to "Decide where each piece lives and when it reaches the writer", and your dense-term experiment goes to "Decide how we'll know the writing works". This ticket decides only the wording and the "don't repeat a hook" rule.