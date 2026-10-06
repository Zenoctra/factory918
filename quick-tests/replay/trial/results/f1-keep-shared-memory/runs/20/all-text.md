I've saved your answers. I wanted to post them word for word on the ticket, but the GitHub call was denied, so they're in a local file for now. I'll post them when you allow it. Your budget rule from Q5 is already in my memory, and so is the new test from Q1.

## Q1 in practice

Ask two questions of any rule:

1. **Is it about what to get done, or how to do it?**
2. **Did the person who owns that decision say it must be followed?**

If both answers point to "binding", the rule is binding. Anything else is a tip. A tip goes in the brief with its reason, and the reader can take a better route if it finds one.

| Rule | Binding? | Why |
|---|---|---|
| Never push to main | Yes | Merging is your decision, and you set the rule. |
| The orchestrator never writes the code | Yes | It's about how the work is done, but you set it, with evidence behind it. |
| Don't edit `src/auth/`; another subagent is working there | Yes | The orchestrator assigns files between subagents, so it owns that decision. |
| Read only the diff (written by an orchestrator) | No | It's about how the reviewer works, and the orchestrator doesn't own that. It becomes "the change is in these files", a place to start. |
| This change must halve token burn | No | It was a prediction, and you never approved it as a requirement. Your Q5 case. |

## Q2: your point about one strong term

I agree it's worth pinning. It also has a risk. A micro-genre term brings in that genre's norms, including ones you didn't choose. That is the same pull a list has, packed into one word. So one strong term is a tool with the same danger as a list: it saves rules, and it can also narrow the reader.

Testing it belongs to "Decide how we'll know the writing works": how many rules get followed, and whether one term carries several rules or loses some of them. It's also an input to "Decide what the writing standard is and what carries it". I'll add it to both when I can write to the tracker.

## Q3: your worry is right, and I overstated the evidence

The evidence that both kinds of bug get found is about a severity bar. Told "only report high severity", reviewers still find the low-severity bugs and just don't report them. Your worry is about focus, which is different, and there the evidence agrees with you. In the gorilla study, what people were told to count decided what they saw.

So a "be especially wary of X" nudge in an open reviewer's brief will probably hide what lies outside X. What worked in the one model study was a second reviewer with an open brief, which recovered everything the focused one missed. If you want emphasis, give it to a separate pass, and keep the open reviewer open. That's a design question for the review system (Q8 below).

---

❓ **Q4 (asked again) - One way to handle departures, replacing five.** Take one case: a subagent reviewing a PR needs to read a 400-line file, and a rule says never read more than 150 lines at once. Here is what each current mechanism tells it to do:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, so in practice it obeys or stops.
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed." It reads 150 lines and writes a note.
3. **Go back to the reasoning, then decide and record it.** The manual says to re-read PHILOSOPHY "when a rule fights you". Where the spec is silent, the agent makes the call and records a Provisional decision you can overrule.
4. **Skip with a reason.** poteto-mode lets a step stay in the list marked `skip: <reason>`, never skipped silently. Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping it.
5. **Stop and send it back up.** A writer that can't implement a test cell as written stops and reports it. Writer flags must end `fixed:` or `accepted: <reason>`.

The same situation gets five different answers: ask first, obey, decide, skip, or stop. Which one the agent follows depends on which file it happened to read.

My proposal splits it into two cases, and keeps most of what exists:

- **A tip doesn't fit.** The subagent uses its judgment and says in its report where it went another way and why. Mechanisms 3 and 4 already work like this.
- **A binding rule fights the goal.** The subagent stops that part, reports it to the rule's owner, and does the rest. That is mechanism 5. Mechanism 1 is the same thing when you're in the room, because asking you is reporting to the owner.
- **Mechanism 2 goes.** Obeying first and explaining later is how a goal gets quietly shrunk to fit a rule.

In the example, the 150-line cap has no reason and no owner ruling, so it's a tip. The reviewer reads the whole file and says so.

➡️ Adopt the two cases, and drop "obey, then explain".

---

❓ **Q6 - How a binding rule is worded.** The research says three things. Plain wording works better than emphasis, because current Claude over-applies "MUST" and "CRITICAL". A rule with its reason gets applied well in cases the writer didn't foresee. A bare "don't" keeps the forbidden thing in mind without saying what to do instead.

➡️ Every binding rule is stated plainly, once, with its reason and what to do instead. For example: "Don't push to main; Manuel merges. Push your branch and open a PR."

---

❓ **Q7 - Check the test against real rules.** Here are rules from the factory today, with the verdict I'd give each. Mark any you disagree with.

| Rule | Verdict |
|---|---|
| The mandatory trail review ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)) | Binding. It's a required step you set, and it caught errors 3 of 3 times. This fits your Q5 point that processes you require stay required. |
| Subagents never launch their own dev servers ([template/AGENTS.md:68](template/AGENTS.md:68)) | Binding, but the reason was dropped when it was copied from Theo. Restore it: ports and processes are shared with other subagents and with you. |
| The `spec:` citation gate in `review-brief.sh` | Not a rule for the reviewer. It's a filter, so it moves to the step after the review (your Q3 answer). |
| The 150-line read cap in the `knowledge` skill | A tip, or deleted. It has no recorded reason. |
| pstack's "Execute only the task and path scope the parent assigns" | Split it. "The task" binds. "The path scope" is a starting point. It's vendored, so the change goes in as a patch. |
| "That is the scope; nothing wider is redesigned" (the design-hole path) | Binding, since scope is part of the task. It gains a line inviting the reader to report what it saw outside the scope. |

➡️ As in the table.

---

❓ **Q8 - Where the review-system work goes.** You described a review system of your own: several passes, better briefs, measuring missed bugs and not only false positives, a wider spread than bug-hunting, and moving away from interrogate's leading wording. This map's destination is a plan for how agents write, and a review system is bigger than that: it covers process, passes and measurement. Some existing tickets touch it already: "Eval the judge and trail-review models the way #103 evals reviewers" and "Choose each tier's review round count from the clean measurement". The options:

- (a) Treat it as fog on this map.
- (b) Give it a map of its own, like the five, and note it under this map's Out of scope.
- (c) Fold it into "Prototype brief templates for the recurring lane jobs".

➡️ (b). Open the map after "Decide what the writing standard is and what carries it" resolves, because the review system will inherit that standard. Templates alone can't give you multiple passes or recall measurement.