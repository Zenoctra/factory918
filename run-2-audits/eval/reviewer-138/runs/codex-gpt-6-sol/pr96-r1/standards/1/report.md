## Would break

1. **A quoted shell path with a space is skipped.** `CODING_STANDARDS.md`, Bash, requires quoted paths because paths here contain spaces, and requires testing commands as a user types them. The unquoted expansion splits an already quoted argument before globbing. With a valid file alongside it, the gate exits successfully without checking the file with a space.

   Documented step: Ticket `## Design`: "`bash .github/shellcheck.sh '<glob>' ...` exactly these; quote a glob, the script expands it."

   Result: `bash .github/shellcheck.sh .scratch/work/shellcheck-probe/clean.sh '.scratch/work/shellcheck-probe/bad file.sh'` printed `ShellCheck 0.11.0, files checked: 1` and exited 0, although the second file contains SC2086.

   spec: design bash .github/shellcheck.sh '<glob>' ...

   ```bash
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   ```

## Fails open

2. **An unmatched glob passes when another file matches.** `CODING_STANDARDS.md`, Bash, says a failure a gate depends on is printed before anything continues and must never be hidden. The gate tests only whether the aggregate file list is empty, so a mistyped glob is silently ignored when another argument contributes a file.

   Documented step: Ticket `## Design`, "A glob matches no file" row: print `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr and exit 1.

   Result: `bash .github/shellcheck.sh .scratch/work/shellcheck-probe/clean.sh '.scratch/work/shellcheck-probe/missing/*.sh'` printed `ShellCheck 0.11.0, files checked: 1` and exited 0, with no refusal.

   spec: table A glob matches no file/Exit

   ```bash
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   if [ "${#files[@]}" = 0 ]; then
     echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
     exit 1
   fi
   ```

## Standards breaches

## Fix alongside

hard findings: 2
