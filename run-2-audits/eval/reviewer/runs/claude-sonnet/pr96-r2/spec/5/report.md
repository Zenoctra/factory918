## Walk

1. `template/.github/shellcheck.sh` runs ShellCheck 0.11.0 with `--external-sources`, default severity, no `--shell`, over the files its globs (or the zero-argument default) match; it exits 1 with a stderr message the moment any single glob matches nothing, even beside globs that do match (`template/.github/shellcheck.sh:38-42`).
2. `.github/workflows/factory-ci.yml:19-21` runs the gate over the factory's 20 files (`factory918.sh`, the gate itself, hooks, skill scripts, tests) and then `tests/shellcheck/gate.sh`, replacing the old `bash -n` step.
3. The fixture job runs `bash .github/shellcheck.sh` with no arguments inside `/tmp/fx`, exercising the project-side default set (`.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh`) — `factory-ci.yml:54-56`.
4. `template/.github/workflows/ci.yml:17-18` adds the same zero-argument step first in a project's `check` job; `cmd_apply`'s `cp -p` (`factory918.sh:137`) lands it as a real, executable file in the project.
5. `opening-a-pr.md.patch:8` (and its rendered copy) tells a lane to run `bash .github/shellcheck.sh` on every changed shell file before the PR opens.
6. `factory918.sh:274-276` adds a doctor line: `PASS shellcheck <version>` when found, else `note` naming the install commands per platform, never `FAIL`.
7. `CODING_STANDARDS.md:15` (factory) and `template/CODING_STANDARDS.md:37` (project) both require a `# shellcheck disable=` directive's reason on the same comment; `overlap.sh:49` carries the model instance.
8. `AGENTS.md:38` lists the exact CI command plus the gate's own test; `docs/M0-findings.md`'s new "ShellCheck (2026-09-22)" section records the pin, both release checksums, and the version verified.

## Would break

(none)

## Fails open

(none)

## Not asked for

(none)

Three candidate risks in the blast-radius grounding do not hold against the shipped code: the "unmatched glob among matched ones" case is refused per-glob at `template/.github/shellcheck.sh:38-42` (`no file matched nope/*.sh; the gate checked nothing`, exit 1), proven by `tests/shellcheck/gate.sh` cases 3 and 3b — the grounding's "files checked: 5, exit 0" claim does not reproduce against this diff. The no-checksum-on-cache-reuse point describes the documented download-once behavior itself, not a deviation from it, and no acceptance criterion asks for reverification on every run. The offline/no-network case exits loudly with curl's own message, which the grounding itself calls "loud, not silent." A fourth point, `tests/shellcheck/gate.sh`'s test 6 assuming no ShellCheck 0.11.0 lives in `/usr/bin` or `/bin`, is a real environment-dependent test fragility, but it is speculative (a future CI image change), not a present wrong or silent result on the documented path, and the "Before you merge" run against the actual environment passed at 10 assertions.

hard findings: 0
