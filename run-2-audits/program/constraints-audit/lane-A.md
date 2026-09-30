# Lane A: the review family

Repository at main 9846844. Read-only pass over every template through which an orchestrator talks to a reviewing, judging or trail-checking subagent: `spec-review` (SKILL.md, the three scripts and what they emit), `interrogate` (all files), `blast-radius`, `show-me-your-work`'s trail review, the reviewer eval runner under `tests/eval/reviewer/`, this repository's `.claude/agents/`, the pstack lane wrappers under `template/.claude/agents/`, the Ticket playbook's review steps, and the hooks under `template/.claude/hooks/`.

Two things frame the result.

First, most of what a 2026-09-23 audit found in this family (`.scratch/program/leading-prompts-audit/report.md`, written at main a9ebdac) was already fixed by #137, commit c3d0b93 "Stop the review briefs from leading the witness", and P18's 2026-09-23 amendment. "Zero items is the expected result", "Read nothing beyond this brief unless...", "Run nothing.", "Under 400 words" and the judge's two heuristics are gone from `template/` and `docs/knowledge/core/`, and `tests/spec-review/no-stale-wording.sh:15` refuses each of them by hand. Each brief now opens with an explicit permission. So this lane reports what survived that sweep, plus what the sweep did not look at.

Second, the sweep did not look at three places, and all three still carry the retired wording or worse: the ten pstack lane wrappers every native reviewer actually runs inside, the 24 frozen briefs the reviewer eval still sends to live models, and the delegation hook's own block messages. The single strongest constraint in the whole family is `template/.claude/agents/pstack-*.md:12`, "Execute only the task and path scope the parent assigns", which is the system prompt of the very subagent the Standards brief's first line tells it may open any file in the repository. The prior audit flagged only the last sentence of that paragraph.

## Inventory

| # | Path | Role that receives it | Filled by | Provenance of the template |
|---|---|---|---|---|
| 1 | `template/.agents/skills/spec-review/scripts/review-brief.sh` (Standards brief) | Standards reviewer lane | the script, whole | ours |
| 2 | `template/.agents/skills/spec-review/scripts/review-brief.sh` (Spec brief) | Spec reviewer lane | the script, whole | ours |
| 3 | `template/.agents/skills/spec-review/scripts/reading-pack.sh` | both reviewer lanes (the `## Reading pack` section) | the script, whole | ours |
| 4 | `template/.agents/skills/spec-review/SKILL.md` steps 4 and 5 | the orchestrator (the brief's spec, held word for word to the script; and the judge) | prose | patched mattpocock `code-review` (`patches/mattpocock/spec-review.SKILL.md.patch`) |
| 5 | `template/.agents/skills/spec-review/scripts/review-comment.sh` | the PR comment, which becomes the next round's `## Settled in earlier rounds` | the script | ours |
| 6 | `template/.agents/skills/spec-review/agents/openai.yaml` | Codex interface metadata only | n/a | ours |
| 7 | `template/.agents/skills/interrogate/references/reviewer-prompt.md` | each interrogate reviewer | prose template with four placeholders | upstream verbatim (pstack) |
| 8 | `template/.agents/skills/interrogate/references/rubric.md` | each interrogate reviewer (pasted into 7) | prose | upstream verbatim (pstack) |
| 9 | `template/.agents/skills/interrogate/references/code-quality-review.md` | each interrogate reviewer (pasted into 7) | prose | upstream verbatim (pstack) |
| 10 | `template/.agents/skills/interrogate/references/lead-judgment.md` | the judge of interrogate step 5, `how` step 3, and `spec-review` step 5 by reference | prose | upstream verbatim (pstack) |
| 11 | `template/.agents/skills/interrogate/SKILL.md` | the orchestrator | prose | patched (SOURCES.md item 10, intent source only) |
| 12 | `template/.agents/skills/blast-radius/SKILL.md` | the blast-radius lane; its hand-back is pasted into the Spec brief's `## Blast radius` | prose | patched (SOURCES.md item 19, #108, Risks bullet only) |
| 13 | `template/.agents/skills/show-me-your-work/SKILL.md` "Cross-model review of the trail" | the trail-review lane | prose the orchestrator paraphrases into a brief | patched (SOURCES.md item 18, #111, check-trail paragraph only) |
| 14 | `template/.agents/skills/show-me-your-work/scripts/check-trail.sh` | the trail-review lane (it runs it) | the script | ours |
| 15 | `tests/eval/reviewer/reviewer.py:642` | the eval's reviewer runs | the script | ours |
| 16 | `tests/eval/reviewer/rounds/*/review/{standards,spec}-brief.md` (24 files) | the eval's reviewer runs, verbatim | frozen fixtures | ours, frozen at an old `review-brief.sh` |
| 17 | `.claude/agents/review-fable-high.md`, `review-lower-high.md`, `review-upper-high.md` | the #138 measurement's reviewer lanes | agent definition | ours |
| 18 | `.claude/agents/tier-upper.md`, `tier-lower.md` | every tiered lane this repository launches | agent definition | ours |
| 19 | `template/.claude/agents/pstack-*.md` (10 files, identical bodies) | every native pstack lane, including both `spec-review` reviewers | agent definition | upstream verbatim (pstack) |
| 20 | `template/.claude/agents/poteto-agent.md` | the default ad-hoc native helper | agent definition | upstream verbatim (pstack) |
| 21 | `template/.agents/skills/poteto-mode/playbooks/ticket.md` steps 0, 5, 8, 9, Design hole, Would-break fix | the ticket owner (itself a subagent under autopilot) | prose | ours (patch series item 2 adds the file) |
| 22 | `template/.claude/hooks/delegation.sh` | the root orchestrator only (a subagent is exempted at `:15`) | the hook's block messages | ours |
| 23 | `template/.claude/hooks/mode.sh`, `session-start.sh`, `session-mandate.md` | every session; the mandate exempts subagents at `:8` | the hook's stdout | ours |
| 24 | `template/.claude/hooks/block-dangerous-git.sh` | every agent including subagents | the hook's block message | adapted mattpocock git-guardrails |
| 25 | `template/docs/agents/review-ladder.md` | the orchestrator | prose | ours |

`.claude/hooks` and `.claude/skills` in this repository are symlinks into `template/`, so items 22 to 24 run on the factory itself.

---

## 1 and 2. The two `spec-review` briefs (`template/.agents/skills/spec-review/scripts/review-brief.sh`). Ours.

Both briefs open with `read_rule`, `review-brief.sh:508`: "You may open any file in the repository and run read-only commands, such as grep or the test suite." That is a highlight, not a limit, and it is the model the rest of this report proposes.

### (a) limits on what may be looked at or explored

**A1. `review-brief.sh:506`** (`pack_rule`, both briefs, emitted at the head of the Report section).

> The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.

Class (a), weak. The second clause is a permission and reads well. The first clause, "is the code to read", is phrased as a definition of the reading set, and next to a 65536-byte pack it invites the reviewer to treat the pack as the boundary. Provenance: 3b8c81b 2026-09-23, "Carry a reading pack in both review briefs, #107"; the commit says "the Report section says the pack is the code to read". The tail "and then read that one function or section, not the file" was removed by c3d0b93 (#137), so this is the residue of a sentence already cut down once. #107's stated reason is cost: "Reviewer lanes rebuilt the code around each hunk by opening the repository." **Replace with:** "The `## Reading pack` section above carries the code the diff touches, as it stands at the reviewed commit, so you do not have to rebuild it; the repository is open to you for everything else."

**A2. `review-brief.sh:503`** (`fix_rule`, both briefs, in `## The fix under review` on a fix-only round).

> Read each fix against its item, walk only the steps these commits touch, and report only what these commits get wrong.

Class (a) on the first limit and (c) on the second. "Walk only the steps these commits touch" tells the reviewer where it may look; "report only what these commits get wrong" tells it what it may say. Provenance: 27c43af 2026-09-22, "Review a Would-break fix once more, in a fourth or fifth round" (#93). The commit message gives the reason for the fix-only *diff* ("a round-three fix for a hard bug on the documented path went out unreviewed"), not for narrowing the reviewer's attention; #93's ask was that the fix be reviewed at all. The prior audit left this as legitimate scope. Under Manuel's 2026-09-24 ruling it is not: the round's diff is already the fix commits and nothing else, so the sentence adds nothing the diff does not already say, and it costs the reviewer the freedom to report that the fix broke something else. **Replace the paragraph with:** "The round before this one fixed these Act on items on this PR after the commit it reviewed; this round's diff is those fix commits and nothing else. Read each fix against its item. Nothing in this section says what you should find or confirm." That is, keep the surrounding sentences and delete the "only ... only" one.

**A3. `review-brief.sh:586`** (Standards brief, when no standards file exists).

> This repository documents no coding standards; the smell baseline below is the whole standard.

Class (a), weak. "The whole standard" closes a door the reviewer might otherwise open (a CONTRIBUTING.md, an AGENTS.md, an `.editorconfig`, an ast-grep rule set). Provenance: bb7c959 2026-09-18, "Let spec-review scripts write the state, the briefs and the comment" (#33). Nothing in #33 asked for it; it is a lane's phrasing for "no `--standards` file was passed". **Replace with:** "No standards file was passed for this review. The smell baseline below applies; if you find a standard documented elsewhere in the repository, judge against it and name where you found it."

### (b) limits on read-only running

None found. c3d0b93 removed "Run nothing." and `read_rule` now names read-only commands explicitly, "such as grep or the test suite".

### (c) caps on output, effort, or scope of search

**C1. `review-brief.sh:550`** (`## Settled in earlier rounds`, both briefs from round two).

> These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm.

Class (c). "Do not raise them again" removes items from what the reviewer may report before it has read the code. The third sentence is a real safeguard and should stay. Provenance: 98ba213 2026-09-18, "Run a review three rounds at most, carry only what cites a decision, and read the ticket author's comments as spec". The commit message states the reason directly: "a finding the human had already settled came back, and the only way to stop a repeat was to tell the next reviewer what to find, which is leading the witness". So the section exists *to avoid* leading, and the `cites:` gate means every carried item rests on a human decision. This is the one (c) in the family with a written reason that survives the new rule, but the imperative form is still a limit. **Replace with:** "These findings were raised in an earlier round and settled by the decision each one cites, which is quoted with each. If you reach one of them again, say what the decision misses rather than filing it as new. Nothing in this section says what you should find or confirm."

**C2. `review-brief.sh:601`** (Standards brief, item-form line).

> Skip anything tooling enforces.

Class (c). Provenance: **upstream verbatim**, mattpocock `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md:64` ("Skip anything tooling enforces. Under 400 words."). We kept this half and c3d0b93 deleted the other half. The reviewer has to guess what tooling enforces, and on this repository tooling means ShellCheck at a pin, `vp check`, ast-grep and eight bespoke gates, which no reviewer can enumerate from a brief. **Replace with:** "A breach that CI already refuses is worth one line under `## Standards breaches`, naming the check, rather than a full item." The same sentence appears at `SKILL.md:100` and would have to move with it.

**C3. `review-brief.sh:609` and `:643`.**

> Write your report to `<dir>/standards-report.md` and reply with only that path.

Class (c) on its face, but it is the hand-back format and step 6 reads the file, not the reply. Recorded under (e).

### (d) real safety rules

None in either brief. The briefs describe no side effects; the reviewer lanes are dispatched in `read-only` mode instead (`SKILL.md:115`), which is the right place for it.

### (e) hand-back format

`:493` (`Documented step:` and `Result:` lines, "an item without its `Documented step:` line is sent back"), `:494` (the `spec:` line's three forms), `:500` (`hard findings: N` exactly once), `:569` and the heading bullets at `:596-599` and `:630-635`, the `1. **Title.** body` item form at `:601` and `:637`, and the report path at `:609` and `:643`. All shape, all checked by `review-comment.sh`, none a limit on looking.

---

## 3. `reading-pack.sh`. Ours.

**(a)/(b)/(c): none found.** Its only two prose lines are highlights: `:18` "The sweep form carries no reading pack: its diff numbers lines as the swept commits did, so the files at HEAD are not the code it shows", and `:209` "Not carried, over the pack's <N> bytes: <list>. Read these at HEAD from the repository." The second is exactly the shape this audit asks for and is worth keeping as the model.

**(d)** none. **(e)** the `## Reading pack` heading and its fenced entries.

---

## 4. `spec-review/SKILL.md`. Our patch on mattpocock's `code-review`.

Step 4 is the specification of the briefs and `tests/spec-review/review-brief.sh` holds it word for word to the script, so every finding above repeats here and must be fixed in both places plus the regenerated patch.

- **`SKILL.md:89`**, the pack rule, word for word. Same as A1.
- **`SKILL.md:81`**, the fix-only paragraph, word for word. Same as A2.
- **`SKILL.md:80`**, the settled paragraph, word for word. Same as C1. The sentence that follows it in SKILL.md is ours and is good: "The section tells a reviewer what is closed, never what to find: a brief that named an expected result would be leading the witness."
- **`SKILL.md:100`**, "A documented repo standard overrides the baseline; skip anything tooling enforces." Same as C2.

Two further sentences constrain the **orchestrator**, not a reviewer, but the orchestrator is a subagent whenever a ticket runs under autopilot, so they reach a subagent by that route:

**A4. `SKILL.md:21`.**

> Do not read the diff yourself: the reviewers get it in their briefs, and you get their reports.

**A5. `SKILL.md:119`.**

> Read the two reports and the ticket, never the code under review (the delegation hook enforces this while the review state exists), and write `<dir>/judgment.md`.

Class (a) both. Provenance: bb7c959 (#33) and the #74 delegation hook (PR #75). The stated reason is real and is P11 plus the review-separation argument: the judge must not be the reader, or the two axes stop being independent. The cost is that a judge cannot check a reviewer's claim against the code before dismissing it, which is the judgment step's whole job. `SKILL.md:115` states the counter-principle in the same file: "the reviewer's context matters more than its model". **Proposed replacement, as a highlight:** "Your inputs are the two reports and the ticket; the reviewers had the diff and the reading pack, and the two axes stay independent because you judge from what they wrote. Where a report's claim is unclear, ask that reviewer rather than re-reading the diff." Whether the enforcing hook should stay is a separate call, noted under item 22.

**(d)** `SKILL.md:115` dispatches both reviewers in `read-only` mode. That is the right kind of rule: it stops writes, not looking. **(e)** the heading shapes, the item forms and the `hard findings:` line, all refused by `review-comment.sh:150`.

---

## 5. `review-comment.sh`. Ours.

**(a)/(b)/(c): none found.** Everything it emits is either verbatim report text or a refusal aimed at the orchestrator ("wait for the reviewer; do not write the report yourself", `SKILL.md:150`, a delegation rule and not a look-limit). Its output becomes the next round's carried set, covered under C1.

**(d)** none. **(e)** the whole script is the comment's shape: `## Standards`, `## Spec`, `## Judgment`, the summary line, `round: N of 3`, `act-on items: N` last.

---

## 6. `spec-review/agents/openai.yaml`. Ours.

Three lines of Codex interface metadata. **None found.**

---

## 7. `interrogate/references/reviewer-prompt.md`. Upstream verbatim (pstack).

This is the whole prompt each interrogate reviewer gets. It has no sentence telling the reviewer it may open the repository; `{DIFF_OR_FILES}` is all it is handed, and the only encouragement to explore sits one level down in the rubric. That absence is itself worth fixing under Manuel's rule.

**A6. `reviewer-prompt.md:15`.**

> You are reviewing whether the code achieves this intent well. Do NOT question the intent itself. Assume the goal is correct and challenge the execution.

Class (c), and (a) in effect. Upstream verbatim; our patch (SOURCES.md item 10) touched only where the intent comes from. It has a real purpose: with a ticket, the intent is the human's words and re-litigating it wastes the round. But `spec-review` has a name for a finding that the intent itself is wrong, a design hole (P27), and telling every reviewer to assume the goal is correct is how a hole goes unreported. **Replace with:** "The intent above is the human's ask, quoted from the ticket. Review whether the code achieves it. If you conclude the ask itself cannot be met as written, say so and show why; otherwise challenge the execution."

**C4. `reviewer-prompt.md:31`.**

> Review the code through every lens in the rubric and the code-quality lens above that you find relevant. Do not force lenses that don't apply.

Class (c), weak; "that you find relevant" leaves the choice with the reviewer. **Keep**, or drop the second sentence as redundant.

**C5. `reviewer-prompt.md:38`.**

> Only include nits if they're genuinely useful, not to pad your review.

Class (c). Upstream verbatim. **Replace with:** "Mark a style or naming point `nit` so the judge can sort it; there is no limit on how many you file."

**C6. `reviewer-prompt.md:54`.**

> Raising hypothetical issues ("what if someone passes null here") without evidence that the code path is reachable

Class (c). This is an evidence bar, and the prior audit called it a scope rule. It is worth keeping in substance, but it currently reads as "do not raise", which under the new rule should become a requirement on the item rather than a ban. **Replace with:** "If you suspect a path is reachable and cannot show it, file the finding and say what you could not trace."

**C7. `reviewer-prompt.md:55`.**

> Praising the code. You're an adversary, not a cheerleader. If you find nothing wrong, say "no findings" and stop.

Class (c), weak. "Say no findings and stop" is a permission for an empty review, which `:59` repeats ("An empty review is a valid outcome"). **Keep.**

**(d)** none. **(e)** the `## Findings` block at `:61-71` (severity, location, finding, evidence, optional suggestion).

**Gap, not a constraint:** the template never tells the reviewer it may open the repository. Since `spec-review`'s briefs now do, and since interrogate reviewers run inside `pstack-*.md` (item 19), the omission is load-bearing. **Add, as the first line of the Instructions section:** "You may open any file in the repository and run read-only commands, such as grep or the test suite; the diff above is where to start, not where to stop." This needs a new patch under `patches/pstack/interrogate/`.

---

## 8. `interrogate/references/rubric.md`. Upstream verbatim (pstack).

**C8. `rubric.md:72`.**

> Only flag security issues you can actually trace through the code. "This could be an injection vector" without showing the input path is not useful.

Class (c). The same shape as C6, and more costly here because security is an ask-by-default category in both `bugbot-triage.md` and `spec-review` step 5's `## Ask`, which exists precisely so an uncertain security point reaches the human. **Replace with:** "Trace a security finding through the code and show the input path. If you cannot complete the trace but the shape worries you, file it and say where the trace stopped; the judge routes security findings to the human."

Everything else in this file pushes the right way and should be quoted as the model: `:17` "When you find a potential bug, trace the execution path", and `:23` "Answering this often requires looking beyond the changed files. Read the surrounding code (callers, callees, type definitions, sibling modules) ... Use the tools available to you (Read, Grep, Glob) to explore." That sentence is the clearest "here is what you CAN look at" in the family, and it contradicts `pstack-*.md:12` head on.

**(d)** none. **(e)** none.

---

## 9. `interrogate/references/code-quality-review.md`. Upstream verbatim (pstack).

**C9. `code-quality-review.md:39`.**

> Prioritize structural code-quality regressions and missed simplifications first, then spaghetti and branching complexity, then boundary, type, and file-size concerns, then smaller modularity and legibility issues. Do not flood the review with low-value nits when larger structural issues exist. Prefer a few high-conviction comments over a long list of cosmetic notes.

Class (c), on the last two sentences. The prior audit read this as ranking rather than capping. Under Manuel's rule, "a few" and "do not flood" are an output cap dressed as an ordering. The ordering sentence earns its place; the two after it do not. **Replace the last two sentences with:** "Order your findings that way so the reader can stop at any point; file every one you have."

**(d)** none. **(e)** the ordering itself, arguably.

---

## 10. `interrogate/references/lead-judgment.md`. Upstream verbatim (pstack).

This is the judge framework for interrogate step 5, `how` step 3, and, by the reference at `spec-review/SKILL.md:119`, the `spec-review` judgment that decides `act-on items:` and therefore whether a PR is merge-ready. #137 removed our paraphrase of these two sentences from `SKILL.md`; the sentences themselves survive here and are still reached by the link.

**C10. `lead-judgment.md:20`.**

> Reviewers, especially adversarial ones, tend to fill their review. If they don't find critical issues, they'll inflate nits to fill the space. If a reviewer's findings are all nits and style preferences, the code is probably fine. Say so.

Class (c), and (a) in effect: it hands the judge a verdict derived from the shape of the report instead of from the code. Provenance: upstream verbatim. Our paraphrase of it was deleted by c3d0b93 with the reason recorded in P18's amendment and in Manuel's words, "I HATE leading witness prompts". **Replace with:** "A report of only nits tells you what that reviewer filed, not what it missed. Sort each item on its merits." New patch under `patches/pstack/interrogate/`.

**C11. `lead-judgment.md:56`.**

> A good verdict is useful, not comprehensive. The user should be able to read the "Act On" section, fix those issues, and ship with confidence. If your "Act On" list has more than 5 items, you're probably not filtering hard enough.

Class (c), an item-count cap on the judged output. This is the sharpest instance of a derived cap beating a stated principle left in the family, and in `spec-review` the Act on count is the merge gate, so the cap has teeth the upstream author never intended. **Replace the last sentence with:** "Order Act On by severity so the user can stop reading at any point; its length is whatever the code earned." New patch, same file as C10.

`:24` ("only a finding if the caller can actually pass null. Trace the call site") and `:32` (the "I would have done it differently" category) are dismissal criteria that require a reason, and stay.

**(d)** none. **(e)** the four buckets and the one-line rationale per finding.

---

## 11. `interrogate/SKILL.md`. Patched (intent source only).

**C12. `SKILL.md:35`.**

> Reviewers challenge whether the work achieves the intent well, not whether the intent itself is correct.

Class (c). This is the orchestrator-facing twin of A6; fix both together, or the brief and the skill disagree. **Replace with:** "Reviewers challenge whether the work achieves the intent; a reviewer that concludes the intent cannot be met as written says so."

**(d)** `SKILL.md:10` "The deliverable is a synthesized verdict. Do NOT auto-apply changes." `SKILL.md:48` routes each reviewer "with `read-only` access and a unique output/receipt path" and refuses a silent model fallback. All three are side-effect and integrity rules and stay.

**(e)** step 4's synthesis fields and the Output Format section's five headings.

---

## 12. `blast-radius/SKILL.md`. Patched (#108, the Risks bullet only).

The lane's hand-back is pasted verbatim into the Spec brief's `## Blast radius` on a cross-cutting diff, so whatever steers this lane steers that review too.

**C13. `SKILL.md:33`** (step 2).

> Find the one fact it's safe because of. Most changes that look scary are safe because of a single fact ... If it holds, most of the scary cases die at once. Spend your time here, not on a long list of maybes.

Class (c), effort direction, with (a) priming toward "safe". Upstream verbatim; our patch touched only `:43`. The heading above it, "Don't trust your own writeup", pushes the other way, and `:16` is good ("that is the trap you are walking into"). **Replace the last sentence with:** "A change can rest on one such fact, on several, or on none. Try to break the fact before you try to prove it, and say which it turned out to be."

**C14. `SKILL.md:12`.**

> Listing the callers is not the job. The agent can grep those in a second. The job is the breakage grep won't show you.

Class (c), weak, and arguably a highlight of where the value is. **Keep.**

**C15. `SKILL.md:35`** (step 4), "Keep the risks you confirmed; list the ones you checked and cleared separately", and **`:43`** "Only the real ones, one per line." Class (c), weak. Both require evidence rather than forbidding a look, and `## Cleared` gives the unconfirmed ones a home. **Keep.**

**(d)** `:47` "strip anything private before it goes anywhere public". **(e)** the five bullets of "What to hand back", the one-risk-per-line rule and the `fixed: <sha>` / `accepted: <reason>` disposition grammar that `review-brief.sh` parses.

---

## 13. `show-me-your-work/SKILL.md`, the trail review. Patched (#111, the check-trail paragraph only).

**C16. `SKILL.md:66`.**

> The subagent reads the audit trail and the run's transcript, then flags what the user should pay attention to. Not a redo of the work, a scan for what's suboptimal or risky.

Class (c). "A scan" tells the reviewer to skim a transcript that is the only record of the run. Upstream verbatim. Against it stands `ticket.md:26`, ours: "on 2026-09-22 three of five lanes ran it and all three found something the owner had wrong". A pass that pays three times out of three should not be described as a scan. **Replace with:** "Not a redo of the work: follow each row's evidence to its source and check it holds, and read the transcript around anything the trail skips."

**A7. `SKILL.md:55`** (the run's own self-audit, not the reviewer's brief).

> Read this run's transcript under Claude Code's per-project transcripts directory at `~/.claude/projects/<encoded-cwd>/`. Don't glob across `~/.claude/projects/`; that reads unrelated private chats.

Class (a) by form, but this is a privacy rule about other people's conversations and its reason is stated in the sentence. **Keep.** Listed here only because it matches the grep for a read limit.

**(d)** the privacy rule at `:55` above; `:50` "Append-only. A wrong call gets a new row that supersedes it. Never edit or delete history."

**(e)** `:75` the "Attention" section, `reviewed by <model>` on its own line, "'No flags' is a valid value; the model name is not", and `:68`'s placement rule for a `check-trail.sh` refusal.

**Worth quoting as the model for the whole audit:** `ticket.md:17`, ours, #109/P109: "The trail review's brief asks it to list every lane launch it finds in the trail and the transcripts, and gives it no list, ceiling or count to compare against; you compare its list with this tier's rule in your hand-back, after it reports." P109's own amendment records Manuel's reason, that criterion 4's list "was a prediction, not a constraint". That is this ruling already encoded once.

---

## 14. `show-me-your-work/scripts/check-trail.sh`. Ours.

**(a)/(b)/(c): none found.** It emits `ok: <N> rows in order inside the run <first> to <last>` or one line per offending row. No prose reaches the reviewer beyond that.

**(d)** none. **(e)** its exit codes and the line form `line <n> <ts>: <reason>`, which `SKILL.md:68` routes under Attention.

---

## 15. `tests/eval/reviewer/reviewer.py`. Ours.

The prompt, `reviewer.py:642-643`:

> Read `<checkout>/<dir>/<axis>-brief.md` whole and follow it. You are working in `<checkout>`; every relative path in the brief is relative to it.

**(a)/(b)/(c): none found.** It is the cleanest template in the family. `reviewer.py:54`'s `BANNED` list refuses a prompt that would leak the words "eval", "test", "judge", "score", "benchmark", "candidate", "rubric", "experiment", "compare" or "arena" through the working path, so the reviewer never learns it is being measured.

**(d)** the runner dispatches Codex lanes in `isolated-write` mode into a throwaway checkout. **(e)** none; the brief owns the shape.

---

## 16. The 24 frozen eval briefs (`tests/eval/reviewer/rounds/*/review/{standards,spec}-brief.md`). Ours, frozen.

These are live prompts: `reviewer.py` copies each one into a fresh checkout and hands its path to a real model. All 24 still carry the wording #137 deleted from `template/`.

- **"Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing."** at `tests/eval/reviewer/rounds/pr94-r1/review/standards-brief.md:3` and in all 24 briefs. Classes (a) and (b) together, and the strongest pair in the family: the reviewer may read only once it already has a finding, so it cannot read in order to find one, and it may run nothing at all.
- **"Zero items is the expected result for a clean change."** at `.../pr94-r1/review/standards-brief.md:103` and in all 24 briefs (plus three `review/diff` fixtures that quote it). Class (c), and a stated expectation of the result.
- **"... Read nothing beyond this brief ... Under 400 words."** at `.../pr94-r1/review/standards-brief.md:118` and `.../pr94-r1/review/spec-brief.md:113`, in all 24. Class (c), a word cap that on an item-per-bug report is a finding cap.

Provenance: 1a73022 2026-09-17 (#33), bb7c959 2026-09-18 (#74) and e691e3f 2026-09-21 (#81), as the prior audit traced them; frozen into these fixtures by #103's eval work. Nothing asked for them to persist here.

`tests/spec-review/no-stale-wording.sh:15` greps only `template` and `docs/knowledge/core`, so it does not see these. The consequence is not only stylistic: the eval now measures a brief the factory no longer ships, so its scores cannot be compared with the current reviewer, and #137's fix is unmeasured. The `.scratch/program/agent-briefs.md` snapshot at `:128` carries as a criterion that no brief "states an expected number of findings, a word or item cap, or a limit on what the reviewer may read or run read-only", which these 24 files fail.

**Proposal:** this is a deliberate baseline, so the fix is not a silent rewrite. Either (i) rebuild the fixtures from the current `review-brief.sh` with `rebuild.sh` and re-run the eval, keeping the old scores as a separate labelled baseline, or (ii) keep the fixtures and say in `no-stale-wording.sh`'s comment and in the eval's docstring that the frozen briefs carry pre-#137 wording on purpose and that their scores do not describe the shipped reviewer. Which one is a call for the human; flagging it, not fixing it.

---

## 17 and 18. This repository's own agent definitions (`.claude/agents/`). Ours.

`review-fable-high.md:8`, `review-lower-high.md:8` and `review-upper-high.md:8`:

> You are a lane launched by a parent session. Do exactly the task in your prompt.

`tier-upper.md:7` and `tier-lower.md:7` add "If the prompt says to invoke the poteto-mode skill first, do that before anything else."

**C17.** "Do exactly the task in your prompt." Class (c), weak. It is a role statement more than a limit and says nothing about files, tools or reading. Provenance: ours, 2026-09-22 and 2026-09-23 by file date; the `tier-*` descriptions name Manuel's 2026-09-22 model-pinning rule, which is what he asked for, while this sentence is the lane's own. **Keep, or soften to:** "You are a lane launched by a parent session. The task in your prompt is what to deliver; how you get there is yours." Given that these five definitions carry the only body a reviewer lane launched from this repository gets, the better change is to add the permission: "You may open any file in the repository and run read-only commands."

**(d)** none. **(e)** none.

---

## 19. The pstack lane wrappers (`template/.claude/agents/pstack-*.md`, 10 identical files). Upstream verbatim (pstack), byte for byte with `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/agents/`.

This is the finding that matters most in my area. `spec-review/SKILL.md:115` says "a native lane is the matching `pstack-<family>-<effort>` subagent", so the Standards reviewer runs as `pstack-opus-medium` and the Spec reviewer as `pstack-opus-high`. Interrogate's native reviewers, the architect judge and every other native pstack lane run under the same body.

**A8. `template/.claude/agents/pstack-opus-medium.md:12`**, and the same line 12 in all ten files.

> Execute only the task and path scope the parent assigns. Read the grounding artifacts by path. Do not choose another model, spawn another agent, or start a pstack workflow. If the assignment is read-only, do not modify files. Return the requested artifact or verdict plus a concise rationale.

Four findings in one paragraph.

1. **"Execute only the task and path scope the parent assigns."** Class (a), the strongest in the family. This is the system prompt; the brief is the user turn. A reviewer reads "only the task and path scope the parent assigns" before it reads "You may open any file in the repository and run read-only commands". The two contradict, and the system prompt usually wins. #137's fix to the briefs is partly cancelled here. The prior audit quoted only this paragraph's last sentence and missed this one.
2. **"Read the grounding artifacts by path."** Class (a), weak alone, reinforcing (1) in context.
3. **`disallowedTools: Agent, Task`** in the frontmatter of all ten. Class (c), a tool-set limit. It has a real purpose, since a lane must not fan out its own swarm, and it is closer to a (d) rule than a look-limit. Noted, not proposed for removal.
4. **"Return the requested artifact or verdict plus a concise rationale."** Class (c), mild; the prior audit flagged this one. "Concise" is an output cap wherever a brief leaves the shape open.

Provenance for all four: **upstream verbatim**, unchanged since vendoring; no ticket of ours asked for any of it. Changing them needs a new patch under `patches/pstack/agents/` listed in `patches/series` with a SOURCES.md line, because `factory918 sync` re-vendors them.

**Proposed replacement for line 12:**

> The parent assigns the task and names the artifacts to start from. You may open any file in the repository and run read-only commands, such as grep or the test suite, to do it well. Do not choose another model, spawn another agent, or start a pstack workflow. If the assignment is read-only, do not modify files. Return the requested artifact or verdict in the shape the brief asks for, with your reasoning.

**(d)** "Do not choose another model, spawn another agent, or start a pstack workflow" (route integrity, and the reason cross-provider agreement means anything) and "If the assignment is read-only, do not modify files". Both stay.

**(e)** "Return the requested artifact or verdict", minus "concise".

---

## 20. `template/.claude/agents/poteto-agent.md`. Upstream verbatim (pstack).

**(a)/(b)/(c): none found.** Its body instructs the lane to read `poteto-mode`'s SKILL.md in full and to navigate to a leaf principle skill when applying one. Both widen rather than narrow. Note the asymmetry: the default ad-hoc helper gets no scope limit, while every model-pinned reviewer lane does.

**(d)** none. **(e)** none.

---

## 21. `poteto-mode/playbooks/ticket.md`, the review steps. Ours.

**A9. `ticket.md:13`** (step 0, the `eco` tier, item 3).

> You run `spec-review` without a review lane: its step 1 script, its two reviewers launched by you with their briefs' paths and polled per the poll rule, its judgment and its comment. Read no brief and no diff while the review state exists; the two reviewers are the fresh context.

Class (a). Under `eco` the ticket owner is itself a subagent, so this is an orchestrator telling a subagent what it may not read. Provenance: 2a4730a 2026-09-23, "State the safe and eco tiers once in Ticket step 0 and point to them where lanes launch", ticket #109, decision P109. #109 asked for the lane count to drop, in its own criterion: "the owner runs the review script and launches the two reviewers directly (no review wrapper lane)". It did not ask for a read ban, and P109 itself renders the rule as "runs `spec-review` without a wrapper lane and judges its reviewers' findings itself". The ban is the lane's extension of the review-separation argument at `SKILL.md:119` into a tier where the hook does not apply (P109: "The delegation hook reads no tier"; `delegation.sh:15` exempts every subagent). **Replace the last sentence with:** "The two reviewers are the fresh context on this diff, and your judgment rests on what they wrote; where a report's claim is unclear, ask that reviewer."

**C18. `ticket.md:45`** (Design hole, step 1).

> Read the `hole:` reference on each marked item: a cell, a signature or a criterion. That is the scope; nothing wider is redesigned.

Class (c), a scope cap on the `architect` brief the orchestrator then writes. Provenance: ae85a15 2026-09-22, "Say where a design hole goes, in the skill, the ladder and the playbooks", ticket #90, decision P27. P27's recorded reason is Manuel's and is about *reviews*, not reading: "three designs graded by three reviews on PR #87 should never have been allowed to happen"; "it starts all 3 reviews over". The narrow scope keeps a restart from becoming a rewrite, which is a real control, but "nothing wider is redesigned" tells the architect runner where it may not look. **Replace with:** "Read the `hole:` reference on each marked item: a cell, a signature or a criterion. Those references are what the redesign has to fix; if the runner finds the hole reaches further, it says so and you decide before widening."

**C19. `ticket.md:56`** (Would-break fix, step 1), "it briefs the fix commits and nothing else, with the fixed items under `## The fix under review`". This describes what `review-brief.sh` does; the constraint itself is A2, and no separate fix is needed here.

**A10. `ticket.md:11`** (step 0, the `eco` tier, item 1), "launch no explorer, explainer or investigator lane". Class (a) on the orchestrator's own delegation, not on a subagent's reading. It is P109's design and Manuel approved it in #109's own words ("I agree with your choices here"). Noted for completeness; the `how` and `why` lanes are another lane's area.

**Clean, and worth keeping as the model:** `ticket.md:17`, quoted under item 13 above.

**(d)** step 1 "If `git status --porcelain` prints anything, stop"; step 3 "Every listed issue must be closed"; step 8 "Never close the issue by hand"; step 9 "Never merge"; Would-break fix step 2's `gh pr ready --undo`.

**(e)** step 0 item 5 (the one-page hand-back under five named headings), step 8's PR-body sections, the Reply line at `:28`.

---

## 22. `template/.claude/hooks/delegation.sh`. Ours.

`delegation.sh:15` is `[ -z "$agent_id" ] || exit 0`: **every subagent is exempt**, in both tiers, which P109 restates. So this hook injects text into the root orchestrator only. It is in scope because the root orchestrator judges reviews, and because its messages are the enforcement behind A4, A5 and A9.

**A11. `delegation.sh:76` and `:98`.**

> BLOCKED: <path> is under review (fixed point <ref>); the orchestrator does not read the code under review. The reviewers have the diff in their briefs; wait for their reports, or rm -rf .claude/state/review to abandon the review.

Class (a), enforced. It names its own escape hatch, which is more than the prose does. Provenance: bb7c959 (#33) for the state, PR #75 (#74) for the hook.

**A12. `delegation.sh:82`.**

> BLOCKED: <path> is <n> lines; reading it whole is the explorer lane's job. Read it in ranges with offset and limit (200 lines at most), ask /knowledge, or brief an explorer and read its report.

Class (a) and (c), enforced, with a hard numeric cap at `:28` (`max_lines=200`). This is the one place in the family where a derived cap is a mechanism rather than a sentence, and it applies to every tracked file over 200 lines in the `execute` phase. It reaches a reviewing role whenever the root session judges. **Proposed:** turn it into a warning that names the alternatives instead of a block, or keep the block only while the review state exists and let the size rule be advice. I propose no new number; a cap a lane cannot reason past is what the ruling is against.

**(d)** `:58` `guard_write`, the P11 path split (a lane writes code, the orchestrator writes records). A role rule with a decision behind it, not a look-limit; stays.

**(e)** none.

---

## 23. `mode.sh`, `session-start.sh`, `session-mandate.md`. Ours.

**(a)/(b)/(c): none found** that reaches a subagent. `session-mandate.md:8` exempts them outright: "If you were dispatched as a subagent to execute a specific task, ignore this block; the orchestrating session shaped your dispatch." `mode.sh:34` prints "REVIEW: <ref>, <n> files under review; the orchestrator's reads of them are blocked until spec-review step 5 clears `.claude/state/review`", which restates A11 at every prompt of the root session. `mode.sh:27` restricts the planning phase ("do not write production code"), a phase rule and not a look-limit.

**(d)** the planning-phase write rule. **(e)** none.

---

## 24. `block-dangerous-git.sh`. Adapted mattpocock.

**(a)/(b)/(c): none found.** It fires on subagents too, and everything it blocks is a side effect.

**(d)** the whole file, nine patterns: pushing the default branch, force-pushing either way, `reset --hard`, `clean -f`, `branch -D`, `checkout .`, `restore .`, and merging a PR. Its message at `:20` names the safe alternative ("Use --force-with-lease on your own branch, or ask"). This is the shape a real safety rule should have. It is also worth recording that this hook fires on quoted text: writing this report through a heredoc was refused once because a sentence of mine quoted one of the patterns.

**(e)** none.

---

## 25. `template/docs/agents/review-ladder.md`. Ours.

**(a)/(b)/(c): none found.** P18's 2026-09-23 amendment cleared "zero items is the expected result" from rung 1. What remains is the definition of a hard finding, the round rules and the merge-readiness predicate, all counting rules the orchestrator applies rather than instructions a reviewer reads.

**(d)** rung 4, "The agent never merges". **(e)** the `round: N of 3` and `act-on items: N` lines.

---

## Summary of (a), (b) and (c) findings

| Id | Where | Class | Provenance | Asked for? |
|---|---|---|---|---|
| A1 | `review-brief.sh:506` pack rule | a | ours, 3b8c81b (#107) | partly; the cost reason is #107's, the phrasing is not |
| A2 | `review-brief.sh:503` fix-only rule | a, c | ours, 27c43af (#93) | no |
| A3 | `review-brief.sh:586` no-standards line | a | ours, bb7c959 (#33) | no |
| A4 | `spec-review/SKILL.md:21` | a (orchestrator) | ours, bb7c959 (#33) | partly |
| A5 | `spec-review/SKILL.md:119` | a (orchestrator) | ours, PR #75 (#74) | partly, as P11 |
| A6 | `reviewer-prompt.md:15` | c, a in effect | upstream verbatim | n/a |
| A7 | `show-me-your-work/SKILL.md:55` | a, privacy | upstream verbatim | keep |
| A8 | `pstack-*.md:12` first sentence, ten files | a | upstream verbatim | no |
| A9 | `ticket.md:13` | a | ours, 2a4730a (#109, P109) | no; #109 asked to drop a lane, not a read |
| A10 | `ticket.md:11` | a (delegation) | ours, 2a4730a (#109, P109) | yes, Manuel's words in #109 |
| A11 | `delegation.sh:76`, `:98` | a, enforced | ours, PR #75 (#74) | partly |
| A12 | `delegation.sh:82`, the 200-line cap | a, c, enforced | ours, PR #75 (#74) | partly |
| C1 | `review-brief.sh:550` "Do not raise them again" | c | ours, 98ba213 | yes, with a written anti-leading reason |
| C2 | `review-brief.sh:601` and `SKILL.md:100` "Skip anything tooling enforces" | c | upstream verbatim (mattpocock) | n/a |
| C4 to C7 | `reviewer-prompt.md:31`, `:38`, `:54`, `:55` | c | upstream verbatim | n/a |
| C8 | `rubric.md:72` security trace bar | c | upstream verbatim | n/a |
| C9 | `code-quality-review.md:39` "a few high-conviction comments" | c | upstream verbatim | n/a |
| C10 | `lead-judgment.md:20` "probably fine" | c, a in effect | upstream verbatim | n/a; our paraphrase was deleted by #137 |
| C11 | `lead-judgment.md:56` "more than 5" | c | upstream verbatim | n/a; our paraphrase was deleted by #137 |
| C12 | `interrogate/SKILL.md:35` | c | upstream verbatim (our patch touched only the intent source) | n/a |
| C13 | `blast-radius/SKILL.md:33` "not a long list of maybes" | c, a | upstream verbatim | n/a |
| C16 | `show-me-your-work/SKILL.md:66` "a scan" | c | upstream verbatim | n/a |
| C17 | `.claude/agents/*.md` "Do exactly the task in your prompt" | c, weak | ours, 2026-09-22 and 2026-09-23 | the model pinning is Manuel's; this sentence is the lane's |
| E1 | the 24 frozen eval briefs | a, b, c | ours, pre-#137, frozen by #103 | no; retired wording still sent to live models |

Twelve templates in my area carry an (a), (b) or (c) sentence that needs changing. Eight of those sentences are upstream verbatim and need a new patch under `patches/pstack/` (or, for C2, a change to a line we kept from mattpocock); the rest are ours. The three that cost the most are A8, the system prompt of every native reviewer contradicting its own brief; E1, 24 live prompts still carrying the wording #137 deleted, which also leaves #137 unmeasured; and C11, a five-item ceiling on the judged list that gates merge-readiness.
