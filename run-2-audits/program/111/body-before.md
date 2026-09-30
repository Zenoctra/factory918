## What to build

> agent (post-mortem, 2026-09-22): "two trails with invented timestamps"

> agent (delegates.md): "this owner's trail carries timestamps it made up (it wrote "17:45:00Z" at 17:25 and "19:35:00Z" at 17:46); the minutes below come from the transcript."

Facts the lane starts from. The show-me-your-work skill (`template/.agents/skills/show-me-your-work/`, vendored; changes go through `patches/`) keeps a `decisions.tsv` with a `ts` column; its `scripts/log.sh` exists but lanes wrote rows by hand. Ticket #91's and #93's trails carried placeholder and out-of-order timestamps, which broke the post-mortem's per-phase timing (`.scratch/program/postmortem/timeline.md`).

## Acceptance criteria

- [ ] The skill says a row is appended only through `scripts/log.sh`, which stamps `ts` from `date -u`, and a lane never types a timestamp; the patch, `series` and `SOURCES.md` carry it.
- [ ] A trail whose rows are out of order or carry a timestamp outside the lane's run is refused by the trail review with a line naming the rows.
- [ ] `docs/agents/evidence.md` or the skill names the trail as the timing record the post-mortem tooling reads.

## Blocked by

None.

