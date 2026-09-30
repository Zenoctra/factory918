## Walk

1. Criterion 1, the factory's CI. `factory-ci.yml:19` runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` in place of `bash -n`. Run at HEAD: `ShellCheck 0.11.0, files checked: 20`, exit 0. Every `scripts/*.sh` under `template/.agents/skills/` sits one level down (five files, `find -path '*/scripts/*.sh'` finds no deeper one), so the one-level glob is the whole set; `wizard/template.sh` is not `scripts/*.sh`. The pin is the script's `version=0.11.0` with both release checksums; the runner image (Ubuntu 24.04, image 20260907, `shellcheck 0.9.0-1` from apt) is off-pin, so CI takes the download branch, never the image's copy.
2. Criterion 2, a project's CI. `template/.github/workflows/ci.yml:17-18` runs the zero-argument form first in `check`; its defaults are `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`. `cmd_apply` copies every template file with `cp -p` (`factory918.sh:137`), so a project gets `.github/shellcheck.sh` executable; `cmd_update` adds it to an older project as a new template file (`:334-339`) and CI calls it through `bash`, so the lost mode bit there does not matter. Run in `template/`: `files checked: 11`, exit 0. The fixture step (`factory-ci.yml:54-56`) runs the same form inside `/tmp/fx`.
3. Criterion 3, the playbook. `opening-a-pr.md:9` carries the sentence through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch:8`, and `SOURCES.md` item 3 describes it. With `--external-sources` and the `source-path=SCRIPTDIR` directives, a per-file run from the root gives the same answer as the whole set, so the sentence is true.
4. Criterion 4, the doctor. `factory918.sh:274-276` reads `shellcheck --version` under `|| true`; with shellcheck on PATH it prints `PASS  shellcheck 0.11.0`, without it the substitution is empty (probed with `PATH=/usr/bin:/bin`) and `note` prints `NOTE  shellcheck` with `brew install shellcheck (apt ..., dnf ..., winget ...)` as the fix. It is a NOTE, not a FAIL, and does not set `fail`.
5. Criterion 5, the directive rule. `CODING_STANDARDS.md:15` (Bash section) states the same-line second comment, with `overlap.sh:49` as the example; `template/CODING_STANDARDS.md:37` states it for projects. All twelve `disable=` directives across the 20 files carry a second comment (a grep for a directive without ` #` after the code list finds none). The gate itself checks only that a directive parses, which is what the criterion asks.
6. Criterion 6. `AGENTS.md:38-39` lists the gate command and the gate test; `docs/M0-findings.md:170-172` is the dated ShellCheck section with the version, the two checksums and the flag reasons.
7. Design usage, `bash .github/shellcheck.sh` and `'<glob>' ...`. The script expands each argument itself (`for f in $g`, unquoted on purpose), keeps regular files, and prints the count before `exec`ing ShellCheck, so a finding prints the count line then the report and exits 1 (the test's row 2). The factory's `.github/shellcheck.sh` is a symlink (mode 120000) to the template's copy, as the design says.
8. Design row "A glob matches no file". The refusal fires only when the whole file list is empty (`files` array of length 0); the test's row 3 covers the one-glob call. See item 2 under Fails open for a glob list that is partly empty.
9. Design rows "absent or off-pin" and "not pinned". Run with `PATH=/usr/bin:/bin` and a fresh `TMPDIR`: the darwin build was downloaded once into `$TMPDIR/shellcheck-0.11.0`, the checksum was checked, and the second run reused the binary. The fake-`uname` row is refused with the exact message (test 6). On the runner image the apt copy lives at `/usr/bin/shellcheck` at 0.9.0, so test 6's `PATH=/usr/bin:/bin` still lands in the download branch and the fake `uname` is what decides; the row holds there too.
10. Design "Writes nothing inside the repository". The only writes are under `${TMPDIR:-/tmp}/shellcheck-0.11.0`; the test's fixture is a temp directory with a space and passes.
11. Blast radius, the Risks heading. The grounding's `### Risks` heading holds no line; every entry is under `### Cleared`. So there is no risk line to walk, and no `fixed:` or `accepted:` disposition to check. The one fact (the hook is byte-identical outside comments) is consistent with the diff: the four `delegation.sh` hunks are comment lines only.

## Would break

1. **The gate test fails on its first run wherever the download branch runs.** `sha256sum -c -` and `shasum -a 256 -c -` print `<path>: OK` on stdout, before the count line. `tests/shellcheck/gate.sh` test 1 compares stdout exactly, so on a machine without the pinned ShellCheck on PATH the first `bash tests/shellcheck/gate.sh` fails and the second passes. Reproduced at HEAD:

```
$ TMPDIR="$(mktemp -d)" PATH=/usr/bin:/bin bash tests/shellcheck/gate.sh
FAIL 1 a clean file
  got:    exit 0: /var/folders/.../shellcheck-0.11.0/sc.tar.xz: OK
ShellCheck 0.11.0, files checked: 1
  wanted: exit 0: ShellCheck 0.11.0, files checked: 1
$ TMPDIR=<same> PATH=/usr/bin:/bin bash tests/shellcheck/gate.sh
ok 10 assertions
```

The factory job on `ubuntu-latest` (image shellcheck 0.9.0, off-pin) passes only because the `ShellCheck` step runs before the test step in the same job and leaves the binary under `/tmp`; reorder the steps, run the test in its own job, or run it on a fresh machine as `AGENTS.md` lists it, and the documented command reports a failure on a clean gate. The design says a download run prints what the clean row prints.
Documented step: `AGENTS.md:39`, "`bash tests/shellcheck/gate.sh`", and the ticket's table, "Local ShellCheck absent or off-pin, platform pinned | downloads once, then one of the rows above", where the row above prints "`ShellCheck 0.11.0, files checked: N`".
Result: the first run prints `FAIL 1 a clean file` with the checksum's `OK` line in `got` and exits 1; the same command passes on the next run.
spec: table "Local ShellCheck absent or off-pin, platform pinned"/Prints

## Fails open

2. **A glob that matches nothing is not refused when another glob matches something.** The refusal at `template/.github/shellcheck.sh:40-43` fires only when the whole `files` array is empty. With several globs, a glob that matches no file is dropped and the run proceeds with the rest:

```
$ bash .github/shellcheck.sh 'nope/*.sh' factory918.sh
ShellCheck 0.11.0, files checked: 1
$ echo $?
0
```

The factory's CI line names five globs and the project's default names three; a moved hooks directory or a renamed `tests/` layout leaves the gate silently checking fewer files, and nothing asserts the count (`AGENTS.md:38` says "over 20 files" as prose). The script's own header (`:10-11`, "Globs that match no file at all") documents the narrower behaviour, so the implementation and the ticket's row disagree; the row's caller column, "fixes the glob; a gate that checked nothing is not a pass", is written per glob.
Documented step: the ticket's table, "A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob".
Result: the empty glob is ignored, the count line reports the files the other globs matched, and the exit is 0.
spec: table "A glob matches no file"/Exit

## Not asked for

hard findings: 2
