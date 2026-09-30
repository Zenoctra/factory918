## Walk

1. Factory CI's `ShellCheck` step runs `bash .github/shellcheck.sh` over `factory918.sh`, `template/.github/shellcheck.sh`, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`, replacing the removed `bash -n` step, then a second step runs `tests/shellcheck/gate.sh` (factory-ci.yml:19-22).
2. Template CI runs the bare `bash .github/shellcheck.sh` in a project, defaulting to `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`; the fixture job re-runs the same bare form inside `/tmp/fx` after apply (ci.yml:17-18; factory-ci.yml:54-56).
3. The Opening a PR playbook's patch adds a sentence telling the lane to run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens (opening-a-pr.md:9).
4. `factory918 doctor` gains a `shellcheck` line printing PASS with the version, or a NOTE naming the install command, never FAIL (factory918.sh:270-273).
5. `CODING_STANDARDS.md` requires a `# shellcheck disable=` directive's reason as a second comment on the same line, modeled on `overlap.sh`'s fixed directive.
6. `AGENTS.md` Verifying lists the ShellCheck command and `tests/shellcheck/gate.sh`; `docs/M0-findings.md` records a 2026-09-22 line with the verified version and both release checksums.

## Would break

1. **The playbook's command does not check every changed shell file.** The sentence tells a lane to run the bare `bash .github/shellcheck.sh` "on every shell file the diff changes," but that invocation only checks the script's hardcoded defaults (`.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh`; `template/.github/shellcheck.sh:35`). A lane changing `factory918.sh` or a file under `tests/*/*.sh` and following this sentence literally gets a silent pass, then hits the finding only when CI's fuller invocation runs — the exact round-trip cost the ticket was written to remove.
Documented step:
```
The Opening a PR playbook (through its patch) names `shellcheck` on every changed shell file before the PR opens, so a lane runs it before CI does.
```
Result: `bash .github/shellcheck.sh` bare skips `factory918.sh`, `template/.github/shellcheck.sh` itself, and `tests/*/*.sh` — files CI's own step does check.

## Fails open

2. **A glob that matches nothing among several is dropped without a word.** The design documents refusal only when the whole set is empty; per-glob mismatches are never surfaced. `for g in "$@"; do for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done; done` (`template/.github/shellcheck.sh:37-39`) silently contributes zero files for a non-matching glob as long as another glob still matches something, so the run exits 0 with a smaller, unannounced count instead of naming which glob missed.
Documented step:
```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```
Result: a glob that matches nothing is refused only when it is the *only* glob passed; alongside a matching glob it silently shrinks the checked set with no message at all, on stdout or stderr.

## Not asked for

hard findings: 2
