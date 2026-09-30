# Writer brief, ticket #106 (Zenoctra/factory918)

You implement ticket #106 in your own worktree. Start: `git switch -c wt/106-writer 01a1e5f46891d10b234fe9ee80cbd9e8c67d4438` (the tip of PR #124's branch `feat/reviewer-model-eval`; your work stacks on it). Read `AGENTS.md` (the nesting rule, patches, verifying).

The spec: `gh issue view 106 --repo Zenoctra/factory918` whole. Its `## Testing decisions` section (Terms, tables A and B, Contract, Tests) is the design; implement it as written. It is also at "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/106/testing-decisions.md". The worked example of the mechanism you extend is ticket #93's Testing decisions and the code PR #102 added (already in your base): the `would-break fixed after` line, `fixed_items`, `fix_rule`, `FP`/`FR`/`FT`. The `cites:` grammar #121 changed stays as it is.

Data shape first (principle-model-the-domain): the per-round facts crossing rounds are comment lines (`reviewed: <sha>` at round one, `fix only after <sha>` at round two, `next round owed: round <N> reviews the fixes marked here` at rounds one and two) and two dir files (`<dir>/reviewed` exists; `<dir>/fix-lines` new, written by review-brief.sh at round two). The fix-only decision is one variable pair (`from`, `via`) that both the round-three gate and #93's round-four/five gate set, and one block runs FR/FP/FT for both. Keep that shape; no scattered round conditionals.

Commit order (the commit order must show it):
1. Tests first: `tests/spec-review/review-brief.sh` and `tests/spec-review/review-comment.sh`, one assertion per cell in the table's order, each labeled with its cell (e.g. `(5A)`), plus the direct assertions for #93's cells 13B (#93 table A row 13 column B), 5C and 5D (#93 table B row 5 columns C and D), and the moved existing assertions the Tests list names. At this commit the new assertions fail; that is expected.
2. The scripts: `template/.agents/skills/spec-review/scripts/review-brief.sh` and `review-comment.sh`. All tests pass.
3. The prose: spec-review SKILL.md steps 1, 4, 6 (the template file AND its patch `patches/mattpocock/spec-review.SKILL.md.patch`, per `patches/README.md`; `SOURCES.md` if the design says so), both babysit copies (`template/.agents/skills/poteto-mode/playbooks/babysit.md`, `template/.agents/skills/babysit/SKILL.md`) through their patches, `template/docs/agents/review-ladder.md` (and its copy under `docs/agents/` if one exists: AGENTS.md says those are copies), `docs/knowledge/core/MANUAL.md` then `python3 tools/build_knowledge.py` (commit what it regenerates), `tests/spec-review/no-stale-wording.sh` if the design names a phrase. Do NOT edit `docs/knowledge/core/DECISIONS.md`: the owner writes P20's amendment.

Rules:
- A cell you cannot implement as written: stop and report the cell; never fill it in yourself.
- Rounds one and two's brief output (stdout and both briefs) stays byte for byte what it is today (criterion 1); the `same` helper proves it.
- Comments: only a non-obvious why. The scripts' header comments carry the design's clauses. `/deslop` over your diff before the last commit.
- Commits: plain-sentence titles naming #106, ending with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Never push, never open a PR, never touch GitHub beyond reading.

Verify, and report each outcome:
- `bash tests/spec-review/review-brief.sh`, `bash tests/spec-review/review-comment.sh`, `bash tests/spec-review/no-stale-wording.sh`.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` and `bash tests/shellcheck/gate.sh`.
- `bash tests/hooks/delegation.sh`, `bash tests/poteto-mode/overlap.sh`, `bash tests/spec-review/review-brief.sh` again after the prose commit (it pins SKILL.md and babysit text).
- `./factory918.sh sync` leaves `git status` clean; `python3 tools/build_knowledge.py` leaves it clean and `python3 tools/check_knowledge.py` passes.
- Run the new review-comment.sh on a round-two fixture dir and paste the tail it printed.

Report: an act-on list (one item per flag, risk or deviation, each marked "fix", "accepted: reason" or "ask"), the branch name, `git log --oneline 01a1e5f..HEAD`, each verification with its outcome, and any cell you could not implement. Write it to a file inside your worktree, then `cp` it to "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/106/writer-report.md", and reply with only that path.
