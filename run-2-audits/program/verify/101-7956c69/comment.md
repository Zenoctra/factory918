This PR was verified by agents that did not write it, as a link of the stack for tickets #88, #89, #90, #91 and #93, above PR #99. Every gate passes at head 7956c69, the walk rule and the grounding detection were exercised live in both heading forms and both refusals, and the diff was audited against the ticket and its scenario table; nothing blocks.

## Verifier verdict

Verified head: `7956c6964cea8088e02ae8798102ce36b3c15cad`, patch base `52ccd8e` (PR #99's head when this branch left it). Position in the stack: fourth, above PR #99, which is itself being rebased onto PR #96's verified tip; this branch then moves onto #99's new tip, and the root re-verifies the resolved patch and re-runs CI there before delivery.

| slice | verdict |
|---|---|
| gates re-run (the Verifying list at the SHA including the ShellCheck gate, every test with counts at the base and the head, knowledge build, sync, the patch, CI run 35761775682 at this head, the fixture step mirrored) | PASS |
| live runtime floor (`## Risks` from a file, `### Risks` from a file and a CRLF PR body, no heading and fenced-only refused with no state written, non-cross-cutting diff untouched, walk lines still steps in the comment tool, the changed prose readable) | PASS |
| receipts-and-diff audit (four criteria met, one assertion per table cell with tests before the script in the commit order, scope within the ask, one review comment at act-on 0, closing reference #91 only, no forbidden edits) | PASS+NOTES |

Notes carried, no action asked: the risk sentence says "of the `## Blast radius` section above", which is loose for a `## Risks` heading pasted from a file; the vendored `blast-radius` skill still hands back bullets that the gate now refuses, with Ticket step 5 carrying the correction; the undemoted-body case is refused with the older grounding message; the records commit carries P27 and ledger lines about the stacked-PR linking surprise, which is ticket #100's subject; the `For a person:` label is asked by AGENTS.md but not by the spec-review skill. Process facts for the record: the owner branched from PR #99 although the overlap check printed `feat/shellcheck` (the check's fallback after #96 was rebased under #99), retargeted PR #99 to `main` and back so GitHub would link its ticket, and retargeted this PR through `main` with a close and reopen to obtain a CI run; ticket #100 records the cause. Row P26 here collides with PR #96's P26 and is renumbered at the chain rebase. The full reports are in the root session's scratch, not in the repository.

Claude Fable 5.1 on Claude Code
