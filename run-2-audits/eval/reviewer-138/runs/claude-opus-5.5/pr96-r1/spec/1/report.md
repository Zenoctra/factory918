## Walk

1. Criterion 1, the factory's CI. `factory-ci.yml:19` replaces the `bash -n` step with `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`. `.github/shellcheck.sh` is a symlink to the template's gate. The gate pins 0.11.0 by `--version` match, or downloads that release with a sha256 check. The globs cover every file the criterion names: 1 CLI, 5 hooks, 5 `scripts/*.sh` (no skill has a deeper `scripts/` shell file), 8 under `tests/*/`, plus the gate itself, 20 in all. Run here, the gate printed `ShellCheck 0.11.0, files checked: 20` and exited 0. Each of the 20 files run alone also passes.
2. Criterion 2, the template's CI. `template/.github/workflows/ci.yml:17-18` runs the no-argument form first in `check`. Its defaults are `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`. `cmd_apply` copies the gate (`factory918.sh:131-137`, `cp -p`), and `cmd_update` adds it to existing projects as a new template file. The fixture step `factory-ci.yml:54-56` runs the same command in `/tmp/fx`. Run from `template/`, the no-argument form checked 11 files and exited 0. The python profile adds no shell file.
3. Criterion 3, the Opening a PR playbook. `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch:8` adds the sentence "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens". I applied the patch to the pinned upstream copy in a temp dir, and the result equals `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` byte for byte. `SOURCES.md` item 3 describes it.
4. Criterion 4, the doctor. `factory918.sh:274-276` prints `PASS  shellcheck <version>` when any `shellcheck` answers `--version`. Otherwise it prints a `NOTE` whose fix starts `brew install shellcheck` and names apt, dnf and winget. The line never sets `fail`.
5. Criterion 5, the directive rule. `CODING_STANDARDS.md` gets a new Bash bullet on the directive's reason on the same line. The file's header says the Standards axis reads it, and P25 says CI does not check the reason. Every `# shellcheck disable=` across the 20 files carries a ` # reason` on its own line, which I checked with a grep. `overlap.sh:49` gains the reason it lacked at `ab47eb9`, so it is now the model the criterion names. `template/CODING_STANDARDS.md` "Suppressions" carries the same rule to projects.
6. Criterion 6, the records. `AGENTS.md:38-39` lists the gate command with the count 20, which is right at this tree, and `bash tests/shellcheck/gate.sh`. `docs/M0-findings.md` gets "## ShellCheck (2026-09-22)" with the version, both checksums and the flag reasoning. `template/AGENTS.md:63` gives projects the same Verifying line.
7. Design, the scenario rows the test covers. `tests/shellcheck/gate.sh` passed with 10 assertions: a clean file, a planted SC2086, a glob that matches nothing (refused on stderr), `#!/bin/sh` keeping SC3030, the no-argument form counting 4, and the unpinned platform refused. For the platform row, PATH is set to `$fx/bin:/usr/bin:/bin`. That hides a Homebrew ShellCheck but not one in `/usr/bin`. The runner's apt ShellCheck is off-pin, so the row still reaches the `uname` refusal. A Linux machine with 0.11.0 in `/usr/bin` would fail row 6 loudly.
8. Design, the download and checksum rows. `shellcheck.sh:18-33` picks the platform from `uname`, downloads with `curl -fsSL` into `${TMPDIR:-/tmp}/shellcheck-0.11.0`, and checks with `sha256sum -c -` or `shasum -a 256 -c -`. Under `set -e`, a mismatch exits 1 with the tool's own message. I did not run the download here, because it fetches a file from the network. The fixture job on `ubuntu-latest` is where it is proven.
9. P25 and the playbook's "run it before the PR" claim. From `/`, a per-file run of `tests/spec-review/review-brief.sh`, `layout.sh` and `template/.agents/skills/spec-review/scripts/review-brief.sh` passes, through `source-path=SCRIPTDIR` and `--external-sources`. So a per-file run and the whole-set run agree.
10. Blast radius, Risks. The Risks heading has no entries, so the walk has no risk lines. I spot-checked items from the Cleared list: `delegation.sh` changes by comment lines only (the diff hunks), `${skills:?}` sits under a non-empty `$TEMPLATE` path, and the gate's own test and the full set pass. They hold.

## Would break

## Fails open

1. **An argument that matches no file is dropped whenever another argument matches.** `shellcheck.sh:36-43` (the loop at `:38`) refuses only when all arguments together yield zero files. An argument that matches nothing next to one that matches is skipped without a word. This covers a misspelled or renamed path, a CI glob whose directory moved, and a directory name. The unquoted `for f in $g` also splits a path that contains a space into pieces that match nothing, so that path is dropped too. Examples, all run from the repository root:
   - `bash .github/shellcheck.sh factory918.sh 'typo/*.sh' template/.claude/hooks/nosuch.sh` printed `files checked: 1` and exited 0.
   - `bash .github/shellcheck.sh tests factory918.sh` printed `files checked: 1` and exited 0.
   - An existing `"a b/bad.sh"` with a planted SC2086, passed next to a clean file, printed `files checked: 1` and exited 0.

   The lane's run on "every shell file the diff changes" then passes files it never checked. If a CI glob in `factory-ci.yml:19` stops matching after a rename, the factory's gate passes with fewer files and nobody hears of it. The fix stays inside the design's own refusal: refuse any single argument that matches no regular file, and name it.
   ```
   | A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
   ```
   Documented step: ticket #88 `## Design`, usage line "bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes", and the table row "A glob matches no file".
   Result: the unmatched argument is silently left out. The gate prints a smaller count and exits 0, so the lane or CI treats the missing file as checked.
   spec: table A glob matches no file/Prints

## Not asked for

hard findings: 1
