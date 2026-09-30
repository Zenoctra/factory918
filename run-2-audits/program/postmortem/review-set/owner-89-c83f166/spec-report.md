# Spec report

## Walk

1. Ticket step 1 runs `overlap.sh N`. The awk pass now sets `skip` on `^## (Diff|Testing decisions|Design)[[:space:]]*$` and clears it at the next `## ` heading, so backticked tokens inside the two artifact sections never become pathspecs; `### ` subheadings inside a table do not clear it, and a trailing `\r` from `gh` still matches.
2. With every token inside those sections, `paths` is empty and the script prints `go: ...`, `paths: none`, `base: origin/main` and exits 0 before `gh pr list`, so step 1 branches from main.
3. `--diff` (step 8) never reads the ticket body, so the record run is unchanged.
4. Architect Phase B now tells runners that a stateful design's package opens with the table, its contract and its test list, and points at `references/runner-prompt.md`, which already carries the shape and the refusal-cell rule. The new patch's context matches the pin at lines 29-35, and the vendored copy differs from the pin only at the patched line, so `sync` reproduces it; `series` lists it.
5. Ticket step 6 posts the artifact: read the body with `gh issue view N --json body -q .body`, add the section with its `Posted by the agent <date>` first line, write the whole file with `gh issue edit N --body-file`; a failed write stops before implementation. `SCENARIO-TABLE.md` says the same, with the reason (`--body-file` replaces, never merges).
6. The `to-spec` bullet and its patch agree, and "the rule above about paths and snippets" names a rule that is really above it.
7. Docs stay consistent: `MANUAL.md` counts five project documents and lists `SCENARIO-TABLE.md`; `template/docs/factory918/` holds exactly those five, each byte-identical to the stripped core body; `INDEX.md` records 175 lines, which `wc -l` confirms, and the mini-TOC offsets are unshifted because the new bullet is in the last section; the `build_knowledge.py` docstring now matches the code's `!= "CONVERSATION-DIGEST.md"` test.
8. The new test case puts one token in each skipped section and asserts exit 0 with `paths: none`; miss either heading and the tokens match PRs 1, 2 and 4 and the case fails at exit 1.
9. `SCENARIO-TABLE.md` states the amended rule in "Where it goes"; the #42 quote below it is kept at the old `## Diff`-only wording, as the criterion's verbatim example, and P24 carries the dated amendment.

## Would break

## Fails open

## Not asked for

hard findings: 0
