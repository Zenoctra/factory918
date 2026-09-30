## Would break

## Fails open

## Standards breaches

1. **P21 now lists three of four `cites:` forms.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." `DECISIONS.md` P21 says only three citation shapes carry; this hunk adds a fourth. The ticket leaves `DECISIONS.md` to the owner, so this is the owner's line to amend, not the writer's.

```
+- `cites: <decision>` ... `#N comment <YYYY-MM-DD>` (a ticket comment by the ticket's author) or `#N <reference>` (a cell, signature or criterion of the ticket in the `spec:` grammar ...)
```

## Fix alongside

2. **Unanchored `hole:` grep.** `fixed:` and `ticket:` are read only as the field ending the line; `holed()` reads any `hole:` substring, so a reason containing "as a whole: it reads fine" is refused as carrying a `hole:` field (reproduced with `review-comment.sh <dir>`). Match ` hole: ` as a trailing field, as `ending` does.

```
+holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

3. **Duplicated Code: the two field regexes are written twice.** `ending` holds `fixed: [0-9a-f]{7,40}` and `ticket: #[0-9]+`, and the count greps repeat both. Build the counts from the same pieces.

```
+ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
 fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
 ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

4. **Stale clause kept in a rewritten line.** SOURCES.md item 6 is replaced whole and still says the count "counts only the Would-break items"; Fails-open items have counted since #81.

```
+6. ... Each report sorts its findings under `## Would break` and two axis-specific headings, and its `hard findings: N` counts only the Would-break items; ...
```

5. **The manual's ready-when line predates `restart`.** `docs/knowledge/core/MANUAL.md:103` says a PR is ready when the last review line reads `act-on items: 0`; a restart comment whose Act on items are all holes reads that too. Not in the diff and the ticket keeps `MANUAL.md` from the writer; one clause for the owner.

```
2. It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`; ...
```

Verified: ShellCheck clean; the four spec-review and hook tests pass; the three patches apply to their pinned upstreams and reproduce the template copies byte for byte.

hard findings: 0
