## Would break

1. **The human's merge checklist still says a zero count means ready.** The change teaches three readers of `act-on items:` that a `restart` comment is not merge-ready whatever its count (`babysit/SKILL.md`, `poteto-mode/playbooks/babysit.md`, `docs/agents/review-ladder.md`), and `review-comment.sh` now subtracts every `hole:` item from the count. A PR whose only Act on item is a design hole therefore publishes `restart` above `act-on items: 0`. The merge step Manuel follows was not amended, and it tests the count alone, so a PR mid-redesign passes it.
Documented step: `docs/knowledge/core/MANUAL.md:103`, "It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`; ... If any of those is missing, say 'fix that and come back'." (generated copy: `template/docs/factory918/MANUAL.md`)
Result: the human merges a PR whose design was returned to `architect`; the Design hole section's "A PR mid-restart is never merge-ready" is never reached, because the one reader that decides the merge never learned the rule.
spec: design a review comment carrying `restart` is not merge-ready whatever its count

```
+[ "$holes" -eq 0 ] || echo restart
 echo "round: $round of 3"
-echo "act-on items: $((act - fixed_here - ticketed + ask))"
+echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

## Fails open

## Standards breaches

2. **The count's decision row was not amended.** `AGENTS.md`, "Pull requests": "A decision you had to make goes under Provisional in `DECISIONS.md`". P19 defines `act-on items` and was amended once before for `ticket:`; `hole:` is the second exclusion and the `restart` line is new, and neither reaches P19 or P20. No `DECISIONS.md` hunk is in the diff.

```
| P19 | ... `act-on items` is Act on plus Ask (amended 2026-09-18, PR B: an Act on
item marked `ticket: #N` is filed as its own ticket and not counted) ...
```

## Fix alongside

3. **Shotgun surgery, the readers of one line.** Four files now repeat the restart sentence nearly word for word (item 1's three, plus `spec-review/SKILL.md`). Nothing holds the copies together the way `tests/spec-review/review-brief.sh` holds the rules; `no-stale-wording.sh` only bans the old phrase.

4. **Duplicated line-offset assertions.** The two new blocks in `tests/spec-review/review-brief.sh` are the same shape, and a rule that ever matches twice makes `-ne` fail on a multi-line operand rather than on the offset.

```
+  if [ "$(grep -nF -- "$spec_rule" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "$step_rule" "$f" | cut -d: -f1) + 2))" ]; then
```

hard findings: 1
