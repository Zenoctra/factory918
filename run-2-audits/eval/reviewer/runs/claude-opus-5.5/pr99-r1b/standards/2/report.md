# Standards report, 69bd412

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the reference grammar lives in two scripts.** `review-brief.sh` and `review-comment.sh` each define the same `ref` regex, and both comments point at a test that keeps the two copies in step. That is acceptable, but the grammar is now the core contract of `spec:`, `hole:` and `cites:`. A shared sourced file, or one script printing it for the other, would remove the need for the test.

```
+ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

2. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is repeated in review-comment.sh.** The same `sed` that pulls the judged item id appears in the references loop and again in the hole-check loop. A one-line helper, like the new `title()`, would give both sites one definition.

```
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

3. **Shotgun Surgery: the restart rule is written out in five places.** The "`restart` is not merge-ready" paragraph appears word for word in `babysit/SKILL.md`, `playbooks/babysit.md`, both babysit patches and SOURCES.md entries 4 and 12. This follows the patch-and-template layout the repo requires, so it is noted only. It is fixed only if a later edit touches the paragraph again.

```
+   A review comment carrying the line `restart` names a design hole and is not a merge-ready comment whatever its count: ...
```

hard findings: 0
