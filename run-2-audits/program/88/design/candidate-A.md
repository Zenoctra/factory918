# Candidate A: one pin in a script the template carries, default severity, reasons on the directive line

Runner: claude:fable@high. Checkout read: `feat/shellcheck` at `ab47eb9`. Every claim about a flag or a directive below was run with `/opt/homebrew/bin/shellcheck` 0.11.0 on scratch copies of the files; the command and its outcome are pasted where the claim is made.

## Problem

Ticket #88 puts ShellCheck in five places that each have a different delivery path: the factory's CI (edited directly), the template's CI (copied into projects by `apply`, merged by `update`, and run alone in the project's repository where nothing of the factory is reachable), the fixture job (which never runs the template's `ci.yml` and re-types its commands), the doctor (a `chk` cannot print NOTE, so the line is written inline like the models-sheet line at `factory918.sh:272`), and the Opening a PR playbook (vendored; changed only through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`, or `sync` reverts it). The gate has to pass at the merge commit, and at HEAD the 18 files it names carry 57 findings, 45 of them SC2016 on backticks and `$` that are meant literally. Three constraints shape the answer: the pin must be exact and must not depend on the runner image; a project's CI cannot reach the factory's files; and the standards axis, not CI, is what judges a suppression's reason, so the reason has to be where a reviewer reading the diff sees it. One more fact surfaced while testing and is not in the frame: `tests/spec-review/layout.sh` is sourced through `$here`, which ShellCheck resolves relative to the *current directory*, so a lane checking one changed test file alone gets SC1091 plus three SC2154 warnings unless `-x` is passed and the source is named by a directive.

## Usage (caller's view)

**A lane, before the PR opens** (root `AGENTS.md`, Verifying; the same line the playbook names):

```
shellcheck -x <every changed .sh file>
```

From the factory root the full set is one line, and it is what CI runs:

```
shellcheck -x factory918.sh template/.github/shellcheck.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh
```

No output and exit 0 is the pass. A finding prints `file:line:col: level: message [SCnnnn]` (with `-f gcc`) and exits 1.

**The factory's CI** (`.github/workflows/factory-ci.yml`, `factory` job, right after "Shell syntax"):

```yaml
      - name: ShellCheck, pinned by template/.github/shellcheck.sh
        run: bash template/.github/shellcheck.sh factory918.sh template/.github/shellcheck.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh
```

**A project's CI** (`template/.github/workflows/ci.yml`, `check` job, after "Reject committed PR evidence", before `setup-vp`; no toolchain is needed):

```yaml
      - name: ShellCheck the hooks and skill scripts
        run: bash .github/shellcheck.sh .github/shellcheck.sh .claude/hooks/*.sh .agents/skills/*/scripts/*.sh
```

**The fixture job**, proving the project's globs on the real copy `apply` made (`factory-ci.yml`, after "The gates a project runs"):

```yaml
      - name: The shell gate a project runs
        working-directory: /tmp/fx
        run: bash .github/shellcheck.sh .github/shellcheck.sh .claude/hooks/*.sh .agents/skills/*/scripts/*.sh
```

**The doctor**, on a machine with the tool and on one without:

```
PASS  shellcheck 0.11.0
```

```
NOTE  shellcheck
      fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); CI pins 0.11.0 in .github/shellcheck.sh
```

Both outputs were produced by running the exact line in a shell, the second with `PATH=/usr/bin:/bin`.

**A suppression**, the form every directive in the repository takes after this ticket (`template/.agents/skills/poteto-mode/scripts/overlap.sh:49`, the model):

```
  # shellcheck disable=SC2016 # the backticks are the ticket's token delimiters, matched literally
```

## Shape

### 1. Pinning: a release download in one script the template carries

`template/.github/shellcheck.sh`, new, mode 755, the whole file:

```bash
#!/usr/bin/env bash
# The shell gate CI runs, over the files it is given. ShellCheck is pinned here and nowhere else:
# a runner image carries whatever version it carries, so the release is downloaded once per job
# and its sha256 checked before it runs. A lane runs its own shellcheck (factory918 doctor says
# how to install it); this script is the gate's one pin, and the M0 findings record it.
set -euo pipefail
pin=0.11.0
dir="${RUNNER_TEMP:-/tmp}/shellcheck-v$pin"
if [ ! -x "$dir/shellcheck" ]; then
  curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v$pin/shellcheck-v$pin.linux.x86_64.tar.xz" -o "$dir.tar.xz"
  echo "8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198  $dir.tar.xz" | sha256sum -c - >/dev/null
  tar -xJf "$dir.tar.xz" -C "$(dirname "$dir")"
fi
"$dir/shellcheck" --version | sed -n 's/^version: /shellcheck /p'
exec "$dir/shellcheck" -x "$@"
```

Why a script and not step text: the pin and the checksum then exist once, in a file `apply` copies and `update` merges, instead of three times (factory job, fixture job, template CI) in YAML that a project may have edited. A project's CI reaches it at `.github/shellcheck.sh`, its own copy; the factory's CI reaches the same file at `template/.github/shellcheck.sh` (the nesting rule, P7). The tarball name and sha256 are the frame's measured values; the tarball extracts to `shellcheck-v0.11.0/shellcheck`, which is why `-C "$(dirname "$dir")"` lands the binary at `$dir/shellcheck`. Why a download and not `ludeeus/action-shellcheck`: the action's SHA cannot be verified from here, it adds a stranger's code to every project, and it would appear in three workflows with its own version to bump. Interface depth: three one-line callers; the script hides the version, the URL, the checksum, the extraction path and the `-x` flag. The script is itself in every glob it serves (`.github/shellcheck.sh` in the project step, `template/.github/shellcheck.sh` in the factory step), so it is linted by what it runs.

Verified: `bash -n template/.github/shellcheck.sh && shellcheck -f gcc template/.github/shellcheck.sh` → no output, `exit=0`. The download itself was not run from this session (a binary from the network; the runner does it, `sha256sum -c` gates it).

### 2. The invocation: `-x`, default severity, no `-s`, the globs as the ticket names them

`shellcheck -x FILES`. Nothing else.

- **`-x`** is required. Without it, a sourcing test checked on its own reports the sourced file as not followed and every variable it sets as unassigned:

  ```
  $ shellcheck -f gcc tests/spec-review/review-brief.sh          (alone, no -x, edited copy)
  tests/spec-review/review-brief.sh:21:3: note: Not following: ./tests/spec-review/layout.sh was not specified as input (see shellcheck -x). [SC1091]
  tests/spec-review/review-brief.sh:73:7: warning: skill is referenced but not assigned. [SC2154]
  tests/spec-review/review-brief.sh:111:6: warning: source_skill is referenced but not assigned. [SC2154]
  tests/spec-review/review-brief.sh:363:18: warning: hooks is referenced but not assigned. [SC2154]
  exit=1
  $ shellcheck -x tests/spec-review/review-brief.sh              (alone, -x, from the repo root)
  exit=0
  ```

  The whole-set run is clean either way because `layout.sh` is in the input list, so CI would pass without `-x`; the flag is for the lane checking one file, which is the ticket's point. `-x` costs nothing on a hook with no `source`.
- **Default severity** (style and up), not `-S warning`. The three findings on PR #87 that motivated the ticket are an unquoted expansion (SC2086, level *info*), a failing command in a process substitution and a discarded stderr; `-S warning` hides the first class entirely. What `-S warning` leaves at HEAD, measured:

  ```
  $ shellcheck -f gcc -S warning factory918.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh
  factory918.sh:249:211: warning: Tilde does not expand in quotes. Use $HOME. [SC2088]
  factory918.sh:384:101: warning: Use "${var:?}" to ensure this never expands to / . [SC2115]
  factory918.sh:386:76: warning: Use "${var:?}" to ensure this never expands to / . [SC2115]
  tests/spec-review/layout.sh:1:1: error: Tips depend on target shell and yours is unknown. Add a shebang or a 'shell' directive. [SC2148]
  tests/spec-review/layout.sh:12:34: warning: hooks appears unused. Verify use (or export if used externally). [SC2034]
  tests/spec-review/layout.sh:20:3: warning: skill appears unused. Verify use (or export if used externally). [SC2034]
  exit=1
  ```

  Six lines, all of which this design fixes anyway; the floor would buy nothing at HEAD and would silence the class the ticket exists for.
- **No `-s`**. Each file's shebang picks its dialect: `fake-gh.sh` is `#!/bin/sh` and is checked as sh (forcing `-s bash` on it adds a spurious SC2015 at 15:54, measured: `shellcheck -s bash tests/spec-review/fake-gh.sh` → 1 finding, `exit=1`; the same file at HEAD without `-s` reports the same SC2015 in its own dialect, and the fix in §3 removes it in both). `layout.sh` has no shebang and gets a `shell=bash` directive (§3), which is not a `disable=`.
- **No `.shellcheckrc`**, no `--norc`. The gate reads none of ours; a project that adds its own is honoured (verified that ShellCheck finds an rc in a parent directory of the script: `rc/.shellcheckrc` with `disable=SC2016`, `shellcheck rc/sub/a.sh` from `/` → `exit=0`). That is the project's knob, not the factory's.
- **Globs**: factory, `factory918.sh template/.github/shellcheck.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh` (19 files: the ticket's 18 plus the script). Project, `.github/shellcheck.sh .claude/hooks/*.sh .agents/skills/*/scripts/*.sh`. Written against `template/` in the factory, never `.claude/` (a symlink there; gotcha 2 in the grounding). The `bash -n` step at `factory-ci.yml:19` widens to the same skill glob so the two shell steps cover one set; today it misses `show-me-your-work/scripts/log.sh`. A glob with no match is passed literally and fails loud (`shellcheck 'nothing/*.sh'` → `openBinaryFile: does not exist`, `exit=2`); `shellcheck` with no files exits 3. Both are the right behaviour for a gate whose file set the factory owns.

### 3. Every finding at HEAD, resolved

Measured at HEAD, one call over the 18 files, default severity: 57 findings, `exit=1` (`shellcheck -x ... | wc -l` → `57`). After the edits below, on a scratch copy of the whole tree:

```
$ shellcheck -x factory918.sh template/.github/shellcheck.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh
exit=0
$ (cd / && shellcheck -x <the same 19 files by absolute path>)
exit=0
$ bash -n on all 19                                                        ok
$ bash tests/hooks/delegation.sh; tests/spec-review/review-comment.sh; tests/spec-review/review-brief.sh; tests/poteto-mode/overlap.sh
PASS PASS PASS PASS      (run in a scratch checkout of HEAD with the edited files dropped in)
```

The directive form, verified: `# shellcheck disable=SC2016 # reason` parses and suppresses (`ok.sh exit=0`); the same line without the second `#` is a parse error, `SC1073 Couldn't parse this shellcheck directive` and `SC1072 Expected '=' after directive key` (`bad.sh exit=1`). So "reason on the same line" means: after a second `#`. A directive on the line above a command covers that command, including a compound one (the `while` at `delegation.sh:206` inside a `case` arm, verified in the delegation.sh run below). Directives before the first command of a file are file-level, and several keys share one line (`shell=bash disable=SC2034`, verified on `layout.sh`).

Judgements, one per class:

- **SC2016 ×45** (literal backticks and `$` in single quotes). False positives everywhere they occur, and everywhere in the same shape: the report grammar and the token delimiters that `review-brief.sh`, `review-comment.sh`, `overlap.sh` and their tests match literally, plus one sed address. Not 45 directives, and not an rc: the rc would blind every project's future hooks to a real `'$var'` mistake, and 45 lines bury the two real fixes. One file-level directive per file whose whole job is literal `$` and backticks (four files), one line directive where a single occurrence is an accident of a sed address (`delegation.sh:21`), and a reason on the two existing directives. The four file-level lines go on the line before `set -euo pipefail`, the way `tests/poteto-mode/overlap.sh:17` already does:
  - `template/.agents/skills/spec-review/scripts/review-brief.sh`, before line 17: `# shellcheck disable=SC2016 # the backticks and $ inside single quotes are the report shape, matched literally` (clears 16).
  - `template/.agents/skills/spec-review/scripts/review-comment.sh`, before line 16: the same line (clears 1).
  - `tests/spec-review/review-brief.sh`, before line 18: the same line (clears 25).
  - `tests/spec-review/review-comment.sh`, before line 9: the same line (clears 2).
  - `template/.claude/hooks/delegation.sh`, before line 21 (`command="$(field '7,$p')"`): `# shellcheck disable=SC2016 # 7,$p is a sed address: $ is the last line, not a variable`.
  - `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` becomes `  # shellcheck disable=SC2016 # the backticks are the ticket's token delimiters, matched literally`.
  - `tests/poteto-mode/overlap.sh:17` becomes `# shellcheck disable=SC2016 # the backticks in the bodies below are the ticket's token delimiters, not command substitutions`.

  Verified per file: each of the four with its file-level line → `exit=0` when run in the whole set; `overlap.sh` and its test with the reasons → `exit=0`.
- **SC2086 ×3** (`delegation.sh:164` `set -- $args`, `:184` `set -- $words`, `:206` `scan_segment $seg`). Intentional word splitting: each rebuilds a space-joined list as positional parameters, and the test pins the behaviour. A directive with its reason on the line above each; not a rewrite to arrays inside a hook that runs without `-e` by design.
  - before 164: `  # shellcheck disable=SC2086 # the split is the point: args is a space-joined list rebuilt as positional parameters`
  - before 184: `  # shellcheck disable=SC2086 # the split is the point: words is a space-joined list rebuilt as positional parameters`
  - before 206: `    # shellcheck disable=SC2086 # the split is the point: each segment is a space-joined token list`

  Verified: `shellcheck -f gcc d.sh` (delegation.sh with the four lines) → `exit=0`; `bash -n` ok; `tests/hooks/delegation.sh` PASS.
- **SC2115 ×2** (`factory918.sh:384,386` `rm -rf "$skills/$n"`). Not real. `skills` is `"$TEMPLATE/.agents/skills"`, a literal suffix on a value that `set -e` would have aborted on at line 8 if `cd` failed, so it is never empty and never `/`; `n` is a `basename` at 384 and a literal from a fixed list at 386, so the worst case with an unmatched glob is `rm -rf "<skills>/*"`, quoted, a no-op. Resolution: `"${skills:?}/$n"` at both, because it is three characters, is what the linter names as the fix, and states the invariant in the code instead of in a comment (a runtime check over a prose reason, per encode-lessons-in-structure). Verified: the edited `factory918.sh` → `exit=0`, and `sync`'s count line still prints 72 both ways.
- **SC2034 ×2** (`layout.sh:12,20`, `hooks` and `skill`). Real to the linter, false in fact: the file is sourced and the two variables are what the sourcing test reads. A same-line reason on the file's one directive line (next bullet).
- **SC2148 ×1** (`layout.sh:1`, no shebang). The file is sourced and must not get a shebang that invites running it. One line inserted after the header comment, before the first command at line 7: `# shellcheck shell=bash disable=SC2034 # sourced by the tests, never run; hooks and skill are read by the sourcing test`. Verified: `shell=bash` alone leaves the two SC2034 (`layout2.sh` → 2 findings, `exit=1`); the combined line clears both, placed at line 1 or at line 7 (`layout.sh`, `layout1.sh` → `exit=0`).
- **SC1091/SC2154 on the sourcing tests when checked alone** (found while testing, not in the frame). One directive line above the dot line in each of the two tests: `# shellcheck source-path=SCRIPTDIR source=layout.sh`, above `tests/spec-review/review-brief.sh:20` and `tests/spec-review/review-comment.sh:11`. With `-x`, the lane's single-file check then passes from any directory. Verified: each test alone with `-x` from `/` by absolute path → `exit=0`; from the root → `exit=0`. Without the directive, `-x` from `/` fails (`Not following: ./tests/spec-review/layout.sh: openBinaryFile: does not exist`) because ShellCheck resolves `$(cd "$(dirname "$0")/../.." && pwd -P)` to `.`. Not a `disable=`, so no reason is required; the line explains itself.
- **SC2088 ×1** (`factory918.sh:249`). False positive: the tilde is in the fix string printed to a person, a `~/.factory918` they will read, not a path the script expands. Directive on the line above: `  # shellcheck disable=SC2088 # the tilde is in the fix string printed to a person, not a path`. Verified in the `factory918.sh` run.
- **SC2015 ×2**. `factory918.sh:272`: not real (`note` runs after `echo PASS` only if stdout is closed, in which case `note`'s echo fails the same way), but the line becomes an `if`/`else` anyway, because the new doctor line below is written as one and the two should read the same: `  if [ -f "$HOME/.claude/pstack-models.md" ]; then echo "PASS  models sheet"; else note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"; fi`. `tests/spec-review/fake-gh.sh:15`: real in shape (a failing `cat` would print "no pull requests found" over a real error), fixed the same way: `  "pr view --json body"*) if [ -f "${FAKE_PR_BODY:-}" ]; then cat "$FAKE_PR_BODY"; else echo 'no pull requests found for branch "x"' >&2; exit 1; fi ;;`. Verified: `sh -n` ok, `shellcheck` → `exit=0`, `review-brief.sh` test PASS.
- **SC2012 ×1** (`factory918.sh:398`, `ls -d | wc -l`). Not real for our directory names, but the portable form is the same length and needs no directive: `$(find "$skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')`. Verified: prints 72, same as `ls`.

Scorecard: 2 real fixes (`fake-gh.sh:15`, and `:?` as a stated invariant), 3 tidy-ups that remove a finding without a directive (`:272`, `:398`, `layout.sh`'s `shell=`), 11 directive lines with a reason (4 file-level SC2016, 1 SC2016, 3 SC2086, 1 SC2034 on the `shell=` line, 1 SC2088, and 2 reasons added to the existing directives). Nothing is silenced by an rc or a severity floor.

### 4. The fixture runs the project's step inside `/tmp/fx`

Yes: the step quoted in Usage, `working-directory: /tmp/fx`, `bash .github/shellcheck.sh .github/shellcheck.sh .claude/hooks/*.sh .agents/skills/*/scripts/*.sh`. It runs the copy of the script `apply` placed in the project, over real files, not symlinks, and the same globs a project's `ci.yml` names. The text is re-typed, as "The gates a project runs" at `factory-ci.yml:71` already re-types `vp check && ...`; the pin is not re-typed because it lives in the script. Verified the project-shaped run on a scratch copy: `cd proj && shellcheck -x .github/shellcheck.sh .claude/hooks/*.sh .agents/skills/*/scripts/*.sh` → `exit=0`. The vendored `worktree-audit.sh` and `show-me-your-work/scripts/log.sh` are clean at HEAD (`shellcheck` over the two → `exit=0`), so no patch to a vendored script is needed.

### 5. The doctor line

Inserted after `chk "hooks executable"` at `factory918.sh:265`, in the `if`/`else` shape of the delete-branch-on-merge line:

```bash
  # A machine without shellcheck still applies and updates; CI runs the pinned one either way.
  if command -v shellcheck >/dev/null 2>&1; then echo "PASS  shellcheck $(shellcheck --version | sed -n 's/^version: //p')"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); CI pins 0.11.0 in .github/shellcheck.sh"; fi
```

Label `shellcheck`; PASS text carries the version, so a person can compare it with the pin by eye; NOTE, never FAIL, because a project machine lacks it and `apply` and `update` both end in `cmd_doctor`. The version is not compared to the pin: CI is the gate and holds the pin; a newer local ShellCheck reports a superset (fine), an older one a subset (CI catches it). A comparison would need the doctor to parse the project's `.github/shellcheck.sh` for a NOTE nobody acts on. Verified: `bash -n` and `shellcheck -x` on the edited `factory918.sh` → `exit=0`; the line printed `PASS  shellcheck 0.11.0` on this machine and the NOTE with the fix under `PATH=/usr/bin:/bin`.

### 6. The prose, exact text

- `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, the `**PRs.**` paragraph, one sentence inserted after "Run `/deslop` over the diff before commit.": **Run `shellcheck -x` over every changed shell file before the PR opens; CI runs the same check at a pinned version, and a finding caught here costs no review round.** Then regenerate the patch with the command at `patches/README.md:9` (`diff -u --label a/poteto-mode/playbooks/opening-a-pr.md --label b/poteto-mode/playbooks/opening-a-pr.md research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/playbooks/opening-a-pr.md template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md > patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`) and confirm `./factory918.sh sync` leaves `git status` clean.
- `SOURCES.md:15`, item 3, appended: **The `**PRs.**` paragraph also tells the lane to run `shellcheck -x` over every changed shell file before the PR opens.**
- `CODING_STANDARDS.md`, Bash section, a bullet after line 14: **- A `# shellcheck disable=` directive carries its reason on the same line, after a second `#`: `# shellcheck disable=SC2016 # the backticks are the ticket's token delimiters, matched literally` (`template/.agents/skills/poteto-mode/scripts/overlap.sh`). CI runs `shellcheck` and honours any directive; whether the reason holds is judged here.**
- `template/CODING_STANDARDS.md:37`, Suppressions, becomes: **Every new or broadened `oxlint-disable`, `@ts-ignore`, `@ts-expect-error` needs an adjacent comment explaining why, and a `# shellcheck disable=` carries its reason on the same line, after a second `#` (`# shellcheck disable=SC2086 # the split is the point`). The directive itself is not an explanation. A stale `oxlint-disable` fails lint; a stale `shellcheck` directive is a review finding.** Yes to the template: projects have hooks, the hooks carry directives from day 0, and "universally designed" means a project agent reads the same rule.
- `AGENTS.md`, Verifying, a bullet after line 38 (`bash -n factory918.sh`): **- `shellcheck -x factory918.sh template/.github/shellcheck.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh`; CI runs it through `template/.github/shellcheck.sh`, which holds the pin.**
- `template/AGENTS.md`, Verifying, a bullet after line 62: **- Shell (`.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`): `shellcheck -x <file>` on every changed shell file before the PR opens. CI runs `.github/shellcheck.sh` over both globs at the version it pins; `factory918 doctor` says how to install it.**

### 7. Test first, and the commit order that shows it

The test is the gate itself: the CI step, which fails at HEAD with 57 findings. There is no scenario table and no script with state; the script's behaviour is "download, check, run", and the step is what exercises it. Four commits on `feat/shellcheck`:

1. **The gate** — `template/.github/shellcheck.sh`; the three CI steps; the `bash -n` glob at `factory-ci.yml:19` widened to `template/.agents/skills/*/scripts/*.sh` and `template/.github/shellcheck.sh`. CI is red at this commit by design: 57 findings, the failing test.
2. **Every finding at HEAD resolved** — the §3 edits, including the reasons on the two existing directives and the two `source-path` lines. CI green from here.
3. **The doctor line** — `factory918.sh`, §5.
4. **The prose and the records** — the playbook sentence and its regenerated patch, `SOURCES.md` 3, both standards, both `AGENTS.md`, `docs/M0-findings.md`, the P25 row in `docs/knowledge/core/DECISIONS.md` followed by `python3 tools/build_knowledge.py` (it rewrites the file's header, `template/docs/factory918/DECISIONS.md` and `docs/knowledge/INDEX.md`; the file is at 92 lines against the 240 cap).

Commit 1 is not landable alone; the ticket's run-under rule (test before implementation, order visible) outranks "each commit is a future PR" here, and the PR body says so.

### 8. The `## Design` artifact and the M0 line

On the ticket, under `## Design`, since there is a script with a signature:

```
.github/shellcheck.sh FILE...
  Runs ShellCheck 0.11.0 with -x over FILE... and exits with its status. Downloads the pinned
  Linux x86_64 release into $RUNNER_TEMP (or /tmp) once per job and checks its sha256 first.
  Callers: template ci.yml (check job), factory-ci.yml (factory job, as template/.github/shellcheck.sh;
  fixture job inside /tmp/fx). A lane does not call it; it runs its own shellcheck -x.
```

`docs/M0-findings.md`: a row in the Tool versions table after line 24, `| shellcheck | 0.11.0 | brew install shellcheck (2026-09-21) | not in the spec; #88 |`, and a section before `## Still open` (line 170):

> ## ShellCheck (2026-09-22)
>
> Verified with shellcheck 0.11.0 (Homebrew, `/opt/homebrew/bin/shellcheck`). Over the 19 files the factory CI names it reported 57 findings at `ab47eb9`, 45 of them SC2016 on literal backticks and `$` in single quotes; `--severity=warning` leaves 6, which hides SC2086, the unquoted-expansion class PR #87 paid three review rounds for, so the gate runs at the default severity. A directive with its reason on the same line, `# shellcheck disable=SC2016 # reason`, parses; the reason without a second `#` is SC1072. `# shellcheck shell=bash disable=SC2034 # reason` on one line before a sourced file's first command clears SC2148 and SC2034. A sourcing test checked alone needs `-x` and `# shellcheck source-path=SCRIPTDIR source=layout.sh`, because ShellCheck resolves `$(cd "$(dirname "$0")/../.." && pwd -P)` to the current directory. CI pins the v0.11.0 Linux x86_64 release, sha256 `8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198`, through `template/.github/shellcheck.sh`. `shellcheck` with no files exits 3; a glob passed literally exits 2.

`docs/knowledge/core/DECISIONS.md`, Provisional, one row: `| P25 | The shell gate | ShellCheck at its default severity with -x, pinned in template/.github/shellcheck.sh, over the hooks and skill scripts in every project and the factory's own set; a disable= directive carries its reason after a second # on the same line, and the Standards axis, not CI, judges it | -S warning hides SC2086, the class #87 paid for; one pin in a copied file beats three in YAML; a reason where the reviewer reads the diff is the only place CI cannot check. Claude Fable 5.1, 2026-09-22 |`.

### Every file the writer touches

- `template/.github/shellcheck.sh` — new, the 15-line script quoted in §1, mode 755.
- `.github/workflows/factory-ci.yml` — line 19: add `template/.github/shellcheck.sh` and replace the two named skill globs with `template/.agents/skills/*/scripts/*.sh`; after line 19: the ShellCheck step; after line 71: the fixture step.
- `template/.github/workflows/ci.yml` — after line 23: the project step.
- `factory918.sh` — directive line above 249; 265+: the doctor line; 272: `if`/`else`; 384 and 386: `${skills:?}`; 398: `find`.
- `template/.claude/hooks/delegation.sh` — directive lines above 21, 164, 184, 206.
- `template/.agents/skills/spec-review/scripts/review-brief.sh` — file-level SC2016 line before 17.
- `template/.agents/skills/spec-review/scripts/review-comment.sh` — file-level SC2016 line before 16.
- `template/.agents/skills/poteto-mode/scripts/overlap.sh` — 49: reason appended.
- `tests/spec-review/review-brief.sh` — file-level SC2016 line before 18; `source-path` line above 20.
- `tests/spec-review/review-comment.sh` — file-level SC2016 line before 9; `source-path` line above 11.
- `tests/spec-review/layout.sh` — the `shell=bash disable=SC2034` line inserted before 7.
- `tests/spec-review/fake-gh.sh` — 15: `if`/`else`.
- `tests/poteto-mode/overlap.sh` — 17: reason appended.
- `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` — 9: the sentence; then `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` regenerated.
- `SOURCES.md` — 15: the sentence appended to item 3.
- `CODING_STANDARDS.md` — the Bash bullet after 14.
- `template/CODING_STANDARDS.md` — 37: the Suppressions paragraph.
- `AGENTS.md` — the Verifying bullet after 38.
- `template/AGENTS.md` — the Verifying bullet after 62.
- `docs/M0-findings.md` — the table row after 24; the section before 170.
- `docs/knowledge/core/DECISIONS.md` — the P25 row, then `python3 tools/build_knowledge.py` (which also rewrites `template/docs/factory918/DECISIONS.md` and `docs/knowledge/INDEX.md`).

## Synthesis decision

(left for the arena)

## Tradeoffs accepted

- We accept that a project's CI downloads a 5 MB tarball from GitHub on every job, in exchange for a pin that does not depend on the runner image and a checksum that fails the job if the download is not the release. No cache step; the pin makes it cheap to add one later.
- We accept 11 directive lines, in exchange for keeping SC2016 live for every future hook and script and keeping each reason next to the code it excuses.
- We accept default severity, so a future style-level finding (SC2012-class) fails CI, in exchange for SC2086 staying reported. The escape is a same-line reason, which the standards say is a review question, not a rc edit.
- We accept `${skills:?}` at two lines whose emptiness is impossible, in exchange for two fewer directives and an invariant stated in the code.
- We accept the script being Linux x86_64 only, in exchange for eight fewer lines; a lane on macOS runs its own ShellCheck and the doctor tells it how, which is the ticket's design.
- We accept commit 1 being red, in exchange for the order the ticket's run-under rule asks for.
- We accept that `update` brings the new CI step to an existing project only through a three-way merge of `ci.yml` (or a `.factory-merge` file if the project edited it), which is how every template CI change already arrives.

## Alternatives considered

- **Inline step text in all three places, no script.** Exposes the version, URL and checksum in three YAML files, two of them the same text in different repositories, and a bump is a three-file edit that `update` may drop into a `.factory-merge`. Hides nothing. Lost on single source of truth.
- **`ludeeus/action-shellcheck` pinned by SHA.** Hides the download behind `uses:`, but its SHA cannot be verified from here, it puts a stranger's code in every project's CI, and it would still be three copies of the pin. Lost on trust and on the same duplication.
- **A `.shellcheckrc` with `disable=SC2016` at the factory root and in the template.** Two files (or a root symlink), zero directives, and every project's new hook loses the check that catches `'$var'` written by mistake; a reason in an rc is far from the code it excuses. Lost on the rule the standards state.
- **`-S warning`.** Six findings to fix instead of 57, but the SC2086 class that cost PR #87 its rounds is info-level and would never be reported. Lost on the ticket's own motivation.
- **A `for` loop per file in the CI step.** Under the runner's `bash -e`, stops at the first failing file and reports one file's findings. One call over the list reports all of them. Lost on reader load.
- **Comparing the doctor's version to the pin.** Would make the doctor parse `.github/shellcheck.sh` to print a NOTE that changes nobody's action; CI is where the pin binds. Lost on the smallest change.

## Open questions and risks

- Is `winget install koalaman.shellcheck` the id Manuel wants in the fix string? It is what the winget catalogue is believed to use; it was not checked from this session, and the doctor's other lines name the tool by package manager only ("brew, apt, dnf or winget"). Should the fix string follow that shorter form instead?
- Should the P25 row be filed, or is the ticket's Decision section record enough and the row noise? The `AGENTS.md` rule ("a decision you had to make goes under Provisional") says file it; the frame did not ask for one.
- The fixture job's doctor output will now print `PASS  shellcheck <runner version>` on `ubuntu-latest` (the image carries one) and the NOTE on an image without; neither fails the job. Is a `tail -30` at `factory-ci.yml:51` still enough to show the line, or should the writer widen it?
- The script is Linux x86_64 only. If a self-hosted ARM runner ever runs a project's CI, `sha256sum -c` fails loudly with the right message. Is that acceptable, or should the darwin.aarch64 checksum from the frame be carried too, at eight more lines?
- A glob that matches nothing fails the project's CI with `openBinaryFile: does not exist`. A project that deletes all its hooks edits its CI step; is that the wanted behaviour, or should the step tolerate an empty glob?

## Next implementation step

Write `template/.github/shellcheck.sh` and the three CI steps, push commit 1, and watch the factory job fail with the 57 findings before touching a single finding.
