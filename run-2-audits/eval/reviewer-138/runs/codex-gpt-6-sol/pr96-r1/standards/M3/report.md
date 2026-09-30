## Would break

## Fails open

1. **A subdirectory call can silently lint the wrong source.** `CODING_STANDARDS.md` (Bash) requires a gate to print a failure it depends on before continuing and to test calls from another directory. `docs/knowledge/core/DECISIONS.md` P25 requires a lane's per-file run and CI's whole-set run to give the same answer. The gate documents that `--external-sources` needs the repository root, but it checks only whether each glob matches a file, so an explicit file passed from a subdirectory proceeds. In a reproduction, the root call found SC2154 and exited 1; the subdirectory call of the same script found a different `lib.sh`, printed `files checked: 1`, and exited 0.

   Documented step: `template/.github/shellcheck.sh:6-7` says, "Run it from the repository root: --external-sources resolves a sourced file against the working directory."

   Result: A lane can receive a clean result for a file that the documented root call reports as defective.

   spec: design shellcheck.sh [glob...]

   ```bash
   for g in "$@"; do
     matched=0
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
     if [ "$matched" = 0 ]; then
       echo "shellcheck.sh: no file matched $g; the gate checked nothing" >&2
       exit 1
     fi
   done
   echo "ShellCheck $version, files checked: ${#files[@]}"
   exec "$bin" --external-sources "${files[@]}"
   ```

## Standards breaches

## Fix alongside

hard findings: 1
