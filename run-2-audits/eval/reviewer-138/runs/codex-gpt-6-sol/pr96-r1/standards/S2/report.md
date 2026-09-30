## Would break

## Fails open

1. **A run from another directory can check the wrong sourced file.** `CODING_STANDARDS.md:12-13` requires a gate to print failures before it continues and requires tests with absolute paths from another directory. The gate documents the repository root as required but does not check it. With an explicit absolute target, ShellCheck resolves `./helper.sh` from the caller's directory and can report a clean result for a file with a finding.

Documented step: `template/.github/shellcheck.sh:7-8`: "Run it from the repository root: --external-sources resolves a sourced file against the working directory."

Result: In `.scratch/work/sc-cwd/a`, `main.sh` sources `./helper.sh` and references an unset `$x`; the gate reports SC2154 and exits 1. From sibling directory `b`, which has a `helper.sh` that sets `x`, invoking the same gate with the absolute path to `a/main.sh` prints `ShellCheck 0.11.0, files checked: 1` and exits 0. The wrong working directory proceeds without a refusal or a finding.

spec: design shellcheck.sh [glob...]

```sh
echo "ShellCheck $version, files checked: ${#files[@]}"
exec "$bin" --external-sources "${files[@]}"
```

## Standards breaches

## Fix alongside

hard findings: 1
