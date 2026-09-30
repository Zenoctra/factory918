## Act on

1. [S1] **`gh issue edit --body-file` replaces the body; nothing says to write the old body back.** Step 6 says "appended" but names a command that replaces, and no document in the diff says to fetch the body and write body-plus-section; the loss is silent and the next Spec review would read a ticket with no criteria. The fix is a sentence in step 6, not a criterion.
2. [P1] **The posted table becomes overlap.sh's pathspecs.** Both reviewers found it independently: a posted table carrying backticked paths feeds the step-1 check, which then matches unrelated PRs or exits 2; the fix (an unbackticked-paths rule in the posting instruction, or one more skipped section in the check) leaves the criterion as written.
3. [S5] **The posted table feeds tokens back into `overlap.sh`.** The same finding as P1; the same change fixes both.
4. [P3] **The map still says four project documents.** The PR changed AGENTS.md's count to six and left MANUAL.md:165 and the `build_knowledge.py` docstring at four; the count rule is documented and each fix is one line.
5. [P4] **A failed post does not stop the work.** Step 8 has a stop clause and step 6 has none; the ticket's own rule 5 says a refusal added under a could-not-run clause is not a design hole, so this is one sentence on the PR.

## Ask

## Consider

6. [P2] **architect's own skill still says usage first.** The criterion names the runner prompt and the runner prompt is met; a table slot in the skill's Output shape and rationale template is a second patch on a vendored skill, worth it only if the synthesis step actually drops the table the runners produced.
7. [S2] **The to-spec exemption covers half the rule it points at.** A real disagreement between the "no file paths or snippets" rule and a bullet that exempts only snippets, but the table's example paths are a design record, not a spec's prose; rewording the bullet to exempt both halves is cheap if the owner agrees it reads as a conflict.

## Noted

8. [S3] **`SOURCES.md` line 3 is left saying what this commit records as false.** Valid, but line 3 predates this PR and its concern is `sync`, not the design artifact; the M0-findings line is the dated record and the correction is its own quick ticket.
9. [S4] **Duplicated Code / Shotgun Surgery.** The four playbooks are vendored files patched one by one, so each carries its own delegation sentence by construction; no Act on fix touches them, so this stays a note.

## Dismissed
