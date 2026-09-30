## Would break

## Fails open

1. **A glob that matches nothing is dropped without a word when another glob matches.** The gate refuses only when every argument matched nothing; an argument that matched nothing is not named when any other one did. `bash template/.github/shellcheck.sh 'nope/*.sh' tests/shellcheck/gate.sh` prints `ShellCheck 0.11.0, files checked: 1` and exits 0; `bash template/.github/shellcheck.sh template/.claude/hooks/typo.sh tests/shellcheck/gate.sh` does the same. The factory's CI step passes five globs, so a directory that moves (`template/.claude/hooks` renamed, or a skill's `scripts/` folded elsewhere) leaves its files unchecked and the step green, which is the case the script's own header calls "a failure, not a pass". The same loop is why a path with a space is lost: `for f in $g` word-splits before it globs, so `'my dir/x.sh'` becomes two words that match nothing and are dropped by the same silent path. Standard: `CODING_STANDARDS.md`, Bash, "A failure a gate depends on is printed before anything continues ... never hide it", and "Quote every path. Paths here contain spaces." A per-argument check (an argument whose expansion has no existing file is refused, naming that argument, before ShellCheck runs) closes both; `IFS=$'\n'` around the loop keeps the glob and stops the split on spaces. The design cell's message text ("the gate checked nothing") would change for the partial case; whether that makes it a design hole under Run-under rule 5 is the judge's call, not this reviewer's.
   ```sh
   files=()
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   if [ "${#files[@]}" = 0 ]; then
     echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
     exit 1
   fi
   ```
   Documented step: ticket `## Design`, table row "A glob matches no file", Prints `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr, Exit 1, "a gate that checked nothing is not a pass"; and `.github/workflows/factory-ci.yml:19`, the five-glob step.
   Result: with any other argument matching, `files checked: N` and exit 0, the unmatched argument named nowhere; the caller reads a pass over files that were never opened.
   spec: table "A glob matches no file"/Prints

## Standards breaches

## Fix alongside

2. **Test 6 hides ShellCheck by trimming PATH, which does not hide a distro copy.** `PATH="$fx/bin:/usr/bin:/bin"` leaves `/usr/bin/shellcheck` visible; `ubuntu-latest` carries one (off-pin today, which is why the test passes there and why the fixture proves the download). On the day the image ships 0.11.0, test 6 fails red and the fixture job stops exercising the download path, with nothing in the diff to show for it. A fake `shellcheck` in `$fx/bin` that prints an off-pin `version:` line hides it on every machine. Smell: environment-dependent test.
   ```sh
   PATH="$fx/bin:/usr/bin:/bin" run clean.sh
   same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
   ```

3. **Three directive reasons cite `line 7`, a number nothing holds in place.** `set -fuo pipefail` is at `delegation.sh:7` today; a line added to the header moves it and the three reasons go quietly wrong. Naming the statement (`set -f in the header`) says the same thing and cannot drift. Smell: a count in prose with no regenerating command.
   ```sh
   # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $args
   ```

hard findings: 1
