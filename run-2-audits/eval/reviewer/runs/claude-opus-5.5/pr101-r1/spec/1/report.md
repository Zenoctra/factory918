## Walk

1. Criterion 1: `review-brief.sh` holds the Contract's sentence in `risk_rule` and appends it to the Spec brief's `## Walk` bullet on the same line when `grounding` is non-empty. `grounding` is set only inside the cross-cutting block, so a diff that is not cross-cutting keeps the plain bullet (1B, 3B, 9B). The Standards brief never gets it.
2. Criterion 2, detection: inside the cross-cutting block, after the empty-grounding refusal and before any state is written, the script runs awk over the grounding. It strips CR and trailing blanks, applies the shared `fenced` rule, and matches the first line that is exactly `## Risks` or `### Risks`. When no line matches, it removes `$dir` and prints the Contract's refusal on stderr, naming `$blast` or "the PR body's Blast Radius section", then exits 1.
3. Criterion 2, tests: 1A, 2A, 7A and 8A assert the bullet with the risk sentence. 5A and 6A assert the refusal naming the file, with no state and no briefs. 3A covers the CRLF PR body with `### Risks` and the fenced `## ` line. 4A covers both the empty case and the prose-then-`## Risks` refusal naming the body. 9A, 9B and 10 stand as before, and 1B and 3B assert that the sentence is absent. The `SKILL.md` pin of `risk_rule` is added.
4. Criterion 3: `review-comment.sh` is unchanged. The new fixture inserts two risk lines, numbered 4 and 5, after walk line 3 and expects the same counts and comment.
5. Criterion 4: `opening-a-pr.md` and its patch say the `## ` headings are demoted to `###` when pasted, because an undemoted `## ` line ends the section, and that the risks are found under `### Risks`.
6. `SKILL.md` step 1 and its patch carry the Risks heading rule and quote the refusal. Step 4 carries the sentence word for word, and the patch matches the template.
7. `ticket.md` step 5 asks for the hand-back with each part under a `## ` heading and numbered risks under `## Risks`, and says that "verbatim" becomes "demoted to `###`".
8. `SOURCES.md` items 3 and 6 each gain a sentence. The CI fixture is rewritten with `## Risks` so it passes the new check, and CI asserts that the risk sentence is present in the Spec brief and absent from the Standards brief.

## Would break

## Fails open

## Not asked for

1. **P27 and its M0-findings and ledger lines.** The diff adds a settled decision on how to open stacked PRs (against `main`, then retargeted). This is a workflow rule unrelated to the Spec walk, recorded in `DECISIONS.md` rather than under Provisional or as its own ticket. The ticket notes #100 as the tracked fix.
```
Its files overlap #90's and #93's in `review-brief.sh` and its test; under the program's go it stacks on the printed PR.
```

hard findings: 0
