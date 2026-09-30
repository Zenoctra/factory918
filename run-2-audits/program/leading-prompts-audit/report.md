# Leading prompts audit

I checked 31 prompt and brief templates for agents that judge work, and 9 of them contain wording that steers the result, caps output or effort, or limits what the agent may read. The worst of it is ours: the two spec-review briefs that `review-brief.sh` writes, and the mirror text and judge step our patch added to `spec-review/SKILL.md`, carry every kind at once (an expected zero, a 400-word cap, a ban on reading or running anything). The other five are pstack upstream, verbatim, and each is milder: one sentence nudging a judge toward "probably fine", toward few grafts, toward "safe", or toward a shallow pass.

Scope: `template/.agents/skills/**`, `template/.claude/**`, `template/docs/**` sources, `tests/eval/**`, at main a9ebdac. Line numbers are from that tree. Provenance was checked three ways. A pstack file identical to `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/` (`diff -rq`) is upstream verbatim. For a patched file I checked each quoted sentence against the upstream copy with `grep -F`. For our own files I ran `git log -S` and read the ticket.

Classes: (a) primes the result, (b) caps output or effort, (c) limits evidence gathering, (d) a legitimate scope rule.

## Counts

| | templates | with an (a), (b) or (c) sentence | (a) | (b) | (c) |
|---|---|---|---|---|---|
| Ours (no upstream) | 3 | 2 (Standards brief, Spec brief) | 2 | 1 | 3 |
| Our patch on an upstream file | 2 | 2 (spec-review SKILL.md step 4 and step 5) | 3 | 2 | 3 |
| Upstream verbatim (pstack, mattpocock) | 26 | 5 (lead-judgment, arena, blast-radius, trail review, pstack lane wrappers) | 3 | 2 | 1 |
| **Total** | **31** | **9** | 8 | 5 | 7 |

Sentence counts are distinct flagged sentences in that row's templates. A sentence both briefs carry counts once. A sentence classed (a) and (b) counts under its first class, except `SKILL.md:116`, whose two clauses count once each. One upstream sentence, mattpocock's "Under 400 words.", lives on only inside our files: upstream it was one line in a brief the orchestrator wrote by hand, and we moved it into the script. It is counted under ours.

The 31 templates are these. Ours: the Standards brief and the Spec brief (`review-brief.sh`), and the eval runner prompt (`tests/eval/reviewer/reviewer.py:642`). Our patch: spec-review `SKILL.md` step 4 (the brief's specification) and step 5 (the judge). Upstream: interrogate `reviewer-prompt.md`, `rubric.md`, `code-quality-review.md`, `lead-judgment.md` and the SKILL.md step 5 verdict; how `critic-prompt.md`, `critique-rubric.md` and the SKILL.md step 3 lead judgment; arena cross-judge, pick and graft; architect synthesis and `design-red-flags.md`; the Eval playbook judge; swarm verifiers and aggregation; autopilot-full step 4, autopilot-stack step 4, shipping's per-PR verdict and orchestrate's verifier; blast-radius; the show-me-your-work trail review; reflect's judgment, tooling and divergent reviewers and synthesizer; thermo-nuclear review; `bugbot-triage.md`; maintain-verification-skill's source readers; grilling; the pstack lane wrappers `template/.claude/agents/pstack-*.md` (eleven identical bodies, counted once).

Out of scope, noted because the same wording spreads there: `why` (investigators and a synthesizer weigh evidence but do not look for problems), `template/docs/agents/review-ladder.md:6` and `docs/knowledge/core/DECISIONS.md:87` (P18). The last two are read by the orchestrator, not by a reviewer, but both repeat "zero items is the expected result for a clean change". Changing the brief means amending P18 and the ladder too.

## 1. spec-review Standards and Spec briefs (`template/.agents/skills/spec-review/scripts/review-brief.sh`). Ours.

Every reviewer reads this text. Both briefs carry the definition, the quotes, the pack rule and `common()`. The item-form lines are per brief.

1. `review-brief.sh:402` (both briefs). "Zero items is the expected result for a clean change." **(a).** It states a finding count up front, and zero is the count that ends the round. Came in with e691e3f 2026-09-21, "Define a hard finding as the documented path or a fail-open, in both briefs", PR #85, ticket #81. **Asked for**, in the sense that the wording is a #81 acceptance criterion and P18 carries it. But the agent proposed the sentence in #81's conversation ("Zero items is the expected result for a clean change, said in those words"), right after Manuel had rejected a quota because it "is going to consistently return a result with exactly 1 thing that breaks". Manuel approved the ticket as a whole. He did not ask for this sentence. **Replace with:** "Report every item that meets this definition, and only those; the report's length follows from the diff, not from any expected count." Then amend P18 and `review-ladder.md:6` to match.

2. `review-brief.sh:407` (both briefs). Manuel: "An edge case outside the intended path being unsupported is not a flag." **(a).** Manuel asked for this quote verbatim (#81: "add these two quotes as well to the list of my words that we keep quoted"). On its own it is a scope rule. Placed next to (1), it reads as a reason to drop an item, and it cuts against the definition's second half: an unsupported edge case that proceeds silently *is* a Fails-open finding. A reviewer can file that item under "edge case" and leave it out. **Keep the quote** (Manuel's words) **and add one sentence of ours after the five quotes:** "An edge case that proceeds silently is not unsupported, it fails open: file it under `## Fails open`."

3. `review-brief.sh:425` (`common()`, both briefs). "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing." **(c).** The condition is circular: the reviewer may read only once it already has a finding, so it cannot read in order to find one. The #103 audit found four of 13 labelled bugs sat in files this sentence kept closed (`.scratch/program/reviewer-eval-audit/report.md`). "Read nothing beyond" came in with 1a73022 2026-09-17 (PR #39, ticket #33). "Run nothing." came in with bb7c959 2026-09-18 (PR #75, ticket #74), carrying on 481076d, "no commands in any brief". **Unasked.** #33 asked that briefs hand reviewers content instead of commands, to cut the 130K discovery cost. It did not ask that reviewers be forbidden to read or run anything. A lane extended "do not hand the reviewer a command" into "the reviewer runs nothing". #107 later wrote "The existing 'Read nothing beyond this brief' sentences stay as they are", which kept the sentence without re-examining it. Against it stands P16's note, Manuel 2026-09-18: "the reviewer's context matters more than its model". The cap has a real reason (cost, #33). **Narrower form:** "Start from the diff and the reading pack. Open whatever else a suspicion needs, such as a caller, a callee or a test, and run read-only commands (grep, the test suite) to confirm or clear it. Do not re-derive what the pack already carries."

4. `review-brief.sh:423` (pack rule, both briefs). "…open the repository only for what the pack does not carry, and then read that one function or section, not the file." **(c).** Asked for word for word by #107 (commit 3b8c81b 2026-09-23, PR #126). "Not the file" caps the reading at one unit even when the bug spans two. **Replace the tail with:** "…open the repository for what the pack does not carry."

5. `review-brief.sh:513` (Standards) and `review-brief.sh:549` (Spec). "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file." **(c)**, the same as (3), repeated in the item-form line. Same commits. **Delete both repeats** once (3) is replaced.

6. `review-brief.sh:513` and `:549`. "Under 400 words." **(b).** It caps the output, and on an item-per-bug report that caps the finding count too: the #103 re-run ran under this cap. The wording is upstream mattpocock (`research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md:64,70`), moved into our script in 1a73022 (#39) and bb7c959 (#75). Nobody re-asked for it. The cap has a real reason: the orchestrator reads both reports into the judgment. **Narrower form:** "Keep each item's body under about 80 words plus its quoted hunk; there is no limit on the number of items, and the `## Walk` has one line per step."

Checked and left as (d): `review-brief.sh:420` (the fix-only rule, "walk only the steps these commits touch, and report only what these commits get wrong"), which keeps a fix-only round on the diff it was asked to review. `:465` "Do not raise them again" names what is settled, and its own sentence says it names nothing to find. `:503` "every smell is a judgement call, never a hard violation" (mattpocock upstream) and `:511` "they never count" are counting rules. Neither stops a reviewer from filing. `:417` is the count rule.

## 2. spec-review `SKILL.md` step 4, the brief's specification (`template/.agents/skills/spec-review/SKILL.md`). Our patch on mattpocock's `code-review` (`patches/mattpocock/spec-review.SKILL.md.patch`, SOURCES.md item 6).

The orchestrator does not paste this text. The test holds it word for word to the script, so every fix in section 1 has to land here too. The same sentences:

- `SKILL.md:79` "Zero items is the expected result for a clean change." **(a)**, as 1.1.
- `SKILL.md:83` the "not a flag" quote. **(a)**, as 1.2.
- `SKILL.md:75` "Over that, the brief hands the path `<dir>/diff`, so a reviewer reads one file and runs nothing." **(c).** 481076d 2026-09-17 ("Act on the review of #39: no commands in any brief"). **Unasked**, the same extension as 1.3. **Replace with:** "…so no brief carries a command."
- `SKILL.md:86` the pack rule. **(c)**, as 1.4.
- `SKILL.md:97` and `:108` "read nothing beyond the brief but the code around a hunk; under 400 words." **(c)** and **(b)**, as 1.5 and 1.6.

`tests/spec-review/review-brief.sh:195,200` pins the definition and the quotes. `tests/eval/reviewer/rebuild.sh` rebuilds the frozen rounds' briefs and compares them byte for byte, so a changed brief is a new eval baseline. That comparison is a reason to rerun the eval, not a reason to keep the wording.

## 3. spec-review `SKILL.md` step 5, the judge. Our patch (same patch file).

`SKILL.md:116` "…a reviewer with nothing critical inflates nits, so a report that is all nits means the code is probably fine; more than five Act on items means you are not filtering…" **(a)** and **(b).** The first clause tells the judge what to conclude from the shape of a report. The second sets an item ceiling that pushes the judge to demote real items. Our lane paraphrased pstack's `lead-judgment.md` (section 4) in 8eb32c3 2026-09-18, PR #77, ticket #76. #76 asked for the lead-judgment step "following `interrogate`'s lead-judgment reference". Restating these two heuristics in our own words was the lane's choice. The ticket did not ask for it. The judgment here also decides the count that gates the round, which makes the priming more expensive than in interrogate, where the verdict is advice. **Replace with:** "Sort every item on its merits; the Dismissed list is shown so the human can overrule you." Drop both heuristics.

Checked and left as (d): `SKILL.md:122` Consider ("not sure outweighs the cost of addressing it now") and `:124` Dismissed ("wrong, nitpicky or missing context") are sorting categories with a reason required.

## 4. interrogate `references/lead-judgment.md`. Upstream pstack, verbatim.

This file is the judge framework for interrogate step 5 and how step 3 ("Same framework as the interrogate skill"), and spec-review step 5 paraphrases it.

- `lead-judgment.md:20` "If a reviewer's findings are all nits and style preferences, the code is probably fine. Say so." **(a).** It sets a default verdict from the shape of the findings instead of from the code. **Replace with:** "A report of only nits says nothing about what the reviewer missed; judge the code, not the report's shape." Only through a patch in `patches/pstack/interrogate/`.
- `lead-judgment.md:56` "If your 'Act On' list has more than 5 items, you're probably not filtering hard enough." **(b)** and (a). It is a count ceiling on the verdict. The reason is real: the human reads Act On and ships from it. **Narrower form:** "Order Act On by severity so the human can stop reading at any point; its length is what the code earned."

Checked and left as (d): `:24` "only a finding if the caller can actually pass null. Trace the call site." requires evidence and tells the judge to go get it. `:32` "I would have done it differently" is a dismissal category with a reason required.

## 5. arena `SKILL.md`, Phase E graft (the parent judging the losers). Upstream pstack, verbatim.

`arena/SKILL.md:56` "The signal is usually one or two things per candidate, not most of it." **(a).** It primes a graft count before the parent has read the losers. **Replace with:** "Port what the base lacks and the rubric rewards; name what you rejected and why." Only through a new patch. The cross-judge brief (`:42`) and the pick (`:46-52`) are clean. They say to read every candidate end to end and to score criterion by criterion.

## 6. blast-radius `SKILL.md`. Upstream pstack, verbatim.

`blast-radius/SKILL.md:33` "Most changes that look scary are safe because of a single fact… If it holds, most of the scary cases die at once. Spend your time here, not on a long list of maybes." **(a)**, with a touch of (b). It tells the lane that the expected answer is "safe", and to spend its effort proving safety rather than looking for breakage. It feeds the Spec brief's `## Blast radius` section on cross-cutting diffs, so its priming reaches spec-review too. **Replace with:** "Find the fact the change's safety rests on, if one exists, and try to break it before you try to prove it; a change can rest on several facts or on none." `:43` "Only the real ones" is (d): each risk needs a line, a likelihood and a check.

## 7. show-me-your-work, "Cross-model review of the trail". Upstream pstack, verbatim (our patch touched only the check-trail paragraph at `:68`).

`show-me-your-work/SKILL.md:66` "Not a redo of the work, a scan for what's suboptimal or risky." **(c)**, mild. "A scan" tells the reviewer to skim. The Ticket playbook (`ticket.md:18`) records that this review found something wrong in three of three lanes on 2026-09-22, so a deeper pass pays. "Not a redo" is a legitimate scope rule and stays. **Replace with:** "Not a redo of the work: follow each row's evidence to its source and check it holds." `:75` "'No flags' is a valid value" is (d), since it permits an empty result without expecting one.

## 8. pstack lane wrappers (`template/.claude/agents/pstack-*.md:12`, eleven files). Upstream pstack, verbatim.

"Return the requested artifact or verdict plus a concise rationale." **(b)**, mild. Every native reviewer, critic and judge lane runs under this body. The standards reviewer runs on `pstack-opus-medium`. It asks for short prose about the verdict and does not cap findings. A brief's own report shape overrides it in practice. **Narrower form:** "Return the requested artifact or verdict in the shape the brief asks for." This matters only where a brief leaves the shape open.

## 9. Templates checked and found clean

All upstream unless marked. In each case, every sentence that could read as leading is a (d) scope rule or an explicit permission, not an expectation.

- interrogate `reviewer-prompt.md`. `:55` "If you find nothing wrong, say 'no findings' and stop." and `:59` "An empty review is a valid outcome." permit an empty result without predicting one. Our "expected" in 1.1 turned that permission into an expectation. `:15` "Do NOT question the intent itself" and `:54` "without evidence that the code path is reachable" are scope and evidence rules.
- interrogate `rubric.md` and `code-quality-review.md`. `:39` "Prefer a few high-conviction comments over a long list of cosmetic nits" ranks structure above nits and does not cap findings. `:43` "Do not approve merely because behavior seems correct" pushes the other way. Interrogate SKILL.md step 5 is clean too. Our patch changed only the intent source.
- how `critic-prompt.md` (`:44` "An empty critique is a valid outcome", a permission), `critique-rubric.md`, and SKILL.md step 3. Step 3 inherits section 4 by reference, so fixing `lead-judgment.md` fixes how.
- architect Phase B synthesis and `design-red-flags.md`. `:36` "even when the first looks sufficient" pushes against stopping early.
- Eval playbook judge (blinded, rubric held back, "No leakage of what's being measured").
- swarm verifiers ("PASS, ISSUES, or BLOCKED with evidence"). The aggregation's "one-line evidenced issues" at `:45` is a report format for the reader, (d).
- autopilot-full step 4 ("distrusting the PR body", "a verdict without it is not clean"), autopilot-stack step 4, shipping ("Green is not safe"), orchestrate verifier (`:90`).
- reflect's four references. "Skip trivial things" and "One-offs are not learnings" are scope rules.
- thermo-nuclear review ("Do not stop at…", "Do not approve merely because…"), which pushes against early stopping.
- `bugbot-triage.md` ("When in doubt, ask", ask-by-default categories).
- maintain-verification-skill ("Live pass. Required even when source looks clean").
- grilling.
- Ours: `tests/eval/reviewer/reviewer.py:642`. The runner prompt is neutral ("Read … whole and follow it"), and `:54` bans leak words from it. It replays the frozen briefs, so it measures section 1's wording as it stands.

## Where the pattern came from

Upstream supplies permission for an empty result ("valid outcome") and two judge heuristics ("probably fine", "more than 5"). The escalation is ours. "Valid" became "expected", the judge heuristics were restated inside a count gate, and a cost fix meant to stop handing reviewers commands (#33) grew into "read nothing, run nothing" without a ticket asking for it. The one sentence Manuel asked for verbatim, the "not a flag" quote, is sound as a scope rule. It leads only because it sits next to the expected zero and has no line tying it to Fails open.
