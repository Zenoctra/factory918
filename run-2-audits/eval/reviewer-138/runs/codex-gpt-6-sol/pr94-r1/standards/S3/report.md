## Would break

## Fails open

## Standards breaches

1. **The worked table leaves cells undefined.** `docs/knowledge/core/DECISIONS.md:93` (P25) requires one assertion per cell, and `docs/knowledge/core/SCENARIO-TABLE.md:29-33` says every cell contains the printed output, exit code, and caller action. The newly published canonical example has blank cells without a legend saying they are inapplicable or inherit another cell. That makes the example inconsistent with the rule it teaches.

   ```md
   | 5. Program died; its line left behind | rows 2 to 4 apply unchanged: a line covers only stacks among the tickets it names while their PRs are open; nothing to clean up | | | | |
   | 10. A PR head with no merge base against its base | git's `no merge base` on stderr / 2 / stop, report; the human closes or rebases that PR | | | | / 2 |
   ```

## Fix alongside

hard findings: 0
