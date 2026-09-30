## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code.** The new `ref=` regex line is a verbatim, non-trivial three-branch pattern copied between `review-brief.sh` and `review-comment.sh`, on top of the pre-existing `fenced=` awk fragment duplicated the same way. The tests pin the two copies identical (`fragment()` in `tests/spec-review/review-brief.sh`), but a shared value still lives twice on disk.

```sh
+ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```
(present, unchanged in wording, in both `template/.agents/skills/spec-review/scripts/review-brief.sh` and `.../review-comment.sh`)

hard findings: 0
