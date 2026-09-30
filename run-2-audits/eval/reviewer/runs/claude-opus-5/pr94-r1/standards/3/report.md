# Standards report

## Would break

1. **The named command replaces the ticket body it is told to append to.** `gh issue edit N --body-file` sets the body; it does not append. Nothing in the new step or in `docs/agents/issue-tracker.md` tells the agent to read the current body first and re-emit it with the new section. An agent that follows the step literally writes the table to a file, runs the command, and the ticket loses `## What to build`, `## Acceptance criteria`, `## Parent` and `## Blocked by`. Both the writer's brief and the Spec brief then carry a ticket with no intent, since `review-brief.sh` pastes the body whole. `docs/agents/issue-tracker.md` "Conventions" lists create, read, list, comment, label and close, and no body-edit operation to inherit the read-then-write shape from; its own new paragraph says only "may append two more sections".

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` — "the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`".
Result: the whole ticket body is overwritten by the design artifact.

```
6. ... and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`
```

## Fails open

## Standards breaches

2. **The posting instruction is addressed to the orchestrator inside the file handed to the runners.** `runner-prompt.md` is, by its own first paragraph, passed through to every candidate runner. The new closing sentence instructs the orchestrator, who never reads this file as its own instruction; the four playbooks' architect steps and `architect/SKILL.md` say nothing about posting. Only the Ticket playbook carries the rule, so a non-ticket `/architect` run has no instruction at all. `CODING_STANDARDS.md`, Markdown: written with `/writing-for-agents` (one actor per document).

```
Then the type sketch, function signatures, module map, and prose rationale ... The orchestrator appends the synthesized first deliverable to the ticket before implementation
```

## Fix alongside

3. **Dangling reference.** In the `to-spec` bullet, "the rule above" is the no-code-snippets rule two sections up, not the nearest rule above it in Testing Decisions; name the section.

```
It is a decision, not a code snippet, so the rule above does not exclude it.
```

4. **The inserted sentence orphans the step's last instruction.** Perf issue step 3 now ends `... never fills it in. Capture a post-fix trace.`; the trace instruction belongs beside "review the diff".

hard findings: 1
