I'll read the departure rules where they're written before saying anything about whether they conflict.

---

The background search has finished. None of my recommendations in round one change, but three findings bear on them, and one claim from the search was wrong once I read the files.

**For Q1 (what makes a rule binding).** The run-2 constraints audit sorted limits with nearly the split you rejected: what a subagent may look at, what it may run, caps on output, and then two kept classes, safety rules and hand-back format.
- That split made it miss things at first. A late addendum admits it had filed some rules under "report format" and skipped them.
- The worst of those concern how the work is finished, not the search. The Standards review brief makes a reviewer cite a ticket criterion for each bug, but the brief never shows the ticket. On one PR an honest reviewer filed nothing, and all four of that PR's real bugs went unfiled.
- So the audit's own evidence backs your point that search is only where this shows first.

The search also found route rules that did good:
- The mandatory trail review caught the owner's mistakes 3 times out of 3.
- An agent broke the delegation rule knowingly, and a hook now holds it.

Both are rules you set, with a reason that was measured. That fits the recommendation that only the owner of an authority can make a rule binding.

**For Q2 and Q5 (route knowledge and budgets).** The research note for "Research how wording and missing context shape a reader's response" is written. It's on the unmerged `research/wording-and-reader-context` branch.
- It says specific guidance on method helps on simple tasks and for less capable readers.
- It says no model study tests a limit on strategy as such.
- It separates what the writer chooses to volunteer from what the reader is allowed to seek. That's the line Q2(b) draws.
- The audit shows the worst limits on review briefs ("read nothing beyond this brief, run nothing") were added by subagents to save cost. No ticket asked for them. That's the case Q4 and Q5 are meant to stop.

**For Q3 (when a binding rule fights the goal).** The search reported five ways of departing from a rule that "don't agree". Read where they're written, each covers a different situation:
- The sign-off line in your note in `template/AGENTS.md` speaks to the main session, with you there to sign off.
- `skip: <reason>` in poteto-mode covers playbook steps.
- The Feature playbook's "stops and reports the cell, and never fills it in" covers a code-writing subagent. That's already option (a) in Q3.

The real gap is narrower. No text tells an unattended subagent what to do when a binding rule fights its goal. The session mandate even tells subagents to ignore it. Q3 is aimed at exactly that gap.

Two smaller things I found, which don't belong to this ticket:
- In `template/AGENTS.md`, "These are good defaults, not hard rules" comes right after your note, so it could mean the note or the whole file. I'll record it on "Decide the scope and order of reworking existing files" unless you want it settled here.
- `MANUAL.md` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed. I can file a quick ticket for it.

Round one still stands as asked, Q1 to Q5.