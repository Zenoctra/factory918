# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **The skip list is case-sensitive, and the spec's own heading is capitalized.** `to-spec/SKILL.md:59` writes the spec section as `## Testing Decisions`; the awk predicate matches only `Testing decisions`. Every documented writer of the ticket body (Ticket step 6, `SCENARIO-TABLE.md`, P25) uses the lowercase form, so the happy path holds, but a body carrying the spec's capitalization has its cell paths counted and can stop the ticket on a false overlap. A `[[:space:]]`-tolerant, case-insensitive match (`tolower($0) ~ /^## (diff|testing decisions|design)[[:space:]]*$/`) closes it at no cost.

```
-  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
+  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
```

2. **The new case never proves the skip ends.** Existing case 17 puts a `## Notes` section after `## Diff`, so it proves both that the section is skipped and that counting resumes at the next heading. The new body ends with `## Design`, so both skipped sections run to EOF and the expected output (`paths: none`) is the same output a body with no token at all gives (case 9). Appending a counted section, for example `## Notes` with a token no PR touches, would pin the resumption for the two new headings too.

```
+## Design
+
+`src/z.txt`'
+check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

3. **Step 6 names no place for the body file.** The step says to read the body into a file and write it back, without saying where the file lives; every other artifact in the playbooks is given a path (`.scratch/<ticket>/blast-radius.md`). `.scratch/<ticket>/body.md` would keep the intermediate out of the tree the diff sees.

Checked and clean: the line counts (`MANUAL.md` is 175, the INDEX row and the header agree), the five documents under `template/docs/factory918/` against "the first five", the `build_knowledge.py` docstring against its `CONVERSATION-DIGEST.md` exclusion at line 136, the new patch's hunk context against `template/.agents/skills/architect/SKILL.md`, its `series` line and its `SOURCES.md` entry, and the source and template copies of P24, which are identical.

hard findings: 0
