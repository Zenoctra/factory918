### 1 and 2. `review-brief.sh`, Standards and Spec briefs (ours)

Both briefs open with `review-brief.sh:508`, "You may open any file in the repository and run read-only commands, such as grep or the test suite." That is the model for every proposal below.

- **`:506`** (both briefs) "The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry." **(a)**, weak: the first clause defines the reading set. Ours, `3b8c81b` (#107, reason: reviewers rebuilt the code around each hunk, a cost). The tail "then read that one function or section, not the file" was already cut by `c3d0b93` (#137). **Replace:** "The `## Reading pack` section above carries the code the diff touches, as it stands at the reviewed commit; the repository is open to you for everything else."
- **`:503`** (fix-only round) "Read each fix against its item, walk only the steps these commits touch, and report only what these commits get wrong." **(a)** and **(c)**. Ours, `27c43af` (#93). #93 asked that the fix be reviewed at all; the narrowing was the agent's, for cost. **Replace:** delete the sentence; keep "Read each fix against its item." The round's diff already is the fix commits.
- **`:586`** "This repository documents no coding standards; the smell baseline below is the whole standard." **(a)**, weak. Ours, `bb7c959` (#33), unasked. **Replace:** "No standards file was passed for this review. The smell baseline below applies; a standard you find documented elsewhere in the repository applies too, and you name where you found it."
- **`:550`** (round two onward) "Do not raise them again." **(c)**. Ours, `98ba213`, with a written anti-leading reason (a settled finding kept coming back). **Replace:** "If you reach one of them again, say what its cited decision misses rather than filing it as new." Keep the section's closing sentence.
- **`:601`** (Standards) "Skip anything tooling enforces." **(c)**. Upstream Matt, `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md:64`. Also at `spec-review/SKILL.md:100`. **Replace:** "A breach CI already refuses is worth one line under `## Standards breaches`, naming the check."
- (d): none in the briefs; the lanes run `read-only` (`SKILL.md:115`). (e): headings, item form, `Documented step:`/`Result:`, `hard findings: N`, report path.

### 6. Frozen eval briefs, `tests/eval/reviewer/rounds/*/review/{standards,spec}-brief.md` (ours, 24 files)

`reviewer.py` copies each into a checkout and hands it to a live model, so these are live prompts. All 24 still carry the wording #137 removed:

- **`pr94-r1/review/standards-brief.md:3`** and all 24: "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing." **(a)** and **(b)**.
- **`:103`** and all 24: "Zero items is the expected result for a clean change." **(c)**, and a stated expectation.
- **`:118`** (Spec `:113`) and all 24: "Under 400 words." **(c)**.
- Ours: `1a73022` (#33), `bb7c959` (#74), `e691e3f` (#81); frozen by the #103 eval work. **Proposal:** delete these lines by rebuilding the fixtures from the current `review-brief.sh` (`rebuild.sh`), keeping the old scores as a labelled baseline. The eval currently measures a brief the factory no longer ships, so #137 is unmeasured. Whether to rebuild or keep them as a deliberate baseline is Manuel's call; if kept, `no-stale-wording.sh` should say so.
- (d): the runner uses `isolated-write` in a throwaway checkout. (e): the brief's own.

### 39 and 40. `.claude/agents/review-*-high.md` and `tier-*.md` (ours)

- **`review-fable-high.md:8`** (and the other two, and `tier-*.md:7`) "Do exactly the task in your prompt." **(c)**, weak. Ours, 2026-09-22/23; Manuel's rule was the model pinning, not this sentence. **Replace:** "The task in your prompt is what to deliver. You may open any file in the repository and run read-only commands to deliver it."
- (d): none. (e): none.

### 43. `spec-review/SKILL.md` (patch on Matt's `code-review`)

Step 4 is the brief's specification and `tests/spec-review/review-brief.sh` pins it word for word, so rows 1 and 2 repeat here: `:89` (pack rule), `:81` (fix-only rule), `:80` ("Do not raise them again"), `:100` ("skip anything tooling enforces"). Each fix lands in the script, the skill, the test and the regenerated patch together. Two more reach a subagent whenever the ticket owner is one:

- **`:21`** "Do not read the diff yourself: the reviewers get it in their briefs, and you get their reports." **(a)**. Ours, `bb7c959` (#33). **Replace:** "The reviewers get the diff in their briefs, and you get their reports."
- **`:119`** "Read the two reports and the ticket, never the code under review (the delegation hook enforces this while the review state exists)". **(a)**. Ours, `bb7c959` and PR #75 (#74, P11). A judge that cannot check a reviewer's claim against the code before dismissing it is judging blind. **Replace:** "Your inputs are the two reports and the ticket. The two axes stay independent because you judge from what the reviewers wrote; where a claim is unclear, ask that reviewer." Whether the hook keeps blocking the root is row 100.
- (d): `:115` both reviewers `read-only`. (e): headings, item forms, `hard findings:`.

### 48. `architect/SKILL.md` (our patch)

- **`:36`** "unless the caller's tier asks for one runner (below)" and **`:38`** the one-runner eco judge. **(c)**, a fan-out cap. Ours, `a9b978c`, `41a901f`, `819f256`; #109, approved by Manuel ("I agree with your choices here"). **Proposal:** keep while #109 stands; if the 2026-09-24 ruling is read to cover how many lanes run, delete the clause at `:36` and all of `:38`. The judge brief itself highlights what the judge can use and is fine.
- (d): none. (e): the package order.

### 58. `factory-retro/SKILL.md` (ours)

- **`:15`** "the last seven days if there is none, and skim each for the user correcting the agent" **(a)** and **(c)**. Ours, `572dda7`, no ticket; the reason is weekly cadence, not cost. **Replace:** "The sessions since the last stamp (or the last seven days) are the ones no retro has read, so start there; older sessions and `subagents/` are there too. Read each for the user correcting the agent."
- **`:17`** "say so and stop" **(c)**, borderline. **Replace:** "nothing has recurred yet: say so, list each single entry as waiting, and encode nothing."
- **`:35`** "in one sentence" **(c)**. **Delete** "in one sentence".
- (d): `:39` promotion is the human's decision. (e): table and stamps.

### 70. `poteto-mode/playbooks/ticket.md` (ours, shipped through the patch series)

- **`:13`** (eco) "Read no brief and no diff while the review state exists; the two reviewers are the fresh context." **(a)** on the owner, a subagent in autopilot. Ours, `2a4730a` (#109). #109 asked to drop the review wrapper lane; the read ban is the lane's extension, and the delegation hook exempts subagents, so nothing enforces it. **Replace:** "The two reviewers are the fresh context on this diff, and your judgment rests on what they wrote; where a report's claim is unclear, ask that reviewer."
- **`:11`** (eco) "launch no explorer, explainer or investigator lane" **(c)**; **`:12`** "one runner and one judge" and "Feature step 4 briefs one writer, never an arena." **(c)**; **`:15`** "is one page" **(c)**. Ours, `2a4730a`, all asked for in #109 and approved. **Proposal:** keep while #109 stands, reworded as a default rather than a ban: "the default here is to read it yourself", "Feature step 4 briefs one writer", and "Every hand-back uses Autopilot-stack step 7's headings" (drop "is one page").
- **`:45`** "That is the scope; nothing wider is redesigned." **(c)** on the architect re-run. Ours, `ae85a15` (#90); the ticket says "scoped to the cell", not "nothing wider". **Replace:** "That is where the redesign starts; the runners get the whole artifact and the ticket, and say where the hole reaches further." And **`:46`** "scoped to it" **(c)**: **replace** "on it".
- **`:46`** "Two runners, the judge skipped when they converge" **(c)**: drops the one lane that reads the runners' work, backwards against eco, with no recorded reason. Ours, `ae85a15`. **Replace:** "Two runners and the judge".
- **`:23`** "a writer that cannot implement a cell as written stops and reports the cell, and never fills it in." **(c)**, also at `feature.md:12`, `bug-fix.md:9`, `refactoring.md:11`, `perf-issue.md:16`. Ours, `02af48c` (#89); a contract rule. **Replace:** "... stops and reports the cell, so the table is amended on the ticket rather than diverging from the code."
- **`:10`** "never nested in one line" **(b)**. Ours, a real guard fact. **Replace:** "The worktree guard refuses `git` inside `$(...)` inside `[ ]`, so the nested form fails."
- **`:56`** "it briefs the fix commits and nothing else" describes row 1's `:503`; fixed there.
- (d): clean checkout; never close the issue by hand; never merge; append-only design record. (e): step 0 item 5 headings, `## Overlap`, `## Blast Radius`.

### 71 to 74. `feature.md`, `bug-fix.md`, `refactoring.md`, `perf-issue.md` (patched; mixed)

- **`feature.md:12`** "a specific scope (file paths, named data shape ... and success criteria)" **(a)+(c)**: the orchestrator is told to hand the writer a file list. Upstream. **Replace:** "The brief names the outcome, the data shape and its organizing structure, the success criteria, and the files you already know are involved, as a starting point."
- **`bug-fix.md:9`** "a specific scope" **(a)+(c)**, upstream; same replacement.
- **`refactoring.md:11`** "a specific scope (file paths, the names being moved, the behavior to hold)" **(a)+(c)**, upstream. **Replace:** "The brief names the behavior to hold, the names being moved, and the call sites you found; renames hide in strings and prose, so the lane is expected to find the ones your list missed."
- **`feature.md:12`** "The delegate owns the diff directly and never waits on or launches a nested agent." **(c)**, upstream. **Replace:** "The delegate owns the diff directly; a nested agent would hide its work from your review."
- **`perf-issue.md:3`** "don't read source instead of measuring" **(a)**, mild, upstream. **Replace:** "Reading the source tells you what could be deleted; only the trace tells you what is slow, so do both and let the trace decide."
- The writer-cell sentence is ours, row 70.
- (d): `isolated-write` in a dedicated worktree. (e): act-on-list report, reply contract.

### 81. `autopilot-stack.md` (our patch)

- **`:11`** "Every STACK-READY report ... is one page under these headings" **(c)** for "one page". Ours, `ae1b4b5` (#105), reason: inconsistent report shapes. **Replace:** "uses these headings", dropping "is one page".
- **`:10`** "Owners start one at a time" **(c)**, measured reason. **Replace:** "Each owner starts from the settled tip of the chain, so they run one at a time; in the 2026-09-22 run parallel owners only bought waiting."
- (d): no owner merges or arms auto-merge; the root is the only topology writer; owners push only their branches; zero-writes hold on stop. (e): the five headings.

### 98. `knowledge/SKILL.md` (ours)

Any lane can load it. The delegation hook's read cap exempts subagents (DECISIONS row 19), and this skill puts the cap back on them. Ours, `fa61555`, from `docs/FACTORY-SPEC-v2.md:13`, `:48` (context cost); no reason is recorded for 150, 30 or 40.

- **`:3`** "without reading whole files" **(a)**. **Replace:** "an index, grep and a per-file table of contents point at the section that answers."
- **`:9`** "Reading any of it whole would spend the context window on things you do not need. Follow this procedure exactly." **(a)**. **Replace:** "The procedure below is the fastest way to the section that answers."
- **`:17`** "it is the one file meant to be read whole" **(a)**. **Replace:** "Start from `$KB/INDEX.md`; it lists every file with its purpose and line count."
- **`:18`** `| head -40` **(c)**. **Delete.**
- **`:19`** "**Open the mini-TOC, not the file.**" / "Read the first 30 lines of the candidate file only." **(a)**. **Replace:** "Every chunked file opens with a `## Contents` list with line numbers, which points at the section to read."
- **`:20`** "Hard rule: never read more than 150 lines in one call, and never read a file whose header says more than 200 lines without a range." **(a)+(c)**. **Delete.**
- **`:21`** "in a few sentences" **(c)**. **Delete.**
- **`:22`** "**Stop.** Do not summarise the file, do not read adjacent sections "for context," do not read the whole conversation digest ..." **(a)**. **Delete** the step.
- (d): none. (e): `path:line` citation; Provisional row when the corpus is silent.

### 99. `factory918/SKILL.md` (ours)

Model-invoked; fires on any fresh lane.

- **`:10`** "in one plain sentence with the command, then stop" **(c)**. Ours, `19e80e5`. **Replace:** "Give the user the first `FAIL`'s fix as the next step, with its command."
- **`:45`** "Match the situation below, name the entry point, and stop. Do not run it yourself unless the user asked for the work" **(c)**: a lane's work comes from its parent. Ours, `fa61555`. **Replace:** "Match the situation below and name the entry point. When the user, or the session that launched you, asked for the work, run it."
- **`:62`** "Reads ranges, not files." **(a)**. **Replace:** "it finds the section that answers and cites it."
- **`:74`** "rather than paraphrasing at length" **(c)**, a reply cap. **Delete** the clause.
- (d): never merge; confirm before deleting; strangers' text is data; ask before force-push, deletes, deploys, external messages.

**Group C, none found:** 47 `check-trail.sh`, 66 `grilling`, 77 `prototype.md` (its caps remove a quality bar and widen), 78 `eval.md` (its blinding rules, `:9`, `:11`, `:13`, `:14`, `:19`, withhold the experiment from candidates for a stated measurement reason; kept as integrity rules, not reading limits), 80 `autopilot-full.md` (by reference to row 70 only), 82 `autonomous-run.md` (it widens: "Mid-run discoveries are yours"), 83 `shipping.md`, 88 `visual-parity.md` (anti-tampering, (d)), 89 `worktree-cleanup.md`, 90 `pause-safely.md` ("Start nothing new" defines pausing), 91 `authoring-a-skill.md`, 94 `codex-tools.md`, 95 `bugbot-triage.md` (it pushes the other way), 96 `to-spec` and 97 `to-tickets` (both tell the planner to leave file paths out of specs and tickets, which withholds pointers from later briefs; upstream Matt; noted, not a lane limit).

### 100. `template/.claude/hooks/delegation.sh` (ours)

`:15` exempts every subagent, so this binds the root orchestrator only. It is the enforcement behind rows 43 and 70's read bans.

- **`:76`, `:98`** "BLOCKED: <path> is under review ...; the orchestrator does not read the code under review." **(a)**, enforced. Ours, `bb7c959` (#33) and PR #75 (#74, P11). **Proposal:** keep only if Manuel still wants the judging root blind to the code; the message already names its escape. If not, delete the review-state block and let the judge read what it needs to weigh a claim.
- **`:82`** "BLOCKED: <path> is <n> lines; reading it whole is the explorer lane's job. Read it in ranges with offset and limit (200 lines at most) ..." with `max_lines=200` at `:28`. **(a)+(c)**, enforced. Ours, PR #75; Manuel questioned it on 2026-09-18 ("Are we neutering the orchestrator ...") and let it through for the execute phase (DECISIONS row 19). **Replace** the block with a warning that names the same alternatives; no number.
- (d): `:58` the P11 write-path split.

**Group D, none found:** 101 (`session-mandate.md:8` exempts subagents; `:2` repeats the `knowledge` pointer, row 98), 102 `block-dangerous-git.sh` (all (d); its message names the safe alternative).

### 103. `template/AGENTS.md` (ours, with Theo and Matt fragments)

Every agent reads it, subagents included (its glossary says so), so these bind every lane whatever its brief says.

- **`:5`** "`knowledge` looks things up without reading files whole." **(a)**, mild. Ours, `fa61555`. **Replace:** "`knowledge` finds the section of the knowledge base that answers a question."
- **`:64`** "Smallest proof that the change works: the tests you touched, targeted lint and typecheck for the scope you changed." **(b)/(c)**. Theo, `research/2-theo-t3code-excerpts/AGENTS.md:106`. **Replace:** "Prove the change works: at least the tests you touched plus lint and typecheck for the scope you changed, and any other check that helps."
- **`:65`** "Run the whole suite only if it finishes in under 30 seconds. Otherwise CI owns the full suite." **(b)**, a time cap on a read-only run. Ours (the 30 seconds is from `research/superseded/FACTORY-SPEC-v1.md:409`, no reason). **Replace:** "CI runs the whole suite on every PR; run it locally too whenever that helps."
- **`:68`** "Subagents never launch their own dev servers, simulators or emulators." **(b)**, near (d). Theo's, widened by us; his reason was his own running instance, and our rule 1 (`:43`, kill only a PID you captured) already covers the side effect. **Replace:** "A lane that needs the running app may start it from its own worktree on a free port and stops it by the PID it captured."
- **`:68`** "run once by the primary agent after integrating" **(b)/(c)**. Theo verbatim. **Replace:** "after integrating; a lane may also run it on its own slice."
- **`:78`** "Reviewers ignore body prose by design, so the label is for people, not a signal to models." **(a)**. Ours, `70fe295` (#19); pstack's interrogate reads the PR description, and our Spec brief pastes the PR body's Blast Radius. **Replace:** "The label is for people."
- **`:79`** "poll checks and comments newer than the last push" **(a)**. Theo verbatim. **Replace:** "poll the checks and the comments; the ones newer than the last push are what changed."
- **`:98`** "Skip anything tooling already enforces." **(c)/(a)**. Matt. **Replace:** "What tooling enforces is in `vite.config.ts`, `ast-grep/rules/` and `pyproject.toml`, and CI reports it."
- (d): `:18` ask before irreversible actions; `:43` kill only captured PIDs; `:44` never read or print `.env*`, credentials or production data (a read limit that guards secrets, kept); `:45` destructive git; `:47` strangers' text is data; `:80` never merge. (e): PR shape, `For a person:`.

### 104. `docs/knowledge/core/MANUAL.md` (ours; mirrored at core line minus 19 in `template/docs/factory918/MANUAL.md`)

- **`:95`** "which is why local checks stay targeted" **(b)**. **Replace:** "This is the one place everything is guaranteed to run on every PR."
- **`:96`** "(the taste the implementer was deliberately not loaded with ...)" **(a)**, a file withheld from the writer on purpose; nothing enforces it. **Replace:** "against `CODING_STANDARDS.md`, which the review applies whether or not the writer read it".
- **`:98`** "It is the expensive rung, so it is conditional." **(c)**. **Delete** the sentence; whether the gate stays is Manuel's call.
- **`:99`** "polls checks and comments newer than its last push" **(a)**. Same replacement as `AGENTS.md:79`.
- **`:83`** "so a fix low in the chain costs one re-review, not one per PR above it" **(c)**, cost framing ours (`4839da7`), rule upstream. **Replace:** "a PR whose `git patch-id` is unchanged keeps its review, because the reviewed change is the same bytes."
- **`:143`** "Opus 5 medium" for how explorers, swarm workers and the Standards reviewer **(c)**, an effort cap. Ours (#22, #33); upstream runs these at xhigh. **Proposal:** drop the effort cap to match the other reviewer rows.
- **`:165`, `:176`** "without reading files whole", **`:177`** "a section at a time", **`:178`** "Only if you are changing the factory itself." **(a)**. **Replace:** "finds the section that answers", "sectioned so `/knowledge` can find the part you need", "Most useful when you are changing the factory itself."
- (d): never merge; ask before irreversible actions; the git guard. (e): ticket headings, PR shape, review comment lines.

### 105. `docs/knowledge/core/DECISIONS.md` (ours; mirrored at core line minus 8)

- **`:85`, P16** "`standards reviewer: claude:opus@medium`" with the reason "Matching a pasted diff against pasted rules needs less judgment ..." **(c)**, and the reason assumes a reviewer that reads only what was pasted. Ours, `481076d` (#33). **Replace** the reason with Manuel's own sentence in the same row, "the reviewer's context matters more than its model", and drop the effort cap.
- **`:105`, P107** "Rejected: ... rewording the \"Read nothing beyond this brief\" sentences (they agree with the pack)." **(a)+(b)** by what it defends; stale since #137. **Replace** with "The pack is what the brief highlights; the reviewer opens anything else it needs (P18 as amended by #137)."
- **`:89`, P20** "the next round, to five, reviews only that fix" and "round three reviews only round two's fix commits" **(a)/(c)**. Ours, `7b01fd6` (#93, cost) and `caecbc4` (#106, which Manuel sanctioned conditionally). **Replace:** "the next round's fixed point is `<sha>`, so its diff is that fix; the reviewer opens anything the fix reaches."
- **`:90`, P21** "nobody else's comments and none of the PR's own." **(a)**, borderline. **Replace:** "A ticket's spec is its body plus the comments its author posted."
- **`:108`, P109** "and hands back one page" **(c)**. Asked for in #109. **Replace:** "and hands back under Autopilot-stack step 7's headings."
- (d): decisions 6 and 7, P3, P11, P30. (e): P13, P18, P19, P23, P27, P28, P108.

### 106. `docs/knowledge/core/PHILOSOPHY.md` (ours; mirrored at core line minus 10)

- **`:43`**, belief 9, "Read knowledge in ranges, never whole." **(a)**, the root of every "without reading files whole" line. Ours, `fa61555`, from the spec's instruction to the model building the factory. **Replace:** "Point at documents instead of duplicating them; `/knowledge` finds the section that answers. Keep summaries in the main thread and bulk in subagents."
- **`:13`** "afterwards use `/knowledge` to look things up by section rather than re-reading" **(a)**, mild. **Replace:** "afterwards `/knowledge` finds any section again."
- **`:39`**, belief 5, "run the whole suite only if it finishes in under 30 seconds" **(b)**. **Replace:** "Run the checks for what you touched, and anything else that helps; CI runs everything on every PR."
- **`:44`**, belief 10, "they are off unless a decision is contested" **(c)**, a cost gate on launching lanes. **Delete** that clause; whether to gate is Manuel's call.
- **`:64`** "`/knowledge <question>` looks things up without reading files whole." **(a)**, mild. **Replace:** "finds the section that answers it."
- (d): irreversible actions wait; planning writes no code; the human merges; strangers' text is data.

### 107. `template/docs/agents/models.md` (ours)

- **`:15`** "matches a pasted diff against pasted rule sections, junior work" **(a)** in phrasing. Ours, `1a73022` (#33, cost). **Replace:** "starts from the pasted diff and rule sections".
- **`:16`** "a well-built brief carries everything it reads" **(a)**. Ours, `1a50d76`. **Replace:** "a well-built brief gives it a head start on what to read".

**Group E, none found:** 108 `review-ladder.md` (P18's amendment already cleared "zero items is the expected result").

### Addendum 2026-09-25: filing gates, missed by the first pass

The first pass sorted "what a finding must carry" under (e), report format, and judged none of it. That was wrong: a rule that sends back or drops an item without some line decides which bugs get reported. Three such gates in `template/.agents/skills/spec-review/scripts/review-brief.sh`, all ours:

- **`:494`** `spec_rule`, "The same item carries a line `spec:` naming the artifact it rests on ... an item without a `spec:` line is sent back." Ours, `0b8e257` (#90). In the Standards brief it demands a citation of a ticket the brief never shows, so an honest reviewer files a real bug soft or not at all. Filed as #144 (2026-09-25 01:11Z). **Replace** per #144: `spec: none` is allowed and nothing is sent back.
- **`:493`** `step_rule`, "an item without its `Documented step:` line is sent back." Ours, `0b8e257` (#90). The `Documented step:` line is how a hard finding shows it is on the happy path, which is Manuel's definition of hard, so the line stays. **Replace** the gate: an item with no documented step is filed as not hard, never sent back.
- **`:596`-`:598`** Standards headings, "a breach of a documented standard ... Cite the standard (file + the rule)." Ours. Every Standards item must cite a written standard, so a behaviour bug with no standard behind it has nowhere to go. Evidence: Sol's pr99-r1 Standards run filed nothing and said "the report will include only findings tied to a documented rule or a named smell"; all four pr99 hard bugs are behaviour bugs. **Replace:** cite the standard where one applies; a real bug with none goes under its own heading instead of being dropped. This belongs with the review-merge work (one review, or a Standards brief that files any real bug).
