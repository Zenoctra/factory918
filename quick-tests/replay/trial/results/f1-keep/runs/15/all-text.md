I tried to post your answers word for word as a comment on this ticket, the way the map keeps your earlier answers. The post was declined, so for now they're saved only in a local scratch file. Tell me if you want them on the ticket.

**Settled from your answers:**

- **Q2 (b).** I'm carrying your point about strongly linked terms forward. One exact term can pull in most of the rules you'd otherwise have to list, and the extra words then go only to what the term wouldn't bring in. That bears on "Decide what the writing standard is and what carries it". It's also an experiment for "Decide how we'll know the writing works": how many rules get followed, and which ones still need stating even when a term covers them.
- **Q5.** Here's your rule as I have it:
  - In `safe`, budget never shapes the work. It's only measured afterward, to find savings.
  - In `eco` and Let It Rip, a token budget, or a wall-clock budget in Let It Rip, enters a brief only if you set it. Even then, someone first asks you how much it should weigh.
  - When in doubt, leave the budget out.
  - A writer who thinks a budget matters but can't ask you passes it on as information, not as a rule.
  - A budget only binds once you've approved it.

  The "halve the token burn" story is the failure this rule prevents: a prediction got turned into a requirement for closing the ticket.
- **Q3 (a), with a correction.** I overstated the evidence. It shows that a bar on what gets reported hides bugs the reader already found. It does not show that a reader focused on one kind of bug still finds the others. The gorilla studies point the other way: what you're told to look for decides what you see. So (a) settles the bar, and your worry about focus is a separate question. It's Q6 below.

Your note about a review system of our own fits the map. I'll add it to the map's "Not yet specified" section when this ticket closes, unless you'd rather it be a map of its own.

---

❓ **Q1 - Your choice (c), shown on real rules.** The test is two questions about each rule:

1. Is it about what's wanted, what done means, or whose call something is? Or is it about how to get there?
2. If it's about how to get there, did the person who owns that call set it?

A rule binds when the first answer is "what's wanted", or when the second answer is yes. Anything else becomes information, given with its reason.

| Rule | About | Who set it | Result |
|---|---|---|---|
| Never push to `main` | Whose call: merging is yours | You | Binds |
| The orchestrator never writes the code itself; a subagent does | How to get there | You, with evidence; a hook holds it | Binds, because it's yours |
| Don't edit `src/auth/`, another subagent is working there right now | Whose call: the orchestrator owns which subagent works where | The orchestrator, which owns that | Binds |
| Reviewer: read only the diff | How to get there | The orchestrator, to save tokens; nobody who owns that call | Information only ("the diff is here, the ticket is there") |
| Read the tier with two plain commands, because the worktree guard refuses `git` inside `$(...)` | How to get there | Nobody made it binding | Information with its reason. The reader follows it because it's right. |
| Under 400 words | How it finishes | Nobody | Moves to the filter step under Q3 |

In practice, binding rules are few, each one can name its owner, and everything else arrives as information with its reason.

➡️ Confirm (c) if the table matches what you meant. If a row looks wrong, that's where we slow down.

---

❓ **Q4 - What the reader does when it leaves the route, or when a binding rule fights the goal.** Here are the five mechanisms the factory has now:

1. **Ask first.** "Say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent running unattended has nobody to ask, and there's no record of this ever being used.
2. **Obey, then explain.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite of 1: comply first, talk afterward.
3. **Decide and record.** Where the spec is silent, the agent decides and writes a Provisional decision that you can overrule (PHILOSOPHY, DECISIONS, the Ticket playbook).
4. **Skip visibly.** A step you skip stays in the list as `skip: <reason>` (pstack's poteto-mode). This is switched off for delegation ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Hand it back up.** A writer's flags must end `fixed:` or `accepted: <reason>` before review starts. A writer that can't build a test cell as written stops and reports it. A design hole amends the ticket with a dated line. Acceptance criteria that can't fail go back to you.

The conflicts: 1 says ask before acting, 2 says obey and then explain, and 3 and 4 say act and then record. No text says which one applies when.

My proposal, mapped onto those five:

- **Leaving the route, which is information, not a binding rule:** the reader acts on its own judgment, and its report always says where it left the route and why, or that it didn't. That's 3 and 4 made general.
- **A binding rule fighting the goal:** the reader stops that part, reports to the rule's owner, and carries on with the rest. That's 5 made general. In the main session, where you're right there, stopping means asking you, so 1 survives there.
- **2 goes away.** A binding rule is simply obeyed, and information was never an order to obey.
- **4's delegation exception survives**, because that rule is yours and binds.
- **The goal never shrinks to fit a rule.**

➡️ Adopt it.

---

❓ **Q6 - May a brief say which kinds of problems matter most?** This was your worry under Q3. A reviewer chasing edge cases with unsupported input can read straight past the bug you care about. But any focus you name hides something else. That's the gorilla finding, and in Shin's preprint a focused model omitted critical findings that a second reviewer with an open brief recovered. The options:

- (a) Never. Every reviewer gets one open brief.
- (b) Say what matters most and why, as part of the goal, and also always run one reviewer with an open brief and no stated focus.
- (c) Several focused reviewers, one per kind of problem, plus one open reviewer.

➡️ (b). Under Q1, a priority is part of the goal, so it's allowed when it comes from you or the ticket. It's leading when it's the orchestrator's guess about where the bugs are. The open reviewer covers whatever the focus hides. Whether (c) is worth its cost is a question for the review system you want, so I'd leave it there rather than decide it here.