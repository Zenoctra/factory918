## Would break

1. **`## Ask` is counted, and no consumer of the count can clear it.** `review-comment.sh` prints `act-on items: $((act + ask))`, and SKILL.md step 5 says of an Ask item "You never dismiss one of these; it waits for the human." The two readers of that line were not updated: `template/.agents/skills/poteto-mode/playbooks/babysit.md` step 16 says "A nonzero count, or no review comment on the latest commit, is a blocker of the same class as a red check, and the fix lands on this PR", and `docs/agents/review-ladder.md` rung 1 says "Act-on items get fixed". A single security, privacy, auth, data or cross-system finding therefore pins `act-on items` above zero with nothing the agent may do about it, so babysit can never reach merge-ready and re-runs the round. The ticket asked only that such a finding "cannot be dismissed by the agent; it is asked" — not that it be added to the count babysit gates on.

2. **The fix-alongside rule has no bucket in the judgment.** The ticket: "Smells go under `## Fix alongside`, are not counted, and are fixed only when a would-break fix already touches that code." The briefs place them there, but step 5's five headings offer only Act on (counted), Ask, Consider, Noted ("valid but not actionable here") or Dismissed. The script's own fixture files the smell as `1. [S3] **Duplicated Code.** Fixed alongside S1 if the loops are touched.` under `## Noted` — the heading that means it will not be fixed. The conditional-fix half of the criterion survives only as a reviewer's free-text reason.

## Latent

3. **"Cheaper than the writer's lane" is untrue in the `opus` preset.** `template/docs/agents/models.md` justifies the new row "so it runs cheaper than the writer's lane", but `machine/pstack-models.opus.md` sets both `feature, refactoring` and `spec reviewer` to `claude:opus@high`.

4. **An off-shape report costs a whole round.** `shape` refuses any extra `## ` heading (a `## Summary`, or an unfenced blockquote line beginning `## `). SKILL.md step 6 lists the refusal but gives no re-run path for a report already paid for.

5. **Four criteria are absent here.** Blast-radius grounding, carry-forward, the author's ticket comments, the round cap and the ledger line are not in this diff; consistent with "likely a stack of PRs, one concern each", noted so the rest stays tracked.

## Not asked for

6. **Heading-shape and reference validation.** The ticket asked only that the script "exits 1 when a report's `hard findings:` line exceeds the number of items under `## Would break`". The exact-heading check and the `[S<n>]`/`[P<n>]` completeness check are additions; they enable the count but widen the refusal surface.

hard findings: 2
