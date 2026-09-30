# Standards report

## Would break

## Fails open

1. **A dropped glob does not lower the count it should.** `template/.github/shellcheck.sh:34-39` builds `files` by looping every glob and every match inside it; a glob with zero matches contributes nothing and nothing says so, so the "no file matched" refusal only fires when *every* glob is empty.
   ```
   files=()
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   if [ "${#files[@]}" = 0 ]; then
     echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
     exit 1
   fi
   ```
   Documented step: `template/.github/shellcheck.sh:38`, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass" — read together with `CODING_STANDARDS.md`, "A failure a gate depends on is printed before anything continues... never hide it."
   Result: a rename that empties one glob among several (e.g. a moved `scripts/` directory) drops that glob's files from the check with `files checked: N` merely shrinking; the gate still exits 0 and prints nothing that names the miss.

## Standards breaches

## Fix alongside

2. **Data Clumps.** The pinned version, and each platform's tag and checksum, travel as separate scalars that a fifth field (a third platform) would force apart again.
   ```
   version=0.11.0
   sha_linux_x86_64=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
   sha_darwin_aarch64=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79
   ```
   `template/.github/shellcheck.sh:10-12`

3. **Duplicated Code.** The same shellcheck-disable comment, word for word, appears at three call sites in `delegation.sh` guarding the same `set -f` fact each time.
   ```
   # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   ```
   `template/.claude/hooks/delegation.sh:252,260,268`

hard findings: 1
