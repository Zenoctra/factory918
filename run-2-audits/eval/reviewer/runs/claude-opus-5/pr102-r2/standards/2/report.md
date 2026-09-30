## Would break

## Fails open

## Standards breaches

1. **P20's row title still says three.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." The row the diff amends now documents up to five rounds, but its name column still reads three, in the source and in the generated template copy (`docs/knowledge/core/DECISIONS.md:87`, `template/docs/factory918/DECISIONS.md:79`). `tests/spec-review/no-stale-wording.sh` greps for `at most three rounds`, which this word order escapes.

```
| P20 | Three review rounds at most | ... Amended 2026-09-22 (#93): ... the next round, to five, reviews only that fix ...
```

2. **`gh pr ready --undo` carries no dated finding.** `CODING_STANDARDS.md`, "Commits and pull requests": "a verified tool fact goes to `docs/M0-findings.md` with its date". P30 and the two playbooks make the draft conversion the human-visible block of the round-five stop, and `docs/M0-findings.md` has no line for `gh pr ready --undo` at any `gh` version. No script runs it, so nothing changes today; the record the standard asks for is missing.

```
converts the PR to a draft with `gh pr ready --undo`, goes on with the work that does not depend on the PR, and waits
```

## Fix alongside

3. **Duplicated Code: the `fixed:` grammar is written twice, differently.** `review-comment.sh` matches `fixed: [0-9a-f]{7,40}$` everywhere; `review-brief.sh`'s new extraction of the items a fix-only round carries uses `fixed: [0-9a-f]+$`, so a one-character value the comment script would not treat as a fix is pasted into `## The fix under review`. The two scripts already share `fenced=`, `ref=` and now `cap=3;` under the test that holds the copies together; this line is the odd one out. Fix it if a would-break fix touches this awk.

```
fixed_items="$(printf '%s\n' "$deciding" | awk "$fenced"'
  /^## / { if (h == "Judgment") j = 1; next }
  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]+$/
')"
```

hard findings: 0
