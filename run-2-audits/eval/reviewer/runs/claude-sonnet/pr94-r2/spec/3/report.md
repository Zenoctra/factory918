## Walk

1. `architect/SKILL.md` Phase B (and its new `patches/pstack/architect/SKILL.md.patch`) now says a stateful design's package opens with the scenario table, its contract and its test list, deferring the shape to `references/runner-prompt.md` — which already specified exactly that ordering.
2. `to-spec/SKILL.md` (and its patch) reword the Testing Decisions bullet so the scenario table is a decision the "no file paths or code snippets" rule does not exclude.
3. `poteto-mode/playbooks/ticket.md` step 6 now reads the current ticket body (`gh issue view N --json body -q .body`), appends the artifact section, and writes the whole body back with `gh issue edit N --body-file`; a write failure stops the agent before implementation.
4. `overlap.sh`'s step-1 path extraction now skips `## Testing decisions` and `## Design` headings in addition to `## Diff`, so a scenario-table cell's example path or a design sketch's path is never read as a path the ticket names.
5. `tests/poteto-mode/overlap.sh` adds a case with a table under `## Testing decisions` and a path under `## Design`, asserting both are ignored; the header comment is updated to match.
6. `SCENARIO-TABLE.md` (core and template copies) documents the read-then-write-whole-body posting mechanics and that the step-1 overlap check skips both artifact sections.
7. `MANUAL.md`/`INDEX.md` line counts move to 175, the "first five" project documents list gains `SCENARIO-TABLE.md`, and `build_knowledge.py`'s comment is corrected to describe the actual copy rule (every core doc except `CONVERSATION-DIGEST.md`).
8. `SOURCES.md` item 14 and `DECISIONS.md` P24 are reworded to record that `architect/SKILL.md` now agrees with the runner prompt and that the overlap check's exclusion list grew by two sections.

Verified: `bash tests/poteto-mode/overlap.sh` passes all 57 assertions against the new script and the new fixture case; `python3 tools/build_knowledge.py` runs clean and the actual copy logic (`if p.name != "CONVERSATION-DIGEST.md"`) already matches the corrected comment; `docs/knowledge/core/MANUAL.md` is actually 175 lines.

## Would break

## Fails open

## Not asked for

hard findings: 0
