# Digest for #111: Stamp trail rows with the clock, never a typed time

Required reading
- Ticket: `gh issue view 111 --repo Zenoctra/factory918` (three criteria; no worked example, no review rounds cited).
- Skill under change: `template/.agents/skills/show-me-your-work/SKILL.md`, `scripts/log.sh`, `references/decision-log-template.tsv` (vendored from open-pstack v1.3.0; research copy under `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/show-me-your-work/`).
- Patch rules: `patches/README.md`, `patches/series`, `SOURCES.md` (next free item: 18 at base f58308b).
- Playbooks: `template/.agents/skills/poteto-mode/playbooks/ticket.md`, `feature.md`, `opening-a-pr.md`, `babysit.md`.
- Post-mortem timing: `.scratch/program/postmortem/timeline.md` (main checkout, untracked).

Facts a run paid for
- A lane's completion notification reaches the root session, never the owner. Poll the exact absolute path the lane was told to write, inside the turn; never end the turn to wait.
- GitHub links `Closes #N` only on a PR based on the default branch; any `closes` word beside a ticket number closes it. Name other tickets without one.
- Actions creates no `pull_request` run for a PR that conflicts with its base.
- `gh issue edit --body-file` replaces the body; read it first and write it back whole.

Owner rules for this lane
- Base `origin/feat/review-reading-pack` (PR #126, head f58308b), branch `feat/trail-clock`, PR draft with `--base feat/review-reading-pack`, never retargeted.
- Lanes: tier-upper / tier-lower only; writers' first line invokes poteto-mode; results copied to `.scratch/program/111/<lane>/`.
- decisions.tsv rows only through `scripts/log.sh`.
- PR body ends `Closes #111`, attribution, `Claude Opus 5.5 on Claude Code`.
- Records: P111.
