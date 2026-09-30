## Would break

1. **A quoted path containing spaces is split and can be silently skipped.** `CODING_STANDARDS.md`, Bash: “Quote every path. Paths here contain spaces.” The gate expands each argument with word splitting before globbing. Passing `clean.sh 'scripts/with space/check.sh'` therefore checks only `clean.sh` when the split fragments do not exist. The new test puts spaces in the working directory but passes only relative filenames without spaces, so it does not cover this behavior. Preserve each argument's spaces while expanding its glob.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`: “Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens”.

   Result: A changed file whose supplied path contains spaces is omitted; with another clean matching file, the gate exits successfully without checking it.

   ```bash
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
