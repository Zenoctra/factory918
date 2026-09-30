# Standards report, ab47eb9

Verified in a scratch copy under git: `python3 tools/build_knowledge.py` and `./factory918.sh sync` both leave `git status` clean; every patch in `series` applies (the two new ones included); `docs/agents/issue-tracker.md` and the template copy are identical; INDEX line counts (93, 71, 88) match `wc -l`; the slim `SCENARIO-TABLE.md` is the core page minus its header (79 lines). The playbook edits, the runner-prompt and to-spec patches are listed in `series` and described in `SOURCES.md` items 13 to 15; `ticket.md` is in `sync`'s `keep_files`, so its edit needs no patch.

## Would break

## Fails open

## Standards breaches

1. **A sentence known to be false stays in `SOURCES.md` while the finding records that it is false.** `docs/M0-findings.md` (2026-09-22) says `sync` "bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth", and the same commit edits `SOURCES.md` without touching line 3, which still reads "`factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION." Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it". The fix is the one line, not a note elsewhere saying the line is wrong.
   ```
   +2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

2. **`SCENARIO-TABLE.md` carries three Diátaxis modes.** "The shape" is reference, "Where it goes" is a procedure (the command, the first-line rule, the checkpoint phrase, restated from Ticket step 6), "Why" is explanation. Standard: `CODING_STANDARDS.md`, Markdown, "One Diátaxis mode per file". The page's stated reader ("the person who opens a ticket and finds a table ... and the agent that has to write one") is served by explanation plus a pointer to Ticket step 6 for the procedure; restating the procedure gives the rule a fourth home (see 3).
   ```
   +On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. Posting is the record. ...
   ```

## Fix alongside

3. **Duplicated Code: the trigger clause is spelled out in eight places and already drifts.** "(a file it reads or writes, exit codes, rounds, or more than one actor)" appears in P25, Ticket step 6, the runner prompt, the four playbook sentences' referent, the page and the glossary; the to-spec patch drops "rounds", the glossary drops the list. A later change to the trigger (the S1 clause, for one) must find every copy.
   ```
   +- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: ...
   ```

4. **A rule for the orchestrator sits in the runner-facing file.** The runner prompt is "passed through to every parallel candidate runner"; its new last sentence says what the orchestrator does after synthesis. `architect/SKILL.md` Phase C ("Default: proceed directly to implementation with the synthesized design") is untouched, so an `/architect` run outside the Ticket playbook never learns to post the artifact. Writing-for-agents: address the reader who acts.
   ```
   +Then the type sketch, function signatures, module map, and prose rationale ... The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.
   ```

5. **The manual does not carry the human's new touchpoint.** `core/MANUAL.md` is "what the human does at each point"; P25 adds one (read the table on the ticket, edit it if wrong, say `/architect with checkpoint` to be stopped first) and the manual's Execution section (L75) does not mention it; `grep -i "scenario\|Testing decisions"` over the manual finds nothing.

6. **The posted table's backticks feed `overlap.sh` on a step-1 rerun.** Check mode skips only `## Diff` (`overlap.sh:48`) and runs without `GIT_LITERAL_PATHSPECS`, so once step 6 has appended a table, a restarted session's step 1 reads every backticked cell token as a pathspec: a glob in a cell (`*.sh`) matches wide and stops the ticket with a spurious exit 1; an absolute path exits 2. Both are loud, so not a hard finding, but nothing in step 6, the page or the runner prompt tells the table's author that its backticks are pathspecs from then on; row 14 of the #42 table shows the author working around it by hand ("unbackticked here so this ticket's own check does not trip on it").

hard findings: 0
