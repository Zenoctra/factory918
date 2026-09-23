# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

01e5386 Refuse a glob that matches nothing even beside globs that match
69bd412 Record the ShellCheck pin, the gate decision and a lost lane
f156229 Name the shell gate in the playbook, the standards and both AGENTS.md
992ce94 Give the doctor a shellcheck line
741bc89 Resolve every ShellCheck finding on the factory's shell files
1208407 Add the shell gate, its test and the three CI steps that call it

## Changed files

 .github/shellcheck.sh                              |  1 +
 .github/workflows/factory-ci.yml                   |  9 ++-
 AGENTS.md                                          |  3 +-
 CODING_STANDARDS.md                                |  1 +
 SOURCES.md                                         |  2 +-
 docs/M0-findings.md                                |  4 ++
 docs/agents/ledger.md                              |  1 +
 docs/knowledge/INDEX.md                            |  2 +-
 docs/knowledge/core/DECISIONS.md                   |  3 +-
 factory918.sh                                      | 13 ++--
 .../poteto-mode/playbooks/opening-a-pr.md.patch    |  2 +-
 .../skills/poteto-mode/playbooks/opening-a-pr.md   |  2 +-
 .../.agents/skills/poteto-mode/scripts/overlap.sh  |  2 +-
 .../skills/spec-review/scripts/review-brief.sh     |  1 +
 .../skills/spec-review/scripts/review-comment.sh   |  1 +
 template/.claude/hooks/delegation.sh               |  4 ++
 template/.github/shellcheck.sh                     | 47 ++++++++++++
 template/.github/workflows/ci.yml                  |  2 +
 template/AGENTS.md                                 |  1 +
 template/CODING_STANDARDS.md                       |  2 +-
 template/docs/factory918/DECISIONS.md              |  1 +
 tests/poteto-mode/overlap.sh                       |  5 +-
 tests/shellcheck/gate.sh                           | 84 ++++++++++++++++++++++
 tests/spec-review/fake-gh.sh                       |  2 +-
 tests/spec-review/layout.sh                        |  1 +
 tests/spec-review/review-brief.sh                  |  2 +
 tests/spec-review/review-comment.sh                |  3 +
 27 files changed, 183 insertions(+), 18 deletions(-)

## Blast radius

The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence.

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

## Diff

The diff is 542 lines; read it from `.scratch/review/ab47eb9/diff`.

## The ticket (#88)

## Problem

Observed (agent): three of the ten hard findings across the three review rounds on PR #87 were shell mechanics a linter reports (a failing command inside a process substitution, an unquoted command substitution, stderr discarded). Nothing in the factory's checks or the template's CI runs `shellcheck`, so each one cost a review round and a fresh writer lane to fix. On PR #92, where the writer ran `shellcheck` before every report, that class produced zero findings in three rounds. The tool was not on Manuel's machine until it was installed by hand on 2026-09-21 (0.11.0, Homebrew), so a project machine will lack it too.

## Decision

> user: ShellCheck sounds like a good ticket for sure. It sounds like something that agents could pretty universally benefit from, so it should probably be in this factory project scope but also it should be present in pretty much every project that inits factory in it too. So it should be a universally designed feature

> user: itd be nice if something like that could get caught before CI checks that kick us back at a brand new writer and 200k tokens on context window to fix some random syntax error like that.

> agent: On catching it before CI without a new writer, the cheap place is the writer lane's verification list, run before it reports. That costs no tokens and keeps decision 5, the formatter-only commit hook, intact.

## Acceptance criteria

- [ ] `shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/` and `tests/*/*.sh`, pinned to an exact version (a release download or a pinned action, not whatever the runner image carries), and passes at the merge commit.
- [ ] The template's CI runs `shellcheck` over a project's `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh`, pinned the same way, and the fixture flow passes it.
- [ ] The Opening a PR playbook (through its patch) names `shellcheck` on every changed shell file before the PR opens, so a lane runs it before CI does.
- [ ] `factory918 doctor` has a `shellcheck` line, its fix `brew install shellcheck` (or the platform's equivalent), and the check is `NOTE`, not `FAIL`, on a machine without it.
- [ ] A `# shellcheck disable=` directive is allowed only with its reason on the same line; the existing one in `template/.agents/skills/poteto-mode/scripts/overlap.sh` is the model. CI does not enforce the reason; the Standards axis does, and `CODING_STANDARDS.md`'s Bash section says so.
- [ ] `AGENTS.md` Verifying lists the command, and a dated line in `docs/M0-findings.md` records the version verified.

## Run under

Until #89, #90, #91 and #93 merge, the lane that runs this ticket follows their rules by hand; following them is part of the ticket. The worked example of every artifact named here is ticket #42 (its `## Testing decisions` section) and PR #92 (its description and its three review comments); read both first. The rules: (1) `how` and `blast-radius` as the Ticket playbook says. (2) When the change has state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step writes a scenario table before any code: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does; a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen. When the change is code with no state that crosses a function boundary, the architect step posts the usage and signature sketch (the caller's usage first, then types and signatures) on the ticket under `## Design` instead; a prose change has no artifact beyond its acceptance criteria. The table is appended to this ticket's body under `## Testing decisions`, first line "Posted by the agent <date>"; the human edits it if it is wrong, and a stop before implementation is asked for only with the phrase "/architect with checkpoint". (3) The test is written from the table before the implementation, one assertion per cell, and the commit order shows it. (4) A writer that cannot implement a cell as written stops and reports the cell; it never fills it. (5) In review, a finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a table cell or a term its cells use, a signature or a usage in the sketch, or an acceptance criterion (the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change goes back to architect, which re-derives it from the intent and amends the ticket with a dated line); a design hole is not fixed on the PR but returns to architect, scoped to that cell, and the review count restarts (on this PR with a comment that says "restart" and why); a refusal added under an existing could-not-run clause is not a hole. (6) The Spec reviewer's walk has one line per risk in the blast-radius grounding. (7) A round that fixed a Would-break item is followed by another round even past three, reviewing only the fix (the previous reviewed commit as the fixed point), up to five; at five with Would-break items still found, stop, write a report for the human, mark the PR unfinished and wait. (8) `shellcheck` on every changed shell file before the PR opens. This ticket has no state of its own, so rule 2 yields no table; rules 6 to 8 still apply to its review.

## Blocked by

- #42 (PR #92 carries the script this ticket's disable rule is modeled on)



## Design

Posted by the agent 2026-09-22. The change has one script, `template/.github/shellcheck.sh`, that both CIs and a lane call; its usage and signature are the design artifact. The rest of the ticket is CI text, a doctor line and prose, which have no artifact beyond the acceptance criteria.

Usage, the caller's view:

```
bash .github/shellcheck.sh                        this project's shell files: .claude/hooks/*.sh, .agents/skills/*/scripts/*.sh, .github/shellcheck.sh
bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it
bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes
```

In the factory, `.github/shellcheck.sh` is a link to `template/.github/shellcheck.sh` (the nesting rule, P7), and CI runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`. The fixture job runs the zero-argument form inside `/tmp/fx`, which is the template CI's step character for character.

Signature: `shellcheck.sh [glob...]`. Runs ShellCheck 0.11.0 with `--external-sources` at the default severity and no `--shell` over the files the globs match. Uses the `shellcheck` on PATH when its version is the pin; otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that. Writes nothing inside the repository.

| Situation | Prints | Exit | The caller |
|---|---|---|---|
| Every file clean | `ShellCheck 0.11.0, files checked: N` | 0 | proceeds |
| A finding | the count line, then ShellCheck's own report | 1 | fixes it, or adds `# shellcheck disable=SCnnnn # <reason>` on the line above |
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
| Local ShellCheck absent or off-pin, platform pinned | downloads once, then one of the rows above | as that row | nothing; the doctor's NOTE says how to install one |
| Local ShellCheck absent, platform not pinned | `shellcheck.sh: ShellCheck 0.11.0 is not pinned for <os>.<arch>; install it by hand` on stderr | 1 | installs it; `factory918 doctor` names the command |
| Checksum mismatch | refused with `sha256sum`'s own message | 1 | reports it; the pin or the download is wrong |

`tests/shellcheck/gate.sh` asserts the first three rows, the platform row (a fake `uname` on PATH with ShellCheck hidden) and that a `#!/bin/sh` file keeps its POSIX checks. The download row is proven by the fixture job on `ubuntu-latest`, whose image carries an off-pin ShellCheck; the checksum row is the tool's own refusal and is not simulated.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/ab47eb9/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
