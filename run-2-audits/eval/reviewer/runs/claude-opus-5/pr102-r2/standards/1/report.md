# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The `fixed:` grammar is the one shared fragment no test holds together.** `review-comment.sh` decides an item is fixed with `{7,40}`; `review-brief.sh`, which pastes the same items into the next brief, matches `[0-9a-f]+`. The two scripts already pin `fenced`, `ref=` and now `cap=3; ` against drift with `fragment()` in `tests/spec-review/review-brief.sh`; this third shared grammar is copied by hand and not pinned. Smell: Duplicated Code. Lift the `fixed:`/`ticket:` anchors into the same copied fragment the test compares.

```
+  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]+$/
```

```
+done < <(items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$' || true)
```

2. **`<dir>/reviewed` records `HEAD` in the sweep form too, where `HEAD` is not what was reviewed.** In the `--paths`/`--commits` form the diff is `git show <commits> -- <paths>` and `fixed` is the literal word `paths`, so `HEAD` is unrelated to the reviewed commits. The write is unconditional, and `review-comment.sh` has no sweep case: a sweep judgment marking a Would-break item `fixed:` would print a `would-break fixed after <sha>` naming a commit the review never looked at. The PR path is unaffected (a sweep has no PR rounds), so this is a judgement call, not a count. Write the file only outside the sweep form, or record `${commits[0]}` there.

```
 echo "$round" > "$dir/round"
+git rev-parse HEAD > "$dir/reviewed"
```

3. **`SKILL.md` step 4 lists the new section out of emission order.** The bullet is placed after `## Settled in earlier rounds`, but `common()` emits `## The fix under review` before `## Blast radius`, the diff and the settled section. Both texts say "before the diff", so nothing is wrong, but a reader building the brief by the bullet order gets a different file from the script's. Move the bullet above the blast-radius one.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, under exactly this paragraph: ...
```

hard findings: 0
