## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the reference grammar lives in two scripts.** `review-brief.sh` and `review-comment.sh` each define the same `ref` regex. The comments say a test holds the copies together, but a single sourced definition would remove the drift risk altogether.

```sh
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

2. **The design-hole redirect splits the PR-body sentences in ticket.md step 8.** The new sentence sits between "Then run **Opening a PR**." and the two sentences about that PR's body (Verification, `Closes #N`). As a result, the body rules now read as if they follow the redirect. Moving the redirect to the end of the step keeps the Opening-a-PR instructions together.

```md
Then run **Opening a PR**. A `spec-review` comment carrying the line `restart` names a design hole: go to **Design hole** below, not on to step 9. The body's Verification section quotes each criterion with its evidence path.
```

3. **Greedy `hole:` extraction can take the wrong value.** `mark` and `value()` both take the text after the last `hole:` on the line. A `design <signature>` value that itself contains `hole: ` would be cut at the inner occurrence. The documented forms make this unlikely, so it is only a judgement call.

```sh
mark="$(printf '%s' "$line" | sed -E "s#.*hole: ($ref)\$#\1#")"
```

hard findings: 0
