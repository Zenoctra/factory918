## Would break

## Fails open

## Standards breaches

1. **Garbled sentence in the skill an agent reads.** `CODING_STANDARDS.md`, Markdown: "Written with `/writing-for-agents` when an agent reads it." The `## Report` bullet of `SKILL.md` step 4 (and the same line in `patches/mattpocock/spec-review.SKILL.md.patch`) runs two clauses together, so the sentence that introduces the five quotes has no readable subject. No behavior rides on it: the test greps the quotes, not this line.

```
"Zero items is the expected result for a clean change." Then the five sentences of Manuel's the definition follows, attributed, as the script writes them:
```

## Fix alongside

2. **Duplicated Code: the definition sentence lives in four places.** `review-brief.sh` (`definition=`), `tests/spec-review/review-brief.sh` (`definition=`), `tests/spec-review/no-stale-wording.sh` (the retired half) and now the CI workflow. The workflow copy re-asserts what `tests/spec-review/review-brief.sh` already checks, and every rename now has four literals to chase.

```yaml
grep -qF 'A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). ...' "$f"
```

3. **Duplicated Code: `suite factory` adds no coverage in `review-comment.sh`'s test.** `review-comment.sh` reads only the git toplevel, `.scratch/review/x` and `.claude/state/review`; none of those differ between the two layouts, so the second pass re-runs ~40 identical assertions. The second layout earns its keep in `review-brief.sh`'s test (the hooks path), not here.

```sh
suite project
suite factory
```

4. **Mysterious Name: `line` holds two unrelated values in `report()`.** First the `hard findings:` line, then the stepless item, three statements later. A second local would read straight.

```sh
  line="$(grep -E '^hard findings: [0-9]+$' "$f" | tail -1)" || fail ...
  ...
  line="$(stepless "$f")"
```

5. **P23 is out of order in the Provisional table.** The rows run P1..P21 ascending; P23 was inserted before P22, so the table reads P21, P23, P22, P2. Both copies (`docs/knowledge/core/DECISIONS.md:89`, and the generated template copy) carry it.

```
| P23 | The Spec report opens with a walk | ...
| P22 | Who signs a comment | ...
```

hard findings: 0
