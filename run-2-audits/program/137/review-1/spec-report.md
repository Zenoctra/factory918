## Walk

1. Line 1, "Zero items is the expected result for a clean change.": `review-brief.sh` drops it from `definition`, SKILL.md step 4 and the patch drop it from the quoted definition, P18 (core and generated copy) drops it, and `template/docs/agents/review-ladder.md` drops "and zero items is the expected result for a clean change". `docs/agents/review-ladder.md`, which the ticket names as a copy, does not exist in this repository, so there is nothing to change there. `no-stale-wording.sh` refuses both capitalizations, and CI now matches the definition with `grep -qxF`, so a trailing sentence would fail it.
2. Line 2, the read and run ban: `common()` now prints `read_rule`, "You may open any file in the repository and run read-only commands, such as grep or the test suite.", as each brief's first line. The Standards and Spec item-form sentences lose the ban. SKILL.md adds the reading sentence as the first bullet of "Both briefs" and drops "so a reviewer reads one file and runs nothing" and "read nothing beyond the brief but the code around a hunk". SOURCES.md item 6 now says "each brief says the reviewer may open any file and run read-only commands". The stale-wording check and CI refuse "Read nothing beyond this brief unless", "Run nothing." and "reads one file and runs nothing".
3. Line 3, the reading-pack tail: `pack_rule` now ends "open the repository for what the pack does not carry." in the script, SKILL.md, the patch and test row 27. "read that one function or section, not the file" is refused by the stale-wording check.
4. Line 4, "Under 400 words.": removed from both item-form sentences in the script, SKILL.md and the patch. Both capitalizations are refused, and CI fails a brief that carries it.
5. Line 5, the judge heuristics: SKILL.md step 5 and the patch now read "sort each item on its merits; the Dismissed list is shown so the human can overrule you." The test and the stale-wording check refuse "all nits" and "more than five Act on items". Upstream `interrogate/references/lead-judgment.md:20` keeps its nit-inflation paragraph, which the ticket says to leave as it is.
6. Criterion 2: `report_rules` prints `edge_rule` two lines after the fifth quote and before `pack_rule`. `blind_rules` asserts this position in both briefs of the main run and of each row-27 brief, and Manuel's fourth quote is unchanged in `quotes`.
7. Criterion 3: none of the new text mentions earlier rounds. The new `headings` assertions pin a round-two brief and a round-five fix-only brief to the `## ` headings they carried before this change, with no new section.
8. Criterion 4: P18 carries "Amended 2026-09-23 (#137)", which lists the four removals, says that later rounds stay blind, and quotes Manuel three times.
9. Criterion 5: `tests/spec-review/review-brief.sh` asserts the edge line, the reading sentence and the absence of each retired phrase in both briefs, and asserts the same in SKILL.md. I ran it: `ok 1836 assertions`. `review-comment.sh` gives `ok 298 assertions`, `no-stale-wording.sh` gives `ok: no stale wording`, and `./factory918.sh sync` leaves `git status` clean.

## Would break

## Fails open

## Not asked for

hard findings: 0
