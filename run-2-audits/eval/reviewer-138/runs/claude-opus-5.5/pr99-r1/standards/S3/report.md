## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **`hole:` is found as a substring anywhere on a judgment line, prose included.** This is a judgement call, not a breach of a documented standard. The table's own note says "only the field that ends the line is a field", but `holed()` uses a bare `grep 'hole:'`. So a Dismissed or Noted reason that contains the text `hole:` is refused as a misplaced field. That includes "not a design hole: the cell stands" and the word "whole:". An Act on reason that contains it is refused as "fits no form". I ran this in a temp repo: `2. [S2] **Two.** not a design hole: the cell stands` under `## Dismissed` exits 1 with "carries a 'hole:' field under '## Dismissed'". The refusal is loud and rewording fixes it, so it does not count. Now that the skill teaches the phrase "design hole", this reason text is likely to occur. Anchoring on `hole: ` preceded by start-of-line or whitespace, or testing only the trailing field, would match what the note says.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

2. **Duplicated Code: the trailing `fixed:`/`ticket:` patterns are written twice.** `ending` spells both regexes. Forty lines below, the two count greps spell them again, separately. A change to one grammar (the sha length, for example) has to be made in both places, or `holed` and the count will disagree about which field ends the line. Fix: build `fixed_here` and `ticketed` from the same two pieces, or define the pieces once and compose `ending` from them.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
...
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

Checked and clean:
- `bash .github/shellcheck.sh` passes over the 5 changed shell files.
- The tests pass: `tests/spec-review/review-comment.sh` (134 assertions), `review-brief.sh` (414) and `no-stale-wording.sh`.
- Every new `# shellcheck disable` carries its reason on the same line and sits above a single statement.
- `./factory918.sh sync` on a copy leaves `git status` clean, so the three patches reproduce the template.
- `tools/check_knowledge.py` passes.
- Every count in the prose ("Four trailing fields", "a fourth citation form") is true at this commit.

hard findings: 0
