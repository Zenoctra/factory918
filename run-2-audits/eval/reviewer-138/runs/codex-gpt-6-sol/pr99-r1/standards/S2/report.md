## Would break

## Fails open

## Standards breaches

1. **New test paths are unquoted.** `CODING_STANDARDS.md`, Bash rule “Quote every path. Paths here contain spaces.” The added restart fixtures pass path operands without quotes. Quote these operands in the new test code.

```sh
sed 's/^round: 2 of 3$/round: 3 of 3/' restart-2.md > restart-3.md
{ cat previous.md; printf '\036\n'; cat restart-2.md; } > both.md
rm -rf .scratch .claude/state
```

## Fix alongside

hard findings: 0
