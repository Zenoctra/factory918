## Walk

1. Criterion 1, the factory's CI: `.github/workflows/factory-ci.yml:19-20` runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` through the root symlink to `template/.github/shellcheck.sh`, which pins 0.11.0 by version check plus a sha256-checked release download. Run at HEAD on this machine: `ShellCheck 0.11.0, files checked: 20`, exit 0. The merge commit itself cannot be checked from here.
2. Criterion 2, the template's CI: `template/.github/workflows/ci.yml:17-18` runs the zero-argument form first in `check`. It covers `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`. `cmd_apply` copies the gate with `cp -p`, and `cmd_update` adds it to an existing project together with the new `ci.yml`. The fixture job runs the same command in `/tmp/fx` (`factory-ci.yml:54-56`). A copy of `template/` with the `.claude/skills` link, gated from its root, gives `files checked: 11`, exit 0.
3. Criterion 3, the playbook: the `**PRs.**` paragraph in `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` now names `bash .github/shellcheck.sh` on every changed shell file before the PR opens. The template copy carries the same sentence, and `SOURCES.md` item 3 records it. Neither `sync` nor git was available here (the snapshot has no `.git`), but the patch's `+` line and the template line match byte for byte in the diff.
4. Criterion 4, the doctor: `factory918.sh:274-276` prints `PASS  shellcheck <version>` when a `shellcheck` is on PATH. Otherwise it prints a NOTE whose fix starts `brew install shellcheck` and lists apt, dnf and winget. Checked here: PASS 0.11.0 with the Homebrew build on PATH, and the NOTE with `PATH=/usr/bin:/bin`. It is a NOTE, never a FAIL, and it cannot fail the doctor.
5. Criterion 5, directives: all 12 `# shellcheck disable=` lines in the gated set, plus the `shell=bash disable=SC2034` line in `layout.sh`, carry a reason as a second comment on the same line. The reason-less one in `overlap.sh:49` gained a reason, so the "model" the criterion names now matches the rule. `CODING_STANDARDS.md`'s Bash section states the rule. P25 records that CI does not enforce it and the Standards axis does.
6. Criterion 6: `AGENTS.md` Verifying lists the exact CI command ("ShellCheck at the pin over 20 files") and `bash tests/shellcheck/gate.sh`. `docs/M0-findings.md` gains `## ShellCheck (2026-09-22)` with the version, both checksums and the flag reasoning.
7. Design usage, `bash .github/shellcheck.sh` with no arguments: the gate substitutes the three project globs (`shellcheck.sh:35`). gate.sh case 5 asserts `files checked: 4` in a synthetic project.
8. Design usage, globs and single files: each argument goes through `for f in $g` and is kept only when `[ -f "$f" ]` holds. The resulting list goes to `shellcheck --external-sources`.
9. Table row "Every file clean": prints the count line and exits 0 (gate.sh case 1).
10. Table row "A finding": the count line, then ShellCheck's report through `exec`, exit 1 (gate.sh case 2, SC2086).
11. Table row "A glob matches no file": refused on stderr with exit 1, but only when every argument together matched nothing (gate.sh case 3, one argument). A glob or path that matches nothing next to one that matches is dropped. See [P1].
12. Table row "Local ShellCheck absent or off-pin, platform pinned": `--version` is compared with `version: 0.11.0`. On a mismatch the gate downloads into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, and a later run reuses the extracted binary. The download was not run here because it needs the network. The fixture and factory jobs on `ubuntu-latest`, whose shellcheck is off-pin, take this path.
13. Table row "Local ShellCheck absent, platform not pinned": exact message and exit 1 (gate.sh case 6, a fake `uname`).
14. Table row "Checksum mismatch": `sha256sum -c -` or `shasum -a 256 -c -` fails under `set -e`, exit 1, and nothing is extracted, so the next run downloads again.
15. Documentation the diff changes: P25 in `docs/knowledge/core/DECISIONS.md`, regenerated into `template/docs/factory918/DECISIONS.md`. `INDEX.md` gives 93 lines, and `wc -l` gives 93. `check_knowledge.py` passes (118 files).
16. Documentation the diff changes: `template/AGENTS.md` Verifying gains a Shell line, and `template/CODING_STANDARDS.md` Suppressions gains the same-line reason rule. See [P3].
17. The `## Blast radius` section's Risks heading is empty (the author put everything under Cleared), so there are no risk lines to walk. For the Cleared claims I re-ran: `tests/hooks/delegation.sh` (55), `review-brief.sh` (334), `review-comment.sh` (82), `gate.sh` (10). Every changed line in `delegation.sh` is a comment.

## Would break

## Fails open

1. **A glob or path that matches no file is dropped silently whenever another argument matches.** The gate collects matches from all arguments and refuses only when the combined list is empty (`template/.github/shellcheck.sh:36-42`). Probes run at HEAD from the repository root:

```
$ bash .github/shellcheck.sh factory918.sh 'template/.claude/hookz/*.sh'
ShellCheck 0.11.0, files checked: 1
exit 0
$ bash .github/shellcheck.sh factory918.sh template/.claude/hooks/delegaton.sh
ShellCheck 0.11.0, files checked: 1
exit 0
```

This matters on the documented path. A lane running the playbook sentence on "every shell file the diff changes" that mistypes one path gets a pass on the rest. A glob in the factory's CI line that stops matching, for example after files move a directory deeper, shrinks the set without a failure. The count line is printed, but nothing checks it and the exit is 0. The same `for f in $g` also splits a path that contains a space into words, and those words are dropped the same way. gate.sh case 3 tests only a single non-matching argument, so the mixed case is untested. Whether the row means "any one glob" or "all globs together" decides the fix. Its message says "no file matched <globs>; the gate checked nothing", which reads as all together. If that reading is the intended one, the fix changes the table row, not the code (rule 5 of Run under).

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: ticket `## Design`, row "A glob matches no file", and the usage line `bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes`.
Result: a non-matching glob or a mistyped path next to a matching one is skipped. The gate prints a smaller count and exits 0.
spec: table A glob matches no file/Exit

## Not asked for

2. **The `bash -n` CI step and its `AGENTS.md` line are removed.** The ticket asks for ShellCheck to run. It does not ask for the syntax step to go. The diff replaces the step and says ShellCheck "replaces `bash -n`, whose set it covers". The blast radius reports six unparseable probes, and ShellCheck rejects each one with exit 1. The new set is a superset of the old one (it adds `template/.github/shellcheck.sh` and every skill's `scripts/*.sh`). As far as I can tell nothing is lost.

```
- [ ] `shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/` and `tests/*/*.sh`, pinned to an exact version (a release download or a pinned action, not whatever the runner image carries), and passes at the merge commit.
```

spec: criterion 1

3. **Project-facing prose beyond the criteria.** The criteria name the factory's `AGENTS.md` Verifying and the factory's `CODING_STANDARDS.md` Bash section. The diff also adds a `Shell:` line to `template/AGENTS.md` Verifying and a same-line-reason sentence to `template/CODING_STANDARDS.md` Suppressions. Both follow from the Decision quote, "it should be present in pretty much every project that inits factory in it too", and from criterion 2. They are consistent with the gate's behavior.

```
- [ ] `AGENTS.md` Verifying lists the command, and a dated line in `docs/M0-findings.md` records the version verified.
```

spec: criterion 6

hard findings: 1
