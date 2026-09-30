## Would break

## Fails open

## Standards breaches

1. **The gate word-splits a path it is given.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." and "Test a command the way a user types it: absolute paths". `for f in $g` is unquoted so the glob expands, but a space in the argument splits it too. This repository lives under `.../Under The Sun Collective/...`, so an absolute path to a changed file is refused with `no file matched <path>` while the file exists. The refusal is loud, but its message misstates the cause, and the only workaround is to pass a relative path. Setting `IFS=$'\n'` around the loop, or `set -f` off plus `IFS=`, keeps glob expansion and stops the split.

```sh
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
```

## Fix alongside

2. **The doctor passes any ShellCheck version.** Judgement call. The line next to it, `vp matches the ADR pin`, checks the pin. This line prints `PASS  shellcheck 0.10.0` on an Intel Mac, where the gate refuses to run (`not pinned for Darwin.x86_64`). A `NOTE` when `$scv` is not `0.11.0` would match what the gate does.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

3. **A directive reason cites a line number.** Mysterious Name, in its loose sense: `(line 7)` drifts as soon as a line is added above it, and the three reasons in `delegation.sh` then point at the wrong line. "`set -f` is on (the `set -fuo pipefail` at the top)" stays true when lines move.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

hard findings: 0
