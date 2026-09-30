This PR was verified by agents that did not write it, as the first link of the stack for tickets #88, #89, #90, #91 and #93. Every repository gate passes at head 715100c, the changed behavior was exercised live, and the three findings from the first pass were fixed and re-checked.

## Verifier verdict

Verified head: `715100c12a8eef8d9f2eb547769404c1f9ce7ab1`, patch base `ab47eb9` (main). Position in the stack: bottom.

| pass | slice | verdict |
|---|---|---|
| 78be65e | gates re-run (syntax, five test scripts, knowledge build, sync, seven patches, shellcheck 0.11.0, CI 35748776685, the fixture flow) | PASS |
| 78be65e | live runtime floor (the `overlap.sh` section skip both ways, `SCENARIO-TABLE.md` reaching an applied project, the patched skills after sync) | PASS+NOTES |
| 78be65e | receipts-and-diff audit | ISSUES: the body's `closes #88` wording linked #88; the section-skip rule left sibling `## ` parts of an artifact uncovered and the #42 amendment overstated it; the model-and-harness line was missing |
| 715100c | delta audit and gates re-run after the fixes | PASS: closing references list only #89; the one-section rule is in Ticket step 6, the ticket body shape and `SCENARIO-TABLE.md`, with a fixture that fails when the boundary is loosened; #42's amendment is now true of its body; body signed |

Notes carried, no action asked: the playbooks' architect steps do not carry the posting rule (a run started outside the Ticket playbook never meets it); `doctor`'s slim check does not guard the fifth document; the heading match is case-sensitive; `VERSION` is not bumped; commit 78be65e (three record lines) was not reviewed; an agent amended closed ticket #42, which is Manuel's call. The full reports are in the root session's scratch, not in the repository.

Claude Fable 5.1 on Claude Code
