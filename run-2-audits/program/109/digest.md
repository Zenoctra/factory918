# #109 digest (owner, safe mode)

Ticket: #109 "Add an eco tier that keeps only the surprise-finding lanes fresh". Settled by Manuel on the ticket
("I agree with your choices here"); not reopened. Base origin/main (a9ebdac), branch feat/eco-tier, PR targets main.

Required reading: the ticket body; playbooks ticket.md, feature.md, autopilot-stack.md, opening-a-pr.md, babysit.md
under .claude/skills/poteto-mode/playbooks/; architect, how, spec-review, blast-radius, show-me-your-work skills;
template/.claude/hooks/delegation.sh and tests/hooks/delegation.sh; MANUAL.md "Execution"; DECISIONS P11, P19,
P20, P25, P105, P110, P111; postmortem delegates.md and summary.md, waits.md.

Facts (Ticket step 0): poll rule (poll the exact absolute file, never end the turn); Closes links only on a
default-branch base, and "closes" beside any other number links it; a conflicting PR gets no Actions run;
gh issue edit --body-file replaces the body. Vendored playbooks change only via patches/ + series + SOURCES.md.
#108 works in parallel on review-brief.sh and its test: do not touch. #132 (hook misses an interpreter write):
do not fix, do not rely on the hook's matching for eco's size rule.

Numbers for the ledger line (waits.md class sums, five fresh owners, #90's 60-min rate-limit gap removed):
waiting on children 267 min + turn ended 86 min of 506 min = 70%; waiting on children alone 53%;
model latency 98 min (15 to 25 min per owner). Lanes that changed the outcome: 9 of 77 (blast radius, both
reviewer axes, trail review, arena judge, one writer flag). Found nothing: how explorers/explainers, review
wrapper lanes, small fix lanes, records lanes.
