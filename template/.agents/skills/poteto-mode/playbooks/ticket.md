### Ticket

**A ticket is the ask. Read it, prove its criteria can fail, run the matching playbook, end in a PR that closes it.** For any request carrying an issue reference: `#N`, `owner/repo#N`, or an issue URL.

1. Read the ticket: `gh issue view N --json title,body,labels,state,comments`. Its **What to build** is the goal; its **Acceptance criteria** are the finish condition; its **Parent** is the spec: read it too (`gh issue view <parent>`), and read `CONTEXT.md` and the ADRs in the area.
2. Check **Blocked by**. Every listed issue must be closed. If one is open, stop and report which; do not start.
3. Falsifiability pass. For each criterion name the command or observation that would fail it right now. A criterion that already passes at HEAD, that another ticket owns, or that only restates the request goes back to the human as a note before work starts. Criteria the human confirms become the verification plan.
4. Select by content and run that playbook's steps verbatim from step 1: new behavior → Feature; a defect → Bug fix; a behavior-preserving change → Refactoring; measured slowness → Perf issue. `how` and `why` over the affected subsystem come first in all of them.
5. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it.
6. Verify on the matching surface per `docs/agents/evidence.md`; the primary agent runs the project's `verify-<app>` skill once after integrating.
7. Run **Opening a PR**. The body's Verification section quotes each criterion with its evidence path. The last line before the attribution is `Closes #N`. Never close the issue by hand; the merge closes it.
8. Babysit to merge-ready per `playbooks/babysit.md`. Never merge.

**Reply:** the ticket, the criteria and how each was proven, what the ticket did not settle and what you chose, the PR URL.
