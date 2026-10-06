Your Q5 answer is a standing rule, so I'm saving it to memory now, along with the corrected version of the old constraint test.

---

Your answers are saved word for word in my notes for the ticket. Your Q5 answer is also saved to memory as a standing rule, and I've rewritten my old memory that still said "safety rules are the exception". Taking your points in order:

## Q1 explained with real rules

The test comes down to two questions you ask of any rule:

1. **Is it about *what* or *how*?** "What" is the result wanted and whose call each thing is. "How" is the way the reader gets there.
2. **Did the person who owns that call say it must hold?**

By default, a "what" rule binds when its owner set it, and a "how" rule is advice with its reason. You can deliberately make a "how" rule binding, and nobody else can. A "what" rule its owner never set, such as a guess, a prediction, or something a lane added, binds nobody.

Here is how that sorts some real rules:

| Rule | What or how | Who set it | Binds? |
|---|---|---|---|
| Never push to main | What: merging is your call | You | Yes |
| Don't edit files another lane is working in | What: it isn't this reader's call | The orchestrator, which assigns the files | Yes |
| The orchestrator never writes the code | How | You, after a lane broke it | Yes, because you chose to bind it |
| Run the trail review | How | You, with evidence (3 of 3 catches) | Yes, same reason |
| Read only the diff | How | A lane, to save cost | No. It becomes "the change is in this diff; follow it wherever it reaches" |
| Only report high-severity bugs | How the task is finished | A lane | No. The bar moves to the filter step (Q3) |
| Cite a `spec:` line or it isn't a bug | Looks like what done means | Nobody: a lane added it, and it hid 4 real bugs | No |
| Cut token burn in half (your Q5 story) | Looks like what done means | Nobody: it was a prediction | No |

The last two rows are the trap. A rule can look like part of the goal without anyone who owns the goal having set it. Your token story is exactly that case. The test catches it because it asks where the rule came from, not only what it says.

## Q2: pinned, with one caution from the research

When this ticket resolves, the instruction limit and your "microgenre term" idea go onto the map as open questions. They need experiments, and the ticket "Decide how we'll know the writing works" is the natural home. The caution is that a strong term pulls the reader toward the center of what it names.

- **That's good for a rule about behavior.** One word can carry ten rules.
- **It's risky for a goal that needs to range widely.** The research found models' answers to open questions are already 71–82% alike, and examples copy themselves into the output. A term that packs a review goal tightly may also shrink it toward the obvious center.

So your idea probably works for compressing rules and should be tested with care on goals. Your "extra push" question belongs in the same experiment.

## Q3: correcting what I said

I didn't show that both kinds of bug get found. The evidence I cited says a bar changes what the reviewer reports, not what it finds. Your worry is about a different effect: what the reviewer looks at in the first place. That effect is real.

- In the gorilla study, observers counting the black team's passes noticed the gorilla 58% of the time. Observers counting the white team's passes noticed it 27% of the time.
- In Shin's preprint, a narrow task instruction hid critical findings the same model reported without it.

So (a) fixes the bar but doesn't fix focus. A slight push toward one bug class would raise hits in that class and lower them everywhere else. That's the headache you predicted. The research's answer is structural: more than one look. Lanes can each own a concern, plus one lane with the open goal, and then a verifier that sorts the findings. That's review-system design, which leads to Q7.

## Q5: my restatement

Correct me if I've got this wrong:

- **In `safe`** (the first mode's name), budget never affects how work is done. It's only measured afterwards, to find what to optimize.
- **In `eco`**, a token budget exists only once you set one. Before it goes into any brief, you're asked how much priority it has.
- **Let It Rip** adds wall clock under the same rule. A goal you set for the whole run doesn't have to be told to a reader, and it never overrides processes you required.
- **When in doubt, don't communicate budget.** If it seems important and nobody can ask you, it goes in as information, never as a limit. A budget written as binding is one you approved.

---

## Round two

❓ **Q6 - Does the table above match what you meant by (c)?** If any row lands on the wrong side, that row is the most useful thing you could tell me.

➡️ I'd keep it as written.

---

❓ **Q4 (asked again, with the list) - One way to depart from a rule, in place of five.** Here is what the factory says today:

1. **Say so loudly and get a sign-off before breaking it.** This is in [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20). It assumes you're there to sign off, and nothing says what a subagent does when you aren't. It also pulls against the next line of the template: "Proceed on anything reversible."
2. **Follow the file, then tell me why your instinct differed.** This is in [template/AGENTS.md:16](template/AGENTS.md:16). It means comply first and explain afterwards. That's the opposite default from the first mechanism.
3. **Re-read the philosophy when a rule fights you; where the spec is silent, decide and record a Provisional decision you can overrule.** This is in [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) and in the DECISIONS Provisional rows.
4. **Skip a step visibly with `skip: <reason>`.** This is in [poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113) (upstream). Delegation is the exception: skipping it is forbidden.
5. **Send it back up.** Writer flags must end `fixed:` or `accepted:`. A writer that can't build a table cell as written stops and reports it. A design hole amends the ticket. Criteria that can't be tested go back to you.

What I proposed, compared against that list:

- **For "how" advice**, the reader uses its judgment and its report always says where it took a different route and why. This replaces 2 and 4. With Q6's table, delegation needs no special exception, because it's a rule you bound.
- **For a binding rule that fights the goal**, the reader stops that part, reports to the rule's owner, and carries on with the rest. This replaces 1 and works for subagents. When the owner is you and you're present, it's the same thing as asking for a sign-off.
- **3 stays.** A silent spec is a gap, not a rule fighting the goal, and the Provisional record is the right tool for it.
- **5 stays.** Every item in it is already "stop and report to the owner".

➡️ Merge 1, 2 and 4 into the first two bullets above. Keep 3 and 5.

---

❓ **Q7 - Where does the review system go?** What you described goes beyond how briefs are worded. It covers the passes, which lanes look at what, a verifier that classifies findings, measuring recall against planted bugs, and `interrogate` leading the witness. Some of this already exists as scattered tickets: "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers". The options:

- (a) A new ticket on this map.
- (b) Its own map, a sixth, which takes this map's decisions as input.
- (c) Folded into the template prototype and rework tickets here.

➡️ (b). How review briefs are worded stays here, in the templates and the rework. The review process itself is a larger design than this map's destination, so it gets an Out of scope line here pointing at the new map. You'd chart it after this one, or alongside it.

---

❓ **Q8 - How are the few binding rules written and held?** The research says four things:

- plain wording works better than emphatic wording, because current Claude over-applies "MUST";
- give the reason, because the model generalizes from it;
- say what to do, not only what not to do;
- a message at the moment of use beats a general reminder loaded earlier.

The options:
- (a) Each binding rule is stated once, in plain words with its reason, where it applies. A hook holds it wherever a hook can, and the hook's refusal message carries the reason and the way forward.
- (b) Restate binding rules in every brief.

➡️ (a). Restating a rule everywhere adds to the instruction count you pinned in Q2. The research also says text repeated everywhere gets read as boilerplate.