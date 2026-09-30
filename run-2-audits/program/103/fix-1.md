First action: invoke the poteto-mode skill with the Skill tool, then do the task below.

# Fix lane 1 for ticket #103: report parsing and two uncovered rules

Repository Zenoctra/factory918. In your own worktree: `git fetch origin` then `git switch -c wt/103-fix1 origin/feat/reviewer-model-eval`. Commit there; do not push; no PR. Read `AGENTS.md`. Launch no agents. The spec is the `## Design` section of `gh issue view 103 --repo Zenoctra/factory918`; the code is `tests/eval/reviewer/reviewer.py` and its test `tests/eval/reviewer/refusals.sh`.

Fix, test first (the test commit before the code commit):

1. `parse_report` treats a line inside a fenced code block (``` or ~~~) that starts with `<n>. ` as a new item. Reviewers quote numbered criteria inside fences (the historical `tests/eval/reviewer/rounds/pr94-r1/review/standards-report.historical.md` item 1 quotes a line starting `6. ` and gets a phantom hard item 6). Make item detection and heading detection ignore fenced lines; fenced lines stay part of the current item's text. Add an assertion that a fenced `6. ` line inside a hard item neither creates an item nor changes the unlabeled count, and that the pr94-r1 standards historical report parses to exactly the items its headings number.
2. Add an assertion for the existing `## Walk` skip (Walk lines numbered 1..K are not items, and do not match or claim a label).
3. Add assertions for the contamination rule's Grep and Glob with no `path`, and with a `path` outside the checkout.

Then: `bash tests/eval/reviewer/refusals.sh` passes; `python3 tests/eval/reviewer/reviewer.py check` still prints `ok` for all 13 labels; `bash .github/shellcheck.sh tests/eval/reviewer/refusals.sh` passes. No narrating comments. Write an act-on list result (branch, head SHA, commits, each check with its outcome, flags) to exactly /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/103/fix-1-result.md, or if refused, the same relative path under your worktree. Reply with only the path.
