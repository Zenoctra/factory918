## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Two quoting styles for the same `$fenced` splice.** Every existing splice site prepends the variable in double quotes (`awk "$fenced"'...'` or `awk -v sep="$rs" "$split$fenced"'...'`), but the new Risks check instead opens with a single-quoted literal and appends `$fenced` after it (`awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }'"$fenced"'...'`). Both are correct shell, but a reader scanning this file for how `$fenced` is spliced in now has two shapes to reconcile.
```
+  if ! printf '%s\n' "$grounding" | awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }'"$fenced"'
+      $0 == "## Risks" || $0 == "### Risks" { found = 1; exit }
+      END { exit !found }'; then
```

hard findings: 0
