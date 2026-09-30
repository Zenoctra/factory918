# Writer report, ticket #88

Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a04f2da1c527e1ba3`
Branch: `wt/88-writer`, from `ab47eb91fa42a896c1eec054e526b615b5cbf316`. Status after the last commit: clean (`git status --porcelain` prints nothing). Nothing pushed, no PR opened.

## The five commits (`git log --oneline ab47eb9..HEAD`)

```
69bd412 Record the ShellCheck pin, the gate decision and a lost lane
f156229 Name the shell gate in the playbook, the standards and both AGENTS.md
992ce94 Give the doctor a shellcheck line
741bc89 Resolve every ShellCheck finding on the factory's shell files
1208407 Add the shell gate, its test and the three CI steps that call it
```

## The one deviation from the brief: 20 files, not 19

The brief and candidate B say the factory gate reports `files checked: 19`. It reports 20. B's 19 is the ticket's 18 files plus the gate script, counted before `tests/shellcheck/gate.sh` existed; the test lands under `tests/*/*.sh`, which B's Point 7 wanted ("the gate lints its own test"), so the design's own consequence is 20. Nothing was widened or narrowed to reach it. The root `AGENTS.md` bullet and the M0 section say 20, with the reason in M0. If the orchestrator wants 19 in the prose instead, that is one word in two files, but it would be false at the commit that lands it.

Everything else in the brief was implemented as written. No cell or row was left unfilled.

## The gate

At commit 1 (`1208407`), over the factory set, before any fix:

```
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 19
... exit=1
```

57 findings (`shellcheck -x -f gcc` over the same 19 files: SC2016 x45, SC2086 x3, SC2015 x2, SC2034 x2, SC2115 x2, SC2012 x1, SC2088 x1, SC2148 x1), the ticket's breakdown exactly. `tests/shellcheck/gate.sh` was not yet counted because the first run happened before the test file was written; from the moment it existed the set was 20.

At HEAD (`69bd412`):

```
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 20
exit=0
$ shellcheck factory918.sh template/.github/shellcheck.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh     # no -x
exit=0
$ cd / && shellcheck -x -f gcc <absolute path>/tests/spec-review/review-brief.sh <absolute path>/tests/spec-review/review-comment.sh   # graft 1
exit=0
```

Both green from commit 2 (`741bc89`) on.

## Verification, each command with its exit code and last line

Run before every commit from commit 2 on (the shell tests also at commit 1 where they applied). The results below are from the run before commit 5; every earlier run gave the same lines.

| Command | Exit | Last line |
|---|---|---|
| `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` | 0 | `ShellCheck 0.11.0, files checked: 20` |
| `bash tests/shellcheck/gate.sh` | 0 | `ok 10 assertions` |
| `bash tests/hooks/delegation.sh` | 0 | `ok 55 assertions` |
| `bash tests/spec-review/review-comment.sh` | 0 | `ok 82 assertions` |
| `bash tests/spec-review/review-brief.sh` | 0 | `ok 334 assertions` |
| `bash tests/poteto-mode/overlap.sh` | 0 | `ok 56 assertions` |
| `bash tests/spec-review/no-stale-wording.sh` | 0 | `ok: no stale wording` |
| `sh -n tests/spec-review/fake-gh.sh` | 0 | (no output) |
| `./factory918.sh sync` (commit 2, exercising the array count) | 0 | `vendored: 72 skills. Review with git status, bump VERSION, commit.` |
| `./factory918.sh sync > /dev/null && git status --porcelain` (commits 4 and 5) | 0 | only the files of the commit in progress; nothing after the commit |
| `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git status --porcelain` (commit 4) | 0 | `knowledge files: 118 → docs/knowledge`, status held only commit 4's seven prose files |
| `python3 tools/build_knowledge.py`, then `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git status --porcelain` (commit 5) | 0 | `knowledge ok: 118 files`; status held the five record files, committed together |

Note on the knowledge step at commit 5: `check_knowledge.py` run first on the edited `DECISIONS.md` fails with `core/DECISIONS.md: INDEX says 92 lines, file has 93`, because the build is what rewrites the core file's `<!-- lines: N -->` header and the `INDEX.md` row. Running the build first, then check, then build again, gives a clean pass and a clean tree; CI's order (`check && build && git diff --exit-code`) passes on the committed result, which carries the 93.

`tests/shellcheck/gate.sh` asserts, from a fixture directory whose path has a space: a clean file exits 0 with the exact line `ShellCheck 0.11.0, files checked: 1`; a planted `cat $f` exits 1 with SC2086; `'nope/*.sh'` exits 1 with `shellcheck.sh: no file matched nope/*.sh; the gate checked nothing` on stderr and nothing on stdout; a `#!/bin/sh` file with an array exits 1 with SC3030; the zero-argument form from a simulated project root (two hooks, one skill script under `.agents/skills/x/scripts/`, the script copied to `.github/shellcheck.sh`, `.claude/skills -> ../.agents/skills`) exits 0 with `files checked: 4`; a fake `uname` printing `Plan9`/`mips` on `PATH=<fakedir>:/usr/bin:/bin` exits 1 with `shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand`; and the script's mode bit. The fixture files are heredocs rather than `printf '...$1...'`, because the gate itself flagged the single-quoted `$` as SC2016 on the first draft of the test. The download path is not tested (fixture job).

## The doctor line, both states (scratch file `scratchpad/doc.sh`, outside the repository)

```
$ bash doc.sh
PASS  shellcheck 0.11.0
exit=0
$ PATH=<emptydir>:/usr/bin:/bin bash doc.sh
NOTE  shellcheck
      fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE
exit=0
$ shellcheck doc.sh
exit=0
```

## `git status --porcelain`

After `./factory918.sh sync > /dev/null` at HEAD: nothing.
After `python3 tools/build_knowledge.py` at HEAD: nothing.

## `git diff --stat ab47eb9..HEAD`

```
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
 template/.github/shellcheck.sh                     | 45 ++++++++++++
 template/.github/workflows/ci.yml                  |  2 +
 template/AGENTS.md                                 |  1 +
 template/CODING_STANDARDS.md                       |  2 +-
 template/docs/factory918/DECISIONS.md              |  1 +
 tests/poteto-mode/overlap.sh                       |  5 +-
 tests/shellcheck/gate.sh                           | 81 ++++++++++++++++++++++
 tests/spec-review/fake-gh.sh                       |  2 +-
 tests/spec-review/layout.sh                        |  1 +
 tests/spec-review/review-brief.sh                  |  2 +
 tests/spec-review/review-comment.sh                |  3 +
 27 files changed, 178 insertions(+), 18 deletions(-)
```

`.github/shellcheck.sh` is a git symlink (mode 120000) to `../template/.github/shellcheck.sh`; `template/.github/shellcheck.sh` is mode 100755.

## Small choices the orchestrator should know about

- The factory CI step after `ShellCheck` is named `shellcheck.sh passes, refuses and counts what the test says`, in the style of the other test steps, and sits between `ShellCheck` and the delegation test. The fixture step is `The shell gate a project runs` (synthesis's name), placed right after `Day 0 on a fresh monorepo`.
- `tests/poteto-mode/overlap.sh`: with the reason now on the directive line, the header's last sentence ("The backticks in the bodies below are the ticket's token delimiters, not command substitutions.") said the same thing twice, so that sentence moved onto the directive rather than being kept in both places. Nothing else in the header changed.
- The `layout.sh` directive sits after the six-line header comment, before `source_skill=` (synthesis's placement).
- The ledger line is verbatim from the brief, including `Claude Fable 5.1` as the model column, although every earlier row spells the model `fable`. Left as given; a one-word change if the file's spelling is preferred.
- Root `AGENTS.md` bullet, root `CODING_STANDARDS.md` bullet and the M0 section carry no long dash; B's em dashes became commas or sentence breaks with the words otherwise intact.
- Commit messages: plain-sentence subjects, no trailing period, body says the problem then the fix, trailer `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` after a blank line. Message drafts are in `scratchpad/msg1.txt` to `msg5.txt`.
- The harness's worktree guard refused compound Bash lines that mixed `git` with pipes, loops or `cd`; every check above was rerun as a plain command, so no verification was skipped, only split.
