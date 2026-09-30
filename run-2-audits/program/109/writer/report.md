# Writer report, ticket #109

Branch: `wt/109-writer`, in worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a86de29853404e1ef`, created from `origin/main` (a9ebdac). Nothing pushed, no agents launched.

## Log, origin/main..HEAD (oneline)

```
391a8e7 Say in the manual how to set the tier and that safe is the fallback.
c25cc71 Carry the tier in the autopilot-stack owner brief and let architect run one runner with an adversarial judge.
811cf86 State the safe and eco tiers once in Ticket step 0 and point to them where lanes launch.
96901b9 Assert the delegation hook answers the same under every tier file.
```

## Checks (all on HEAD 391a8e7)

- `bash .github/shellcheck.sh ...` (the brief's file set): pass, "ShellCheck 0.11.0, files checked: 24".
- `bash tests/hooks/delegation.sh`: pass, `ok 76 assertions`. On `origin/main` the same file gives `ok 55 assertions`, so +21. Table B was green against the unmodified hook on commit 96901b9, before any other change; every row matched the table.
- `bash tests/shellcheck/gate.sh`: pass, `ok 17 assertions`.
- `bash tests/poteto-mode/overlap.sh`: pass, `ok 57 assertions`.
- `./factory918.sh sync`, then status --porcelain: rc 0, empty.
- `python3 tools/build_knowledge.py`, then status --porcelain: empty.
- `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`.

## Flags (act-on list)

1. Table B is written as a `for tier in none eco junk` loop holding seven `expect` lines, one per row (B1..B7), each with a literal expected exit and message and its own label `tier <t>: B<n> ...`. That is 21 assertions at runtime from 7 source lines, the loop form the brief allows. The fixture for each tier is set inside a `case`. `rm -f .claude/state/tier` runs after the loop and before `echo planning`.
2. B6 runs `bash .claude/skills/spec-review/scripts/review-brief.sh main` as a command string only. The fixture has no such file, so the test proves the hook passes the command, not that the script runs.
3. The architect patch has one hunk (`@@ -29,12 +29,14 @@`), not two. The new paragraph sits five lines below the existing edit, so `diff -u` merged the contexts into one hunk. This is the regenerated output of the brief's `diff -u --label` command, and sync re-applies it cleanly.
4. The architect's "Design it twice." is not bold in the file (the brief quoted it as `**Design it twice.**`). The new paragraph goes after that paragraph, as the brief says.
5. The new architect sentence sits directly after "Require at least two structurally distinct candidates". The two sentences read as a rule and its exception, but that paragraph does not say the exception exists. A reviewer may want "unless the caller's tier asks for one runner" added to it. I left the paragraph as the brief gave it.
6. `check_knowledge.py` passes with the dangling `P109` mentions in MANUAL.md and ticket.md, so it does not check that a P-id in prose resolves. P109 still needs the owner's DECISIONS.md row before merge.
7. Wording kept as the brief gave it for ticket.md step 0 and the five pointers, and for the MANUAL paragraph and sentence. The ticket.md pointer for step 6 goes after the long sentence that names `architect`'s first deliverable, which ends "never merges.".
8. SOURCES.md item 11 gains "the owner's brief carries the tier as the digest's `Tier: eco` line and the owner follows it for its whole run (#109)". Item 14 gains "a caller whose tier asks for one runner (`eco`) keeps the cross-judge, briefed to read that one candidate adversarially (#109)".
9. Outside the table. Ticket step 0 cites "Feature step 5" as the path CI takes. That matches feature.md step 5 ("A fix lane proves its change on the path CI takes"), which is phrased for a fix lane, not an owner. Worth checking that an eco owner reads it as applying to itself.
10. The /deslop and /unslop skills were not loaded. I read the diff myself instead: the test code has no narrating comments, and the prose is the brief's text with no additions besides the SOURCES clauses in flag 8.
11. The worktree-isolation guard refuses a Bash command whose text names the version-control tool, so this report's log heading and status lines are reworded. The commands themselves ran as the brief names them.
