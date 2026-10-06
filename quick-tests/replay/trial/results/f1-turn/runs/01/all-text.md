I couldn't save your answers on the ticket: the permission check blocked the comment. Your answers are still here in the conversation, and I can post them word for word to the ticket whenever you want. I did save your budget rule to my memory, since it applies well beyond this ticket.

Below: Q1 shown with real rules, your Q3 worry, the five mechanisms for Q4, how I read your Q5, and two questions.

## Q1 in practice

A plainer version of (c): **only someone with the right to decide something can turn it into a rule.**

- You can make anything a rule.
- An agent writing a brief can pass your rules down, and can set rules only about things it controls itself.
- Everything else the agent knows goes in as advice, with its reason, and the reader may do better.

Here's how that sorts real rules from the factory:

| Rule | Who decided it | What happens to it |
|---|---|---|
| Never push to main | You (merging is yours) | Stays a rule |
| The orchestrator never writes code; it hands it to another agent | You, with evidence | Stays a rule, even though it's about method, because you made it one |
| Don't edit files another agent is working on | The orchestrator, which assigned those files | Stays a rule, with the reason |
| "Read nothing beyond this brief" (old reviewer brief) | An agent, to save cost | Not a rule. At most it becomes "the diff is at X" |
| Read knowledge files 150 lines at a time | Nobody recorded a reason | Advice with a reason, or deleted |
| "Cite a `spec:` line or it isn't a bug" | An agent | Goes away under Q3: report everything, sort afterward |
| Don't tell the reviewer what the author thinks is fine | — | Not a rule on the reader at all. It's the writer choosing what to leave out, so the standard ticket owns it |

If that table matches what you meant by (c), I'll use it as the working version.

## Q2: your point about one well-chosen term

I'll carry it to "Decide what the writing standard is and what carries it" and "Decide how we'll know the writing works", since it's both a writing technique and an experiment. One caution belongs in that experiment: a term that pulls in the right 90% also pulls in that genre's habits, including ones you don't want. That's the list problem in another form. So the test has to count what the term pulls in that you didn't ask for, as well as how many rules it saves.

## Q3: your worry is real, and (a) alone doesn't cover it

The research shows two different effects:

- **A bar** ("only report serious bugs"): the reader still finds everything and just doesn't write it down. Your (a) fixes this, because everything gets reported and a separate step sorts it.
- **A focus** ("look for input edge cases"): this can stop the reader seeing other things at all. It's the gorilla effect. In the 2026 model study, a focused instruction hid critical findings. Sorting afterward can't fix this, because those findings were never made.

Your "slight push" toward certain bug types is a focus, so it carries that risk. The evidence-backed fix is more than one pass. A second reviewer with an open brief recovered everything the focused one missed. So if you want extra attention on one kind of bug, give that kind its own reviewer and keep one reviewer whose brief is open. That's review-system design, which leads to Q7.

## Q4: the five ways the factory currently handles a rule that fights the task

| # | Where | What it tells the reader | Problem |
|---|---|---|---|
| 1 | Both AGENTS.md files | "Say so loudly and get a sign-off before breaking it" | A subagent working alone has nobody to ask, so in practice it complies |
| 2 | [template/AGENTS.md:16](template/AGENTS.md:16) | Follow the file, then tell me why your instinct differed | Contradicts #1: comply first instead of asking first. Both sit in the same file, four lines apart |
| 3 | PHILOSOPHY, DECISIONS | Where the spec says nothing, decide yourself and record a Provisional decision you can overrule | Fine, but it covers gaps, not conflicts |
| 4 | poteto-mode, from upstream | You may skip a step if you write `skip: <reason>`; skipping silently isn't allowed | Fine, but [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) shuts it off for delegation |
| 5 | Review scripts and playbooks | The writer stops and reports a test cell it can't build as written; flags must end `fixed:` or `accepted: <reason>` | Fine, but it applies to only a few steps |

None of the five has ever been studied for whether it works. The real conflict is between #1 and #2, plus the fact that #1 can't work for a subagent working alone. Numbers 3, 4 and 5 are each sound for their own case.

❓ **Q6 - One rule to replace #1 and #2**:
- **Advice** (a default, a route the writer suggests): the reader uses its judgment. Its report always says where it went another way and why, or that it didn't. This is #4's `skip: <reason>`, applied everywhere.
- **A rule that fights the goal**: the reader stops that part and reports the conflict to whoever owns the rule, then carries on with the rest. In a conversation where you're present, that means asking you, which is #1. For a subagent working alone, it means reporting to the agent that sent it, which is #5's "stop and report the cell".
- **A gap**: keep #3 as it is.
- **Never**: shrinking the goal to fit a rule.

➡️ Adopt it. #3, #4 and #5 survive as special cases of it, and #1 and #2 merge into one rule.

## Q5: your rule as I understood it

- In `safe`, a budget never shapes how work is done. It's only measured afterward, to find savings.
- In `eco` and Let It Rip, a token budget, plus wall-clock time in Let It Rip, reaches a reader only after you've set it and said how much it should weigh.
- When in doubt, leave the budget out.
- If it seems important and I can't ask you, it goes in as information, not a limit.
- A budget written as a rule must have your approval.
- A predicted saving never becomes the condition for closing a ticket.

Correct me if any of that is off.

## Q7: where does the review system go?

❓ **Q7 - Where should a review system of your own be designed?** Your Q3 answer describes one: several passes, briefs that don't lead, and recall that counts as much as precision.
- (a) A new, sixth map, which this one feeds.
- (b) Fog on this map for now.
- (c) Inside the ticket "Prototype brief templates for the recurring lane jobs".

➡️ (a). The destination is a working review process, which is bigger than how review briefs are written, and it depends on what this map decides. Until it exists, I'd add a fog line here pointing at it.

Once Q1's table and Q6 are settled, the next round covers how the rules that remain are worded and enforced: plain wording with reasons instead of emphatic wording, and whether a hook's refusal message carries the rule better than repeating it in every brief.