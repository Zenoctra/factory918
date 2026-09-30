# Fix brief 4, ticket #109, review round three's Act on items

Repository Zenoctra/factory918. Read AGENTS.md first. In your own worktree run `git fetch origin`, then create branch
`wt/109-fix4` from `origin/feat/eco-tier` (head 259448e, PR #135). Commits go on top; never rewrite existing
commits. Touch only `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, no patch) and
`docs/knowledge/core/MANUAL.md` (then `python3 tools/build_knowledge.py`, which regenerates
`template/docs/factory918/MANUAL.md`).

Round three's reports (read the two items quoted here; the review is at 259448e):
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a2ce71454fd0910f0/.scratch/review/origin_main/standards-report.md`

## Fixes, each its own commit

1. [S1, Would break] `ticket.md` step 0 "The tier", closing paragraph: the count "one runner and one judge" becomes
   "one runner and one judge per architect round (a Design hole restart runs another)". Keep the rest of the
   sentence.
2. [S2, Fails open] `ticket.md` step 0 "The tier": after "the brief wins over the file, because a run never changes
   tier halfway.", add "A digest or brief with no `Tier:` line is `safe`." Then the replacement-owner sentence reads
   against it unchanged.
3. [round two's Consider, the owner's call] `ticket.md` step 0 "The tier": the second read command is unquoted, and a
   checkout path with spaces (this repository's has them) makes it fail silently to `safe`. Write it as
   `cat "<that dir>/../.claude/state/tier"` with the quotes, and add after the junk-value sentence: "A read that fails
   is `safe` too, and the digest says it failed."
4. [S3, Fix alongside] `MANUAL.md`, the sentence after the `## Models and cost` table becomes a pointer, so the list
   is stated once: "The tier (Execution, **Safe and eco.**) decides how many of these roles a ticket launches; the
   list is Ticket step 0, "The tier"." Then `python3 tools/build_knowledge.py` and commit what it regenerates.

Plain-sentence commit messages ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

Checks after the last commit: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`,
`bash tests/hooks/delegation.sh`, `./factory918.sh sync` then status clean, `python3 tools/build_knowledge.py` then
status clean, `python3 tools/check_knowledge.py`. Write your report with Bash to exactly
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/fix4/report.md`: the
branch, `git log --oneline origin/feat/eco-tier..HEAD` with each commit's SHA, the item each commit fixes, and each
check's outcome. Push nothing. Launch no agents. Reply with only the report path.
