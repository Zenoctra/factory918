Your round-one answers are saved word for word in my scratchpad, and they'll go into the ticket's resolution comment in full. Three things first, then round two.

**Q1, explained in practice.** I said (c) needs both halves of the test; in use it comes down to one question. For any rule in a brief, ask: **who made this rule, and is the decision theirs to make?** If yes, the rule binds. If no, it's the writer's knowledge, and the reader may use it or not.

What each person owns:
- **You** own the factory's process, merges, and the goal. In a project using the factory, that's the project's human.
- **The ticket** owns the scope.
- **An orchestrator** owns only the coordination between its subagents, such as who is editing which file right now.

Here's how five real rules come out:

| Rule | Who made it | Decision theirs? | Result |
|---|---|---|---|
| "Never push to main" | You | Yes: merging is yours | Binds |
| "The orchestrator never writes the code; a subagent does" | You, after it was broken | Yes: the factory's process is yours | Binds (and a hook holds it) |
| "Subagent B is editing `x.ts`; don't write it" | The orchestrator | Yes: coordination is its job | Binds, with the reason |
| "Read only the diff; don't open other files" | An orchestrator, to save cost | No: nobody who owns the reviewer's method asked for it | Not binding. It becomes "the diff is at `<path>`" |
| "Under 400 words" | A lane, for cost | No | Not binding, and Q3 already moved that kind of bar out of the brief |

What the test stops is an orchestrator promoting its own guess about how to do the work into a wall. You can still make any rule bind. That's why (b)'s half matters.

**Q3, one correction to what I implied.** You said "if you are saying the evidence says both get found". That holds for a reporting bar: a reviewer told "only high severity" still finds the low ones and just doesn't report them. Removing the bar fixes that. It does not hold for a focus. In the gorilla study, what people were told to count decided what they saw. In Shin's model study, a focused instruction hid findings the same models reported without it. So "be especially wary of X" in an open brief carries exactly the risk you worried about. Shin's evidence for the remedy is a separate pass with an open brief, not a push inside the same brief. That's Q7 below.

**Q5** is recorded as you stated it. Your "Safety Mode" is the `safe` tier from P109, the default where every playbook step runs as written:
- In `safe`, a budget never affects the process. It's only measured afterward.
- In `eco` and Let It Rip, a token or wall-clock budget reaches a brief only after you've been asked how binding it is.
- When in doubt, the budget isn't communicated at all.
- If it seems important but there's no chance to ask, it goes in as information.
- It binds only if you approved it as binding.

The wall-clock half also touches the map "Design Let It Rip as the third mode". When I resolve this ticket, I'll leave a pointer there.

---

❓ **Q4 - What replaces the five ways the factory handles a rule that fights the task?** Here they are, with what each tells the reader to do:

1. **Stop and get sign-off before breaking it.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20). A subagent has nobody to ask, and nothing says how it would. It also pulls against "never block on the human" two lines earlier in the template.
2. **Obey, then explain afterward.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed."
3. **Decide yourself and record it for you to overrule.** When the spec is silent, the agent makes the call and writes a Provisional row in DECISIONS.
4. **Skip the step and write `skip: <reason>`.** This comes from upstream poteto-mode. It's switched off for delegation, which [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) makes mandatory.
5. **Hand it back up to whoever owns it.**
   - Writer flags must end `fixed:` or `accepted: <reason>` before review runs.
   - A writer that can't build a test cell as written stops and reports the cell.
   - A design hole amends the ticket.
   - The falsifiability pass sends bad criteria back to you.

They conflict. Faced with the same rule, one says to stop and ask, one to obey, one to decide yourself, one to skip, and one to hand it back.

My proposal maps onto these:

- **For a rule that binds:** the reader keeps to it. If the rule fights the goal, the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest.
  - That is 5, generalized.
  - It replaces 1 for subagents. For a session you're typing into, "report to the owner" is the same thing as 1, because you're right there.
  - The reader never shrinks the goal to fit the rule.
- **For knowledge about the route that doesn't bind:** the reader uses its judgment. Its report always says where it took a different route and why, or that it took none. This replaces 4 and 2 for anything that doesn't bind.
- **Mechanism 3 stays.** It isn't a rule fighting the task; it's a gap the spec left, and someone has to fill it.

There's one leftover. 1 and 2 both live in AGENTS.md and govern your rules there. Under Q1 your rules bind, but the template calls them "good defaults, not hard rules". The next question settles that.

➡️ The mapping above. 1 is kept only where a person is present; 2 and 4 fold into the departure line; 3 and 5 stay.

---

❓ **Q5 - Do the rules you write in AGENTS.md bind?** The template says "good defaults, not hard rules", which makes everything in it something the reader may argue with. Under Q1, a rule from you binds. Two readings fit:
- (a) Every rule in AGENTS.md binds, because the human wrote it. The file stops calling them defaults, and anything you mean only as advice is written as knowledge, with its reason.
- (b) AGENTS.md mixes the two, and each rule says which it is.

➡️ (b). You'll want to write advice there too, such as testing habits and style. If each binding rule names itself as binding and carries its reason, the reader knows which is which without guessing. It costs a few words on each binding rule, and you'll likely have few of them.

---

❓ **Q6 - How is a binding rule worded?** The research gives three findings:
- Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule.
- A bare "don't" keeps the forbidden thing in mind without saying what to do instead.
- Every rule added splits attention. That's your pinned point; the next question picks up your co-pulling idea.

The proposal:
- Each binding rule is stated once, plainly, as what to do: "Open a PR; Manuel merges," not "NEVER push to main".
- It carries its reason and its owner.
- Where a hook already holds the rule, briefs don't repeat it. The hook's refusal message carries the reason and the way forward instead, because that message arrives at the moment the reader needs it.

The cost: a reader that doesn't know about a hook loses a turn when it hits it.

➡️ All three. The lost turn is cheap, and the refusal message teaches better than a line the reader skimmed 4,000 tokens earlier.

---

❓ **Q7 - How does a review aim at a particular kind of bug without hiding the others?** You raised this in your Q3 answer. The options:
- (a) A push in the brief: "we're especially wary of X." This is the gorilla risk.
- (b) Each focus becomes its own pass, with one pass always left fully open. A verifier then sorts and rates what all the passes found. This is Shin's design.
- (c) No focus at all, only open passes.

The question here is the principle. Designing the passes belongs to whichever ticket builds the review system (Q8).

➡️ (b). A focus is never written into an open brief. Where a focus earns its place, it gets its own pass, and an open pass always runs beside it.

---

❓ **Q8 - Where does "a review system of our own" go?** Your note on it covers several points:
- Review may be the most important step.
- `spec-review` mostly hunts bugs, while `interrogate` covers a wider range but leads the witness.
- Published studies of AI review celebrate few false positives and ignore missing half the planted bugs.
- It needs multiple passes.

This map's destination is about writing. It already includes the brief templates, and review briefs are among them. It doesn't include redesigning the review process: the passes, the verifiers, and measuring recall. The options:
- (a) A sixth map of its own, opened with your words verbatim, drawing on this map's decisions.
- (b) A ticket on this map.
- (c) A note under this map's "Not yet specified" for now.

➡️ (a), with a line under this map's "Out of scope" pointing to it. It's large enough to need its own destination, and it should start after this map settles what a good brief is, since every pass will be briefed.

---

❓ **Q9 - Where does your co-pulling idea get pinned?** The idea: one precise term that carries 90% of the rules, with explicit rules only for what that term wouldn't carry. It bears on two tickets:
- **"Decide what the writing standard is and what carries it"** is where it would shape the standard's wording.
- **"Decide how we'll know the writing works"** is where your experiment lives: how many rules get followed, and whether a co-pulling term outperforms the list of rules it stands for.

➡️ Your words go verbatim into the map's Notes as a standing consideration for every ticket. Both tickets also get a comment pointing to them. You asked for it to bear on all decisions, and Notes is the part of the map every session reads.