## Walk

1. `spec-review/SKILL.md` step 5 and `docs/agents/review-ladder.md` rung 1 both gain the design-hole definition (three artifacts: table cell/term, `## Design` signature, acceptance criterion; intent outranks a criterion; a could-not-run refusal is not a hole), word for word between the two.
2. `spec-review/SKILL.md` step 4 gains the `spec_rule`, echoed by `review-brief.sh` into both briefs one blank line after the step rule; `review-comment.sh`'s `report()` calls `stepless()` a second time with `^spec: $ref\$` and refuses a counted item lacking it, before the judgment is read.
3. `SKILL.md`'s trailing-fields list goes from three to four, adding `hole: <reference>`; `review-comment.sh` checks a `hole:` field in order — outside Act on (any of Ask/Consider/Noted/Dismissed), fitting no form, then differing word-for-word from the item's `spec:` — and subtracts matched holes (`holes`) from `act-on items`.
4. `review-comment.sh` prints `restart` right after the summary line and before `round:` when any Act on item carries a well-formed `hole:`.
5. `review-brief.sh` slices the fetched comment history to what follows the last line that is exactly `restart` outside fenced text (via the existing `$split` CR/whitespace trim), prints `restart: the round and the settled items count from the last restart comment`, and both the round and the `cites:` carry-forward read only the sliced history.
6. `poteto-mode/playbooks/ticket.md` step 8 sends a `restart`-carrying `spec-review` comment to a new **Design hole** section (architect Phase B scoped to the reference, dated amendment, tests rewritten, review restarted) instead of on to step 9.
7. `babysit/SKILL.md`, `poteto-mode/playbooks/babysit.md` (and their `patches/pstack/...` copies) each gain one byte-identical sentence: a `restart` comment is never merge-ready regardless of its count.
8. `cites:` gains a fourth form, `#N <reference>`, sharing the `ref` grammar with `spec:`/`hole:` (`tests/.../review-brief.sh`'s `fragment()` holds `fenced` and `ref` together across both scripts); `no-stale-wording.sh` blacklists the retired "Three trailing fields" phrase.
9. New fixtures in `tests/spec-review/review-brief.sh` (table A rows 5–17: restart detection in prose/fences/trailing text, multiple restarts, four-comment refusal, cite carry-forward and malformed-cite drop) and `tests/spec-review/review-comment.sh` (table B rows 1–6: missing/malformed `spec:`, each `hole:` column, two-holes-one-line, last-field-wins, rerun-after-state-cleared) exercise the contract.

## Would break

## Fails open

## Not asked for

hard findings: 0
