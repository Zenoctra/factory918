

## Testing decisions

Posted by the agent 2026-09-22. Two architect runners (Fable, Opus) designed this from the code at PR #99's head and converged on every structural choice; the judge was skipped. The scenario table is the spec for the mechanism: a review finding that changes a cell is a design hole and returns the work to architect; a finding that leaves the table standing is an implementation bug fixed on the PR. The test is written from the table before the script, one assertion per cell.

### Scenario table

Cell = what the Spec brief's `## Walk` bullet carries / exit / what the orchestrator does. `R` = the bullet as today plus the risk sentence (the Contract), with `## Blast radius` before `## Diff` in both briefs as today. `plain` = the bullet as today, no risk sentence. `E` = today's refusal `review-brief: cross-cutting diff (<paths>) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE`, stderr, exit 1, no state, no briefs. `N` = the new refusal (the Contract), stderr, exit 1, no state, no briefs. `ignored` = today's stderr line `review-brief: the diff is not cross-cutting; <FILE> is not pasted`, the file never read. "Grounding" = the file's text, or the PR body's section cut at the next unfenced `## ` line, leading blank lines stripped (today's extraction, unchanged). The Standards brief carries the risk sentence in no cell; `review-comment.sh` reads no cell (walk lines are steps, never items).

| Situation | A. cross-cutting diff | B. not cross-cutting |
|---|---|---|
| 1. `--blast-radius FILE`, `## Risks` unfenced, numbered risks under it | `R` / 0 / spawn both lanes; the reviewer walks the steps, then the risks | `plain`, `ignored` / 0 / spawn both lanes |
| 2. `--blast-radius FILE`, `### Risks` (a body pasted back to a file) | as 1A; the source restricts no level | as 1B |
| 3. PR body section, `### Risks` inside it (PR #92's shape; CRLF and a fenced `## ` line kept, today's fixture) | `R` / 0 / spawn both lanes | `plain` / 0 / the body is never fetched |
| 4. PR body section, headings not demoted (`## Risks` after `## Blast Radius`) | the section ends at the first inner `## `: nothing left before it gives `E`, prose left gives `N` / 1 / stop; the author demotes the body's headings to `###` (Opening a PR); no code beyond the two messages | as 3B |
| 5. Grounding present, no Risks heading at all (the bullet hand-back `- **Risks.**`, today's `blast.md`) | `N` / 1 / stop; the author adds the heading; no code beyond the message | as 1B or 3B |
| 6. The only Risks heading is inside a fenced block | as 5A: headings are read outside fenced text only | as 1B or 3B |
| 7. Both levels present (`## Risks` then `### Risks`) | `R` / 0 / the first unfenced one satisfies the check; nothing is counted, so nothing else moves | as 1B or 3B |
| 8. Risks heading with no numbered line under it | `R` / 0 / the reviewer writes zero risk lines; no code | as 1B or 3B |
| 9. No grounding: no `--blast-radius`, and no PR or an empty `## Blast Radius` section | `E` / 1 / stop, as today | `plain` / 0 / spawn both lanes, as today |
| 10. `--blast-radius` names no file | refused with the tool's own message, the `usage()` block / 1 / stop; costs no code | as 10A |

### Contract

The rule: one shell variable, `risk_rule`, holding this sentence, appended to the Spec brief's `## Walk` bullet on the same line, only when `grounding` is non-empty; the bullet's own text does not change, so the assertions that pin it hold as substrings:

> The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing.

`SKILL.md` step 4 carries the sentence word for word as it carries the blast-radius paragraph, and step 1's cross-cutting paragraph says the grounding must carry a Risks heading and quotes the refusal; `tests/spec-review/review-brief.sh` pins the sentence as one string in the source `SKILL.md`, in the Spec brief (1A), and absent from the Standards brief (1A) and from every Spec brief of a diff that is not cross-cutting (1B, 3B).

Detection, inside the existing cross-cutting block, after the empty-grounding check and before any state is written, over the grounding text whatever its source, with the shared `fenced` awk (fenced text skipped), CR and trailing blanks stripped: the first line that is exactly `## Risks` or `### Risks`. Not found: `rm -rf "$dir"`, then on stderr, exit 1:

> review-brief: the blast-radius grounding (<FILE, or: the PR body's Blast Radius section>) has no Risks heading outside fenced text; put the risks under a line that is exactly `## Risks` in the file, `### Risks` in the PR body, where the grounding's headings are demoted one level so the section stays intact

Files: `template/.agents/skills/spec-review/scripts/review-brief.sh` (the variable, the detection, the refusal, the header comment); `template/.agents/skills/spec-review/SKILL.md` through `patches/mattpocock/spec-review.SKILL.md.patch` (steps 1 and 4); `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`: the `## Blast Radius` bullet says the file's `## ` headings are demoted to `###` when it is pasted, because an undemoted `## ` line ends the section, and that `review-brief.sh` finds the risks under `### Risks`; `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 5 (ours): the hand-back is written with each part under a `## ` heading and one numbered risk per line under `## Risks`, and "that file verbatim" becomes "that file with its `## ` headings demoted to `###`"; `SOURCES.md` items 3 and 6, one sentence each. `template/.agents/skills/blast-radius/SKILL.md` is vendored and not touched. `review-comment.sh` is unchanged; criterion 3's regression check is one fixture in `tests/spec-review/review-comment.sh`: a Spec report whose walk continues with risk lines still counts them as steps (the same `hard findings:` and `act-on items:` as without them).

Tests, `tests/spec-review/review-brief.sh`, one assertion per cell, named by row and column in a comment: 1A and 1B on a new `blast-risks.md` (today's `blast.md` text plus `## Risks` and one numbered risk), the cross-cutting `x.sh` commit and the README-only commit; 2A the same file with `### Risks`; 3A and 3B today's CRLF `pr-body.md` with `### Risks` added, its existing assertions standing; 4A a `pr-body-undemoted.md` with prose then `## Risks`, refused with `N` naming the PR body, no state, no briefs; 5A today's `blast.md` unchanged, now refused with `N` naming the file; 6A `blast-fenced.md`; 7A `blast-both.md`; 8A `blast-empty-risks.md`; 9A, 9B and 10 today's assertions, unchanged. The `SKILL.md` block gains the `risk_rule` pin.

Open, with the default taken: the heading text is exactly `Risks` (`## Risks (confirmed)` is refused, the message says the form); the risk lines continue the walk's numbering; the Spec report's word cap is unchanged (PR #92 had four risks); `blast-radius/SKILL.md` still hands back bullets, so `ticket.md` step 5 carries the heading shape instead of a patch on that skill.
