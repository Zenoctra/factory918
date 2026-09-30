# Lane brief: judge unlabeled hard findings from the reviewer eval

Read-only investigation. Write only under your own output directory (given in your prompt). Never edit anything under version control, never run git commands that change state (no checkout, reset, commit, stash), never use gh or the network. To read code at a commit use `git -C "<repo>" show <sha>:<path>` or `git -C "<repo>" diff <a> <b> -- <path>`.

Repository: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918` (call it REPO).

## Background

Ticket #103 re-ran frozen code-review briefs against several models. Each brief lives at `REPO/tests/eval/reviewer/rounds/<round>/review/<axis>-brief.md`, with its diff at `.../review/diff`. The file `REPO/tests/eval/reviewer/rounds/<round>/round` gives `fixed_point=` and `head=`: the brief reviews `git diff <fixed_point> <head>`, and the whole tree at `head` was available to the reviewer. All heads exist locally as `refs/keep/103/<short sha>`.

A report's hard findings are the numbered items under `## Would break` and `## Fails open`. Findings that matched one of the 13 labels in `REPO/tests/eval/reviewer/labels` (tab separated: brief, id, kind, anchors, title) were scored; your items did NOT match any label on their own brief. Your job is to judge each one.

The original first-run reviews of every round are at `REPO/tests/eval/reviewer/rounds/<round>/review/<axis>-report.historical.md` (both axes, all headings). Later rounds of the same PR are the other `<round>` directories with the same `prNN` prefix; the commits between rounds are `git log <head_of_round_n>..<head_of_round_n+1>`.

The briefs define a hard finding: the documented path gives a wrong or silent result, or an input outside it proceeds silently instead of being refused with a message. An unsupported edge case outside the documented path is NOT a hard finding.

## Your items

`items.tsv` in your output directory: id, model, brief, k, item_no, report_path. Read item `item_no` in the report at `report_path` (the numbering is continuous across headings; find `<item_no>. **`).

## For each item decide

1. `verdict`, one of:
   - `real`: the described behavior actually happens at that round's head, on the documented path or as a silent fail-open, and it is not one of the 13 labels. Check the code at the head; quote the line.
   - `label:<brief> <id>`: it is the same bug as a label, only worded differently or the label belongs to the other axis or another round of the same PR (say which).
   - `real-minor`: true, but a wording/standards issue or an edge case outside the documented path, not a hard finding by the brief's own definition.
   - `noise`: false, misread, or already handled by the code (quote what handles it).
2. `cluster`: a short slug naming the underlying bug, identical across items that describe the same bug (so they can be deduplicated; reuse the slug across rounds when the same code carries it).
3. `caught_by`: did any historical report (any round of the same PR, either axis, any heading) name it? Give `<round>/<axis> item N (heading)` or `none`.
4. `fixed`: was it changed in a later round's commits, or on main later? Give the commit and a few words, or `no`/`unknown`. (`git log --oneline refs/keep/103/<head>..main -- <path>` and `git show` help.)
5. `evidence`: `path:line @ sha` and a short quote (under 20 words) of the code that proves the verdict.

## Output

Write `verdicts.tsv` in your output directory with header `id	verdict	cluster	caught_by	fixed	evidence`, one row per item, tabs only (no tabs inside fields). Then write `done` as the only content of a file named `DONE` in the same directory. Reply with only the path of verdicts.tsv.
