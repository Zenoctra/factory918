## Walk

1. Criterion 1, the definition. `spec-review/SKILL.md` step 5 gains the design-hole paragraph (three artifacts, intent over criterion, the could-not-run carve-out, "test for all three") and `docs/agents/review-ladder.md` rung 1 gains its one-sentence twin; the patch carries both into `SOURCES.md` item 6.
2. Criterion 2, as amended. `review-brief.sh` defines `spec_rule` beside `step_rule` and echoes it one blank line after the step rule in the Spec brief always and in the Standards brief only under `[ -n "$spec" ]`, the same test that writes `spec-brief.md`; `review-comment.sh` sets `has_spec` from `spec-brief.md` before the Standards report is checked and `report()` runs the `^spec: $ref$` scan through `stepless()` only with it, returning 0 otherwise.
3. Criterion 3, the mark. `holed()` is `items` minus lines ending in a `fixed:`/`ticket:` field, grepped for `hole:`; the four refusals fire in the amended order (no spec, placement over Ask/Consider/Noted/Dismissed, form against `hole: $ref$`, then value against `specs()`'s row for the judged `[SP]<n>`), `holes` is subtracted in `act - fixed_here - ticketed - holes + ask`, and `restart` prints after the summary and before `round:`.
4. Criterion 4, the restart. One awk between `bodies` and the round awk keeps the comments after the last `restart` line outside fenced text, counting separators as `split` does; `restarted` prints the `restart:` line after `ticket:`; `top`, the `settled:` line and the fourth-round refusal all read the sliced history. The Ticket playbook gains the step 8 pointer and the six-step **Design hole** section, no step renumbered.
5. Criterion 5, the cite. `review-brief.sh`'s `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group; `review-comment.sh` still never reads `cites:` and `review-brief.sh` never reads `hole:`.
6. Criterion 6, the tests. `review-brief.sh` covers A5 to A8, A11 to A17, the no-spec layout pin and `fragment()` over both `ref=` lines; `review-comment.sh` covers rows 1A to 1G, 2, 3, 4, 5A and 5D to 5G, 6, 7 and the notes' two-hole, last-field and rerun cases.
7. Criterion 7, babysit. The same sentence lands in `template/.agents/skills/babysit/SKILL.md:41` and `poteto-mode/playbooks/babysit.md:18`, both patches and `SOURCES.md` items 4 and 12; columns A to C of table B print as before.

## Would break

## Fails open

## Not asked for

hard findings: 0
