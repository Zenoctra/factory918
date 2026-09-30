## Would break

## Fails open

## Standards breaches

1. **The gate's test never runs it the way every document says to type it.** `CODING_STANDARDS.md`, Bash: "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." `AGENTS.md:38`, the playbook and both CI steps type `bash .github/shellcheck.sh`, the root symlink; `tests/shellcheck/gate.sh` copies the file into the fixture instead and runs `$script` by absolute path, so the one form a lane actually types is exercised only by CI. A copy resolves `$(dirname "$0")` and the symlink does not, and nothing in the test set would catch that.

```sh
script="$here/template/.github/shellcheck.sh"
...
cp "$script" project/.github/shellcheck.sh
```

## Fix alongside

2. **Speculative Generality / silent count.** `factory918.sh:388`: with `nullglob` off, an unmatched `"$skills"/*/` leaves the literal pattern, so the line prints `vendored: 1 skills`. The old `ls -d | wc -l` failed loudly. The missing-skill loop below still sets `failed=1`, so this is cosmetic, but the number is what a person reads.

```sh
local -a dirs; dirs=("$skills"/*/)
echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
```

3. **Two tests assume no pinned ShellCheck in `/usr/bin`.** `tests/shellcheck/gate.sh:71` and `:82` hide ShellCheck by narrowing `PATH` to `/usr/bin:/bin`. The day a runner image ships 0.11.0 there, test 6 takes the on-pin branch and test 9 never reaches the checksum, and both fail with no code fault. Hiding it by pointing `PATH` at an empty directory would hold.

```sh
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
```

4. **A reason that cites a line number.** Three directives in `template/.claude/hooks/delegation.sh` say "set -f is on (line 7)". The standard asks for the reason, not the coordinate; the number drifts on the next edit above it while the sentence still reads as fact.

```sh
# shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

5. **Prose narrower than the default set.** `template/AGENTS.md:63` says the zero-argument form "checks the project's hooks and skill scripts"; it also checks `.github/shellcheck.sh` itself, which is why the fixture counts what it counts.

hard findings: 0
