Round one of the review found nothing that breaks or fails open: the spec reviewer walked all five removed lines and every acceptance criterion and found each one met, and the standards reviewer ran the test suites and ShellCheck clean. Two style points are noted and need no change here: the list of banned phrases is repeated in three files, and one test check that compares a brief's headings passes only because today's test data pastes in no Markdown that has its own headings. Claude Opus 5.5 on Claude Code

## Standards

# Standards report

What I ran, read-only, at `e710e99`: `bash .github/shellcheck.sh …` (26 files, ShellCheck 0.11.0, clean), `bash tests/spec-review/no-stale-wording.sh` (ok), `bash tests/spec-review/review-brief.sh` (ok, 1836 assertions), `bash tests/eval/reviewer/refusals.sh` (230 checks), `./factory918.sh sync` (working tree clean, so the patch and `template/.agents/skills/spec-review/SKILL.md` agree), `python3 tools/check_knowledge.py` and `tools/build_knowledge.py` (clean, so `docs/knowledge/core/DECISIONS.md` and its generated copy agree). I also grepped the repository for each retired phrase; the only live hits outside `research/`, the frozen `tests/eval/reviewer/rounds/*` recordings and the `-` lines of `patches/mattpocock/spec-review.SKILL.md.patch` are `template/.agents/skills/interrogate/references/lead-judgment.md:20`, which is upstream pstack text the ticket says to leave alone.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code / Shotgun Surgery: the retired-wording list now lives in three files in four disagreeing forms.** Adding or retiring a sixth phrase means editing `tests/spec-review/no-stale-wording.sh`, two loops in `tests/spec-review/review-brief.sh` and two `if grep` lines in `.github/workflows/factory-ci.yml`, and the four lists already use different strings for the same phrase (`Zero items` vs `Zero items is the expected result`, `not the file` vs `read that one function or section, not the file`, `runs nothing` vs `reads one file and runs nothing`), so a phrase can be banned in one place and unnoticed in another. One list, read by the three callers, would make the ban a single edit.

   ```
   +hits="$(grep -rnF -e '## Latent' … -e 'Zero items is the expected result' -e 'Read nothing beyond this brief unless' -e 'read that one function or section, not the file' -e 'Run nothing.' -e 'reads one file and runs nothing' -e 'read nothing beyond the brief but the code around a hunk' -e 'Under 400 words' -e 'under 400 words' -e 'a report that is all nits means' -e 'more than five Act on items' -e 'zero items is the expected result' template docs/knowledge/core | cut -d: -f1,2 || true)"
   ```

   ```
   +  for w in "Under 400 words" "Read nothing beyond this brief" "Run nothing" "Zero items" "not the file"; do
   +for w in "all nits" "more than five Act on items" "under 400 words" "runs nothing"; do
   ```

   ```
   +            if grep -qF 'Under 400 words' "$f"; then echo "$f carries a word cap" && exit 1; fi
   +            if grep -qF 'Read nothing beyond this brief unless' "$f"; then echo "$f carries a reading limit" && exit 1; fi
   ```

2. **`headings()` scans for `## ` without tracking fences, where the same file's `section()` deliberately does.** A real brief's `## Standards` section pastes `CODING_STANDARDS.md` whole and its `## Reading pack` pastes changed files whole, both of which carry `## ` lines; this brief has nine `## ` lines that are pasted content rather than brief structure. The exact-match assertion therefore holds only because the test fixture has no standards file and no Markdown in its pack, so the comment's claim that "a round-two and a fix-only brief carry exactly the `## ` headings they carried before it" is broader than what is checked, and a fixture that later gains a `.md` file fails the test for an unrelated reason. `section()` twelve hundred lines above already carries the fence-tracking awk and a comment explaining why it is needed.

   ```
   +headings() {
   +  [ "$(grep '^## ' "$1")" = "$2" ] || { echo "FAIL $3: $1's headings are"; grep '^## ' "$1"; exit 1; }
   +  n=$((n + 1))
   +}
   ```

hard findings: 0

## Spec

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

## Judgment

## Act on

## Ask

## Consider

## Noted

1. [S1] **The retired-wording list lives in three files in four forms.** A fair duplication smell, but it is a Fix alongside item with no Act on fix touching that code, and each list does refuse the phrases the ticket names; worth one shared list if the ban grows again.
2. [S2] **`headings()` does not skip fenced `## ` lines.** True that the exact-match assertion holds only for the current fixture, which has no standards file and no Markdown in its pack; a Fix alongside item with no Act on fix beside it, and the check does pin criterion 3 for the briefs the test builds today.

## Dismissed

Standards: 0 would break, 0 fail open, of 2; Spec: 0 would break, 0 fail open, of 0; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point 6e5c539.
reviewed: e710e99ce4293ff2d057b7c9d639a82e97c88f04
round: 1 of 3
act-on items: 0
