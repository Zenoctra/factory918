# Spec report

## Walk

1. `MANUAL.md:79` states the three relations: `Blocked by` off the frontier, disjoint files parallel off `main`, overlapping files sequenced; "Overlap is not coupling"; only coupled work stacks, on a go.
2. `MANUAL.md:81` routes autopilot-stack to coupled work, says the go appends a program line naming its tickets, that a line needs no removal, that the overlap is recorded in `## Overlap`, and that a rebase re-reviews only a PR whose `patch-id` changed.
3. `factory918/SKILL.md:55-56` carry the same two cases into the router rows, naming `overlap.sh N` and `overlap.sh go "<label>" 4 5 8`.
4. `autopilot-stack.md:7` (via `patches/.../autopilot-stack.md.patch`, hunk recounted to `-2,9 +2,9`) runs `overlap.sh go "autopilot-stack" 4 5 8` on the operator's go.
5. `ticket.md:5` step 1 runs `overlap.sh N` after the dirty check: the script reads the newest program line naming `#N` (`overlap.sh:29-31`), returns `base: main` with no origin (`:33-37`), collects backticked tokens outside `## Diff` (`:40-44`), lists open PRs and force-fetches every head (`:48-55`), and diffs each head from `nearest` (`:61-71`).
6. `overlap.sh:100-110` prints `base: origin/main` when nothing is shared, exits 1 when a printed PR's closing ticket is on no line, else picks the containing head, else the lowest number's.
7. `ticket.md:5` maps those exits: 0 branch from `<ref>`, 1 stop and reply, 2 stop and report stderr; `stack #N on #M` re-runs after a one-off `go`.
8. `ticket.md:12` step 8 runs `overlap.sh N --diff` and pastes the output as `## Overlap` before `## Verification`.
9. `docs/agents/ledger.md:22` records the seven-re-reviews mis-estimate and the stack it justified.

## Would break

## Fails open

1. **Step 8 has no exit-2 branch, so a failed check reads as "no overlap".** Table rows 10E and 11E give exit 2 as "stop, report", and step 1 says so; step 8 keys only on "output, when there is any" and exit 1. On exit 2 stdout is empty, so the agent writes no `## Overlap` section and proceeds to Opening a PR. Nothing distinguishes "the check ran and found nothing" from "the check could not run".

```
| 11. gh fails or is absent | gh's message (or `command not found`) on stderr / 2 / stop, report | | | | / 2 |
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:12`
Result: a PR opens with no Overlap section and no signal that the check failed; a reader reads the absent section as no overlap.

## Not asked for

hard findings: 1
