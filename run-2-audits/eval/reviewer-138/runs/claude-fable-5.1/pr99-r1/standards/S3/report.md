## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `fixed:` and `ticket:` regexes live twice in `review-comment.sh`.** `ending` repeats the two patterns the count greps use eight lines later; a change to one shape (say, a 6-char sha) would have to land in both, and `holed()` and `fixed_here` would disagree if it did not. Fold the count greps onto `$ending`'s alternatives, or build `ending` from two named variables the counts also use.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
...
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

2. **Mysterious Name, mild: `holed()` matches `hole:` as a substring.** A judgment reason containing `loophole:` or `pothole:` is picked up as a field and refused as "fits no form". The refusal is loud, so this is a judgement call, not a finding; anchoring the grep to a word start (`grep -E '(^| )hole:'`) would keep the message honest for that reason text.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

Verified: ShellCheck at the repo pin exits 0 over the changed shell files; `tests/spec-review/review-brief.sh` (414 assertions), `tests/spec-review/review-comment.sh` (134) and `tests/spec-review/no-stale-wording.sh` pass. The two `ref=` lines and the `fenced` fragment are byte-identical across the scripts. The new `# shellcheck disable=SC2016` in the comment test sits on the one statement that needs it with its reason on the same line, per CODING_STANDARDS.md. No `sed -i`, `date -d` or `readlink -f`; every path stays quoted; `|| true` only guards a `grep` that legitimately matches nothing. "Four trailing fields" is true at this commit.

hard findings: 0
