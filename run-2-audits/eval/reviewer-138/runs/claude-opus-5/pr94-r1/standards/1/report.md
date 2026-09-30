# Standards report

Two plain sentences first. The prose and the patches are internally consistent and the machinery holds: `python3 tools/build_knowledge.py` and `./factory918.sh sync` both leave the tree byte-identical, every patch in `series` applies, and the five tests that exist at this commit pass. What breaks is the hand-off: the one command the new step gives replaces the ticket body instead of appending to it, and `architect`'s own two files were left at the old first deliverable, so the design that has to reach the ticket may never be written.

## Would break

1. **`gh issue edit N --body-file` replaces the ticket body; the step says it appends.** `gh issue edit` has no append flag: `--body-file` sets the body from the file. An agent that follows the step as written, with a file holding the synthesized table, destroys `## What to build`, `## Acceptance criteria`, `## Parent` and `## Blocked by`. Nothing notices: `gh` prints the issue URL, `review-brief.sh` then briefs an empty spec (it writes `gh issue view N --json body` straight to `ticket.md`), `interrogate` step 2 loses the intent it reads verbatim, and Ticket step 8's Verification section has no criteria left to quote. Every other write to an issue in this repo is documented with the exact command that performs it; this one names a command that performs the opposite. The fix is the read-modify-write, in one clause: view the body to a file, append the section, then `--body-file` that file.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`, step 6.

   ```
   before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`
   ```

   Standard: `docs/agents/issue-tracker.md:7-12`, "Conventions" — each write is documented with its exact command (`gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.`). The new paragraph at `docs/agents/issue-tracker.md:26` documents the two appended sections but not the operation that appends them, so the half-written command in the playbook is the only copy.

   Result: the ticket body is replaced by the table alone, silently, at the moment the ticket's own spec is supposed to grow.

   spec: criterion 3

2. **`architect`'s own two files still document the old first deliverable, and the package has no slot for the table.** Only `references/runner-prompt.md` was patched. `SKILL.md` Phase B, the file the orchestrator reads, still enumerates the package as usage-first, and `references/rationale-template.md`, which the same patched sentence tells the runner to shape its prose by, has eight headings and none of them holds a scenario table, a contract or a test list. Arena returns one synthesized package shaped by that template, so for a stateful design the orchestrator can finish Phase B holding nothing to post. Both files are vendored, so the fix is two more patches in `patches/series` beside the one this PR adds.

   Documented step: `template/.agents/skills/architect/SKILL.md:32`, Phase B.

   ```
   Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it.
   ```

   ```
   # rationale-template.md headings, whole
   ## Problem / ## Usage (caller's view) / ## Shape / ## Synthesis decision
   ## Tradeoffs accepted / ## Alternatives considered / ## Open questions and risks / ## Next implementation step
   ```

   Standard: `CODING_STANDARDS.md`, Markdown — "Written with `/writing-for-agents` when an agent reads it"; that skill's Pruning rule, "Keep each meaning in a **single source of truth**", and its relevance rule, "A line loses relevance ... by going stale as the behaviour or world it describes changes".

   Result: a runner that follows `SKILL.md` and the template writes usage-first with no table; a runner that follows the patched runner prompt writes a table with no section to put it in. Either way the stateful branch of criterion 1 yields no artifact, and no check exists to say so.

   spec: criterion 1

3. **The posting rule lives only in a Ticket step reached after the playbook has already opened the PR.** Ticket step 5 hands the whole selected playbook off ("run that playbook's steps verbatim from step 1"), and every playbook ends at **Opening a PR**. An orchestrator working the Ticket playbook in order therefore reaches step 6, the only place that says to post before implementation, after implementation, verification and the PR. The playbooks do not close the gap: Feature step 2 and Refactoring step 3 are the architect steps this diff touches and neither mentions the artifact, while Feature step 4 and Refactoring step 5, two steps later, already presume it posted ("The brief carries the ticket's design artifact (Ticket step 6)"). Step 6's existing `tdd` sentence sets the precedent for a constraint that applies during step 5, but it carries no "before" in it; this one does. One clause in each of the four architect steps, the patches this PR already opens, puts the rule where the agent acts.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:9`, step 5, then step 6.

   ```
   5. Select by content and run that playbook's steps verbatim from step 1 ...
   6. ... The selected playbook's architect step adds the ticket's own: ... and before implementation the synthesized table is appended to the ticket's body
   ```

   ```
   # feature.md:6, the architect step, unchanged on this point
   2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
   ```

   Result: the writer's brief carries no artifact, the table lands on the ticket after the PR is open, and the review reads a ticket whose Testing decisions postdate the code it is judging.

   spec: criterion 3

## Fails open

4. **A second architect run appends a second `## Testing decisions`, and nothing says the first one goes.** The design-hole restart is a documented path here (this ticket's own Run under, rule 5: "a design hole is not fixed on the PR but returns to architect, scoped to that cell"), and a restart re-synthesizes the table. Step 6, P25, `issue-tracker.md:26` and the page all describe the first posting only; `issue-tracker.md:26` says the human "edits them in place", which is the human's path, not the agent's. Two sections with the same heading both reach the Spec brief, because the body is pasted whole, and the `spec: table <row>/<column>` line a reviewer must write no longer names one cell.

   Documented step: `docs/agents/issue-tracker.md:18`, "Every ticket has this shape, in this order", read with `docs/agents/issue-tracker.md:26`.

   ```
   The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state
   ```

   Result: the second posting proceeds silently, the ticket carries two Testing decisions sections, and which one is spec is undecided.

   spec: criterion 3

## Standards breaches

5. **The trigger condition for the table is written five times and two copies drop `rounds`.** The playbook, the runner prompt, P25 and the page all say "a file it reads or writes, exit codes, rounds, or more than one actor". The `to-spec` bullet and the knowledge index's "read when" both omit `rounds`, so a design whose state is rounds — review rounds, retry rounds, the exact case `babysit` and `spec-review` live on — gets no table from the planning path and does not point the reader at the page. Same one-place-edit rule as item 2: `CODING_STANDARDS.md`, Markdown, via `/writing-for-agents`, "Keep each meaning in a **single source of truth**".

   ```
   # template/.agents/skills/to-spec/SKILL.md:66
   - For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table
   ```

   ```
   # docs/knowledge/INDEX.md:12 and tools/build_knowledge.py:42
   Designing or reviewing anything with state: a file, exit codes, more than one actor.
   ```

## Fix alongside

6. **`SOURCES.md` line 3 is false and this commit says so in another file.** The new M0-findings line records that `sync` bumps no VERSION and touches no network; `SOURCES.md` line 3, in a file this diff edits two lines below, still promises both. One sentence, in a file already open.

   ```
   # SOURCES.md:3
   `factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.
   ```

   ```
   # docs/M0-findings.md, added
   factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

7. **The table's backticked vocabulary becomes `overlap.sh`'s pathspecs.** Step 1 reads every backticked whitespace-free token in the ticket body as a pathspec and skips only a `## Diff` section (`overlap.sh:48`). Step 6 now appends a section full of them. Within one run step 1 is already past, but a resumed or restarted ticket re-runs step 1 against the grown body, and a cell that needs a dot-dot or absolute path in backticks makes the check exit 2 (#42's own table un-backticked that example for exactly this reason, and only inside that table). Neither the runner prompt, step 6 nor the page carries the rule; one clause in the page's "The shape" would.

   ```
   # overlap.sh:48
   outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
   ```

8. **The writer's rule is pasted verbatim in five places.** The 43-word clause from "When it is a scenario table" to "never fills it in" appears in all four playbooks and again in the page's "Where it goes". Four playbook copies are defensible — one file is read per branch — but the fifth is prose about the same rule, and `SCENARIO-TABLE.md` is where a future edit will start. Same duplication rule as items 2 and 5; a judgement call, since the criteria asked for the playbook copies.

   ```
   # feature.md:12, bug-fix.md:9, perf-issue.md:16, refactoring.md:11
   a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

hard findings: 4
