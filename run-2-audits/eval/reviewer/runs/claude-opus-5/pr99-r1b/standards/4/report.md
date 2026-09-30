## Would break

1. **The Standards brief demands a `spec:` reference it never gives the reviewer.** `review-brief.sh` now writes `$spec_rule` into `standards-brief.md` whenever a ticket was fetched, and `review-comment.sh`'s `report()` runs the `spec:` check on `standards-report.md` as well as on `spec-report.md`. But the Standards brief carries only the commits, the `--stat`, the diff, the standards files and the smell baseline: the ticket body, its `## Testing decisions` table, its `## Design` sketch and its criteria go into the Spec brief alone, and the Standards brief ends with "Read nothing beyond this brief". The Standards reviewer is therefore ordered to name a cell, a signature or a criterion it has never seen, on pain of its report being sent back. The only report that passes is one whose `spec:` lines are guesses that happen to match `$ref`; the check is a shape check, so a guess passes. Step 5 then judges a hole against that guess, and the `hole:` word-for-word comparison in `review-comment.sh` compares two fabrications. (This report is the demonstration: its brief carries the spec rule and no artifact.)

Documented step: `template/.agents/skills/spec-review/SKILL.md` step 4, "The spec rule is in a brief only when step 2 found a spec: a review with no spec has no scenario table, no `## Design` sketch and no criteria, so no item is asked what it rests on" — the condition is "the review has a spec", not "this brief carries it".
Result: the Standards axis invents references, `review-comment.sh` accepts them, and the design-hole path rests on them.
spec: table B/2

```sh
  if [ -n "$spec" ]; then
    echo "$spec_rule"
    echo
  fi
  echo "Write your report to \`$dir/standards-brief.md\` ..."
```

```sh
  [ -n "$has_spec" ] || return 0
  line="$(stepless "$f" "^spec: $ref\$")"
```

## Fails open

## Standards breaches

## Fix alongside

2. **A bare `restart` line anywhere in a posted comment wipes the history.** `review-brief.sh` matches `$0 == "restart"` over the whole comment body, and `review-comment.sh` prints both reports verbatim inside it. A report whose prose puts the bare word on its own line, outside a fence, resets the round to 1 and drops every settled item silently. The `round:` line is protected by "the last such line is its own"; this one is not. Judgement call, not a documented breach.

hard findings: 1
