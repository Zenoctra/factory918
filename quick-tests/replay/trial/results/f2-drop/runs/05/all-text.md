The background search is done. Three of its findings change my round-one recommendations. Your answers to round one are still open, so I've revised two questions instead of starting a new round.

**1. A rule about what "done" looks like did real harm too.**
- The Standards review brief requires every hard bug to cite a ticket criterion, and the brief never shows the reviewer the ticket.
- Honest reviewers therefore marked real bugs down. One wrote that a bug was "not filed hard because the Standards brief carries no ticket criteria to cite."
- That rule is about the shape of the report, which my Q1 test would have counted as safe ("what done means"). So the test I proposed has the same flaw you found in the old one.
- The run-2 constraints audit made the same mistake. It sorted limits into five classes and kept "safety" and "hand-back format" as safe, which mirrors the framing you corrected. Its late addendum admits the report-format rules were skipped, and that's where this harm was.

**2. Some rules about the route earned their place, with a measured reason.**
- The mandatory trail review caught errors the owner had made in 3 of 3 runs.
- The delegation rule was broken knowingly while it was only prose, so a hook now enforces it.
- A cell was cut on the judge's word that git would fail loudly, and git didn't.
- So "the route always belongs to the reader" is too strong as it stands. The rules that did good all carried their evidence with them.

**3. The factory gives agents five ways to depart from a rule, and they disagree.**

| Where | What it says |
|---|---|
| `template/AGENTS.md:20` | "Say so loudly and get a sign-off" before breaking a rule. |
| `template/AGENTS.md:16` | "Follow the file and tell me why your instinct differed." This is the opposite default. |
| PHILOSOPHY and DECISIONS | Decide, and record a Provisional row so Manuel can overrule it. |
| pstack | Skip a step visibly, with a `skip: <reason>` line. |
| The feature playbook | Write `fixed:` or `accepted:` on each flag, or stop and report a cell. |

No audit examined these. The sign-off line also pulls against "never block on the human", and no text says how a subagent would get a sign-off.

Revised questions:

---

❓ **Q1 (revised) - What makes a rule binding?** Sorting by subject fails twice:
- "What done means" covered the report rule that did harm.
- "Route" covered the trail review that did good.

What separates them is whether the rule carries its own case:
- the reason it exists;
- the evidence behind it;
- who owns it.

With those, the reader can tell when it's in the situation the rule was written for. The `spec:` citation rule had none of them. The trail-review rule has all three (`ticket.md:26`).

The options:
- (a) A rule is binding only when its owner made it so and it carries its reason and evidence. Every other rule is knowledge the reader weighs against the goal.
- (b) A rule is binding based on who owns it alone, reason optional.
- (c) No general test; each rule is argued case by case.

➡️ (a). This also drops the subject-based sorting, which is the part of my first answer that repeated the old mistake.

---

❓ **Q3 (revised) - What does the reader do when a rule fights the goal?** This now means picking between the five mechanisms above.

The options:
- (a) One mechanism everywhere: take the route the goal needs, say in the report which rule you departed from and why, and stop only where the departure can't be undone or the decision isn't yours.
- (b) Keep the sign-off line for the person's session and use (a) for subagents.
- (c) Keep all five, each in its own context.

➡️ (a). "Can't be undone or isn't yours" is the line that already exists in "never block on the human", so this reconciles the two instead of adding a third rule.

---

Q2, Q4 and Q5 stand as written.

Two smaller findings:
- The research for "Research how wording and missing context shape a reader's response" is drafted on its branch. It says no study tests a limit on a model's strategy directly, and that specific method helps on simple tasks and novice readers. That cuts slightly against Q2's starting point, and I'll carry it into the resolution comment.
- `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed. It's outside this ticket, so I'll file it as a quick ticket unless you'd rather I didn't.