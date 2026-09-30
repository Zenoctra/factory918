`review-brief.sh` checks a ticket's writer flags, but only under a line that is exactly `### Writer flags <YYYY-MM-DD>`. A flag list it could not read looked like no list, so the review went ahead with the flags unchecked.

## Why

PR #136 (ticket #108) refuses a review while a writer flag has no disposition. When the list is hidden, the check prints nothing and passes. Some ways to hide it: an unclosed fence above the heading, the list inside a quote, or a hyphenated or singular heading (`### Writer-flags`, `### Writer flag`). Ticket #139 asks for one count rule that covers all of them, not a parser for each shape.

## Scope

- `template/.agents/skills/spec-review/scripts/review-brief.sh`: after the existing flag check prints nothing, one awk pass collects the lines that read as a writer flags heading. Such a line is two or more `#` whose text holds `writer` and, later on the line, `flag`, in any case. Spaces, `>` quote markers and list markers may come before the `#`. A second run of the existing `$disposed` awk, with `-v at=1`, prints the line number of each flag it reads, and each read flag belongs to the nearest heading line at or above it. Any heading line with no flag removes the review directory, prints the refusal naming each such heading line, and exits 1. The count is per heading line, since the root's verification found that a second writer's hidden list passed behind the first list's flags. The header comment gets one sentence on the rule.
- `tests/spec-review/review-brief.sh`: table D from the ticket's `## Testing decisions` (D1 to D18, and D11b), and one assertion that pins the SKILL.md sentence word for word, plus the `rz8` helper. #108's C6/f assertion moves to the new refusal.
- `template/.agents/skills/spec-review/SKILL.md` step 1, through `patches/mattpocock/spec-review.SKILL.md.patch`: one sentence names the new refusal. `SOURCES.md` patch 6 names it too.
- `docs/knowledge/core/DECISIONS.md`: row P139, and its generated copies.

## Tradeoffs

- #108's cell C6/f moves from a brief to the refusal. That body has the opener and a bare line inside a closed fence. #139's criterion 1 refuses a heading inside a fence, and the ticket is the later spec. No other cell of #90's, #93's, #106's, #107's or #108's tables changes, and #137's criteria are untouched.
- The refusal header still says no flag could be read "from its body" when another list was read. The heading lines it names are the exact answer.
- A heading such as `## Writer flag handling` with no list is refused. The message says which heading form the check reads. A one-`#` line never counts, since in a ticket it is a code comment more often than a heading, and a level-one `# Writer flags` is already a #136 near-miss.
- The guard runs only when #136's check printed nothing. Every body #136 already refuses keeps its exact message.

## Blast Radius

Only reviews that pass `--ticket`, or whose commits name a ticket, reach the new code, and only when the body holds a writer flags heading line. A body with no such line takes the same path as before: the guard's first test is empty and nothing else changes. The refusal fires before any state is written, like the other refusals. Of the 12 program tickets I checked (#90 to #139), only #108 has a heading line, and its list reads 15 flags, so it still briefs.

## Overlap

```
go: autopilot-stack
#143 feat/reviewer-eval-rerun: docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
```

Both PRs append a Provisional row; the rows are independent.

## Review

Three `spec-review` rounds. Each found a heading shape the match missed: a list marker before the hashes (round 1), a one-hash code comment refused and a decorated heading missed (round 2), a possessive or plural heading (round 3). Each widened the one match and added table D rows; the ticket's `## Testing decisions` carries a dated amendment per round. Round 3 closed with `act-on items: 0`, its fixes marked. After the root's verification, the count became per heading (D10 to a refusal, D17, D18); that fix closes a Fails-open item, not a Would-break one, so P20 owes no fourth round.

## Verification

- Criterion 1 (a heading anywhere with zero flags read is refused: exit 1, the heading named, no state): cells D2 to D7, D10, D11, D11b, D13 to D16, D18 and C6/f in `tests/spec-review/review-brief.sh` assert exit 1, the exact stderr, and no `.claude/state/review` or `.scratch/review/<id>`. At the tests commit f455c8f with the old script, C6/f and D2 to D7 failed (exit 0), in both suite passes; D11 and D11b failed at f41ddf3 before 833fcae; D12, D13 and D14 failed at 416a175 before 1f26c5e; D15 and D16 failed at a68ef03 before f494d2b; D10 and D18 failed at 197c676 before 659f508.
- Criterion 2 (a body with no heading briefs byte for byte as at #136's head): at 5f0c725, before the three review rounds widened the match, the writer lane ran the e710e99 script and this head with the suite's fake gh on #108 C7/f's body and on the fake's fixed body. Both exit 0 with empty stderr, and `cmp` and `diff -r` found the briefs, the review directory, `.claude/state/review`, stdout and stderr identical. e710e99 is #140's head, which contains #136's head. At the head, D9 and D12 (a fenced one-`#` code comment) assert the brief in the suite, and the final match finds no line in the live bodies named below except #108's list heading; the harness was not rerun at the head.
- Criterion 3 (every heading with a readable list behaves as before): D1, D17 (two readable lists) and A8, and every other cell of #108's tables, pass unchanged.
- Criterion 4 (no shape-specific parsing): the diff adds one line match and one count. It names no fence or quote.
- `bash tests/spec-review/review-brief.sh`: ok 1876 assertions at 8aa660a. CI run 35932109587 at 8aa660a: success.
- The final match (review round 3), run by hand over the bodies of #90, #93, #103, #105 to #111, #137 and #139, matches only #108's `### Writer flags 2026-09-23`.
- `./factory918.sh sync` leaves `git status` clean at 8aa660a. `bash tests/knowledge/provisional-ids.sh`: 26 passed. `bash tests/spec-review/no-stale-wording.sh`: ok.
- `bash .github/shellcheck.sh` on the full AGENTS.md set: 24 files, exit 0. `bash tests/spec-review/review-comment.sh`: ok 298. `bash tests/hooks/delegation.sh`: ok 55. `bash tests/poteto-mode/overlap.sh`: ok 57.
- `python3 tools/build_knowledge.py` leaves `git status` clean after the records commit, and `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`.
- mawk was not run locally. CI on Ubuntu runs the suite under mawk.

Closes #139
🤖 Generated with [Claude Code](https://claude.com/claude-code)
Claude Opus 5.5 on Claude Code
