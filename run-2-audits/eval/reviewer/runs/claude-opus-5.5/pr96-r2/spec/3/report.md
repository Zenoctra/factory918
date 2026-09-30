## Walk

1. Factory CI: the `ShellCheck` step in `factory-ci.yml` replaces `bash -n`. It runs the gate over `factory918.sh`, the gate itself, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`. The gate holds 0.11.0 and both sha256 sums, and the next step runs `tests/shellcheck/gate.sh`.
2. Template CI: `ci.yml` runs `bash .github/shellcheck.sh` first in `check`. With no arguments the gate checks `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and itself. The fixture job runs the same zero-argument form in `/tmp/fx`.
3. Pin: when the version on PATH is off-pin or missing, the gate downloads the release for Linux x86_64 or Darwin arm64, checks its sha under `set -e` and runs it. It refuses any other platform by name (exit 1), and gate test 6 covers that refusal.
4. Glob rows: every glob that matches no file is refused on stderr with exit 1, also when it stands beside globs that match (01e5386, tests 3 and 3b). Blast-radius risk 3 describes the code before that commit and no longer holds.
5. Playbook: the `**PRs.**` sentence is in both the patch and the synced copy, and SOURCES.md item 3 describes it.
6. Doctor: prints `PASS shellcheck <ver>` or `NOTE`, with the fix `brew install shellcheck` and the equivalents for other platforms.
7. Directive rule: `CODING_STANDARDS.md` carries it in the Bash section and `template/CODING_STANDARDS.md` under Suppressions. `overlap.sh:49` now carries its reason, and every new directive has a same-line reason.
8. `AGENTS.md` Verifying lists the command and the test. `M0-findings.md` has a dated ShellCheck section that names 0.11.0.
9. Risk 1, a cached binary reused without a checksum: this is off the documented path, and a fresh CI runner never reaches it.
10. Risk 2, test 6 on a runner with 0.11.0 in `/usr/bin`: the test would fail loudly, not pass.
11. Risk 3: fixed, see step 4.
12. Risk 4, a lane offline or on an unpinned platform: the gate refuses with curl's message or its own line, exit nonzero.
13. Risk 5, a `ci.yml` conflict on `update`: the conflict goes to `ci.yml.factory-merge` through the existing `cmd_update` path. The gate step does not fail silently here: the conflict is reported.

## Would break

## Fails open

## Not asked for

hard findings: 0
