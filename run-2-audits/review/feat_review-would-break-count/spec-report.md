## Would break

1. **A re-sorted Ask item cannot be re-aggregated: the new numbering check refuses it.** `review-comment.sh` now runs `numbered "$dir/judgment.md"`, requiring every judgment item to equal its document-order position. The documented Ask path moves an item from `## Ask` into a later bucket; item 3 landing under `## Dismissed` leaves the order 1,2,4,5,3 and the script exits 1. Neither SKILL.md step 5, babysit's step 4 nor the playbook tells the orchestrator to renumber, and no test exercises a re-sort that crosses headings (the round-3 fixture reruns an unchanged judgment).

```
An Ask item waits for the human. When the human answers, move it to the bucket the answer settles, with the answer as the one-line reason, and rerun `scripts/review-comment.sh <dir>` on the same reports; that is the same round, not a new one.
```

2. **The same round's rebuilt comment is counted as a round.** `review-brief.sh` derives the round from `[.comments[] | select(.body | test("(^|\n)act-on items:"))] | length`. The rebuilt comment (Ask answered, or a report sent back) also ends in `act-on items:`, so posting it — which the ladder and babysit require — makes the next run believe one more round ran. Three rounds become two whenever an Ask item is answered, and nothing instructs the orchestrator to edit the earlier comment in place or to pass `--round`.

```
`review-comment.sh` prints `round: N` above `act-on items`, counted from the PR's earlier review comments
```

3. **Settled items do not survive past one round.** Only `last.body` of the previous comment is parsed, and the carry comes from that judgment's Noted/Dismissed items. An item settled in round 1 is (correctly) not re-raised in round 2, so it is absent from round 2's judgment and absent from round 3's brief — round 3's reviewer may raise it afresh. That is the recurrence the criterion names.

```
Today each round is a fresh reviewer with the ticket body only; "whole `DECISIONS.md` is writable" was raised in rounds 2 and 4 of PR #75.
```

## Latent

4. **A review dir written before this change has no `round` file**, so `review-comment.sh <dir>` prints `round: 1 of 3` for it.

5. **The gh-derived refusal is untested.** `tests/spec-review/review-brief.sh` reaches the fourth-round refusal only through `--round 4`; the fake `gh` never reports three prior comments.

6. **Every comment by the ticket's author becomes spec**, including status notes the agent posts on the ticket under that login.

## Not asked for

7. **A fix for #79** (commit fd6c805, the fence/info-string rule and the pinned heading bullets) rides on this branch, outside #76's criteria and the one-concern-per-PR rule.

hard findings: 3
