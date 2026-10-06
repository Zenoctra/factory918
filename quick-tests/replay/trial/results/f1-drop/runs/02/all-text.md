Your answers are saved in a local file. I tried to post them word for word as a comment on the ticket and the post was declined. If you want them on the ticket, I'll post them together with the resolution.

Where things stand: Q2 is settled. Q1 and Q5 are settled pending one check each, below. Q3 has a follow-up. Q4 now has the five mechanisms laid out.

## Q1 in practice

Option (c) comes down to two questions you ask of any rule: **who said so, and was it theirs to say?**

| Rule | Who said so | Was it theirs to say? | Result |
|---|---|---|---|
| Never push to main | You, in AGENTS.md | Yes. Merging is your call | Binds |
| The orchestrator never writes the code itself | You, after an agent broke it knowingly | Yes. It's your factory, and you can fix part of the route when you judge it necessary | Binds, even though it's about the route |
| A review brief says "read only the diff" | The orchestrator, to save tokens | No. How a reviewer searches isn't the orchestrator's to decide | Doesn't bind. At most it becomes information: "the change is in these files" |
| "Lane B is editing `auth.ts` right now; leave it alone" | The orchestrator | Yes. It handed out the files | Binds |
| "Halve the token burn" as a ticket's closing criterion, from your Q5 story | A model, turning a prediction into a requirement | No. Only you can say how much a budget weighs | Doesn't bind. It was information |
| An acceptance criterion you approved | You | Yes | Binds, as what done means, not as how to get there |

"What the rule is about" decides whether it was theirs to say:
- Your authority covers everything, the route included, when you choose to use it.
- An orchestrator's authority covers only what it really owns, such as which lane has which files and where results go.
- A lane's authority covers nothing it hands down.

A rule that binds still carries its reason, per Q2.

## Q2: the rule-load point and dense terms

I'll pin your point to two tickets: "Decide how we'll know the writing works" (it's an experiment) and "Decide what the writing standard is and what carries it". One caution for that experiment: a dense term brings its genre's norms with it. That's ideal for context. For an open-ended search, though, the genre's norm is the default list. "Code review" pulls in the usual bug classes, so the term can quietly bring back the multiple-choice problem. Your "say only what the genre wouldn't" handles what you add. It doesn't handle what the term quietly leaves out, so the experiment should measure both.

## Q4: the five mechanisms that exist now

1. **Say so loudly, get a sign-off, then break the rule.** This is in [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20). A subagent has nobody to ask. It also pulls against "Proceed on anything reversible" two lines earlier, at [template/AGENTS.md:18](template/AGENTS.md:18).
2. **Follow the file, then tell me why your instinct differed.** This is at [template/AGENTS.md:16](template/AGENTS.md:16), and it's the opposite default to #1: comply now, explain later.
3. **Where the spec is silent, decide and record a Provisional row you can overrule.** This is [PHILOSOPHY.md:47-55](docs/knowledge/core/PHILOSOPHY.md:47).
4. **Skip a step visibly with `skip: <reason>`.** This is upstream pstack, at [poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113). It's switched off for delegation by [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12).
5. **Hand it back to the artifact.** A writer that can't implement a table cell stops and reports it ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)). A writer's flags must end `fixed:` or `accepted: <reason>`, and a script refuses the review until they do ([ticket.md:23](template/.agents/skills/poteto-mode/playbooks/ticket.md:23)).

The conflict: #1 says ask before departing, #2 says comply and explain afterwards, and #3 and #4 say decide yourself and record it. Which one an agent follows depends on which file it happened to read.

## Questions this round

❓ **Q1′ - Does the table match what you meant by (c)?** Especially the second row: you can make part of the route binding when you judge it necessary, and nobody below you can.

➡️ Yes, as the table shows.

---

❓ **Q4′ - Which mechanism replaces the five?**
- **(a)**
  - For the route: the reader uses its judgment, and its report always says where it took a different route and why, or says "none".
  - For a binding rule that fights the goal: the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest.
  - The reader never shrinks the goal to fit a rule.

  #3 and #5 stay, because filling a gap and handing a stuck cell back are already this shape. #1, #2 and #4 merge into it.
- **(b)** Sign-off first everywhere, with subagents reporting and waiting.
- **(c)** Leave all five as they are.

➡️ (a). It changes words of yours. [template/AGENTS.md:16](template/AGENTS.md:16) says "follow the file and tell me why your instinct differed". Under (a), for anything that isn't binding, the instinct may win and must be reported. You'd be reversing your own line, so I want that explicit rather than buried in a rework ticket.

---

❓ **Q5′ - Is this your budget rule?**
- In `safe` (the factory's name for the first mode), no budget ever shapes the process. Tokens and time are measured after the run, to look for savings.
- In `eco` and Let It Rip, a budget reaches a brief only after you set it and are asked how much it weighs against your other goals. Let It Rip adds wall-clock time as a second budget, under the same rule.
- When in doubt, the budget stays out. A writer who thinks it matters but can't ask gives it as information, never as a limit. A budget written as binding has your approval behind it.
- A prediction ("this should halve token burn") is never a criterion a ticket closes on. **This bullet is my inference from your story, not your words.**

➡️ Yes, all four.

---

❓ **Q6 - Your worry about a reviewer focusing on the wrong kind of bug.** I need to correct myself. The evidence says a bar on *reporting* doesn't stop the *finding*. It doesn't say a reviewer finds everything whatever its focus. The gorilla studies say the opposite: what you tell it to look for decides what it sees. So the "slight push" you described is exactly the mechanism behind your worry. It would raise the kinds you name and lower the rest. The options:
- **(a)** No push. One open brief, every finding reported with its severity, and a verifier rates them.
- **(b)** When certain kinds matter, give each focus its own pass, and always keep one open pass with no focus. A focus becomes one lane's whole job instead of a tilt on the only lane.
- **(c)** The slight push inside a single brief.

➡️ (b) when certain kinds matter, (a) otherwise. In Shin's preprint, a separate open-ended critic recovered every finding a focused instruction had hidden. How many passes to run is the review system's question (Q7), not this ticket's.

---

❓ **Q7 - Where does the review system live?** What you described goes beyond writing: multiple passes, a verifier, interrogate's own leading, and measuring recall, so that "no false positives" can't hide 50% of planted bugs missed. Several tickets touch part of it:
- on this map, "Prototype brief templates for the recurring lane jobs" covers how review briefs are worded, and "Decide the scope and order of reworking existing files" covers reworking them;
- off this map, "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers" cover part of the rest.

The options:
- **(a)** Its own wayfinder map, which takes this map's decisions as input.
- **(b)** Unmapped territory on this map, under "Not yet specified".
- **(c)** Folded into the template prototype ticket.

➡️ (a). This map's destination is how the factory writes. A review system also decides process: how many passes, who filters, and how recall is measured. Writing alone can't settle that. I'd record it under this map's Out of scope, pointing to the new map, and chart that map when you're ready.

---

Once Q1′ is confirmed, round two covers how binding rules are worded and held: in prose, in a hook's refusal message, or both. It will also put the `spec:` citation gate and your halve-the-token-burn story to the rules as test cases.