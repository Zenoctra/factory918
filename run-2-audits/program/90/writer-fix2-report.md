# Fix report: the restarted round one of PR #99 (ticket #90)

Three new commits on `wt/90-fix2`, from `32978fa`. Every check the brief names passes; nothing was changed from the brief.

- Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-add3a32a5e752d91a`
- Branch: `wt/90-fix2`
- `git rev-parse HEAD`: `384bb43a872c1bca7b63a27aab2590ac37d46fae`

## git log --oneline 32978fa..HEAD

```
384bb43 Record the design-hole decision and the merge read's restart clause
831f4b4 Show a refused hole's value as written
785b158 Expect a hole written without the space to be refused as written
```

## git diff --stat 32978fa..HEAD

```
 docs/agents/ledger.md                                         | 2 ++
 docs/knowledge/INDEX.md                                       | 2 +-
 docs/knowledge/core/DECISIONS.md                              | 7 ++++---
 docs/knowledge/core/MANUAL.md                                 | 2 +-
 template/.agents/skills/spec-review/scripts/review-comment.sh | 8 ++++----
 template/docs/factory918/DECISIONS.md                         | 5 +++--
 template/docs/factory918/MANUAL.md                            | 2 +-
 tests/spec-review/review-comment.sh                           | 3 +++
 8 files changed, 19 insertions(+), 12 deletions(-)
```

## What each commit does

1. `785b158` (S4, test first): one `refuse` beside the 1E loop in `tests/spec-review/review-comment.sh` for an Act on item ending ` hole:table 2/D`, expecting the message to show `'hole:table 2/D'`. Run against the script at `32978fa` it failed with the message showing `'hole: table 2/D'`, as the brief predicted.
2. `831f4b4` (S4, script): `value()` in `template/.agents/skills/spec-review/scripts/review-comment.sh` returns the raw text after the last `hole:`; the two refusals print `'hole:$(value "$line")'`; the comment above `value()` says the value is shown as written. Every existing expected message is byte-identical (their inputs carry the space).
3. `384bb43` (S1, S2, S3, ledger): the MANUAL merge-read clause at `docs/knowledge/core/MANUAL.md:103`; P26 appended to the Provisional table and P20, P21 amended inline in `docs/knowledge/core/DECISIONS.md`; the two ledger lines in `docs/agents/ledger.md`; and what `build_knowledge.py` regenerated (`docs/knowledge/INDEX.md`, `template/docs/factory918/DECISIONS.md`, `template/docs/factory918/MANUAL.md`, plus the `<!-- lines: 94 -->` header the build writes into `DECISIONS.md` itself, which is the extra line in that file's stat).

The test and the script landed as two commits, the test first, so the test hunk precedes the script in history (the brief allowed either shape).

## Checks, with exit codes

| Check | Result | Exit |
|---|---|---|
| `bash tests/spec-review/review-comment.sh` (before the script fix) | `FAIL an Act on hole written without the space, shown as written (1E)`, got `'hole: table 2/D'`, wanted `'hole:table 2/D'` | 1 |
| `bash tests/spec-review/review-comment.sh` (after) | `ok 148 assertions` | 0 |
| `bash tests/spec-review/review-brief.sh` | `ok 422 assertions` | 0 |
| `bash tests/spec-review/no-stale-wording.sh` | `ok: no stale wording` | 0 |
| `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` | `ShellCheck 0.11.0, files checked: 20` | 0 |
| `python3 tools/check_knowledge.py` | `knowledge ok: 118 files` | 0 |
| `python3 tools/build_knowledge.py` then `git status --porcelain` | `knowledge files: 118`, status empty | 0 |
| `./factory918.sh sync` then `git status --porcelain` | `vendored: 72 skills`, status empty | 0 |
| `/deslop` over the diff, `/unslop` over the commit messages and the added prose | nothing to change; the added comments match the files' style, the commit messages carry no dashes or filler, the records text is the brief's | n/a |

MANUAL.md stays under the build's 220-line cap (174 lines, unchanged count; the clause extends one line).

## Changed from the brief

Nothing in substance. Two notes:

- The DECISIONS row is appended at the end of the file, since P25 was the last line; the row shape (six `|` separators) matches P20 to P25.
- The worktree guard refused one compound Bash call (a `tail | od` pipe, a heredoc append and a `git diff` chained with `&&`), so the ledger append was redone as a single python write. Nothing ran from the refused call. This is the behavior the first ledger line records.

No push, no rebase, no amend, no reset.
