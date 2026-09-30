First action: invoke the poteto-mode skill with the Skill tool, then do the task below.

# Fix lane 3 for ticket #103: a finished Claude run that never reads as finished

Repository Zenoctra/factory918. In your own worktree: `git fetch origin` then `git switch -c wt/103-fix3 origin/feat/reviewer-model-eval`. Commit there; do not push; no PR. Read `AGENTS.md`. Launch no agents. Code: `tests/eval/reviewer/reviewer.py` (`finished`) and its test `tests/eval/reviewer/refusals.sh`. Test first: the test commit before the code commit.

Evidence. Two Sonnet runs completed (the harness reported them done and their reports exist), yet `collect` keeps them `in flight`: the transcript's last assistant line is a text-only message whose `.message.stop_reason` is null, not `end_turn`. Example transcript (read only its last 6 lines): `/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/subagents/agent-aecdb2cd92da55efd.jsonl`. The harness writes one line per content block, so a text-only line can also appear mid-message before a tool_use line.

Fix: a run is finished when its last assistant line has `stop_reason: end_turn`, or when that line's content is text blocks only (no `tool_use`) and the transcript file has not been modified for at least 120 seconds (an env knob `REVIEWER_SETTLE_SECONDS`, default 120, so the test can set 0). Add assertions: a null-stop text-only last line older than the settle time is finished and collected; the same line younger than it stays in flight; a null-stop line whose content has a tool_use stays in flight.

Then `bash tests/eval/reviewer/refusals.sh` passes, `python3 tests/eval/reviewer/reviewer.py check` prints 13 `ok`, `bash .github/shellcheck.sh tests/eval/reviewer/refusals.sh` passes. No narrating comments. Write an act-on list result (branch, head SHA, commits, checks, flags) to exactly /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/103/fix-3-result.md, or if refused, the same relative path under your worktree. Reply with only the path.
