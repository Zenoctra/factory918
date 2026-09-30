# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the CR/trailing-whitespace trim idiom is inlined a third time.** The new Risks-heading check re-writes the same normalization awk block that already exists twice in this file (the `fenced` definition and the `top`/round-parsing block), instead of reusing `$split`'s or a shared snippet.

```awk
  if ! printf '%s\n' "$grounding" | awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }'"$fenced"'
      $0 == "## Risks" || $0 == "### Risks" { found = 1; exit }
      END { exit !found }'; then
```

hard findings: 0
