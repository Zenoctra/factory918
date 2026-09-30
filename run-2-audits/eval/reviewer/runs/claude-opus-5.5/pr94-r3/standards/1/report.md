# Standards review, 715100c

The change is documentation plus one new test case. The skip rule in `overlap.sh` (line 49) is `awk '/^## /{skip=...}'`, so a `### ` line never matches `^## ` and never ends the skip. The new `### Contract` part in test 17 therefore stays skipped, which is what the docs now describe. The core and generated SCENARIO-TABLE hunks are identical, and so are the two issue-tracker copies.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Shotgun Surgery: one rule stated in four places.** The rule that the whole artifact stays in one section with `###` parts, because the skip ends at the next `## `, is written separately in `ticket.md` step 6, in `SCENARIO-TABLE.md`, and in `issue-tracker.md`, and the `overlap.sh` header restates the skip boundary. The next change to the skip boundary has to edit all of them. The playbook step could state the rule once and the other docs could point to it.

```diff
+... The whole artifact (the legend, the table, the contract and the test list, or the usage and the signatures) stays inside that one section, its parts under `###` headings, because the skip ends at the next `## ` heading.
+... Each section holds the whole artifact, with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading.
```

2. **"From now on" in durable prose.** The phrase depends on when it is read, and a later reader cannot tell which commit it means. Naming the commit or PR that set the rule would fix that.

```diff
+#42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section.
```

hard findings: 0
