Yes. The research changes most of the round, and in two places it changes what I'd recommend. I've now read the whole note, [docs/research/wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md); the § numbers below are its sections. First what changed, then a new round that replaces the one above.

## What changed

1. **How the goal and "done" are written bounds the route more than any rule.** My round assumed both were safe to fix and put all the risk on the route. The evidence says otherwise:
   - Observers told what to count often missed the gorilla walking through: 46% didn't see it. A 2026 preprint found the same in models (one author, not peer reviewed). A narrow task instruction suppressed findings the same models reported without it. A separate critic with an open brief recovered every one (§4).
   - Anthropic reports that Claude, given a bar like "only report high-severity issues", still finds the bugs and then leaves out the ones below the bar. It published no numbers (§4). The `spec:` gate the run-2 audit flagged is this exact case.
   - People rewarded on a measure start acting as if the measure were the goal, without noticing (§4).

2. **Writing route knowledge "as information" doesn't make it harmless.** Readers treat everything in a request as put there on purpose (§1), and current Claude models read instructions literally (§11). Once a reader sees a method, it tends to use it:
   - Chess masters kept their eyes on a familiar mate while believing they were looking for a shorter one.
   - Codex copied lines from an example function into 32–61% of its answers (§2).

   Wording still matters. The same limit stated as information instead of as control didn't cost creativity (§4), and models generalize from a stated reason. But the research draws a line I hadn't: **facts about the situation** versus **a suggested method**. A subagent is a capable reader who knows little about this project. Explicit context helps readers with little background (§9). Step-by-step guidance hurts capable readers (a meta-analysis of 60 studies, §4).

3. **Permission to depart from a rule mostly goes unused.** Survey respondents told they could ask for help did so in 4% of the cases where help was given. Calling definitions "essential" instead of "available" raised checking from 23% to 81% (§8). Models almost never ask on underspecified tasks. They also act on hints without mentioning them: Claude 3.7 Sonnet named a hint it used 25% of the time (§3). So silent narrowing won't show in a subagent's reasoning either.

4. **A distinction I'd missed: what the writer holds back versus what the reader may examine.** Forensic science protects an examiner's independence by withholding other people's conclusions, not by limiting what the examiner looks at. Across 16 medical studies, relevant context improved readers' accuracy, and none found a loss (§3). This settles the reviewer case under your broader principle.

5. **A number in a brief works as a target.** Anchors move models, and the stronger GPT models moved more consistently. Tight output budgets cut a reasoning model from 72% to 54% (§3, §4). My old Q5 called a budget stated "as a fact" safe. It isn't.

6. **Where specific method helps.** Specific goals help on simple tasks, and guidance helps novices (§4). That matches your own carve-out for lists: "fine if you are looking at a closed ended task where the options truly ARE listable and complete."

One limit. No study tests a limit on strategy itself in a model, such as which files to read or in what order (§13). This decision rests on human evidence plus nearby model evidence about thresholds, framing and formats. It's a judgment, and "Decide how we'll know the writing works" can test it.

---

❓ **Q1 - What may a brief fix that the reader can't change?** I'm giving no options this time. A list of options bounds the answer even when it has an "other" slot (§2), and this is the question where that would hurt most. Here's a proposal to push against:

- **Only authority binds.** A binding rule marks something that isn't the reader's to decide: your merges, a file another subagent is working in, the ticket's scope, effects outside its job. It binds because its owner set it. The delegation rule binds because you set it, not because of what it says.
- **Authority limits what the reader changes, never what it reads, considers or reports.** The ticket's scope stops a subagent from changing code outside it. It doesn't stop it from reading there or reporting what it found; anything found there becomes a ticket, as AGENTS.md already says. Limiting action costs discovery nothing. Limiting attention is how the gorilla gets missed.
- **The goal is written as the purpose, at the level of why the job exists.** It isn't narrowed to where the writer expects the answer. A study of army orders found that real intent statements were full of method, which tied the hands of the people they were meant to free (§4). Briefs do the same unless the writer checks.
- **"Done" is evidence of the goal, not the goal.** When a done criterion and the purpose disagree, the purpose wins and the reader says so. This generalizes your P109 ruling that a predicted result never outranks the designed feature.

Test case: under this proposal the `spec:` citation gate is a reporting rule that filtered out findings, so it can't bind.

➡️ The proposal above. What I need from you is whether it matches "the design architecture of how the task is pursued or completed", or leaves something out.

---

❓ **Q2 - Facts about the situation, or a suggested method?** When the writer knows something about the route:
- (a) It passes on facts the reader couldn't easily find, each with its reason, and writes no method for an open task. "The guard refuses `git` inside `$(...)`" is a fact. "Read the tests first, then the diff" is a method.
- (b) It may also offer a method, labelled as a suggestion, with its reason.
- (c) It passes nothing about the route.

➡️ (a). (b) looks harmless, but a literal reader tends to follow any method it's shown. (c) throws away the warnings a reader new to the project most needs.

---

❓ **Q3 - Closed tasks.** Some jobs are closed: whether the result is complete can be checked without judgment. Run this script and report the output, apply this patch, copy these files. May a brief for a closed task spell out the method?

➡️ Yes. Specific method helps on simple tasks, and this is your own carve-out for lists. The test: if checking the result takes judgment, the task is open. The risk is a writer calling an open task closed to justify writing a method. So the line has to be checkable, not left to the writer's feeling.

---

❓ **Q4 - One way to depart from a rule.** The factory has five ways today, and they conflict. This proposal would replace them all. It builds on Q1 and Q2, so I'll redo it if you change either.
- **Route facts:** the reader goes its own way where it judges better, and says so in its report.
- **Authority:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. It never narrows the goal to fit the rule.
- **The brief says, in plain words, that the reader's judgment of the route is the one that counts.** Plain, not emphatic: emphatic wording makes current Claude over-apply instructions (§4). Assigned dissent also worked worse than real dissent (§3), so a loud invitation risks departures for show.
- **Every report has a section for what shaped the work.** It names the rules and facts the reader followed even where its own judgment pulled the other way, and where it departed. Models use hints without saying so, so a section for departures alone would miss silent compliance.

➡️ As proposed.

---

❓ **Q5 - Restraint by the writer is not a limit on the reader.** Should the standard keep these two apart?
- **What the writer holds back:** its own conclusion, what it expects to find, how many problems it expects. Lineup instructions implying the culprit was present made 78% of witnesses pick someone, against 33% when told the culprit might not be there. Telling a model the code was bug-free cut detection from 97% to 4%. Claude Opus 4.5 held up best but still dropped from 96% to 89% (§3).
- **What the reader may examine:** never limited, and it's given the context that matters to the task.

➡️ Yes. A reviewer stays independent by not hearing the writer's conclusion, not by reading less. "Read only the diff" protected nothing. "Don't tell the reviewer you think it's clean" protects a lot. How a writer avoids leading belongs to "Decide what the writing standard is and what carries it". This ticket only settles that the writer's restraint never turns into a limit on the reader.

---

❓ **Q6 - Report shapes, reporting bars and budgets.**
- (a) A report's shape may be fixed when a script or the next reader needs it, but anything that doesn't fit still has a place in it.
  - Nothing is withheld for falling below a bar: no severity floor, no count, no length cap.
  - Every finding comes with its confidence and severity, and filtering is a separate step.
  - A budget appears only when its owner set a real one. It says what it protects, and it never limits the count or length of the output.
- (b) The same, but length caps are allowed for cost.
- (c) No fixed report shapes at all.

➡️ (a). It's the vendor's own advice for review prompts (§4). (b) brings back the "under 400 words" line the leading-prompts audit removed. (c) breaks the scripts that read reports, such as `review-comment.sh`. A fixed shape didn't cause the harm on its own; the harm came when the shape dropped what didn't fit.

---

❓ **Q7 - How a binding rule is worded.** Proposal:
- Plain words, the reason, and what to do instead.
- No capitals or "CRITICAL".
- Where a hook enforces the rule, the prose says so once, with the reason, and doesn't repeat the rule elsewhere.

The evidence: a bare "don't" leaves a model on some other fixed default (§5). Emphatic wording leads to over-application (§4). A line repeated in every question stopped being read (one study, §1). The git guard's block message already works this way: it names the way forward ("Use --force-with-lease on your own branch, or ask").

➡️ As proposed.

---

**Two notes.**
- When I close this ticket, I'll pass "Decide how we'll know the writing works" the experiment the research says nobody has run. It gives subagents the same open task with and without an example list, and the same rule worded as an order and as a fact, then counts what each version finds.
- My memory still holds the old "safety rules are the exception" test. I'll rewrite it once this round settles.