## Walk

1. Factory CI's `Shell syntax` step becomes `ShellCheck`, calling the root symlink with the five globs the ticket names (`factory-ci.yml:19`); `tests/shellcheck/gate.sh` joins as its own step.
2. The pin lives in one file: version, both release sha256s and the flags (`template/.github/shellcheck.sh:14-16`), with `--external-sources`, default severity and no `--shell`.
3. A project's `ci.yml` runs the zero-argument form first in `check` (`template/.github/workflows/ci.yml:17-18`); the fixture job runs the same line inside `/tmp/fx`.
4. The Opening a PR playbook, through its patch, tells the lane to run the gate on every changed shell file before the PR opens.
5. `cmd_doctor` prints `PASS shellcheck <v>` or a NOTE naming `brew install shellcheck` and three other package managers (`factory918.sh:274-276`).
6. Both `CODING_STANDARDS.md` copies require a `disable=` reason as a second comment on the same line; `overlap.sh:49` is rewritten to that shape.
7. `AGENTS.md` Verifying carries the command verbatim; `docs/M0-findings.md` gains a dated ShellCheck section, and P25 records the decision.

## Would break

## Fails open

1. **A glob that matches nothing is dropped when another glob matches.** The refusal fires only when the whole set is empty (`template/.github/shellcheck.sh:41-44`); a stale glob beside a live one shrinks the set with no word, and the count line is the only tell. The same loop word-splits unquoted (`:38-40`), so a shell file under a directory whose name holds a space is dropped the same way.

Documented step:
```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```
Result: renaming `tests/` or a skill's `scripts/` leaves factory CI green over a smaller set; the gate reports a pass it did not earn.

2. **A cached binary is run without the sha or the version check.** Once `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` exists, `[ ! -x "$bin" ]` (`:26`) skips the download, the checksum and any re-check that the file is the pin; on a shared box `/tmp` is world-writable, and the author proved a planted script runs in its place.

Documented step:
```
Uses the `shellcheck` on PATH when its version is the pin; otherwise downloads the pinned release ... checks its sha256, and runs that.
```
Result: the gate reports `ShellCheck 0.11.0` while running something else, and passes silently.

## Not asked for

hard findings: 2
