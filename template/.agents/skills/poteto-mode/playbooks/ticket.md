### Ticket

**A ticket is the ask. Read it, prove its criteria can fail, run the matching playbook, end in a PR that closes it.** For any request carrying an issue reference: `#N`, `owner/repo#N`, or an issue URL. A request carrying several references and `autopilot-stack` goes to that playbook instead; each of its owner lanes then runs this playbook for its own ticket.

1. Start from an up-to-date `main`. `git fetch origin main:main` (`git pull --ff-only` when on `main`), so local `main` moves too, then note the current branch. If `git status --porcelain` prints anything, stop, tell the user the checkout is dirty and what is in it, and do not start. Otherwise `git switch -c <branch> origin/main` (`main` when the repository has no remote), or start from the parent PR's branch when the ticket stacks on an open PR on purpose. A session inherits whatever branch the last one left; a branch started from a stale or already-merged one carries someone else's commits into the PR.
2. Read the ticket: `gh issue view N --json title,body,labels,state,comments`. Its **What to build** is the goal; its **Acceptance criteria** are the finish condition; its **Parent** is the spec: read it too (`gh issue view <parent>`), and read `CONTEXT.md` and the ADRs in the area. The body shape is `docs/agents/issue-tracker.md`, "Ticket body".
3. Check **Blocked by**. Every listed issue must be closed. If one is open, stop and report which; do not start.
4. Falsifiability pass. For each criterion name the command or observation that would fail it right now. A criterion that already passes at HEAD, that another ticket owns, or that only restates the request goes back to the human as a note before work starts. Criteria the human confirms become the verification plan.
5. Select by content and run that playbook's steps verbatim from step 1: new behavior → Feature; a defect → Bug fix; a behavior-preserving change → Refactoring; measured slowness → Perf issue. `how` and `why` over the affected subsystem come first in all of them. A change whose diff will touch a cross-cutting path, one under a `.claude/hooks/` directory, a `.claude/settings.json`, or a file of the `factory918` skill (`.agents/skills/factory918/`), at any depth (`spec-review`'s `review-brief.sh` holds the predicate), reaches every session and skill at once: after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape (what it does; the one fact it is safe because of and how far it was proven; risks; cleared; before you merge), with a risk for every session kind (the interactive session, a subagent, a hook's own invocation, `factory-start` at day zero, a review in progress) and every skill the change reaches, each with a `file:line`. Such a change never skips `architect`. The PR body's `## Blast Radius` section is that file verbatim, and `review-brief.sh` refuses to brief the diff without it.
6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it.
7. Verify on the matching surface per `docs/agents/evidence.md`; the primary agent runs the project's `verify-<app>` skill once after integrating.
8. Run **Opening a PR**. The body's Verification section quotes each criterion with its evidence path. The last line before the attribution is `Closes #N`. Never close the issue by hand; the merge closes it.
9. Babysit to merge-ready per `playbooks/babysit.md`. Never merge.

**Reply:** the ticket, the criteria and how each was proven, what the ticket did not settle and what you chose, the PR URL.

### Quick ticket

**Work that started in conversation and will end in a PR gets a ticket first, in the words that decided it.** Then it is Ticket work. A change that ends in a commit on a branch needs none.

1. File it before starting: `gh issue create --label ready-for-agent --title "<the ask in six words>" --body "<body>"`. The body shape and the quoting rule are `docs/agents/issue-tracker.md`, "Ticket body": its **What to build** is the exchange that carried the decision, quoted and attributed, never paraphrased. No **Parent**, no **Blocked by**.
2. Its **Acceptance criteria** come from the falsifiability pass (step 4 above): one checkbox per observation that would fail today, in the user's terms.
3. Reply with the number and the criteria in one line, then proceed; do not wait. The human edits the issue if the words are wrong.
4. From here it is the Ticket playbook: the PR says `Closes #N`, `spec-review` reads the issue, the merge closes it.
