## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code.** The reference grammar for `cites:`/`spec:`/`hole:` (`table <row>/<column> | design <signature> | criterion <k>`) is copied verbatim, character for character, between `review-brief.sh` and `review-comment.sh`, mirroring the pre-existing `fenced=` fragment duplication. A test (`fragment()` in `tests/spec-review/review-brief.sh`) pins the two copies equal, which is the repo's accepted mitigation for this exact pattern elsewhere, so this is a judgement call rather than an unmitigated duplication.

```sh
+ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```
(appearing identically in both `template/.agents/skills/spec-review/scripts/review-brief.sh` and `template/.agents/skills/spec-review/scripts/review-comment.sh`)

hard findings: 0
