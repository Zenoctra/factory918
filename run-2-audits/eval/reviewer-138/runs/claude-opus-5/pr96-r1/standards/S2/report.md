## Would break

1. **An argument whose path holds a space is split, so the gate never reads the file and still prints a pass.** `template/.github/shellcheck.sh:38` expands each argument unquoted so the shell globs it. Word splitting runs before pathname expansion, so a glob's *results* keep their spaces (a file `wrap/b a d.sh` matched by `wrap/*.sh` is checked, verified), but the *argument itself* is split on IFS first: an argument naming a path that contains a space becomes two words, neither is a file, and `[ -f "$f" ]` drops both. Alone, that argument reaches the refusal at `:40-43`, which says no file matched a path that exists. Beside one argument that does match, nothing is said at all: the gate prints its count and exits 0 with that file unread. The same splitting makes every absolute path in this clone unusable, because the clone's own path contains spaces (`Under The Sun Collective`). `tests/shellcheck/gate.sh:14-16` puts the space in the working directory only, never in an argument, so no assertion covers it. This is not the settled [S1]: there a glob correctly matched nothing and the fix was a refusal when any one argument matches nothing; here the file exists and is named correctly, that refusal would report "no file matched" for a file the gate should have read, and the cause is the split at `:38`. Setting `IFS=` before the loop keeps the glob and stops the split, verified on both a literal path and a pattern.

```sh
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

```
$ bash template/.github/shellcheck.sh 'my dir/bad.sh'          # bad.sh carries an SC2086
shellcheck.sh: no file matched my dir/bad.sh; the gate checked nothing     exit 1
$ bash template/.github/shellcheck.sh ok/good.sh 'my dir/bad.sh'
ShellCheck 0.11.0, files checked: 1                                        exit 0
$ bash template/.github/shellcheck.sh ok/good.sh "/tmp/sctest/my dir/bad.sh"
ShellCheck 0.11.0, files checked: 1                                        exit 0
```

The standard breached is `CODING_STANDARDS.md:8`, "Quote every path. Paths here contain spaces", and `:13`, "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink".
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs, so the finding lands in this lane instead of a review round"; `template/AGENTS.md:63` repeats it, and `template/.github/shellcheck.sh:6` documents the argument form as "exactly these; quote a glob, this script expands it".
Result: a lane that names a changed shell file under a directory whose name has a space, together with any file that does match, reads `ShellCheck 0.11.0, files checked: N` and exit 0 while that file is never checked, so its findings reach CI, the round this gate exists to save. With that argument alone the gate exits 1 claiming no file matched a path that is there.
spec: design shellcheck.sh [glob...]

## Fails open

## Standards breaches

2. **The M0 record's file counts do not reconcile, and the twentieth file is never named.** The ticket's four globs give 19 files at this commit (`factory918.sh` 1, `template/.claude/hooks/*.sh` 5, `template/.agents/skills/*/scripts/*.sh` 5, `tests/*/*.sh` 8 with the new `tests/shellcheck/gate.sh` among them), so 18 before the test joined. The twentieth is `template/.github/shellcheck.sh`, which the CI command adds and this sentence never mentions, so 18 plus the test reads as 19 and a later reader rebuilding the gate's set from the record looks for a lost file. `docs/M0-findings.md:172` also carries no command that regenerates the count; the command lives in `AGENTS.md:38`, a different file. The standard is `CODING_STANDARDS.md:25`, "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby". Both counts are individually true, so nothing behaves differently.

```
At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0
after five fixes and the directives; `tests/shellcheck/gate.sh` joins the set, so the factory's gate
checks 20 files.
```

## Fix alongside

3. **A cached ShellCheck is executed without its checksum.** `template/.github/shellcheck.sh:26-32`: `[ ! -x "$bin" ]` skips the download, and with it the sha256 check, so whatever already sits at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` is what the gate runs. On a machine with an unset `TMPDIR` and a shared `/tmp`, the first writer of that path decides which binary every later gate run executes. A judgement call, not a documented standard: when a fix already touches this block, check the extracted binary's sha or cache under a directory only this user can write.

```sh
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
```

hard findings: 1
