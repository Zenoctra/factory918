## Would break

## Fails open

## Standards breaches

1. **The gate word-splits every path it is given.** The standard is `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." and "Test a command the way a user types it: absolute paths". The loop expands `$g` unquoted, so the argument is split on spaces as well as globbed. From this repository, `bash .github/shellcheck.sh "$PWD/factory918.sh"` becomes `.../Work/Under`, `The`, `Sun`, ... and is refused with `no file matched /Users/.../Under`. The refusal is loud, so this is not a hard finding, but its message points at the wrong cause. `tests/shellcheck/gate.sh` puts its fixture under `with space`, yet it passes only relative arguments, so the space never reaches a glob. Setting `IFS=` around the loop keeps globbing and stops the split. Add one gate.sh row that passes an absolute path.

```sh
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
```

## Fix alongside

2. **A cached binary is trusted on `-x` alone** (Speculative trust; blast-radius risk 1). The checksum and the version are checked only on the download path. A re-run of `"$bin" --version | grep -qx "version: $version"` after the `if` would cover the cached path in one line.

```sh
  if [ ! -x "$bin" ]; then
```

3. **The doctor prints PASS for any ShellCheck version.** The `vp` checks next to it compare against the pin. This line reports `PASS  shellcheck 0.9.0` even though the gate will not use that build. `NOTE` for an off-pin version would match what the gate actually does.

```sh
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

4. **Directive reasons cite a line number** (`set -f is on (line 7)`, three times in `delegation.sh`). The line number goes stale on the next edit above line 7. Write "`set -f` is on (the `set -fuo pipefail` at the top)" instead.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

hard findings: 0
