## Walk

1. Criterion 1: `spec-review/SKILL.md` step 5 gains the design-hole paragraph (three artifacts, intent outranks a criterion, could-not-run refusals excluded); `review-ladder.md` rung 1 carries the same definition and the `hole:`/`restart` path.
2. Criterion 2 (as amended): `review-brief.sh` echoes `$spec_rule` after `$step_rule` in the Spec brief and, only when `$spec` is set, in the Standards brief; `review-comment.sh` sets `has_spec` from `<dir>/spec-brief.md` before the Standards report and runs `stepless "$f" "^spec: $ref\$"` after the step check.
3. Criterion 3: `holed()` takes judgment lines not ending in `fixed:`/`ticket:` that hold `hole:`; refusals run no-spec, then placement (G), form (E), value against `specs()` (F, 5D); `holes` is subtracted and `restart` printed between the summary and `round:`.
4. Criterion 4: the slice awk keeps only comments after the last exact, unfenced `restart` line; `restart:` is printed after `ticket:`; the round and settled derivations read the slice; the Ticket playbook's step 8 pointer and Design hole section send the work to `architect` Phase B with two runners and a dated amendment; both babysit files carry the byte-identical sentence.
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group.
6. Criterion 6: the tests cover rows B1A-G, B2-B5, B7, the two-holes, last-field and rerun notes; A5-A8, A11-A17; the `ref=` twin in `fragment()`; the no-spec brief layout.
7. Criterion 7: columns A to C keep the old output; the babysit addition applies only to a comment carrying `restart`.

## Would break

## Fails open

## Not asked for

1. **Merge read in MANUAL.md.** Both `MANUAL.md` copies now say that a `spec-review` comment carrying `restart` is not ready. The ticket's Files touched says:

```
`arena`, `architect`, `MANUAL.md` and `DECISIONS.md` (the owner's Provisional entry) untouched by the writer.
```

The line agrees with criterion 4 ("A PR mid-restart is never merge-ready"). Commit 384bb43 is the owner's entry, which the ticket expects, so this is recorded here and not counted.

hard findings: 0
