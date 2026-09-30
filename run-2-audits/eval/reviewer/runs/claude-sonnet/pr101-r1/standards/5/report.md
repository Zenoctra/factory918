## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated refusal shape in `review-brief.sh`.** The new Risks-heading refusal repeats the shape of the grounding-empty refusal right above it (`rm -rf "$dir"`, compute a `where`/message naming the source, `echo ... >&2`, `exit 1`), down to the `[ -z "$blast" ] || where="$blast"` source-naming idiom. Fix alongside a would-break touching this block by factoring the two refusals into one small helper (e.g. `refuse_grounding <msg-using-$where>`).

```sh
  if ! printf '%s' "$grounding" | grep -q '[^[:space:]]'; then
    rm -rf "$dir"
    echo "review-brief: cross-cutting diff (${crossing# }) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE" >&2
    exit 1
  fi
  # The Spec walk covers each risk by name (the Walk bullet below), so the grounding must hold them
  # under a heading the reviewer can find, at either level: a file keeps its own `## Risks`, a PR
  # body carries the file with its headings demoted to `###` so the section above survives. Read
  # outside fenced text with the same fence rule as a report; a bullet hand-back has no heading.
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
