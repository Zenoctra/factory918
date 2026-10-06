## Final message

/private/tmp/wsbox/w-20261005-191213-1405/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

## Would break

1. **`--body-file` replaces the body the step says it appends to.** Ticket step 6 names a command that overwrites; nothing tells the agent to read the existing body first. `gh issue edit N --body-file f` sets the body to the file, so a file holding only the table drops What to build, Acceptance criteria, Parent and Blocked by, and `review-brief.sh` then pastes a body with no intent in it into the Spec brief. One clause fixes it: read `gh issue view N --json body`, append, write the whole body back.

```
before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6` (and `docs/knowledge/core/SCENARIO-TABLE.md:43`).
Result: the ticket body becomes the table alone; the spec is gone from the ticket and from every later brief.

2. **MANUAL's count of what a project carries is now false, and the sixth document is in neither map.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." A project now carries five slim documents, and `SCENARIO-TABLE.md` appears in no reading list a person is sent to; `PHILOSOPHY.md:64` names the others and omits it too.

```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```

Documented step: `docs/knowledge/core/MANUAL.md:165-170`.
Result: the reader is told four and finds five, with no line saying when to open the new page.

## Fails open

## Standards breaches

## Fix alongside

3. **Duplicated Code.** The writer paragraph ("The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, ... never fills it in.") is pasted verbatim into four playbooks and their four patches. The repo already duplicates the `architect` skip clause the same way, so this follows precedent rather than breaking one.

4. **Divergent Change in Ticket step 6.** The step now holds the spec's seams and the architect artifact's posting rule, and it sits after step 5's "run that playbook's steps verbatim", so the "before implementation" rule is reached on time only through the delegation steps' forward pointer.

5. **Trigger drift.** The to-spec patch's stateful trigger drops "rounds", which the other four statements of the same trigger keep.

hard findings: 2
```
