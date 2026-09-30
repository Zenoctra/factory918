## Walk

1. Factory CI's ShellCheck step runs `template/.github/shellcheck.sh` (via the `.github/shellcheck.sh` symlink) over the factory's 20 named files.
2. Factory CI's gate-test step runs `tests/shellcheck/gate.sh`.
3. The fixture job runs the zero-argument form of the gate inside `/tmp/fx`.
4. A project's `ci.yml` runs the zero-argument gate as an early `check` step.
5. The Opening a PR playbook (through its patch) tells the lane to run the gate on every changed shell file before the PR opens.
6. `factory918 doctor` prints `PASS shellcheck <version>` or a `NOTE` naming the platform install command.
7. A `# shellcheck disable=` directive is required to carry its reason as a second comment on the same line; `CODING_STANDARDS.md`'s `## Bash` section states this, modeled on `overlap.sh`.
8. `AGENTS.md` Verifying lists the gate command; `docs/M0-findings.md` records the pinned version, dated 2026-09-22.
9. The gate uses the local `shellcheck` when its version matches the pin, else downloads the pinned Linux x86_64 or Darwin arm64 build, checks its sha256, and runs it.
10. The gate expands the given globs (or its built-in default set), collects matched files across all of them, and refuses only when the combined set is empty.

## Would break

## Fails open

1. **A silently shrinking glob set.** The emptiness check in `template/.github/shellcheck.sh:40-43` is over the combined `files` array from every glob, not per glob: `for g in "$@"; do for f in $g; do ...; done; done` followed by one `[ "${#files[@]}" = 0 ]` test. When several globs are passed and one matches nothing (a renamed `tests/` or a skill's `scripts/` directory), that glob is dropped with no message; the run still exits 0, and the only tell is the printed count shrinking by whatever that glob would have added.
Documented step: `template/.github/shellcheck.sh:38` comment, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass," and the design table row "A glob matches no file | ... | 1 | fixes the glob; a gate that checked nothing is not a pass."
Result: a single unmatched glob among several proceeds silently at exit 0 instead of being refused; only the whole-invocation case (every glob empty) is refused.

## Not asked for

hard findings: 1
