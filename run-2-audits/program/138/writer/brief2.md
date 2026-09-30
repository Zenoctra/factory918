# Writer brief 2: replace the contamination heuristic with a content check (#138, Manuel's decisions of 2026-09-24)

Work on `wt/138-writer`, fast-forwarded first to `feat/reviewer-eval-rerun` (58b0458). New commits only, no rebase, no push. Do not launch reviewer runs. M = /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918 (main checkout). W = /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-af1a10e904a9448aa (the owner's worktree).

## The rules, from Manuel

1. Reviewers keep their full tool set, Bash included. Nothing in any prompt, brief or agent definition tells them what they may not read or run ("never tell a subagent what it can't look at; only highlight what it can use"). Check the runner prompt, the three `tests/eval/reviewer/agents/*.md` bodies and the brief text the runner adds (the settled section) against that, and report what you find. Each run's copy of the code at the reviewed commit stays as it is.
2. A run is contaminated when a tool result in its transcript holds text that exists only in the future. That means a line added by a commit after the reviewed head that is not present in what the run was given.
3. The tests use real transcripts on this machine, and you write them first.
4. `collect` can re-run the check over runs it already collected.

## The content check (design; say in the result where you deviate and why)

- **Future lines of a run.** Take the commits after the run's head on its PR's line of history, as far as the keep refs (`refs/keep/103/*`) and `origin/main` carry them. For every such tip that descends from the head, collect the `+` lines of `git diff <head> <tip>`.
  - Normalize each line: strip it, and drop lines under a length floor. Choose the floor from the corpus and record it with its reason in a constant comment. Also drop generic lines: pure punctuation or braces, fence markers, and lines that are only a Markdown heading word.
  - Subtract every normalized line present in what the run was given: the tree the export came from (the head, or the masked commit), and the review files copied into the export. Those are the brief (with any settled lines), `diff` and the reading pack. The brief is written by e710e99's script, so its wording is newer than the head and must never count.
- **Scan.** Scan every `tool_result` block in the transcript (text and nested text content) line by line.
  - Normalize each line the same way, after stripping the prefixes tools add: the Read tool's `   12→` or `12\t`, `cat -n`, and grep's `path:12:` or `path-12-`.
  - A hit is an exact match of the normalized line against the future set. Keep a small count threshold only if the corpus shows single-line false positives, and record it.
  - The receipt detail names the first few hits: the future line, which commit first added it, and the tool call that returned it.
- **What goes away.** Drop the Bash path and pattern tokenizer (`bash_reaches`, PATH_TOKEN, PATTERN, SEGMENT_SPLIT, COMMAND_WORDS and their tests).
- **What stays of the tool-name check.** Keep it only where it says something the content check cannot:
  - A tool whose reads land in another transcript (`Agent`).
  - A tool that returns live network state git does not hold (`WebFetch`, `WebSearch`).
  - Decide from the corpus whether a `gh` call needs the same treatment. `claude-opus-5/pr99-r1b/standards/3` ran `gh issue view 90` and got the live ticket. Say what you chose.
  - Every other tool, Skill and Bash included, goes through the content check alone.
- **Caching.** Cache the future-line set per (head, given-tree) under the output directory so `collect` stays fast. The cache must be rebuildable and keyed by the commits it read.

## Tests first, against real transcripts

- **The corpus.** 377 #103 receipts are under `M/.scratch/eval/reviewer/runs/<descriptor>/<round>/<axis>/<k>/receipt.json`. Each receipt's `source` is its transcript, and all of them exist.
  - The #103 rounds' heads and briefs are at e710e99: `git show e710e99:tests/eval/reviewer/rounds/<round>/round` and `.../review/*`.
  - 18 receipts say `contaminated`: `grep -l '"contaminated"' -r M/.scratch/eval/reviewer/runs --include=receipt.json`.
  - `claude-sonnet/pr96-r3/spec/1` is scored `complete` but read the worktree's later `shellcheck.sh`. It is the audit's case of later code read and missed (M/.scratch/program/reviewer-eval-audit/report.md, section 6).
- **Labels come first.** For each of the 19 cases, and at least 20 clean receipts spread across models and rounds, decide by reading the transcript's tool calls and results whether the run really read code from after its head.
  - Write the label and one line of evidence per case to a committed file, for example `tests/eval/reviewer/contamination-cases`: receipt path relative to `M/.scratch/eval/reviewer`, verdict `future` or `clean`, and the evidence.
  - Commit the labels, and the test that reads them, before the check exists, so the test fails first.
  - A run that read outside its export but saw only content identical at the head is `clean` under the new rule. Say so in its evidence.
- **The corpus test.** `tests/eval/reviewer/corpus.sh`, or a `reviewer.py` verb that a shell test calls, runs the content check on every labelled case and fails on any mismatch.
  - It exits 0 with one `skip:` line when the corpus directory is absent, which is CI's case. The real run is local.
  - Keep `refusals.sh` covering the mechanics on small synthetic fixtures: prefix stripping, the floor, the given-tree subtraction (a brief line newer than the head is not a hit), the masked tree, and the recheck.
- **Recheck.** `collect --recheck` recomputes the verdict for every collected run from its receipt's `source` transcript and its run.json (tree, settled lines) and rewrites the receipt status and detail.
  - A run that turns contaminated is set aside as today.
  - A formerly contaminated run that is clean under the new check becomes complete only when its report is still in the run directory; otherwise it stays set aside.
  - Print one line per changed verdict. Prove it against a copy of M/.scratch/eval/reviewer-shaped data or a synthetic fixture.
  - The three pilot runs under `W/.scratch/eval/reviewer-138/runs/` may be collected by the root while you work. Do not collect them yourself, and do not delete anything there.

## Verify

Run each of these:
- `python3 tests/eval/reviewer/reviewer.py check`
- `bash tests/eval/reviewer/refusals.sh`
- the corpus test, locally, with its per-case outcome table
- `bash tests/eval/reviewer/rebuild.sh` for all three rounds
- `bash tests/eval/reviewer/fixes.sh`
- ShellCheck with the AGENTS.md line; update the file count there if a new script changes it
- `/deslop` over the diff

Do not touch docs/.

## Result

Write `M/.scratch/program/138/writer/result2.md` (write it in your scratch, then `cp` it, as before) with:
- the head sha and each commit
- the floor and any threshold, with the corpus numbers behind them
- the gh decision
- the per-case corpus table: case, label, verdict, first hit
- each verify outcome
- an act-on list

Then write `M/.scratch/program/138/writer/done10` with the head sha.
