# Standards review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

8b47278 Refuse the --diff record on a detached HEAD
ebf7e96 Treat a git error in the ancestor test as a failure, not as "no"
432397e Record that overlap.sh is ours and kept through sync
aac4dc6 Make the one-off go name the ticket the printed PR closes
46a0f1d Quote the program file path in the overlap test
661b8e1 Document the go command with bare ticket numbers
6b027ef Record the overlap rule and the go line as P24
67903cf Say in the playbook and the manual that a PR's line is its own commits
9439fb9 Diff each open PR from the PR under it, so a stacked PR reports only its own commits
b7ea7ed Record the program's go line when autopilot-stack starts
4839da7 Tell the manual's reader how two tickets relate before running both
d83b310 Route several tickets by how their files relate
b699cc6 Make the Ticket playbook run the overlap check before it branches
cce8b80 Add the overlap check the Ticket playbook runs before it branches
4de9c91 Add the test for the overlap check before its script
4da48ab Record the script path the brief got wrong
e79a411 Record the seven re-reviews mis-estimate in the ledger

## Changed files

 .github/workflows/factory-ci.yml                   |   4 +-
 AGENTS.md                                          |   1 +
 SOURCES.md                                         |   2 +-
 docs/agents/ledger.md                              |   2 +
 docs/knowledge/INDEX.md                            |   4 +-
 docs/knowledge/core/DECISIONS.md                   |   3 +-
 docs/knowledge/core/MANUAL.md                      |  22 ++-
 factory918.sh                                      |   2 +-
 .../poteto-mode/playbooks/autopilot-stack.md.patch |   7 +-
 template/.agents/skills/factory918/SKILL.md        |   4 +-
 .../poteto-mode/playbooks/autopilot-stack.md       |   2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |   4 +-
 .../.agents/skills/poteto-mode/scripts/overlap.sh  | 116 +++++++++++
 template/docs/factory918/DECISIONS.md              |   1 +
 template/docs/factory918/MANUAL.md                 |   4 +-
 tests/poteto-mode/overlap.sh                       | 213 +++++++++++++++++++++
 16 files changed, 367 insertions(+), 24 deletions(-)

## Blast radius

The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence.

### What it does

Run 1's three prose surfaces still hold: `docs/knowledge/core/MANUAL.md:79-81` (copied to `template/docs/factory918/MANUAL.md:60-62`), the router rows `template/.agents/skills/factory918/SKILL.md:55-56`, and `poteto-mode/playbooks/ticket.md`. Every session kind reads the router row (`session-mandate.md:2`); `ticket.md` runs interactively and in every owner lane (`autopilot-stack.md:5`).

New: `template/.agents/skills/poteto-mode/scripts/overlap.sh`, under a vendored skill, kept across `sync` by `factory918.sh:381`; its test `tests/poteto-mode/overlap.sh`, wired into `factory-ci.yml:26-27`, the syntax loop widened to `poteto-mode/scripts/*.sh` (`:19`). `ticket.md:5` step 1 runs `overlap.sh N` after the dirty check and before the ticket is read: it force-fetches every open PR head (`overlap.sh:52-59`), diffs each against the PR under it or `origin/main` (`:63-73,87`), and exits 1 on a shared path no go covers (`:91-92,103`). `ticket.md:12` step 8 runs `--diff` and pastes the output as `## Overlap`. `autopilot-stack.md:7` step 3, via its patch, runs `overlap.sh go`, the only writer (`:22-27`) of `.claude/state/program`, resolved through `--git-common-dir` (`:20`). No step is renumbered.

### The one fact it's safe because of

Nothing parses the prose surfaces; the script's only callers are `ticket.md:5,12` and `autopilot-stack.md:7`; its only writes are `.claude/state/program` and `refs/remotes/origin/*`. Rung 4.

Grep (`*.sh *.py *.yml *.ts` under `tests/ tools/ .github/ factory918.sh template/.claude template/.agents/skills/spec-review/scripts`, research excluded) for `overlap.sh|state/program|Several unblocked tickets`: only `tests/poteto-mode/overlap.sh`, `factory-ci.yml:26-27`, `factory918.sh:381`. Readers of the changed paths: `factory918.sh:275-276` (`[ -f ]`), `build_knowledge.py:39`, `review-brief.sh:188` (path glob), `tools/bootstrap/` (frozen). No hook names the script or the file (grep of `template/.claude/hooks/*.sh`: nothing). `.claude/state/` is ignored here (`.gitignore:7`) and in projects (`template/.gitignore.factory:5`, appended by `factory918.sh:145`, checked at `:266`). Proof D: `refs/heads` unchanged across a run; only `origin/feat-a` moved.

Checks in a throwaway worktree of the writer's branch, removed after:

```
bash -n factory918.sh                                     exit 0
bash tests/poteto-mode/overlap.sh                         ok 51 assertions      exit 0
bash tests/hooks/delegation.sh                            ok 55 assertions      exit 0
bash tests/spec-review/review-brief.sh                    ok 334 assertions     exit 0
bash tests/spec-review/review-comment.sh                  ok 82 assertions      exit 0
bash tests/spec-review/no-stale-wording.sh                ok: no stale wording  exit 0
python3 tools/check_knowledge.py                          knowledge ok: 118 files  exit 0
python3 tools/build_knowledge.py && git status --short    knowledge files: 118, status empty  exit 0
./factory918.sh sync && git status --short                vendored: 72 skills, status empty  exit 0
```

MANUAL is 174 lines, 155 body: 65 under `build_knowledge.py:29` (220), 66 under `check_knowledge.py:16` (240).

### Risks

1. **A fork PR stops every ticket (interactive session, owner lane).** `overlap.sh:57` fetches `refs/heads/<headRefName>` from origin; a cross-repository PR's branch is not there, `git fetch` fails, the trap (`:17`) exits 2 for every `overlap.sh N` until that PR closes. Proven: a fake `pr list` naming `contrib-branch` gives `fatal: couldn't find remote ref refs/heads/contrib-branch`, exit 2. Likely wherever outsiders open PRs, never in Manuel's own repos; cost is a blocked step 1 with a clear stderr. Check: `gh pr list --json isCrossRepository` (the field exists) and skip, or fetch `pull/N/head`.
2. **No `gh` on PATH exits 2 (interactive session).** `:44` calls `gh` with no `command -v`; proven: `gh: command not found`, exit 2. Step 2 would have failed the same way. Low cost.
3. **`--diff` on detached HEAD reports the own PR (owner lane).** `:75` gives an empty `cur`, so `:86` skips nothing; proven: exit 1, `#1 feat-a: a.md`. Low: owners work on branches (`opening-a-pr.md:5`).
4. **`--limit 100` (`:52`).** PR 101+ is invisible, silently. Unlikely here.

### Cleared

- No origin: `:37-41` prints `base: main`, exit 0 (test 4). `origin/main` behind: `:54` force-fetches it.
- Linked worktree: `:20` reads the common dir's file (test 29); hooks read `.claude/state/mode` and `review` by project dir (`mode.sh:32`, `delegation.sh:25-26`), never the program file.
- Hooks: `block-dangerous-git.sh:7-17` sees only `overlap.sh N`; `delegation.sh:46` classes `.claude/state/*` untracked.
- `factory-start`, `factory-doctor`, `knowledge` SKILL.md: no `overlap|program|autopilot|ticket playbook|state/` hits.
- Review in progress: `review-brief.sh:188` matches `factory918/SKILL.md`, so the PR body needs `## Blast Radius`; `:196-197` ends it at the next `## `, so `## Overlap` after it is safe (run 1 proof).
- Stale refs: nothing relies on them; `factory918.sh:199`, `make-pr-easy-to-review/SKILL.md:24`, `multi-phase-plan.md:76` fetch first.
- `spec-review`: `review-comment.sh:133-141` reads its own headings only.
- `sync` keeps the script (`factory918.sh:381`) and reapplies the patch (`patches/series:3`); the widened CI syntax loop passes.

### Before you merge

```
git worktree add --detach <scratch>/wt42 wt/42-writer-v2 && cd <scratch>/wt42
bash -n factory918.sh; bash tests/poteto-mode/overlap.sh; bash tests/hooks/delegation.sh
bash tests/spec-review/review-brief.sh; bash tests/spec-review/review-comment.sh; bash tests/spec-review/no-stale-wording.sh
python3 tools/check_knowledge.py; python3 tools/build_knowledge.py && git status --short
./factory918.sh sync && git status --short
```

Risk 1 repro: a fixture clone with `.claude/skills` linked to the branch's skills, a fake `gh` listing a `headRefName` absent on origin, `overlap.sh 9`: expect exit 2.

## Diff

The diff is 578 lines; read it from `.scratch/review/origin_main/diff`.

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

Write your report to `.scratch/review/origin_main/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
