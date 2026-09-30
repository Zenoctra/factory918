## Walk

1. `architect`'s runner prompt (patch + `template/.agents/skills/architect/references/runner-prompt.md`) splits the first deliverable: scenario table, contract, test list when the design has state; usage and signature sketch otherwise; then the type sketch and rationale as before.
2. The same paragraph carries the refusal-cell rule and the "cut only after the refusal was run and seen" clause.
3. Ticket playbook step 6 adds the posting rule: `gh issue edit N --body-file` under `## Testing decisions`, `Posted by the agent <date>`/`Approved by <name> <date>`, human edits in place, stop only with `/architect with checkpoint`, brief carries it because `review-brief.sh` pastes the body (confirmed: `review-brief.sh` writes `gh issue view --json body` whole into `ticket.md`).
4. Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3 each gain the test-from-the-table sentence and the stop-and-report clause, in patch and template.
5. `to-spec`'s Testing Decisions list gains the table as the shape for stateful work, in patch and template; both new patches are in `patches/series` and `SOURCES.md` (13-15), and their context matches the pins under `research/`.
6. `core/SCENARIO-TABLE.md` is added as a sixth core document, wired into `CORE_DOCS`, `INDEX.md`, the glossary and `knowledge/SKILL.md`; the mini-TOC offsets and the 88/79 line counts check out.
7. `docs/agents/issue-tracker.md` (both copies) documents the two appended sections.

## Would break

1. **`MANUAL.md` still says a project carries four core documents.** The diff makes it five; the "Where to read more" list has no `SCENARIO-TABLE.md` row, so a reader following the manual does not learn the page exists in the project copy. `AGENTS.md` got its count fixed; this one did not.
Documented step: `docs/knowledge/core/MANUAL.md:165` (and the generated `template/docs/factory918/MANUAL.md:146`)
Result: a false count and a missing entry in the only list of what `docs/factory918/` holds.
```
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```

2. **The posted table feeds `overlap.sh` as pathspecs.** Step 1 and step 8 take every backticked token outside a `## Diff` section as a pathspec. Step 6 now appends a table full of backticked tokens to the same body; the #42 example alone quotes `.claude/state/program` and `tests/poteto-mode/overlap.sh`. Nothing excludes `## Testing decisions`.
Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6` ("appended to the ticket's body") against step 8's `overlap.sh N --diff`
Result: step 8 reports overlap on files named only as examples, exits 1 and tells the agent to merge an unrelated PR first; #42's own row 14 kept a path unbackticked to dodge exactly this.

## Fails open

## Not asked for

3. **Stray `M0-findings.md` claim.** The dated line also records that `sync` bumps no VERSION, contradicting `SOURCES.md`; unrelated to the table.

hard findings: 2
