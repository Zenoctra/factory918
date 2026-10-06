Your answers aren't on the ticket yet. Posting them verbatim was declined here, so they'll go into the resolution comment word for word when we close it.

## What's settled

- **Q2: write route knowledge as a resource, with its reason.** I'm also keeping your note about rule count. Each added rule lowers the chance any one gets followed. One well-chosen term, like a micro-genre in music prompting, may pull a whole cluster of rules in with it. Then you only spell out what that term wouldn't already carry. That needs an experiment: how many rules get followed, and which ones still need stating even when a term covers them. When this ticket closes, I'll add it to the map as input for "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it".
- **Q3: the reviewer reports everything, and a separate step applies the bar.** On your worry about focus, I need to correct something. The evidence doesn't say a focused reviewer finds both kinds of bug. It says two different things:
  - A bar changes what gets reported. The reviewer still finds the bug and then withholds it.
  - A focus changes what gets seen. Shin's 2026 preprint is the model example: a narrow focus hid findings, and a separate reviewer with an open brief recovered them.

  So your worry is real, and Q9 below takes it up.
- **Q5: budgets.** Here's how I'd record your answer, so you can correct it:
  - In `safe`, no budget ever reaches a brief or shapes a process. Budgets are measured after a run, to look for savings.
  - In `eco` and Let It Rip, a budget reaches a brief only after you've set it and been asked how much it should weigh. Let It Rip adds wall-clock time under the same rule. A goal you set for a mode never overrides a process you've required.
  - When in doubt, leave the budget out. If the writer thinks a budget matters but can't ask you, it goes in as information. It binds only with your approval.
  - Underneath your story is a general rule: a writer never turns a prediction into a requirement for closing the ticket. It's the same mistake as the "at most" list in P109.

  One naming point: the factory calls `safe` and `eco` *tiers* (Ticket step 0), while the Let It Rip map calls itself a third *mode*. I'll leave that for the Let It Rip map to settle.

## Q1, explained more plainly

Ask two things about any rule in a brief: is it about what to deliver, or about how to work? And who said it has to be this way?

A rule the reader must obey can come only from whoever owns the thing it protects. That's usually you, sometimes the ticket, and sometimes another agent's files. An agent writing a brief can pass your rules on. It can't invent new must-obey rules about how the reader works. What it knows about how to work goes in as advice with the reason, which is your Q2 answer.

Think of a general contractor. It passes on the client's floor plan and the rule that the neighbour's fence stays put. It doesn't order the electrician which wall to wire first. It says "the east wall is old plaster and cracks easily."

Q6 tests this against real factory rules.

---

❓ **Q6 - Do these verdicts match your sense of the rule?**

| Rule | About what, and who owns it | Verdict |
|---|---|---|
| Never push to `main` (git guard hook) | The merge is yours | Must obey |
| The session you type into never writes the code itself (delegation hook) | How the work is done, but you set it, with evidence | Must obey, because it's yours |
| "That is the scope; nothing wider is redesigned" ([ticket.md:45](template/.agents/skills/poteto-mode/playbooks/ticket.md:45)) | What to deliver; the ticket owns the scope | Must obey. Anything noticed outside the scope is still reported and becomes a ticket, as `AGENTS.md` already says |
| "Subagents never launch their own dev servers" ([template/AGENTS.md:66](template/AGENTS.md:66)) | How to work, but ports and the machine are shared with other agents | Must obey, with the reason put back. The reason was lost when the rule was copied from Theo |
| `knowledge`: "never read more than 150 lines in one call" | How to work; no reason or owner on record | Advice with a reason, or deleted |
| The `spec:` gate: a bug with no ticket line to cite is sent back | How to finish | Under Q3, the reviewer files it anyway and a later step decides what blocks |
| "Cut token burn in half" turned into what done means | A prediction an agent promoted, without asking you | Not binding. At most it's information (your Q5) |

➡️ They match my reading of your (c). If any verdict feels wrong to you, that row is where the test needs fixing.

---

❓ **Q7 - What happens to a rule whose owner can't be found?** Many rules in the factory have no recorded owner or reason, like the 150-line cap.

➡️ It's treated as advice, not as a rule the reader must obey. That's the same fail-open you chose for budgets. The work of reworking existing files can then either find its owner or delete it.

---

❓ **Q4, asked again - What happens when the reader departs from a route, or a must-obey rule fights the goal?** These are the five ways the factory handles it today:

1. **Say so loudly and get a sign-off before breaking it** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent running alone has nobody to sign off. There's no record of it ever being used, and it pulls against "never block on the human".
2. **Follow the file, then say why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This obeys first and explains afterwards, so it treats advice as a rule.
3. **Where the spec says nothing, decide and record a Provisional decision you can overrule** (`DECISIONS.md`, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30)).
4. **Skip a step visibly, with `skip: <reason>`** (vendored pstack). The one exception is delegation, where [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping.
5. **Send it back to whoever owns it.** A writer's flagged risks must end `fixed:` or `accepted: <reason>`, or a script refuses the review. A writer who can't build a test exactly as specified stops and reports it.

Under your Q1 and Q2 answers, only two of these conflict:

➡️ My recommendation for each:
- **#1** stays for the session you're talking in, because you're there to sign off. For a subagent running alone, it becomes: stop that part, report the conflict to the rule's owner, and carry on with the rest.
- **#2** goes, because it makes the reader obey advice.
- **#4** stays, because it's already "depart and say why". Its delegation exception is your rule, so the exception stays too.
- **#3 and #5** stay. They're already "report to the owner".
- Across all of them: the reader never shrinks the goal to fit a rule.

---

❓ **Q8 - How are must-obey rules held and worded?** The options:
- (a) Restate them in every brief.
- (b) Hold each at the strongest level that can hold it: a hook or script where possible, stated once in prose with its reason. A brief repeats a rule only when this reader, in this job, could break it and nothing would catch it.

➡️ (b). Your note on rule count is the main reason: every restated rule takes attention from the rest. When a rule is written, it says what to do and why. It doesn't use capitals or "NEVER", because current Claude over-applies emphatic rules. The git guard's refusal message is a good model: it blocks, then names a way forward ("Use --force-with-lease on your own branch, or ask").

---

❓ **Q9 - When you care about a particular kind of bug, how does the brief say so?** Naming a kind pulls the reader toward it and suppresses the rest. In one study, four problems offered on a list rose from 2% of answers to 60%. So your "slight push" in an open reviewer's brief would act like the list you warned about.

The options:
- (a) An open reviewer only, with no kinds named.
- (b) An open reviewer with a light mention of the kinds you're wary of.
- (c) The open reviewer stays unprimed. A kind you really care about, security for example, gets its own pass with that focus. The verifier then merges and rates both reports.

➡️ (c), as a principle. A priority gets its own pass and never a push in the open one. The details of passes and the verifier belong to Q10.

---

❓ **Q10 - Where does "a review system of our own" live?** You described it: several passes, better briefs, a verifier, and recall measured against planted bugs rather than celebrating zero false positives. The options:
- (a) Inside this map, under the review-template and rework tickets.
- (b) As its own map, which this map's writing decisions feed.
- (c) As fog on this map for now.

➡️ (b). Review design covers passes, the verifier, what blocks a merge, and measurement. That's process, and it's bigger than writing. The reviewer evals in "Eval the judge and trail-review models the way #103 evals reviewers" and the review-round ticket "Choose each tier's review round count from the clean measurement" would feed it. Here I'd add one Out of scope line pointing at it. The new map gets its own charting session when you want it.