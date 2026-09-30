## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code.** The two refusal paths in the new Risks-heading check repeat the same three-line shape (`rm -rf "$dir"`, an `echo ... >&2`, `exit 1`) that the missing-grounding check just above it already uses.

```bash
  if ! printf '%s\n' "$grounding" | awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }'"$fenced"'
      $0 == "## Risks" || $0 == "### Risks" { found = 1; exit }
      END { exit !found }'; then
    rm -rf "$dir"
    where="the PR body's Blast Radius section"
    [ -z "$blast" ] || where="$blast"
    echo "review-brief: the blast-radius grounding ($where) has no Risks heading outside fenced text; put the risks under a line that is exactly \`## Risks\` in the file, \`### Risks\` in the PR body, where the grounding's headings are demoted one level so the section stays intact" >&2
    exit 1
  fi
```

hard findings: 0
