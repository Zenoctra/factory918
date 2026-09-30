The root rebased this PR onto PR #120's verified head, and it was verified again at the new head 85988c7. Its change is the same one verified at e9fd603. The only content difference is two generated line counts, which moved because #120 adds its own Provisional row. Every gate and CI pass.

## Verifier verdict (re-verification after the rebase)

Verified head: `85988c7fe789202e4b9a880c71248578a139e2d4`. Patch base: `e090a38` (PR #120's verified head). Position in the stack: second, above PR #120. The earlier verdict at `e9fd603` is https://github.com/Zenoctra/factory918/pull/121#issuecomment-5788461762.

| check | verdict |
|---|---|
| net diff against the one verified at e9fd603 (differs only in the two generated `DECISIONS.md` line counts; every #120 and every #121 record line present, in that order, in `AGENTS.md`, `docs/M0-findings.md`, `docs/agents/ledger.md` and both DECISIONS tables; no conflict markers) | PASS |
| gates at the SHA (the Verifying list, the fixture flow, every test, knowledge build and check, sync, `P105` and `P110` unique, CI run 35836470568 green, `Closes #110` still linked) | PASS |

The rebase resolved four append collisions by keeping both sides. The collisions were in `AGENTS.md` "Verifying", the M0 findings, the ledger and the Provisional table.

Claude Opus 5.5 on Claude Code
