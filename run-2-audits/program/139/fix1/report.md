# #142 fix round 1 (ticket #139)

Branch: wt/139-fix1, from origin/feat/unreadable-writer-flags at 69d6a96. Not pushed. Head 6128acca788599a5141d19e6b8aef92a23c59455.

## Commits
- f41ddf3 Test that a writer flags heading after a list marker is refused. Adds D11 ("- ### Writer flags 2026-09-23", blank, "   1. bare") and D11b ("1. ### Writer flags 2026-09-23", same) in tests/spec-review/review-brief.sh, both expecting rz8 with the heading line; the table D comment says "after any list marker too". Act on 1, tests.
- 833fcae Count a writer flags heading written after a list marker. The review-brief.sh guard regex is now ^([[:space:]>]|[-*+]|[0-9]+[.)])*#+[[:space:]]*writer[ -]flags?([^[:alpha:]]|$), still one line match on the raw body. The guard comment gains: "The check above has already refused every near-miss and unclosed-fence record, so any record the awk below prints is a read flag." Act on 1 and 3.
- 6128acc Name the writer flags heading refusal in spec-review step 1. One sentence added to the "With a ticket, at every round and in both forms" paragraph, quoting the refusal's opening words. patches/mattpocock/spec-review.SKILL.md.patch regenerated with diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md over the research upstream code-review/SKILL.md and the edited file (the recipe reproduced the old patch byte for byte before the edit). SOURCES.md patch 6 names the third refusal (#139). Act on 2. No test pins that paragraph, so no pin changed.

## Failed before the script change
- D11: exit 0, wanted 1 with the refusal (the suite stops at its first FAIL).
- D11b: with D11 commented out temporarily, exit 0, wanted 1. Restored before committing.

## Quick run, no new cell
- The guard's awk over #108's C7/f body and over fake-gh.sh's fixed body prints nothing, so neither is counted. The suite's D9, C7/f and A1/P also assert both brief with empty stderr.

## Verification (at 6128acc)
- bash tests/spec-review/review-brief.sh: ok 1860 assertions.
- bash .github/shellcheck.sh (the 26-file set from the brief): ShellCheck 0.11.0, 26 files, clean.
- bash tests/spec-review/no-stale-wording.sh: ok, no stale wording.
- bash tests/spec-review/review-comment.sh: ok 298 assertions.
- ./factory918.sh sync then git status --porcelain: empty.
- python3 tools/check_knowledge.py: knowledge ok, 119 files.
- One review-brief run failed because I ran sync concurrently and it removed SKILL.md mid-run; the rerun alone passed. Not a defect.

## Act on (owner)
1. The SOURCES.md clause in 6128acc was not in the brief. AGENTS.md says a vendored-skill patch is described in SOURCES.md, so I added it. Drop it if unwanted.
2. The refusal text still says flags are read "only under an unfenced, unquoted line"; it does not mention list markers. The amendment asks no message change; noting only.
3. The step 1 paragraph still ends "A ticket with no such list is unaffected", which reads slightly loose next to the new sentence (a body with a heading line and no read list is refused). Left as is.
