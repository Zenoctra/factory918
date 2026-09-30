# Slice: live floor: does an agent following the playbooks behave right in each tier?
This PR is mostly prose an agent follows. At the SHA:
(a) Safe is today: with no tier file, an empty file, `ECO`, ` eco`, `eco\n\n`, `safe`: quote the step 0 rule and say
    which tier each yields; a run with no file must behave byte-for-byte as a9ebdac's playbooks describe (diff the
    playbooks' text an owner reads in safe against a9ebdac; any change a safe-mode agent would act on is an issue).
(b) Eco: read Ticket step 0's rule and every step it overrides as an owner with no other context. For each item Manuel
    settled (keep fresh: writer, blast radius, both reviewer axes every round, judge, trail review; owner does: how,
    synthesis, writer's brief, small fixes, records, one-page report; architect: one runner plus adversarial judge),
    quote the sentence the owner acts on and say whether it does the right thing. A place where eco drops a lane Manuel
    said stays fresh is an issue.
(c) The owner's extra drops, not in Manuel's list: `why` investigators, the writer arena, `interrogate`. Quote where
    each is dropped and say whether criterion 4's ceiling actually requires it.
(d) The tier file lookup: `git rev-parse --git-common-dir` from a linked worktree finds the main checkout's file;
    an `eco` in a worktree's own `.claude/state` does nothing (the owner accepts this). Show both.
(e) The hook: `tests/hooks/delegation.sh` table B rows behave the same with each tier file; the hook is byte-identical
    to a9ebdac.
(f) Autopilot-stack step 1: the owner brief names the tier and a replacement owner inherits it; quote.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/135-9454e38/worker-runtime.md`.
