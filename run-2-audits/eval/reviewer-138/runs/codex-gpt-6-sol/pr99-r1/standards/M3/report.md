## Would break

## Fails open

## Standards breaches

1. **Provenance gives the old finding count.** `CODING_STANDARDS.md`, Markdown: “A count or a version in prose is true at the commit that lands it.” The changed `SOURCES.md` item 6 still says each report has two axis-specific headings and counts only Would-break items. The current Standards and Spec report shapes each have three other headings, and `hard findings: N` counts both Would-break and Fails-open items.

```text
Each report sorts its findings under `## Would break` and two axis-specific headings, and its `hard findings: N` counts only the Would-break items;
```

## Fix alongside

hard findings: 0
