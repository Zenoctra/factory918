## Would break

## Fails open

## Standards breaches

1. **Two directive reasons describe code the directive does not cover.** `CODING_STANDARDS.md`, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line". P25 says the Standards axis checks that reason, and a reason that misdescribes the suppressed code misleads the next reader into thinking the suppression was checked. In `review-comment.sh:40` the reason calls `fenced` "Markdown emitted verbatim". `fenced` is an awk program. Nothing in it is emitted. SC2016 fires on its `$0`, which awk reads as the record, and on the backticks in the fence regexes. In `review-brief.sh:17`, the file-level reason says every single-quoted string is "a jq program or a Markdown template". Two of the 16 sites it suppresses are awk programs: `split='` at `:116` and `fenced='` at `:120`, the second a copy of the review-comment fragment. I found them by stripping the directive and rerunning ShellCheck 0.11.0. The scope is fine, since all 16 sites are literal. Only the wording is wrong. Fix: say "awk program" in the first reason and "a jq or awk program or a Markdown template" in the second.

```sh
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
```

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

## Fix alongside

2. **The cached ShellCheck is trusted because it is executable, and the pin is not checked again.** This is a judgement call. The sha256 check covers the tarball only when it is downloaded. On every later run, `[ ! -x "$bin" ]` is the only test before `exec "$bin"`. The count line still says `ShellCheck 0.11.0` whatever that binary is. I probed with `TMPDIR` pointing at a scratch directory and ShellCheck off PATH. A stub script at `$TMPDIR/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` made the gate print `ShellCheck 0.11.0, files checked: 1` and exit 0 on a file with a planted SC2086. An empty executable at that path, which is what an interrupted `tar` leaves, gives exit 1 with `Undefined error: 0` and no hint to delete the directory. On Linux the default is the shared `/tmp`. Fix, if a would-break fix touches this block: after extraction, and before using a cached binary, run the same `--version | grep -qx "version: $version"` test as line 18. On a mismatch, delete the directory and download again, or refuse with a message naming the directory.

```sh
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
```

3. **Three directive reasons point at a line number.** This is a judgement call. The reasons at `delegation.sh:165`, `:186` and `:209` say `set -f is on (line 7)`. A line added to the hook's header makes all three wrong, and nothing catches that. Saying `set -f is on (the set line at the top)` keeps the reason true without the number.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

hard findings: 0
