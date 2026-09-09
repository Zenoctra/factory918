<!-- lines: 15 | source: spec/FACTORY-SPEC-v2.md | part 3/17 | title: The Factory spec, v2 — Change log, v2 → v2.1 (2026-09-09, layout only) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Change log, v2 → v2.1 (2026-09-09, layout only)

## Change log, v2 → v2.1 (2026-09-09, layout only)

The draft repo, this spec, the hand-written sources and the research corpus were folded into one folder, `factory918/`, so a Claude Code session opened there sees everything. No design change.

- **§0**: the companion bundle is gone; the pinned upstream copies are in `research/`, the drafts are this repository, `CLAUDE.md` gives the reading order. The writing skills are linked into `.claude/skills/`; nothing is installed at user level.
- **§4**: layout adds `CLAUDE.md`, `docs/FACTORY-SPEC-v2.md`, `research/`, `tools/build_knowledge.py`, `tools/bootstrap/` and `.claude/skills/`; `build_knowledge.py` moved to `tools/`; `docs/knowledge/core/` is hand-maintained, the rest of `docs/knowledge/` is generated.
- **§5**: the glue-skill drafts are in `template/.agents/skills/` (was `factory918-skeleton/...`); patch 9 (the `/no-comments` sweep) is listed in `SOURCES.md`.
- **§8, §9**: `factory918 knowledge` runs `tools/build_knowledge.py`; M0 loads the writing skills from `.claude/skills/`.

---
