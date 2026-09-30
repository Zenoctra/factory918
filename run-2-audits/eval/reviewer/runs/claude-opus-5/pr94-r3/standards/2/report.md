# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The overlap header comment wraps raggedly after the reflow.** The rewrapped block leaves `# no base. \`overlap.sh go` as a short line in the middle of the paragraph, so the `go` subcommand's sentence starts at the end of a line and reads as part of the `--diff` sentence. No documented standard covers script comments (the markdown rule is for docs and skills), so this is a judgement call; rewrap while the file is open.

```
# `overlap.sh N --diff` compares the branch's own paths by the same rule (the own PR skipped,
# literal pathspecs), prints nothing when none is shared, the go and the PR lines otherwise, and
# no base. `overlap.sh go
# "<label>" N...` appends `<label>: #a #b ...` to the program file, its only writer;
```

Checked and clear: the awk skip (`overlap.sh:49`) uses `/^## /`, which does not match a `###` line, so the new rule the prose states is what the code does, and the test's `### Contract` case exercises it. Both `issue-tracker.md` copies and both `SCENARIO-TABLE.md` copies carry the same text, so source and generated agree.

hard findings: 0
