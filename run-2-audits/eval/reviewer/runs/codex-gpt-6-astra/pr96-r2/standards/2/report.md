## Would break

1. **A quoted path can silently select a different file.** `CODING_STANDARDS.md`, Bash: “Quote every path. Paths here contain spaces.” The unquoted expansion splits each argument before expanding its glob. For a changed file `old clean.sh`, if `clean.sh` also exists, the gate ignores the missing `old` fragment, checks only `clean.sh`, and passes. Preserve spaces while expanding each supplied pattern.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`: “Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens”.

   Result: `bash .github/shellcheck.sh 'old clean.sh'` can report one checked file and success while leaving the requested file unchecked.

   ```bash
   for g in "$@"; do
     matched=0
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
   ```

## Fails open

2. **An executable cache entry bypasses the pin.** `docs/knowledge/core/DECISIONS.md`, P2: “Pin every tool CI runs to an exact version”. Executability alone admits a cached replacement without checking its version or integrity. Verify the cached executable against trusted release contents before reuse.

   Documented step: `AGENTS.md:38` prescribes `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`, “ShellCheck at the pin”.

   Result: With no pinned ShellCheck on PATH, a replacement cached script that exits zero produces a successful gate labelled `ShellCheck 0.11.0` without checking any files.

   ```bash
   dir="${TMPDIR:-/tmp}/shellcheck-$version"
   bin="$dir/shellcheck-v$version/shellcheck"
   if [ ! -x "$bin" ]; then
   ```

## Standards breaches

## Fix alongside

hard findings: 2
