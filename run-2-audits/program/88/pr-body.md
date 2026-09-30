## Why

Three of the ten hard findings across the three review rounds on PR #87 were shell mechanics a linter reports: a failing command inside a process substitution, an unquoted command substitution, stderr discarded. Nothing in the factory's checks or a project's CI ran `shellcheck`, so each one cost a review round and a fresh writer lane. On PR #92, where the writer ran `shellcheck` before every report, that class produced zero findings in three rounds. Manuel's decision on #88: one universally designed feature, in the factory and in every project the factory is applied to, caught before CI by the lane that wrote the code.

The fix is one gate script the template carries, `template/.github/shellcheck.sh`. It holds the ShellCheck version, both release checksums and the flags; a project gets it as `.github/shellcheck.sh`, the factory reaches the same file through a symlink of that name, and the factory CI, the template CI, the fixture job and the lane before a PR all run the same command. The design was chosen in an architect arena between two candidates and is posted on the ticket under `## Design`, with a case table that `tests/shellcheck/gate.sh` asserts row by row. Commit 1 adds the gate and is red by design (57 findings at `ab47eb9`); commit 2 resolves them.

## Scope

- `template/.github/shellcheck.sh`, new. Runs ShellCheck 0.11.0 with `--external-sources` at the default severity and no `--shell` over the files its globs match. Uses the `shellcheck` on PATH when its version is the pin; otherwise downloads the release tarball for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, and on every such run verifies its sha256 and runs the binary it extracts from it. With no arguments it checks a project's `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and itself. A glob that matches nothing is refused (exit 1, "the gate checked nothing"), even beside globs that match, and so is a platform the pin has no build for; an argument is one path or one glob and is never split on a space.
- `.github/shellcheck.sh`, a symlink to `../template/.github/shellcheck.sh`, the nesting rule `.claude/hooks` already follows, so `bash .github/shellcheck.sh` is one command in the factory and in a project.
- `.github/workflows/factory-ci.yml`: the `Shell syntax` step (`bash -n`) is replaced by the gate over `factory918.sh`, `template/.github/shellcheck.sh`, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh` (20 files, `show-me-your-work/scripts/log.sh` newly covered), plus `bash tests/shellcheck/gate.sh`; the fixture job runs the zero-argument form inside `/tmp/fx` right after `apply`. `template/.github/workflows/ci.yml`: `ShellCheck` is the first step of `check`.
- `tests/shellcheck/gate.sh`, new, 17 assertions at the head: a clean file passes and is counted, a planted SC2086 is reported, a glob that matches nothing is refused on stderr, also when it stands beside a glob that matches (case 3b), a `#!/bin/sh` file keeps its POSIX checks, the zero-argument form from a project root counts the right files, an unpinned platform without ShellCheck is refused, the mode bit, an absolute path with a space and a glob whose directory has a space are each one argument (cases 8 and 8b), and on the two pinned platforms a cached tarball that fails its checksum is refused and removed (case 9).
- Every finding at `ab47eb9` resolved. Five fixes: the models-sheet doctor line and the fake gh's `pr view --json body` branch become `if`/`else` (SC2015), `rm -rf "$skills/$n"` becomes `"${skills:?}/$n"` twice in `cmd_sync` (SC2115; `$skills` is a literal suffix on `$TEMPLATE` and never empty, so this states an invariant), the vendored-skill count reads an array instead of `ls | wc -l` (SC2012). The rest are intentional and carry `# shellcheck disable=` with the reason as a second comment on the same line, on the narrowest scope: file level in `review-brief.sh` and its test, whose single-quoted strings are jq programs and Markdown templates; inline in `delegation.sh` (a sed address, three `set -f` word splits), `review-comment.sh` and its test, `factory918.sh:249` (a tilde in text printed to a person). The two existing directives (`overlap.sh:49`, its test) gain their reasons the same way. `tests/spec-review/layout.sh` declares `shell=bash` since it is sourced and has no shebang, and the two tests that source it carry `source-path=SCRIPTDIR` so a per-file run from any directory resolves it.
- `factory918.sh`, `cmd_doctor`: a `shellcheck` line after the models sheet. `PASS  shellcheck 0.11.0` when the tool is on PATH; otherwise `NOTE  shellcheck` with the fix `brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck)`. A NOTE, not a FAIL, because the gate downloads the pinned build without it.
- `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`, through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` (regenerated) and `SOURCES.md` item 3: the `**PRs.**` paragraph tells the lane to run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens.
- `CODING_STANDARDS.md`, Bash: a `# shellcheck disable=` directive carries its reason as a second comment on the same line, on the narrowest scope that fits. `template/CODING_STANDARDS.md`, Suppressions: the same rule for a project's hooks and skill scripts. CI honours the directive; whether the reason exists and holds is the Standards axis's question.
- `AGENTS.md`, Verifying: the gate command replaces `bash -n factory918.sh`, and `bash tests/shellcheck/gate.sh` joins the list. `template/AGENTS.md`, Verifying: a Shell bullet.
- Records: `docs/M0-findings.md`, `## ShellCheck (2026-09-22)`, the pin, both checksums, the finding counts per severity and the three measured facts behind the flags; `docs/knowledge/core/DECISIONS.md` P26 (P25 until the chain rebase onto PR #94, whose own row is P25) (knowledge rebuilt); `docs/agents/ledger.md`, one line for a lane this run lost.

Out of scope: `template/.agents/skills/wizard/template.sh` (not under `scripts/`, a library the wizard copies; not in the ticket's set); a doctor line that checks a project's `ci.yml` still names the gate after a local edit.

## Tradeoffs

- One managed file in every project, in exchange for one copy of the pin, the flags and the project glob list. A `run:` block per workflow would put the pin in two files and the flags in three, and a project's CI cannot read the factory's files.
- The default severity, so every finding at `ab47eb9` had to be resolved, in exchange for SC2086 staying reported: it is info level, and a `--severity=warning` floor (6 findings instead of 57) would pass the class PR #87 paid three review rounds for.
- Two file-level SC2016 directives in `review-brief.sh` and its test, in exchange for not writing 41 inline ones. Both files exist to emit jq programs and Markdown; a `'$var'` typo there is a typo in a literal the 334-assertion test compares word for word.
- A tarball download on a machine whose ShellCheck is off-pin, in exchange for the lane's run and CI's run being one run. The download is proven by the fixture job on `ubuntu-latest`, whose image carries an off-pin ShellCheck; it was not run on this machine, which has the pin.
- `bash -n` removed rather than kept beside the gate. ShellCheck refuses an unparseable file at error level and its set is wider.
- Commit 1 is red by design, in exchange for the order the ticket's run-under rule asks for. The order that holds is the gate and its test before the findings are resolved; inside commit 1 the script was written before its test, which is why the gate flagged the test's first draft.

## Blast Radius

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
$ bash tests/shellcheck/gate.sh -> ok 17 assertions (ok 10 at 69bd412; cases 3b, 8, 8b and 9 came with the review rounds)
$ review-comment 82, review-brief 334, overlap 56 assertions; no-stale-wording ok; build_knowledge + check_knowledge -> clean, 118 files
```

`${skills:?}` cannot fire: `skills="$TEMPLATE/.agents/skills"` and `TEMPLATE="$F918_DIR/template"` (`factory918.sh:9`), so the string is never empty. The `set -f` the three directive reasons cite is real: `set -fuo pipefail` at `delegation.sh:7`, no `set +f` anywhere.

### Risks

1. The cached tarball is verified on every run and the binary re-extracted from it (`template/.github/shellcheck.sh`, the `verify` line and the `tar -xJf` after it; `a64c7e6`, `1362b48`), and a tarball that fails its checksum is removed so the next run downloads it again (`2360707`), so a foreign binary at the cache path never runs; the root's runtime verifier planted a real tarball holding a fake binary and it was refused unextracted. What remains is the re-extraction itself: two gate runs sharing one `TMPDIR` on an off-pin machine rewrite each other's binary (the verifier saw exit 137 on two of three cold runs and `File exists` on two of three warm ones). A lane and CI never share a `TMPDIR`; ticket #97. Check: two concurrent runs with one `TMPDIR` and ShellCheck hidden from PATH.
2. `tests/shellcheck/gate.sh:75` assumes no 0.11.0 lives in `/usr/bin` or `/bin`. Test 6 hides ShellCheck by narrowing PATH; the day the `ubuntu-latest` image ships 0.11.0 in `/usr/bin`, the on-pin branch runs and the test fails: I put `/opt/homebrew/bin` on that PATH and got `FAIL 6 ... got: 0 wanted: 1`. Likely within a year; cost is a red factory CI with no code fault. Check: `shellcheck --version` on the runner.
3. A glob that matches no file is refused even beside globs that match (`template/.github/shellcheck.sh`, the per-argument `matched` check; `01e5386`): `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `shellcheck.sh: no file matched nope/*.sh; the gate checked nothing` on stderr and exits 1, and `gate.sh` case 3b asserts it. What remains is the other refusal's wording: a checksum mismatch prints only the tool's `WARNING: 1 computed checksum did NOT match`, with no `shellcheck.sh:` prefix, no path and no word that the tarball was removed; ticket #98. Check: a bogus cached tarball with ShellCheck hidden from PATH.
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
- Fixture step: the zero-argument form over the template's files gives `files checked: 11`, exit 0; with the hooks deleted, refused with `no file matched .claude/hooks/*.sh`, exit 1 (`01e5386`); from a subdirectory, refused with the gate's own message.
- `cmd_apply` copies with `cp -p` (`factory918.sh:137`), so the copy is executable. The symlink is outside `template/`: `apply` never copies it, `git status --porcelain template` ignores it, `actions/checkout` keeps symlinks.
- Removed `bash -n`: six unparseable probes (unterminated `if`, string, `for`, `)`, `$(( ))`, `${x`) all exit 1 under ShellCheck.
- `sha256sum -c -` and `shasum -a 256 -c -` both refuse a wrong sha; macOS `tar -xJf` extracts without `xz` on PATH. A half download leaves no binary, so the next run retries.
- Knowledge: `build_knowledge.py` regenerates `template/docs/factory918/DECISIONS.md` with P26 (P25 before the chain rebase); the tree stays clean.
- wizard: `template.sh` is not `scripts/*.sh`, so it is outside the set (it has findings of its own); `wizard/SKILL.md:41` is vendored and unchanged.

Addendum, 2026-09-22, after the review and the root's verification: risks 1 and 3 above now describe what runs at this head (their first texts described `69bd412`); risk 1 was closed by `a64c7e6` with `1362b48` (the tarball's sha256 is verified and the binary re-extracted on every run; a bogus cached tarball is refused with the tool's own WARNING), and risk 3 by `01e5386` (a glob that matches nothing is refused even beside globs that match), so the Cleared line "with the hooks deleted, 6 and exit 0" no longer holds and that case exits 1. Risks 2, 4 and 5 stand as written. The trail review after round three found a fourth thing: a truncated or foreign cached tarball failed the checksum on every later run with no retry, so `2360707` removes it on a mismatch and the next run downloads it again, which also makes the Cleared line "a half download leaves no binary, so the next run retries" true again. Two gates sharing one TMPDIR at the same moment re-extract over each other's binary; a lane and CI never share one, so it is left as a known risk.

### Before you merge

```
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'   # expect files checked: 20
bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh
diff <(git show main:template/.claude/hooks/delegation.sh | grep -v '^\s*#') <(grep -v '^\s*#' template/.claude/hooks/delegation.sh)
TMPDIR=$(mktemp -d) PATH=/usr/bin:/bin bash template/.github/shellcheck.sh tests/shellcheck/gate.sh   # the download path, once, with the sha OK line
```

## Overlap

```
go: autopilot-stack
#94 feat/design-artifact-on-ticket: AGENTS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh
```

Recorded at the final head `2360707`; at `69bd412`, when this PR opened, the same run listed #94 without the two `overlap.sh` files. The go `autopilot-stack` covers #88 and #89, so the root resolves the shared files at chain time.

## Verification

Each criterion of #88 is quoted, then how it was proven. The design artifact on the ticket (`## Design`, posted 2026-09-22) is the spec for the script; `tests/shellcheck/gate.sh` was written in commit 1 from its case table, one assertion per row, and passes with `ok 17 assertions` at the head (`ok 10` at `69bd412`, before the review rounds added cases 3b, 8, 8b and 9).

- "`shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/` and `tests/*/*.sh`, pinned to an exact version (a release download or a pinned action, not whatever the runner image carries), and passes at the merge commit." `.github/workflows/factory-ci.yml`, step `ShellCheck`, runs `bash .github/shellcheck.sh` over those globs plus the gate itself; the script pins v0.11.0 by release download with sha256 `8c3be12b…7198` (Linux x86_64) and `56affdd8…0a79` (macOS arm64). At `1208407` (commit 1) the gate exits 1 with 57 findings; at `69bd412` it prints `ShellCheck 0.11.0, files checked: 20` and exits 0, from this checkout and with `--external-sources` dropped. CI: run 35747640954 on head `69bd412`, job Factory, success; its log shows `/tmp/shellcheck-0.11.0/sc.tar.xz: OK` (the download and checksum on a runner whose image carries an off-pin ShellCheck) then `ShellCheck 0.11.0, files checked: 20`.
- "The template's CI runs `shellcheck` over a project's `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh`, pinned the same way, and the fixture flow passes it." `template/.github/workflows/ci.yml`, step `ShellCheck`, `bash .github/shellcheck.sh`, whose zero-argument default is exactly those two globs plus itself. The fixture job's new step `The shell gate a project runs` runs the same three words inside `/tmp/fx`. `gate.sh` case 5 proves the zero-argument form from a project root (`files checked: 4` over two hooks, one skill script and the gate). CI: the same run, job Fixture, success; step `The shell gate a project runs` logged `/tmp/shellcheck-0.11.0/sc.tar.xz: OK` then `ShellCheck 0.11.0, files checked: 11` inside `/tmp/fx`.
- "The Opening a PR playbook (through its patch) names `shellcheck` on every changed shell file before the PR opens, so a lane runs it before CI does." `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, the `**PRs.**` paragraph; the patch regenerated with the command in `patches/README.md`; `SOURCES.md` item 3 says so; `./factory918.sh sync > /dev/null && git status --porcelain` prints nothing at `69bd412`.
- "`factory918 doctor` has a `shellcheck` line, its fix `brew install shellcheck` (or the platform's equivalent), and the check is `NOTE`, not `FAIL`, on a machine without it." `factory918.sh`, `cmd_doctor`, the two lines after the models sheet. Run as a scratch file with the tool on PATH: `PASS  shellcheck 0.11.0`, exit 0. With `PATH=<emptydir>:/usr/bin:/bin`: `NOTE  shellcheck` then `      fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE`, exit 0.
- "A `# shellcheck disable=` directive is allowed only with its reason on the same line; the existing one in `template/.agents/skills/poteto-mode/scripts/overlap.sh` is the model. CI does not enforce the reason; the Standards axis does, and `CODING_STANDARDS.md`'s Bash section says so." `overlap.sh:49` now reads `# shellcheck disable=SC2016 # the backticks are the ticket's token delimiters, not command substitution`; every directive in the diff has the same shape (a reason without the second `#` is SC1073 plus SC1072, measured); `CODING_STANDARDS.md`, Bash, the last bullet; `template/CODING_STANDARDS.md`, Suppressions.
- "`AGENTS.md` Verifying lists the command, and a dated line in `docs/M0-findings.md` records the version verified." `AGENTS.md`, Verifying, first two bullets; `docs/M0-findings.md`, `## ShellCheck (2026-09-22)`.

Also run from this checkout at `69bd412`, each exit 0, and again at the chained tip with `gate.sh` at 17 and `overlap.sh` at 57 assertions: `bash tests/shellcheck/gate.sh` (`ok 10 assertions`); `bash tests/hooks/delegation.sh` (`ok 55 assertions`); `bash tests/spec-review/review-comment.sh` (`ok 82 assertions`); `bash tests/spec-review/review-brief.sh` (`ok 334 assertions`); `bash tests/poteto-mode/overlap.sh` (`ok 56 assertions`); `bash tests/spec-review/no-stale-wording.sh`; `bash -n factory918.sh`; `python3 tools/check_knowledge.py` (`knowledge ok: 118 files`) then `python3 tools/build_knowledge.py` and `git status --porcelain` empty; `./factory918.sh sync` then `git status --porcelain` empty; `.claude/skills/poteto-mode/scripts/overlap.sh 88` printed `go: autopilot-stack` and `base: origin/main` at step 1, and `overlap.sh 88 --diff` at step 8 printed the `## Overlap` section above, exit 0.

Review: three rounds of `spec-review`, comments on the PR (round 1 https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779416046, round 2 https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779650623, round 3 https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779871731). Round one found one fails-open item on both axes (a glob among several that matched nothing was dropped silently), fixed by `01e5386`; round two found one would-break (an argument with a space was word-split before globbing) and one fails-open on both axes (the cached binary was never checked again), fixed by `72953c0` and `a64c7e6`, then `1362b48` after CI caught the checksum tool's `OK` line on the runner's download path; round three found no hard item and ended with `act-on items: 0`. No round changed a cell of the design on the ticket. `3f3814c` records the CI proof in `docs/M0-findings.md` and two ledger rows. CI: run 35752369368 on `3f3814c`, both jobs green; `2360707` (the tarball removal, from the trail review) is the final head and its run is named in the owner report.

Closes #88

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Claude Fable 5.1 on Claude Code
