## Would break

## Fails open

1. **A named file or glob that matches nothing is dropped silently when another argument matches.** CODING_STANDARDS.md, Bash: "A failure a gate depends on is printed before anything continues." The gate refuses only when the whole argument list matches nothing. One argument that matches no file (a misspelled path, or a path that is no longer where the lane thinks it is) beside one that matches is skipped without a word. The count line is the only trace, and the gate exits 0. Run at this commit: `bash .github/shellcheck.sh factory918.sh typo.sh` prints `ShellCheck 0.11.0, files checked: 1` and exits 0.
Documented step: template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9 "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"
Result: a changed file named wrongly is never checked, and the lane reads exit 0 as a pass for every file it named.
spec: table A glob matches no file/Exit

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

2. **An argument with a space is split into words, and each word is dropped.** CODING_STANDARDS.md, Bash: "Quote every path. Paths here contain spaces." and "Test a command the way a user types it: absolute paths, from another directory". `for f in $g` splits each argument on whitespace before it globs. A path with a space becomes several non-files, and the `[ -f ]` filter drops each one silently. Lanes type absolute paths, and this checkout's absolute path has spaces in it (`Under The Sun Collective`). Run at this commit, with a planted SC2086 in `<scratch>/with space/bad.sh`: `bash .github/shellcheck.sh "<scratch>/with space/bad.sh" factory918.sh` prints `ShellCheck 0.11.0, files checked: 1` and exits 0. The finding is never reported. When the spaced path is the only argument, the gate refuses with "no file matched", which names a file that exists. The fix is the same loop as item 1: expand each argument as a quoted glob with no word splitting, and refuse any argument that matches nothing.
Documented step: template/AGENTS.md:63 "Shell: `bash .github/shellcheck.sh` before a PR, on the files the diff changes"
Result: a changed file named by an absolute path under a directory with a space is not checked, and the gate exits 0 on the others.
spec: design `shellcheck.sh [glob...]`

```sh
for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
```

## Standards breaches

3. **Two directive reasons misdescribe the code they suppress.** CODING_STANDARDS.md, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line". In `review-comment.sh:40` the reason says the block is "Markdown emitted verbatim", but `fenced` is an awk program. Its backticks are regex literals that match Markdown fence runs, and nothing is emitted. The file-level reason in `review-brief.sh:17` says "every single-quoted string here is a jq program or a Markdown template", but two of the sixteen sites it covers, `split=` and `fenced=`, are awk programs. A reason that names the wrong language points the next reader at the wrong check.

```sh
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
```

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

## Fix alongside

4. **The cached binary runs without a version or checksum check (a judgement call against P2/P25's pin).** The sha256 is checked only at the moment of download. On later runs, any executable already at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` runs with no check. On Linux, where `/tmp` is shared, that can be a file some other user put there. The design says the gate "checks its sha256, and runs that". Two ways to keep that true: run `"$bin" --version | grep -qx "version: $version"` on the cached path too, or keep the tarball and verify it before each extract.

```sh
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
```

5. **Directive reasons cite a line number (fragile reference).** Three SC2086 reasons in `delegation.sh` say "set -f is on (line 7)". A header line added above line 7 makes all three wrong, and nothing checks them. "set -f is on (the `set -fuo pipefail` at the top)" stays true.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

6. **Duplicated Code: the factory's file set is written out twice.** The five-argument list appears verbatim in `factory-ci.yml:19` and in `AGENTS.md:38`, together with its count. A new glob or file has to be added in both places, and the count in prose has to change with it.

```
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
```

hard findings: 2
