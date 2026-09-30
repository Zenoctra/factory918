## Walk

1. Criterion 1: `patches/pstack/architect/references/runner-prompt.md.patch` and the template copy make the first deliverable the scenario table, then the contract, then the test list for a design with state, the usage and signature sketch otherwise, and say the orchestrator appends the synthesized one to the ticket (`## Testing decisions` / `## Design`).
2. Criterion 2: the same bullet carries the refusal cell and "Cut such a cell only after the refusal was run and seen", in the patch and in `template/.agents/skills/architect/references/runner-prompt.md:7`.
3. Criterion 3: Ticket step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`) carries the posting rule, the first-line stamp, the human-edits clause, the `/architect with checkpoint` opt-in (which `architect/SKILL.md:48` supports) and the review-brief sentence; `spec-review/scripts/review-brief.sh:222,333` does paste the whole ticket body.
4. Criterion 4: Feature 4, Bug fix 3, Refactoring 5 and Perf issue 3 each carry the test-from-the-table sentence and the stop-and-report clause. I applied all four patches to the pins under `research/3-pstack/` in a scratch repo: each applies and reproduces its `template/` copy byte for byte.
5. Criterion 5: `to-spec` Testing Decisions gains the table bullet; the new patch applies to `research/1-matt-pocock/.../engineering/to-spec/SKILL.md` and reproduces the template copy; both new patches are listed in `patches/series`.
6. Criterion 6: `SCENARIO-TABLE.md` is core document six. A rebuild in a copy of the tree (`tools/build_knowledge.py`) reproduces `docs/knowledge/` and `template/docs/factory918/` with no change; `check_knowledge.py` passes at 119 files; the mini-TOC offsets (14, 24, 41, 49, 80) land on their headings; grep for "scenario table" hits `INDEX.md:12`, `GLOSSARY.md:51` and P25.
7. Local gates: `tests/hooks/delegation.sh` (55), `tests/spec-review/review-comment.sh` (82), `review-brief.sh` (334), `layout.sh` and `no-stale-wording.sh` all pass.

## Would break

1. **The command the posting step names replaces the ticket body instead of appending to it.** `gh issue edit N --body-file F` sets the body to F's contents; there is no append form. An agent that follows step 6 literally (write the table, run the command) drops `## What to build`, `## Acceptance criteria` and `## Blocked by` — the spec `review-brief.sh` pastes and the criteria the falsifiability pass was built on. Nothing in `docs/agents/issue-tracker.md` gives a body-edit recipe, so the round trip (fetch the body, append, write the whole file back) is nowhere stated. One clause in step 6 and in `SCENARIO-TABLE.md:43` fixes it.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`")
Result: the body is overwritten with the table alone; the ticket's ask, criteria and blockers are gone and the next brief has no spec.
spec: criterion 3

2. **A posted table's backticked paths become `overlap.sh` pathspecs.** Check mode reads every backticked whitespace-free token in the body and skips only a `## Diff` section (`overlap.sh:48-50`). After step 6 posts a table and contract, a later step-1 run on the same ticket — the case #42 itself went through after PR #87 was closed — matches any open PR touching a path the design merely names (`.claude/state/program`, `tests/poteto-mode/overlap.sh`) and stops at exit 1, or hits git's fatal at exit 2 on a token that is no path. #42's own table row 14 works around this by leaving tokens unbackticked; this diff makes posting a standing rule and carries no such instruction.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` (step 1 runs `overlap.sh N`, "the ticket body's backticked tokens as pathspecs")
Result: a re-run of a ticket that carries a posted design stops on its own design's paths; the human has to edit the ticket to start the work.
spec: criterion 3

3. **The core-document sweep stopped at AGENTS.md and INDEX.md.** `MANUAL.md` still tells the reader a project carries "only the first four" and lists four; a project now carries five, since `build_core` copies every core document except the digest. `PHILOSOPHY.md:64`'s pointer list and `tools/build_knowledge.py:8` ("copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY … into template/docs/factory918/") name four as well, in a file this diff edits.

```
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```

Documented step: `docs/knowledge/core/MANUAL.md:165` and `template/docs/factory918/MANUAL.md:146`, "Where to read more"
Result: the reader-facing map of the core set is wrong by one and never names the new page; `/knowledge` finds it only through INDEX.md and the glossary.
spec: criterion 6

## Fails open

4. **A stateful design whose playbook skipped `architect` still produces no artifact, and nothing sends it back.** The posting rule hangs off the architect step. Feature step 2 still allows `architect skipped: <reason>` for any diff that is not cross-cutting, and Bug fix 3, Refactoring 3 and Perf issue 3 run `architect` only when the change crosses a function boundary. So a one-file change that writes a state file or adds an exit code reaches implementation with no table, no stop and no record — the failure this ticket opens with. The intent outranks the criteria, so the gap belongs back in design, not on the PR.

```
The ticket had no Testing decisions because it was planned as prose, and nothing sent it back for them when the design added state.
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/feature.md:6` (`architect skipped: <reason>`), `bug-fix.md:9`, `perf-issue.md:16`, `refactoring.md:9` ("If the target crosses a function boundary")
Result: state ships with no design artifact and nothing refuses it; the reviewer has only the criteria to judge against, which is the pre-#89 state.
spec: criterion 3

## Not asked for

hard findings: 4
