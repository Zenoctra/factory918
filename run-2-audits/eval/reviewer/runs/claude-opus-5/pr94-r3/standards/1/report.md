# Standards report

The change is prose plus one comment rewrap and one test case; the documented claim it adds was checked against the code that implements it, and they agree.

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Rewrapped comment leaves a stub line mid-sentence.** The header rewrap in `overlap.sh` ends a paragraph at `` `overlap.sh go `` with the rest of that backtick span on the next line, so a quoted command is split across a line break and the line is a quarter full. Rewrapping the remaining three lines of the paragraph would close it. Cosmetic; touch it only if a real fix lands in this header.

```
+# no base. `overlap.sh go
 # "<label>" N...` appends `<label>: #a #b ...` to the program file, its only writer; a linked
```

Checked and clean: the awk skip at `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` keys on `/^## /`, which a `### ` line does not match, so the new sentences in `docs/agents/issue-tracker.md`, `template/docs/agents/issue-tracker.md`, `SCENARIO-TABLE.md` (both copies) and `playbooks/ticket.md` describe what the script does. The two `SCENARIO-TABLE.md` copies and the two `issue-tracker.md` copies carry identical text, so source and generated/vendored copies are in step (CODING_STANDARDS.md, Markdown). The new `### Contract` fixture in `tests/poteto-mode/overlap.sh` exercises the claim rather than restating it, and its check name was updated with it. No counts or versions in the new prose.

hard findings: 0
