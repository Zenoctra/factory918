## Would break

1. **The Spec brief never tells the reviewer to fence its quotes, and the script counts unfenced text.** The criterion is "Both briefs define a hard finding as wrong behavior in normal use and require each one as a numbered item under a `## Would break` heading", and `review-comment.sh` enforces that shape with awk that only skips fenced regions: `headings()` takes any line starting `## ` and `items()` any line starting with a digit, a dot and a space. The Standards brief says "with the quoted hunk in a fenced block under it"; the Spec brief only says "quotes the spec line it rests on". A ticket whose acceptance criteria are Markdown — this ticket's are, including literal `## ` headings and numbered criteria — leads the Spec reviewer to paste a line that either fails the shape check outright or is silently counted as an extra item, which then fails the reference check with a message about a judgment that is correct. This report had to avoid line-initial headings and numerals to pass.

2. **A quoted hunk that contains a fence unbalances the fence toggle.** Same awk: `/^```/ { fence = !fence }`. Sixteen of the eighteen changed files here are Markdown, and the briefs, SKILL.md and the patch all carry fenced examples. A reviewer quoting such a hunk inside a fenced block leaves `fence` inverted for the rest of the file, so real headings are skipped and the report is refused for a shape it has.

## Latent

3. **Under-counting is accepted.** The criterion says exit 1 when the count "exceeds" the Would-break items; the script uses `-le`, so a report saying 0 with three Would-break items passes.

4. **Trailing space after a heading name breaks the match**, since `headings()` compares the raw substring.

5. **Four of the seven criteria are untouched** — blast-radius grounding, carry-forward, the author's ticket comments, the round cap and the ledger line. The ticket allows this ("likely a stack of PRs, one concern each"), but the round cap edits the same output block this PR rewrites.

6. **The `opus` preset is not cheaper than the writer's lane**, both `claude:opus@high`; the criterion says "so its finder can run cheaper than the writer's lane", and models.md was softened to "no dearer".

## Not asked for

7. **An `Ask` bucket counted into `act-on items`, and a rerun-by-directory mode.** The criterion names four buckets and no rerun path. Both follow from the ask-by-default rule, but a pending question now blocks babysit's merge-ready gate.

hard findings: 2
