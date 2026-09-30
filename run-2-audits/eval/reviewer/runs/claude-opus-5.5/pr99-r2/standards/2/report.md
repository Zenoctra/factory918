# Standards review, 69bd412

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the reference grammar is copied into both scripts.** The same `ref` regex is defined in `review-brief.sh` and `review-comment.sh`. A test keeps the two copies in step, so this is a judgement call and not a defect. A shared file that both scripts source would remove the copy.

```bash
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

2. **Duplicated Code: the item's `[S<n>]`/`[P<n>]` id is parsed twice in `review-comment.sh`.** The judgment-reference loop and the new hole loop run the same `sed`. A small `ref_id()` helper next to `title()` would serve both.

```bash
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

3. **Inconsistent pipefail guard on `holed | head -1`.** Under `set -euo pipefail`, if `head` closes the pipe early, `holed` can exit with SIGPIPE, and that aborts the assignment. Line 564 guards against this with `|| true`, but the two sibling calls do not. Judgment files are small, so the pipe does not close early in practice. Adding the same guard would make the three calls consistent.

```bash
  line="$(holed | head -1)"
...
  line="$(holed "$h" | head -1)"
```

hard findings: 0
