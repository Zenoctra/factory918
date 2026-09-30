# Standards review

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Test comment says the opposite of the assertion under it.** Smell: Mysterious Name, in a comment. The 1A comment says the risk sentence sits "on its own line". The assertion right under it, the script's comment ("the risk sentence joins it on the same line") and SKILL.md ("continues on the same line") all say the sentence is on the bullet's line. Change the comment to "on the bullet's line".

```
+# 1A: --blast-radius FILE with `## Risks` and a numbered risk. Both briefs carry the grounding under
+# `## Blast radius` before `## Diff`; the Spec brief's Walk bullet continues with the risk sentence
+# on its own line; the Standards brief does not carry the sentence.
```

2. **The risk sentence exists in four copies.** Smell: Duplicated Code, accepted by design. `risk_rule` is spelled out in `review-brief.sh`, `tests/spec-review/review-brief.sh`, `SKILL.md` and the vendored patch. The test holds the script and SKILL.md together, so drift gets caught, and this follows the same pattern as `blast_rule` and `step_rule`. Nothing to change unless a would-break fix touches this code.

```
+risk_rule='The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, ...'
```

hard findings: 0
