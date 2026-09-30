# Spec report

## Walk

1. Factory CI's ShellCheck step runs the gate over `factory918.sh`, itself, the hooks, every skill's `scripts/*.sh` and `tests/*/*.sh` (`.github/workflows/factory-ci.yml:19-20`).
2. Factory CI then runs the gate's own test, `tests/shellcheck/gate.sh` (`:21-22`).
3. The fixture job runs the zero-argument gate inside `/tmp/fx` right after `apply`, before `review-brief.sh` briefs the project (`:54-56`).
4. The template's CI runs the zero-argument gate as a project's first step (`template/.github/workflows/ci.yml:17-18`).
5. `template/.github/shellcheck.sh` resolves files from the globs given (or its own default three globs), refuses any glob matching nothing before ShellCheck runs, uses PATH's `shellcheck` when it already reports version 0.11.0, otherwise downloads the pinned tarball for the running platform once, verifies its sha256 every time that branch runs, extracts and execs it with `--external-sources` and no `--shell`.
6. The Opening a PR playbook, in both the patch and the generated file, tells the lane to run the gate on every changed shell file before the PR opens.
7. `factory918 doctor` prints `PASS shellcheck <version>` when one is on PATH, else a `NOTE` naming the platform install commands (`factory918.sh:274-277`).
8. `CODING_STANDARDS.md` (factory and template) requires a `# shellcheck disable=` directive's reason as a second comment on the same line, modeled on `overlap.sh`'s directive, which now carries one.
9. `AGENTS.md` Verifying lists the gate command and `tests/shellcheck/gate.sh`; `docs/M0-findings.md` records the pin, both checksums and the resolved-findings count under a 2026-09-22 heading.

## Would break

None.

## Fails open

None. The glob-refusal loop (`template/.github/shellcheck.sh:36-43`) checks each glob argument independently and exits before the next is processed, so a later unmatched glob is caught even when an earlier one matched — traced against the code, this holds despite the blast-radius grounding listing it as an open risk.

## Not asked for

None.

hard findings: 0
