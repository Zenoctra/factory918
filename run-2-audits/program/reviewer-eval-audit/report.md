# Reviewer eval audit (#103)

The real reviews in the first run were Claude Opus 5 at effort high. The test re-ran it at effort medium, under a 400-word cap, and scored it against labels that are just the hard findings one earlier run happened to file. Four of the 13 labels were already listed in the brief's own Risks section, four others are in files the brief tells the reviewer not to open, and 31 of the 43 "unlabeled" hard findings are real bugs; 18 of those are labelled bugs the scorer could not credit.

So the low recall is partly the test. The sequential effect Manuel suspects is real, though. The first run's later rounds and the verifiers found bugs in code that earlier rounds had read. Of the three bugs later rounds found, round one had already seen two ("nothing" in a walk, "Fix alongside") and mentioned the third in passing.

Scratch scripts ran in a private `mktemp -d`. Paths are relative to the repository root unless absolute. "Transcripts" means `~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/`.

## 1. Which model ran the real reviews

Every Standards and Spec reviewer of PRs #94 to #102 was Claude Opus 5 (`claude-opus-5`) at effort `high`. Fable 5.1 ran the orchestrating `spec-review` lanes: it launched the reviewers, wrote the judgment and signed the posted comment. That is why the comments read "Claude Fable 5.1 on Claude Code" (`tests/eval/reviewer/rounds/pr94-r2/inputs/previous.txt`).

**Evidence.**
- Each reviewer's `.meta.json` has `"agentType":"general-purpose"` and `"model":"opus"`.
- Every assistant line in each reviewer JSONL has `.message.model` equal to `claude-opus-5`, and every `.effort` is `high` (`transcripts/b4a8ae9c-.../subagents/agent-<id>.*`).
- The parent lane `ab6800a8e8b4c0978` is `claude-fable-5-1`.
- The root session has 407 `effort: high` lines.
- The eval session `48857ffb...` has 443 `effort: medium` lines.
- The post-mortem records only the family (`opus`) and says effort is absent (`.scratch/program/postmortem/agents.md`).

The model does not vary by round or axis:

| round | Standards lane | Spec lane | brief dir | model, effort |
|---|---|---|---|---|
| pr94-r1 | a6625c5aa72f90533 | a040c8b58af0e0d62 | review/ab47eb9 | opus-5, high |
| pr94-r2 | aab0f43e3cdada323 | aaa018ce502562a46 | review/c83f166 | opus-5, high |
| pr94-r3 | a8212e800c58adbbe | a16952e884b94e4ec | review/78be65e | opus-5, high |
| pr96-r1 | a141f0ee48ed845a6 | a74ddcb0d4f1a9763 | review/ab47eb9 | opus-5, high |
| pr96-r2 | a428870f36ece4045 | ac96f9c313222e690 | review/ab47eb9 | opus-5, high |
| pr96-r3 | ad70319b18a14313c | a70dc177c5a70b021 | review/ab47eb9 | opus-5, high |
| pr99-r1 | a6b4312d006c84caa | ad553319b415994ab | review/69bd412 | opus-5, high |
| pr99-r1b | ac3b8c3b87d5c9e4a | a9a1b02d23c5f38b6 | review/69bd412 | opus-5, high |
| pr99-r2 | ae9752af497ed8c24 | ad769b6a11bf430bd | review/69bd412 | opus-5, high |
| pr101-r1 | a544fcb3f8dee2b9a | a198b19489a01b3b7 | review/52ccd8e… | opus-5, high |
| pr102-r1 | a999c50e5d7c827cc | a5c83f5bac3ed44ce | review/d8e382c… | opus-5, high |
| pr102-r2 | a0ee70d27577f85ed | ad61b873b1f55b6e2 | review/d8e382c… | opus-5, high |

The eval's `claude:opus-5` is the same served model, through `tier-lower`. All 72 complete receipts say `"reported_model": "claude-opus-5"` and `"effort": "medium"`, so the eval re-ran the labelling model one effort step lower.

The original prompt also differed from the eval's:
- It pointed at the worktree with `.git` and allowed "the code around a hunk in the repository".
- It opened with the text "Requested effort: medium.", but the harness still ran it at high.
- The eval prompt is two sentences in an export with no `.git` (`.scratch/eval/reviewer/runs/claude-opus-5/pr94-r1/standards/1/prompt.txt`).

## 2. Real hard bugs not in the labels

`scores.tsv` has 43 unlabeled hard items across the complete runs. Two `tier-lower` lanes judged each one against the code at that round's head (`judge-pr96/verdicts.tsv`, `judge-rest/verdicts.tsv`). I re-read U07, U13, U14 and U31 myself and agree with the lanes on all four.

| model, axis | items | new real bug | a label's bug (other axis, other round, or other wording) | real, not hard | noise |
|---|---|---|---|---|---|
| opus-5 spec | 13 | 6 | 4 | 2 | 1 |
| opus-5 standards | 5 | 1 | 4 | 0 | 0 |
| opus-5.5 spec | 3 | 1 | 1 | 1 | 0 |
| opus-5.5 standards | 0 | 0 | 0 | 0 | 0 |
| sonnet spec | 6 | 1 | 0 | 2 | 3 |
| sonnet standards | 3 | 1 | 0 | 0 | 2 |
| gpt-6-astra spec | 10 | 3 | 6 | 1 | 0 |
| gpt-6-astra standards | 3 | 0 | 3 | 0 | 0 |
| **total** | **43** | **13** | **18** | **6** | **6** |

The 13 new-bug items reduce to 9 distinct bugs:

| bug | found by | born | caught by the original rounds? | fixed? |
|---|---|---|---|---|
| Ticket step 6 guards the write but not the read: a failed `gh issue view` empties the ticket (U07) | opus-5, pr94-r2/spec | fix b368116 | no | no (`ticket.md:10 @ 0c63fa6`) |
| The zero-argument gate refuses in the factory, which has no `.agents/` (U13, U28) | opus-5, pr96-r2/spec; sonnet, pr96-r3 | fix 01e5386 | pr96-r3/standards item 1, as a Standards breach | no |
| A checksum failure hides the path and wedges the tarball (U14) | opus-5, pr96-r3/spec | fix a64c7e6 | pr96-r3/standards item 4, Fix alongside | 070c1fa, after the rounds |
| The playbook's bare `shellcheck.sh` does not lint the diff's files (U23, U24) | sonnet, pr96-r1, both axes | round 1 (`opening-a-pr.md:9 @ 69bd412`) | no; the run-1 verifier found it | ae1b4b5 |
| Stateful work inside one function skips `architect` and the table (U31 to U33) | astra, pr94-r1/spec, 3 of 3 runs | round 1 (`bug-fix.md:9 @ c83f166`) | no | no |
| The Standards brief demands `spec:` but carries no ticket artifact (U17) | opus-5, pr99-r1b/standards | round 1 (`review-brief.sh:363 @ 32978fa`) | no; a relative of the pr99-r1 P1 hole | no |
| The would-break line prints at rounds 1 and 2, but its sha gate runs only above round 3 (U03, U19) | opus-5.5 and opus-5, pr102-r1/spec | round 1 | pr102-r1/standards item 1, as a Standards breach | fc75ac6 |
| The would-break sha has no ancestry check (U20) | opus-5, pr102-r2/spec | `review-brief.sh:230 @ fc75ac6` | no | no |
| A rebuilt comment licenses a round five (U21) | opus-5, pr102-r2/spec | `review-brief.sh:183 @ fc75ac6` | no | no |

- The original rounds never named 6 of the 9 as hard, and filed 2 others under non-hard headings.
- Three of the 9 were born in fix commits.
- Opus 5 found 7 of the 9.

The 18 "label's bug" items are finds the scorer discards:
- **Other axis, same brief (3):** U04 (S1 found on pr94-r1/spec), U06 (P1 found on pr94-r1/standards), U15 (S1 found on pr99-r1/spec).
- **Anchor misses on the brief's own label (2):** U05 and U34.
- **A later round's label found on an earlier brief that already had the code (13).**

## 3. Where the labels came from

The labels are exactly the hard items in the historical reports: all 13 calibrate `ok` under `reviewer.py check`. Each was first found by the Opus 5 (high) reviewer of the brief it is scored on.

No label is scored on a brief whose code lacks the bug. The case Manuel remembers (a bug born in a fix, labelled on an earlier brief) does not occur. The reverse does: bugs already present in an earlier brief are labelled only on the later one.

| label | first found | code in that brief's diff? | also present, unlabeled, in | how the reviewer gets it |
|---|---|---|---|---|
| pr94-r1 S1 | #94 r1, Standards | yes (`ticket.md` step 6, diff:425) | none | reading the diff |
| pr94-r1 P1 | #94 r1, Spec | partly: `overlap.sh` is not in the diff (fixed in r2 by 3f5033f) | none | a file outside the diff |
| pr94-r1 P2 | #94 r1, Spec | no: `architect/SKILL.md` is not in the diff (fixed in r2 by 0c63fa6) | none | a file outside the diff |
| pr94-r1 P3 | #94 r1, Spec | partly: the `CORE_DOCS` line is in the diff; the docstring and `MANUAL.md:165` are not | none | a file outside the diff |
| pr94-r1 P4 | #94 r1, Spec | yes | none | reading the diff |
| pr96-r1 S1 and P1 (glob) | #96 r1, both axes | yes (`shellcheck.sh:38-42 @ 69bd412`) | none | the brief's Risks item 3 names it |
| pr96-r2 S1 (space split) | #96 r2, Standards | yes | pr96-r1 (`:38 @ 69bd412`) | reading the diff |
| pr96-r2 S2 and P1 (cache) | #96 r2, both axes | yes (`:26`) | pr96-r1 (`:26 @ 69bd412`) | the brief's Risks item 1 names it |
| pr99-r1 S1 | #99 r1, Standards | yes (`holed()`, diff:462) | none | reading the diff |
| pr99-r1 P1 | #99 r1, Spec | yes (`spec_rule`, diff:319) | none | reading the diff and the ticket |
| pr99-r1b S1 | #99 r1b, Standards | no: `MANUAL.md` is not in the diff and was unchanged until 384bb43 | pr99-r1 (`MANUAL.md:103 @ 52ccd8e`) | a file outside the diff |

**Labels the brief hands over.** All four pr96 briefs carry a `### Risks` list. Its item 1 is "A cached binary is reused with no checksum" and its item 3 is "An unmatched glob among matched ones is dropped without a word" (`rounds/pr96-r1/review/spec-brief.md`). Those two items cover 4 of the 13 labels, and nearly all recall comes from them:

| model | Standards, pr96 | Standards, rest | Spec, pr96 | Spec, rest |
|---|---|---|---|---|
| sonnet | 3/9 | 0/9 | 4/6 | 1/15 |
| opus-5 | 4/9 | 1/9 | 5/6 | 3/15 |
| opus-5.5 | 4/9 | 0/9 | 3/6 | 1/15 |
| gpt-6-astra | 7/9 | 0/7 | 2/4 | 0/12 |

**Labels outside the diff.** P1, P2, P3 and r1b S1 need a file the diff does not touch. The brief says: "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing."

**The denominators.** Recall counts one offer per label per run, and failed runs still count.
- 18 is 6 Standards labels × 3 runs.
- 21 is 7 Spec labels × 3 runs.
- Astra Standards is 16: 18 minus two usage-limit dropouts on `pr99-r1b/standards` (k=2 and k=3).
- Astra Spec is 16: 21 minus the 3 missing `pr99-r1/spec` runs and the 2 missing `pr96-r2/spec` runs.

**A wider ground truth does not rescue Claude.** I credited a run for any label bug present in its brief's code, from either axis and any round. The denominator becomes 42 per model and axis:
- Opus 5 falls to 0.29 on Spec and 0.21 on Standards.
- Opus 5.5 falls to 0.12 and 0.10.
- Sonnet falls to 0.12 and 0.07.
- Astra rises to 0.31 and 0.25.

## 4. Do reviewers stop after the first few findings?

They mostly file nothing at all, and no report files more than three hard findings:

| model, axis | reports | 0 | 1 | 2 | 3 | 4+ | mean |
|---|---|---|---|---|---|---|---|
| sonnet std | 35 | 31 | 2 | 2 | 0 | 0 | 0.17 |
| sonnet spec | 35 | 26 | 7 | 2 | 0 | 0 | 0.31 |
| opus-5 std | 36 | 27 | 8 | 1 | 0 | 0 | 0.28 |
| opus-5 spec | 36 | 19 | 12 | 5 | 0 | 0 | 0.61 |
| opus-5.5 std | 36 | 32 | 4 | 0 | 0 | 0 | 0.11 |
| opus-5.5 spec | 36 | 30 | 5 | 1 | 0 | 0 | 0.19 |
| astra std | 22 | 16 | 2 | 4 | 0 | 0 | 0.45 |
| astra spec | 12 | 6 | 3 | 0 | 3 | 0 | 1.00 |

The historical high-effort report on pr94-r1/spec filed 4 hard findings. No eval Claude run filed more than 2.

**Briefs with two or more labels.** Only pr94-r1/spec and pr96-r2/standards qualify.
- No Claude run, out of 18, found all the labels on them.
- Opus 5 found some but not all in 4 of 6 runs (`[P1,P3]`, `[P3]`, `[S2]`, `[S1]`) and nothing in the other 2.
- Sonnet and Opus 5.5 each found nothing in 5 of 6.
- Astra found both pr96-r2 labels in 3 of 3 runs and nothing on pr94-r1/spec.
- On pr96-r1, which has three real bugs, no Claude run filed all three as separate items.

**What the brief does.** There is no cap on the number of findings, but four things push the count down:
- "Zero items is the expected result for a clean change."
- "Under 400 words." The Spec `## Walk` spends that budget first: the median Spec report is 408 words for Opus 5 (19 of 36 over the cap) and 392 for Opus 5.5 (16 of 36 over).
- "An edge case outside the intended path being unsupported is not a flag."
- The rule against reading beyond the brief, quoted in section 3.

The historical reports broke the word cap: 490 and 536 words on pr94-r1, and 537 on pr99-r1/spec. `spec-review/SKILL.md` adds no cap.

## 5. Pooling, and the sequential evidence

### Variance, not the sequential effect

Each number is the mean union recall over every subset of n runs on the same brief.

| model, axis | 1 run | 2 runs | 3 runs |
|---|---|---|---|
| sonnet std | 0.17 | 0.17 | 0.17 |
| sonnet spec | 0.24 | 0.33 | 0.43 |
| opus-5 std | 0.28 | 0.50 | 0.67 |
| opus-5 spec | 0.38 | 0.52 | 0.57 |
| opus-5.5 std | 0.22 | 0.28 | 0.33 |
| opus-5.5 spec | 0.19 | 0.24 | 0.29 |
| astra std | 0.39 | 0.53 | 0.60 |
| astra spec | 0.13 | 0.20 | 0.20 |
| one opus-5 run + one opus-5.5 run, std / spec | 0.37 / 0.43 | | |

The union of every model's runs reaches 4/6 on Standards and 5/7 on Spec.

### 5a. Later rounds in the first run: fix-born or missed-then-found

Run 1 had seven rounds after a first round. Only pr96-r2 and pr99-r1b filed hard findings: 4 items, 3 distinct bugs.

| later-round finding | code at the previous reviewed head | touched by the fix? | class | what round one said |
|---|---|---|---|---|
| pr96-r2 std 1: an argument with a space is word-split | `shellcheck.sh:38 @ 69bd412`, `for f in $g` | the line was edited by 01e5386, but `$g` stayed unquoted | missed-then-found | named in passing inside the glob item: "a path with a space, which splits on the unquoted `$g`" (`pr96-r1/.../standards-report.historical.md`, item 1) |
| pr96-r2 std 2 and spec 1: a cached binary runs unchecked | `:26 @ 69bd412` | no | missed-then-found | "Risk 1 (cached binary, no sha): nothing; `:26` skips the download and the checksum" (`pr96-r1/.../spec-report.historical.md`, Walk 8) |
| pr99-r1b std 1: the MANUAL merge read takes `act-on items: 0` alone | `MANUAL.md:103 @ 52ccd8e` | no | missed-then-found | Fix alongside: "so this is noted, not asked for" (`pr99-r1/.../standards-report.historical.md`, item 3) |

Per PR and axis there are 0 fix-born findings. Missed-then-found: #96 Standards 2, #96 Spec 1, #99 Standards 1; #94, #101 and #102 had none.

Round one had seen or brushed each of these bugs, rated it below hard while filing a single hard item, and the next round rated the same code hard. That is Manuel's "reads less strictly" hypothesis, and the first run supports it. The eval adds the other kind: fix-born bugs U07, U13 and U14, which the original later rounds did not name as hard.

There is also a weak natural experiment in the eval data, at effort medium with 6 runs per cell. It shows no rise once round one's bug was fixed:

| bug and model | earlier brief | later brief |
|---|---|---|
| cache, opus-5 | 2/6 (pr96-r1) | 3/6 (pr96-r2) |
| cache, opus-5.5 | 1/6 | 0/6 |
| MANUAL, opus-5 | 1/6 (pr99-r1) | 0/5 clean (pr99-r1b) |

### 5b. What the verifiers found after the rounds ended at zero

Source: `verifiers/verifier-issues.tsv` and `summary.md`. Verifier lanes across 11 PRs raised 81 items. 56 were in code a round had read, and 46 of those were never named by any round, on any axis or under any heading.

| run | items | in reviewed code | never named | issue-class, in reviewed code, never named |
|---|---|---|---|---|
| run 1 | 28 | 18 | 15 | 4 |
| run 2 | 53 | 38 | 31 | 6 |

The issue-class items:
- **#94:** the fix for P1, the heading skip at `overlap.sh:48 @ 0c63fa6`, still leaks pathspecs (`verify/94-78be65e/worker-audit.md`, Issues 2). This one is fix-born.
- **#102:** table cells with no assertion, and a round-one judgment that can end the review at zero (`verify/102-fc75ac6/worker-audit.md`, Issues 1 to 3).
- **#125:** the design hole, "a bare `else` or `done` does the same" (`verify/125-caecbc4/worker-audit.md`, section 7), and 26 cells with no assertion.
- **#126:** "177 secret lines carried where the diff showed 6" (`verify/126-f58308b/worker-runtime.md`, Notes 1).

The other 36 in reviewed code are notes. Most were found by running the code, not by reading the diff.

### 5c. A sequential test (designed, not run)

- **Briefs.** pr94-r1, pr96-r1 and pr99-r1, both axes: six briefs, each with at least two known bugs. Delete the Risks list from the pr96 briefs.
- **Ground truth.** Every real bug in that head's code, from both axes and all rounds: about 6 bugs on pr94-r1, 4 on pr96-r1 and 3 on pr99-r1.
- **Arm S (sequential).** Pass 2 and pass 3 list the earlier passes' hard items under `## Settled in earlier rounds`, with the skill's paragraph ("Do not raise them again").
- **Arm M (masked).** Pass 2 runs on the tree with pass 1's bugs fixed. The real fix commits exist for pr96-r1 (01e5386, 72953c0, a64c7e6) and pr94-r1 (b368116, 3f5033f, ca2c106, 0c63fa6).
- **Arm I (independent).** Three fresh passes. The existing medium runs are its baseline.
- **Measure.** New ground-truth bugs per chain in passes 2 and 3. Also count ground-truth bugs that appear under non-hard headings, which measures the down-grading seen in 5a.
- **Settings.** Effort high, matching the labelling runs. Keep the 400-word cap, and record it. If the budget allows, add a factor with and without the read ban.
- **Models.** Opus 5, which wrote the labels and has the most run-to-run variance, and Opus 5.5, the most repeatable. Sonnet adds little: its union recall stays flat on Standards.
- **Size.** 6 briefs × 3 arms × 3 passes × 4 chains = 216 runs per model, giving 24 chains per arm. That should read a difference of about one bug per chain; a difference below 0.3 bugs per chain would not be readable.
- **Cost at medium, from the receipts.** Opus 5 takes 0.88 to 1.39M cache read and 11 to 15K output per run, about 245M and 2.9M in total, and about 75 minutes at 8 concurrent runs. Opus 5.5 takes 0.43 to 0.54M and 3.7 to 5.1K per run, about 105M and 1M in total, and about 20 minutes.
- **Cost at high.** Expect 1.5 to 2 times more. For example, the original pr94-r1 Standards lane produced 23.6K output tokens, against an eval mean of 11.3K.

## 6. Other things that bias the recall

- **Effort.** The labels came from high effort; every eval Claude run was medium.
- **Axis split.** The blinded judge was offered both axes' labels (114 cross-axis decisions in `.scratch/program/103/audit/verdicts-claude.tsv`). It credited three distinct cross-axis finds, all by Opus 5, and the table counts none of them.
- **The one judge disagreement.** It is `claude-opus-5/pr94-r1/spec/1`, item 2: "`build_knowledge.py`'s docstring still names four slim copies". That is label P3. The anchor `\b(four|4)\b.{0,40}document` misses by 3 characters. With that hit, Opus 5 is 3/3 on P3 and 9/21 on Spec. On Astra the judge credited 3 finds the anchors missed: two terse rewordings of the glob label and one label from the other axis.
- **Contamination exclusions.** 18 runs were excluded, 4 of them with hits. `claude-opus-5/pr99-r1b/standards/3` was the only Opus 5 run to find r1b S1. It found it with an in-export grep of `docs/knowledge/core/`, then ran `gh issue view 90`, which returned the live ticket. Excluding it is correct, but a legitimate find went with it.
- **Holes in the contamination detector.** A Bash command is flagged only when it lacks the export path (`reviewer.py`, `receipt_from_transcript`). The `gh` call above was prefixed `cd <export> &&` and was caught only through a later grep. `claude-sonnet/pr96-r3/spec/1` read a worktree file (`cat -n` of the worktree's `shellcheck.sh`) and is scored clean; that brief has no label, so recall is unaffected. No other complete Claude run called `gh`.
- **Demotion.** Opus 5.5 filed 6 Standards label finds under non-hard headings. The historical Opus 5 did the same in round one (5a).
- **What a label is.** A label is "every hard item one Opus 5 (high) run filed". There are 6 or 7 per axis, and pr94-r1/spec holds 4 of the 7 Spec labels. That favours the labelling model's taste.
- **Astra's missing runs.** Astra has no complete run of pr99-r1/spec, so its Spec row lacks one of only two labels outside pr96 that any model found.
