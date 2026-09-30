## Walk

1. Criterion 1, the factory's CI. `.github/workflows/factory-ci.yml:19` runs `bash .github/shellcheck.sh` with five globs; the root `.github/shellcheck.sh` is a symlink to `template/.github/shellcheck.sh`. At this commit the globs resolve to 1 + 1 + 5 hooks + 5 skill scripts + 8 tests = 20 files (`find` over `tests`, `template/.claude/hooks`, `template/.agents/skills/*/scripts`), and the run prints `ShellCheck 0.11.0, files checked: 20`, exit 0. The only skill shell file outside the set is `wizard/template.sh`, which is not under `scripts/`, as the ticket's glob says. The pin is a version check on whatever `shellcheck` is on PATH (`template/.github/shellcheck.sh:18`), else a release download with a sha256; the download branch I did not run here (it needs the network), so it stands on the author's fixture job.
2. Criterion 1, `bash -n` replaced. An unterminated `if` fed to the gate exits 1, so the syntax class `bash -n` caught still fails.
3. Criterion 2, a project's CI. `template/.github/workflows/ci.yml:17-18` runs the zero-argument form first in `check`; `:39` of the gate sets the globs to `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`. `cmd_apply` copies every template file with `cp -p` (`factory918.sh:137`), so the project gets the script executable; `cmd_update` writes a new template file with Python's `write_bytes` (`:329`), so an existing project gets it 0644, which every documented call (`bash .github/shellcheck.sh`) tolerates. The fixture step (`factory-ci.yml:54-56`) runs it in `/tmp/fx`; not run here (needs `vp`).
4. Criterion 3, the playbook through its patch. Applying `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` to the pinned upstream copy under `research/` reproduces `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` byte for byte, and the patch is on `patches/series:7`. The sentence names `bash .github/shellcheck.sh` on every shell file the diff changes, before the PR opens. `SOURCES.md:15` records it.
5. Criterion 4, the doctor. `factory918.sh:274-276` prints `PASS  shellcheck <version>` when `shellcheck --version` answers, else `NOTE  shellcheck` with `brew install shellcheck` first in the fix and the apt, dnf and winget forms after it. `|| true` on the substitution keeps a missing binary from tripping `set -e`. The line is above `slots filled`, so a day-zero project sees it. An off-pin local build prints PASS with its version; the gate downloads the pin regardless, so no documented call gives a wrong answer.
6. Criterion 5, the directive rule. Every `# shellcheck disable=` in the 20 files carries a second `#` with a reason (grep over the set finds none without). `CODING_STANDARDS.md:15` states the rule and the narrowest-scope placement for the factory; `template/CODING_STANDARDS.md:37` states it for a project under Suppressions. `overlap.sh:49` is the model, now with its reason on the line. The two file-level SC2016 directives (`review-brief.sh:17`, `review-comment.sh:40`, and the three test files) sit at file scope, which the standard allows for a file whose whole job produces the pattern.
7. Criterion 6, the records. `AGENTS.md:38` lists the CI command verbatim and `:39` the gate test; `docs/M0-findings.md:170-172` is dated 2026-09-22 with the version, both checksums and the flag findings (its "the 18 files ... `gate.sh` joins the set, so 20" skips that `shellcheck.sh` is the other joiner; the 20 is true). `docs/knowledge/core/DECISIONS.md:93` adds P25, `INDEX.md` says 93 lines and `wc -l` agrees, and `template/docs/factory918/DECISIONS.md:85` carries the regenerated row.
8. Design row "Every file clean": `clean.sh` prints the count line, exit 0 (`tests/shellcheck/gate.sh:66`, passes here).
9. Design row "A finding": a planted SC2086 prints the count line then ShellCheck's report, exit 1 (`gate.sh:67`).
10. Design row "A glob matches no file": a lone `nope/*.sh` is refused on stderr with the gate's message, nothing on stdout, exit 1 (`gate.sh:68-70`). A glob that matches nothing beside one that does is not refused; see [P2].
11. Design row "Local ShellCheck absent or off-pin, platform pinned": the download branch, `template/.github/shellcheck.sh:24-33`; a half download leaves no `-x` binary, so the next run retries. Not run here.
12. Design row "Local ShellCheck absent, platform not pinned": the fake `uname` case prints `not pinned for Plan9.mips; install it by hand` on stderr, exit 1 (`gate.sh:74-76`, passes here). The test hides ShellCheck by leaving Homebrew's directory off PATH, not by shadowing the binary; see [P1].
13. Design row "Checksum mismatch": `sha256sum -c -` or `shasum -a 256 -c -` under `set -e`, exit 1 with the tool's message. Not run here.
14. The `--external-sources` claim behind P25: `tests/spec-review/review-brief.sh:21` and `review-comment.sh:11` carry `source-path=SCRIPTDIR source=layout.sh`, and `layout.sh:7` carries `shell=bash disable=SC2034 # reason` on one line; the whole-set run is clean.
15. The rest of the suite on this checkout: `tests/hooks/delegation.sh` 55, `review-comment.sh` 82, `review-brief.sh` 334, `overlap.sh` 56, `no-stale-wording.sh` ok, `gate.sh` 10. The only non-comment code edits outside the new script are `factory918.sh` (the models-sheet `if`, `${skills:?}`, the array count in `cmd_sync`) and `tests/spec-review/fake-gh.sh` (an `if` for `&& ... ||`); each keeps the branch it replaced.
16. Blast radius, Risks: the heading is empty, so there is no risk line to walk; the fourteen Cleared lines are the author's, and the ones I could rerun (the 20-file run, `gate.sh`, `delegation.sh`, the patch reproducing the playbook) hold.

## Would break

1. **The gate test's platform assertion holds only while no pinned ShellCheck is in `/usr/bin` or `/bin`.** `tests/shellcheck/gate.sh:73` runs the gate with `PATH="$fx/bin:/usr/bin:/bin"` so the fake `uname` is found and, on this machine, Homebrew's `shellcheck` is not. The gate consults `shellcheck --version` before `uname` (`template/.github/shellcheck.sh:18-19`), so on a host whose `/usr/bin/shellcheck` is the pin (apt and dnf install there; 0.11.0 has been released long enough for a distribution to carry it) the gate finds the pin, never reaches the fake `uname`, prints `ShellCheck 0.11.0, files checked: 1` and exits 0, and assertion 6 fails on a correct gate. Reproduced here by adding Homebrew's directory to that PATH: `PATH="$fx/bin:/opt/homebrew/bin:/usr/bin:/bin" bash template/.github/shellcheck.sh clean.sh` prints the count line, exit 0. The header's "ShellCheck hidden" (`gate.sh:7`) is an assumption about where the binary lives, not something the test does; a shim `shellcheck` in `$fx/bin` that exits 127 would make it true everywhere.

```
`tests/shellcheck/gate.sh` asserts the first three rows, the platform row (a fake `uname` on PATH with ShellCheck hidden) and that a `#!/bin/sh` file keeps its POSIX checks.
```

Documented step: `AGENTS.md:39`, "`bash tests/shellcheck/gate.sh`", and the ticket's Design paragraph quoted above.
Result: on a host with the pinned ShellCheck under `/usr/bin` or `/bin`, the documented verification command prints `FAIL 6 an unpinned platform without ShellCheck is refused` for a gate that is behaving as designed; on this machine and on today's `ubuntu-latest` (off-pin image) it passes.
spec: design `tests/shellcheck/gate.sh` asserts the platform row (a fake `uname` on PATH with ShellCheck hidden)

## Fails open

2. **A glob that matches nothing is dropped silently when any other argument matches.** The refusal fires only on `${#files[@]} = 0` (`template/.github/shellcheck.sh:41-44`); each non-matching glob or path is skipped by the `[ -f ]` test at `:39` with no message. So a renamed directory or a typo in one of the five CI globs, or a test tree one level deeper, leaves that whole set unchecked while the step stays green with a smaller count. Reproduced here: `bash .github/shellcheck.sh 'template/.claude/hookz/*.sh' factory918.sh` prints `files checked: 1`, exit 0; `bash .github/shellcheck.sh factory918.sh 'tests/*/*/*.sh'` likewise; a path with a space, `"my file.sh" clean.sh`, is split into two names that match nothing and prints `files checked: 1`, exit 0. `gate.sh:68` tests only a lone glob, so the case is untested. The header hedges it with "match no file at all" (`:10`), but the design row and the message's "no file matched <globs>" say a glob, and a caller fixing "the glob" cannot tell which one from a count.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: the ticket's Design table, row "A glob matches no file"; `template/.github/shellcheck.sh:10-11`, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass."
Result: the files behind the dead glob are not checked, nothing names the glob, the count line changes, and the exit is 0.
spec: table A glob matches no file/Prints

## Not asked for

hard findings: 2
