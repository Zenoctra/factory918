## Would break

1. **The Standards brief carries no ticket, so no counted Standards item can satisfy the new spec rule.** `report()` is shared by both reports, so the spec check runs on `standards-report.md`, and all three forms name a part of the ticket. The Standards brief is `common` + the standards files + the smell baseline + the report rules; the ticket body reaches only the Spec brief. Breaches CODING_STANDARDS.md, Bash: "Every doctor check carries its fix as the third argument. A `FAIL` with no fix is a bug" — this reviewer cannot perform the fix the refusal names. It bit this review: I could not ground a cell, signature or criterion for this item.
Documented step: `template/.agents/skills/spec-review/SKILL.md:84`, "The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` ... or `criterion <k>` ..."; the brief's contents are `SKILL.md:86`.
Result: a real breach is dropped, or filed with an invented reference that `review-comment.sh` then validates word for word against the invention once it is marked `hole:`.
spec: design report <file> <heading>...

```sh
  line="$(stepless "$f" "^spec: $ref\$")"
  [ -z "$line" ] || fail "$f item '$(title "${line#*: }")' under '## ${line%%: *}' has no 'spec:' line; a counted item names what it rests on ... Ask the reviewer for it"
```

## Fails open

## Standards breaches

2. **`MANUAL.md` still makes `act-on items: 0` sufficient for merge-ready.** A judgment whose only Act on items are holes prints `restart` and `act-on items: 0` (`tests/spec-review/review-comment.sh`, "two holes print one restart line and both are left out"). The ladder, `babysit/SKILL.md` and the Ticket playbook were amended; the core manual was not, so the human's checklist passes a PR mid-restart. CODING_STANDARDS.md, Markdown: "`docs/knowledge/core/` is the source".

```
2. It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`; ...
```

3. **No decision records the restart.** `DECISIONS.md:87` P20, "Three review rounds at most", still says the script "counts the PR's earlier review comments and refuses a fourth round"; it now counts only those after the last restart, so the cap is per series, not per PR. Nothing was added under Provisional. CODING_STANDARDS.md, Commits and pull requests: "a choice to `docs/knowledge/core/DECISIONS.md` under Provisional".

## Fix alongside

4. **Duplicated Code.** The `fixed:`/`ticket:` patterns are written twice, in `ending` (line 156) and again at lines 197-198. Widening one and not the other lets an item be both excluded from `holed` and counted as fixed, understating the count. Build `ending` from two named patterns the counts reuse.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
```

5. **Duplicated Code.** The restart awk's `END` block re-derives comment boundaries and repeats `$split`'s CR and trailing-blank stripping, which the same program already applied to `$0`. Two copies that must stay in step.

```sh
for (i = 1; i <= NR; i++) { t = raw[i]; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t); at[i] = c; if (t == sep) c++; else if (hit[i]) last = c }
```

hard findings: 1
