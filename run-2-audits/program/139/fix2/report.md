# #139 fix lane, review round 2

Branch `wt/139-fix2`, from `origin/feat/unreadable-writer-flags` at 6128acc; not pushed. Worktree: `.claude/worktrees/agent-aa844324c2f940c80`. Head 4cc51f5.

## Commits

- 416a175 Test that the writer flags guard skips code comments and counts decorated headings. Adds D12, D13 and D14 after D11b in `tests/spec-review/review-brief.sh` (body8, go8 nc P, briefed8 / refused8 + rz8), as the second 2026-09-23 amendment gives them.
- 1f26c5e Count only two-hash writer flags headings, with any decoration around the words. Act on 1, 2, 3 and 5. The guard's match in `template/.agents/skills/spec-review/scripts/review-brief.sh` is now
  `tolower($0) ~ /^([ \t>]|[-*+]|[0-9]+[.)])*##+[^a-z]*writer[^a-z]*flags?([^a-z]|$)/`
  (no POSIX classes). Still one line match over the raw body. The guard comment names the grammar and why two `#`; the header comment adds "decorated" (lines rewrapped to the file's width).
- 4cc51f5 Describe the writer flags heading in spec-review step 1 by its general form. SKILL.md step 1 now says "a line of two or more `#` whose text reads as writer flags (in any case or spelling, decorated, fenced, quoted, or after a list marker)". Patch `patches/mattpocock/spec-review.SKILL.md.patch` regenerated with `diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md template/.agents/skills/spec-review/SKILL.md` (a one-line change in the patch). SOURCES.md patch 6 clause changed from "a writer flags heading line in any form" to "a writer flags heading line of two or more `#`, in any form", since a single `#` no longer counts.

DECISIONS.md untouched (Act on 4 is the owner's).

## Failed before the script change (at 416a175)

The suite stops at the first failure, so D13 and D14 were confirmed with temporary copies of the suite with the earlier new rows removed (copies deleted, never committed).
- D12: `exit 1, wanted 0`; stderr was the #139 refusal naming `  # writer flags are parsed here`.
- D13: `exit 0, wanted 1, the refusal and no state`.
- D14: `exit 0, wanted 1, the refusal and no state`.

## Verification at 4cc51f5

- `bash tests/spec-review/review-brief.sh`: ok 1866 assertions (D1 to D11b and every other cell unchanged).
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`: exit 0, 26 files.
- `bash tests/spec-review/no-stale-wording.sh`: ok, no stale wording.
- `bash tests/spec-review/review-comment.sh`: ok 298 assertions.
- `./factory918.sh sync` (run alone), then `git status --porcelain`: empty.
- `python3 tools/check_knowledge.py`: knowledge ok, 119 files.
- New match by hand over the bodies of #90 #93 #103 #105 #106 #107 #108 #109 #110 #111 #137 #139: one line matches, #108's `### Writer flags 2026-09-23`. No other body has a matching line.

## Act on, for the owner

1. Act on 4: rewrite the DECISIONS.md P139 row's grammar sentence to the final match (two or more `#`, list markers and `>` quotes before, any non-letters between the `#` run and `writer` and between `writer` and `flag`).
2. Push `wt/139-fix2` onto `feat/unreadable-writer-flags` (fast-forward from 6128acc) and run round 3.
