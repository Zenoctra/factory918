# Answer key audit for #138: is the key right about severity?

Nine of the fourteen bugs in the key meet the review brief's own definition of hard. Six meet it clearly and three are close calls. The other five are real problems that should move to "real but not hard", because stale prose, a skipped design step and a tampered cache do not make the documented path give a wrong or silent result. Manuel's suspicion is partly right: the key pays Opus 5 for filing those five as hard, and it docks Opus 5.5 and Fable 5.1 on two of them where their non-hard call was correct. The bigger distortion is in the measurement itself. The Standards brief tells a reviewer to cite a ticket it is never shown, and that pushes an honest reviewer to file real bugs as non-hard. That is truth bug pr99-r1 G4, still live in the harness, and two of the reviewers under test named it.

## Method

- Standard: the definition in `review-brief.sh`, with Manuel's quotes as the tiebreak. "Hard" means would break (the documented path gives a wrong or silent result) or fails open (an input outside the path proceeds silently). A refusal that says how to correct itself is not a finding. An unsupported edge case is not a flag.
- For each bug I read its proof in `tests/eval/reviewer/truth-notes.md`, the code at the round's head (`git show <head>:<file>`; heads c83f166, 69bd412, 52ccd8e) and the round's frozen ticket (`tests/eval/reviewer/rounds/<round>/inputs/ticket.md`). All of these are in worktree `agent-af1a10e904a9448aa`.
- I decided every classification before I opened any #138 report or receipt. The record is `scratchpad/classes-before-runs.txt` in this session's scratchpad, written at 20:06 CDT. I read the runs afterwards. One call got stronger after reading the runs (pr99-r1 G4, see there), and none flipped.
- Filings come from the 29 reports under `.scratch/eval/reviewer-138/runs/*/*/*/*/report.md` as they stood at about 20:10 CDT. Runs were still being added. I parsed them with `reviewer.parse_report` and the truth anchors, then read every matched item, because the anchors mis-credit four items (see "Scorer mis-credits"). The sample is small: mostly one run per cell, Fable has 5 reports, and Fable's pr99-r1 spec report is contaminated.
- Filing notation: H means filed under Would break or Fails open. N means filed under a non-hard heading. "missed" means no report names the bug. Masked passes (M2, S2) have some fixes applied, so a bug missing there is not counted as a miss.

## pr94-r1 (head c83f166, ticket #89)

### G1. `--body-file` replaces the ticket body
- Documented path: Ticket step 6, `ticket.md:10`: "the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`". Ticket #89 criterion 3: "the table is appended to the ticket's body".
- Class: **would break**. The step names `gh issue edit N --body-file` as the append mechanism, but that command sets the body to the file's contents. An agent that writes only the table to the file wipes the ticket's criteria. The word "appended" says what was meant, so a careful agent may read the body first. That makes this close, but the documented command itself is wrong. **Hard: yes.**
- Likelihood: sometimes, since every stateful ticket reaches this step. GitHub keeps edit history, so the body can be recovered.
- Cost: one sentence, read the body and write it back (b368116).
- Filing: Opus 5 H (spec/1#1). Opus 5.5 missed. Fable missed. The anchors match Fable standards/1#3, but that item is about step order, not the body.

### G2. Backticked tokens in a posted table become overlap pathspecs
- Documented path: Ticket step 1, `overlap.sh N` reads "a path the ticket names in backticks". `overlap.sh:48`: `awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip'`. Step 6 then appends a table full of backticked tokens.
- Class: **would break, loudly**. A re-run of step 1 after the table is posted reads the table's paths as the ticket's own. It can print unrelated PRs, exit 1, and tell the reply to "merge #k, or say `stack #N on #M`", which is a wrong result with a wrong remedy. It fails closed and loud, and the step 1 re-run happens only on a relaunch or a pickup. **Hard: yes, weakly.** The other reading, taken by Opus 5.5 ("both results are loud, so this does not fail open") and Fable ("it is loud, not silent"), is that a loud false stop costs one human turn and is not hard. The definition says "wrong **or** silent", so by the letter it is hard. By Manuel's "fail fast and loud" it is the mildest kind of hard.
- Likelihood: rarely.
- Cost: one regex in the awk and one test (3f5033f, 715100c).
- Filing: Opus 5 H (spec/1#2, spec/I2#2). Opus 5.5 N (standards/1#5, standards/M2#5). Fable N (standards/1#5).

### G3. architect's SKILL.md still says usage first
- Documented path: the runner prompt that the architect skill passes to each runner, `runner-prompt.md:7 @ c83f166`: "With state ...: a scenario table, then the contract derived from it, then the test list." Ticket #89 criterion 1 is scoped to the runner prompt, and it is met.
- Class: **real but not hard**. `SKILL.md:32` and `:84` ("The caller's usage is written first") contradict the runner prompt, but the prompt a runner actually works from is explicit, and Ticket step 6 tells the orchestrator to post the table. The claim that the package "can come back with no scenario table" is a guess about agent behavior, not a path that gives a wrong result. This is conflicting prose.
- Likelihood: rarely.
- Cost: one sentence (0c63fa6).
- Filing: Opus 5 H (spec/I2#1, spec/S2#1). Opus 5.5 missed. Fable H (spec/1#1).

### G4. "Four documents" where build_core copies five
- Documented path: `MANUAL.md:165`, "a project carries only the first four, under `docs/factory918/`", and the `build_knowledge.py` docstring. Criterion 6: the page is "reachable through `/knowledge scenario table`".
- Class: **real but not hard**. This is a stale count in a reading list. `/knowledge` reaches the page through INDEX.md, and `knowledge/SKILL.md @ c83f166` already lists "the scenario table" in the slim set, so criterion 6 holds. The repository's own standard ("a count or a version in prose is true at the commit that lands it") makes this a Standards breach, which is where Opus 5.5 filed it. truth-notes itself calls it "the weakest hard bug".
- Likelihood: never breaks a path.
- Cost: two lines (ca2c106).
- Filing: Opus 5 H (spec/1#3). Opus 5.5 N (standards/1#1 and #2, I2#3, M2#2, S2#1). Fable N (standards/1#2).

### G5. A failed `gh issue edit` does not stop the work
- Documented path: Ticket step 6, `ticket.md:10`. It has no failure clause, where step 8 has "Exit 2: stop and report stderr."
- Class: **refused loudly, not a finding**. A failed `gh issue edit` prints gh's own error and a nonzero exit to the agent. #89's own rule for inputs outside the path is "refused with the tool's own message ... costs no code". What happens next is agent judgment, and a missing table on the ticket shows up at the Spec review. The other reading: the playbook goes on without the artifact, which is fail-open at the process level. I think that reading is weaker, because nothing is silent to the agent.
- Likelihood: rarely (auth or network failure).
- Cost: one sentence (b368116).
- Filing: all three missed. The scorer credits Opus 5 spec/1#4 to G5, but that item is about a skipped architect step (G6). It says nothing about a failed post.

### G6. Stateful work inside one function skips architect and the table
- Documented path: Ticket step 6, "The selected playbook's architect step adds the ticket's own: when the design **adds** state ... `architect`'s first deliverable is the scenario table". `bug-fix.md:9` and `perf-issue.md:16`: "If it crosses a function boundary, `architect` first". The #89 ticket: "For anything with state, the scenario table".
- Class: **real but not hard**. This is a scope gap between the ticket's intent and the playbooks' trigger, not a wrong result on a documented path. Step 6's own trigger is a design that adds state, and a bug fix or perf fix inside one function rarely adds any. No fix was ever made (truth-notes: none at e710e99), which suggests the owners did not rate it worth fixing. The other reading, Opus 5's, is that a stateful change silently gets no table. That is a real design hole in the ticket, but "silent" here means a missing design step, not wrong output.
- Likelihood: rarely.
- Cost: a trigger edit in three playbooks, plus a decision about whether small fixes should carry tables.
- Filing: Opus 5 H (spec/1#4, spec/I2#3). Opus 5.5 H (spec/I2#1). Fable missed.

## pr96-r1 (head 69bd412, ticket #88)

### G1. One unmatched glob is dropped
- Documented path: the ticket's `## Design` table, row "A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` | 1 | fixes the glob; a gate that checked nothing is not a pass". Code, `shellcheck.sh:40`: `if [ "${#files[@]}" = 0 ]`.
- Class: **fails open**. A stale or mistyped glob next to one that matches is dropped, and the gate exits 0. That contradicts a documented row. **Hard: yes, clearly.**
- Likelihood: rarely to sometimes (a renamed directory, or a typo in the CI list).
- Cost: about 4 lines (01e5386).
- Filing: Opus 5 H (spec/1#1, standards/1#1). Opus 5.5 H (spec 1, I2; standards 1, I2). Fable H (spec/1#1).

### G2. An argument with a space is word-split
- Documented path: the Design usage, "`bash .github/shellcheck.sh .claude/hooks/mode.sh` a lane before the PR opens, on every shell file the diff changes". `CODING_STANDARDS.md:8 @ 69bd412`: "Quote every path. Paths here contain spaces." `:13`: "Test a command the way a user types it: absolute paths". Code, `shellcheck.sh:38`: `for f in $g`.
- Class: **would break**. An absolute path under `.../Under The Sun Collective/...` is split into pieces. Alone, it is refused as "no file matched" although the file exists, which is wrong. Next to any matching argument, it is skipped with exit 0, which is silent. Opus 5.5 reproduced both results (standards/1#1). **Hard: yes, clearly.**
- Likelihood: sometimes in this factory, where lanes are told to use absolute paths. Never with relative paths.
- Cost: one line, `IFS=` (72953c0).
- Filing: Opus 5 missed. Opus 5.5 H (standards/1#1, and named in spec/1#1 and I2#1). Fable missed (Fable has no pr96 Standards report).

### G3. A cached binary runs without re-verification
- Documented path: the Design row "Local ShellCheck absent or off-pin, platform pinned | downloads once". Code, `shellcheck.sh:26`: `if [ ! -x "$bin" ]`.
- Class: **unsupported edge case, not a flag**. The cache file exists only after a tarball whose sha256 was checked, because `set -e` stops before `tar` on a mismatch. Reaching the bug needs something else to write an executable at a versioned path in the user's `$TMPDIR`. The gate already trusts any `shellcheck` on PATH that prints `version: 0.11.0` (`:18`), with no checksum, so trusting the cache is the design's trust level, not a hole in it. The other reading: by the brief's letter an unexpected cache "proceeds silently", so it fails open. Opus 5.5 found one realistic variant: an interrupted `tar` leaves an empty executable, which fails loudly with "undefined error: 0" and no fix hint. That is loud, so it is not fail-open either.
- Likelihood: never on the happy path.
- Cost: about 5 lines to verify the binary on every run (a64c7e6).
- Filing: Opus 5 N (standards/1#3). Opus 5.5 H once (spec/M2#1) and N twice (standards/M2#4, S2#2, "this is a judgement call"). Fable missed.

### G4. The playbook's bare gate is not scoped to the diff
- Documented path: `opening-a-pr.md:9 @ 69bd412`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens". Ticket #88 criterion 3: "so a lane runs it before CI does".
- Class: **would break, weakly**. Taken literally, the command is the bare form. In the factory, the bare form lints only the hooks and the gate itself, so a changed `factory918.sh` or `tests/*/*.sh` passes the lane check unread. That is silent, and it defeats the criterion's purpose. CI catches the file later. In a project, the bare set equals the template CI's set, so nothing is missed there. The other reading: "on every shell file" implies passing the files, the design's usage line shows the file form, and CI is a loud backstop, so this is ambiguous prose and not hard.
- Likelihood: sometimes in the factory, never in a project.
- Cost: one sentence (ae1b4b5).
- Filing: Opus 5 H (standards/1#1, "the zero-argument gate passes over 6 of the factory's 20 files"; the scorer credits it to G1). Opus 5.5 missed. The anchors match its space-split item, but that item is G2. Fable missed.

## pr99-r1 (head 52ccd8e, ticket #90)

### G1. "hole:" in a reason is read as the field
- Documented path: the ticket's design, `ticket.md:101` in the frozen ticket: "the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`: `hole: $ref$`". The code comment at `review-comment.sh:152-155` says the same. Code, `:158`: `grep -vE "$ending" | grep 'hole:'`.
- Class: **would break, loudly**. A Noted or Dismissed reason such as "not a design hole: P3 covers it" is valid under the documented contract, and it is refused. The message says it "carries a 'hole:' field", which names the wrong cause. So the refusal does not say how to correct it, and the "refused with a message" exemption does not apply. **Hard: yes, but close.** The other reading, taken by Opus 5.5 ("the run fails loudly, so this is not a hard finding, but the refusal message points at the wrong cause") and Fable ("refused, loudly"), is that a loud false refusal costs one retry. Both of them also named the misleading message, which is what the eventual fix changed (53ca502).
- Likelihood: sometimes, since "hole:" is natural phrasing in a judgment written about design holes.
- Cost: anchor the grep, or reword the message. A few lines.
- Filing: Opus 5 missed. Opus 5.5 N (standards/1#3). Fable N (standards/1#4).

### G2. A review with no ticket cannot finish
- Documented path: `spec-review/SKILL.md @ 52ccd8e` step 2.4: "If nothing is found, the Spec sub-agent skips and the report says ... 'no spec: Standards axis only'". Code: `review-brief.sh:360` echoes `$spec_rule` into the Standards brief with no guard, and `review-comment.sh:114` refuses a counted item without `spec: $ref`.
- Class: **would break**. On the documented no-spec path, a hard Standards finding can pass the check only with an invented ticket reference. Otherwise the review cannot finish. **Hard: yes, clearly.**
- Likelihood: sometimes (ad hoc "review since X" runs, projects without tickets).
- Cost: an `if [ -n "$spec" ]` guard, about 5 lines (53ca502).
- Filing: Opus 5 H by the scorer (standards/1#1), but the item's text is G4's mechanism, with G2 implied. Opus 5.5 missed. Fable missed (its spec report is contaminated).

### G3. The manual's merge read takes the count alone
- Documented path: `MANUAL.md:103 @ 52ccd8e`: "It is ready when: ... `spec-review`'s last line on the latest commit reads `act-on items: 0`". `review-comment.sh:206-208` prints `restart` and then `act-on items: 0` when every Act on item is a hole.
- Class: **would break**. The person's documented merge checklist reads a PR as ready while a design hole is open. The agent side (the ladder, babysit, Ticket) was taught about `restart`, and the manual was not. **Hard: yes.**
- Likelihood: rarely. It needs a hole, and a check in the window before the redesign pushes.
- Cost: one clause (384bb43).
- Filing: Opus 5 N (standards/1#2). Opus 5.5 missed. Fable N (standards/1#2, filed as a divergent-change smell).

### G4. The Standards brief demands `spec:` but carries no ticket
- Documented path: #90 criterion 1 (frozen ticket line 20): "`review-brief.sh` writes that rule into both briefs". SKILL.md step 4 says the same. Code: `review-brief.sh:327-364` builds the Standards brief with `$spec_rule` and no `## The ticket`, and says "Read nothing beyond this brief".
- Class: **would break, silently**. On every ticketed review, a hard Standards finding must cite a cell, signature or criterion the reviewer was never shown. Either it invents a reference, which the check accepts and which later scopes a `hole:`, or it demotes a real finding. Both results are wrong and silent. **Hard: yes.** I rated this weak before reading the runs, because the `spec:` line looked like metadata. The runs make it firmer, because it changed filings in #138 itself (next section).
- Likelihood: often. It applies to every ticketed review with a hard Standards item. Still open at HEAD.
- Cost: paste the ticket into the Standards brief, or drop the rule from it. A few lines, plus a design decision.
- Filing: Opus 5 H (standards/1#1, "It bit this review: I could not ground a cell, signature or criterion for this item"). Opus 5.5 missed. Fable missed at pr99, but its pr94 Standards report shows the effect (standards/1#3: "not filed hard because the Standards brief carries no ticket criteria to cite").

## The measurement is biased by pr99-r1 G4

The #138 Standards briefs for all three rounds (`rounds/*/review/standards-brief.md`, for example pr94-r1 line 670 and pr96-r1 line 1161) carry the `spec:` rule and no ticket. Two of the three models said in their reports that this blocked a hard filing. Fable wrote "not filed hard because the Standards brief carries no ticket criteria to cite". Opus 5 wrote "I could not ground a cell, signature or criterion". Opus 5.5 and Fable have 12 Standards reports between them. They filed hard in only two, both on pr96-r1, where Opus 5.5 cited the gate's design by name (`spec: design shellcheck.sh [glob...]`). The other 10 have `hard findings: 0`. The non-hard filings on this axis are therefore partly caused by the brief, not only by the reviewer's severity judgment. A model that follows the brief literally is docked. A model that writes a `spec:` line anyway is paid. Opus 5's pr96-r1 standards/1#1 cites "spec: table zero-argument form/expected result" for a row it says no row covers.

## Scorer mis-credits (anchor matches that are not the bug)
- Opus 5 pr94-r1 spec/1#4 is credited to G5. The item is G6 (skipped architect). G5 was found by no one.
- Opus 5 pr96-r1 standards/1#1 is credited to G1. The item is mainly G4 (the bare gate at the factory root) and also names G1's mechanism.
- Opus 5 pr99-r1 standards/1#1 is credited to G2. The item is G4, with G2 implied.
- Fable pr94-r1 standards/1#3 counts as a demoted G1. The item is about step order, not `--body-file`.

## Summary

| Bug | My class | Hard | Bites on the happy path | Opus 5 | Opus 5.5 | Fable 5.1 |
|---|---|---|---|---|---|---|
| pr94-r1 G1 body-file | would break | yes | sometimes | hard | missed | missed |
| pr94-r1 G2 overlap tokens | would break, loud | yes (weak) | rarely | hard | non-hard | non-hard |
| pr94-r1 G3 architect usage-first | real but not hard | no | rarely | hard | missed | hard |
| pr94-r1 G4 four documents | real but not hard | no | never | hard | non-hard | non-hard |
| pr94-r1 G5 failed post | refused loudly | no | rarely | missed (mis-credited) | missed | missed |
| pr94-r1 G6 architect skipped | real but not hard | no (close) | rarely | hard | hard | missed |
| pr96-r1 G1 unmatched glob | fails open | yes | rarely to sometimes | hard | hard | hard |
| pr96-r1 G2 word split | would break | yes | sometimes (this factory) | missed | hard | missed |
| pr96-r1 G3 cached binary | unsupported edge case | no (close) | never | non-hard | hard once, non-hard twice | missed |
| pr96-r1 G4 bare gate | would break, weak | yes (close) | sometimes (factory only) | hard (credited to G1) | missed | missed |
| pr99-r1 G1 hole: substring | would break, loud | yes (close) | sometimes | missed | non-hard | non-hard |
| pr99-r1 G2 no-ticket review | would break | yes | sometimes | hard (via its G4 item) | missed | missed |
| pr99-r1 G3 manual merge read | would break | yes | rarely | non-hard | missed | non-hard |
| pr99-r1 G4 Standards brief spec: | would break, silent | yes | often | hard | missed | missed (named at pr94) |

## Verdict

- **Meets the definition:** 9 of 14. Six are clear: pr94 G1, pr96 G1, pr96 G2, pr99 G2, pr99 G3, pr99 G4. Three are close: pr94 G2, pr96 G4, pr99 G1. pr94 G2 and pr99 G1 are wrong but loud. pr96 G4 is silent at the lane but has a CI backstop.
- **Move to "real but not hard":** pr94 G3 (conflicting prose), pr94 G4 (a stale count, a Standards breach by the repository's own rule), pr94 G6 (a scope gap that no one fixed), pr96 G3 (an unsupported edge; the gate trusts PATH the same way).
- **Drop, or keep only as a non-hard note:** pr94 G5. A tool failure refused with the tool's own message is the design #89 wrote down. Also, no reviewer in #138 found it; the only credit is an anchor mis-match.
- **Where Manuel's suspicion holds:** Opus 5.5 and Fable filed pr94 G4 and pr96 G3 as non-hard, and I think they were right. The key docks them for it and pays Opus 5 for filing G3, G4 and G6 of pr94 as hard. On pr94 G2 and pr99 G1 they gave a defensible reason ("loud, not silent"). The definition's "wrong or silent" goes against them, and Manuel's "fail fast and loud" goes with them. I would score those two as close calls, not as misses.
- **Where it does not hold:** pr99 G3 is hard, and both Opus 5 and Fable filed it non-hard. pr96 G2 and pr99 G2 and G4 are hard, and Opus 5.5 and Fable missed them rather than demoted them.
- **Before the next comparison:** fix pr99 G4 in the harness briefs, or score the Standards axis separately. As it stands, the brief pushes Standards findings toward non-hard for any reviewer that refuses to invent a reference.

I am Opus 5.5, one of the models under test, and Opus 5 is my family too. The close calls above are the places where my own reading of "loud versus wrong" decides the outcome. On those I gave both readings, and I would weight a second opinion from another model family most on pr94 G2, pr96 G4 and pr99 G1.
