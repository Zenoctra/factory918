# Standards report, c83f166

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated case number in the overlap test.** The new case reuses the label "17" that the `## Diff` case already carries, so a failure message names two different cases the same way. Rename it "17b" or renumber. (Mysterious Name, judgement call.)

```sh
check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

2. **"a cell" covers only one of the two sections.** The sentence says the check skips both sections, but the reason it gives only fits the table, because `## Design` has no cells. "a path either artifact quotes" would cover both. The same wording is in `ticket.md` step 6 and in both copies of `SCENARIO-TABLE.md`.

```md
+The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names.
```

Checked and clean: the `build_knowledge.py` docstring matches line 136 (every core file except `CONVERSATION-DIGEST.md` is copied), and `template/docs/factory918/` holds exactly the five files that "the first five" in `MANUAL.md` counts. The generated copies match their sources. The patch is listed in `series` and described in `SOURCES.md` item 14. The awk change keeps the portable ERE form.

hard findings: 0
