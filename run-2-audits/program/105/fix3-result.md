# PR #120 (ticket #105) fix lane, review round three, Act on item 1

Branch: wt/105-fix3 (from origin/feat/speed-lessons f810542), not pushed.
Commit: a134634b4203de8bdfea64970248a55d6a339f02 "Point every lane-launching skill step at the poll rule"

## Steps changed (pointer added once per step)
Vendored playbooks got "Poll each lane's result file per the poll rule (Ticket step 0)." at the end of the sentence that launches the lanes:
- feature.md step 1 (how), step 2 (architect), step 7 (interrogate)
- refactoring.md step 1 (how), step 3 (architect)
- bug-fix.md step 2 (how + why seeding)
- perf-issue.md step 2 (how)
- hillclimb.md step 1 (how)
- investigation.md step 1 (how, why). New patch: patches/pstack/poteto-mode/playbooks/investigation.md.patch, appended to patches/series.
- opening-a-pr.md, the unnumbered "A subagent that opens a PR runs interrogate" paragraph (see flags)

ticket.md (ours, no patch) got the pointer with "(step 0)":
- Ticket step 5 (how, why, blast-radius; one pointer after the how/why sentence covers the step)
- Ticket step 8 (review round one at first push): "poll each review lane's result file per the poll rule (step 0);"
- Ticket step 9 (trail review, cross-model lanes)
- Design hole step 2 (architect Phase B)
- Would-break fix step 1 (next review round)

Patches regenerated with the patches/README.md command: feature, refactoring, bug-fix, perf-issue, hillclimb, opening-a-pr (changed), investigation (new).
SOURCES.md item 16 extended by one clause naming the added steps and the new investigation patch.

## Checks
- ./factory918.sh sync after the commit: exit 0, git status --porcelain empty. ok
- Regenerating all seven changed patches after the commit: git status --porcelain empty, byte-for-byte. ok
- bash tests/spec-review/no-stale-wording.sh: "ok: no stale wording". ok
- grep -rn "sleep 60" template/.agents/skills/poteto-mode/playbooks/: no output (exit 1). ok
- bash tests/spec-review/review-brief.sh: ok 648 assertions. ok
- bash tests/poteto-mode/overlap.sh: ok 57 assertions. ok

## Flags
- opening-a-pr.md's interrogate sentence is a paragraph, not a numbered step; added because it is a subagent launching lanes, the exact case the poll rule is for. Drop it if only numbered steps count.
- Not changed, with reason: prototype.md step 6 hands off to Feature/architect rather than launching; babysit.md merge-ready check reads a spec-review comment and launches nothing; autopilot-full step 3, autopilot-stack owner steps and orchestrate's coordinator run in the root session, which the poll rule exempts; multi-phase-plan's template lines 40-155 are plan-body placeholders, and its launching steps (3 and the swarm box) already carry the pointer.
