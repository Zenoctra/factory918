## Act on

1. [S1] **The rerun dir is matched as a string.** An absolute or `./` spelling prints the comment and leaves the state behind, so the hook keeps blocking; normalize the argument to a root-relative path before comparing, and test the absolute spelling.
2. [S3] **References resolve by position, not by the number written.** A report that restarts numbering under each heading passes the set check while every `[S<n>]` names a different finding; refuse a report whose written numbers do not run 1..N in document order.
3. [S4] **A fence inside a fence inverts the toggle.** Same defect as [P2]; one fix in the shared awk.
4. [S5] **P17 is a gap in the Provisional table.** One line saying P17 was promoted to decision 19; the orchestrator owns that file and commits it here.
5. [P1] **The Spec brief does not ask for fenced quotes.** The Standards brief does; say the same in the Spec brief, since a quoted criterion carries `## ` and `1. ` lines.
6. [P2] **Fence handling is a bare toggle.** Track the opening fence (backticks or tildes, and its length) and close only on a fence at least as long of the same character, which is the CommonMark rule; the round-2 Standards report itself uses `~~~` fences the current awk does not see.
7. [P4] **A trailing space after a heading breaks the match.** Trim trailing whitespace in the shared parser; rides with the fence fix.

## Ask

## Consider

1. [P6] **In the opus preset the spec reviewer is not cheaper than the writer.** `claude:opus@medium` would make it so; Manuel's stated reason for the row is context over model, so the choice is his and the doc now says "no dearer".

## Noted

1. [S2] **The report shape is written in six places.** The test pins the definition and the headings the script enforces; a rename is rare and the test fails loudly.
2. [P3] **Under-counting passes.** The count line no longer feeds the count; refusing a smaller number would enshrine a line that is now only a cross-check.
3. [P5] **Four criteria are not in this diff.** PRs B and C carry them; the round cap edits the same output block and B is already rebased on this PR.

## Dismissed

1. [P7] **Ask counted and a rerun path were not asked for.** Round 1 settled this: an unanswered security or data question must hold readiness, and the rerun is what lets the human's answer close it without paying for two new reviewer lanes.
