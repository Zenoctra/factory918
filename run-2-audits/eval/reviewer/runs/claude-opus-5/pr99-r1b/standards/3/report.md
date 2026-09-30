## Would break

1. **The human's merge checklist still reads `act-on items: 0` as ready.** The change teaches `babysit/SKILL.md`, `playbooks/babysit.md`, `playbooks/ticket.md` and `review-ladder.md` that a `restart` comment is not merge-ready whatever its count, but `docs/knowledge/core/MANUAL.md` is untouched. Its readiness rule is now false: `review-comment.sh` prints `restart` and `act-on items: 0` together whenever every Act on item is a hole, which the comment test asserts ("two holes print one restart line and both are left out"). The standard is `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it."
Documented step: `docs/knowledge/core/MANUAL.md:103`, "It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`"
Result: the human reads a mid-restart PR as ready and merges work whose design hole was never closed; the agent answering "is PR N safe to merge?" from MANUAL.md says yes.
spec: table 1/D

```sh
[ "$holes" -eq 0 ] || echo restart
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

## Fails open

## Standards breaches

2. **The restart resets the round cap, and `DECISIONS.md` P20 was not amended.** P20 reads "Three review rounds at most ... `review-brief.sh` counts the PR's earlier review comments and refuses a fourth round"; after this change the cap is three rounds *per series*, and a restart starts a fresh three. `CODING_STANDARDS.md`, "Commits and pull requests": "a choice to `docs/knowledge/core/DECISIONS.md` under Provisional." No row was added or amended.

```
# refusal counts only what follows it
# the redesign's first review is round 1 and the fourth-round refusal counts the new series alone.
```

## Fix alongside

3. **`hole:` is detected by an unanchored substring.** `grep 'hole:'` also matches a word ending in `hole:` (`whole:`, `loophole:`), which then reaches the form check and is refused with a confusing message. Mysterious Name / over-broad match; a `(^| )hole:` anchor would say what the field is.

```sh
holed() { items "$dir/judgment.md" "${1:-}" | grep -vE "$ending" | grep 'hole:' || true; }
```

hard findings: 1
