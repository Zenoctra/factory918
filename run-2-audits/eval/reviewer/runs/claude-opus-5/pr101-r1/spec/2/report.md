## Walk

1. Criterion 1, the Walk rule. `review-brief.sh` defines `risk_rule` with the Contract's sentence word for word and, in the Spec branch only, builds `walk="$walk $risk_rule"` when `$grounding` is non-empty, then echoes one bullet. The bullet's own text is unchanged, so `spec_bullets[0]` still matches as a substring.
2. Criterion 2, both heading forms. Inside the cross-cutting block, after the empty-grounding check and before `$state` is written, an awk over `$grounding` strips `\r` and trailing blanks, reuses the shared `fenced` snippet and takes the first line that is exactly `## Risks` or `### Risks`, whatever the source; not found, it `rm -rf "$dir"` and exits 1 with the Contract's message, `where` being `$blast` or "the PR body's Blast Radius section".
3. Criterion 2, the absent case. `grounding` stays empty for a diff that is not cross-cutting, so the rule is never appended (1B, 3B assertions) and `--blast-radius` still only prints the ignored line.
4. Criterion 2, the test. `tests/spec-review/review-brief.sh` adds one assertion per table cell, named by row and column: 1A, 2A, 7A, 8A pass; 5A and 6A refused through `refused_risks`, which also asserts no state and no briefs; 3A with `### Risks` in the CRLF body; 4A with the undemoted body, where the section is cut at `## Risks` and the surviving prose gives the new refusal; 9A, 9B, 10 unchanged. The `SKILL.md` pin for `risk_rule` is added beside the blast-radius pin.
5. Criterion 3. `review-comment.sh` is untouched; its test gains a fixture that appends two risk lines to the Spec walk and asserts the same counts and the same comment.
6. Criterion 4. The Opening a PR bullet, its patch, SOURCES.md items 3 and 6, `ticket.md` step 5, `SKILL.md` steps 1 and 4 with its patch, the script header comment and the CI fixture all say the `## ` headings are demoted to `###` and where the risks go. `DECISIONS.md` P26 and its template copy match, and `INDEX.md` records 95 lines, which is the file's length.

## Would break

## Fails open

## Not asked for

1. **The stacked-PR record.** Commit 469f78d also adds P27, two ledger lines and an M0-findings paragraph about GitHub's closing link and `overlap.sh`, which no criterion of #91 asks for. AGENTS.md requires a decision under Provisional and a surprise in the ledger, so this reads as the mandated record of the lane's own deviation rather than scope creep; noted only so the judge can confirm it belongs here and not on #100.

hard findings: 0
