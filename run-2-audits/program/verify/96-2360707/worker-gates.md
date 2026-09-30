verdict: PASS

# Slice: gates — PR #96 (ticket #88) at 2360707f9bf56e4216f81ec652f20d4682ba24c4

Every repository gate was re-run at the SHA in a detached worktree of my own, with a private
`TMPDIR` (`.../scratchpad/vtmp-gates`, and `.../vtmp-dl` for the download probe) so no cache was
shared with another verifier. Nothing under version control was changed: `git status --porcelain`
was empty at the start, after `build_knowledge.py`, and after each `sync`.

Setup: `git fetch origin feat/shellcheck main`, `git checkout --detach 2360707…` →
`git rev-parse HEAD` printed `2360707f9bf56e4216f81ec652f20d4682ba24c4`. Exit 0.
`shellcheck --version` on PATH is `0.11.0` (`/opt/homebrew/bin/shellcheck`), which is the pin.

## 1. The `AGENTS.md` "Verifying" list as it reads at the SHA

The list at the SHA has nine bullets; `bash -n factory918.sh` is gone, replaced by the ShellCheck
line, which claims "It replaces `bash -n`, whose set it covers."

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, exit 0. The "20 files" in the AGENTS.md sentence is exact.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0. Case 9 was not skipped (Darwin.arm64 is pinned), so the bad-tarball assertions ran.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 82 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 334 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 56 assertions`, exit 0.
- `bash -n factory918.sh` (dropped from the list; run anyway) → no output, exit 0.
- The coverage claim checked directly: the old `bash -n` set (18 files) against the new gate set (20 files); `comm -23` of the sorted lists is empty. The two additions are `template/.agents/skills/show-me-your-work/scripts/log.sh` and `template/.github/shellcheck.sh`. The new set is a strict superset, so "whose set it covers" holds.
- The fixture-flow bullet was not run in full; see check 6.

## 2. Every file under `tests/` (skipping `fake-gh.sh`)

`find tests -type f` lists eight files. Six are runnable entry points; `fake-gh.sh` is skipped per the
slice, and `tests/shellcheck/gate.sh` is counted in check 1 as well.

- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 56 assertions`, exit 0.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0 (added by this diff).
- `bash tests/spec-review/layout.sh` → no output, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 334 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 82 assertions`, exit 0.

No test under `tests/` is left unrun. The diff adds `tests/shellcheck/gate.sh` and touches
`overlap.sh`, `layout.sh`, `review-brief.sh`, `review-comment.sh` and `fake-gh.sh`; all pass.

## 3. Knowledge

- `python3 tools/check_knowledge.py` → `knowledge ok: 118 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 118 → docs/knowledge`, exit 0; `git status --porcelain` printed nothing.

## 4. `./factory918.sh sync`

Run twice, the second time under `bash` so the exit code could be captured (the harness shell is zsh,
where `PIPESTATUS` reads empty).

- `./factory918.sh sync` → exit 0; `applied` lines: 17, matching `wc -l patches/series` = 17; no `FAILED` line and no `missing our skill` line; tail: `vendored: 72 skills. Review with git status, bump VERSION, commit.`
- `git status --porcelain` after each run printed nothing.

Worth recording for the reviewer: the three files this diff changes under the vendored tree
(`template/.agents/skills/spec-review/scripts/review-brief.sh`, `…/review-comment.sh`,
`template/.agents/skills/poteto-mode/scripts/overlap.sh`) need no patch, because all three sit in
`sync`'s `keep_files` at `factory918.sh:385` — they are ours, copied out and back around the
re-vendor. So the clean status is not vacuous for them: sync does overwrite and restore them.

## 5. Patches the diff added or changed

The diff touches exactly one patch, `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`
(plus the prose line for it in `SOURCES.md`). Regenerated with the `patches/README.md` command:

    diff -u --label a/poteto-mode/playbooks/opening-a-pr.md --label b/poteto-mode/playbooks/opening-a-pr.md \
      research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/playbooks/opening-a-pr.md \
      template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md > regen.patch

`diff` exit 1 (the files differ, as expected); `cmp regen.patch patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`
→ no output, exit 0. Byte for byte. The upstream used is the one `sync` reads (`factory918.sh:382`),
not `research/3-pstack/upstream-cursor-plugin/`.

No patch was added, and `patches/series` is unchanged at 17 lines.

## 6. The CI workflows, mirrored locally

The diff changes `.github/workflows/factory-ci.yml` (three steps) and `template/.github/workflows/ci.yml`
(one step). `profiles/python/python.yml` is untouched by the diff. All three files parse under
`python3 -c "yaml.safe_load(...)"`.

Mirrored, in workflow order:

- Factory job, `ShellCheck`: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `files checked: 20`, exit 0. It replaces the removed `Shell syntax` step; the superset check is in 1.
- Factory job, `shellcheck.sh passes, refuses and counts what the test says`: `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- Template `ci.yml`, `ShellCheck`, and the Fixture job's `The shell gate a project runs` are the same zero-argument command (`bash .github/shellcheck.sh`) in the same position, one in a project's own CI and one over `/tmp/fx`. Mirrored by copying `template/` into a scratch directory the way `cmd_apply` does (`cp -Rp`, plus the `.claude/skills -> ../.agents/skills` symlink `apply` creates) and running from its root → `ShellCheck 0.11.0, files checked: 11`, exit 0. That 11 is the number `docs/M0-findings.md:172` and CI both record for the fixture. `ls -l .github/shellcheck.sh` in the copy shows `-rwxr-xr-x`, so `apply`'s `cp -p` carries the mode bit that `gate.sh` case 7 asserts.

Could not mirror, and why:

- The Fixture job around that one added step (`vp create vite:monorepo`, `./factory918.sh apply --scaffold --profile python`, `vp check`, `vp test run`, `pnpm sg:test`, the `python.yml` steps). It needs a network `pnpm install` and many minutes, and the diff adds no step to it beyond the gate line. The substitute above runs the same command over the same file set, because a project's `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh` come from `template/` unchanged and the python profile adds only workflow YAML (`factory918.sh:42-46`). Run 35753462947 at this SHA shows `JOB Fixture: success` and the step `The shell gate a project runs: success`.
- The `ubuntu-latest` leg. This machine is Darwin.arm64, so the `linux.x86_64` pin and its sha are exercised only by CI, which is green at this SHA.

Beyond the slice, the download path the common brief points at: with ShellCheck hidden
(`PATH=/usr/bin:/bin:/usr/sbin:/sbin`, `command -v shellcheck` empty) and a fresh private `TMPDIR`,
`bash .github/shellcheck.sh factory918.sh` → `ShellCheck 0.11.0, files checked: 1`, exit 0. The
tarball it fetched hashes to `56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79`,
exactly the `sha_darwin_aarch64` constant in the script; the extracted binary reports `0.11.0`; a
second run reused the cache, exited 0 again and printed nothing extra, so the `1362b48` fix that
discards the checksum tool's `OK` line holds on a real download, not only in the test's fixture.

## 7. The six CI runs

`gh run view <id> --repo Zenoctra/factory918 --json headSha,conclusion,event,status,displayTitle`.
All six are `event: pull_request`, `status: completed`:

- 35747640954 — `69bd41230e0f62e0824403196243c013118fb302` — success
- 35749314626 — `01e538672e645e670dda4d9707845cc9a761019f` — success
- 35750682737 — `a64c7e6c000d63c1a21352cbea18b768b6de7fd5` — failure
- 35751339998 — `1362b48fa2d50ab1d5989f4126d4ba729ff227ea` — success
- 35752369368 — `3f3814c00750cc48f1b495b73168381aeb0a761f` — success
- 35753462947 — `2360707f9bf56e4216f81ec652f20d4682ba24c4` — success

Each headSha matches its row in the report's table (report.md:65-70). The last is at the head SHA and
is a success: `gh run view 35753462947 --json jobs` gives `JOB Factory: success`, `JOB Fixture:
success`, and the three gate steps `ShellCheck`, `shellcheck.sh passes, refuses and counts what the
test says` and `The shell gate a project runs` all `success`.

The failure at `a64c7e6` is the one the report describes (report.md:67, "gate.sh case 3, the checksum
tool's `OK` line on stderr on the download path only"). `gh run view 35750682737 --log-failed`:

    Factory  shellcheck.sh passes, refuses and counts what the test says  FAIL 3 the refusal is on stderr
      got:    /tmp/shellcheck-0.11.0/sc.tar.xz: OK
    shellcheck.sh: no file matched nope/*.sh; the gate checked nothing
      wanted: shellcheck.sh: no file matched nope/*.sh; the gate checked nothing
    ##[error]Process completed with exit code 1.

One job, one step, one assertion; nothing else failed in that run.

## 8. The `.github/shellcheck.sh` symlink

- `ls -l .github/shellcheck.sh` → `lrwxr-xr-x@ 1 manuel staff 33 … .github/shellcheck.sh -> ../template/.github/shellcheck.sh`.
- `git ls-files -s .github/shellcheck.sh` → `120000 2e847277a33909d2b87144302992ab9ea23da178 0 .github/shellcheck.sh`. Mode 120000, a symlink in the index, not a second copy.
- It resolves at the SHA: reading `.github/shellcheck.sh` returns the 49-line script, identical to `template/.github/shellcheck.sh`, and every factory gate run above went through this path.

## Issues

None.

## Notes

- The Linux leg of the pin (`sha_linux_x86_64`) is proved only by CI; this machine is Darwin.arm64. The Darwin sha I verified byte for byte against a fresh download.
- The Fixture job was not re-run locally (network `pnpm install`, minutes). The one step the diff adds to it was mirrored against a `cp -Rp` copy of `template/` over the identical file set, and CI at the head SHA has the real job green.
- `tests/shellcheck/gate.sh:78` asserts the zero-argument project form counts 4 files in its synthetic fixture; the real template counts 11. Same code path, different file set, so the test does not pin the real number. Not a defect, only worth knowing if someone later adds a hook or a skill script and expects the test to notice.
- `./factory918.sh sync` returns `$failed` and prints no status of its own; under the harness's zsh `${PIPESTATUS[0]}` reads empty, so the exit code above came from a `bash` wrapper. Nothing wrong with the script, a note for whoever scripts this gate next.
- `docs/M0-findings.md` carries the dated `## ShellCheck (2026-09-22)` entry that the last "Verifying" bullet requires for a tool-version claim, and its two shas, its `files checked: 20` and its `files checked: 11` all match what I measured.
