## Would break

## Fails open

1. **A cached binary is trusted without the pin.** The version check runs against `shellcheck` on PATH only. Once `$TMPDIR/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` exists, `[ ! -x "$bin" ]` skips both the download and the sha, and whatever sits at that path is executed while the gate prints `ShellCheck 0.11.0`. The author's own probe replaced the cached file with a two-line script and the gate ran it, exit 0.

Documented step: `docs/knowledge/core/DECISIONS.md` P2, "Pin every tool CI runs to an exact version"; `template/.github/shellcheck.sh:2-3`, "Runs ShellCheck at the pinned version ... downloading that version when this machine does not have it".
Result: on any machine with a warm `$TMPDIR` the gate passes with an unpinned, unverified binary and still claims the pin. One `"$bin" --version | grep -qx "version: $version"` after the extract closes it.

```sh
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" ...
```

## Standards breaches

## Fix alongside

2. **An empty array read under `set -u`.** `${#files[@]}` on an empty array is an unbound-variable error on bash before 4.4, which is stock `/bin/bash` on macOS. Only the no-match path reaches it, but that path is what `tests/shellcheck/gate.sh` test 3 asserts, so a macOS lane typing the documented `bash tests/shellcheck/gate.sh` may get a confusing error in place of the gate's own refusal. Standard: `CODING_STANDARDS.md`, "Prefer commands that behave the same on macOS and Linux." `files=("")`-free fix: `if [ "${#files[@]:-0}" = 0 ]`.

```sh
files=()
...
if [ "${#files[@]}" = 0 ]; then
```

3. **A line number inside a comment.** Three directives cite `set -f is on (line 7)`; the number drifts on the next edit above it. Name the line instead: "`set -fuo pipefail` in the header".

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

4. **The new test is not executable.** `tests/shellcheck/gate.sh` lands `100644` while every other test under `tests/` is `100755`, and the file it tests asserts its own mode bit.

hard findings: 1
