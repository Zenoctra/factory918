Your answers are saved word for word and will go on the ticket when it closes. Q2 and Q5 are settled. Q1 needs the plainer version you asked for, Q4 needs the list I left out, and your Q3 note raises one new question.

## Q1, in practice

Last round I made this more complicated than it is. The whole test is one question the reader can ask about any rule: **did the person who owns this decision say it must be done this way?** If yes, the rule binds. If no, it's advice, and the reader may take another route.

Who owns what:

- **You own** the process you set, and anything nobody else was given.
- **Whoever asked for the work owns its goal.** For a ticket, that's the ticket.
- **An orchestrator owns** what it's asking for and the coordination of its own subagents.
- **Everything else about how to do the job belongs to the reader.**

Some cases:

| Rule | Who said it | Binds? |
|---|---|---|
| Never push to `main` | You | Yes |
| The orchestrator never writes the code itself | You, after it was broken | Yes, even though it's about how the work is done |
| Don't touch `ticket.md`, another subagent is editing it right now | The orchestrator, coordinating its own subagents | Yes |
| Read only the diff | The orchestrator, guessing where the bugs are | No. At most it says "the change is in these files" as a fact |
| Token use must halve before this closes | A model that turned your guess into a requirement | No. It never owned that decision. Your Q5 story is exactly this case |

The last row shows why this works. In your story, the agent made itself the owner of a budget decision that was yours. Under this test, the reader treats its own guesses and the orchestrator's guesses as advice, and only rules from the owner of the decision as binding.

## Settled

**Q2 (b).** Advice about how to do the job is written as information, with its reason.

You also asked me to pin your note about terms that pull in many details at once, like a micro-genre name in music prompts. It belongs on "Decide what the writing standard is and what carries it" and "Decide how we'll know the writing works". I'll post your words on both when this ticket closes.

One thing I'd add to that experiment. A micro-genre name works because it pulls in a whole cluster of details at once. That is also how a list of examples becomes a boundary. So the test should count what the term leaves out as well as what it brings in.

**Q5.** The decision as I'll record it:

- **`safe`:** a budget never shapes the work. It's only measured afterward, to look for savings.
- **`eco` and Let It Rip:** a budget reaches a reader only after you've set it and been asked how much it should outweigh everything else. In Let It Rip that applies to wall-clock time too.
- **When in doubt, leave the budget out.** If an agent thinks a budget matters but can't stop to ask you, it passes it on as information, not as a limit.
- **A budget written as binding** must be one you approved.
- **No budget goal** overrides a process you required.

On naming: the first one is called `safe`. The factory calls `safe` and `eco` "tiers", and the Let It Rip map calls Let It Rip a "mode". I'll write "mode" in this ticket's record unless you'd rather not.

**Q3 (a), with a correction to what you were told.** The evidence says two different things, and your worry falls on the less comfortable one:

- **A bar** ("only report high-severity") changes what the reviewer reports, not what it finds. Asking it to report everything fixes that.
- **A focus** ("look for edge cases in input handling") changes what the reviewer *sees*. That's the gorilla finding. Reporting everything doesn't fix a wrong focus.

So your worry is real. It's also why the "slight push" toward the bug types we care about causes the headache you expected: it is itself a focus, and it hides whatever lies outside it. What helped in the evidence was structural: a second pass with an open brief recovered what the focused one missed. That leads to Q7.

---

❓ **Q6 - What does a reader do when a rule gets in its way?** The factory currently has five ways of handling this:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "say so loudly and get a sign-off before breaking it." It appears only in those two files. A subagent has nobody to ask. It also fights "never block on the human" in [template/AGENTS.md:18](template/AGENTS.md:18).
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed." This is the opposite default to number 1, two lines away in the same file.
3. **Decide and record.** Where the spec says nothing, the agent makes the call and records it under Provisional in `DECISIONS.md`, where you can overrule it.
4. **Skip with a reason.** poteto-mode lets a step be skipped visibly with `skip: <reason>`. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) bans that for delegation.
5. **Stop and send it back.** A writer that can't build a test as written stops and reports it instead of improvising. A design hole amends the ticket. Writer flags must each end `fixed:` or `accepted:`.

They conflict mostly because each was written for a different situation and none says which situation it covers. My proposal keeps the ideas and sorts them by situation:

| Situation | The reader | Comes from |
|---|---|---|
| Advice about the route doesn't fit | Takes its own route. Its report says where and why, or says it took none | 4 |
| It disagrees with a binding rule, but the rule doesn't stop the goal | Follows the rule and says why it disagreed | 2 |
| A binding rule would defeat the goal | Stops that part, tells whoever owns the rule, carries on with the rest. It never shrinks the goal to fit the rule. When you're in the chat, telling you is the sign-off | 1 and 5 |
| Nothing covers the case | Decides and records it so the owner can overrule | 3 |

Two things change:

- Subagents get the third row, which they don't have today.
- "These are good defaults, not hard rules" in the template's `AGENTS.md` stops being true as written: some of your rules there are binding by Q1. That line gets reworded in the rework ticket.

➡️ The table as it stands.

---

❓ **Q7 - Where does the review system go?** You described your own review system: several passes, better briefs, and recall measured as hard as false positives. spec-review hunts bugs, interrogate looks more widely, and both lead the witness somewhat. Options:

- (a) A ticket on this map, treating review briefs as the hardest case of the writing.
- (b) Its own map later, which inherits this map's writing rules as given.
- (c) Fold it into "Prototype brief templates for the recurring lane jobs".

➡️ (b). How many passes there are, what each looks at, and who verifies is process design, not writing. This map can hand it the rules, but it can't decide those things. I'd add one line to this map's Out of scope pointing to it, and file a placeholder issue now with your Q3 words quoted in full so they're on record before anyone charts that map.

---

The next round is how binding rules are worded and enforced: plain wording, the reason attached, and whether a hook's message at the moment it fires does more than repeating the rule in every brief. It waits on Q6.