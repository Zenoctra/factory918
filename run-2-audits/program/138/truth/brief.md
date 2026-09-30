# Ground truth for three reviewed heads (#138)

You build the ground truth for a reviewer measurement: every real, hard bug present in the code of three reviewed heads. Read-only on the repository; you write only the two files named at the end.

M = /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918 (main checkout, holds the evidence under .scratch/)
W = /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-af1a10e904a9448aa (a worktree; run git here, e.g. `git show <sha>:<path>`; every sha below is in its objects)

## The three heads
- pr94-r1: head c83f166578a35e61d0b686c1ae1ed652b051dba6, fixed point ab47eb9, ticket #89. Briefs and historical reports: W/tests/eval/reviewer/rounds/pr94-r1/review/.
- pr96-r1: head 69bd41230e0f62e0824403196243c013118fb302, fixed point ab47eb9, ticket #88. rounds/pr96-r1/.
- pr99-r1: head 52ccd8eb509a2871260827a8514c3a1fcaac4d5d, fixed point 69bd412, ticket #90. rounds/pr99-r1/.

## Read first
1. M/.scratch/program/reviewer-eval-audit/report.md whole. Sections 2, 3 and 5 list the known bugs: the labels (W/tests/eval/reviewer/labels), labels of later rounds whose code was already present at an earlier head (pr96-r2 S1 space split and S2/P1 cache at pr96-r1; pr99-r1b S1 MANUAL at pr99-r1), and the audit's new bugs (U07, U13/U28, U14, U23/U24, U31-U33, U17, U03/U19, U20, U21), each with where it was born.
2. The judge verdicts the audit cites: M/.scratch/eval/reviewer/judge-pr96/verdicts.tsv, judge-rest/verdicts.tsv (find them under M/.scratch/ if the path differs), and the items they name in M/.scratch/eval/reviewer/runs/*/<round>/<axis>/<k>/report.md and M/.scratch/eval/reviewer/scores.tsv.
3. Every later round's historical reports (W/tests/eval/reviewer/rounds/*/review/*-report.historical.md) and the verifier issues (M/.scratch/program/**/verifier-issues.tsv, verify/*/worker-*.md; search with find) for bugs whose code was already present at one of the three heads.

## What counts
A ground-truth bug is a real defect in the code or prose at that head that breaks a documented path or fails open (the review's hard class), present at that exact head (prove it: `file:line @ <head>` from `git show <head>:<file>`). Include it whoever found it, on either axis, in any round, or a verifier. Exclude a bug born after the head (for example in a fix commit: U07, U13, U14, U20, U21 are born later; check each), and exclude real-but-minor items (list those separately, one line each, with why). Do not trust the audit blindly: confirm each bug in the code.

## For each bug
- fix: the commit(s) that remove it from the tree later (look at the rounds that followed: pr94 fixes b368116, 3f5033f, ca2c106, 0c63fa6; pr96 fixes 01e5386, 72953c0, a64c7e6, and later 070c1fa, ae1b4b5; pr99 fixes after 52ccd8e, e.g. 384bb43, 32978fa: confirm with `git log --oneline <head>..<later-sha>` and `git show`). A commit counts only if applying it removes this bug; write `-` when no commit fixes it. Name every commit a fix needs.
- anchors: two or more Python regexes joined by ` && `, all of which must match (re.search) the normalized text of a report item that describes this bug and match no item describing a different bug of the same head. Normalized = lowercase, backticks and asterisks removed, whitespace collapsed (tests/eval/reviewer/reviewer.py `normalize`). Start from the label's anchors when one exists. Validate: with `python3` import W/tests/eval/reviewer/reviewer.py (`sys.path.insert`), run `parse_report` on the historical reports and on the #103 run reports the judges credited to this bug, and show each credited item matches and no item credited to another bug of that head does. Put the validation script and its output in your notes.

## Output (write with Bash, e.g. a heredoc `cat > <path>`; the Write tool may refuse this path)
1. M/.scratch/program/138/truth/truth.tsv: a header line `# round	id	anchors	fix	where	sources	title`, then one tab-separated row per bug: round (pr94-r1 | pr96-r1 | pr99-r1), id (G1, G2, ... per round), anchors, fix (comma-separated 7-char shas in the order they must be applied, or -), where (`file:line @ <7-char head>`), sources (label ids, audit U-numbers, report item refs), title (one sentence, plain).
2. M/.scratch/program/138/truth/notes.md: for each bug the proof it is present at the head and the proof each fix commit removes it; the excluded candidates with the reason; the anchor validation output; any bug whose anchors could not be made to separate, named.
Then write M/.scratch/program/138/truth/done containing the word done. Do not launch subagents. Do not edit anything under W except nothing: you only read there.
