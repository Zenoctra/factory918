# Spec review: shell gate (#88)

## Walk

1. Factory CI runs `bash .github/shellcheck.sh` over the 20 named files in place of `bash -n` (`.github/workflows/factory-ci.yml:19-20`).
2. Factory CI runs `tests/shellcheck/gate.sh` as its own step (`.github/workflows/factory-ci.yml:21-22`).
3. The fixture job runs the zero-argument form inside `/tmp/fx` after `apply` (`.github/workflows/factory-ci.yml:30-32`).
4. `template/.github/workflows/ci.yml` runs the zero-argument form first in `check`, over a project's hooks and skill scripts (`template/.github/workflows/ci.yml:17-18`).
5. The Opening a PR playbook patch adds: run the gate on every shell file the diff changes before the PR opens (`opening-a-pr.md.patch:8`, `opening-a-pr.md:9`).
6. `factory918 doctor` prints `PASS shellcheck <version>` when found, else a `NOTE` naming `brew install shellcheck` and the platform equivalents (`factory918.sh:274-277`).
7. `CODING_STANDARDS.md` and `template/CODING_STANDARDS.md` require a `# shellcheck disable=` directive's reason on the same comment line; CI does not check it, the Standards axis does.
8. `AGENTS.md` Verifying lists the gate command and `tests/shellcheck/gate.sh`, replacing `bash -n` (`AGENTS.md:38-39`).
9. `docs/M0-findings.md` records the verified ShellCheck 0.11.0 pin, both release checksums, and the platform/severity/flag rationale, dated 2026-09-22.
10. `template/.github/shellcheck.sh` downloads the pinned release only when no matching version is on PATH, checks its sha256, and runs it; a glob matching nothing is refused before ShellCheck runs.

## Would break

1. **The update path can silently drop the CI step for an existing project.** `cmd_update`'s `git merge-file` (`factory918.sh:357`) can conflict when a project edited `ci.yml` near the top; the conflict lands in `ci.yml.factory-merge` and `ci.yml` keeps no ShellCheck step. `factory918 doctor` never checks the step is present.

Documented step:
```
The template's CI runs `shellcheck` over a project's `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh`, pinned the same way, and the fixture flow passes it.
```
Result: a project that updates through a conflicting merge keeps `ci.yml` without the gate, and nothing in the factory flags the missing step.

## Fails open

2. **A tampered or corrupted cached binary runs unverified.** The design documents a checksum on the downloaded build. The reviewer's proof (swapping the cached binary at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` for a two-line script) made the gate run that script and exit 0.

Documented step:
```
otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that.
```
Result: once the cache directory exists, whatever binary sits there runs with no re-verification; a shared, world-writable `/tmp` on a persistent Linux box can plant a substitute the gate trusts silently.

## Not asked for

hard findings: 2
