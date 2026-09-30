# Spec review: #88, ShellCheck gate

## Walk

1. Factory CI drops `bash -n` and adds a `ShellCheck` step running `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`, plus a step running `tests/shellcheck/gate.sh` (`.github/workflows/factory-ci.yml:19-22`).
2. Template CI gains a `ShellCheck` step running the zero-argument form as the first check (`template/.github/workflows/ci.yml:17-18`); the fixture job runs the same zero-argument form inside `/tmp/fx` (`.github/workflows/factory-ci.yml:54-56`).
3. The Opening a PR playbook patch adds a sentence directing the lane to run `bash .github/shellcheck.sh` on every changed shell file before the PR opens, mirrored into the template's own copy (`patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch:8`).
4. `factory918 doctor` gains a `shellcheck` line: `PASS` with the installed version when `shellcheck --version` succeeds, else `NOTE` naming the platform install command (`factory918.sh:145-147`).
5. `CODING_STANDARDS.md` requires a `# shellcheck disable=` directive to carry its reason as a second comment on the same line, modeled on the fixed `overlap.sh` directive; the gate script does not check for a reason, only the Standards review axis does.
6. `AGENTS.md` Verifying lists the new gate command and `tests/shellcheck/gate.sh`; `docs/M0-findings.md` gets a dated 2026-09-22 entry with the pin, both release checksums, and the findings-fixed count.

## Would break

1. **The zero-argument gate hard-fails a project with no committed hook script, contradicting the fixture claim it degrades to a smaller count.** `template/.github/shellcheck.sh`'s glob loop (`:36-43`) checks each argument in turn and exits on the first unmatched one before looking at the rest: `for g in "$@"; do matched=0; for f in $g; do ...; done; if [ "$matched" = 0 ]; then echo "... no file matched $g ..." >&2; exit 1; fi; done`. The default arguments are `'.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'` (`:36`), tried in that order. A project with no shell file under `.claude/hooks/` (a `vp create` without `--hooks`, or a hook later removed) makes the first glob unmatched, so the run refuses with `no file matched .claude/hooks/*.sh; the gate checked nothing` and exit 1 — before the other two patterns, which may well match, are even tried.

Documented step:
```
Fixture step: the zero-argument form over the template's files gives `files checked: 11`, exit 0; with the hooks deleted, 6 (`.github/shellcheck.sh` always matches itself); from a subdirectory, refused with the gate's own message.
```
Result: the code refuses the whole run (exit 1, "no file matched") the moment one of the three default globs is empty; it does not fall through to count the remaining two patterns as the grounding claims. `template/.github/workflows/ci.yml:17-18`'s new `ShellCheck` step, added by this diff for every project, therefore fails CI outright for any project state without a `.claude/hooks/*.sh` file, a state the fixture avoids only because it is created with `--hooks` (`.github/workflows/factory-ci.yml:51-53`).

## Fails open

## Not asked for

hard findings: 1
