
### What it does

Adds one gate script, `template/.github/shellcheck.sh`, that runs ShellCheck 0.11.0 with `--external-sources` over the files its globs name and downloads the pinned build when the machine has none (`:18-33`). The factory reaches it through a root symlink. Three CI steps call it: the factory's 20 files in place of `bash -n` (`.github/workflows/factory-ci.yml:19`), the gate's test (`:21`), the zero-argument form inside the fixture (`:54-56`); a project's `ci.yml` gets it first in `check` (`template/.github/workflows/ci.yml:17-18`). The 57 findings at `ab47eb9` are resolved by five edits and directives. Not obvious from the diff: `delegation.sh` gains four comment lines and nothing else, the doctor gains a NOTE line above `slots filled`, and `cmd_sync`'s `rm -rf` now reads `${skills:?}`.

### The one fact it's safe because of

Every file a session runs through behaves exactly as before; only new gates and prose were added. Rung 4.

```
$ diff <(git show ab47eb9:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#') \
       <(git show 69bd412:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#') && echo IDENTICAL
IDENTICAL
$ bash tests/hooks/delegation.sh        -> ok 55 assertions
$ ./factory918.sh sync | tail -1        -> vendored: 72 skills. ...   ; git status --porcelain | wc -l -> 0
$ (models-sheet line, old and new, eval'd with HOME with and without the sheet)
with sheet: same output -> PASS  models sheet
without sheet: same output -> NOTE  models sheet
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' \
    'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'   -> ShellCheck 0.11.0, files checked: 20 ; exit 0
$ bash tests/shellcheck/gate.sh -> ok 10 assertions
$ review-comment 82, review-brief 334, overlap 56 assertions; no-stale-wording ok; build_knowledge + check_knowledge -> clean, 118 files
```

`${skills:?}` cannot fire: `skills="$TEMPLATE/.agents/skills"` and `TEMPLATE="$F918_DIR/template"` (`factory918.sh:9`), so the string is never empty. The `set -f` the three directive reasons cite is real: `set -fuo pipefail` at `delegation.sh:7`, no `set +f` anywhere.

### Risks

1. A cached binary is reused with no checksum. Once `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` exists, `[ ! -x "$bin" ]` at `template/.github/shellcheck.sh:26` skips the download and the sha. On a shared Linux box `/tmp` is world-writable. Proven: I replaced the cached file with a two-line script and the gate ran it (`FAKE BINARY RAN --external-sources ...`, exit 0). Unlikely on a CI runner, which is fresh; bad if it happens, because the gate passes silently. Check: `ls -la ${TMPDIR:-/tmp}/shellcheck-0.11.0`.
2. `tests/shellcheck/gate.sh:75` assumes no 0.11.0 lives in `/usr/bin` or `/bin`. Test 6 hides ShellCheck by narrowing PATH; the day the `ubuntu-latest` image ships 0.11.0 in `/usr/bin`, the on-pin branch runs and the test fails: I put `/opt/homebrew/bin` on that PATH and got `FAIL 6 ... got: 0 wanted: 1`. Likely within a year; cost is a red factory CI with no code fault. Check: `shellcheck --version` on the runner.
3. An unmatched glob among matched ones is dropped without a word (`template/.github/shellcheck.sh:38`). `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5`, exit 0. A rename of `tests/` or `scripts/` shrinks the factory set silently; the count in the line is the only tell. Low likelihood, moderate cost.
4. A lane in a sandbox with no network and no ShellCheck at the pin cannot run the playbook's step (`opening-a-pr.md:9`). Offline the gate exits 7 with curl's message (`shellcheck.sh:28`), and an Intel Mac or an ARM Linux runner is refused at `:20-22`. Loud, not silent; the finding moves back to CI, which is the cost the ticket wanted to avoid. Check: `bash .github/shellcheck.sh .github/shellcheck.sh` in the lane's environment.
5. A project that edited its `ci.yml` near the top gets no gate. `cmd_update` runs `git merge-file` (`factory918.sh:357`); a project step inserted right after `actions/checkout` conflicts (exit 1 in my probe) and lands in `ci.yml.factory-merge` (`:362`), leaving `ci.yml` without the ShellCheck step. An edit elsewhere merges clean (exit 0, step present). The doctor does not check for the step. Medium likelihood, low cost.

### Cleared

- Hook's own invocation: comment lines only, proof above; a `Bash` call of the gate passes the hook (exit 0), since `scan_segment` inspects only tee, cat, head, sed and git (`delegation.sh:191-197`).
- Interactive session: the `AGENTS.md:38` command is the CI step verbatim and passes at 20 files.
- Subagent: `source-path=SCRIPTDIR` (`tests/spec-review/review-brief.sh:21`, `review-comment.sh:11`) makes a per-file run from `/` clean; without it, SC1091 and SC2154.
- `factory-start` day zero: the doctor line (`factory918.sh:274-276`) sits above `slots filled` (`:278`) and prints PASS or NOTE, which `factory-start/SKILL.md:14` accepts. `apply` and `update` end in `cmd_doctor ... || true` (`:168`, `:373`); the fixture's `tail -30` parses nothing; `factory-doctor/SKILL.md:6` prints the table as is.
- Review in progress: `review-brief.sh:189` marks `template/.claude/hooks/delegation.sh` cross-cutting, so this grounding is required; the awk at `:199` ends the section at the next `## `, hence none here. The hook's review read (`delegation.sh:27`, `:76`) is untouched.
- poteto-mode: the playbook sentence lives in the patch (`opening-a-pr.md.patch:8`); `sync` leaves the tree clean.
- spec-review scripts: file-level SC2016 directives only (`review-brief.sh:17`, `review-comment.sh:40`); both tests pass.
- show-me-your-work `log.sh` and `worktree-audit.sh`: linted now, clean, but outside `keep_files` (`factory918.sh:385`), so a future finding must be fixed by a patch or `sync` reverts it.
- Fixture step: the zero-argument form over the template's files gives `files checked: 11`, exit 0; with the hooks deleted, 6 (`.github/shellcheck.sh` always matches itself); from a subdirectory, refused with the gate's own message.
- `cmd_apply` copies with `cp -p` (`factory918.sh:137`), so the copy is executable. The symlink is outside `template/`: `apply` never copies it, `git status --porcelain template` ignores it, `actions/checkout` keeps symlinks.
- Removed `bash -n`: six unparseable probes (unterminated `if`, string, `for`, `)`, `$(( ))`, `${x`) all exit 1 under ShellCheck.
- `sha256sum -c -` and `shasum -a 256 -c -` both refuse a wrong sha; macOS `tar -xJf` extracts without `xz` on PATH. A half download leaves no binary, so the next run retries.
- Knowledge: `build_knowledge.py` regenerates `template/docs/factory918/DECISIONS.md` with P25; the tree stays clean.
- wizard: `template.sh` is not `scripts/*.sh`, so it is outside the set (it has findings of its own); `wizard/SKILL.md:41` is vendored and unchanged.

### Before you merge

```
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'   # expect files checked: 20
bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh
diff <(git show main:template/.claude/hooks/delegation.sh | grep -v '^\s*#') <(grep -v '^\s*#' template/.claude/hooks/delegation.sh)
TMPDIR=$(mktemp -d) PATH=/usr/bin:/bin bash template/.github/shellcheck.sh tests/shellcheck/gate.sh   # the download path, once, with the sha OK line
```

