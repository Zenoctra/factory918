# Standards report, c83f166

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Mysterious Name: two checks numbered 17.** The new check reuses the number of the one above it, so a failure message "17 ..." no longer points at a single case, and every later number is off by one from the count of cases.

```bash
check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
...
check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

2. **Test does not show the skip ends.** The old case 17 puts a counted section (`## Notes`) after `## Diff`, which proves the awk flag resets. The new body ends inside a skipped section, so it cannot tell a skip that resets from one that runs to the end of the body. A trailing `## Notes` with a token would prove the reset for the two new headings.

```bash
## Design

`src/z.txt`'
check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

3. **Duplicated Code: the step 6 write-back procedure is stated twice.** The read, append and write-back sequence, the failure stop and the overlap-skip sentence appear in both `ticket.md` step 6 and `SCENARIO-TABLE.md` "Where it goes". A later change has to edit both files. The page could point at the playbook step instead of restating it.

```
The Ticket playbook's step 6 reads the current body into a file, adds the table at the end under `## Testing decisions`, and writes the whole file back with `gh issue edit N --body-file`, because that command replaces the body and never merges.
```

Checked and cleared: `to-spec` writes `## Testing Decisions` with a capital D, which the case-sensitive awk pattern does not match. A spec's own testing prose is therefore still counted, and the skip applies only to the section step 6 appends. The `build_knowledge.py` docstring matches the code (`if p.name != "CONVERSATION-DIGEST.md"`). "the first five" matches the five documents listed before `docs/knowledge/INDEX.md`.

hard findings: 0
