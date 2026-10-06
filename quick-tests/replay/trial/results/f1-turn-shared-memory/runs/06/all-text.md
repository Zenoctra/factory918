Q2 and Q5 are settled. Your Q5 answer is already in my memory, under the factory's name for the first tier, `safe`.

I tried to post your five answers word for word as a comment on this ticket, so they're kept like your charting-round answers on the map. The post was blocked, so nothing is on GitHub yet. Tell me if you want it posted and I'll retry.

Your Q2 note about one dense term standing in for many rules is an experiment for two other tickets: "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it". Once posting is allowed, I'll add a pointer to your words on both.

**On your Q3 worry: the evidence supports part of it.** It separates two kinds of instruction:
- **A bar** ("only report serious bugs") mostly changes what gets reported, not what gets found. The reviewer still notices the small bug and just leaves it out. Your answer (a) fixes that.
- **A focus** ("look for X") changes what gets seen. This is the gorilla study: observers counting passes missed a person in a gorilla suit walking through the scene.

So if a reviewer fixates on input edge cases, it may genuinely never see the bug you wanted. A "slight push toward certain kinds of bugs" would be a focus too, and it would cost you everything outside that kind. The fix the evidence points to is more than one pass: one open-ended reviewer, plus focused ones if you want them. In the 2026 preprint, a separate open-ended reviewer recovered every finding that the narrow instruction had hidden. That is review-system design, so Q9 below asks where it belongs. (a) stands for this ticket.

**Q1, made concrete.** A rule binds the reader when two things are true:
1. The decision belongs to someone other than the reader.
2. That someone actually made the decision.

What to deliver is the asker's decision. Merging is yours. The files another subagent is editing are that subagent's. How to get there belongs to the reader, unless you have deliberately made that decision yourself, as you did with delegation. Anything else the writer knows is advice, given with its reason.

---

❓ **Q6 - Do these verdicts match what you meant by (c)?** These are real rules from the factory, run through that test:

| The rule | Whose decision | Verdict |
|---|---|---|
| Never push to `main` | Yours: you merge | Binds |
| The orchestrator never writes the code; a separate subagent does | A matter of route, but you made the decision, with evidence | Binds, and you can change it |
| "Execute only the task and path scope the parent assigns" (subagent definitions) | "The task" is the asker's. "Path scope" binds only where another subagent owns those files | Binds where the files are someone else's; elsewhere, advice |
| "Never read more than 150 lines in one call" (`knowledge` skill) | An agent wrote it, and no reason is recorded | Becomes advice with its reason, or is cut |
| The eco owner "reads no brief and no diff" while review runs | Nothing on record says you made this decision. Its reason is keeping the reviewers' view separate | Advice with its reason, unless you claim it |
| A reviewer's finding without a `spec:` citation "is sent back" | A finishing rule | Under your Q3 answer: the reviewer reports it anyway, and the citation becomes a field the later filter uses |

➡️ All six as shown. Mark any that feel wrong. A wrong one tells me the test is off.

---

❓ **Q7 - Which way of departing from a rule should the factory keep?** Today there are five:

1. **Say so loudly and get a sign-off before breaking it** (both `AGENTS.md` files). A subagent has nobody to ask. It also pulls against "never block on the human for reversible work".
2. **Follow the file, then tell me why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). Obey first, explain afterward.
3. **Where the spec is silent, decide and record it as Provisional so you can overrule it** (PHILOSOPHY, DECISIONS).
4. **A skipped step stays in the list as `skip: <reason>`** (pstack's poteto-mode). This is forbidden for delegation.
5. **Stop that piece and hand it back up.** Writer flags must end in `fixed:` or `accepted: <reason>`. A writer that can't build a test case as written stops and reports it. A design hole goes back to the ticket as a dated amendment.

➡️ Replace all five with one rule that has two cases:
- **For advice:** the reader uses its own judgment, and its report always says where it took a different route and why, or that it took none.
- **For a rule that binds:** if the rule fights the goal, the reader stops that piece, reports the conflict to whoever owns the rule, and carries on with the rest. When the owner is you, in the window you're typing in, that is the same as asking you, so the first mechanism survives as a special case.
- **In either case:** the reader never shrinks the goal to fit a rule.

Mechanism 2 goes completely, because obeying a rule against the goal is the failure this ticket is about.

---

❓ **Q8 - How is a binding rule written?** Three findings from the research apply:
- Current Claude models over-apply rules written emphatically, with capitals or "MUST".
- A bare "don't" keeps the idea in the model's mind without saying what to do instead.
- Text repeated in every brief gets read past, while a reminder that arrives at the moment it's needed works.

The options:
- (a) A binding rule is written plainly, with its reason and what to do instead. Where a hook holds the rule, the hook's refusal message carries the reason and the way forward. Briefs don't repeat standing rules.
- (b) The same, but every brief also restates the binding rules that bear on its job.

➡️ (a), with one exception: a binding rule that exists only for this job, such as which files another subagent owns right now, goes in the brief, because nothing else carries it. Where standing rules live in general is a question for the ticket "Decide where each piece lives and when it reaches the writer".

---

❓ **Q9 - Where does the review system you described go?** You described multiple passes, measuring how many real bugs are found rather than celebrating zero false positives, a range wider than `spec-review`, and no leading of the reviewer, including in the vendored `interrogate`. The options:
- (a) A ticket on this map.
- (b) Its own map, a sixth, which inherits this map's writing rules.
- (c) Folded into the tickets for the brief templates and the rework of existing files.

➡️ (b). This map's destination is how agents write. Your review system covers how many reviewers run, what each looks for and how results are scored, which is a design of its own. The review briefs stay in this map's template and rework tickets, so the two meet there.