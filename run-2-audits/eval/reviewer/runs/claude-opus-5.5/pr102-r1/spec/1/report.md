## Walk

1. Criterion 1: `review-comment.sh` resolves each `fixed:` Act on item's reference through `specs()` and prints `would-break fixed after <reviewed>` only for a `## Would break` heading. Fails-open, breach and ticketed fixes print no line. `review-brief.sh` reads the line from the deciding comment and refuses a sixth round (`F6`).
2. Criterion 2: the gate requires `<sha>` to resolve (`FR`) and to equal the fixed point (`FP`). `<dir>/reviewed` records HEAD at brief time. `SKILL.md` step 1 and the Ticket playbook name `review-brief.sh <sha> --ticket N`.
3. Criterion 3: no count comparison in either script. The step 5 paragraph gives the round-three look, the go-on to four and five, and the round-five report, draft and wait.
4. Criterion 4: babysit's sentence is identical in both copies and pinned by the brief test. A round-three comment without the line reads as before, and `F4` is byte-identical.
5. Criterion 5: the brief test covers rows 3, 9 and 11 (round four fix-only, round five, sixth refused). The comment test covers row 3 in columns C and D.
6. Criterion 6: P20 is amended and P30 is added. The ladder's rung 1 carries the one sentence, and MANUAL gains the `would-break fixed after` condition.

## Would break

1. **The Ticket playbook sends a round-one or round-two Would-break fix to a fix-only round.** Ticket step 8 routes any comment that carries the line to **Would-break fix**. That section's step 1 says to run the next round "with `<sha>` as its fixed point", `review-brief.sh <sha> --ticket N`, for every round "below round five". `review-comment.sh` prints the line at rounds one and two too (table B 3A). Table A row 12 says the next round then reviews the whole diff from the original fixed point, and the script does not check the sha before round four. `SKILL.md` step 6 also calls the sha "the next round's fixed point" with no round qualifier.
   ```
   | 12. (1W s) ... | `R(2)`, `S`, no FIX, `paths` / 0 / round two reviews the whole diff from `o`, as today; the sha is not checked before round four
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md`, Would-break fix step 1: "Below round five: run the next round with `<sha>` as its fixed point and the ticket named".
   Result: round two runs from `<sha>` with no refusal. It reviews only the fix commits, and the rest of the diff gets one review where the design gives it two or three. A later `act-on items: 0` then reads as review-ready.
   spec: table 12/A

## Fails open

## Not asked for

hard findings: 1
