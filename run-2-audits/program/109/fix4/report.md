# Fix 4 report, ticket #109, PR #135

Branch `wt/109-fix4`, from `origin/feat/eco-tier` at 259448e, in worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aca5c33cff4e4b2a4`. Nothing pushed, no agents launched, no existing commit rewritten.

## Commits (`git log --oneline origin/feat/eco-tier..HEAD`)

    9454e38 Point the MANUAL's tier sentence at Ticket step 0 instead of restating the eco list.
    d9a4227 Quote the tier file path, since a checkout path with spaces made the read fail silently to safe, and have the digest report a failed read.
    6fab5bd Read a digest or brief with no Tier line as safe, so the tier fails closed.
    1756050 Count one architect runner and judge per round in the eco launch list, since a Design hole restart runs another.

- 1756050 fixes item 1 [S1]: ticket.md step 0 "The tier", the count now reads "one runner and one judge per architect round (a Design hole restart runs another)", rest of the sentence kept.
- 6fab5bd fixes item 2 [S2]: "A digest or brief with no `Tier:` line is `safe`." added after "because a run never changes tier halfway."; the replacement-owner sentence is unchanged.
- d9a4227 fixes item 3 [round two's Consider]: the read is now `cat "<that dir>/../.claude/state/tier"`, and "A read that fails is `safe` too, and the digest says it failed." follows the junk-value sentence.
- 9454e38 fixes item 4 [S3]: docs/knowledge/core/MANUAL.md, the sentence after the Models and cost table is now the pointer "The tier (Execution, **Safe and eco.**) decides how many of these roles a ticket launches; the list is Ticket step 0, "The tier"." The commit includes the regenerated template/docs/factory918/MANUAL.md.

Each commit touched one file (two for 9454e38, source plus regenerated copy), checked with `git diff --stat` before committing.

## Checks, after the last commit

- ShellCheck at the pin over the brief's globs: exit 0, "ShellCheck 0.11.0, files checked: 24".
- `bash tests/hooks/delegation.sh`: exit 0, "ok 76 assertions".
- `./factory918.sh sync`: "vendored: 72 skills", then `git status --short` empty.
- `python3 tools/build_knowledge.py`: exit 0, then `git status --short` empty.
- `python3 tools/check_knowledge.py`: "knowledge ok: 119 files".
