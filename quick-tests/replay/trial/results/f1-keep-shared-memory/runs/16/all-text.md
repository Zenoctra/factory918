I've recorded your answers. Your budget rule and the new binding test are already in my memory. I'll keep your words verbatim and post them on the ticket when it resolves, the same way the map's comments do.

Two things to pin before round two:

- **One well-chosen term can do the work of a dozen rules.** Your micro-genre point: a term the model already associates with most of what you want can replace a long rule list. You then add only what that term wouldn't bring with it. I'll add it to the map's "Not yet specified" section as an experiment. The experiment measures how many rules a lane actually follows, whether one term carries a whole cluster of them, and which rules still need stating on their own. It fits the ticket "Decide how we'll know the writing works".
- **Review gets its own system.** I've noted this and put it to you as Q8 below.

## Q1 in practice

The test comes down to one sentence: **is this something someone other than the reader has the right to decide, and did that person decide it?** If yes, the rule binds, and it's written with its reason. If no, it's information: the reader may do it differently and says so in its report.

Here it is applied to real rules in the factory today. The verdicts follow from your answers, but they're mine. Flag any you'd rule differently.

| Rule as written today | Whose call is it? | Verdict |
|---|---|---|
| "Never push to main" | Yours. Merging is your decision. | **Binds.** The hook holds it. |
| "The orchestrator never writes the code; a lane does" | Yours, set with evidence. | **Binds**, even though it's about the route, because you made it binding. |
| "Owners start one at a time" (autopilot-stack) | Yours, with a measured reason. | **Binds.** The reason goes with it. |
| "Files A and B are being edited by another lane" (in a brief) | The orchestrator's. It runs the lanes. | **Binds.** The orchestrator owns coordination, so it may bind this. |
| "Read only the diff" / "never read more than 150 lines in one call" | Nobody's but the reader's. No owner gave a reason. | **Information at most:** "the change is in X, and Y calls it." Otherwise it's deleted. |
| "Do exactly the task in your prompt" (tier agents) | The task is the owner's. "Exactly" is the route. | **The task binds and "exactly" goes.** The reader can also report what it noticed outside the task (Q3). |
| "Subagents never launch dev servers" | Partly yours: stray servers on your machine collide. | **The safety half binds, with its reason restored.** The rest goes. |
| "No `spec:` citation, no bug" (review gate) | A finishing rule. | **Moves out of the reviewer's brief** into a later filter step (Q3). |

If a row feels wrong, that tells us the test is wrong, which is more useful than agreeing in the abstract.

## Round two

❓ **Q4 (asked again) - Replace the five ways of departing from a rule with one?** These are the five the factory has today, in plain terms:

1. **Ask first.** Both AGENTS.md files say: "If a rule fights the task, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and the rule clashes with "never block on the human".
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed."
3. **Decide and record.** Where the spec is silent, the agent decides and writes a Provisional decision you can overrule.
4. **Skip visibly.** pstack's `skip: <reason>` lets a step be skipped with a note. The delegation step forbids it.
5. **Stop and send it back.** A writer that can't build a test cell as written stops and reports it. Writer flags must end `fixed:` or `accepted: <reason>`. A design hole amends the ticket with a dated line. Bad criteria go back to you.

The conflict: when a rule doesn't fit, the reader is told to ask, to obey, to decide, to skip or to send it back, depending on which file it happened to read. Nothing says which wins.

My proposal keeps two of them and folds in the rest:
- **For route knowledge:** the reader uses its judgment, and every report says where it took another route and why, or that it didn't. This is mechanisms 3 and 4 made universal.
- **For a binding rule that fights the goal:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. This is mechanism 5. In your own session, the owner is you, so "ask first" survives there and nowhere else.
- **Mechanism 2 goes.** It was the only one that told the reader to comply silently with things that aren't binding.

➡️ Adopt it. The reader never shrinks the goal to fit a rule.

---

❓ **Q6 - How is a binding rule written and held?** The research says:
- emphatic wording ("CRITICAL", "NEVER") makes current Claude over-apply a rule;
- a bare "don't" keeps the idea active without saying what to do instead;
- every added rule costs attention, which is your co-pull point.

The options:
- (a) Each binding rule is stated once, plainly, with its reason and who set it. Where a hook can hold it, the hook does, and the hook's refusal message carries the reason and a way forward. That message arrives exactly when it's needed. Briefs then point to the rule rather than repeat it.
- (b) Briefs restate every binding rule each time, to be safe.

➡️ (a). Restating everywhere is how the rule count grows until rules start being dropped.

---

❓ **Q7 - Can a brief say which kinds of bug we fear most?** Your worry is a real one, and I should correct what I said earlier. The evidence that "both get found" is about bars: a reviewer told to report only severe bugs still finds the minor ones and leaves them out. Your worry is about focus, which is different, and the evidence there agrees with you. In the gorilla study, what observers were told to look for decided what they saw. Naming part of a list also suppresses recall of the rest. So a reviewer drifting into edge cases can read right past what matters. The "slight push" in the brief carries the same risk, as you suspected. The finding that does help is from Shin's preprint: a second reviewer with its own open brief recovered everything the focused one missed.

The options:
- (a) The general reviewer's brief stays open. A concern you care about (security, the happy path, data loss) gets its own pass with its own open brief, alongside the general one. A later step sorts all findings by type.
- (b) The general brief mentions the concern as information, with no list.
- (c) Neither.

➡️ (a). Your "multiple passes" instinct is what the evidence supports. It keeps each brief open and still makes sure the thing you fear gets looked at.

---

❓ **Q8 - Where does "a review system of our own" go?** Your points: today `spec-review` mostly hunts bugs, `interrogate` looks wider but leads the witness too, and studies report "no false positives" while missing half the planted bugs. That points to a redesign covering passes, briefs, verifiers and recall measurement. That's process design, not only writing. The options:
- (a) Carry it inside this map, through the ticket "Prototype brief templates for the recurring lane jobs".
- (b) Make it a sixth map of its own. This map hands it the writing rules, and it designs the passes.
- (c) Decide later.

➡️ (b), with a line in this map's "Not yet specified" pointing to it until it exists. The templates ticket would still write the review briefs, but how many passes there are and what each looks for is a bigger question than this map's destination.