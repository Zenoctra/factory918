## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Blast-radius hand-back shape not updated to match.** `ticket.md` now tells the lane to write the blast-radius hand-back "each part under a `## ` heading and one numbered risk per line under `## Risks`", and `review-brief.sh` refuses any grounding lacking an unfenced `## Risks`/`### Risks` line. But `template/.agents/skills/blast-radius/SKILL.md` ("What to hand back") still specifies the old bullet shape, with no `## ` headings at all:

```
- **What it does.** What changed, including the part that isn't obvious.
- **Risks.** Only the real ones. Each names how it breaks, the `file:line`, how likely and how bad, and how to check. Paste the proof for the ones that matter.
```

against the new `ticket.md` line:

```
after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape (...), each part under a `## ` heading and one numbered risk per line under `## Risks`
```

A lane that follows `blast-radius/SKILL.md` literally produces the old bullet form, which `review-brief.sh`'s new check then refuses for having no `## Risks` heading. This is Divergent Change: the hand-back's shape is now specified in two places (`ticket.md` and `blast-radius/SKILL.md`) and only one was updated in this change. Fixing it means updating `blast-radius/SKILL.md`'s "What to hand back" section to the heading shape, or reverting `ticket.md` to describe the bullet shape the skill still emits.

hard findings: 0
