# Standards review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

a0b809a Make the spec-review tests executable
3fe24a9 Point the doctor at step 6, list the two spec-review tests, and soften the spec reviewer row
1ab072c Let review-comment.sh rerun on a finished review, and give Fix-alongside items a bucket
41104d7 Record what a review counts and that the orchestrator judges before the count
1a50d76 Add a spec reviewer row so the Spec axis runs cheaper than the writer
8eb32c3 Give spec-review a Judge step between the reports and the count
e730367 Count only what would break, and only after the orchestrator has judged it

## Changed files

 .github/workflows/factory-ci.yml                   |   6 +-
 AGENTS.md                                          |   2 +
 SOURCES.md                                         |   2 +-
 docs/knowledge/INDEX.md                            |   4 +-
 docs/knowledge/core/DECISIONS.md                   |   6 +-
 docs/knowledge/core/MANUAL.md                      |   9 +-
 factory918.sh                                      |   2 +-
 machine/pstack-models.fable.md                     |   1 +
 machine/pstack-models.opus.md                      |   1 +
 patches/mattpocock/spec-review.SKILL.md.patch      |  55 +++--
 template/.agents/skills/spec-review/SKILL.md       |  42 +++-
 .../skills/spec-review/scripts/review-brief.sh     |  28 ++-
 .../skills/spec-review/scripts/review-comment.sh   | 109 +++++++--
 template/docs/agents/models.md                     |   5 +-
 template/docs/factory918/DECISIONS.md              |   4 +-
 template/docs/factory918/MANUAL.md                 |   1 +
 tests/spec-review/review-brief.sh                  |  64 ++++++
 tests/spec-review/review-comment.sh                | 249 +++++++++++++++++++++
 18 files changed, 527 insertions(+), 63 deletions(-)

## Diff

The diff is 874 lines; read it from `.scratch/review/main/diff`.

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

A hard finding is wrong behavior in normal use: a command, hook, script or documented flow does something other than what the ticket or its own documentation says it does, on the path a user takes.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that produces wrong behavior in normal use. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Write your report to `.scratch/review/main/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and nothing else.
