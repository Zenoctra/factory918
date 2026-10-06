The background search is done, and its results change two of the questions from round one. Q2, Q4 and Q5 stand as I asked them; your answers to round one are still open.

**What it found**
- **Some route rules did real good.** The common thread: you set them, and each has a measured reason.
  - The mandatory trail review found an owner's mistake 3 times out of 3 ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)).
  - An agent broke the delegation rule knowingly, so the rule now runs as a hook.
  - The blast-radius rule exists because an agent read too narrowly and a hook bug survived four review rounds ([ledger.md:17](docs/agents/ledger.md:17)).
- **Rules about how work is finished did as much harm as rules about reading.** The Standards brief requires every hard finding to cite a `spec:` line from a ticket the reviewer never sees. Honest reviewers therefore demoted real bugs. One reviewer wrote "not filed hard because the Standards brief carries no ticket criteria to cite." The run-2 constraints audit had first classed report format as safe and said so in a late addendum. The gate is still live at [review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494).
- **Many route rules give no reason.** Three examples:
  - "never an arena" ([ticket.md:12](template/.agents/skills/poteto-mode/playbooks/ticket.md:12));
  - the 150-line read cap in the `knowledge` skill;
  - "Do exactly the task in your prompt" in the reviewer and tier agent files.
- **Most of the audits' recommended deletions haven't landed.** The ticket "Decide the scope and order of reworking existing files" covers them.

**Departing from a rule.** The search reported five ways a reader can depart from a rule and said they contradict each other. I read each one where it's written. They don't contradict; each covers a different situation:
- "follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)) is for when the agent would prefer another pattern.
- "say so loudly and get a sign-off" (line 20) is for when a rule blocks the task.
- `skip: <reason>` is for skipping a playbook step. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) marks the delegation step as never skippable. That's a rule its owner made binding.
- A writer that can't implement a test cell "stops and reports the cell, and never fills it in" (same line). That's Q3's option (a), already in use.
- A Provisional row is for when the spec says nothing, not for when a rule gets in the way.

The real gap is subagents. None of these gives a subagent a way past a rule that blocks its task, and nothing says how a subagent would get a sign-off with no person there. A smaller problem: in the template, "These are good defaults" comes right after your note, so "These" may mean only the note.

The research ticket's write-up is on its branch, but my read of it was refused. The search's summary of it says two things. First, the evidence supports your broader framing. Second, no study tests limits on an AI model's strategy directly, and step-by-step method does help on simple tasks. I'll read it before closing this ticket if you allow the read.

---

❓ **Q1 (revised) - What makes a rule binding?** My first test sorted rules by what they're about: the task binds, the route doesn't. The `spec:` gate breaks that test. It's about what "done" means, so the test would have made it binding, and it still worked against the goal. Options:
- (a) the first test: sort by what the rule is about, then check who owns it;
- (b) sort by owner and reason, whatever the rule is about: a rule binds only when its owner made it binding and wrote down why; everything else is knowledge, written as in Q2;
- (c) no test; argue each rule on its own.

➡️ (b). Your trail review and the delegation rule pass it. So does the `spec:` gate, which shows that (b) alone can't catch a bad binding rule. Q3 catches it: when a binding rule blocks the goal, the reader reports it to the rule's owner rather than quietly demoting the bug.

---

❓ **Q3 (revised) - What does a subagent do when a binding rule blocks its goal?** You're present for the root session, so the sign-off line works there. A subagent has nobody to ask. Options:
- (a) Stop that part. Put the conflict, with its evidence, in the result for whoever briefed it, and finish the rest. If the rule is yours, the orchestrator brings the conflict to you.
- (b) Break the rule and report that it did.
- (c) Narrow the goal to fit the rule.

➡️ (a). The orchestrator must pass the conflict on to you rather than settle it itself, or it becomes the rule's quiet owner.

---

Separately: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but PHILOSOPHY has eleven since the cost belief was cut. It's outside this ticket. I can file it as a quick ticket if you want.