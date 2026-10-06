I tried to post your answers word for word as a comment on the ticket, and the post was declined. Nothing went up. Your answers are saved in a local scratch file for now. Tell me if you want them on the ticket, as the map's charting rounds were, and I'll post them.

Here's what changed from your answers, then round two.

**Your notes, and where I'll put them when the ticket closes:**
- **Q2, terms that pull in many rules at once.** I'd put this with the ticket "Decide how we'll know the writing works" as an experiment to run, and point to it from "Decide what the writing standard is and what carries it". One thing the experiment should measure: a term that pulls in many rules also pulls in that field's habits. "Security review" might call up a fixed checklist, which is the list problem again. That's fine for a song's style and risky for a reviewer.
- **Q3, a review system of the factory's own.** Q7 below asks where it belongs. Your line about studies that report no false positives while missing half the planted bugs goes to the measurement ticket too: recall is the measure.
- **Q5, budgets.** Q6 below restates your rule to check I have it right.

**A correction on Q3.** I didn't say the evidence shows a reviewer finds both kinds of bug. It shows two different failures:
- **A bar** ("only report high severity") makes a reviewer find a bug and then not report it. Your (a) fixes that.
- **A focus** decides what the reviewer sees in the first place. That's the gorilla study: the observers counting passes didn't see the gorilla. A reviewer chasing edge cases in unsupported input really can read past the kind of bug you want.

Your "slight push" cuts both ways. Naming a kind of bug helps the reviewer find that kind, the way listing "invention of the computer" raised it from 1% of answers to 30%. It also costs the reviewer what lies outside the list. Shin's preprint suggests a different fix: run separate passes, including one with an open brief. That's a decision about how review is set up, not about wording, so it belongs in Q7.

---

❓ **Q1 - Check: does the binding test read right with real rules?** In practice, (c) asks two questions of every rule in a brief:
1. Is it about the task itself? That means what's wanted, what done means, or what isn't the reader's to decide.
2. Did whoever owns that call say it must hold?

If the answer to both is yes, the rule binds. Otherwise it is the writer's knowledge, which goes in with its reason or is left out. Here is the test applied to rules the factory has today:

| Rule as written today | Whose call | Under (c) |
|---|---|---|
| Never push to `main` | Yours: merging is your decision | Binds |
| The orchestrator never writes the code inside a playbook | Yours, with evidence, and a hook enforces it | Binds: who does which job is your call |
| Read nothing beyond this brief. Run nothing. | A lane added it to save cost (#33). Nobody asked for it | Gone. Nobody who owns the reviewer's method said it |
| `knowledge`: never read more than 150 lines in one call | Unknown, with no recorded reason | Knowledge at most: if the reason is context cost, say so, and the reader decides |
| Subagents never launch their own dev servers | Theo's rule, adopted without its reason | Splits in two. "Ports and processes other lanes are using aren't yours" binds. The rest is knowledge |
| Read the tier in two plain commands, because the guard refuses `git` inside `$(...)` | A fact about the tool | Not a rule at all. It's knowledge with its reason, the best form |
| A reviewer must cite a `spec:` line, or the bug isn't filed hard | Our script | Under Q3 (a), it stops being a gate. The reviewer reports everything, and the citation becomes a field the later filter sorts by |
| Under 400 words | A lane | Gone, under Q3 |

➡️ If every row reads the way you'd have ruled it, (c) is understood the same way by both of us. Tell me any row you'd rule differently. Each disagreement shows where the test is still unclear.

---

❓ **Q4 - One way to depart from a rule instead of five: here are the five.** These are the ways the factory's text currently tells a reader to handle a rule that gets in the way:

1. **Speak up and wait for sign-off.** "If a rule in this file fights the task in front of you, say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). It came from Theo. Nothing says how a subagent gets that sign-off, since no person is in its loop. It also conflicts with "never block on the human; proceed on anything reversible."
2. **Follow first, explain after.** "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default to 1: comply, then report.
3. **Decide and record it as provisional.** Where the spec is silent, the agent makes the call and records it under Provisional in `DECISIONS.md`, so you can overrule it later.
4. **Skip with a reason.** In poteto-mode, a skipped step stays in the list with `skip: <reason>`, and skipping silently is not allowed. The delegation step forbids even this.
5. **Answer back to the artifact.** A writer flag must end `accepted: <reason>` or the review is refused. A writer that can't implement a test cell as written stops and reports that cell. A design hole gets a dated amendment on the ticket.

Under the decisions so far, these are really three situations, and each gets one answer:
- **The reader goes a different way from the route the writer suggested.** It uses its judgment. Its report always has a line saying where it went differently and why, or that it didn't. Mechanisms 2 and 4 become this.
- **A binding rule fights the goal.** The reader stops that part, reports the conflict to the rule's owner, carries on with the rest, and never shrinks the goal to fit the rule. Mechanism 1 becomes this, with the owner named and no wait for a sign-off that can't arrive.
- **Nobody has decided yet.** The reader decides and records it where the owner will see it. Mechanisms 3 and 5 already work this way and stay.

➡️ Adopt the three. The test of this answer is whether you'd keep any of the five as it stands. Mechanism 5 survives almost unchanged.

---

❓ **Q5 - How is a binding rule worded and held?** This is the question I held back from round one. The research has four points:
- Current Claude models apply emphatic wording ("CRITICAL", "MUST") too broadly.
- A prohibition keeps the forbidden idea active and doesn't say what to do instead.
- A reminder at the moment of use fixes much of the gap, and a standing instruction does little.
- Your point about the number of rules: every rule repeated in every brief costs attention.

The options:
- (a) State each binding rule once, plainly, as what to do, with its reason and its owner. Where a hook enforces it, the hook's refusal message carries the reason and the way forward, and briefs don't repeat it. A rule no hook reaches, such as one inside a subagent, goes in the brief that needs it.
- (b) Restate binding rules in every brief that might touch them.
- (c) Leave the wording to the standard ticket.

➡️ (a). The git guard already works this way: its block message says "Use --force-with-lease on your own branch, or ask." Where each piece lives in general belongs to the ticket "Decide where each piece lives and when it reaches the writer". This question settles only how a binding rule is worded.

---

❓ **Q6 - Check: is this your budget rule?**
- **`safe`** (the factory's name for what you called Safety Mode): a budget never shapes the work. Cost is measured afterward, only to look for savings.
- **`eco` and Let It Rip:** a budget comes into play only after you set one. Before it reaches any brief as binding, you're asked how much it weighs against everything else. In Let It Rip, wall-clock time is a second budget, under the same rule. Your overall goal for a run doesn't get told to the reader just because it's the goal, and it never overrides a process you required.
- **When in doubt, leave the budget out.** If it seems important and you can't be asked, it goes in as information, not as a limit. If it goes in as binding, you approved it.
- **A prediction is never a requirement.** "This might halve the token use" never becomes a closing criterion without your say-so. Your story, about the agent that rewrote its architecture to hit a predicted number, is the same failure as the "at most" list in P109.

➡️ Confirm or correct. If it's right, the last point generalizes beyond budgets: no predicted number becomes a requirement without its owner. I'd carry that point into the standard.

---

❓ **Q7 - Where does a review system of the factory's own belong?** You expect one, and you think review is the step that gains the most from this work. Today, spec-review looks mostly for bugs. `interrogate` looks more widely, and its vendored script also leads its reviewers. No open ticket owns redesigning review: the closest are "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers". The options:
- (a) Make it a ticket on this map. The map's destination is how the factory writes, and a review system is more than writing.
- (b) Give it its own map, opened once this map's decisions exist. This map keeps the ticket "Prototype brief templates for the recurring lane jobs", which covers review briefs, and points forward to the new map.
- (c) Add it to an existing map, such as "Optimize token use and wall-clock time without losing reliability".

➡️ (b). How many passes, how open each brief is, recall as the measure, and when a verifier sorts what came back are questions about the system, and they build on what this map decides about writing. I'd record your note under this map's Out of scope with a link, so it isn't lost before that map exists.