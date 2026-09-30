# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **The `## The #42 example` caveat restates a rule that now lives in four files.** The section's job is the verbatim legend and table; the added history says #42's own record predates the rule and that future tables differ. The rule itself is already stated in `docs/agents/issue-tracker.md`, the Ticket playbook step 6, and this file's "On the ticket" section, so a later change to it has four prose sites to keep true (Smell baseline, Shotgun Surgery). A clause pointing at the rule's home would carry the same warning.

```
+The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. #42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section.
```

Checked and clean, so not findings: the claim the prose adds is true of the code it describes. `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` recomputes `skip` only on lines matching `/^## /`, which requires a space as the third character, so a `### ` heading leaves `skip` set and the section runs to the next `## `. The script's behavior is unchanged here; only its header comment was rewrapped, and it now matches line 49. The new test case discriminates rather than decorates: the added `### Contract` quotes `src/x/y.txt`, which test 18 proves PR 2 touches, so test 17 would print a PR line if the skip stopped at the `###`. The generated `template/docs/factory918/SCENARIO-TABLE.md` and the vendored `docs/agents/issue-tracker.md` match their sources (`docs/knowledge/core/`, `template/docs/agents/`) hunk for hunk, per AGENTS.md "Which files are the truth".

hard findings: 0
