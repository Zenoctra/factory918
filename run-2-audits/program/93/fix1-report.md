# PR #102 (ticket #93), review round one: fix lane report

Branch `wt/93-fix1`, one commit on top of 7b01fd6480b3e54a78611db4aca23bf55b4726be.

Commit: fc75ac6 "Say which rounds the would-break line makes fix-only"

## The three hunks

1. `template/.agents/skills/poteto-mode/playbooks/ticket.md`, "Would-break fix", step 1. It now opens by saying the round the comment belongs to decides the next one: on a round-three or round-four comment the next round runs with `<sha>` as its fixed point and the ticket named (`scripts/review-brief.sh <sha> --ticket N`), briefing the fix commits and nothing else with the fixed items under `## The fix under review`; on a round-one or round-two comment the next round runs as any other, from the original fixed point over the whole diff, and the line only says the PR is not review-ready. The rest of the step is unchanged: from round three on the fix lane fixes that round's Act on items before the comment is posted, round three's look for the cause, no count between rounds.

2. `template/docs/agents/review-ladder.md`, rung 1: the closing lines are now `round: N of 3` (`of 5` from round four) and `act-on items: N`. `template/.agents/skills/spec-review/SKILL.md` step 1 had the phrase "the round is one more than the highest `round: N of 3` line among them"; it now reads "`round: N of 3` (or `of 5`) line among them". The skill is vendored, so `patches/mattpocock/spec-review.SKILL.md.patch` was regenerated with the given `diff -u` command (exit 1, as expected) and differs from before by that one line.

3. `template/.agents/skills/spec-review/scripts/review-brief.sh`: the awk program that builds `fixed_items` matched `/fixed: [0-9a-f]{7,40}$/`; it now matches `/fixed: [0-9a-f]+$/`, since an awk interval expression is the one form the two awks do not both accept in every version. Every `grep -E` interval is untouched.

## Verification (from the worktree root, after the commit)

- `bash tests/spec-review/review-brief.sh` -> `ok 648 assertions`
- `bash tests/spec-review/review-comment.sh` -> `ok 192 assertions`
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` -> `ShellCheck 0.11.0, files checked: 20`
- `shellcheck -x template/.agents/skills/spec-review/scripts/review-brief.sh` -> no output, exit 0
- `./factory918.sh sync` -> `vendored: 72 skills. Review with git status, bump VERSION, commit.`; `git status --porcelain` printed nothing
- `python3 tools/build_knowledge.py` -> `knowledge files: 119 → docs/knowledge`; `git status --porcelain` printed nothing

Not pushed; no PR touched.
