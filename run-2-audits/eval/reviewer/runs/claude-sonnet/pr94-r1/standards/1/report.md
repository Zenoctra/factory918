# Standards review report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the writer-brief sentence is pasted into four playbooks verbatim.** The same paragraph about the scenario table appears identically in `bug-fix.md`, `feature.md`, `perf-issue.md`, and `refactoring.md` (via their patches), rather than being said once and referenced. This may be a deliberate repo convention (each playbook is read standalone by an independent lane, so cross-references are avoided elsewhere too, e.g. the repeated "Inconclusive... is not a pass" line), so it is a judgement call, not a clear miss.

```
+3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

Checked and clean: the "Ticket step 5" vs "Ticket step 6" cross-references stay correctly split (P25's no-renumbering choice, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); `docs/knowledge/core/` header line counts (92→93, 69→71, new 88) match the added line counts; the `INDEX.md` file count (118→119) and per-file counts agree; the new `CORE_DOCS` tuple in `tools/build_knowledge.py` is syntactically consistent with its neighbors and matches the generated `template/docs/factory918/SCENARIO-TABLE.md` (slim, no header, as `knowledge/SKILL.md` describes); the Glossary entry sits in correct alphabetical order (Router, Scenario table, Seam); `docs/agents/issue-tracker.md` and its template copy carry the identical addition, consistent with "edited in the template... then copied."

hard findings: 0
