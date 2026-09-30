## Would break

1. **Quoted paths containing spaces can be silently omitted.** `CODING_STANDARDS.md`, Bash: “Quote every path. Paths here contain spaces.” In `template/.github/shellcheck.sh:38`, expanding `$g` unquoted splits an explicitly supplied filename before glob expansion. With existing `clean.sh` and `bad name.sh`, `bash .github/shellcheck.sh clean.sh 'bad name.sh'` checks only `clean.sh` when neither `bad` nor `name.sh` exists. Findings in the omitted file cannot fail the gate. Preserve each argument's whitespace while expanding globs, and report arguments that produce no files.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`: “Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens”.

   Result: The command can exit successfully after checking only one of the two requested files, without reporting the omission.

   ```bash
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   if [ "${#files[@]}" = 0 ]; then
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
