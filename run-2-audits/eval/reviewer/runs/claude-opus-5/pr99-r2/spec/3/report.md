## Walk

1. Criterion 1, the definition: `spec-review/SKILL.md` step 5 gains the design-hole paragraph (three artifacts, intent outranks a criterion, the could-not-run exception), and `review-ladder.md` rung 1 gains the matching sentence; the patch carries both SKILL.md edits with the same hunk counts (`@@ -57,26 +65,89 @@`, +3 new-side lines).
2. Criterion 2, the `spec:` line: `review-brief.sh` defines `spec_rule` and echoes it one blank line after `$step_rule` at both call sites, the Standards one guarded by `[ -n "$spec" ]`, the same test that writes `spec-brief.md`; `review-comment.sh` sets `has_spec` from `spec-brief.md` before any report is read, and `report()` runs `stepless "$f" "^spec: $ref$"` only with it, after the `Documented step:` scan.
3. Criterion 3, the mark: `holed()` takes judgment items whose line does not end in a `fixed:`/`ticket:` field and carries `hole:`; refusals run no-spec, then placement (Ask/Consider/Noted/Dismissed), then form (`grep -vE "hole: $ref$"`), then the word-for-word compare against `specs()`'s n-th line for that report; `holes` is subtracted in the count and `echo restart` sits between the summary and `round:`, so `act-on items:` stays last.
4. Criterion 4, the restart: one awk between `bodies` and the round awk keeps only lines after the last comment holding a line that is exactly `restart` (CR and trailing blanks stripped by `$split` before the test, fenced lines dropped by `$fenced`), prints the cut count, and sets `restarted`; the `restart:` line prints after `ticket:` and before `round:`, `--round` included. The round, the `settled:` line, the settled section and the fourth-round refusal all read the sliced history, so the script refuses a strict subset of what it refused before. The Ticket playbook gains the Design hole section and the step 8 pointer; babysit's playbook and SKILL.md gain the same sentence.
5. Criterion 5, the cite: a fourth `cites:` alternative `#[0-9]+ $ref`, still `$`-anchored, inside the existing group; `review-comment.sh` still never reads `cites:`, `review-brief.sh` still never reads `hole:`.
6. Criterion 6, the tests: `review-comment.sh` covers rows 1A-1G, 2, 3 (malformed and fenced), 4, 5A/5D-5G, 6, 7 and the two-holes, last-field and rerun notes; `review-brief.sh` covers A5-A8, A11-A13, A14-A17, the no-spec layout pin, and `fragment()` now holds both `ref=` lines together.
7. Criterion 7: babysit's existing merge-ready bullet is untouched; the new sentence adds a condition only for a comment carrying `restart`.

## Would break

## Fails open

## Not asked for

hard findings: 0
