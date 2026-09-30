# Standards report, c83f166

## Would break

## Fails open

## Standards breaches

1. **A count in prose has no regenerating command nearby.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." The count is true at this commit: `tools/build_knowledge.py:136` copies every core document except `CONVERSATION-DIGEST.md`, which is five documents. No command next to the count shows how to check it, so the next core document will make it stale again the same way "four" went stale.

```diff
-Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
+Everything below lives in the factory clone (`~/.factory918`); a project carries only the first five, under `docs/factory918/`.
```

## Fix alongside

2. **Duplicated test label.** The new case reuses the number 17, so a failure message names "17" for two different cases. Mysterious Name, a minor case.

```diff
 check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
+check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

Checked and clean: the awk alternation `^## (Diff|Testing decisions|Design)` is POSIX ERE, so BSD and GNU awk read it the same way. The new test case would exit 1 without the change, because `docs/a.md` and `src/z.txt` match open PRs in the fixture. The new `pstack/architect/SKILL.md.patch` hunk matches the template file at line 29. It is listed in `series` and described in `SOURCES.md` item 14. The generated `template/docs/factory918/` copies match their core sources. The `build_knowledge.py` docstring agrees with the filter at line 136.

hard findings: 0
