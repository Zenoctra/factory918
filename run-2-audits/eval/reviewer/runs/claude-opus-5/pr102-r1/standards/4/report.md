# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Mysterious Name: P20 is still titled for the cap it no longer has.** The row now allows five rounds, but its title and opening clause still state three, and the new stale-wording pattern (`at most three rounds`) was chosen so it does not match the surviving phrase. Rename the row and reword the opening clause the amendment contradicts, or add the title to `no-stale-wording.sh`.

```
| P20 | Three review rounds at most | `review-brief.sh` counts the PR's earlier review comments and refuses a fourth round before writing any state; the comment prints `round: N of 3`; ... Amended 2026-09-22 (#93): from round three on ... the next round, to five, ...
```

2. **The new brief bullet is out of the list's order.** Step 4's bullets otherwise run in the order the script emits them (commits, stat, blast radius, diff, settled, report). `common()` emits `## The fix under review` between the stat and `## Blast radius`, but the bullet is written after the settled bullet. The "before the diff" clause keeps it from misleading, but the list stops being readable as the brief's shape.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, ...
```

3. **Duplicated Code: the round-five procedure is written twice and pinned nowhere.** The five-step stop (fix and mark, post the comment, write the report, `gh pr ready --undo`, go on and wait) is in `spec-review/SKILL.md` step 5 and again in `ticket.md`'s Would-break fix section, with no test holding the copies together, while every other string this change duplicates (`fix_rule`, the babysit merge-ready sentence, the `cap=3;` line) is pinned in `tests/spec-review/review-brief.sh`. Pin one copy as the source, as the change does for the rest, or have one point at the other.

```
+At round five with Would-break items still found: fix and mark them as at any last round and post the comment; then write a report for the human ...; mark the PR unfinished (`gh pr ready --undo`, ...); go on with the work that does not depend on this PR; and wait for the human.
```

hard findings: 0
