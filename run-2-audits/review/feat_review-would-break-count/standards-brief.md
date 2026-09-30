# Standards review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

fd7996e Record that a rule was added to a ticket before the problem was put to Manuel
fd6c805 Close a fence only on its own character with no info string, and pin the heading bullets (#79)
04e5a2a Parse the carried judgment's fences by the CommonMark rule and refuse a misnumbered judgment
d7860b0 Record the three-round limit, the carry-forward rule, and the #74 comment the reviewers never saw
98ba213 Run a review three rounds at most, carry only what cites a decision, and read the ticket author's comments as spec

## Changed files

 SOURCES.md                                         |   6 +-
 docs/agents/ledger.md                              |   2 +
 docs/knowledge/INDEX.md                            |   2 +-
 docs/knowledge/core/DECISIONS.md                   |   6 +-
 patches/mattpocock/spec-review.SKILL.md.patch      |  45 +++--
 patches/pstack/babysit/SKILL.md.patch              |   2 +-
 .../pstack/poteto-mode/playbooks/babysit.md.patch  |   2 +-
 template/.agents/skills/babysit/SKILL.md           |   2 +-
 .../skills/poteto-mode/playbooks/babysit.md        |   2 +-
 template/.agents/skills/spec-review/SKILL.md       |  34 +++-
 .../skills/spec-review/scripts/review-brief.sh     |  81 ++++++++-
 .../skills/spec-review/scripts/review-comment.sh   |  46 +++--
 template/docs/agents/review-ladder.md              |   2 +-
 template/docs/factory918/DECISIONS.md              |   4 +-
 tests/spec-review/review-brief.sh                  | 201 +++++++++++++++++++--
 tests/spec-review/review-comment.sh                | 156 +++++++++++++---
 16 files changed, 500 insertions(+), 93 deletions(-)

## Diff

The diff is 1093 lines; read it from `.scratch/review/feat_review-would-break-count/diff`.

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

Write your report to `.scratch/review/feat_review-would-break-count/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and nothing else.
