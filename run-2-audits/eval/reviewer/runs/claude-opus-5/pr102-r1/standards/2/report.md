# Standards report

## Would break

## Fails open

## Standards breaches

1. **The skill still reads the round from `of 3` alone.** `review-brief.sh` now matches `/^round: [0-9]+ of [35]$/`, and its own header comment says so ("`of 5` past three"), but step 1 of the skill an agent follows still describes only the `of 3` form. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it". A reader of the skill would think a `round: 4 of 5` comment does not count a round.

```
template/.agents/skills/spec-review/SKILL.md:25
the round is one more than the highest `round: N of 3` line among them (a comment without one is round 1)
```

2. **The ladder's sentence on the comment's last lines was not amended.** Two clauses of the same paragraph now disagree: the first fixes the form at `of 3`, the second lists `round: 4 of 5` and `round: 5 of 5`. Same standard as [S1].

```
template/docs/agents/review-ladder.md:6
The report is posted as a comment on the PR, names the commit it reviewed, and ends with the lines `round: N of 3` and `act-on items: N`. One PR gets three rounds, five when round three or four fixed a Would-break item
```

3. **P20's title still says three at most, and the stale-wording gate misses it.** The row body is amended to five; the title is not, in `docs/knowledge/core/DECISIONS.md` and the generated `template/docs/factory918/DECISIONS.md` alike. `no-stale-wording.sh` gained `at most three rounds` but not the reversed phrasing the title uses, so the gate passes over the one place the old cap survives. Same standard as [S1].

```
| P20 | Three review rounds at most | `review-brief.sh` counts the PR's earlier review comments and refuses a fourth round
```

## Fix alongside

4. **Interval expression inside awk.** `fixed_items` is the first `{n,m}` repetition in an awk program in these scripts; the sibling checks all use `grep -E`. `CODING_STANDARDS.md` bash: "Prefer commands that behave the same on macOS and Linux." Current macOS awk accepts it, older one-true-awk builds do not, and a miss here is silent: the fix section would be empty, not refused. `[0-9a-f][0-9a-f]*` or routing the line through `grep -E` removes the question.

```
fixed_items="$(printf '%s\n' "$deciding" | awk "$fenced"'
  /^## / { if (h == "Judgment") j = 1; next }
  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]{7,40}$/
')"
```

hard findings: 0
