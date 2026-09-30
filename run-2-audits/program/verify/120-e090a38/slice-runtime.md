# Slice: live runtime floor
This PR is prose an agent follows. The floor is whether an agent reading only the changed playbooks does the right
thing, plus the mechanical paths it names. At the SHA:
(a) Read `template/.agents/skills/poteto-mode/playbooks/ticket.md` whole, and `autopilot-stack.md`, `feature.md`,
    `bug-fix.md`, `babysit.md`, `opening-a-pr.md` at the changed ranges. For each of the ticket's 16 criteria, quote
    the sentence an agent would act on and say whether an agent with no other context would do the right thing.
    A rule stated two ways that disagree, or a pointer to a step that does not say what the pointer claims, is an issue.
(b) The poll rule: stated once in Ticket step 0 and pointed to from every step that launches a lane. List every
    playbook step under `template/.agents/skills/poteto-mode/playbooks/` that launches a lane (grep for subagent,
    lane, fan-out, swarm, arena, delegate) and say which carry the pointer and which do not.
(c) Autopilot-stack steps 6 and 7 with the rewrite exception: construct the sequence "root rebases a parent with a
    live child" and say whether the two steps now agree, quoting both.
(d) The P29 amendment against `autopilot-stack.md` and `ticket.md`: who retargets through trunk, stated the same way
    in all three places.
(e) The `sync` path: in a scratch clone, run `./factory918.sh sync` from the SHA and confirm the vendored copies
    under `template/.agents/skills` equal what the patches produce (no hand edits to a vendored file outside a patch).
(f) The owner's Blocked item: the ticket says a child's completion notification reaches the root, never the owner;
    the owner observed otherwise. Quote the sentence as it landed and say whether the poll rule is correct either way.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/120-e090a38/worker-runtime.md`.
