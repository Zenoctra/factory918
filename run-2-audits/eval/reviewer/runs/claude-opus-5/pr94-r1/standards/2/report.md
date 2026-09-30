# Standards review

## Would break

1. **A posted table's backticked tokens become overlap.sh pathspecs.** Step 6 now appends a scenario table to the ticket body, and `overlap.sh` reads the whole body and skips only a `## Diff` section (`template/.agents/skills/poteto-mode/scripts/overlap.sh:48`, `outside="$(... skip=($0 ~ /^## Diff[[:space:]]*$/) ...)"`). Every whitespace-free backticked token in the appended table or sketch is therefore a named path. The #42 table alone carries `tests/poteto-mode/overlap.sh`, `.claude/state/program` and `origin/main`; P24 (`docs/knowledge/core/DECISIONS.md`) excluded `## Diff` for exactly this reason, and the table's own row 7 says "tokens under `## Diff` ignored". Either `## Testing decisions` and `## Design` join the skip predicate, or step 6 says the artifact goes in fenced blocks.

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6` "the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`", then step 8 "Run `.claude/skills/poteto-mode/scripts/overlap.sh N --diff` ... exit 1 means the reply names the printed PR as the one to merge first."

Result: after step 6, step 8 matches the table's tokens against every open PR, so a PR that touches `tests/poteto-mode/overlap.sh` makes the check exit 1 and the PR is not opened; a token outside the repo exits 2 (table row 14). The overlap the ticket actually has is never what was tested.

```
6. ... before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
```

## Fails open

## Standards breaches

2. **The build script's docstring still lists four slim copies.** `CODING_STANDARDS.md`: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." `CORE_DOCS` gained `core/SCENARIO-TABLE.md` and `build_core` copies it, but `tools/build_knowledge.py:8` was not touched.

```
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

3. **MANUAL's "Where to read more" says four and lists four.** Same standard. `docs/knowledge/core/MANUAL.md:165` is a core source, so the count is now wrong in the factory and in every project's slim copy, and the scenario table has no entry a human would find.

```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```

## Fix alongside

4. **Duplicated Code.** The same three sentences ("The brief carries the ticket's design artifact (Ticket step 6) ... never fills it in.") are pasted into four playbooks and four patches; a later wording change is four edits. The playbooks already repeat delegation prose upstream, so this is a judgement call, not a breach.

hard findings: 1
