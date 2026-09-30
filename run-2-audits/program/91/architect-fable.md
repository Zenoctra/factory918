# Design for #91: the Spec walk covers every blast-radius risk (base: PR #99's head, 52ccd8e)

## Usage

`review-brief.sh HEAD~1 --blast-radius blast.md` on a cross-cutting diff, `blast.md` holding a `## Risks` heading: stdout, stderr and both briefs' `## Blast radius` as today; the Spec brief alone carries one more paragraph, directly after its four heading bullets:

> This diff is cross-cutting: after the lines per documented step, the walk carries one numbered line per risk under the grounding's Risks heading (the `## Blast radius` section above), each naming the risk and saying what the diff does at that risk. These lines are walk lines too, numbered on from the step lines, and count nothing.

`review-brief.sh <fixed>` with a PR body holding `## Blast Radius` with `### Risks` inside (PR #92's shape): the same.

Either source without a Risks heading outside fenced text: stderr `review-brief: the blast-radius grounding (blast.md | the PR body's Blast Radius section) has no Risks heading; put the risks under "## Risks" in the file, "### Risks" in the PR body, where the grounding's own headings are demoted one level so the section stays intact`, exit 1, no state, no briefs.

Not cross-cutting: nothing new; with `--blast-radius`, today's stderr line `not pasted`, the file unread.

## Scenario table

Cell = Spec brief carries / exit / caller. `S` = `## Blast radius` before `## Diff`, both briefs (today). `W` = the paragraph above, Spec brief only. `E` = today's refusal `cross-cutting diff (<paths>) without a blast-radius grounding; ...`. `N` = the new refusal above. Both: stderr, exit 1, no state. Grounding = the file's text, or the body's section cut at the next unfenced `## `.

| Situation | A. cross-cutting diff | B. not cross-cutting |
|---|---|---|
| 1. `--blast-radius FILE`, unfenced `## Risks`, numbered risks under it | `S`, `W` / 0 / reviewer walks steps, then risks 1..R | no `S`, no `W`; stderr `not pasted` / 0 / as today |
| 2. `--blast-radius FILE`, `### Risks` (a body pasted back to a file) | as 1A; the source restricts nothing | as 1B |
| 3. PR body (CRLF, a fenced `## ` line inside: today's fixture), `### Risks` inside the section (PR #92) | as 1A | no `S`, no `W`, silent; body not fetched / 0 |
| 4. PR body, headings not demoted (`## What it does` ... `## Risks`) | the section ends at the first inner `## `: nothing left, `E`; prose left, `N` / 1 / demote to `###`; no code | as 3B |
| 5. No Risks heading (the bullet form `- **Risks.**`, today's fixtures) | `N` / 1 / add the heading; no code beyond the message | as 1B or 3B |
| 6. `Risks` heading only inside a fence | not found: `N` / 1 / as 5A | as 1B or 3B |
| 7. Both levels present, or two `### Risks` | the first satisfies the check: as 1A | as 1B or 3B |
| 8. Risks heading, no numbered line under it | as 1A / the reviewer writes zero risk lines; no code | as 1B or 3B |
| 9. Absent: no `--blast-radius`, no PR or an empty section | `E` / 1 / as today | silent / 0 / as today |
| 10. `--blast-radius FILE` missing on disk | refused with the tool's own message, `usage:` / 1 | same |

Column B never reads the file or the body; the Standards brief carries `W` in no cell. `review-comment.sh` reads no cell: risk lines under `## Walk` are steps, never items, never counted (`items()` skips `Walk`).

## Contract

Rule: `risk_rule`, the paragraph under Usage, one fixed string naming neither level nor count, emitted in the Spec brief when `grounding` is non-empty. `SKILL.md` step 4 carries it word for word, as it carries `blast_rule`; the test pins one string in both. A level or a count would pin two fragments and buy nothing: `review-comment.sh` enforces no count (criterion 3).

Detection: one predicate over the extracted grounding whatever its source, after today's empty check and before any state; on a miss `rm -rf "$dir"`, `N`, exit 1:

```
printf '%s\n' "$grounding" | awk "$fenced"'/^##?# Risks[ \t]*$/ { f = 1; exit } END { exit !f }'
```

The shared `fenced` awk skips fenced text and CR; the first unfenced `## Risks` or `### Risks` satisfies it. A body section cannot hold `## Risks` (the cut ends there first), so both levels from both sources costs no branch and refuses nothing valid.

Files:

- `review-brief.sh`: `risk_rule` beside `blast_rule`; the check and `N`; the Spec block emits `risk_rule` after the bullets when `grounding` is set.
- `patches/mattpocock/spec-review.SKILL.md.patch` (template copy kept equal by `sync`): step 1 quotes `N`; step 4's Spec brief adds after the bullets "For a cross-cutting diff (step 1), then the risk rule, word for word:" and the paragraph.
- `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`: the bullet's last sentence becomes "For a cross-cutting diff (Ticket step 5) this section is `.scratch/<ticket>/blast-radius.md` with its `## ` headings demoted to `###`, so the section stays one section; `spec-review`'s `review-brief.sh` reads it from here and finds the risks under `### Risks`."
- `ticket.md` step 5 (ours, `keep_files`): each hand-back part under a `## ` heading, risks numbered under `## Risks`; "verbatim" becomes "with its headings demoted to `###`".
- `SOURCES.md` items 3 and 6, one clause each. `review-comment.sh` unchanged.

Tests, `tests/spec-review/review-brief.sh`, one assertion per cell after the existing blast-radius cases. `risk_rule` joins the pinned strings: `has SKILL.md`; `has $spec`, `lacks $std` in 1A; `lacks $spec` in the non-cross-cutting runs. Reused: `blast.md` gains `## Risks` plus one `1. **Title.**` risk (1A, positioned two lines after the Not asked for bullet); the CRLF `pr-body.md` gains `### Risks` (3A); `pr-body-empty.md` (9A); the README commit (1B, 3B); the `x.sh` commit throughout. New, one per cell: `blast-h3.md` (2A), `blast-bullets.md` with today's bullet text (5A: `N` exactly, no state, the existing `set +e` pattern), `blast-fenced.md` (6A), `blast-both.md` (7A), `blast-empty-risks.md` (8A), `pr-body-undemoted.md` in both shapes (4A). Cell 10 is today's usage assertion. `tests/spec-review/review-comment.sh` gains one walk numbered 1..4, lines 3 and 4 risk lines; counts unchanged (criterion 3).

## Rationale

The brief already carries the grounding; on #87 and #92 the walk's shape demanded nothing per risk, so reviewers who read the risks wrote nothing about them. One fixed sentence attached to the walk closes that for one pinned string. Refusing a grounding without a Risks heading is the definition's own line: the rule names a heading, so without one the reviewer writes zero risk lines silently, which fails open; the refusal names the fix, so the demotion rule reaches the playbook too.

Rejected: a variable sentence (two pinned fragments, nothing downstream checks the count); a per-source level rule (it refuses only a file pasted back from a body); the bullet form as a third shape (the ticket names two; bullet risks are not numbered lines the walk can mirror); a nested bullet under Walk (the test pins the Walk bullet whole); counting risk lines in `review-comment.sh` (criterion 3).

## Open

- `E` does not mention demotion: an undemoted `## What it does` right after `## Blast Radius` gets `E`, not `N`. Default: leave `E`, pinned exactly by two assertions; the playbook teaches demotion.
- A file with `## Risks` puts a `## ` heading inside the brief's `## Blast radius` section. Nothing parses a brief; default: leave it.
- Variants (`### Risks (confirmed)`) get `N`. Default: exact match.
- The blast-radius skill's hand-back is a bullet list (vendored). Default: no patch there; `ticket.md` step 5 carries the heading requirement.
