---
name: factory-retro
description: Read this project's ledger of agent surprises, find the corrections that recur, and turn each into a rule at the strongest rung that can hold it. Use when the user asks for a retro, asks what keeps getting corrected, wants a ledger entry promoted to a rule, or once a week.
disable-model-invocation: true
---

# Factory918 retro

The ledger is `docs/agents/ledger.md`: one line per time an agent surprised the human. A rule is earned by recurrence, never by one entry (`docs/factory918/PHILOSOPHY.md`, belief 11). This skill turns recurrences into rules. `reflect` is a different tool: it mines the current transcript for learnings and edits skills.

## 1. Read the ledger

Read the whole file; it is short by design.

Then read what nobody wrote down. Claude Code keeps every session under `~/.claude/projects/<encoded cwd>/` (the cwd with `/` replaced by `-`), one `.jsonl` per session. Take the files modified since the last `<!-- retro -->` stamp in the ledger, or the last seven days if there is none, and skim each for the user correcting the agent (messages that push back on an approach, a skipped verification, a broken rule). A product decision ("make it blue instead") is not a correction; a process correction is. Add each one to the grouping below as an unwritten entry marked `(transcript)`. This is where most recurrences are found, so do it even when the ledger is empty.

With fewer than two entries across both sources, say so and stop: nothing has recurred yet.

## 2. Group

Group entries that describe the same correction, even in different words. Show the groups as a table: correction, count, dates, the lines. Entries seen once go in a last row named "waiting"; they stay in the ledger.

## 3. Pick the rung

For every group with two or more entries, name the strongest rung that can hold it, in this order, and draft the rule:

1. Unrepresentable state: a type change (name the type and the file).
2. A check that fails CI: a rule in `oxlint-plugin-project/rules/` (TypeScript only) or `ast-grep/rules/` (any language), or a `banned-api` entry in `pyproject.toml`; with a debt ceiling (`maxOccurrences`, `per-file-ignores`) when old code violates it.
3. A canonical helper the code should call instead.
4. A runtime check.
5. A test at a seam.
6. One line in `AGENTS.md`.
7. A skill edit; hand it to `reflect`.

Say in one sentence why each higher rung cannot hold it.

## 4. Confirm, then encode

Show the table and the drafts and ask which to encode. Promoting a rule is the human's decision. For each confirmed one: write the rule and its test (a rule test and snapshot for ast-grep, a `*.test.ts` for the oxlint plugin, a `ruff check` run for a banned API), run the gate on the ledger's own example to prove it fires, and append ` -> promoted YYYY-MM-DD: <path>` to each ledger line it came from. When asked, delete a rule the ledger shows never fired.

End by appending `<!-- retro YYYY-MM-DD -->` on its own line to the ledger; the phase hook reads it to know when the next retro is due.

## 5. Report

What was promoted, with paths; what is waiting for a second occurrence; the next retro date, a week out.
