## Would break

## Fails open

1. **A glob or path that matches nothing passes when any other argument matches, so a stale CI glob or a mistyped file in a lane's run goes unchecked.** `template/.github/shellcheck.sh:36-43` collects every match into one array and refuses only when the array is empty, so the refusal fires when *every* argument misses and never when one does. Run at `69bd412` from the repository root: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` printed `ShellCheck 0.11.0, files checked: 5`, exit 0; `bash .github/shellcheck.sh template/.claude/hooks/mode.sh template/.claude/hooks/mode.hs` printed `files checked: 1`, exit 0, the typo dropped without a word; the factory's own CI line with `tests/*/*.sh` mistyped as `test/*/*.sh` printed `files checked: 12`, exit 0, so the eight test files fell out of the gate and CI stayed green. Only when everything misses does it say so: `bash .github/shellcheck.sh 'nope/*.sh' 'also/*.sh'` gave `shellcheck.sh: no file matched nope/*.sh also/*.sh; the gate checked nothing`, exit 1, and `tests/shellcheck/gate.sh:66` asserts that single-argument case only. Standard: `CODING_STANDARDS.md:12`, "A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command, never hide it", and the gate's own header at `:10-11`, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass". The ticket's Problem is a finding that reaches CI because nothing ran the linter; a gate that silently narrows its own set is the same hole one directory rename away, and the next step the factory took on `main` (a `tests/*/*/*.sh` glob added later) shows the set does move. The fix is per argument: refuse, naming the argument, when its own expansion adds no file, and the message stops listing `$*` for a miss it did not make. The zero-argument defaults are the gate's own three globs, so the author decides whether a project with no `.agents/skills/*/scripts/*.sh` is a refusal or a pass under the same rule; the fixture project has hooks and scripts either way. The test then gains the row `one argument misses beside one that matches`, which the table does not carry today.
```sh
if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs, so the finding lands in this lane instead of a review round." and `.github/workflows/factory-ci.yml:19` `run: bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`.
Result: a lane that names two changed files with one path mistyped gets the count line and exit 0 and the mistyped file is never linted; a CI glob that stops matching after a directory move drops its whole set from the gate and the step stays green, with only the count on stdout to notice.
spec: table `A glob matches no file`/`Exit`

## Standards breaches

2. **The finding counts in the ShellCheck record have no command beside them.** `docs/M0-findings.md:172` states 57 findings at `ab47eb9`, 6 at `warning`, 1 at `error`, and 0 after the change, and no line near it says what produces those numbers; the nearest command is the 20-file gate line in `AGENTS.md:38`, which runs at HEAD over a different set and counts files, not findings. The numbers are right (regenerated from an archive of `ab47eb9` with `shellcheck -x -f gcc factory918.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh | wc -l`, then with `-S warning` and `-S error`: 57, 6, 1), but the reader has to rediscover the set (the 18 files the ticket names, `-x`, one line per finding) to check them. Standard: `CODING_STANDARDS.md:25`, "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." Pasting the `-f gcc | wc -l` form into the paragraph closes it.
```
At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0 after five fixes and the directives; `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files. The severity floor is the default, not `warning`: SC2086, the unquoted expansion the ticket's Problem names, is info level, so `--severity=warning` leaves that class passing (6 findings at `warning`, 1 at `error`).
```

## Fix alongside

3. **Divergent Change, the doctor's `shellcheck` line reports any version as PASS while the neighbouring `vp` check compares to a pin.** `factory918.sh:274-276` prints `PASS  shellcheck <version>` for whatever `shellcheck --version` answers, so a 0.9.0 from `apt` (the `ubuntu-latest` image's) passes the doctor while the gate ignores it and downloads 0.11.0. Nothing documented is wrong, the gate is the one that has to match the pin and does, but `chk "vp matches the ADR pin"` two screens up sets the pattern, and the NOTE's fix text sends a person to package managers that will install an off-pin build the doctor then blesses. Either print `NOTE` when the version is off the pin, with the gate's download named as the reason it is not `FAIL`, or say in the PASS line that the pin is the gate's, not the doctor's.
```sh
local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

4. **Information leakage, `factory918 update` lands the gate without its mode bit that `apply` and the gate's test both keep.** `cmd_update`'s heredoc adds a file new to the template with `L.write_bytes(n_bytes)` (`factory918.sh:334`), which creates it 0644, while `cmd_apply` copies with `cp -p` (`:137`) and `tests/shellcheck/gate.sh:78` asserts `test -x` on the template copy as part of the contract. Every documented caller runs `bash .github/shellcheck.sh`, so nothing breaks; the bit is simply asserted in one place and dropped in another. The `chmod +x` at `:155` already covers hooks after `apply`; the same line after `update`, or `shutil.copy2`, keeps the two paths alike.
```py
L.parent.mkdir(parents=True, exist_ok=True); L.write_bytes(n_bytes); report["added"].append(rel)
```

5. **Mysterious Name, three directive reasons cite `set -f` by line number.** `template/.claude/hooks/delegation.sh:165`, `:186` and `:209` say "set -f is on (line 7)"; the number is true today (`:7` is `set -fuo pipefail`) and this very diff moved every line under it by four, so the next edit above line 7 turns a reason into a wrong pointer that ShellCheck cannot check. "the header's `set -f`" says the same thing and stays true.
```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $args
```

hard findings: 1
