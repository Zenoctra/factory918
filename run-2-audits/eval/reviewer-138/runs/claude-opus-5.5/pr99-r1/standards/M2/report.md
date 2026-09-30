## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the trailing-field patterns and the reference extraction are each written twice in `review-comment.sh`.** The new `ending` regex restates the two patterns that `fixed_here` and `ticketed` grep for a few lines below, so a change to the `fixed:` or `ticket:` grammar now has to be made in two places or `holed` and the count disagree. The `[S<n>]`/`[P<n>]` extraction `sed` is also copied from the refs loop into the hole loop. Fix: define the two field patterns once and build both `ending` and the counts from them, and give the reference extraction one small function that both loops call.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
...
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Judgement call: `holed` treats any `hole:` in a reason as a field, but the comment above it says only the field that ends the line counts.** A Noted or Dismissed reason such as "not a design hole: the cell stands" is refused as "carries a 'hole:' field under '## Noted'". Step 5 now asks the judge to decide hole or bug, so this wording is likely. The refusal names the heading and the item, so the judge can reword and rerun. It is loud, not silent, and it is not a hard finding. The comment and the code say different things, though, and the next reader will trust the comment. Fix: make the comment say that any `hole:` text in a judgment line is read as a field attempt, and that this is why a malformed field is refused (column E).

```sh
# reference of the report item the judgment item names. The field that ends the line is the
# field, so a `hole:` before a trailing `fixed:` or `ticket:` is text.
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
# holed <heading>: the judgment items under the heading whose line carries a `hole:` field.
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

Checked, no finding: `set -euo pipefail` and quoted paths in every new line; the new `# shellcheck disable=SC2016` in the test carries its reason on the narrowest scope; `|| true` covers only grep's no-match; `sed -E`, `awk` POSIX classes and `paste -sd` behave the same on BSD and GNU; the three changed patches apply and `./factory918.sh sync` reproduces the template byte for byte (run in a scratch git copy); ShellCheck 0.11.0 is clean; `tests/spec-review/review-comment.sh` (134), `review-brief.sh` (414), `no-stale-wording.sh` and `tests/hooks/delegation.sh` (55) pass; the counts in prose ("Four trailing fields", "three forms", "five malformed cites") are true at this commit.

hard findings: 0
