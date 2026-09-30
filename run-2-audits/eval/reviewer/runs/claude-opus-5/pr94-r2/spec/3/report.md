## Walk

1. Ticket step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`): the agent reads the body with `gh issue view N --json body -q .body`, adds `## Testing decisions` at the end with its `Posted by the agent <date>` first line, writes the whole file back with `gh issue edit N --body-file`, and stops if the write fails. That matches `gh issue edit`, which replaces the body and never merges, so the previous "append" wording could not be followed without losing the body.
2. The same step and `SCENARIO-TABLE.md` "Where it goes" (both copies) say the step-1 overlap check skips `## Testing decisions` and `## Design`.
3. `overlap.sh:48` implements it: `awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip'` drops the heading and its lines until the next `## `. Only these two headings can hold a posted artifact (`docs/agents/issue-tracker.md:26`), and both are spelled there exactly as the regex matches.
4. With every token inside the skipped sections, `paths` is empty and the script takes the early exit `paths: none\nbase: origin/main`, exit 0. Test 17 in `tests/poteto-mode/overlap.sh` asserts exactly that for a table quoting `docs/a.md` and a `## Design` quoting `src/z.txt` (both paths that PRs 1, 2 and 4 in the fixture touch, so an unskipped section would exit 1). The older `## Diff` case keeps a token under `## Notes`, so its expectation without `paths: none` is still right.
5. Criterion 1 (architect's first deliverable): `architect/SKILL.md` Phase B now states the stateful package opens with the table, contract and test list, agreeing with `references/runner-prompt.md:7`. The new `patches/pstack/architect/SKILL.md.patch` carries the same sentence and is listed in `series`; applied to the pinned upstream `research/3-pstack/.../architect/SKILL.md` it applies clean, so `sync` reproduces the vendored copy. `SOURCES.md` item 14 records it.
6. Criterion 5 (`to-spec`): the table bullet's exemption now names "the rule above about paths and snippets", which is the Implementation Decisions rule at `to-spec/SKILL.md:55`; skill and patch match.
7. Criterion 6 (a page projects get): `build_knowledge.py` copies every core doc except `CONVERSATION-DIGEST` (its code at line 136 already did; only the stale docstring naming four documents changed), so `SCENARIO-TABLE.md` ships. Both `MANUAL.md` copies now say "the first five" and list it, and the header and `INDEX.md` counts match the file's 175 lines.

## Would break

## Fails open

## Not asked for

hard findings: 0
