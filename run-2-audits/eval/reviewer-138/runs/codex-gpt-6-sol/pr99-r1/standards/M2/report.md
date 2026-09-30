## Would break

## Fails open

## Standards breaches

1. **The source record states the wrong finding count.** `CODING_STANDARDS.md`, Markdown rule “A count or a version in prose is true at the commit that lands it”: the edited `SOURCES.md` item 6 still says `hard findings: N` counts only Would-break items. Both review briefs and `review-comment.sh` count Would-break and Fails-open items. The same source sentence also says there are two axis-specific headings, though the Standards report now has three.

```md
Each report sorts its findings under `## Would break` and two axis-specific headings, and its `hard findings: N` counts only the Would-break items;
```

## Fix alongside

hard findings: 0
