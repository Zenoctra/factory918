# Spec report

The commit only adds a rule to prose and one test case; the script's behaviour is unchanged. I walked the rule against the code that enforces it and found nothing that breaks or fails open.

## Walk

1. Ticket step 6 tells the orchestrator to append the artifact under `## Testing decisions` (or `## Design`), and now to keep the whole artifact inside that one section with its parts under `###` headings.
2. `docs/agents/issue-tracker.md:26` and its template copy state the same rule and give the reason: the overlap check skips a section up to the next `## ` heading.
3. `SCENARIO-TABLE.md` repeats it for the table's parts (legend, table, contract, test list) and records that #42's record predates the rule.
4. `template/.agents/skills/poteto-mode/scripts/overlap.sh:5-6` documents the skip as running "up to the next `## ` heading"; the code is untouched by this commit.
5. `overlap.sh:49` is the enforcement: `awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip'`. Only a line beginning `## ` (hash, hash, space) re-evaluates `skip`.
6. `### Contract` has `#` in the third position, so it does not match `^## `; `skip` stays set and the whole subsection is dropped, exactly as the three documents now claim.
7. The next `## ` heading outside the three names clears `skip`, so the rule's stated boundary is the real one.
8. With every token skipped, `paths` is empty and the script prints `go: ...` / `paths: none` / `base: origin/main` and exits 0 — the expectation the new test asserts.
9. `tests/poteto-mode/overlap.sh:151-161` quotes `src/x/y.txt` inside the `### Contract` subsection. Fixture PR #2 touches that path, so a token leaking out of the skip would give exit 1 and a `#2 feat-b:` line; the test is falsifiable, not decorative.
10. Generated copies stay in step: `template/docs/factory918/SCENARIO-TABLE.md` carries the identical sentence, the core document is still 88 lines as `docs/knowledge/INDEX.md:12` records, and the worktree is clean.

## Would break

## Fails open

## Not asked for

hard findings: 0
