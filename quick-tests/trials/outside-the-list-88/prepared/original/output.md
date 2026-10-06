## Final message

/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/blast-radius.md

## File written: /private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/blast-radius.md

```
### What it does

Adds one gate script, `template/.github/shellcheck.sh`, that runs ShellCheck 0.11.0 with `--external-sources` over the files its globs name and downloads the pinned build when the machine has none (`:18-33`). The factory reaches it through a root symlink. Three CI steps call it: the factory's 20 files in place of `bash -n` (`.github/workflows/factory-ci.yml:19`), the gate's test (`:21`), the zero-argument form inside the fixture (`:54-56`); a project's `ci.yml` gets it first in `check` (`template/.github/workflows/ci.yml:17-18`). The 57 findings at `ab47eb9` are resolved by five edits and directives. Less obvious: `delegation.sh` gains four comment lines and nothing else, the doctor a NOTE line above `slots filled`, and `cmd_sync`'s `rm -rf` reads `${skills:?}`.

### The one fact it's safe because of

Every file a session runs through behaves as before; only gates and prose were added. Rung 4.

```
$ diff <(git show ab47eb9:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#') \
       <(git show 69bd412:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#') && echo IDENTICAL
IDENTICAL
$ bash tests/hooks/delegation.sh  -> ok 55 assertions
$ ./factory918.sh sync | tail -1  -> vendored: 72 skills. ...   ; git status --porcelain -> empty
$ models-sheet line, old and new, eval'd with and without the sheet -> same output both ways (PASS / NOTE)
$ bash .github/shellcheck.sh factory918.sh ... 'tests/*/*.sh'  -> ShellCheck 0.11.0, files checked: 20 ; exit 0
$ bash tests/shellcheck/gate.sh -> ok 10; review-comment 82, review-brief 334, overlap 56; knowledge clean
```

`${skills:?}` cannot fire: `TEMPLATE="$F918_DIR/template"` (`factory918.sh:9`) is a literal suffix, never empty. The `set -f` the three directive reasons cite is real: `set -fuo pipefail` at `delegation.sh:7`, no `set +f` anywhere.

### Risks

1. A cached binary is reused with no checksum. Once `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` exists, `[ ! -x "$bin" ]` at `template/.github/shellcheck.sh:26` skips the download and the sha; on a shared Linux box `/tmp` is world-writable. I replaced the cached file with a two-line script; the gate ran it (`FAKE BINARY RAN --external-sources ...`, exit 0). Unlikely on a fresh runner; bad when it happens, the gate passes silently. Check: `ls -la ${TMPDIR:-/tmp}/shellcheck-0.11.0`.
2. `tests/shellcheck/gate.sh:75` assumes no 0.11.0 lives in `/usr/bin` or `/bin`. When `ubuntu-latest` ships 0.11.0 there, test 6 takes the on-pin branch and fails: with `/opt/homebrew/bin` on that PATH I got `FAIL 6 ... got: 0 wanted: 1`. Likely within a year; a red factory CI with no code fault. Check: `shellcheck --version` on the runner.
3. An unmatched glob among matched ones is dropped without a word (`template/.github/shellcheck.sh:38`): `'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5`, exit 0. A rename of `tests/` shrinks the set silently; the count is the only tell. Low likelihood, moderate cost.
4. A lane with no network and no ShellCheck at the pin cannot run the playbook step (`opening-a-pr.md:9`). Offline the gate exits 7 with curl's message (`shellcheck.sh:28`); an Intel Mac or ARM Linux is refused at `:20-22`. Loud, not silent; the finding moves back to CI, which the ticket wanted gone. Check: `bash .github/shellcheck.sh .github/shellcheck.sh` in the lane.
5. A project that edited its `ci.yml` near the top gets no gate. `cmd_update` runs `git merge-file` (`factory918.sh:357`); a project step right after `actions/checkout` conflicts (exit 1 in my probe) and lands in `ci.yml.factory-merge` (`:362`), so `ci.yml` has no step. An edit elsewhere merges clean. The doctor does not notice. Medium likelihood, low cost.

### Cleared

- Hook's own invocation: comment lines only, proof above; a `Bash` call of the gate passes (exit 0), since `scan_segment` inspects only tee, cat, head, sed and git (`delegation.sh:191-197`).
- Interactive session: the `AGENTS.md:38` command is the CI step verbatim, 20 files.
- Subagent: `source-path=SCRIPTDIR` (`tests/spec-review/review-brief.sh:21`, `review-comment.sh:11`) makes a per-file run from `/` clean; without it, SC1091 and SC2154.
- `factory-start` day zero: the doctor line (`factory918.sh:274-276`) sits above `slots filled` (`:278`) and prints PASS or NOTE, which `factory-start/SKILL.md:14` accepts; `apply` and `update` end in `cmd_doctor ... || true` (`:168`, `:373`), `tail -30` parses nothing, `factory-doctor/SKILL.md:6` prints the table as is.
- Review in progress: `review-brief.sh:189` marks `template/.claude/hooks/delegation.sh` cross-cutting, so this grounding is required; the awk at `:199` ends the section at the next `## `, hence none here. The hook's review read (`delegation.sh:27`, `:76`) is untouched.
- poteto-mode: the playbook sentence lives in the patch (`opening-a-pr.md.patch:8`); `sync` leaves the tree clean.
- spec-review scripts: file-level SC2016 directives only (`review-brief.sh:17`, `review-comment.sh:40`); both tests pass.
- show-me-your-work `log.sh` and `worktree-audit.sh`: linted now, clean, but outside `keep_files` (`factory918.sh:385`), so a future finding needs a patch or `sync` reverts the fix.
- Fixture step: the zero-argument form over the template's files, `files checked: 11`; hooks deleted, 6 (the gate matches itself); from a subdirectory, refused.
- `cmd_apply` copies with `cp -p` (`factory918.sh:137`), so the copy is executable. The symlink is outside `template/`: `apply` never copies it, `git status --porcelain template` ignores it, `actions/checkout` keeps it.
- Removed `bash -n`: six unparseable probes (unterminated `if`, string, `for`, `)`, `$(( ))`, `${x`) all exit 1 under ShellCheck.
- `sha256sum -c -` and `shasum -a 256 -c -` both refuse a wrong sha; macOS `tar -xJf` needs no `xz`; a half download leaves no binary.
- Knowledge: `build_knowledge.py` regenerates `template/docs/factory918/DECISIONS.md` with P25, tree clean.
- wizard: `template.sh` is not `scripts/*.sh`, outside the set; `wizard/SKILL.md:41` is vendored, unchanged.

### Before you merge

```
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'   # files checked: 20
bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh
diff <(git show main:template/.claude/hooks/delegation.sh | grep -v '^\s*#') <(grep -v '^\s*#' template/.claude/hooks/delegation.sh)
TMPDIR=$(mktemp -d) PATH=/usr/bin:/bin bash template/.github/shellcheck.sh tests/shellcheck/gate.sh   # download path
```
```

## Written by shell commands (content not recoverable from the transcript)

$TMPDIR
$t/proj/.claude
$t/proj/.github
$t/with/.claude
/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/gate-with-pin-on-path.sh
/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/probe1.sh
/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/probe2.sh
/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/probe3.sh
/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/wt88
