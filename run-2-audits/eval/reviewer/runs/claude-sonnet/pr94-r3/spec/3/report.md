## Walk

1. `docs/agents/issue-tracker.md` and its template copy add one sentence: each of the `## Testing decisions` / `## Design` sections must hold the whole artifact, with `###` headings for its parts, because the overlap check skips a section only up to the next `## ` heading.
2. `docs/knowledge/core/SCENARIO-TABLE.md` and its generated `template/docs/factory918/SCENARIO-TABLE.md` copy add the same rule, naming the artifact's parts (legend, table, contract, test list) as the `###` subheadings, and note that ticket #42's own record predates the rule and still uses `## ` for its parts.
3. `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 adds the identical rule for both the scenario table and the usage/signature sketch.
4. `template/.agents/skills/poteto-mode/scripts/overlap.sh`'s header comment is reworded to say the skip runs "up to the next `## ` heading" instead of just naming the two sections.
5. `tests/poteto-mode/overlap.sh` extends fixture 17's `## Testing decisions` body with a nested `### Contract` heading and a backtick path, keeping the expected result (`paths: none`) the same, and renames the check's description accordingly.

Checked against the code: the skip logic (`awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip'`) toggles only on lines matching `^## ` (two hashes then a space); a `### Contract` line does not match that anchor, so it never flips `skip` off. The comment change in step 4 and the new test case in step 5 both describe behavior the script already had — no code line in `overlap.sh` changed outside the comment.

## Would break

(none)

## Fails open

(none)

## Not asked for

(none)

hard findings: 0
