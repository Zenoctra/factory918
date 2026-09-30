## Walk

1. Criterion 1: `review-brief.sh` sets `risk_rule` to the Contract's sentence word for word and appends it to the Spec brief's `## Walk` bullet on the same line, only when `grounding` is non-empty. The Standards brief never carries it. `SKILL.md` step 4 and the patch carry it word for word, and the test pins it in the source `SKILL.md`.
2. Criterion 2, detection: inside the cross-cutting block, after the empty-grounding check and before any state is written, the script strips CR and trailing blanks, applies the shared `fenced` awk (fenced lines hit `next`), and matches the first line that is exactly `## Risks` or `### Risks`. If none matches, it runs `rm -rf "$dir"` and prints the Contract's refusal naming `$blast` or "the PR body's Blast Radius section", then exits 1.
3. Criterion 2, tests: 1A, 2A, 3A, 4A (both sub-cases), 5A, 6A, 7A, 8A, 9A, 9B, 10, 1B and 3B each carry an assertion named by row and column. The absent case (9B, 1B, 3B) asserts that the sentence is not there.
4. Criterion 3: the `review-comment.sh` fixture adds two risk lines, numbered 4 and 5, after walk step 3, and expects the same `hard findings`/`act-on items` counts and the same comment. The script itself is unchanged.
5. Criterion 4: the Opening a PR bullet, both the template and its patch, says the `## ` headings are demoted to `###` because an undemoted line ends the section, and that `review-brief.sh` finds the risks under `### Risks`. `ticket.md` step 5 gives each part of the hand-back a `## ` heading, puts the risks under `## Risks`, and says to demote them when pasting. `SOURCES.md` items 3 and 6 each gain a sentence.
6. CI fixture: the fixture's `/tmp/blast.md` gains `## Risks` so that 5A does not refuse it. The fixture asserts the sentence is in the Spec brief and not in the Standards brief.

## Would break

## Fails open

## Not asked for

1. **P27 and its ledger/M0 lines about stacked-PR closing links.** The diff adds decision P27, which says a stacked PR is opened against `main` and then retargeted. It also adds two ledger entries and an M0-findings line about `overlap.sh` coverage and GitHub's `closingIssuesReferences`. The ticket and its table cover the Spec walk and the Risks heading only. The ticket says:

   ```
   - [ ] For a cross-cutting diff, the Spec brief's `## Walk` rule requires, after the lines per documented step, one numbered line per risk under the grounding's Risks heading
   ```

   The lines record what happened on this run, as the Pull requests rule asks of surprises. P27 is a new process rule for owner lanes, which is a separate concern.

hard findings: 0
