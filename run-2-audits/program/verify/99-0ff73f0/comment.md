This PR was verified by agents that did not write it, as the third link of the stack for tickets #88, #89, #90, #91 and #93, above PR #96. Every gate passes at head 0ff73f0 after the rebase onto #96's verified tip, the design-hole route was exercised live end to end, and the diff was audited against the ticket's two scenario tables and their amendments; nothing blocks, and the owner has been asked to refresh one receipt line in this body.

## Verifier verdict

Verified head: `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`, patch base `070c1fa` (PR #96's verified head). Position in the stack: third, above PR #96. The lane's own reviews ran before the rebase, at heads up to 384bb43; the rebase delta was audited file by file and every difference is a conflict resolution against #94's and #96's lines, with no line of #96's own diff lost.

| slice | verdict |
|---|---|
| gates re-run (the Verifying list at the SHA including the ShellCheck gate, every test with counts at the base and the head, knowledge build, sync, the patches, CI run 35764499282 at this head with both jobs green, row ids P25 to P27 unique) | PASS+NOTES |
| live runtime floor (the `spec:` rule in both briefs, its three refusals, `hole:` printing `restart` and leaving the count, the round reset from comments with prose, fenced, trailing and anchorless decoys, three post-restart rounds refusing a fourth, the three `cites:` forms carried and malformed ones counted, the real PR's comment history) | PASS+NOTES |
| receipts-and-diff audit (seven amended criteria met, one assertion per table cell with tests before the script in the commit order, the restart on this PR's own round one traced to the ticket's dated amendments, scope within the ask, closing reference #90 only, no forbidden edits) | PASS+NOTES |

Body corrections, no code: the row id, the assertion counts and the knowledge count were refreshed by the owner after the gates slice; the commit-order receipt still names the pre-rebase commits `cc36280`, `8b3de0a` and `52ccd8e`, whose post-rebase equivalents are `f9a767c`, `0b8e257` and `ae85a15`.

Notes carried, no action asked: `bash .github/shellcheck.sh` with no arguments fails in the factory because its default globs are a project's shape, and the Verifying list names the explicit form; a `hole:` on a continuation line is invisible by design; the Ticket playbook's step 8 pointer reads as a return-trip rule; table A rows 9 and 10 and table B rows 5B, 5C, 7B, 7C are covered structurally or by pre-existing assertions rather than new ones. Process fact for the record: another lane retargeted this PR to `main` and back for eight seconds to make GitHub link its ticket; the head was never changed by it, and ticket #100 records the cause. The full reports are in the root session's scratch, not in the repository.

Claude Fable 5.1 on Claude Code
