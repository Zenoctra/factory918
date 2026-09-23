## Walk

1. `review-brief.sh` writes `git rev-parse HEAD` to `<dir>/reviewed` beside `<dir>/round`, in the sweep form too (one code path), after the state dir is rebuilt.
2. The round parse becomes `/^round: [0-9]+ of [35]$/`, so comments written before this ticket still parse and `of 5` comments count.
3. The deciding comment is cut as the last non-blank comment of the post-restart history, CR and trailing blanks stripped; `wb`, `had_spec` and `fixed_items` are read from it alone, outside fenced text.
4. `FM` fires first when the words are followed by anything but 40 lowercase hex, including nothing.
5. `F6` next when the round exceeds five.
6. Past three, a missing line or a round that is not `top + 1` gives `F4` (byte-identical to the old refusal when `top <= 3` and the round is four) else `F5`.
7. `FR` when the named commit does not resolve, then `FP` when the fixed point is not that commit (the sweep form's `paths` lands here), then `FT` when no ticket resolved and the previous round had a spec.
8. `cap=3; [ "$round" -le 3 ] || cap=5`, written identically in both scripts, prints `round: N of <cap>`.
9. From round four `common()` prints `## The fix under review`, `$fix_rule`, then the deciding comment's fixed Act on lines, after `## Changed files` and before `## Blast radius` and `## Diff`, in both briefs.
10. `review-comment.sh` computes the same cap, resolves each `fixed:` Act on item to its report heading through `specs()`, and prints `would-break fixed after <sha>` only when a `## Would break` item is fixed and no hole is marked; `restart` outranks it.
11. `RM` refuses a missing or non-40-hex `<dir>/reviewed` after the round-file refusal, before any output, naming the first Would-break fix and telling the caller to write the id rather than rerun the brief.
12. Tail order stays summary, restart/WB line, `round:`, `act-on items:` last; the summary prints no would-break count.
13. `spec-review/SKILL.md` steps 1, 4, 5 and 6 carry the new text, and every added line of `patches/mattpocock/spec-review.SKILL.md.patch` appears verbatim in the template copy.
14. `ticket.md` step 8 routes to a new `### Would-break fix` section; no step is renumbered.
15. Both babysit copies carry the replacement merge-ready sentence byte-identical, pinned by `has` in the brief test; their patches match too.
16. `review-ladder.md` rung 1, `MANUAL.md`'s merge checklist, `DECISIONS.md` P20's amendment and P30, `SOURCES.md` items 4, 6 and 12, and the generated `template/docs/factory918/` copies all say the same.
17. `no-stale-wording.sh` blacklists `at most three rounds`; no occurrence remains under `template` or `docs/knowledge/core`.
18. `tests/spec-review/review-brief.sh` adds one assertion per table A cell and pins the `cap=3;` line through `fragment()`; `review-comment.sh` adds one per table B cell and `rearm()` writes `reviewed`.

## Would break

## Fails open

## Not asked for

hard findings: 0
