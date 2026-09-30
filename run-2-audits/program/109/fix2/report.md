# Fix 2 report, ticket #109, PR #135

Branch `wt/109-fix2`, created from `origin/feat/eco-tier` at 148aa8a, in worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-ada450082b2c4f784`. Nothing pushed; no agents launched.

## Commits (log --oneline origin/feat/eco-tier..HEAD)

```
6430d6b Name eco's architect, arena and interrogate savings under the models table, and cut the manual's eco paragraph to what a person decides.
d14029f Skip interrogate in eco wherever a step launches it, not only at Feature step 7.
```

- d14029f (item 1): `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 0 item 2 and the override list, `template/docs/agents/review-ladder.md` rung 3, `docs/knowledge/core/MANUAL.md` ladder item 6, plus regenerated `template/docs/factory918/MANUAL.md`.
- 6430d6b (items 2 and 3): `docs/knowledge/core/MANUAL.md` models-table sentence and the **Safe and eco.** paragraph, plus regenerated `template/docs/factory918/MANUAL.md`.

All text is the brief's wording verbatim.

## Checks

- `bash tests/hooks/delegation.sh`: exit 0, "ok 76 assertions".
- `./factory918.sh sync`: exit 0, status clean after.
- `python3 tools/build_knowledge.py`: exit 0, status clean after.
- `python3 tools/check_knowledge.py`: "knowledge ok: 119 files".

## Act on

1. Unslop pass: I kept the brief's text verbatim, but two sentences use a colon as a mid-sentence connector (unslop rule 14). They are "The delegation hook guards the session you type into the same way in both tiers: in a ticket you run yourself, a small fix still goes to a fix lane." and the older "`safe` is the fallback: when a model struggles...". The models-table colon introduces a list and is fine. If you want them changed, a period works, for example "...in both tiers. In a ticket you run yourself, a small fix still goes to a fix lane."
2. There is no root copy of `review-ladder.md` under `docs/agents/`, so only the template copy changed.
