# Standards review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

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

The diff is 537 lines; read it from `.scratch/review/ab47eb9/diff`.

## Standards

### CODING_STANDARDS.md

# Coding standards for the factory itself

Read at review time by `spec-review`'s Standards axis. Skip anything the CI gate (`.github/workflows/factory-ci.yml`) already enforces. The template's `CODING_STANDARDS.md` is for projects; this one is for the bash, Python and markdown this repository is made of.

## Bash (`factory918.sh`, the hooks)

- `set -euo pipefail` at the top; one function per subcommand; the dispatch `case` at the bottom.
- Quote every path. Paths here contain spaces.
- Prefer commands that behave the same on macOS and Linux. Where BSD and GNU differ (`sed -i`, `date -d`, `readlink -f`), either use a form both accept or branch on `command -v`.
- Structured edits to JSON or YAML go through `jq` or a short `python3` heredoc, never `sed`.
- Every doctor check carries its fix as the third argument. A `FAIL` with no fix is a bug.
- A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command (the doctor's report at the end of `apply` is one), never hide it.
- Test a command the way a user types it: absolute paths, from another directory, through the installed symlink.
- A `PreToolUse` hook that must let the call through on its own failure runs without `-e`, says so in its header, and exits 2 only on a decided block. `delegation.sh` and `format-on-write.sh` are the two that do.
- A `# shellcheck disable=` directive carries its reason as a second comment on the same line: `# shellcheck disable=SC2016 # the backticks are the ticket's token delimiters`. The directive sits on the narrowest scope that covers the intent, above the one statement or at the top of a file whose whole job produces the pattern.

## Python (`tools/`, heredocs in the CLI)

- Standard library only. One script per job; each exits 1 on any miss and says what missed.

## Markdown (docs, skills, both `AGENTS.md`)

- Written with `/writing-for-agents` when an agent reads it, `/technical-writing` and `/unslop` when a person does. One Diátaxis mode per file, except the vendored copies under `docs/agents/`, which are edited in the template or not at all.
- `docs/knowledge/core/` is the source; everything under `docs/knowledge/spec/`, `pages/`, `notes/` and `template/docs/factory918/` is generated and never edited.
- A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby.

## Commits and pull requests

The rules are in `AGENTS.md`, "Pull requests"; they are not repeated here. Records: a verified tool fact goes to `docs/M0-findings.md` with its date, a surprise to `docs/agents/ledger.md`, a choice to `docs/knowledge/core/DECISIONS.md` under Provisional.

## Smell baseline

Each smell reads *what it is* -> *how to fix*; match it against the diff. A documented repo standard overrides the baseline; every smell is a judgement call, never a hard violation.

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/ab47eb9/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
