## Would break

1. **The Standards brief demands a `spec:` reference it does not carry.** The spec rule is echoed at both call sites (`review-brief.sh:360` and `:390`), but only the Spec block writes `## The ticket (#N)` (`:370`); `common()` carries commits, files, blast radius, diff and settled items, never the ticket. So a Standards reviewer with a would-break finding has no table, `## Design` sketch or criterion list to name, while the same brief forbids fetching one. Standard: `CODING_STANDARDS.md`, Markdown — agent-facing markdown is written with `/writing-for-agents`, whose rule is that the document holds what its reader needs.
Documented step: `template/.agents/skills/spec-review/scripts/review-brief.sh:356`, "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file."
Result: the Standards report is refused by `review-comment.sh:115` until the reviewer either breaks the brief or invents a reference, and an invented one then passes the `hole:` word-for-word check unchallenged. This report had to read the ticket over `gh` to comply.
spec: criterion 2

```sh
  echo "$step_rule"
  echo
  echo "$spec_rule"
  echo
  echo "Write your report to \`$dir/standards-report.md\` and reply with only that path."
```

2. **The human's merge check still passes a mid-restart PR.** Babysit, `babysit/SKILL.md` and the review ladder all learned that a `restart` comment is not merge-ready, but the human-facing merge checklist in the core manual did not, and `review-comment.sh:206-208` can print `restart` above `act-on items: 0`. Standard: `CODING_STANDARDS.md`, Markdown — "`docs/knowledge/core/` is the source; everything under `docs/knowledge/spec/`, `pages/`, `notes/` and `template/docs/factory918/` is generated and never edited."
Documented step: `docs/knowledge/core/MANUAL.md:103`, "It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`".
Result: the human reads a hole-marked comment as ready and merges the work the change exists to send back to `architect`; the generated copy at `template/docs/factory918/MANUAL.md:84` ships the same check to every project.
spec: table 1/D

```sh
[ "$holes" -eq 0 ] || echo restart
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

## Fails open

## Standards breaches

3. **The Provisional rows that record the review loop were not amended.** `DECISIONS.md` P21 still enumerates three `cites:` forms where there are now four, P19 still lists only `ticket:` as the uncounted Act-on field, P18 still names `Documented step:` as the last per-item refusal, and P20's review-ready sentence has no restart clause. Every earlier change to this loop carries a dated amendment (P16, P18, P19, P20). Standard: `CODING_STANDARDS.md`, Markdown — "A count or a version in prose is true at the commit that lands it"; and Commits and pull requests — "a choice to `docs/knowledge/core/DECISIONS.md` under Provisional."

```md
| P21 | What carries into the next round | Only a Noted or Dismissed judgment item ending in `cites: user: "..." on #N`, `cites: DECISIONS.md <row>` or `cites: #N comment <date>` is pasted into the next briefs
```

## Fix alongside

4. **Duplicated Code.** The `fixed:` and `ticket:` patterns are now spelled three times in `review-comment.sh`, once inside `ending` and once each in the counters, so the sha width lives in two places.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

5. **Mysterious Name.** The hole loop reuses `want`, which held the expected `[S<n>]`/`[P<n>]` set twelve lines up, for a report item's reference, and splits `rests` into `at` and `want` by tab. Two names and a struct-shaped string where a reader has to hold both meanings.

```sh
rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

hard findings: 2
