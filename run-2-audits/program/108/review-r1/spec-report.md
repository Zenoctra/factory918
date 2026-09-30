## Walk

1. Criterion 1, risk refusal: for a cross-cutting diff, `review-brief.sh` runs `undisposed risks` over the grounding right after the Risks-heading check (the `--blast-radius` file or the PR body's section). Each offending line is named under the header "has risk lines without a disposition", `$dir` is removed, and the script exits 1 before `.claude/state/review` is written (line 448). A diff that is not cross-cutting skips the check and keeps today's "is not pasted" line (A1).
2. Criterion 2, flag refusal: the ticket fetch now runs before the reading pack and before any state write. `undisposed flags` runs whenever a body came back, at every round and in both forms, and refuses in the same way. A ticket with no `### Writer flags YYYY-MM-DD` opener produces no records. When gh fails, the run still briefs as no-spec (A10), and the risk check runs first (A7).
3. The grammar: an item is an unfenced, non-blank line no deeper than the list's first line. Its disposition is the last `fixed:` or `accepted:` field on the line. A sha is checked for format, then that it resolves, then `--is-ancestor HEAD`. Near-miss openers and an unclosed fence opened inside a list are refused. This matches the contract and tables B and C, and the `US` separator keeps an empty value from shifting fields when `read` splits the record.
4. Criterion 3: `risk_rule` gains the "honors the disposition" clause. SKILL.md step 4 and the patch carry it word for word, the test pins both, and `no-stale-wording.sh` retires the old tail.
5. Criterion 4: the test commit 7cfdceb comes before the script commit 4ad87b9. The tests assert A1–A10 by form, every non-blank cell of B and C by column, and the three prose pins. The #91 fixtures and CI's `/tmp/blast.md` gain `accepted: fixture` (writer flag 1, accepted).
6. Criterion 5: the Blast Radius bullet in `opening-a-pr.md` and the Risks bullet in the `blast-radius` hand-back each show a disposition example line, through their patches. The new patch is listed in `series`, and SOURCES items 3 and 19 describe the changes.
7. Docs: Ticket step 5 adds "each ending with its disposition once acted on". Step 6 places the dated Writer flags heading under Testing decisions or Design. The four playbooks now point to Ticket steps 5 and 6 and to the refusal. P108 is recorded and P28 is amended.

## Would break

## Fails open

## Not asked for

hard findings: 0
