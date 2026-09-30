# Fix round 1, PR #96 (ticket #88)

Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a38c70a0aebc65bb1`
Branch: `wt/88-fix1`, created from `FETCH_HEAD` of `origin/feat/shellcheck` at `69bd41230e0f62e0824403196243c013118fb302` (the worktree started on `ab47eb9`, main, so the fetch path was taken).
Commit: `01e538672e645e670dda4d9707845cc9a761019f`
Subject: `Refuse a glob that matches nothing even beside globs that match`
Worktree is clean after the commit. Nothing pushed.

## What changed

1. `template/.github/shellcheck.sh`: each argument is expanded on its own; the first that yields no existing regular file prints `shellcheck.sh: no file matched <that glob>; the gate checked nothing` on stderr and exits 1 before ShellCheck runs. The message keeps the design table's form (ticket #88, `## Design`, row 3) rather than the brief's `...checked nothing it names`, because case 3 of the test compares stderr exactly against that form and the brief said existing cases must still pass. The header comment's glob sentence now states the new rule and its reason.
   One thing beyond the letter of "keep everything else as is": the old whole-set check after the loop (`if [ "${#files[@]}" = 0 ]`) became unreachable, since every argument either adds a file or exits and `$#` is never 0 after the `set --` default, so I removed it instead of leaving a branch that cannot fire. The commit body says so.
2. `tests/shellcheck/gate.sh`: case `3b`, `clean.sh 'nope/*.sh'` exits 1 with the message naming `nope/*.sh` (`check_err`) and nothing on stdout (`same`). Two assertions, so the count went from 10 to 12. The header comment names the new row and was reflowed. Nothing renumbered.
3. `chmod +x tests/shellcheck/gate.sh`, now mode 100755 in the index like `tests/hooks/delegation.sh`.

## Checks, pasted

```
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 20
exit 0

$ bash tests/shellcheck/gate.sh
ok 12 assertions
exit 0

$ bash tests/hooks/delegation.sh
ok 55 assertions
exit 0
```

By hand:

```
$ bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'
shellcheck.sh: no file matched nope/*.sh; the gate checked nothing
exit 1

$ bash .github/shellcheck.sh 'nope/*.sh'
shellcheck.sh: no file matched nope/*.sh; the gate checked nothing
exit 1

$ bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh' 2>/dev/null | wc -c
       0
```

## git diff --stat 69bd412..HEAD

```
 template/.github/shellcheck.sh | 16 +++++++++-------
 tests/shellcheck/gate.sh       |  9 ++++++---
 2 files changed, 15 insertions(+), 10 deletions(-)
```

`git ls-files -s tests/shellcheck/gate.sh` shows `100755`.
