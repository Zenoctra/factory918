## Would break

## Fails open

1. **A named file whose path holds a space is dropped, and the gate passes.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." and "Test a command the way a user types it: absolute paths, from another directory". The glob loop expands each argument unquoted, so the argument is split on whitespace as well as globbed. Each piece fails `[ -f ]` and is skipped without a message. When another argument matches, the run checks only that file and exits 0. When the spaced path is the only argument, the refusal says "no file matched" for a file that exists and does not tell the user how to correct the call. Run at this commit with ShellCheck 0.11.0 on PATH, where `with space/bad.sh` holds an unquoted `cat $f` (SC2086):
   `bash .github/shellcheck.sh "$S/with space/bad.sh" factory918.sh` printed `ShellCheck 0.11.0, files checked: 1` and exited 0. The same file copied to a path without a space reported SC2086.
   Every absolute path into this repository holds a space (`Under The Sun Collective`), and lanes are told to use absolute paths. So a lane that follows the playbook with absolute paths, mixed with one relative path, gets a pass on a file that was never checked.

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"
Result: the file with a space in its path is not checked, and the gate prints a count one short of the arguments and exits 0.
spec: design `shellcheck.sh [glob...]`

2. **A named path that matches nothing is dropped when another argument matches.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues." The design table has a row for a glob that matches no file. That row ends in a refusal on stderr and exit 1. The script refuses only when every argument together matches nothing. `bash .github/shellcheck.sh template/.claude/hooks/nope.sh factory918.sh` printed `ShellCheck 0.11.0, files checked: 1` and exited 0, with nothing on stderr. So a lane that mistypes one of the changed files gets a pass. The blast radius documents the zero-argument form's tolerance as deliberate: with the hooks deleted it counts 6 files. A per-argument refusal when arguments are given keeps that form as it is.

```sh
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

Documented step: ticket #88 `## Design` table, row "A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1"
Result: exit 0 with `files checked: 1`; the missing path is not named anywhere.
spec: table A glob matches no file/Exit

## Standards breaches

## Fix alongside

3. **The doctor passes any ShellCheck version, but the gate accepts only the pin (Information leakage).** On an off-pin install, the doctor prints `PASS  shellcheck 0.9.0`, and the gate ignores that binary. On a pinned platform the gate downloads the pin. On any other platform it refuses. The NOTE's fix text says `.github/shellcheck.sh downloads the pinned build without it`, which is true only on Linux x86_64 and macOS arm64. Also, `apt install shellcheck` installs an off-pin version that the gate still refuses on an unpinned platform. The pin is known in the gate but not in the doctor.

```sh
local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

4. **The directive reasons in `delegation.sh` cite a line number.** The three SC2086 reasons say `set -f is on (line 7)`. This is true at this commit, but it becomes false as soon as a line is added above line 7. Naming the statement (`set -fuo pipefail` at the top) has the same meaning and does not drift.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

5. **Gate test case 6 follows a different path on CI than its name says.** The header says "ShellCheck hidden", and the case is named "without ShellCheck". Its PATH keeps `/usr/bin`. The ticket's design says the `ubuntu-latest` image carries an off-pin ShellCheck, which is `/usr/bin/shellcheck`. On CI, then, the case reaches the refusal through the off-pin branch, not the absent one. If a machine has 0.11.0 in `/usr/bin`, the case fails, loudly. It does not fail open.

```sh
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
```

hard findings: 2
