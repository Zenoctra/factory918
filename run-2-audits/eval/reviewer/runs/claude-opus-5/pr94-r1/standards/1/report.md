# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

1. **The builder's docstring still names four slim documents.** `tools/build_knowledge.py` gains the sixth `CORE_DOCS` tuple, and `build_core` copies every core document except `CONVERSATION-DIGEST.md` into `template/docs/factory918/`, so this commit makes the slim set five. The module docstring, six lines above the edited tuple, still says four. `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." No behavior change: the exclusion is by filename, not by this list.

```
  docs/knowledge/core/*.md                 HAND-MAINTAINED. ... then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY
                                           (headers stripped) into template/docs/factory918/ for projects.
```

2. **`SOURCES.md` is edited while a line it contains is recorded as false.** The same commit appends entries 14 and 15 to `SOURCES.md` and writes a findings line saying line 3 of that file misdescribes `sync`. The false line is left standing, which leaves the repository shipping prose the commit itself knows is wrong (`CODING_STANDARDS.md`, Markdown, same rule). Correcting line 3 or marking it superseded is a one-line fix in a file already open.

```
+2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

## Fix alongside

3. **Duplicated Code / Shotgun Surgery: the writer rule is copied into eight places.** The same sentence pair ("The brief carries the ticket's design artifact (Ticket step 6)... never fills it in") is inlined verbatim into `feature.md` step 4, `bug-fix.md` step 3, `perf-issue.md` step 3 and `refactoring.md` step 5, plus each of their four patches. A later wording change has to land in all eight. This matches the house pattern already there (the "cross-cutting diff (Ticket step 5) never skips it" clause is repeated the same way), so it is the documented style, not a breach; fold it into one referenced line only if one of those steps is rewritten anyway.

```
+... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

Checked and clean: `ticket.md`, `overlap.sh` and `review-brief.sh` are in `factory918.sh`'s `keep_files`, so the `ticket.md` step-6 edit needs no patch; the new `runner-prompt.md` and `to-spec/SKILL.md` edits do carry patches, both listed in `series` and described in `SOURCES.md`; the new core document's header count, mini-TOC offsets (L14/L24/L41/L49/L80), `INDEX.md` row, file count and the `AGENTS.md` "six" all hold; the M0-findings claim about the doctor checking only PHILOSOPHY and MANUAL matches `factory918.sh:275`.

hard findings: 0
