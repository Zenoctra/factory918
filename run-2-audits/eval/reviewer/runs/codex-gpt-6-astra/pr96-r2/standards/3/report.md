## Would break

1. **Quoted paths are split again inside the gate.** `CODING_STANDARDS.md`, Bash: “Quote every path. Paths here contain spaces.” The unquoted expansion performs word splitting before glob expansion. Preserve spaces while expanding each supplied pattern.

   Documented step: `template/.github/shellcheck.sh:6`: `bash .github/shellcheck.sh '<glob>' ...` (“exactly these; quote a glob, this script expands it”).

   Result: An argument `'scripts/my check.sh'` becomes `scripts/my` and `check.sh`. If either exists, the gate checks that file and can pass while omitting the requested file; otherwise it incorrectly reports no match. Quoting the argument at the call site does not prevent this.

   ```sh
   for g in "$@"; do
     matched=0
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
   ```

## Fails open

2. **The cached executable bypasses the pin verification.** `docs/knowledge/core/DECISIONS.md`, P2: “Pin every tool CI runs to an exact version.” The PATH executable is version-checked, but the cached executable is accepted solely because it is executable. Validate the cached artifact before reuse.

   Documented step: `AGENTS.md:38` prescribes `bash .github/shellcheck.sh ...`, “ShellCheck at the pin over 20 files.”

   Result: With no matching version on PATH, an existing replacement executable in the predictable cache runs without a version or integrity check. It can return zero without linting anything while the gate announces ShellCheck 0.11.0. The brief records this replacement probe succeeding.

   ```sh
   dir="${TMPDIR:-/tmp}/shellcheck-$version"
   bin="$dir/shellcheck-v$version/shellcheck"
   if [ ! -x "$bin" ]; then
   ```

## Standards breaches

## Fix alongside

hard findings: 2
