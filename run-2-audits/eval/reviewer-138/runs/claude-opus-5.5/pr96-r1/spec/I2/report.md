## Walk

1. Criterion 1, factory CI. `.github/workflows/factory-ci.yml:19` runs `bash .github/shellcheck.sh` over `factory918.sh`, `template/.github/shellcheck.sh`, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`. The version and both release sha256 values are pinned in `template/.github/shellcheck.sh:13-15`, and the root file is a symlink to it. Run on the snapshot with ShellCheck 0.11.0 on PATH, it printed `ShellCheck 0.11.0, files checked: 20` and exited 0. That is 18 files the ticket names plus the gate and its test.
2. Criterion 2, template CI. `template/.github/workflows/ci.yml:17-18` runs the zero-argument form first in `check`. The default globs (`shellcheck.sh:35`) are `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`, and they use the same script, so the pin is the same. The fixture step (`factory-ci.yml:54-56`) runs the gate character for character in `/tmp/fx`. Run from `template/` as a stand-in for an applied project, it checked 11 files and exited 0. `apply` copies the file with `cp -p`, and `update` adds it as a new template file; CI calls it through `bash`, so the mode bit does not matter. I did not run the download path, which is the one the runner takes because it ships an off-pin ShellCheck.
3. Criterion 3, playbook. `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch:8` adds "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens". I applied the patch with `git apply` to the pinned upstream `opening-a-pr.md`, and the result is byte-identical to `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`. `SOURCES.md` item 3 describes it. The writer lane also gets the rule from `template/AGENTS.md` Verifying, which is where the ticket's Decision quote puts it.
4. Criterion 4, doctor. `factory918.sh:274-276` prints `PASS  shellcheck <version>` when any `shellcheck --version` answers. Otherwise it prints `NOTE  shellcheck` with the fix `brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck)`, and never FAIL. It sits above `slots filled`.
5. Criterion 5, directives. The linted set has 12 `# shellcheck disable=` lines, and each carries a second `# reason` comment on the same line (grep over the 20 files). The `overlap.sh:49` directive, bare at `ab47eb9`, now has its reason. The factory's `CODING_STANDARDS.md` Bash section states the rule, and P25 says CI cannot check that a reason exists and the Standards axis does.
6. Criterion 6, records. `AGENTS.md:38` lists the CI command verbatim with "over 20 files". `docs/M0-findings.md`, "ShellCheck (2026-09-22)", records 0.11.0 and both checksums.
7. Design, row "Every file clean". `shellcheck.sh:44-45` prints the count line and runs `exec shellcheck --external-sources`, which exits 0. `tests/shellcheck/gate.sh` case 1 asserts it; the test passed with `ok 10 assertions`.
8. Design, row "A finding". ShellCheck's own report follows the count line, with exit 1 (gate case 2, SC2086).
9. Design, row "A glob matches no file". `shellcheck.sh:36-43` refuses only when all the arguments together match nothing. One non-matching glob among matching ones is silently dropped; see P1.
10. Design, row "Local ShellCheck absent, platform not pinned". The `case` at `:19-23` refuses with the pinned message. Gate case 6 asserts it with a fake `uname`.
11. Design, row "Local ShellCheck absent or off-pin, platform pinned". `:18-33` downloads into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once and reuses it while the binary is executable. Nothing is written inside the repository. I did not run it.
12. Design, row "Checksum mismatch". `sha256sum -c -` or `shasum -a 256 -c -` exits nonzero, and `set -e` stops the script before `tar` runs.
13. Documentation the diff changes, `template/AGENTS.md` Verifying. The Shell line names the gate before a PR on the changed files, and names the zero-argument form as what CI runs. That matches `ci.yml`.
14. Documentation the diff changes, the per-file run a lane makes. `# shellcheck source-path=SCRIPTDIR source=layout.sh` in both spec-review tests lets a run from `/` or from `template/` resolve the sourced file with no findings, as `docs/M0-findings.md` says.
15. Blast radius. The grounding's Risks heading holds no risks, because everything is listed under Cleared. So this walk has no risk lines.

## Would break

## Fails open

1. **A glob or path that matches nothing is dropped silently when another argument matches.** `shellcheck.sh:36-43` puts every matching file in `files` and refuses only when `files` ends up empty. So `bash .github/shellcheck.sh factory918.sh template/.claude/hooks/typo.sh` and `bash .github/shellcheck.sh factory918.sh 'template/.claude/hookz/*.sh'` both print `files checked: 1` and exit 0. The same happens to the factory CI's five-argument line if one glob stops matching, for example after a directory is renamed: the gate passes while checking fewer files, and nothing names the dead glob. It also happens to a lane that passes a mistyped path with "every shell file the diff changes", and to the zero-argument form at the factory root, which prints `files checked: 6` because `.agents/skills/*/scripts/*.sh` matches nothing there. A path argument that contains a space is split by the unquoted `for f in $g`, and its pieces are dropped the same way. The design row and its refusal message put the check on the glob, so the fix is to refuse each argument that matches no file, naming it. The one exception, a path the diff deletes, would then be refused with a message the lane can correct.
Documented step: ticket `## Design` table, row "A glob matches no file"
Result: exit 0 with a lower count, and the non-matching glob is never named
spec: table A glob matches no file/Prints

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

## Not asked for

2. **The `bash -n` step is removed from the factory CI and from `AGENTS.md` Verifying.** The ticket asks for ShellCheck to run. It does not ask for the syntax step to go. The diff replaces it, and `AGENTS.md:38` says ShellCheck "replaces `bash -n`, whose set it covers". The grounding reports six unparseable probes that ShellCheck rejects with exit 1, and the new set is a superset of the old one. The removal looks safe but was not requested.
spec: criterion 1

```
- [ ] `shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/` and `tests/*/*.sh`, pinned to an exact version
```

3. **The directive rule goes further than criterion 5 asks.** The factory's `CODING_STANDARDS.md` adds a placement rule: "the narrowest scope that covers the intent, above the one statement or at the top of a file whose whole job produces the pattern". `template/CODING_STANDARDS.md` "Suppressions" also gives projects the same-line reason rule for hooks and skill scripts. The criterion asks only for the reason on the same line, in the factory's Bash section. The template sentence fits the ticket's "universally designed" Decision. The scope rule is new.
spec: criterion 5

```
- [ ] A `# shellcheck disable=` directive is allowed only with its reason on the same line; the existing one in `template/.agents/skills/poteto-mode/scripts/overlap.sh` is the model. CI does not enforce the reason; the Standards axis does, and `CODING_STANDARDS.md`'s Bash section says so.
```

hard findings: 1
