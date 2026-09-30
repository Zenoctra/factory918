# Standards report

## Would break

## Fails open

## Standards breaches

1. **P20's row title still states the retired count.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it". The row's amendment raises the cap to five, but its title keeps the old count, and the same title ships in the generated template copy. `tests/spec-review/no-stale-wording.sh` now bans "at most three rounds"; the title says the same thing in the other word order and passes the grep.

```
| P20 | Three review rounds at most | `review-brief.sh` counts the PR's earlier review comments and refuses a fourth round before writing any state; ... Amended 2026-09-22 (#93): from round three on the Act on items are fixed before the comment and the round may be the last, unless a fixed item sits under `## Would break` ...
```

## Fix alongside

2. **Duplicated Code: the `fixed:` sha shape is written twice, in two widths.** `review-comment.sh` decides what counts as a fix with `[0-9a-f]{7,40}$`; `review-brief.sh` pastes the same items into `## The fix under review` with `[0-9a-f]+$`. The repo already pins shared fragments byte for byte (`fenced=`, `ref=`, and now `cap=3;`, held together by `fragment()` in `tests/spec-review/review-brief.sh`); this one is not. A three-character `fixed: abc` is invisible to one script and a fix to the other.

```
fixed_items="$(printf '%s\n' "$deciding" | awk "$fenced"'
  /^## / { if (h == "Judgment") j = 1; next }
  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]+$/
')"
```

```
done < <(items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$' || true)
```

3. **The new SKILL.md step-4 bullet sits out of emission order.** The bullet list otherwise runs in the order `common()` writes the sections; the new one is listed after the diff and after `## Settled in earlier rounds`, which the script emits last, while its own text says "before the diff". The text is right and the position is misleading; move the bullet above the diff bullet.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, under exactly this paragraph: ...
```

hard findings: 0
