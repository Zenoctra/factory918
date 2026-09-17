# Coding standards for the factory itself

Read at review time by `spec-review`'s Standards axis. Skip anything the CI gate already enforces. The template's `CODING_STANDARDS.md` is for projects; this one is for the bash, Python and markdown this repository is made of.

## Bash (`factory918.sh`, the hooks)

- `set -euo pipefail` at the top; one function per subcommand; the dispatch `case` at the bottom.
- Quote every path. Paths here contain spaces.
- Prefer commands that behave the same on macOS and Linux. Where BSD and GNU differ (`sed -i`, `date -d`, `readlink -f`), either use a form both accept or branch on `command -v`.
- Structured edits to JSON or YAML go through `jq` or a short `python3` heredoc, never `sed`.
- Every doctor check carries its fix as the third argument. A `FAIL` with no fix is a bug.
- A failure a gate depends on is reported, never swallowed with `|| true`. `|| true` is for output the user does not need.
- Test a command the way a user types it: absolute paths, from another directory, through the installed symlink.

## Python (`tools/`, heredocs in the CLI)

- Standard library only. One script per job; each exits 1 on any miss and says what missed.
- Edits to prose files assert on the exact text they replace, so a stale anchor fails loudly instead of silently doing nothing.

## Markdown (docs, skills, both `AGENTS.md`)

- Written with `/writing-for-agents` when an agent reads it, `/technical-writing` and `/unslop` when a person does. One Diátaxis mode per file.
- `docs/knowledge/core/` is the source; everything under `docs/knowledge/spec/`, `pages/`, `notes/` and `template/docs/factory918/` is generated and never edited.
- A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby.

## Commits and pull requests

- One concern per PR. A commit message says the problem, then the fix; the PR body adds a Verification section naming what ran.
- Anything verified against a tool version gets a dated line in `docs/M0-findings.md`; a surprise gets a line in `docs/agents/ledger.md`; a choice gets a Provisional row in `DECISIONS.md`.
