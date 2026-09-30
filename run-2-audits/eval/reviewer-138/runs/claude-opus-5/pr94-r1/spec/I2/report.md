The change is prose and patches: it makes a scenario table the first thing `architect` produces for a design with state, and posts it on the ticket before implementation. Five of the six criteria hold as written and every patch applies; three items are about the path around the new rule rather than its words — the skill that owns the deliverable, the ticket-body check that now reads the table, and the designs that never reach `architect` at all.

## Walk

1. Ticket step 5 selects the playbook and runs its steps verbatim from step 1; a cross-cutting diff never skips `architect` (`template/.agents/skills/poteto-mode/playbooks/ticket.md:9`).
2. The selected playbook's architect step runs it: always in Feature (`feature.md:6`, skip recorded as a reason), only when the work crosses a function boundary in Bug fix (`bug-fix.md:9`), Refactoring (`refactoring.md:9`) and Perf issue (`perf-issue.md:16`).
3. `architect` Phase B passes `references/runner-prompt.md` to each runner and states the package shape (`template/.agents/skills/architect/SKILL.md:32`).
4. The patched runner prompt makes the first deliverable, for a design with state, the scenario table, then the contract derived from it, then the test list, and for stateless code crossing a function boundary the usage and signature sketch (`architect/references/runner-prompt.md:7-8`) — criterion 1's shape, in the shape the ticket names.
5. The same bullet carries the refusal cell verbatim and the rule that such a cell is cut only after the refusal was run and seen (`runner-prompt.md:7`) — criterion 2.
6. The prompt's closing paragraph tells the orchestrator to append the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (`runner-prompt.md:10`).
7. Ticket step 6 carries the posting rule: `gh issue edit N --body-file`, the `Posted by`/`Approved by` first line, the human edits it, a stop only with `/architect with checkpoint`, and that the Spec brief carries it (`ticket.md:10`). `review-brief.sh:222` does write the whole issue body to the brief, so that claim holds; the rule sits in step 6 rather than a step of its own, which P25 records as a deliberate choice.
8. The four delegation steps say the test is written from the table before the implementation, one assertion per cell in the table's order, and that a writer who cannot implement a cell stops and reports it (`feature.md:12`, `bug-fix.md:9`, `refactoring.md:11`, `perf-issue.md:16`) — criterion 4.
9. `to-spec`'s Testing Decisions names the table as the shape for stateful work (`template/.agents/skills/to-spec/SKILL.md:66`) — criterion 5.
10. The knowledge page exists with what it is, the shape, where it goes and the #42 example (`docs/knowledge/core/SCENARIO-TABLE.md`), is listed in `INDEX.md`, is copied to `template/docs/factory918/SCENARIO-TABLE.md` by `build_core`, and the `knowledge` skill's slim list names it — criterion 6. `python3 tools/build_knowledge.py` then `check_knowledge.py` run clean at 119 files and change nothing.
11. `./factory918.sh sync` on a copy of the reviewed tree applied all 19 patches, including the two new ones, and left the tree clean.

## Would break

1. **`architect`'s own skill still names the usage sketch as the first deliverable, and the synthesized package has no slot for a table.** The patch reaches `references/runner-prompt.md` only. `SKILL.md:32` still tells the runner what the package is, and `references/rationale-template.md:9-11` is the shape it must fit: a "Usage (caller's view)" section whose note reads "Write this first, before the type sketch", then Shape, Synthesis decision, Tradeoffs, Alternatives, Open questions, Next step. There is no section for a table, a contract or a test list. A runner reads both files (the prompt says to read the skill in full) and gets two different answers for a stateful design; the orchestrator synthesizes into the template and has nothing shaped to post.

```
- [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list
```

Documented step: `template/.agents/skills/architect/SKILL.md:32`, "Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it."
Result: for a design with state the skill and the runner prompt disagree on the first deliverable, and the table can be dropped at synthesis because the package shape has no place to keep it, with nothing printed or refused when it is.
spec: criterion 1

2. **A table posted on the ticket becomes the ticket's named paths for the overlap check.** `overlap.sh` reads every backticked whitespace-free token in the issue body as a pathspec and skips only a `## Diff` section (`overlap.sh:48-50`; P24 settles it). Nothing in the diff excludes `## Testing decisions` or `## Design`, and nothing tells the table's writer to avoid backticked paths. Run the script's own extraction over the table this change publishes as the durable example: 22 tokens, of which `tests/poteto-mode/overlap.sh` is a real path in this repository. The table itself shows the collision was already met by hand — row 14 carries the note "unbackticked here so this ticket's own check does not trip on it".

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation
```

Documented step: `ticket.md:10` appends the table to the body; `ticket.md:5` then runs `overlap.sh N`, whose printed overlaps come from "a path the ticket names in backticks".
Result: on any check-mode run after the table is on the body — the `Approved by <name>` case, where the human approves and the table is on the ticket before step 1 (#42's second run worked exactly that way), or a lane restarted mid-ticket — a PR touching a file the table mentions is reported as an overlap and step 1 exits 1 and stops the ticket; a table holding a dot-dot or absolute token exits 2. Both come from the table's prose, not from the ticket's real paths.
spec: criterion 3

3. **A design with state that never reaches `architect` gets no artifact, silently.** Criterion 3's trigger is the design adding state; the implementation's trigger is the architect step running, because Ticket step 6 opens "The selected playbook's architect step adds the ticket's own". In Bug fix, Refactoring and Perf issue `architect` runs only when the work crosses a function boundary, and the one clause this change strengthened names cross-cutting diffs, not state. A bug fix that changes an exit code or a state file inside one function has state, crosses no boundary, and is not cross-cutting: no table is written, none is posted, and no step says so.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/bug-fix.md:9`, "If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it." (same shape at `perf-issue.md:16` and `refactoring.md:9`).
Result: the stateful work the rule exists for can run to a PR with no scenario table and no artifact beyond its criteria, and the run proceeds without a message; the reviewer then has nothing under `## Testing decisions` to check cells against and is back to the prose-sketch review the ticket set out to end.
spec: criterion 3

## Fails open

## Not asked for

hard findings: 3
