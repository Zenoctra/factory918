---
name: knowledge
description: Look something up in the Factory918 knowledge base without reading whole files. Use when unsure why this system does something, when a term in AGENTS.md, a playbook or a ticket is unclear, when two vendored skills seem to disagree, or when the user asks how Factory918 works or where a rule came from.
argument-hint: "The question, in a few words"
---

# Knowledge lookup

The corpus is large (the four source systems, six research notes, three reference pages, the spec, the philosophy). Reading any of it whole would spend the context window on things you do not need. Follow this procedure exactly.

## Where the corpus is

`$FACTORY918_HOME/docs/knowledge` if that variable is set; else `~/.factory918/docs/knowledge`; else this project's `docs/factory918` (slim: philosophy, manual, decisions, glossary and the scenario table only, with no header or mini-TOC, so take line numbers from grep and `wc -l`). Call it `$KB`.

## Procedure

1. **Index first.** Read `$KB/INDEX.md` whole; it is the one file meant to be read whole. Every file is listed with its purpose, its line count and when to read it.
2. **Grep before you read.** `rg -n -i "<two or three terms>" $KB --glob '*.md' | head -40`. Prefer terms that would appear in a heading. If the question is about a term, try `GLOSSARY.md` and `DECISIONS.md` first.
3. **Open the mini-TOC, not the file.** Every chunked file begins with a header block: `<!-- lines: N -->` and a `## Contents` list with line numbers per section. Read the first 30 lines of the candidate file only.
4. **Read the section, in a range.** Use the Read tool with `offset` and `limit` from the TOC. Hard rule: never read more than 150 lines in one call, and never read a file whose header says more than 200 lines without a range.
5. **Answer with a citation.** Give the answer in a few sentences and cite `path:line`. If two sources disagree, say which one Factory918 follows and why (`DECISIONS.md` wins, then `PHILOSOPHY.md` §"The beliefs that decide things").
6. **Stop.** Do not summarise the file, do not read adjacent sections "for context," do not read the whole conversation digest to answer a small question.

## When the corpus does not answer

Say so. Then apply the procedure in `PHILOSOPHY.md` §"How to decide when the spec is silent" and record the outcome under "Provisional" in `DECISIONS.md`.
