# Standards report, ab47eb9

The rebuild, the knowledge check, `sync` and the stale-wording test all pass on this commit; the generated copies match their sources and the two new patches apply. The one hard finding is a gap between the trigger for `architect` in the four playbooks and the trigger for the table in P25: a design with state that does not cross a function boundary never reaches the step that writes the table.

Verified in a scratch copy of the reviewed tree: `python3 tools/build_knowledge.py` then `git status` clean; `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`; `./factory918.sh sync` prints `applied` for all 19 patches, including `pstack/architect/references/runner-prompt.md.patch` and `mattpocock/to-spec/SKILL.md.patch`, and `git status` stays clean; `bash tests/spec-review/no-stale-wording.sh` prints ok. `docs/agents/issue-tracker.md` is byte-identical to the template copy. The `## Contents` line numbers of the new core page point at their headings.

## Would break

## Fails open

1. **A design with state that crosses no function boundary never reaches the table.** P25 and Ticket step 6 hang the table on "the selected playbook's architect step", but three of the four playbooks run `architect` only when the change "crosses a function boundary", and Feature still accepts `architect skipped: <reason>` for anything that is not cross-cutting. A change with state inside one function or one script (a new exit code, a state file read by an existing command) is exactly the #87 shape, and every playbook carries it to the delegation sentence, where "the brief carries the ticket's design artifact" has nothing to carry and says nothing about that case.
   ```
   template/.agents/skills/poteto-mode/playbooks/bug-fix.md:9
   3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. [...] The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, [...]
   template/.agents/skills/poteto-mode/playbooks/feature.md:6
   2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); [...]
   template/.agents/skills/poteto-mode/playbooks/ticket.md:10
   6. [...] The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table [...]
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/bug-fix.md:9`, `perf-issue.md:16`, `refactoring.md:9` ("If it crosses a function boundary, `architect` first") and `feature.md:6` (the skip clause), read with `ticket.md:10` (step 6), which fires only inside the playbook's architect step; `docs/knowledge/core/DECISIONS.md:93` (P25, "For a design with state ... the architect step's first deliverable is a scenario table").
   Result: the writer is briefed and implements a stateful change with no table on the ticket and no stop; the Spec reviewer's brief has no `## Testing decisions` to check against, so the review is again a search, which is the failure #89 exists to close. Fix is one clause: state joins the cross-cutting diff as a case that never skips `architect` (Feature step 2) and that runs it even inside a function boundary (Bug fix 3, Perf issue 3, Refactoring 3), in the four patches and the four template copies.
   spec: criterion 3

## Standards breaches

2. **The new core page mixes three Diátaxis modes.** `CODING_STANDARDS.md:22`: "One Diátaxis mode per file, except the vendored copies under `docs/agents/`". `SCENARIO-TABLE.md` is explanation ("What it is", "Why"), reference ("The shape", the #42 legend and table) and a procedure with a command ("Where it goes": `gh issue edit N --body-file`, the first-line format). The other core documents have the same shape, so this is Manuel's call on the standard rather than on the page; the procedure paragraph is the part that could move to the Ticket playbook, which already holds it.
   ```
   docs/knowledge/core/SCENARIO-TABLE.md:12
   This page says what the table is, what shape it takes, where it goes, and why two runs of the same ticket made it a rule.
   docs/knowledge/core/SCENARIO-TABLE.md:43
   On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. [...]
   ```

## Fix alongside

3. **Duplicated Code: the definition of "state" is written out seven times and drifts once.** The runner prompt, Ticket step 6, P25, the core page and the four playbooks all spell out "(a file it reads or writes, exit codes, rounds, or more than one actor)"; the to-spec patch drops "rounds". Point the copies at the page and keep one list, or at least align the to-spec line.
   ```
   template/.agents/skills/to-spec/SKILL.md:66
   - For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: [...]
   template/.agents/skills/architect/references/runner-prompt.md:7
   - With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, [...]
   ```

4. **The slim copy names a factory-only path.** `template/docs/factory918/SCENARIO-TABLE.md` reaches a project through `apply`, where `tests/poteto-mode/overlap.sh` does not exist. The sentence is true in the factory and a dead reference in every project; say it is the factory's test, or drop the sentence from the page and leave the pointer in P24.
   ```
   template/docs/factory918/SCENARIO-TABLE.md:69
   Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
   ```

5. **SOURCES.md line 3 is recorded as wrong and left standing.** The new M0 finding says `sync` bumps no VERSION and touches no network, "against what SOURCES.md line 3 says; the code is the truth", and the same commit edits SOURCES.md without touching that sentence. A person reading SOURCES.md still gets the wrong behaviour; one clause fixes it (`re-applies the patches from the pins under research/; bump VERSION by hand`). Pre-existing, so it rides only if a fix touches SOURCES.md.
   ```
   docs/M0-findings.md:179
   [...] factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   SOURCES.md:3
   [...] `factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.
   ```

hard findings: 1
