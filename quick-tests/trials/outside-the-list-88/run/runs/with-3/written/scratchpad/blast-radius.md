### What it does

Adds `template/.github/shellcheck.sh`, which runs ShellCheck 0.11.0 with `--external-sources` over the globs it is given and downloads the pinned build into `${TMPDIR:-/tmp}/shellcheck-0.11.0` when the tool on PATH is not at the pin. The factory runs it through a root symlink in place of `bash -n`; the template CI and the fixture job run the zero-argument form. 57 findings over 20 files become five code edits (two `rm -rf "${skills:?}/$n"`, an array count in `cmd_sync`, two `&& ||` chains turned into `if`) and directives with same-line reasons, four of them comment lines in `delegation.sh`. The doctor gains a `shellcheck` line, PASS or NOTE, never FAIL. The playbook, both `AGENTS.md`, both `CODING_STANDARDS.md`, M0 and P25 carry the rule. Unstated: the gate trusts a network fetch and a cache it never re-verifies.

### The one fact it's safe because of

The hook every PreToolUse runs through is the same program once comment lines are stripped, and the three CLI edits print what they did before. Rung 4.

```
$ git show ab47eb9:template/.claude/hooks/delegation.sh | grep -vE '^\s*#' > old
$ git show 69bd412:template/.claude/hooks/delegation.sh | grep -vE '^\s*#' > new
$ diff old new && echo IDENTICAL        -> IDENTICAL (191 lines kept)
$ bash tests/hooks/delegation.sh        -> ok 55 assertions
$ ./factory918.sh sync | tail -1        -> vendored: 72 skills. (porcelain 0 lines; the old ls|wc form: 72)
$ factory918.sh:273-276 alone, old vs new, HOME with and without the sheet
  -> NOTE/PASS  models sheet identical; new adds PASS  shellcheck 0.11.0, or NOTE  shellcheck when hidden
$ ./factory918.sh apply <scratch repo>  -> real cmd_doctor: PASS  models sheet, PASS  shellcheck 0.11.0
```

`${skills:?}` at `factory918.sh:388` and `:390` cannot fire: `skills="$TEMPLATE/.agents/skills"` at `:381`, `TEMPLATE="$F918_DIR/template"` at `:9`. The gate over the 20 files exits 0, also under bash 3.2; `gate.sh` ok 10; spec-review tests 334 and 82; overlap 56; knowledge build and check clean.

### Risks

1. A sandboxed lane dies on a bare curl line. Without the pin on PATH and without network, `template/.github/shellcheck.sh:28` exits 22 printing only `curl: (22) The requested URL returned error: 403`. Nothing names the gate or the install, and `opening-a-pr.md:9` tells the lane to run it. Likely for subagents here (this session is one); a confused lane, CI still catches the finding.
2. The cache is trusted forever. `:26` reuses `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` with no checksum, and on a shared Linux `/tmp` another user can plant it first. Proved: a planted script printed `PLANTED FILE RAN: --external-sources clean.sh`, exit 0. Unlikely on a fresh runner, real on a shared box.
3. The download path is unproven. Not run on the author's machine (`docs/M0-findings.md:172`) nor here (github.com denied). Rung 3 by reading: `sha256sum -c` and `shasum -a 256 -c` accept the same line and a bad line exits 1; `tar -xJf` works without an `xz` binary on macOS and Ubuntu ships xz. If `ubuntu-latest` already carries 0.11.0 the fixture never exercises it either.
4. An ARM or Intel runner is refused. `:19-22` pins two pairs; `ubuntu-24.04-arm` or a Darwin.x86_64 lane without the tool exits 1 (gate test 6 proves it for a fake pair). Rare today, blocks CI when it hits.
5. `update` leaves `ci.yml.factory-merge` and no gate. A project that edited `ci.yml` goes through `git merge-file` at `factory918.sh:356-362`; `old_template` at `:322-324` reads tag `v<recorded>`, this clone has 0 tags, so every such project gets `(no base at v0.3.0)` and the step never lands, CI still green. Rung 3.
6. The zero-argument form cannot refuse. `:35` always includes the gate itself, so a project that deleted its hooks prints `files checked: 1`, exit 0 (run), though `:10-11` promises a failure. Low.
7. The doctor passes any version. `factory918.sh:274-275` says PASS for a 0.10.0 the gate will replace by download. Cosmetic.

### Cleared

- Hook invocation: `set -f` is on at `delegation.sh:7` (`set -fuo pipefail`), no `set +f` anywhere, so the three SC2086 reasons are true.
- Review in progress: the hook still reads `.claude/state/review` at `delegation.sh:27`; `review-brief.sh:189` matches `*.claude/hooks/*` (hence this writeup); `.github/shellcheck.sh` does not match.
- factory-start day zero: the new line sits above `slots filled` (`factory918.sh:278`) and is never FAIL, so `factory-start/SKILL.md:14` never stops on it; `factory-doctor/SKILL.md:6` prints the table as is.
- Fixture: `cp -p` at `factory918.sh:137` keeps mode 755 (scratch apply gave `-rwxr-xr-x`, byte-identical, 11 files checked); `tail -30` at `factory-ci.yml:53` masked apply's exit before this diff too.
- Symlink: git mode 120000, restored by checkout on Linux; the gate ran through it here; `sync` leaves 0 porcelain lines.
- `bash -n` removed: three syntax errors (missing `fi`, unterminated string, open `for`) all exit 1 under ShellCheck (SC1046, SC1009, SC1073).
- `source-path=SCRIPTDIR` at `tests/spec-review/review-brief.sh:20` and `review-comment.sh:11`: `shellcheck -x` by absolute path from another cwd exits 0; without the line, 2 SC1091 and 4 SC2154.
- show-me-your-work `scripts/log.sh`: file 10 of the 20, untouched, clean alone at ab47eb9.
- spec-review scripts: comment-only directives at `review-brief.sh:17` and `review-comment.sh:40`.
- wizard: `template.sh` is outside both glob sets (2 SC2034 if run); `wizard/SKILL.md:41` still says `bash -n`, vendored.
- knowledge: P25 at `docs/knowledge/core/DECISIONS.md:93` and `template/docs/factory918/DECISIONS.md:85`; SIGPIPE on `shellcheck.sh:18`: 0 of 300 runs misfired.

### Before you merge

```
bash tests/hooks/delegation.sh && bash tests/shellcheck/gate.sh
bash /private/tmp/wsbox/w-20261005-191428-ab29/scratchpad/blast-radius-probe.sh
```

The probe diffs the comment-stripped hooks, plants a cache the gate then executes, and runs the gate offline to show the bare curl line. Then read the fixture log for `curl` (risk 3) and `git tag | wc -l` in a clone that serves `update` (risk 5).
