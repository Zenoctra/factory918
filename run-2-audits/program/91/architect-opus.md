# Design for #91: the Spec walk covers every blast-radius risk

## Usage

Two command lines, from `spec-review` step 1, on a cross-cutting diff:

```
review-brief.sh HEAD~1 --blast-radius .scratch/91/blast-radius.md
review-brief.sh 52ccd8e          # the grounding comes from the PR body
```

Both print, unchanged, `ticket: #N`, `round: N of 3` and the two brief paths on stdout, and nothing on stderr. The orchestrator hands each path to its lane.

The Spec brief's `## Walk` bullet then reads as today, plus one sentence, word for word:

> For a cross-cutting diff the walk continues past the documented steps with one line per risk under the grounding's Risks heading, in the grounding's order, each saying what the diff does at that risk; these lines are steps too and count nothing.

Appended to that bullet, on its line, only when the brief carries `## Blast radius`; the Standards brief has no Walk.

A grounding with no Risks heading is refused before any state, exit 1:

```
review-brief: the blast-radius grounding (<FILE, or: the PR body's Blast Radius section>) has no Risks heading; add a line that is exactly `## Risks`, or `### Risks` in a PR body, where the inner headings are demoted so the section stays intact, with one numbered risk under it
```

## Scenario table

Cell = what the Spec brief's Walk bullet carries / exit / what the orchestrator does. `R` = the bullet plus the risk sentence, with `## Blast radius` before the diff. `plain` = today's bullet, no risk sentence. `ignored` = the existing stderr line `the diff is not cross-cutting; <FILE> is not pasted`, the file never read. Both levels are accepted from both sources.

| Situation | A. cross-cutting diff | B. not cross-cutting |
|---|---|---|
| 1. `--blast-radius FILE`, `## Risks` | `R` / 0 / spawn both lanes | `plain`, `ignored` / 0 / spawn both lanes |
| 2. `--blast-radius FILE`, `### Risks` | as 1A | as 1B |
| 3. PR body section, `### Risks` (PR #92's shape) | `R` / 0 / spawn both lanes | `plain` / 0 / the body is never fetched |
| 4. PR body section, headings not demoted (`## Risks`) | the section is cut at `## Risks`, so the grounding has none: refused, naming the PR body / 1 / stop; the author demotes the headings | as 3B |
| 5. Grounding present, no Risks heading (the bullet hand-back `- **Risks.**`) | refused, naming the source / 1 / stop; the author adds the heading | as 1B or 3B |
| 6. The only Risks heading is inside a fenced block | as 5A: headings are read outside fenced text only | as 1B |
| 7. Both `## Risks` and `### Risks` present | `R` / 0 / spawn both lanes; presence is all that is read | as 1B |
| 8. No grounding: no `--blast-radius`, and no or empty `## Blast Radius` section | refused with the tool's own message, unchanged (`cross-cutting diff (<paths>) without a blast-radius grounding; ...`) / 1 / stop | `plain` / 0 |
| 9. `--blast-radius` names no file | refused with the tool's own message, the `usage()` block / 1 / stop; costs no code | as 9A |

## Contract

**The rule.** One variable, `walk_risk_rule`, holding the sentence above. The Walk bullet becomes a variable in the Spec brief block, with the sentence appended when `$grounding` is non-empty; the base bullet's string does not change, so today's word-for-word assertions still hold as substrings.

**Detection.** In the existing `if [ -n "$crossing" ]` block, after the non-empty check on `$grounding`, over the grounding text, with the shared `fenced` awk:

```
awk "$fenced"'{ sub(/\r$/, ""); sub(/[ \t]+$/, "") } /^#{2,3} Risks$/ { found = 1 }
  END { exit !found }'
```

Level 2 or 3, the exact word `Risks`, nothing else on the line, trailing CR and blanks stripped, fenced text skipped. Not found: the refusal above, `rm -rf "$dir"` first, exit 1, like its neighbour. The sentence names no level and no count, so it is one fixed string in the script, in `SKILL.md` and in the test.

**Files.** `spec-review/scripts/review-brief.sh` (variable, detection, refusal, header comment). `spec-review/SKILL.md` through `patches/mattpocock/spec-review.SKILL.md.patch`: step 4's Spec Walk bullet carries the sentence word for word; step 1's blast paragraph carries the Risks requirement and the refusal. `poteto-mode/playbooks/opening-a-pr.md` through its patch: the `## Blast Radius` bullet says the file's `## ` headings are demoted to `###` when pasted, because an undemoted `## Risks` ends the section (row 4). `poteto-mode/playbooks/ticket.md` step 5: each hand-back part under a `## ` heading, `## Risks` holding one numbered risk per line, and "verbatim" becomes "that file with its `## ` headings demoted to `###`". `SOURCES.md` items 3 and 6, a sentence each. `blast-radius/SKILL.md` is vendored and untouched; `review-comment.sh` is unchanged.

**Tests**, one per cell, in `tests/spec-review/review-brief.sh`, written before the implementation.

- 1A, 1B: a new `blast-risks.md`, today's `blast.md` text plus `## Risks` and one numbered risk. 1A reuses the `$hooks/x.sh` commit: `has "$spec" "$walk_risk_rule"`, `lacks "$std" ...`, stdout as printed today. 1B reuses the README-only commit and today's `printed err.txt`, plus `lacks "$spec" ...`.
- 2A: the same file with `### Risks`. 7A: `blast-both.md`, both levels; `R`, exit 0.
- 3A: today's `pr-body.md` (CRLF, the fenced `## ` line) gains `### Risks`; its existing assertions stand.
- 4A: a new `pr-body-undemoted.md`, that body with `## Risks`; refusal, no state, the message naming the PR body.
- 5A: today's `blast.md` unchanged, now asserting the refusal and that neither brief was written. 6A: `blast-fenced.md`, a `## Risks` line inside a fence; same refusal.
- 8A, 8B, 9: today's assertions, unchanged. The `SKILL.md` block gains `has "$source_skill/SKILL.md" "$walk_risk_rule"`.
- Criterion 3 is a regression check in `tests/spec-review/review-comment.sh`: its two-line-Walk spec-report fixture gains two risk lines and still yields `hard findings: 1`.

## Rationale

The failure is a reviewer that reads the risks and walks none of them, so the fix belongs where the walk is specified, in the one bullet the Spec reviewer follows. Appending to that bullet keeps one rule in one place; a separate paragraph would read as optional beside a numbered report shape.

The refusal in rows 4, 5 and 6 is the detection's whole purpose. A rule with no heading to point at gives the reviewer a step it cannot take and a walk nobody can check, a silent wrong result the brief's own definition calls a hard finding; dropping the rule instead is the failure this ticket exists to close. Refusing costs one message and no state, and row 4 catches the undemoted paste criterion 4's prose exists to prevent.

Rejected: naming the risk count (a second parse that can disagree with the pasted grounding, a variable string to pin in three places, and nothing counts walk lines); restricting level 2 to files and level 3 to bodies (two rules where one holds, and it refuses a grounding copied from a PR); a check in `review-comment.sh` (criterion 6 keeps it unchanged).

## Open

- Numbering. Default: the risk lines continue the walk's numbering; the bullet already says the walk is numbered 1..K on its own.
- `## Risks (confirmed)`. Default: refused; the heading text is exactly `Risks`, and the refusal names the form to use.
- `blast-radius/SKILL.md` still hands back bullets, not headings, and is vendored. Default: no patch on it; `ticket.md` step 5 carries the heading shape, and a drift becomes a ticket.
- `docs/M0-findings.md`. Default: no line; nothing here is a tool-version fact.
