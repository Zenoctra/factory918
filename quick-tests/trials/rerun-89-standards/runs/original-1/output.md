## Final message

/private/tmp/wsbox/w-20261005-191213-a2b7/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

## Would break

1. **`MANUAL.md`'s map of what a project carries still says four and omits the new page.** The change makes `SCENARIO-TABLE.md` a sixth core document and a fifth slim copy (`tools/build_knowledge.py` `build_core` copies every core doc except `CONVERSATION-DIGEST.md`), and `AGENTS.md` and `INDEX.md` were updated for it, but `docs/knowledge/core/MANUAL.md` "Where to read more" was not. Breach of `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it."

```
docs/knowledge/core/MANUAL.md:165
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
- `MANUAL.md` ... - `PHILOSOPHY.md` ... - `DECISIONS.md` ... - `GLOSSARY.md` ...
```

Documented step: `docs/knowledge/core/MANUAL.md:165` (and its generated copy `template/docs/factory918/MANUAL.md:146`), the reader's map of the core documents.
Result: a human or agent asking which core documents a project carries is told four and is given no entry for the page that Ticket step 6, the four playbooks and the `architect` runner prompt now all require. Fix is one line plus a bullet in `docs/knowledge/core/MANUAL.md`, then `python3 tools/build_knowledge.py`.

## Fails open

None.

## Standards breaches

2. **`build_knowledge.py`'s own docstring now describes the wrong set of copies.** The file is edited in this diff (the `CORE_DOCS` tuple) but its header still names four documents; `build_core` copies five. Same `CODING_STANDARDS.md` rule as [S1].

```
tools/build_knowledge.py:8
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

## Fix alongside

3. **Ticket step 6 arrives after step 5 has already run the whole playbook (sequencing, not a smell).** Step 5 says to "run that playbook's steps verbatim from step 1", so in reading order the "before implementation" rule lands after implementation. The four playbooks' delegation steps forward-reference "Ticket step 6", which is what saves it; `DECISIONS.md` P25 records the no-renumbering reason. Worth a clause in step 5 pointing forward.

4. **Duplicated Code: the same four-sentence paragraph is pasted into four playbooks and their four patches.**

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer
writes the test from the table before the implementation, one assertion per cell in the table's order, ...
```

Matches the precedent set by the `architect` skip clause, so it is the house style here, not a defect.

5. **`PHILOSOPHY.md:64`'s "read more" list omits `SCENARIO-TABLE.md`**, like [S1] but a navigation list rather than a count.

Checked and clean: both new patches reverse-apply on the template and the reversed files are byte-identical to the pinned upstreams, so `sync` stays clean; every existing patch still reverses; `to-spec` and `architect` are both vendored by `cmd_sync`; `cmd_update` rglobs the template, so the new file reaches existing projects; P25 is under Provisional; the `M0-findings` line is dated.

hard findings: 1
```

## Other files written (not shown)

scratchpad/pcheck/architect/SKILL.md
scratchpad/pcheck/architect/references/design-red-flags.md
scratchpad/pcheck/architect/references/rationale-template.md
scratchpad/pcheck/architect/references/runner-prompt.md
scratchpad/pcheck/to-spec/SKILL.md
scratchpad/pcheck/to-spec/agents/openai.yaml
