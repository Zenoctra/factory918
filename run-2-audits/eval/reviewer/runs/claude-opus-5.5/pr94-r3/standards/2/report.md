# Standards review, 715100c

The change adds one rule in prose (a design artifact stays inside its one `## ` section, with `###` parts) and a test cell for it. No documented standard is breached. The rule matches the script: `overlap.sh:49` starts a new section only on `/^## /`, so a `###` line does not end the skip, and the new `### Contract` cell tests exactly that.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: one rule written out three times.** The same sentence goes into `docs/agents/issue-tracker.md` (and its template copy), `SCENARIO-TABLE.md` and the Ticket playbook's step 6, so any later change to the skip has to touch all three. The earlier step-6 text already had the same spread, so this is a judgement call and counts for nothing.

```diff
+... The whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test list) under `###` headings, because the skip ends at the next `## ` heading.
```

hard findings: 0
