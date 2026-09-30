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
