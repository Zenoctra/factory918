# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the round cap is computed twice.** `review-brief.sh` and `review-comment.sh` each derive `of 3`/`of 5` from the round with the same line, held together only by a comment and a test. It's small, and the two scripts share no library, so it can stay as long as the test pins both copies.

```bash
# review-brief.sh
cap=3; [ "$round" -le 3 ] || cap=5
# review-comment.sh
cap=3; [ "$round" -le 3 ] || cap=5
```

2. **Shotgun Surgery: the round rule's prose is spread over nine files.** The sentence "three rounds, five when round three or four fixed a Would-break item" plus the ready condition is repeated almost word for word in babysit `SKILL.md`, the babysit playbook, both of their patches, `SOURCES.md` twice, `review-ladder.md`, `MANUAL.md` and `spec-review/SKILL.md`. Each later change to the rule has to hit all of them, and `no-stale-wording.sh` only catches the old wording. The vendored patches make some of this copying structural. The babysit copies could point to `spec-review` step 5 instead of restating the rule.

```
The review runs three rounds on one PR, five when round three or four fixed a Would-break item; a comment reading `round: 3 of 3`, `round: 4 of 5` or `round: 5 of 5` with `act-on items: 0` and no `would-break fixed after <sha>` line makes the PR review-ready ...
```

3. **Repeated Switches: two messages refuse a round past three.** The nested `if` in the gate picks between two refusal texts for one condition, the missing `would-break fixed after` line. A single message that includes `$top` would cover both cases.

```bash
if [ "$top" -le 3 ] && [ "$round" -eq 4 ]; then
  echo "review-brief: three rounds were run on this PR; ..." >&2
else
  echo "review-brief: round $round does not follow a review comment carrying ..." >&2
fi
```

hard findings: 0
