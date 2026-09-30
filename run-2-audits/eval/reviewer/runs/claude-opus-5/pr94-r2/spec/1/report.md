## Walk

1. Ticket step 1 runs `overlap.sh N`; its awk now sets `skip` on `## Diff`, `## Testing decisions` and `## Design`, so a path a posted table quotes is not a path the ticket names. A `###` subheading inside a skipped section does not clear `skip`, which is what the rule wants.
2. `tests/poteto-mode/overlap.sh` adds a second case 17 whose body is only those two sections; the expected `paths: none` matches the script's empty-paths branch (`overlap.sh:51`), and the pre-existing case 17 keeps its `## Notes` token, so its expectation without `paths: none` is still right. The duplicate number follows the file's own convention (two cases named "2").
3. Ticket step 6 now reads the body with `gh issue view N --json body -q .body`, adds `## Testing decisions` at the end, and writes the whole file back with `gh issue edit N --body-file`, with the reason (`--body-file` replaces, never merges) stated; a failed write stops the lane before implementation.
4. Both `SCENARIO-TABLE.md` copies say the same in "Where it goes", and add that the step-1 check skips both sections. The template copy is the core copy with the header stripped.
5. `architect/SKILL.md` Phase B gains the stateful-design sentence, in the template copy and in a new patch. The patch's `@@ -29,7 +29,7 @@` context matches the pinned upstream (`research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md:30-32`), and `patches/series` lists it. SOURCES.md line 14 names both files.
6. `to-spec` SKILL.md and its patch now cite "the rule above about paths and snippets", which is the line that exists ("Do NOT include specific file paths or code snippets").
7. `MANUAL.md` counts five project documents and lists `SCENARIO-TABLE.md`; `INDEX.md` moves to 175 lines, matching one added line; `build_knowledge.py`'s docstring now matches its code, which copies every core document except `CONVERSATION-DIGEST` (line 136).

## Would break

## Fails open

1. **A failed body read overwrites the ticket.** Ticket step 6 and both `SCENARIO-TABLE.md` copies guard the write and not the read: if `gh issue view N --json body -q .body` fails or returns nothing, the file holds only the new section and `gh issue edit N --body-file` replaces the whole ticket body with it. The step's own reason for the read is that the command never merges, so the read failing is the case that costs the ticket.

```
read the current body into a file (`gh issue view N --json body -q .body`), add the section at the end ... If the write fails, stop and report the error
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6`; same text at `docs/knowledge/core/SCENARIO-TABLE.md` "Where it goes".
Result: the lane proceeds on an empty read and silently replaces the ticket's Problem, Decision and Acceptance criteria with the table alone.

## Not asked for

hard findings: 1
