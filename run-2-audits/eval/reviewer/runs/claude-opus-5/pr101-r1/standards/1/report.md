## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The Risks heading's level is bound to its source in prose, not in the code.** `SKILL.md` and the refusal message both pin `## Risks` to a file and `### Risks` to a PR body, while the awk accepts either line from either source (the test asserts this as cell 2A). `DECISIONS.md` P26 states the loose rule ("from a `--blast-radius FILE` or the PR body's section alike"), so the code is right and the two sentences a person reads are narrower than what runs. Judgement call, no behaviour change; worth one word ("typically", or naming both levels for both sources) if a would-break fix already touches this block.

```
  if ! printf '%s\n' "$grounding" | awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }'"$fenced"'
      $0 == "## Risks" || $0 == "### Risks" { found = 1; exit }
      END { exit !found }'; then
```

```
The grounding carries its risks under a line that is exactly `## Risks` in a file or `### Risks` in a PR body, ...
```

hard findings: 0
