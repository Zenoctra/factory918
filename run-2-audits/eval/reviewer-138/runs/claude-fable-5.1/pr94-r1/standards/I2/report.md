# Standards review, ab47eb9

For a person: the change is prose and patches, and the machinery holds: `tools/build_knowledge.py`, `tools/check_knowledge.py` and `./factory918.sh sync` all leave the tree byte-identical to the reviewed commit (run in a scratch copy), every patch in `series` applies, and `tests/spec-review/no-stale-wording.sh` passes. One hole in the documented path lets a stateful design go to code with no table, and two records say things the repository does not bear out.

## Would break

## Fails open

1. **A stateful design that skips `architect` gets no table and nothing notices.** Ticket step 6 hangs the table on "the selected playbook's architect step", but Feature step 2 still allows `architect skipped: <reason>` for anything that is not cross-cutting, and Bug fix and Perf issue step 3 run `architect` only when the fix "crosses a function boundary". A single-function change that adds a state file, an exit code or a second actor (the ticket's own trigger) goes straight to delegation; the delegate's brief carries no artifact, the "When it is a scenario table" clause never fires, and the Spec reviewer gets only the criteria. The ticket's Decision makes the table unconditional ("For anything with state ... Before code"); the playbooks make it conditional on a step that may not run.
   ```
   6. The spec's **Testing decisions** are the pre-agreed seams. ... The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table
   ```
   ```
   2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:12` (step 6) with `template/.agents/skills/poteto-mode/playbooks/feature.md:6` (step 2) and `bug-fix.md:9` (step 3, "If it crosses a function boundary, `architect` first").
   Result: the skip reason is recorded and the work proceeds with no `## Testing decisions` section on the ticket; no step refuses it.
   spec: criterion 3

## Standards breaches

2. **The manual still says a project carries four core documents.** `build_core` now copies five into `template/docs/factory918/` (everything but the digest), and the "Where to read more" list has no line for `SCENARIO-TABLE.md`, so the one page a person is told to read from does not reach the new one. `PHILOSOPHY.md:64` ("Where to go next") has the same list without it. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it."
   ```
   docs/knowledge/core/MANUAL.md:165  Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
   ```
   (Regenerated copy at `template/docs/factory918/MANUAL.md:146`.)
   spec: criterion 6

3. **P25 records a fact about `review-brief.sh` that is not there.** The decision's reason for keeping step 6's number says "Ticket step 5" is quoted in four patches and `review-brief.sh`; the script's only reference is the comment "the Ticket playbook says it in words" (`template/.agents/skills/spec-review/scripts/review-brief.sh:183-184`), and `grep -n "step 5"` over it finds nothing. The four patches do quote it. Standard: `CODING_STANDARDS.md`, "Commits and pull requests", records go to `DECISIONS.md`; `docs/M0-findings.md` in this same diff, "the code is the truth".
   ```
   | P25 | ... Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
   ```
   spec: criterion 3

## Fix alongside

4. **Divergent Change: `architect`'s own `## Outputs` still describes one deliverable.** `template/.agents/skills/architect/SKILL.md:84` says the usage is written first and the type sketch derived from it; only the runner prompt knows a table may come first. The orchestrator reads `SKILL.md`, the runners read the prompt; the two now describe different packages.
   ```
   The caller's usage is written first and the type sketch derived from it. One file with new types and signatures for small changes; module map plus type definitions for larger work.
   ```

5. **Non-idempotent append.** Step 6 says the table is "appended to the ticket's body"; a design hole returns the work to architect (the ticket's rule 5), and a second pass appends a second `## Testing decisions`. The #42 run amended in place with a dated line; the playbook does not say which.
   ```
   before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
   ```

6. **Mysterious Name: two layouts for one patch source.** The new patch is `patches/mattpocock/to-spec/SKILL.md.patch`; the existing one is `patches/mattpocock/spec-review.SKILL.md.patch`. `sync` resolves the target from the `--- a/` line, so both apply, but the directory no longer says which form to copy.
   ```
   mattpocock/spec-review.SKILL.md.patch
   mattpocock/to-spec/SKILL.md.patch
   ```

7. **Duplicated Code: one sentence in four playbooks.** The delegation clause is pasted verbatim into Feature 4, Bug fix 3, Refactoring 5 and Perf issue 3 (the router copies steps verbatim, so this is the existing pattern, as with the cross-cutting clause). A change to the rule is four patch edits; the page `SCENARIO-TABLE.md` "Where it goes" carries it a fifth time.
   ```
   The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

8. **Weak pointer in the to-spec patch.** "the rule above" is the no-code-snippets rule two sections up, under Implementation Decisions; inside Testing Decisions nothing above it is a rule.
   ```
   +- For stateful work ... It is a decision, not a code snippet, so the rule above does not exclude it.
   ```

hard findings: 1
