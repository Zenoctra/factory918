# Standards report

Two notes for a person first. The patches, the series and the generated files all check out: every patch in `series` applies to the pinned upstreams, the patched vendor tree equals `template/`, and `build_knowledge.py` reproduces the committed output byte for byte (`check_knowledge.py` ok, 119 files). The one thing that does not hold is *when* the new rule can run: it is written in Ticket step 6, and step 5 has already run the whole playbook by then.

## Would break

1. **The posting rule is written after the step that would obey it.** Ticket step 5 runs the selected playbook "verbatim from step 1", so `architect`, the delegation and the implementation all happen inside step 5. The instruction to post the artifact *before implementation* is in step 6, which is reached after. Nothing the orchestrator actually runs carries it earlier: the playbooks' architect steps (Feature step 2, Bug fix step 3, Refactoring step 3, Perf issue step 3) say nothing about posting, `architect/SKILL.md` never mentions the ticket, `## Testing decisions` or `## Design`, and the one file that does name the orchestrator's job is `runner-prompt.md`, which is text handed *to a runner*.

   ```
   6. ... and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
   ```

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:9` — "5. Select by content and run that playbook's steps verbatim from step 1".
   Result: the artifact lands after implementation, or not at all, so the writer's brief has no table and criterion 4's "test from the table before the implementation" cannot hold.
   spec: criterion 3

## Fails open

2. **The new sections feed overlap.sh's pathspec matcher, which still excludes only `## Diff`.** P24 makes every backticked token in the ticket body a pathspec. The table's legend and contract are full of them (`.claude/state/program`, `origin/main`, `tests/poteto-mode/overlap.sh`). On a resumed ticket run step 1 reads the body again, now with the table in it.

   ```
   The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table
   ```

   Documented step: `docs/knowledge/core/DECISIONS.md:92` (P24) — "matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded)".
   Result: a token named for context, not as a declared path, counts as overlap; under a covering go that silently makes an unrelated PR's head the base instead of `origin/main`.
   spec: criterion 3

## Standards breaches

3. **The manual still says a project carries four core documents.** `docs/knowledge/core/MANUAL.md:165` (and its generated copy `template/docs/factory918/MANUAL.md:146`) under "Where to read more"; `SCENARIO-TABLE.md` appears in neither list, although the `knowledge` skill's `$KB` sentence was updated to name it.

   ```
   Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
   ```

   Standard: `CODING_STANDARDS.md:24` — "A count or a version in prose is true at the commit that lands it."

## Fix alongside

4. **`gh issue edit N --body-file` replaces a body; the step never says to fetch it first.** Step 6 says "appended", but names only the replacing command. Elsewhere this repo spells the mechanics out (step 8's `overlap.sh N --diff`). An agent that writes only the new section drops What to build, Acceptance criteria and Blocked by.

5. **Divergent Change.** `template/AGENTS.md:66`, the letter read on every turn, still knows only "the spec's **Testing decisions**", not the ticket's own — the section the writer now takes its test list from.

hard findings: 2
