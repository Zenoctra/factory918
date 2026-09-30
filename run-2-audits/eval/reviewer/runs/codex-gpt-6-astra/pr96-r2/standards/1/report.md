## Would break

1. **A quoted path can check a different file.** `CODING_STANDARDS.md`, Bash: “Quote every path. Paths here contain spaces.” The unquoted expansion splits the argument before globbing. With `a b.sh` and a clean `b.sh` present, passing `'a b.sh'` ignores the intended file and checks `b.sh`. Preserve whitespace when expanding each pattern; the new test's spaced working directory does not exercise a spaced argument.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`: “Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens”.

   Result: The gate can exit 0 while the changed file has unchecked findings.

   ```sh
   for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
   ```

## Fails open

2. **An executable cache entry bypasses the pin.** `docs/knowledge/core/DECISIONS.md`, P2: “Pin every tool CI runs to an exact version.” Only the PATH binary receives a version check; an executable at the predictable cache path bypasses both version and integrity checks. The brief records a replacement script being executed successfully. Validate cached contents before reuse or extract from a verified archive into a private directory.

   Documented step: `template/.github/shellcheck.sh:2-4` promises the pinned version, downloading it when the machine does not have it; `template/AGENTS.md:63` directs the pre-PR shell check.

   Result: An unexpected cached executable can return 0 without linting, while the gate announces ShellCheck 0.11.0.

   ```sh
   dir="${TMPDIR:-/tmp}/shellcheck-$version"
   bin="$dir/shellcheck-v$version/shellcheck"
   if [ ! -x "$bin" ]; then
   ```

## Standards breaches

## Fix alongside

hard findings: 2
