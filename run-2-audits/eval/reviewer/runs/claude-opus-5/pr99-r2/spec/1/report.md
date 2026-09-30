## Walk

1. The design-hole definition lands in `spec-review/SKILL.md` step 5 and `review-ladder.md` rung 1, naming the three artifacts, the intent-over-criterion rule and the could-not-run exemption (criterion 1).
2. `review-brief.sh` gains `spec_rule`, echoed after `$step_rule` only when `$spec` is set; `review-comment.sh` gains `has_spec` and a second `stepless` pass that refuses a counted item with no `spec: <ref>` line (criterion 2, as amended).
3. `review-comment.sh` detects a `hole:` field with `holed()` (a line carrying `hole:` and not ending in a `fixed:`/`ticket:` field), refuses it in a no-spec review, outside Act on, in no form, or differing from the item's `spec:`; then subtracts `holes` and prints `restart` between the summary and `round:` (criterion 3).
4. `review-brief.sh` slices `bodies` at the last line that is exactly `restart` outside fenced text, prints the `restart:` line, and derives round and settled set from what follows; the Ticket playbook gains the Design hole section and the step 8 pointer (criterion 4).
5. `ref` is a fourth `cites:` alternative, `#N <reference>`, and `fragment()` holds the two `ref=` lines together (criterion 5).
6. `tests/spec-review/` covers table A rows 5-8, 11-17 and table B rows 1-7; `no-stale-wording.sh` blacklists `Three trailing fields` (criterion 6).
7. The byte-identical sentence lands in `babysit.md` and `babysit/SKILL.md`; columns A to C are unchanged (criterion 7).

## Would break

1. **The refused hole's value keeps its leading blank.** `value() { printf '%s' "${1##*hole:}"; }` (`review-comment.sh:554`) does not strip leading blanks, and both refusals interpolate it after a bare `hole:`. For `hole:table 2/D` the script prints `'hole:table 2/D'`; the amended cell says `'hole: <value>'` with `<value>` stripped, i.e. `'hole: table 2/D'`. The two agree only when the mark already has its space.
Documented step:
```
`<value>` is the text after `hole:` with leading blanks stripped; 5E and 5G inherit.
```
Result: the 1E, 1G, 5E and 5G messages differ from the artifact for any mark written without the space, and a test now pins the code's wording against the table's.
spec: table 1/E

## Fails open

## Not asked for

2. **A fifth new assertion.** The amendment lists exactly three added assertions (a prose `hole:` under Act on, one under Noted, the word without a colon accepted). `review-comment.sh:1138` adds a fourth, `hole:table 2/D` refused "shown as written", which is the assertion that pins finding 1.

hard findings: 1
