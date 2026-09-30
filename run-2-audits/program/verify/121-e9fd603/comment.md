Agents that did not write this PR verified it at head e9fd603, as the first link of the stack for tickets #103, #105, #110, #106, #107, #108 and #109. Every gate passes, the id rule held when exercised live, and the diff matches the ticket's scenario table. Nothing blocks, and there are four notes for Manuel.

## Verifier verdict

Verified head: `e9fd603752d1eeacf345c9853e34d0f33e20813c`. Patch base: `86d156a` (`main`). Position in the stack: first link, on `main`.

| slice | verdict |
|---|---|
| gates re-run (the Verifying list at the SHA, the fixture flow, every test with counts at the base and the head, knowledge build, sync, ShellCheck, CI run 35813400632 green at the head, P1 to P30 unchanged, `P110` unique) | PASS |
| live runtime floor (two PRs from one base with `P110` and `P111` pass; both as `P31` refused, naming the duplicate; `P110b` passes, and `P110a`, `P-110`, `P110B` and `p110` are refused; a rebase keeps the id; a reshaped table is refused; a `P110b` cite is accepted and the old cites still work; the new prose lets an agent take a correct id) | PASS |
| receipts-and-diff audit (the three criteria met, one assertion per scenario-table row, tests committed before the check, scope within the ask, two review rounds ending at zero act-on items, closing reference #110 only, no forbidden edits) | PASS+NOTES |

Notes for Manuel. The verifiers asked for no action on any of them.

- The body did not end with the model and harness line. The owner added it after the audit. Only the body changed, and the head is the one verified.
- The check reads only rows under the `## Provisional` heading. A duplicate moved under a new later heading passes. Reaching that needs a deliberate re-layout, and the four accidental reshapes the verifiers tried were all refused.
- PR #120 (ticket #105) adds its row as `P31`. The root has asked its owner to rename it `P105` before the two PRs meet in the chain. Both PRs append to the same table and move the same `INDEX.md` count line, so the rebase that joins them will conflict textually. The resolution keeps both rows and changes no id.
- The fixture line in `AGENTS.md` "Verifying" uses an absolute `--directory`, which `vp` refuses. CI already uses a relative path. The problem predates this PR and is filed as #123.

The full reports are in the root session's scratch, not in the repository.

Claude Opus 5.5 on Claude Code
