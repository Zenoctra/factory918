# spec-review round 1, PR #129 (ticket #111)

reviewed: c183a362e73b88758bdf468a4169619158b47c1d (fixed point f58308b)
comment: https://github.com/Zenoctra/factory918/pull/129#issuecomment-5795711852

round: 1 of 3
act-on items: 0

## Act on

None.

## Ask

None.

## For reference (not counted)

- Consider [S1]: tests/show-me-your-work/check-trail.sh cds into "$tmp/with space" and passes only relative paths, so no absolute or spaced path ever reaches the script's arguments (CODING_STANDARDS.md Bash rule: test with absolute paths, from another directory). Nothing breaks; the script quotes every path. Fix if wanted: add one case that passes the trail and transcript as absolute paths under the spaced directory, run from another directory.
- Noted [S2]: check-trail.sh awk prints "line 1: header is not the template's" in both the NR == 1 rule and the END empty-file branch.
- Noted [S3]: the skill's check-trail paragraph (template/.agents/skills/show-me-your-work/SKILL.md) names exits 0, 1, 2 but not 64.
