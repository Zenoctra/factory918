# PR #135 rebase onto main 672b5a1: check

PR #135's 23 commits were replayed onto main 672b5a1 as branch `chain/135-rebase`, and the new tip is 637a062. Nothing was pushed. Every conflict was a spot where main and #135 edited neighbouring lines, and each resolution kept both sides. Every Verifying gate passes, and the only differences from the old diff are two generated line counts and the lines main itself rewrote.

## Tip

- Branch `chain/135-rebase`, tip `637a062ec5ea03081d1710f0423b8b7a88b0458a`, built from `be9cc3fd667645aece2f5cc7846f03be82a36c2c` with `git rebase --onto origin/main a9ebdac`. `origin/main` is `672b5a1eca9f65b3c8517f417cccd18e17c0f377`.
- There are 23 commits, the same ones as a9ebdac..be9cc3f. Nothing is pushed.

## Conflict log

Commits are listed by their old SHAs.

1. `811cf86` (ticket.md step 0 and its pointers) conflicted in `template/.agents/skills/poteto-mode/playbooks/ticket.md` steps 5 and 6. Main rewrote both lines for #108's disposition rules and #137. I kept main's two lines and added back #135's two pointer clauses at the same anchors. After "come first in all of them." it adds "In `eco` you read them yourself (step 0, the tier)." After "replaces the body and never merges." it adds "In `eco` the architect step is one runner and an adversarial judge (step 0, the tier); the table comes first in both tiers." A script did this (`.claude/worktrees/agent-a2ce71454fd0910f0/.scratch/109/resolve.py`). It asserts that the commit only added text and that each anchor occurs exactly once in main's line.
2. `391a8e7` (MANUAL) conflicted in `docs/knowledge/INDEX.md`, which is generated. I took main's side and ran `python3 tools/build_knowledge.py`.
3. `1d7ef50` (AGENTS and ladder clauses) conflicted in `template/docs/agents/review-ladder.md` rung 1. This file was not on the root's list. Main rewrote the rung 1 line, and I kept main's line and added back #135's clause "(in `eco` its two reviewers are the fresh context, Ticket step 0)" after "round one in a fresh context", with the same script.
4. `148aa8a` (the records commit) conflicted in three files. `docs/agents/ledger.md` keeps both lines, #108's line and then #109's, both dated 2026-09-23, in date order. `docs/knowledge/core/DECISIONS.md` keeps both rows, P108 then P109, with ids unchanged; P137's P18 amendment and P11's #109 amendment both merged without conflict. For `template/docs/factory918/DECISIONS.md` I took main's side, rebuilt, and committed what the rebuild wrote.
5. `dfdf587` (ledger "and one writer", P109 "findings") conflicted in the ledger and DECISIONS, because the base side lacked main's #108 line. I kept main's side and swapped the one line the commit changed for the commit's version (`carry.py`), then regenerated the copy.
6. `be9cc3f` (the P109 amendment) conflicted in DECISIONS the same way and was resolved the same way, with the copy regenerated.
- No other commit conflicted. The final `git grep -n '^<<<<<<<\|^>>>>>>>'` printed nothing (exit 1).
- #137's wording: the branch's added lines contain none of "under 400 words", "Run nothing" or "read nothing beyond". Its one owner-side sentence, "Read no brief and no diff while the review state exists", names the review state the hook reads, not a brief sentence #137 changed. No update was needed.

## Gates at 637a062

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`: "ShellCheck 0.11.0, files checked: 26".
- `tests/shellcheck/gate.sh`: ok 17 assertions.
- `tests/hooks/delegation.sh`: ok 76 assertions.
- `tests/spec-review/review-brief.sh`: ok 1836 assertions.
- `tests/spec-review/review-comment.sh`: ok 298 assertions.
- `tests/poteto-mode/overlap.sh`: ok 57 assertions.
- `tests/spec-review/no-stale-wording.sh`: "ok: no stale wording".
- `tests/knowledge/provisional-ids.sh`: 26 assertions passed.
- `tests/show-me-your-work/check-trail.sh`: ok 66 assertions.
- `tests/eval/reviewer/refusals.sh`: all 230 checks passed.
- `python3 tools/check_knowledge.py`: "knowledge ok: 119 files".
- `python3 tools/build_knowledge.py`, then `git status --porcelain`: empty.
- `./factory918.sh sync`, then `git status --porcelain`: empty.

## Diff comparison

I compared the changed lines of `git diff origin/main chain/135-rebase` with those of `git diff a9ebdac be9cc3f`, file by file (`.scratch/109/cmpdiff.py` in the owner worktree).

- These files have identical changed lines: AGENTS.md, SOURCES.md, docs/agents/ledger.md, docs/knowledge/core/MANUAL.md, both patches, template/.agents/skills/architect/SKILL.md, autopilot-stack.md, template/AGENTS.md, template/docs/factory918/DECISIONS.md, template/docs/factory918/MANUAL.md and tests/hooks/delegation.sh.
- `docs/knowledge/INDEX.md` differs in a generated count. The DECISIONS line count goes 107 to 108 instead of 106 to 107, because main's P108 row is one line more.
- `docs/knowledge/core/DECISIONS.md` differs in the same generated count, in the `<!-- lines: -->` header (107 to 108 instead of 106 to 107). The rows #135 adds and amends are identical.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` steps 5 and 6 differ because of a conflict resolution. The `-` lines are main's new text (#108 and #137), and the `+` lines are main's text plus #135's two pointer clauses. A word diff of origin/main against the branch shows only #135's insertions: the step 0 tier bullet and its list, the four pointer clauses, the Design hole clause, and the Reply clause.
- `template/docs/agents/review-ladder.md` rung 1 differs because of a conflict resolution. The `-` line is main's rewritten rung 1, and the `+` line is that line plus #135's eco clause. The word diff shows only "context;" becoming "context (in `eco` its two reviewers are the fresh context, Ticket step 0);".
- Nothing else differs. #137's wording forced no update.

Claude Opus 5.5 on Claude Code
