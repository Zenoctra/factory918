## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Shotgun Surgery: the design-hole rule is restated in five documents and three patches.** The definition of a hole, the `restart` line and the not-merge-ready consequence are written out in `spec-review/SKILL.md` step 5, `docs/agents/review-ladder.md` rung 1, `babysit/SKILL.md` step 4, `poteto-mode/playbooks/babysit.md` step 6 and `poteto-mode/playbooks/ticket.md`, each mirrored again in `patches/`. A wording change touches eight files, and only the two scripts' shared `ref=` line has a test holding the copies together (`tests/spec-review/review-brief.sh`, `fragment()`). The nesting rule (`AGENTS.md`) forces the patch mirrors, but nothing forces the five prose copies to agree.

```
+   - A review comment carrying the line `restart` names a design hole and is not a merge-ready comment whatever its count: the Ticket playbook's Design hole section returns the work to `architect`, and the PR is ready only when a later review comment without a `restart` line reads `act-on items: 0`.
```

2. **`review-ladder.md` rung 1 is now one paragraph of roughly 470 words.** The new design-hole sentence adds about 150 of them inside an already unbroken bullet, so the rung is read as prose rather than scanned. `CODING_STANDARDS.md` sends agent-facing markdown through `/writing-for-agents`; the rung reads against it. The same content is already a structured section in `ticket.md` ("Design hole", six numbered steps), which the rung could point at.

```
+- **Rung 1 — spec-review.** ... A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a cell of the ticket's scenario table (its expected outcome, a new row or column, or the meaning of a term the cells use), a signature or a usage in its `## Design` sketch, or an acceptance criterion; ... Detection is sharpest for a table and softest for a criterion; all three are marked the same way.
```

hard findings: 0
