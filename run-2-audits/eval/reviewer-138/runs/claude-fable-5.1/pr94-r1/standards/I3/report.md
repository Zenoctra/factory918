# Standards review: ab47eb9 (#89, the scenario table)

The change is prose and patches. What the standards let a reviewer verify by running, ran clean on a copy of this tree: `python3 tools/build_knowledge.py` then `git status --porcelain` printed nothing, `tools/check_knowledge.py` printed `knowledge ok: 119 files`, `./factory918.sh sync` applied all nineteen patches (the two new ones included) and left the tree clean, and `tests/spec-review/no-stale-wording.sh` passed. The mini-TOC of `core/SCENARIO-TABLE.md` (L14, L24, L41, L49, L80) matches the headings, its 88 lines match `INDEX.md`, the slim copy is the body without the header (79 lines), `docs/agents/issue-tracker.md` and the template copy are byte-identical, and the count "119 files" is right (120 markdown files under `docs/knowledge/` including `INDEX.md`). No documented path gives a wrong or silent result and nothing fails open. What is left is one count that the diff made false, one Diátaxis judgment, and smells.

## Would break

Nothing.

## Fails open

Nothing.

## Standards breaches

1. **The manual's count of what a project carries is now false.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." `docs/knowledge/core/MANUAL.md:166` reads "a project carries only the first four, under `docs/factory918/`", and its list below it names `MANUAL.md`, `PHILOSOPHY.md`, `DECISIONS.md`, `GLOSSARY.md`. This diff makes `build_core` copy a fifth file into `template/docs/factory918/` (the tree at this commit has five files there: `wc -l template/docs/factory918/*.md`) and says so itself in `docs/M0-findings.md`, but the manual was not touched. `docs/knowledge/core/PHILOSOPHY.md:64`, the other place that enumerates the core documents by name, also omits the new page. The `knowledge` skill and `AGENTS.md` were updated for the same fact; the manual and the philosophy were not.

```
+    ("core/SCENARIO-TABLE.md", "Factory918: the scenario table", "Designing or reviewing anything with state: a file, exit codes, more than one actor."),
```
```
+2026-09-22. A sixth core document costs one CORE_DOCS tuple in tools/build_knowledge.py and no other code: build_core copies every core document except CONVERSATION-DIGEST.md into template/docs/factory918/, apply copies that directory, doctor checks only PHILOSOPHY and MANUAL.
```

2. **The new page carries three Diátaxis modes.** `CODING_STANDARDS.md`, Markdown: "One Diátaxis mode per file". `core/SCENARIO-TABLE.md` is explanation in "What it is" and "Why", reference in "The shape", and a procedure in "Where it goes" (which step appends the table, with which `gh` command, who edits it, what the writer does). The procedure is the Ticket playbook's step 6 restated; the page's own first paragraph says it is for "the person who opens a ticket and finds a table" and "the agent that has to write one", which are two readers with two modes. A judgment call: the page would hold as explanation plus the shape if "Where it goes" pointed at Ticket step 6 and `docs/agents/issue-tracker.md` instead of repeating them. Quoted from the hunk:

```
+## Where it goes
+
+On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
```

## Fix alongside

3. **Duplicated Code, in prose (Shotgun Surgery on the next edit).** The same rule sentences now live in seven files: the state trigger ("a file it reads or writes, exit codes, rounds, or more than one actor") in Ticket step 6, the runner prompt, `issue-tracker.md`, `SCENARIO-TABLE.md`, `DECISIONS.md` P25, `GLOSSARY.md` and `to-spec/SKILL.md` (there without "rounds"); the header-line rule ("first line `Posted by the agent <date>`, or `Approved by <name> <date>`") in Ticket step 6, `issue-tracker.md`, `SCENARIO-TABLE.md` and P25; and the writer's sentence ("writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in") verbatim in four playbooks, four patches and the page. Changing the header line or the trigger list later means seven edits and a regenerate. One statement (Ticket step 6, or the page) and pointers from the rest is the fix. The four-playbook copy is the clearest instance:

```
+3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

4. **A path that does not exist where the page is read.** The slim copy `template/docs/factory918/SCENARIO-TABLE.md:69` (from `core/SCENARIO-TABLE.md:78`) tells the reader to open `tests/poteto-mode/overlap.sh`. That file is the factory's test; `template/` ships no `tests/` directory, so a project reading its own `docs/factory918/SCENARIO-TABLE.md` is sent to a path it does not have. The page says "the durable copy" is ticket #42 and PR #92; naming the factory repository beside the path, or dropping the sentence from the page and keeping it in P24/P25, fixes it.

```
+Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
```

5. **A tracker write the tracker document does not list.** `docs/agents/issue-tracker.md` opens with "Use the `gh` CLI for all operations" and lists each operation under Conventions (create, read, list, comment, labels, close) and Wayfinding (claim, resolve). Ticket step 6 adds a new write, replacing the whole body with `gh issue edit N --body-file`, and the paragraph this diff adds to `issue-tracker.md` describes the sections but not the command, so the one document meant to hold every tracker operation is the one place the new operation is missing. Since both copies are edited together already, one bullet under Conventions ("Append a section to the body: `gh issue edit <n> --body-file <file>`, the body re-read first so nothing is lost") closes it.

```
+The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, when it is code with no state that crosses a function boundary. Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6). The human edits them in place; `spec-review` reads them as spec because the body is pasted whole.
```

6. **A rationale that cites a quotation that is not there.** P25 says the rule stays in Ticket step 6 "since 'Ticket step 5' is quoted in four patches and `review-brief.sh`". The four patches do quote it (`bug-fix`, `feature`, `perf-issue`, `refactoring`; `opening-a-pr` makes five). `review-brief.sh` does not: its only reference is the comment at line 183, "the Ticket playbook says it in words", with no step number. The no-renumbering choice stands on the patches alone; the citation should say so.

```
+| P25 | The design artifact on the ticket | ... Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
```

7. **A known-false sentence recorded and left in place.** The new M0-findings line says `SOURCES.md` line 3 is wrong ("sync ... bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth"). The finding is the right record per `CODING_STANDARDS.md` "Commits and pull requests" (a verified tool fact goes to `docs/M0-findings.md`), but `SOURCES.md:3` still tells the next reader that `factory918 sync` "will re-fetch these pins, re-apply the patches, and bump VERSION". `SOURCES.md` is edited in this diff two lines lower; the sentence could have been corrected in the same hunk.

```
+2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

hard findings: 0
