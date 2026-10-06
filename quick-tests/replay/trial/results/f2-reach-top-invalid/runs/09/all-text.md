The background search finished. You haven't answered round one yet, so this is what it found that bears on those five questions. I've changed two of my recommendations because of it.

**Q1 (what makes a rule binding).** Some rules about the route have worked, and the reason was on record each time:
- The mandatory trail review caught the owner's mistakes in 3 of 3 runs ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)).
- The delegation rule now has a hook because the written rule alone was broken knowingly ([ledger.md:16](docs/agents/ledger.md:16)).
- The blast-radius rule came from a hook bug that survived four review rounds ([ledger.md:17](docs/agents/ledger.md:17)).

So "route rules are never binding" is too strong. **Revised recommendation:** a route rule can become binding, but only when you make it so and its reason is written down. DECISIONS already requires a reason on every row, so that's the natural place. The reason is also what lets someone retire the rule later. A rule an agent adds on its own judgment stays knowledge, as in Q2.

**Q2 (route knowledge in a brief).** The research ticket's findings sit on the unmerged branch `research/wording-and-reader-context`. They show two effects:
- Specific instructions on method help on simple tasks, and they help novices.
- The same instructions hurt experts on complex tasks.

They also separate two things: the writer holding back what it volunteers, and the writer limiting what the reader may go looking for. No study tests a limit on strategy directly. This supports (b) as I recommended: share what the writer knows, with the reason, and leave the reader free to look beyond it.

**Q3 (when a rule fights the goal).** This one is bigger than I framed it. The factory has five ways to depart from a rule, and they disagree with each other:
1. **Say so loudly and get a sign-off** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). Nothing tells a subagent how to get a sign-off. I found no record of anyone ever using this route.
2. **Follow the file, then say why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default to 1.
3. **Decide, and record a Provisional row in DECISIONS** for you to overrule later.
4. **Mark a step `skip: <reason>`**, from pstack. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) turns this off for delegation.
5. **Stop and report the specific point** (a writer cell it can't implement, a design hole).

**Revised recommendation:** one rule replaces all five, and it depends on what kind of rule is in the way:
- **A binding rule:** stop that part, report it to whoever owns the rule, and carry on with the rest. That's (a) from before.
- **Route knowledge:** depart from it, and say in the report that you did and why.
- **Never** shrink the goal to fit a rule.

Whether to also drop the sign-off line from both AGENTS files is a rework call for "Decide the scope and order of reworking existing files". This ticket only decides the rule.

**Your correction holds beyond search.** The run-2 constraints audit sorted limits using the same "protect the world / shape the search" split you rejected. Its brief also told it "Do not propose new constraints." Its own late addendum then found that rules about how work is *finished* did comparable damage. The clearest case is the `spec:` gate: a reviewer obeyed it, filed nothing, and the PR shipped with 4 hard bugs. The answer-key audit found the same: honest reviewers demoted real bugs because the brief required a citation from a ticket it never showed them.

**Q4 and Q5.** Nothing found changes these.

One stray fact, unrelated to this ticket: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but PHILOSOPHY now has eleven. I'll file a quick ticket for it unless you'd rather I didn't.

Round one is still open: Q1–Q5, with the revisions above to Q1 and Q3.