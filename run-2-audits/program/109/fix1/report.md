# Fix 1 report, ticket #109

The branch is `wt/109-fix1`, five commits on top of `wt/109-writer`, in worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aad7822ef789e1e17`.
Nothing was pushed and no agents were launched. The writer's commits are unchanged.

## Commits (`git log --oneline wt/109-writer..HEAD`)

```
6247aa0 Cut a colon connector and two passive clauses from the tier text, and scope the manual's dropped-lanes line to Autopilot-stack.
1d7ef50 Say in both AGENTS files and the review ladder what eco changes about delegation and the fresh review.
daf9fe8 Make the manual's eco list conditional where the hook makes it so, and name eco's reviewers as rung 1's fresh context.
c46f8cf Exempt a one-runner tier from architect's two-candidate rule and have its judge return defects, not a base.
3b03eb2 Read the tier in two plain commands and let each eco item override the steps it names.
```

## Edits

- Edit 1, all of 1a to 1e: `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, so no patch). Commit 3b03eb2.
- Edit 2, 2a to 2c: `template/.agents/skills/architect/SKILL.md`, with `patches/pstack/architect/SKILL.md.patch` regenerated through `diff -u --label` against `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md`. SOURCES.md item 14 now names both changes. Commit c46f8cf. The 2a clause goes at the end of the sentence ("..., even when the first looks sufficient, unless the caller's tier asks for one runner (below).") because the other placement read badly.
- Edit 3: the MANUAL paragraph is verbatim from the brief. The Rung 1 clause is added. `build_knowledge.py` regenerated `template/docs/factory918/MANUAL.md`. Commit daf9fe8.
- Edits 4 to 6: `template/AGENTS.md` lines 37 and 79, `template/docs/agents/review-ladder.md` line 6, and `AGENTS.md` line 26. Commit 1d7ef50.
- Cleanup commit 6247aa0 comes from the deslop and unslop pass. Deslop found nothing in `tests/hooks/delegation.sh`. Unslop made three changes in ticket.md: it cut the colon connector in my own 1a sentence ("never nested in one line, because ..."), made item 2's "`interrogate` is not run" active, and reworded step 8's eco clause ("you run `spec-review` yourself, with no review lane"). It also fixed MANUAL line 147 (see the act-on list).

## Checks

- `bash .github/shellcheck.sh ...` (the brief's 20-file set) passes. ShellCheck 0.11.0 checked 24 files.
- `bash tests/hooks/delegation.sh` passes with 76 assertions.
- `bash tests/poteto-mode/overlap.sh` passes with 57 assertions.
- `./factory918.sh sync` leaves `git status` clean.
- `python3 tools/build_knowledge.py` leaves `git status` clean.
- `python3 tools/check_knowledge.py` passes with 119 files.

## Act on

1. MANUAL line 147, the "Models and cost" section, was outside the brief. It said "`eco` drops the explorer, explainer, review wrapper, fix and records lanes", unconditionally. That contradicted the corrected Safe and eco paragraph, because in a ticket run directly the hook still sends fixes to a fix lane. Commit 6247aa0 rewrites it to "`eco` drops the explorer, explainer and review wrapper lanes, and under Autopilot-stack the fix and records lanes." Keep it or drop it at review.
2. Edit 5 cites "line 6" of `template/docs/agents/review-ladder.md`, and the clause went there. This repository has no copy of that file under `docs/agents/`, so nothing needed copying.
3. The 1e closing sentence is two "and" clauses chained on one subject ("..., and logs each launch as a trail row, and its brief to the trail review asks ..."). I kept the brief's wording. A reviewer may want it split.
