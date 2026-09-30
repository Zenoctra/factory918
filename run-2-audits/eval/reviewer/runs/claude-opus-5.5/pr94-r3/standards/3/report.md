# Standards review, 715100c

The change documents an existing behavior of `overlap.sh` and adds one test row for it. I checked the claim against the script: line 49 resets `skip` only on `/^## /`, and a `### ` line does not match that pattern, so `###` parts stay inside the skipped section as the new prose and comment say.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Time-relative wording in a core doc.** "From now on" depends on when the reader reads it. Naming the ticket or PR that introduced the rule would keep the sentence true later.
```
#42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section.
```

The two copies of `docs/agents/issue-tracker.md` are identical, and the generated `template/docs/factory918/SCENARIO-TABLE.md` matches its core source. Both follow the source-then-copy rule.

hard findings: 0
