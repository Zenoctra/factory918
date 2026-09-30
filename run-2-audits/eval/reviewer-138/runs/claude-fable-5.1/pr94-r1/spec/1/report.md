The six criteria are met in the files the ticket names, every patch in `series` applies to the pinned upstreams (`sync` and `build_knowledge.py` leave a scratch clone clean; `check_knowledge.py`, the hook, spec-review and overlap tests pass), and `review-brief.sh:222` does paste the whole ticket body. One gap: the rule reaches the runners but not the architect skill's own description of the package the orchestrator synthesizes and appends.

## Walk

1. Criterion 1: `runner-prompt.md.patch` (in `series`, applies) makes the table, then the contract, then the test list the first deliverable for state; the usage and signature sketch otherwise; the orchestrator appends it under `## Testing decisions` or `## Design`. The template copy matches the patched upstream.
2. Criterion 2: the same hunk carries "refused with the tool's own message", "costs no code", and cut only after the refusal was run and seen.
3. Criterion 3: Ticket step 6 (kept as step 6, P25) names the trigger, the `gh issue edit N --body-file` append, both first-line forms, the human edit, `/architect with checkpoint` (a real opt-in, `architect/SKILL.md:48`) and the `review-brief.sh` paste. Step 6 sits after step 5, which runs the selected playbook whole; the order "before implementation" is recovered from the runner prompt and the delegation steps, the same convention steps 6 to 8 already use.
4. Criterion 4: Feature 4, Bug fix 3, Refactoring 5, Perf issue 3, through their patches, say test from the table first, one assertion per cell in order, commit order shows it, a writer stops on a cell it cannot implement and never fills it.
5. Criterion 5: `to-spec/SKILL.md.patch`, new in `series`, applies; the template copy matches.
6. Criterion 6: `core/SCENARIO-TABLE.md` (mini-TOC line numbers correct), listed in INDEX and `CORE_DOCS`, copied to `template/docs/factory918/`; `grep -i "scenario table"` under `$KB` hits it, GLOSSARY and P25. `tools/build_knowledge.py:8` still says the slim copy is "PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY"; the code copies five.
7. `issue-tracker.md` (both copies identical) adds the two optional sections after `## Blocked by`. Note for #42's row 13: a table posted at step 6 adds its backticked tokens to step 8's `--diff` pathspecs; a path-like cell token can name a PR in `## Overlap`, and a backticked dot-dot example exits 2, loudly.
8. SOURCES 13 to 15, P25, the GLOSSARY entry, the M0 finding and the ledger line record the choices.

## Would break

1. **The synthesized package has no slot for the table.** The runner prompt tells each candidate to put the table first, but `architect/SKILL.md:32` still says each candidate's package is "shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale", `rationale-template.md` has sections Usage, Shape, Synthesis decision and no table, and Outputs (`SKILL.md:84`) lists usage, sketch and rationale. The orchestrator reads the skill, not the runner prompt it passes through; arena fills the template's sections when it synthesizes. So the one package Ticket step 6 appends is described, everywhere the orchestrator reads, without the artifact step 6 expects to find in it.
   ```
   `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list
   ```
   Documented step: `template/.agents/skills/architect/SKILL.md:32` and `:84`; Ticket step 6, "before implementation the synthesized table is appended to the ticket's body".
   Result: the candidates carry a table and the synthesized package, shaped to a template with no place for it, can arrive at step 6 without one; the orchestrator then has nothing to append, or appends one candidate's table rather than the synthesis.
   spec: criterion 1

## Fails open

## Not asked for

hard findings: 1
