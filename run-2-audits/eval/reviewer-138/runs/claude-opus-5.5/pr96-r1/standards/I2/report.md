## Would break

## Fails open

1. **A glob or a path that matches nothing is dropped without a word when any other argument matches.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues." The gate refuses only when the whole file list is empty (`template/.github/shellcheck.sh:40-43`, and its header at `:10-11` says "Globs that match no file at all"). The ticket's design row is per glob. A lane that runs the documented per-file form with one mistyped path, or a factory CI glob that stops matching after a move, gets exit 0. The only sign is a smaller count on the first line. Run at this commit from the repository root:

```
$ bash .github/shellcheck.sh factory918.sh 'template/.claude/hooks/typo/*.sh' template/.claude/hooks/nosuch.sh
ShellCheck 0.11.0, files checked: 1
exit=0
```

```sh
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

Documented step: ticket #88, `## Design` table, row "A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass"; usage line `bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes`.
Result: a glob or path that matches no file, given alongside one that does, is skipped. Nothing goes to stderr and the exit is 0, so the lane or CI treats a partial check as a pass.
spec: table A glob matches no file/Exit

## Standards breaches

2. **Two directive reasons misdescribe the strings they cover.** `CODING_STANDARDS.md`, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line." The reason is there, but in these two places it is wrong. In `review-comment.sh` the `fenced` string is an awk program that matches Markdown fence characters. It is not "Markdown emitted verbatim". The file-level reason in `review-brief.sh` says "every single-quoted string here is a jq program or a Markdown template". Two of its 16 SC2016 sites (lines 116 `split='` and 120 `fenced='`) are awk programs. A reader who checks the directive against the code finds the reason does not match, and the rule exists so that the reason can be checked.

```sh
# template/.agents/skills/spec-review/scripts/review-comment.sh
+# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
 fenced='
   /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
```

```sh
# template/.agents/skills/spec-review/scripts/review-brief.sh
+# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

## Fix alongside

3. **Case 6 of the gate's test does not hide ShellCheck on the CI runner, despite what its header says.** This is a judgement call. The header says the unpinned platform is refused "when no ShellCheck is on PATH (... ShellCheck hidden)". `PATH="$fx/bin:/usr/bin:/bin"` hides a Homebrew install on macOS. On `ubuntu-latest`, where the runner image carries ShellCheck in `/usr/bin`, it hides nothing. The case passes there only because that copy is off-pin. If the image ever carried 0.11.0, the case would fail loudly. Either say "absent or off-pin" in the comment, or point PATH at a directory that holds only `bash` and the fake `uname`.

```sh
+PATH="$fx/bin:/usr/bin:/bin" run clean.sh
+same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
```

hard findings: 1
