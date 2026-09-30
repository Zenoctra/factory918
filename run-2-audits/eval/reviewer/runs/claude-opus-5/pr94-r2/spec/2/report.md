## Walk

1. `architect`'s Phase B (criterion 1) now names the scenario table, its contract and its test list as the package's opening for a design with state, in `template/.agents/skills/architect/SKILL.md:32` and in `patches/pstack/architect/SKILL.md.patch`; the patch is listed in `patches/series:12` before the runner-prompt patch and described in `SOURCES.md` item 14.
2. The patch's context matches the pin: `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md:32`, and the `Use your configured architect runners` line at 34, are identical to the hunk, so `sync` re-applies it.
3. Ticket step 6 (criterion 3) reads the body with `gh issue view N --json body -q .body`, adds the section at the end, and writes the whole file back, because `gh issue edit --body-file` replaces; a failed write stops before implementation.
4. `to-spec`'s Testing Decisions (criterion 5) keeps the table as the shape for stateful work; the new wording points at the real rule above it, `Do NOT include specific file paths or code snippets` (`template/.agents/skills/to-spec/SKILL.md:55`).
5. `overlap.sh` step 1 skips `## Diff`, `## Testing decisions` and `## Design`; `tests/poteto-mode/overlap.sh:146` asserts exit 0 with `paths: none` on a body whose table cell quotes `docs/a.md`, a path PR #1 touches, so the skip is proved to suppress the false overlap. P24 carries the dated amendment in both `DECISIONS.md` copies.
6. The knowledge page is the fifth project document (criterion 6): `build_knowledge.py` copies every core file but `CONVERSATION-DIGEST` (line 136), `MANUAL.md` says "first five" and lists it, and the header count 175 matches `wc -l`.

## Would break

1. **The page's own contract still defines named paths by `## Diff` alone.** `docs/knowledge/core/SCENARIO-TABLE.md:76` and cell 7 at line 63 (and their `template/docs/factory918/` copies) say the named paths are the backticked tokens outside a `## Diff` section, which the same page now contradicts at line 45 and the shipped script no longer does. P24 took a dated amendment for exactly this change; the quoted contract did not.

```
The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names.
```

Documented step: `docs/knowledge/core/SCENARIO-TABLE.md:76`. Result: a project agent reading the fifth document's contract learns that a path quoted under `## Testing decisions` counts as a path the ticket names, and writes or reviews against the superseded rule.

## Fails open

## Not asked for

hard findings: 1
