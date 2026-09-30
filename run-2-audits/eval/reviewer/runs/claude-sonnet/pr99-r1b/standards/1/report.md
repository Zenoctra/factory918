## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code.** The artifact-reference grammar is a second regex copied verbatim between the two scripts, alongside the existing `fenced` fragment duplication, guarded only by a test that diffs the two copies rather than a shared source.
```sh
+ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```
(present identically in both `review-brief.sh` and `review-comment.sh`; `tests/spec-review/review-brief.sh`'s `fragment()` now also greps `/^ref='/p` to keep the copies from drifting, the same guard already used for `fenced`.)

2. **Mysterious Name.** `specs()` hardcodes the byte offset past the literal `spec: ` prefix as a bare `7` instead of deriving it from the match, so a future change to the prefix's spelling silently miscounts.
```sh
+specs() {
+  awk -v want="^spec: $ref\$" "$fenced"'
+    function flush() { if (item) print at "\t" v; item = 0; v = "" }
+    /^## / { flush(); next }
+    /^[0-9]+\. / { flush(); if (h != "" && h != "Walk") { item = 1; at = h } next }
+    item && (at == "Would break" || at == "Fails open") && v == "" && $0 ~ want { v = substr($0, 7) }
+    END { flush() }
+  ' "$1"
+}
```

hard findings: 0
