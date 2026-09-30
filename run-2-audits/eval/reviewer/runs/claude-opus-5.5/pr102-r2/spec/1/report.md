## Walk

1. Criterion 1, the comment: `review-comment.sh` resolves each Act on line ending in `fixed:` to its report heading through `specs`. On the first one under `Would break`, with no hole marked, it reads `<dir>/reviewed`, refuses anything that is not 40 hex (RM), and prints `would-break fixed after <sha>` between the summary line and `round:`. A hole prints `restart` instead. Fails-open, breach and prose fixes print no line.
2. Criterion 1, the brief: `review-brief.sh` takes the last comment of the history, reads its WB line outside fenced text and refuses a malformed line first (FM). It then refuses round six (F6). A round past three without the line, or that is not `top + 1`, is refused with F4 or F5, and F4's text is byte-identical.
3. Criterion 2: from round four the brief requires the fixed point to resolve (FR) and to equal the line's sha (FP). With a spec and no ticket it refuses (FT). All of these run at line 207, before `mkdir -p "$dir"` at line 261 and before the empty-diff refusal. `common()` adds `## The fix under review` with `fix_rule` and the deciding comment's fixed Act on lines, before the diff. SKILL.md step 1 and the Ticket playbook's new section give the `<sha> --ticket N` command.
4. Criterion 2, the record: `git rev-parse HEAD > "$dir/reviewed"` is written beside `round` in both forms.
5. Criterion 3: step 5 has the two judgment stops (a look at round three, and at five a report, `gh pr ready --undo`, and a wait). No code compares counts, and the summary line prints no would-break count.
6. Criterion 4: `babysit.md` and `babysit/SKILL.md` carry the same replacement sentence, and both patches were regenerated. A round-three comment without the line reads as before.
7. Criterion 5: `tests/spec-review/review-brief.sh` asserts `round: 4 of 5`, the fix section, FP and the five-round refusal. `review-comment.sh` asserts the WB line at rounds 3, 4 and 5.
8. Criterion 6: P20 is amended and P30 added. The ladder's rung 1 is one sentence. `at most three rounds` is on the stale-wording list.

## Would break

## Fails open

## Not asked for

hard findings: 0
