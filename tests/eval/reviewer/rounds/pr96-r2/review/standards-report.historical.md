## Would break

1. **An argument with a space is split, so the gate refuses a file that exists.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces", and "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." `$g` is unquoted, so word splitting runs before pathname expansion: an argument holding a space becomes several words, none a file, and the gate exits 1 claiming nothing matched. This repository's path has spaces; `tests/shellcheck/gate.sh` misses the case, because its fixture root has a space but every argument is relative and space-free.

```sh
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
  if [ "$matched" = 0 ]; then
    echo "shellcheck.sh: no file matched $g; the gate checked nothing" >&2
```

Documented step: `template/AGENTS.md:63`, "`bash .github/shellcheck.sh` before a PR, on the files the diff changes", and `opening-a-pr.md`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes".
Result: a lane that names a file by absolute path under `.../Under The Sun Collective/...` is told `no file matched /Users/.../factory918.sh; the gate checked nothing`, exit 1, for a file that is there; the message names no way to correct it.

## Fails open

2. **A cached binary is run as the pin without ever being checked.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues"; `DECISIONS.md` P25: the gate "holds the ShellCheck version, both release checksums and the flags". The version test runs on PATH's `shellcheck` only; once the cache path exists, `[ ! -x "$bin" ]` skips the download and the sha, and nothing tests what is there. The author's probe put a two-line script at that path and the gate exited 0.

```sh
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
```

Documented step: `AGENTS.md:38`, "ShellCheck at the pin over 20 files".
Result: whatever sits at that path runs instead, and the gate prints `ShellCheck 0.11.0, files checked: 20` and passes. One `"$bin" --version | grep -qx` after the `fi` closes it.

## Standards breaches

3. **The M0 arithmetic is one short.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." 18 plus `gate.sh` is 19; the twentieth, `template/.github/shellcheck.sh`, is never counted.

```
the 18 shell files the ticket names produced 57 findings ... `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files.
```

## Fix alongside

4. **Speculative Generality (breadth).** `review-brief.sh` takes a file-level `disable=SC2016` where its sibling `review-comment.sh` takes statement-level ones; the blanket also hides a future real one.

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

5. **The skill count now cannot be zero.** An unmatched glob leaves the literal, so the line would say `vendored: 1 skills`; `ls -d | wc -l` said 0.

```sh
local -a dirs; dirs=("$skills"/*/)
```

hard findings: 2
