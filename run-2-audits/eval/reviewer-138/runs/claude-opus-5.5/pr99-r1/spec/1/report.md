## Walk

1. Criterion 1: the design-hole paragraph is in SKILL.md step 5 and review-ladder.md rung 1, with the contract's wording.
2. Criterion 2: `spec_rule` is written one blank line after `step_rule` in both briefs. `stepless "^spec: $ref$"` refuses a counted item without the line, after the step refusal (table B rows 2 to 4).
3. Criterion 3: `holed()` checks placement (G), then grammar (E), then the value against `specs()` (F, 5D). The holes are left out of `act-on items`, and `restart` is printed before `round:`.
4. Criterion 4: the awk in review-brief.sh keeps only the comments after the last `restart` line, prints `restart:`, and resets the round and the settled items (rows 5 to 13). ticket.md has the Design hole section and the step 8 pointer.
5. Criterion 5: `cites:` gains `#[0-9]+ $ref`. Rows 14 to 17 pass.
6. Criterion 6: all three test files pass (134, 414, ok), and ShellCheck is clean on the 7 files. `factory918.sh sync` on a snapshot leaves `git status` clean.
7. Criterion 7: the babysit sentence is byte-identical in both files, and columns A to C are unchanged.
8. Outside the file list, which the ticket leaves alone: `docs/knowledge/core/MANUAL.md:103` still reads "ready when ... `act-on items: 0`" and says nothing about a `restart` comment.

## Would break

## Fails open

1. **A report that ends inside an open fence hides the `restart` line.** `review-comment.sh` finds `hard findings:` with a grep that ignores fences, so it accepts a report whose last quoted block never closes. The fence then stays open in the posted comment through `## Judgment`, `restart` and `round:`. `review-brief.sh` reads that comment with the fence rule and sees no restart line and no round line. Reproduced: a Standards report whose last `Fix alongside` item opens a fence and never closes it, with a judgment item marked `hole: criterion 1`. `review-comment.sh` exits 0 and prints `restart`. Fed back through `--previous`, the next brief prints `round: 2 of 3` and no `restart:` line. A restart posted at round 3 gets the fourth-round refusal instead. The swallowed `round:` line predates this PR; the ignored restart is new.
Documented step: `template/.agents/skills/spec-review/SKILL.md:25`, "so the redesign's first review is round 1 with nothing carried"
Result: the redesign's review runs as round 2 (or is refused at round 4). Nothing is printed, and the hole's three fresh rounds are lost.
spec: table 5/A

```
| 5. (1), (2 restart) | `X`, `R(1)`, no S, `paths` / 0 / the redesign's round one |
```

## Not asked for

hard findings: 1
