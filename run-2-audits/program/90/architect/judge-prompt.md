# Cross-judge brief: arena for ticket #90's design

You are the read-only cross-judge of an arena. Two runners on different models each produced a candidate design package for the same task. Read the frame, then both candidates end to end, then score them and recommend a base. Read nothing else unless a score needs a fact from the grounding the frame names; run nothing that writes.

Work under `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a7e863dda12fb2374` with absolute paths.

- Frame (the task, constraints and rubric): `.scratch/program/90/architect/frame.md`
- Candidate A: `.scratch/program/90/architect/candidate-a.md`
- Candidate B: `.scratch/program/90/architect/candidate-b.md`
- Grounding, for checking a claim: `.scratch/program/90/how/explanation.md`, the ticket `.scratch/program/90/ticket-90.md`, the scripts under `template/.agents/skills/spec-review/scripts/`.

Score each candidate on each of the frame's six rubric criteria, 0 to 3, with one line of reason per score that names the cell, sentence or regex the score rests on. Then: which candidate is the base and why; what from the other is worth grafting (name the cell or sentence); where the two disagree on a design question (where `restart` prints, what a restart does to settled items, whether `hole:` must equal the report item's `spec:`, where the Ticket playbook's return-to-architect text sits, whether babysit prose changes) and which answer is right and why, checked against the grounding; any cell in either candidate that contradicts a fact in the frame's "Facts from the grounding" section; any acceptance criterion of #90 that neither candidate covers.

Write the verdict to `.scratch/program/90/architect/judge.md` with the Write tool, then reply with only that path.
