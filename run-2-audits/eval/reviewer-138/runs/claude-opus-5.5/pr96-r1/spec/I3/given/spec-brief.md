# Spec review brief

You may open any file in the repository and run read-only commands, such as grep or the test suite.

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

## Reading pack

### .github/shellcheck.sh, a symbolic link to ../template/.github/shellcheck.sh: no text

### .github/workflows/factory-ci.yml, whole, 87 lines

```
# The factory's own gate. Job 1 checks the repository; job 2 does what a user does on day 0
# and runs the gates a fresh project would run, so a template regression fails here first.
name: Factory CI
on:
  pull_request:
  push:
    branches: [main]
concurrency:
  group: factory-ci-${{ github.event.pull_request.number || github.sha }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
jobs:
  factory:
    name: Factory
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        run: bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
      - name: shellcheck.sh passes, refuses and counts what the test says
        run: bash tests/shellcheck/gate.sh
      - name: The delegation hook blocks and passes what the test says
        run: bash tests/hooks/delegation.sh
      - name: review-comment.sh prints and refuses what the test says
        run: bash tests/spec-review/review-comment.sh
      - name: review-brief.sh writes the report shape into both briefs
        run: bash tests/spec-review/review-brief.sh
      - name: overlap.sh prints, stops and refuses what the test says
        run: bash tests/poteto-mode/overlap.sh
      - name: No retired review wording under template/ or the core knowledge
        run: bash tests/spec-review/no-stale-wording.sh
      - name: Knowledge base is consistent and built from its sources
        run: python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code
      - name: Vendored skills equal the pins plus the patches
        run: ./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"
  fixture:
    name: Fixture
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v4
      - uses: voidzero-dev/setup-vp@v1
        with:
          version: "0.3.1" # the ADR pin
          node-version: "24"
          run-install: false # the factory root has no package.json; the fixture installs its own
      - uses: astral-sh/setup-uv@v6
      - name: Day 0 on a fresh monorepo
        run: |
          git config --global user.name ci && git config --global user.email ci@factory918.invalid
          (cd /tmp && vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent)
          git -C /tmp/fx add -A && git -C /tmp/fx commit -qm "chore: initial commit"
          ./factory918.sh apply /tmp/fx --scaffold --profile python --name demo | tail -30
      - name: The shell gate a project runs
        working-directory: /tmp/fx
        run: bash .github/shellcheck.sh
      - name: review-brief.sh briefs the apply diff inside the project
        working-directory: /tmp/fx
        run: |
          git add -A && git commit -qm "factory918 apply"
          mkdir -p /tmp/fake-gh && cp "$GITHUB_WORKSPACE/tests/spec-review/fake-gh.sh" /tmp/fake-gh/gh && chmod +x /tmp/fake-gh/gh
          printf -- '- **What it does.** Applies the factory.\n- **Risks.** Every hook under `.claude/hooks/` is new here.\n' > /tmp/blast.md
          PATH="/tmp/fake-gh:$PATH" .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --ticket 1 --blast-radius /tmp/blast.md
          d=.scratch/review/HEAD_1
          test -s "$d/standards-brief.md" && test -s "$d/spec-brief.md"
          for f in "$d/standards-brief.md" "$d/spec-brief.md"; do
            grep -qF 'A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.' "$f"
            grep -qF '`## Fails open`' "$f"
            if grep -qF '## Latent' "$f"; then echo "$f carries ## Latent" && exit 1; fi
          done
          grep -qF '`## Walk`' "$d/spec-brief.md"
          if grep -qF '`## Walk`' "$d/standards-brief.md"; then echo "the Standards brief carries a walk" && exit 1; fi
          rm -rf .claude/state/review
      - name: The gates a project runs
        working-directory: /tmp/fx
        run: vp check && vp test run && pnpm sg:test && pnpm sg
      - name: The Python profile's job
        working-directory: /tmp/fx/python/demo
        run: uv sync --frozen && uv run ruff format --check . && uv run ruff check . && uv run pyright && uv run pytest && uv audit
      - name: The rules fire
        working-directory: /tmp/fx
        run: |
          printf '// TODO later\nexport const x = 1;\n' > packages/utils/src/probe.ts
          if vp lint packages/utils/src/probe.ts > /dev/null 2>&1; then echo "no-todo-without-issue did not fire" && exit 1; fi
          printf 'console.log("x");\n' > packages/utils/src/probe.ts
          if pnpm sg > /dev/null 2>&1; then echo "ast-grep did not fire" && exit 1; fi
          rm packages/utils/src/probe.ts
```

### CODING_STANDARDS.md, whole, 29 lines

```
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
```

### docs/M0-findings.md, lines 170-173 of 181

```
## ShellCheck (2026-09-22)

ShellCheck 0.11.0, Homebrew, macOS arm64, is the pin: `shellcheck-v0.11.0.linux.x86_64.tar.xz` sha256 `8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198`, `shellcheck-v0.11.0.darwin.aarch64.tar.xz` sha256 `56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79`. At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0 after five fixes and the directives; `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files. The severity floor is the default, not `warning`: SC2086, the unquoted expansion the ticket's Problem names, is info level, so `--severity=warning` leaves that class passing (6 findings at `warning`, 1 at `error`). `--external-sources` is required, not optional: without it the two spec-review tests report SC1091 and three SC2154 on the sourced `tests/spec-review/layout.sh`, so a lane checking one changed file would disagree with CI; `-x` resolves the sourced path relative to the working directory, so the gate runs from the repository root, and `# shellcheck source-path=SCRIPTDIR source=layout.sh` above the `.` line lets a per-file run from any directory resolve it too. No `--shell`: forcing `-s bash` hides SC3030 and SC3054 in `tests/spec-review/fake-gh.sh`, which is `#!/bin/sh`. A directive's reason must be a second comment on the same line. `# shellcheck disable=SC2016 # reason` parses, `# shellcheck disable=SC2016 reason` is SC1073 plus SC1072, an error, and `# shellcheck shell=bash disable=SC2034 # reason` on one line clears SC2148 on a file with no shebang. The SC2115 fix, `"${skills:?}/$n"` at the two `rm -rf` lines in `cmd_sync`, states an invariant rather than fixing a live bug, because `$skills` is a literal suffix on `$TEMPLATE` and is never empty. The download path was not run on this machine, which has the pin on PATH; the fixture job on `ubuntu-latest` is where it is proven.

```

### docs/knowledge/INDEX.md, lines 1-29 of 127

```
# Factory918 knowledge base: index

Read this file first; then grep; then read one section by range. Never read a file over 200 lines without `offset`/`limit`.
The literal transcript of the conversation that produced this system is not available; `core/CONVERSATION-DIGEST.md` is the substitute.

| file | what | lines | read when |
|---|---|---|---|
| `core/PHILOSOPHY.md` | Factory918: philosophy | 64 | First. Whenever the spec is silent. |
| `core/MANUAL.md` | Factory918: the manual | 174 | How to run the loop; what the human does at each point. |
| `core/DECISIONS.md` | Factory918: decisions | 93 | Before overriding any vendored skill; these win. |
| `core/GLOSSARY.md` | Factory918: glossary | 69 | A term in AGENTS.md, a playbook or a ticket is unclear. |
| `core/CONVERSATION-DIGEST.md` | How Factory918 was arrived at | 53 | Why something was chosen, historically; the corrections. |
| `spec/FACTORY-SPEC-v2/01-preamble.md` | The Factory spec, v2 — (preamble) | 11 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/02-change-log-v1-v2.md` | The Factory spec, v2 — Change log, v1 → v2 | 20 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/03-change-log-v2-v2-1-2026-09-09-layout-only.md` | The Factory spec, v2 — Change log, v2 → v2.1 (2026-09-09, layout only) | 15 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/04-0-instructions-to-the-implementing-model.md` | The Factory spec, v2 — 0. Instructions to the implementing model | 20 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/05-1-what-manuel-needs-in-one-paragraph.md` | The Factory spec, v2 — 1. What Manuel needs, in one paragraph | 12 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/06-2-the-central-question-does-pstack-build-the-ci-.md` | The Factory spec, v2 — 2. The central question: does pstack build the CI stack on its own? | 38 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/07-3-the-system-end-to-end.md` | The Factory spec, v2 — 3. The system, end to end | 27 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/08-4-repository-layout-of-the-factory.md` | The Factory spec, v2 — 4. Repository layout of the factory | 75 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/09-5-skill-manifest.md` | The Factory spec, v2 — 5. Skill manifest | 61 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/10-6-contradictions-between-the-vendored-skills-and.md` | The Factory spec, v2 — 6. Contradictions between the vendored skills, and how the factory resolves them | 24 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/11-7-the-deterministic-layer-concretely.md` | The Factory spec, v2 — 7. The deterministic layer, concretely | 167 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/12-7-the-deterministic-layer-concretely.md` | The Factory spec, v2 — 7. The deterministic layer, concretely | 128 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/13-7-the-deterministic-layer-concretely.md` | The Factory spec, v2 — 7. The deterministic layer, concretely | 13 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/14-8-factory918-sh-init-apply-doctor-update-sync-la.md` | The Factory spec, v2 — 8. `factory918.sh`: init, apply, doctor, update, sync, labels | 44 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/15-9-milestones-for-the-implementing-model.md` | The Factory spec, v2 — 9. Milestones for the implementing model | 26 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/16-10-decisions.md` | The Factory spec, v2 — 10. Decisions | 8 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/17-11-glossary-of-tools-named-here.md` | The Factory spec, v2 — 11. Glossary of tools named here | 8 | Building or updating the factory itself. |
```

### docs/knowledge/core/DECISIONS.md, lines 1-1 of 93

```
<!-- lines: 93 | source: core/DECISIONS.md | part 1/1 | title: Factory918: decisions -->
```

### docs/knowledge/core/DECISIONS.md, lines 90-93 of 93

```
| P22 | Who signs a comment | A comment the agent posts on a PR or a ticket ends with the model and harness (`Claude Fable 5.1 on Claude Code`), plus `approved by <name>` when the human approved it before posting; only an approved comment posted from the author's account is the author's words. `review-brief.sh` reads only the PR author's account for rounds and carry-forward | Manuel, 2026-09-18: a comment left by the orchestrator without human involvement is signed by the model on the harness; approved, it is signed by both; strangers' comments never reach a brief (#78 round 1). |
| P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
| P25 | One shell gate, carried by the template | `template/.github/shellcheck.sh` holds the ShellCheck version, both release checksums and the flags; a project gets it as `.github/shellcheck.sh` and the factory runs the template's copy. The severity is the default and `--external-sources` is on, so a lane's per-file run and CI's whole-set run give the same answer. A `disable=` directive carries its reason in a second comment on the same line; CI cannot check that a reason exists, the Standards axis does | A `run:` block in each workflow would put the pin in two files and the flags in three, and a project's CI cannot read the factory's files. SC2086 is info level, so a `--severity` floor would pass the class ticket #88 was written for; without `-x` the two spec-review tests report findings on one file that vanish on the whole set, which would make the playbook's "run it before the PR" sentence false. Ticket #88, 2026-09-22. |
```

### factory918.sh, lines 379-405 of 428

```
cmd_sync() {
  need git
  local skills="$TEMPLATE/.agents/skills"
  local pstack="$F918_DIR/research/3-pstack/open-pstack-claude-code-port/plugins/pstack"
  local matt="$F918_DIR/research/1-matt-pocock/skills-repo/skills"
  local ours="factory918 factory-start knowledge mode-plan mode-build factory-doctor factory-retro"
  local keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh"
  local tmp; tmp="$(mktemp -d)"
  for k in $keep_files; do mkdir -p "$tmp/keep/$(dirname "$k")"; cp "$skills/$k" "$tmp/keep/$k"; done
  for d in "$pstack"/skills/*/; do n="$(basename "$d")"; [ "$n" = no-comments ] && continue; rm -rf "${skills:?}/$n"; cp -R "$d" "$skills/$n"; done
  for n in grilling grill-me grill-with-docs domain-modeling to-spec to-tickets wayfinder research prototype setup-matt-pocock-skills writing-for-agents wizard wait-what; do
    src="$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1)"; rm -rf "${skills:?}/$n"; cp -R "$src" "$skills/$n"; done
  rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review" "$skills/spec-review"
  for k in $keep_files; do mkdir -p "$skills/$(dirname "$k")"; cp "$tmp/keep/$k" "$skills/$k"; done
  rm -rf "$TEMPLATE/.claude/agents"; mkdir -p "$TEMPLATE/.claude/agents"; cp "$pstack"/agents/*.md "$TEMPLATE/.claude/agents/"; rm -f "$TEMPLATE/.claude/agents/comment-sicko.md"
  local failed=0
  while read -r p; do
    [ -n "$p" ] || continue
    if git -C "$skills" apply --check "$F918_DIR/patches/$p" 2>/dev/null; then git -C "$skills" apply "$F918_DIR/patches/$p"; echo "applied  $p"
    else echo "FAILED   $p (upstream moved; rewrite the patch)"; failed=1; fi
  done < "$F918_DIR/patches/series"
  rm -rf "$tmp"
  for n in $ours; do [ -f "$skills/$n/SKILL.md" ] || { echo "missing our skill: $n" >&2; failed=1; }; done
  local -a dirs; dirs=("$skills"/*/)
  echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
  return $failed
}
```

### patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch, whole, 26 lines

```
--- a/poteto-mode/playbooks/opening-a-pr.md
+++ b/poteto-mode/playbooks/opening-a-pr.md
@@ -6,7 +6,7 @@
 
 **Commits.** Commit liberally; rebase into small, ordered commits before opening PRs. Each commit is a future PR: landable, ordered to tell the story. Amend when the fix belongs in a just-made commit; new commit when separable.
 
-**PRs.** Run `/deslop` over the diff before commit. Run `/no-comments` before review. Write every PR title, PR description, and commit body with `/technical-writing`, then apply `/unslop`. Apply every technical-writing layer except Diátaxis. Use one word for each action, keep articles, and avoid `-ing` when a plain verb works.
+**PRs.** Run `/deslop` over the diff before commit. Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs, so the finding lands in this lane instead of a review round. Keep comments (DECISIONS.md #4); do not run `/no-comments`. After CI is green, run `spec-review` in a fresh context against the originating ticket (and its parent spec) and `CODING_STANDARDS.md`; fix Act-on items, record the rest in the PR body. The full ladder is `docs/agents/review-ladder.md`. Write every PR title, PR description, and commit body with `/technical-writing`, then apply `/unslop`. Apply every technical-writing layer except Diátaxis. Use one word for each action, keep articles, and avoid `-ing` when a plain verb works.
 
 **Titles.** Use Conventional Commits in the form `type(scope): subject`. Use `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, or `perf` as the type. Use the changed area, such as `pstack` or `poteto-mode`, as the scope. Keep the subject short and imperative. Apply the same `/technical-writing` and `/unslop` pass as the body. Name a real symbol when one carries the change. For example, `fix(pstack): retarget opening-a-pr babysit trigger`. Do not add a trailing period.
 
@@ -15,7 +15,7 @@
 - `## Why`. State the intent and why this approach fits.
 - `## Scope`. State facts from the diff. Name real symbols and paths. Name both sides of a rename or retarget. State what is in and out when the boundary matters.
 - `## Tradeoffs`. State real choices only. Skip this section when there are none.
-- `## Blast Radius`. State who and what the change touches. Explain why the change is safe or risky. If main is red without the fix, name the continuing cost.
+- `## Blast Radius`. State who and what the change touches. Explain why the change is safe or risky. If main is red without the fix, name the continuing cost. For a cross-cutting diff (Ticket step 5) this section is `.scratch/<ticket>/blast-radius.md` verbatim, and `spec-review`'s `review-brief.sh` reads it from here.
 - `## Verification`. State how you ran each check and its rigor. Name the real path, such as the `run` skill, the `verify` skill, or the targeted tests. State the outcome of each check, not only the command name.
 
 After these sections, attach videos or screenshots when they prove a claim. Do not use `## Summary` or `## Test plan` boilerplate. A commit body does not restate its subject.
@@ -28,4 +28,4 @@
 
 **Babysit.** Opening a PR does not start a babysit. Post the URL and keep building. Finish the phase or stack first. Run a separate babysit pass only when the user asks for one after the whole stack exists, per `babysit.md`. A babysit for each new PR stalls the build and spends checks on commits that later waves restart. Push back when feedback drifts from intent.
 
-A subagent that opens a PR runs `interrogate`, `/deslop`, and `/no-comments`. It returns the URL and does not babysit. Return to the parent.
+A subagent that opens a PR runs `interrogate` and `/deslop`. It returns the URL and does not babysit. Return to the parent.
```

### template/.agents/skills/poteto-mode/scripts/overlap.sh, whole, 118 lines

```
#!/usr/bin/env bash
# Ticket step 1 and step 8. `overlap.sh N` prints `go: <label or none>` (the newest line of
# .claude/state/program naming #N), then `#<pr> <head>: <paths>` for every open PR whose own
# commits (its diff from the nearest open-PR head under it, else origin/main) touch a path the
# ticket's body names in backticks (tokens without whitespace, those under `## Diff` skipped,
# passed together as pathspecs), ascending by PR number, then on exit 0 the ref to branch from:
# origin/main when nothing is shared, else the printed head that contains every other, else the
# lowest PR number's. `overlap.sh N --diff` compares the branch's own paths by the same rule (the
# own PR skipped, literal pathspecs), prints nothing when none is shared, the go and the PR lines
# otherwise, and no base. `overlap.sh go
# "<label>" N...` appends `<label>: #a #b ...` to the program file, its only writer; a linked
# worktree reads the main checkout's. Exit 0 decided, 1 a path shared with a PR no go covers (a go
# covers when some line names #N and some line names the ticket each printed PR closes; a PR that
# closes no ticket is never covered), 2 gh or git failed and its message is on stderr, `--diff` on
# a detached HEAD, or more than 100 open PRs, 64 usage.
# Every PR head is fetched fresh before any diff; no origin remote means nothing is in flight.
set -euo pipefail
trap 'exit 2' ERR
usage() { echo 'usage: overlap.sh N [--diff] | overlap.sh go "<label>" N...' >&2; exit 64; }
cd "$(git rev-parse --show-toplevel)"
prog="$(git rev-parse --git-common-dir)/../.claude/state/program"

if [ "${1:-}" = go ]; then
  [ $# -ge 3 ] || usage
  line="$2:"; shift 2
  for t in "$@"; do t="${t#\#}"; [[ $t =~ ^[0-9]+$ ]] || usage; line="$line #$t"; done
  mkdir -p "$(dirname "$prog")"; echo "$line" >> "$prog"; exit 0
fi
[ $# -ge 1 ] && [ $# -le 2 ] || usage
n="${1#\#}"; [[ $n =~ ^[0-9]+$ ]] || usage
diff=""; [ $# -eq 1 ] || { [ "$2" = --diff ] || usage; diff=1; }
cur="$(git branch --show-current)"
if [ -n "$diff" ] && [ -z "$cur" ]; then echo "detached HEAD; run from the ticket's branch" >&2; exit 2; fi

# The newest go naming the ticket is the one the human gave last.
l="$(grep -w -- "#$n" "$prog" 2>/dev/null | tail -n 1 || true)"
go="go: ${l%%: #*}"; [ -n "$l" ] || go="go: none"
covered=1; [ "$go" != "go: none" ] || covered=0

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "no origin remote; nothing in flight" >&2
  [ -n "$diff" ] || printf '%s\nbase: main\n' "$go"
  exit 0
fi

if [ -z "$diff" ]; then
  body="$(gh issue view "$n" --json body -q .body)"
  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
  # shellcheck disable=SC2016 # the backticks are the ticket's token delimiters, not command substitution
  paths="$(printf '%s\n' "$outside" | grep -oE '`[^`[:space:]]+`' | tr -d '`' | sort -u || true)"
  if [ -z "$paths" ]; then printf '%s\npaths: none\nbase: origin/main\n' "$go"; exit 0; fi
fi

# One line per open PR: number, head, the tickets it closes; heads refreshed in one fetch. A 101st
# line means the list is cut, and a PR the check cannot see cannot be ruled out.
prs="$(gh pr list --state open --limit 101 --json number,headRefName,closingIssuesReferences \
  -q 'sort_by(.number)[] | "\(.number)\t\(.headRefName)\t\(.closingIssuesReferences | map("#\(.number)") | join(" "))"')"
if [ "$(grep -c . <<< "$prs")" -gt 100 ]; then echo "more than 100 open PRs; the check cannot list them all" >&2; exit 2; fi
specs=(+refs/heads/main:refs/remotes/origin/main)
while IFS=$'\t' read -r num head closes; do
  [ -n "$num" ] || continue
  specs+=("+refs/heads/$head:refs/remotes/origin/$head")
done <<< "$prs"
git fetch -q origin "${specs[@]}"

# is_ancestor <a> <b>: 0 yes, 1 no; any other git exit ends the run, its message already on stderr.
is_ancestor() { git merge-base --is-ancestor "$1" "$2" && return 0; [ $? -eq 1 ] && return 1; exit 2; }
# nearest <ref> <own head>: the open-PR head under the ref with the fewest commits between, the
# ref's own head never (a head is not its own base), else origin/main.
nearest() {
  local base=origin/main best="" num head closes d
  while IFS=$'\t' read -r num head closes; do
    [ -n "$num" ] && [ "$head" != "$2" ] || continue
    is_ancestor "origin/$head" "$1" || continue
    d="$(git rev-list --count "origin/$head..$1")"
    [ "$d" -gt 0 ] || continue
    if [ -z "$best" ] || [ "$d" -lt "$best" ]; then best="$d"; base="origin/$head"; fi
  done <<< "$prs"
  echo "$base"
}

if [ -n "$diff" ]; then
  base="$(nearest HEAD "$cur")"
  paths="$(git diff --name-only "$base...HEAD")"
  [ -n "$paths" ] || exit 0
  export GIT_LITERAL_PATHSPECS=1
fi
IFS=$'\n' read -r -d '' -a toks <<< "$paths" || true

lines=""; printed=()
while IFS=$'\t' read -r num head closes; do
  [ -n "$num" ] || continue
  [ -z "$diff" ] || [ "$head" != "$cur" ] || continue
  base="$(nearest "origin/$head" "$head")"
  shared="$(git diff --name-only "$base...origin/$head" -- "${toks[@]}" | tr '\n' ' ')"
  [ -n "$shared" ] || continue
  lines+="#$num $head: ${shared% }"$'\n'
  printed+=("$head")
  [ -n "$closes" ] || covered=0
  for t in $closes; do grep -qw -- "$t" "$prog" 2>/dev/null || covered=0; done
done <<< "$prs"

if [ -n "$diff" ]; then
  [ -n "$lines" ] || exit 0
  printf '%s\n%s' "$go" "$lines"
  [ "$covered" = 1 ] || exit 1
  exit 0
fi
printf '%s\n%s' "$go" "$lines"
if [ -z "$lines" ]; then echo "base: origin/main"; exit 0; fi
[ "$covered" = 1 ] || exit 1
base="origin/${printed[0]}"
for h in "${printed[@]}"; do
  holds=1
  for o in "${printed[@]}"; do is_ancestor "origin/$o" "origin/$h" || holds=0; done
  if [ "$holds" = 1 ]; then base="origin/$h"; break; fi
done
echo "base: $base"
```

### template/.agents/skills/spec-review/scripts/review-brief.sh, lines 1-59 of 362

```
#!/usr/bin/env bash
# spec-review step 1. Runs the diff once, writes the review state the delegation hook reads, and
# assembles the two reviewer briefs, so the orchestrator hands each lane a file and reads no code.
#   review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N] [--blast-radius FILE]
#   review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...] [--blast-radius FILE]
# The second form is the sweep over units already on main: the fixed point is the word "paths"
# and the diff is git show <commits> -- <paths>. Rerunning overwrites the previous state.
# The PR comments that end a review carry a line `act-on items:` under `round: N of 3`; the round
# is the highest N plus one (a comment without the line is round 1), so a comment rebuilt in the
# same round does not advance it, and a fourth round is refused. From every such comment, in order,
# the judgment's Noted and Dismissed items that cite a decision are carried into both briefs as
# settled, each line once; --previous FILE supplies the comments instead of gh, and --round N the
# round, for tests and a branch whose PR is elsewhere.
# A cross-cutting diff (one that touches a hooks directory, a settings.json or the factory918
# skill) is briefed only with its blast-radius grounding: --blast-radius FILE, else the PR body's
# `## Blast Radius` section; without one the script refuses before writing any state.
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
set -euo pipefail
usage() {
  echo "usage: review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N] [--blast-radius FILE]" >&2
  echo "       review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...] [--blast-radius FILE]" >&2
  exit 1
}
skill="$(cd "$(dirname "$0")/.." && pwd -P)"
root="$(git rev-parse --show-toplevel)"
cd "$root"
fixed="" ticket="" list="" previous="" round="" blast=""
paths=() commits=() standards=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ticket) ticket="${2:-}"; [ -n "$ticket" ] || usage; list=""; shift ;;
    --previous) previous="${2:-}"; [ -f "$previous" ] || usage; list=""; shift ;;
    --round) round="${2:-}"; [ "$round" -gt 0 ] 2>/dev/null || usage; list=""; shift ;;
    --blast-radius) blast="${2:-}"; [ -f "$blast" ] || usage; list=""; shift ;;
    --standards) list=standards ;;
    --paths) list=paths ;;
    --commits) list=commits ;;
    -*) usage ;;
    *) case "$list" in
         standards) standards+=("$1") ;;
         paths) paths+=("$1") ;;
         commits) commits+=("$1") ;;
         *) [ -z "$fixed" ] || usage; fixed="$1" ;;
       esac ;;
  esac
  shift
done
if [ ${#paths[@]} -gt 0 ]; then
  [ ${#commits[@]} -gt 0 ] && [ -z "$fixed" ] || usage
  for c in "${commits[@]}"; do
    git rev-parse --verify -q "$c^{commit}" >/dev/null || { echo "review-brief: $c does not resolve to a commit" >&2; exit 1; }
  done
  fixed=paths
  id="sweep-$(git rev-parse --short "${commits[0]}")"
else
  [ -n "$fixed" ] || usage
  git rev-parse --verify -q "$fixed^{commit}" >/dev/null || { echo "review-brief: $fixed does not resolve to a commit" >&2; exit 1; }
  id="$(printf '%s' "$fixed" | tr -c 'A-Za-z0-9._-' '_')"
fi
```

### template/.agents/skills/spec-review/scripts/review-comment.sh, lines 33-48 of 159

`````
# The shape is `## ` headings holding numbered items. Fenced text (the quoted hunks) is skipped.
# A fence opens on a line starting with three or more backticks or tildes, whatever follows them;
# it closes only on a line of the same character, at least as long as the opening run, followed
# by nothing but spaces or tabs (no info string). So ```sh inside a ``` block does not close it,
# nor does ``` inside a ```` block or a ~~~ block, and the quoted hunk stays fenced. A heading's
# name is the text after `## ` less trailing whitespace. review-brief.sh carries this fragment
# word for word (tests/spec-review/review-brief.sh holds the copies together).
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
    if (fence == "") { fence = m; next }
    if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t\r]*$/) { fence = ""; next } }
  fence != "" { next }
  /^## / { h = substr($0, 4); sub(/[ \t\r]+$/, "", h) }
'
headings() { awk "$fenced"'/^## / { print h }' "$1"; }
`````

### template/.claude/hooks/delegation.sh, lines 21-31 of 212

```
# shellcheck disable=SC2016 # $p is the sed address 7,$p, not a shell expansion
command="$(field '7,$p')"
root="$(cd "${CLAUDE_PROJECT_DIR:-${cwd:-.}}" 2>/dev/null && pwd -P)" || exit 0
git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -n "$cwd" ] || cwd="$root"
phase="$(cat "$root/.claude/state/mode" 2>/dev/null || echo execute)"
review="$root/.claude/state/review"
max_lines=200

block() { echo "$1" >&2; exit 2; }

```

### template/.claude/hooks/delegation.sh, lines 150-212 of 212

```
# sed -i writes its files; sed -n reads the range its script prints; any other sed prints them whole.
scan_sed() {
  local inplace=0 quiet=0 scripts=0 script="" args="" a b kind=whole
  while [ $# -gt 0 ]; do
    case "$1" in
      -e|--expression) scripts=$((scripts + 1)); script="${2:-}"; shift ;;
      -e*) scripts=$((scripts + 1)); script="${1#-e}" ;;
      --in-place*) inplace=1 ;;
      --quiet|--silent) quiet=1 ;;
      --*) ;;
      -*) case "$1" in *i*) inplace=1 ;; esac; case "$1" in *n*) quiet=1 ;; esac ;;
      *) args="$args $1" ;;
    esac
    [ $# -gt 0 ] && shift
  done
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $args
  if [ "$scripts" = 0 ]; then script="${1:-}"; [ $# -gt 0 ] && shift; fi
  if [ "$inplace" = 1 ]; then for a in "$@"; do target_write "$a"; done; return 0; fi
  if [ "$quiet" = 1 ]; then
    case "$script" in
      *,*p) a="${script%%,*}"; b="${script#*,}"; b="${b%p}"
            case "$a$b" in ""|*[!0-9]*) ;; *) [ $((b - a + 1)) -le "$max_lines" ] && kind=ranged ;; esac ;;
      *p) a="${script%p}"; case "$a" in ""|*[!0-9]*) ;; *) kind=ranged ;; esac ;;
    esac
  fi
  for a in "$@"; do target_read "$a" "$kind"; done
}

scan_segment() {
  local a prev="" words="" cmd
  for a in "$@"; do
    if [ "$prev" = ">" ]; then target_write "$a"; prev=""; continue; fi
    if [ "$a" = ">" ]; then prev=">"; continue; fi
    words="$words $a"; prev=""
  done
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $words
  while [ $# -gt 0 ]; do case "$1" in [A-Za-z_]*=*) shift ;; *) break ;; esac; done
  [ $# -gt 0 ] || return 0
  cmd="$1"; shift
  case "$cmd" in
    tee) for a in "$@"; do case "$a" in -*) ;; *) target_write "$a" ;; esac; done ;;
    cat) for a in "$@"; do case "$a" in -*) ;; *) target_read "$a" whole ;; esac; done ;;
    head) scan_head "$@" ;;
    sed) scan_sed "$@" ;;
    git) scan_git "$@" ;;
  esac
  return 0
}

case "$tool" in
  Write|Edit|NotebookEdit)
    rel="$(relative "$file")" || exit 0
    guard_write "$rel" ;;
  Read)
    rel="$(relative "$file")" || exit 0
    if [ -n "$offset$limit" ]; then guard_read "$rel" ranged; else guard_read "$rel" whole; fi ;;
  Bash)
    # shellcheck disable=SC2086 # set -f is on (line 7), so the tokenised segment splits into words without globbing
    while IFS= read -r seg; do scan_segment $seg; done <<< "$(printf '%s\n' "$command" | tokens)" ;;
esac
exit 0
```

### template/.github/shellcheck.sh, whole, 45 lines

```
#!/usr/bin/env bash
# The shell gate, in this project and in the factory that wrote it. Runs ShellCheck at the pinned
# version over the files the globs name, downloading that version when this machine does not have
# it, so the run a lane makes before a PR and the run CI makes are one run.
#   bash .github/shellcheck.sh                  this project's shell files
#   bash .github/shellcheck.sh '<glob>' ...     exactly these; quote a glob, this script expands it
# Run it from the repository root: --external-sources resolves a sourced file against the working
# directory. The severity is the default, because SC2086, the unquoted expansion, is info level and
# a --severity floor would pass the class this gate exists for. No --shell: each file is read in the
# dialect of its own shebang, so a `#!/bin/sh` file keeps its bashism checks. Globs that match no
# file at all leave the gate checking nothing, which is a failure, not a pass.
set -euo pipefail
version=0.11.0
sha_linux_x86_64=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
sha_darwin_aarch64=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79

bin=shellcheck
if ! "$bin" --version 2>/dev/null | grep -qx "version: $version"; then
  case "$(uname -s).$(uname -m)" in
    Linux.x86_64)                 plat=linux.x86_64;   sha="$sha_linux_x86_64" ;;
    Darwin.arm64|Darwin.aarch64)  plat=darwin.aarch64; sha="$sha_darwin_aarch64" ;;
    *) echo "shellcheck.sh: ShellCheck $version is not pinned for $(uname -s).$(uname -m); install it by hand" >&2; exit 1 ;;
  esac
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
    tar -xJf "$dir/sc.tar.xz" -C "$dir"
  fi
fi

if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
echo "ShellCheck $version, files checked: ${#files[@]}"
exec "$bin" --external-sources "${files[@]}"
```

### template/.github/workflows/ci.yml, whole, 45 lines

```
# DRAFT. Shape follows pingdotgg/t3code's ci.yml (MIT), simplified. setup-vp inputs are the ones T3 Code uses.
name: CI
on:
  pull_request:
  push:
    branches: [main]
concurrency:
  group: ci-${{ github.event.pull_request.number || github.sha }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
jobs:
  check:
    name: Check
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        run: bash .github/shellcheck.sh
      - name: Reject committed PR evidence
        run: |
          files="$(git ls-files .github/pr-assets .artifacts)"
          if test -n "$files"; then
            printf 'PR evidence must be uploaded to the PR, not committed:\n%s\n' "$files" >&2
            exit 1
          fi
      - uses: voidzero-dev/setup-vp@v1
        with:
          node-version-file: package.json
          cache: true
          run-install: true
      - run: vp check
      - run: pnpm sg # cross-language ast-grep rules; sgconfig.yml is at the repo root
      - run: vp run -r build
  test:
    name: Test
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: voidzero-dev/setup-vp@v1
        with:
          node-version-file: package.json
          cache: true
          run-install: true
      - run: vp test run
```

### template/AGENTS.md, lines 60-69 of 102

```
## Verifying

- Commands, TypeScript surfaces: `vp check` (format, lint and types; it stops at the first failing stage, so format first), `pnpm sg` (ast-grep rules), `vp test run <files>`, `vp run -r build`. Vite+'s own docs are at `node_modules/vite-plus/docs/`. Mobile: the same, plus `expo` for running and EAS for builds (see `profiles/react-native`). Python: `uv run ruff format --check`, `uv run ruff check`, `uv run pyright`, `uv run pytest <files>` (see `profiles/python`). Exact versions are in `docs/adr/0001-toolchain.md`.
- Shell: `bash .github/shellcheck.sh` before a PR, on the files the diff changes; with no arguments it checks the project's hooks and skill scripts, which is what CI runs.
- Smallest proof that the change works: the tests you touched, targeted lint and typecheck for the scope you changed.
- Run the whole suite only if it finishes in under 30 seconds. Otherwise CI owns the full suite.
- Test meaningful logic or observable behavior at a seam. No tests that assert wiring or mirror the implementation. A test that needs a timeout to pass is wrong. Expected values come from an independent source of truth.
- The spec's **Testing decisions** are the pre-agreed seams. `tdd` there.
- User-visible changes get one integrated pass with the project's `verify-<app>` skill (or `verify-<app>-mobile` on a simulator), run once by the primary agent after integrating. Subagents never launch their own dev servers, simulators or emulators. Ask permission before browsers, simulators or computer use.
- Evidence conventions: `docs/agents/evidence.md`. Upload evidence to the PR; never commit it.
```

### template/CODING_STANDARDS.md, whole, 37 lines

```
# Coding standards

Read at review time by `spec-review` (Standards axis), not during implementation. Skip anything tooling already enforces.

## Types (from pstack's typescript-best-practices)

- Discriminated unions with a `kind` literal; no optional-field bags.
- Branded types for semantic primitives (`UserId`, `OrderId`); validate once at the boundary.
- Make illegal states unrepresentable (`[T, ...T[]]` for non-empty; `start` + `duration` instead of two dates that can cross).
- `unknown` for external data, then parse into a named domain type at the crossing. Schemas before hand-written guards.
- No `as` casts except after validation. Narrowing order: discriminant switch > `in` > `typeof`/`instanceof` > user-defined guard > `as`.
- Exhaustiveness: `const _exhaustive: never = x` in default arms.
- `satisfies` over `as`. Derive types (`Pick`, `Omit`, `ReturnType`, `typeof`) before writing a new interface.
- Real tests: don't mock what you can run. Mock only at system boundaries (external APIs, time, randomness, sometimes the DB and filesystem). Never your own modules.
- No `console.log` in shipped code; structured logging.

## Shape (from Theo's Taste and pstack's principles)

- Complexity at the adapter boundary; orchestration pure; UI dumb.
- Laziness Protocol: the smallest change that solves the problem; bias toward deletion; flatten anything that takes more than three files to trace.
- Reader load: a new reader answers "where does X come from?" and "what can change X?" in under 30 seconds.
- Model the domain: a state machine over scattered booleans; a table over branching; a typed model over repeated shape assumptions.
- Idempotent operations: "what happens if this runs twice? if the previous run crashed halfway?"
- Comments stay (decision 4). They describe use and non-obvious why, and move with the code. A comment justifying a workaround is a signal the code is wrong; fix the code, keep the note until it is.
- A PR must not push a file from under 1,000 lines to over 1,000 lines without a very strong reason.

## Smells (labelled heuristics, never hard violations; Fowler via Matt's code-review)

Mysterious Name · Duplicated Code · Feature Envy · Data Clumps · Primitive Obsession · Repeated Switches · Shotgun Surgery · Divergent Change · Speculative Generality (delete it; inline until a real need shows) · Message Chains · Middle Man · Refused Bequest.

## Design red flags (pstack's architect)

Shallow module (large interface, little hidden) · Information leakage (one decision known in several places) · Temporal decomposition (modules by execution order instead of knowledge) · Pass-through method (forwards the same arguments, hides nothing).

## Suppressions

Every new or broadened `oxlint-disable`, `@ts-ignore`, `@ts-expect-error` needs an adjacent comment explaining why. The directive itself is not an explanation. A stale directive fails lint. A `# shellcheck disable=` in a hook or a skill script puts its reason in a second comment on the same line, because the directive is itself a comment and an adjacent one would be ambiguous.
```

### template/docs/factory918/DECISIONS.md, lines 82-85 of 85

```
| P22 | Who signs a comment | A comment the agent posts on a PR or a ticket ends with the model and harness (`Claude Fable 5.1 on Claude Code`), plus `approved by <name>` when the human approved it before posting; only an approved comment posted from the author's account is the author's words. `review-brief.sh` reads only the PR author's account for rounds and carry-forward | Manuel, 2026-09-18: a comment left by the orchestrator without human involvement is signed by the model on the harness; approved, it is signed by both; strangers' comments never reach a brief (#78 round 1). |
| P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
| P25 | One shell gate, carried by the template | `template/.github/shellcheck.sh` holds the ShellCheck version, both release checksums and the flags; a project gets it as `.github/shellcheck.sh` and the factory runs the template's copy. The severity is the default and `--external-sources` is on, so a lane's per-file run and CI's whole-set run give the same answer. A `disable=` directive carries its reason in a second comment on the same line; CI cannot check that a reason exists, the Standards axis does | A `run:` block in each workflow would put the pin in two files and the flags in three, and a project's CI cannot read the factory's files. SC2086 is info level, so a `--severity` floor would pass the class ticket #88 was written for; without `-x` the two spec-review tests report findings on one file that vanish on the whole set, which would make the playbook's "run it before the PR" sentence false. Ticket #88, 2026-09-22. |
```

### tests/poteto-mode/overlap.sh, lines 1-24 of 221

```
#!/usr/bin/env bash
# Runs template/.agents/skills/poteto-mode/scripts/overlap.sh against a temp clone with a bare
# origin and three open PRs (a fake gh on PATH answers `pr list` from FAKE_PRS, each PR carrying the
# ticket it closes, or with FAKE_PRS_COUNT generated PRs, `issue view` from FAKE_BODY, and fails the
# call FAKE_GH_FAIL names), and asserts the exit code and the output of each call in the order of
# the scenario table in the ticket's design: usage, no origin remote, a failing gh, a head with no
# merge base, more open PRs than the list holds, tokens that name no path
# or lie outside the repository, one PR shared, a deleted and a stale remote ref both fetched, a file
# a PR creates, a stacked PR reporting only its own commits, a glob and both directory forms,
# `## Diff` skipped, two PRs in ascending number, gos that cover and gos that do not, the base as the
# head that contains the others, a one-off go appended under a program's line, a dead program's
# line, a linked worktree reading the main checkout's file, --diff skipping the own PR and counting
# only the branch's own commits, a literal token under --diff, and the mode bit. The fixture root
# has a space, and from the third call on the script runs by the relative path the playbooks name.
# Exits 1 on the first miss.
# shellcheck disable=SC2016 # the backticks in the bodies below are the ticket's token delimiters, not command substitution
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.agents/skills/poteto-mode/scripts/overlap.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fx="$tmp/with space"
mkdir -p "$fx/bin"
cat > "$fx/bin/gh" <<'GH'
```

### tests/shellcheck/gate.sh, whole, 81 lines

```
#!/usr/bin/env bash
# Runs template/.github/shellcheck.sh, the shell gate, from a temp directory whose path has a
# space, and asserts one case per row of the table under ## Design on ticket #88: a clean file
# passes and is counted, a planted SC2086 is reported, a glob that matches no file is refused on
# stderr, a #!/bin/sh file keeps its POSIX checks, the zero-argument form from a project's root
# counts the project's hooks, skill scripts and the gate itself, and a platform the pin has no
# build for is refused when no ShellCheck is on PATH (a fake uname on PATH, ShellCheck hidden).
# The download is not exercised here; the fixture job in factory-ci.yml proves it. Exits 1 on the
# first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.github/shellcheck.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fx="$tmp/with space"
mkdir -p "$fx/bin" "$fx/project/.claude/hooks" "$fx/project/.agents/skills/x/scripts" "$fx/project/.github"
cd "$fx"
cat > clean.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
name="$1"
echo "hello $name"
SH
cat > unquoted.sh <<'SH'
#!/usr/bin/env bash
f="$1"
cat $f
SH
cat > posix.sh <<'SH'
#!/bin/sh
arr=(a b)
echo "${arr[0]}"
SH
cp clean.sh project/.claude/hooks/a.sh
cp clean.sh project/.claude/hooks/b.sh
cp clean.sh project/.agents/skills/x/scripts/c.sh
cp "$script" project/.github/shellcheck.sh
ln -s ../.agents/skills project/.claude/skills
cat > bin/uname <<'SH'
#!/bin/sh
case "$1" in -s) echo Plan9 ;; -m) echo mips ;; esac
SH
chmod +x bin/uname

n=0
fail() { echo "FAIL $1"; echo "  got:    $2"; echo "  wanted: $3"; exit 1; }
# run <args...>: the gate from the current directory, its exit in code, stdout in got, stderr in err.
run() { set +e; got="$(bash "$script" "$@" 2>"$tmp/err")"; code=$?; set -e; err="$(cat "$tmp/err")"; }
# check <name> <exit> <stdout> <args...>: both exact.
check() {
  local name="$1" want="$2" out="$3"; shift 3
  run "$@"
  if [ "$code" != "$want" ] || [ "$got" != "$out" ]; then fail "$name" "exit $code: $got$err" "exit $want: $out"; fi
  n=$((n + 1))
}
# check_err <name> <exit> <pattern> <args...>: the exit exact, stdout plus stderr holding the pattern.
check_err() {
  local name="$1" want="$2" pat="$3"; shift 3
  run "$@"
  if [ "$code" != "$want" ] || ! grep -qF -- "$pat" <<< "$got$err"; then fail "$name" "exit $code: $got$err" "exit $want with $pat"; fi
  n=$((n + 1))
}
# same <name> <wanted> <got>
same() { [ "$2" = "$3" ] || fail "$1" "$3" "$2"; n=$((n + 1)); }

check "1 a clean file" 0 "ShellCheck 0.11.0, files checked: 1" clean.sh
check_err "2 a planted SC2086" 1 "SC2086" unquoted.sh
check_err "3 a glob that matches nothing" 1 "no file matched nope/*.sh; the gate checked nothing" 'nope/*.sh'
same "3 the refusal is on stderr" "shellcheck.sh: no file matched nope/*.sh; the gate checked nothing" "$err"
same "3 nothing on stdout" "" "$got"
check_err "4 a #!/bin/sh file keeps its POSIX checks" 1 "SC3030" posix.sh
cd project
check "5 the zero-argument form from a project's root" 0 "ShellCheck 0.11.0, files checked: 4"
cd ..
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
same "6 the refusal names the pair" "shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand" "$err"
test -x "$script" || fail "7 the mode bit" "not executable" "executable"
n=$((n + 1))

echo "ok $n assertions"
```

### tests/spec-review/fake-gh.sh, whole, 24 lines

```
#!/bin/sh
# A gh for review-brief.sh: copied onto PATH as `gh` by tests/spec-review/review-brief.sh and by the
# CI fixture step. Fixtures are read from FAKE_GH_DIR, default the current directory (the script
# runs at the repository root):
#   pr.json     the PR, its author and comments; the script's own jq expression runs against it, so
#               the author filter is what is tested. Absent: a PR with no comments.
#   pr-error    printed to stderr with exit 1 in place of the comments (a failing gh).
#   FAKE_PR_BODY  the file whose text is the PR body for `gh pr view --json body`; unset or missing:
#               no PR for this branch.
# `gh issue view` answers with a fixed ticket body holding an acceptance-criteria list, and with the
# ticket author's comments already in the shape the script's jq expression prints (a comment by
# someone else is left out), so a run needs no fixture at all.
d="${FAKE_GH_DIR:-.}"
case "$*" in
  "pr view --json body"*) if [ -f "${FAKE_PR_BODY:-}" ]; then cat "$FAKE_PR_BODY"; else echo 'no pull requests found for branch "x"' >&2; exit 1; fi ;;
  "pr view"*)
    if [ -f "$d/pr-error" ]; then cat "$d/pr-error" >&2; exit 1; fi
    while [ "$1" != -q ]; do shift; done
    if [ -f "$d/pr.json" ]; then exec jq -r "$2" "$d/pr.json"; fi
    echo '{"author": {"login": "me"}, "comments": []}' | exec jq -r "$2" ;;
  *"--json body"*) printf '## What to build\n\nWhat to build: the ticket body\n\n## Acceptance criteria\n\n- [ ] The brief carries the ticket body.\n' ;;
  *"--json author,comments"*) printf '### 2026-09-17\n\nuser: the hook stays in bash.\n\n### 2026-09-18\n\nuser: the count is Act on plus Ask.\n\n' ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
```

### tests/spec-review/layout.sh, whole, 27 lines

```
# Sourced by the spec-review tests. layout <project|factory> <dir>: the spec-review skill copied
# into a new git repository at <dir>, laid out the way that repository holds it, and committed.
# A project (what `factory918 apply` leaves) has `.agents/skills/spec-review/`, `.claude/hooks/`
# with an executable hook, and `.claude/skills -> ../.agents/skills`. The factory has the same
# under `template/`, with `.claude/skills` and `.claude/hooks` linking there. Sets `skill`, the
# copy of the skill to run, and `hooks`, the hooks directory a cross-cutting commit touches.
# shellcheck shell=bash disable=SC2034 # sourced by the two spec-review tests, so it has no shebang; hooks and skill are read by the sourcing test
source_skill="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)/template/.agents/skills/spec-review"
layout() {
  local base link
  case "$1" in
    project) base="$2"; hooks=.claude/hooks; link=../.agents/skills ;;
    factory) base="$2/template"; hooks=template/.claude/hooks; link=../template/.agents/skills ;;
  esac
  mkdir -p "$base/.agents/skills" "$base/.claude/hooks" "$2/.claude"
  cp -R "$source_skill" "$base/.agents/skills/spec-review"
  printf '#!/bin/sh\nexit 0\n' > "$base/.claude/hooks/noop.sh"
  chmod +x "$base/.claude/hooks/noop.sh"
  ln -s "$link" "$2/.claude/skills"
  [ "$1" = project ] || ln -s ../template/.claude/hooks "$2/.claude/hooks"
  skill="$base/.agents/skills/spec-review"
  git -C "$2" init -q
  git -C "$2" config user.email test@factory918.invalid
  git -C "$2" config user.name test
  git -C "$2" add -A
  git -C "$2" commit -qm "the layout"
}
```

### tests/spec-review/review-brief.sh, lines 1-28 of 441

```
#!/usr/bin/env bash
# Runs review-brief.sh twice, in a temp repo laid out as a project and in one laid out as the
# factory (tests/spec-review/layout.sh), each time the copy of the skill that repo holds, and
# asserts that each brief carries the report shape review-comment.sh enforces: the definition
# sentence, Manuel's five sentences, every heading name, the item format, the step rule and the
# count rule. The fake gh (tests/spec-review/fake-gh.sh) on PATH supplies the ticket body and the
# ticket's comments, and the PR's earlier review comments when a fixture file names them (no PR
# otherwise), so the Spec brief is written and the round is 1 unless the comments or --round say
# otherwise. Only the judgment items that cite a decision carry into both briefs, from every earlier
# comment, each line once; the round is one more than the highest `round: N of 3` among the comments,
# so a rebuilt comment does not advance it; a fourth round is refused before any state is written;
# a gh failure other than "no pull requests found" is printed and the run goes on. A diff touching
# a cross-cutting path is briefed with its blast-radius grounding (--blast-radius FILE, else the PR
# body's section) before the diff, and refused without one. The source SKILL.md, step 4, must carry
# the definition, the five sentences, the heading bullets, the step rule, the count rule, the
# settled paragraph and the blast-radius paragraph word for word, so the skill and the script
# cannot drift apart. Exits 1 on the first miss.
# shellcheck disable=SC2016 # the expected strings below are the Markdown the script emits; the backticks and $ are literal
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
# shellcheck source-path=SCRIPTDIR source=layout.sh
. "$here/tests/spec-review/layout.sh"
command -v jq >/dev/null || { echo "FAIL: jq is needed to play gh pr view"; exit 1; }
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/bin"
cp "$here/tests/spec-review/fake-gh.sh" "$tmp/bin/gh"
PATH="$tmp/bin:$PATH"
```

### tests/spec-review/review-comment.sh, lines 11-20 of 546

```
# shellcheck source-path=SCRIPTDIR source=layout.sh
. "$here/tests/spec-review/layout.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
dir=.scratch/review/x
state=.claude/state/review

n=0
code=0
out=""
```

### tests/spec-review/review-comment.sh, lines 93-125 of 546

````
# A Would-break or Fails-open item without a `Documented step:` line is refused by name; a line
# inside a quoted hunk does not count; a body sentence is not the item's title.
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
printf '## Would break\n\n1. **One.** a\nDocumented step: ticket line\nResult: r\n\n## Fails open\n\n2. **Open, silently.** the guard returns. More.\n\n```sh\nDocumented step: inside the hunk\n```\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Fails-open item without a Documented step line, the fenced one not counting"
printf '## Would break\n\n1. **One.** a\n\n## Fails open\n\n2. **Open.** o\nDocumented step: ticket line\n\n## Standards breaches\n\n3. **Breach.** b\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '1. **One.**' under '## Would break' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Would-break item without a Documented step line"

empty_standards > "$dir/standards-report.md"
echo brief > "$dir/spec-brief.md"
refuse "$dir/spec-report.md is missing; wait for the Spec reviewer" "Spec brief without a Spec report"

printf '## Would break\n\n## Fails open\n\n## Not asked for\n\n## Walk\n\nhard findings: 0\n' > "$dir/spec-report.md"
refuse "$dir/spec-report.md has the headings [Would break|Fails open|Not asked for|Walk]; the shape is [Walk|Would break|Fails open|Not asked for], in that order, each holding numbered items or nothing" "Spec report headings out of order"

empty_spec > "$dir/spec-report.md"
refuse "$dir/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun" "no judgment"

printf '## Act on\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md has the headings [Act on|Consider|Noted|Dismissed]; the shape is [Act on|Ask|Consider|Noted|Dismissed], in that order, each holding numbered items or nothing" "judgment without Ask"

printf '## Would break\n\n1. **One.** a\nDocumented step: t\n\n## Fails open\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
printf '## Walk\n\n1. step one\n2. step two\n\n## Would break\n\n## Fails open\n\n1. **Edge.** c\nDocumented step: t\n\n## Not asked for\n\nhard findings: 1\n' > "$dir/spec-report.md"
printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md has 1 items; the reports have 3 (Standards 2, Spec 1). Every report item appears exactly once in the judgment" "judgment short of the reports"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S4] **Two.** later\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [S4]; the reports have 2 Standards items and 1 Spec items" "reference to an item that does not exist"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S1] **One again.** twice\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [S1]; the reports have 2 Standards items and 1 Spec items" "repeated reference"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. **Two.** no reference\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
````

### tests/spec-review/review-comment.sh, lines 511-512 of 546

````
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
fenced_twin 'a ```sh fence quoted inside a ``` block' '```
````

Not carried, over the pack's 65536 bytes: AGENTS.md whole; SOURCES.md whole; docs/agents/ledger.md whole; factory918.sh lines 236-292; template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md whole. Read these at HEAD from the repository.

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

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

An edge case that proceeds silently fails open: file it under `## Fails open`.

The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing. The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk, saying what the diff does at that risk, and saying whether the diff honors the disposition the risk's line ends with (for `fixed: <sha>`, whether that commit fixes the risk; for `accepted: <reason>`, whether the reason holds for this diff); a risk line is a walk line and counts nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3].

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

Write your report to `.scratch/review/ab47eb9/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
