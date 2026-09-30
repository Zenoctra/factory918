Both reviewers found nothing that breaks in normal use, and the six items to act on are wording and one missing path: after the human answers an Ask item, the comment script must be rerunnable without paying for two new reviewer lanes. Reviewed commit 41104d7; this is the first review run on the shape this PR introduces, with the orchestrator judging every finding below.

## Standards

## Would break

## Standards breaches

1. **The doctor still sends the user to step 5 to clear the review state.** The change renumbers Aggregate to step 6, but `factory918.sh:268` keeps the old fix string. CODING_STANDARDS "Every doctor check carries its fix as the third argument" — the fix is there but now names the Judge step, which writes `judgment.md` and clears nothing. The command it names is still right, so nothing breaks; the sentence is false.

```
    note "a review state is left behind: .claude/state/review (...)" "finish the review (spec-review step 5 runs review-comment.sh, which clears it) or rm -rf .claude/state/review"
```

2. **Two new CI gates, no line in AGENTS.md "Verifying".** The workflow gains two steps; the list a contributor runs locally still names only `tests/hooks/delegation.sh`, so the documented verification is no longer what CI runs.

```yaml
+      - name: review-comment.sh prints and refuses what the test says
+        run: bash tests/spec-review/review-comment.sh
+      - name: review-brief.sh writes the report shape into both briefs
+        run: bash tests/spec-review/review-brief.sh
```

## Fix alongside

3. **Mysterious Name: `spec` is both the has-a-Spec-axis flag and the summary prose.** `[ -n "$spec" ]` decides whether to print the Spec report; the same variable is the sentence printed in the summary. The counts it formats are already in `p_wb`/`p_total`, so a plain `has_spec` would read straight.

```sh
+  spec="$p_wb would break of $p_total"
...
 if [ -n "$spec" ]; then cat "$dir/spec-report.md"; else echo "no spec: Standards axis only"; fi
```

4. **Duplicated Code: the definition sentence and the count rule are written out four times** — `review-brief.sh`, `SKILL.md` step 4, the patch, and `tests/spec-review/review-brief.sh`. The test pins the script to `SKILL.md`, which is the mitigation; the fourth copy inside the test is the one that drifts silently.

```sh
+definition="A hard finding is wrong behavior in normal use: ..."
+count_rule='End the report with exactly one line `hard findings: N`, ...'
```

5. **The two new tests land non-executable (100644).** `tests/hooks/delegation.sh` and both skill scripts are 100755. CI invokes them as `bash <path>`, so this costs nothing today; it breaks the moment someone runs `./tests/spec-review/review-comment.sh` the way AGENTS.md writes the other test.

```
100755 tests/hooks/delegation.sh
100644 tests/spec-review/review-brief.sh
100644 tests/spec-review/review-comment.sh
```

hard findings: 0

## Spec

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

## Judgment

## Act on

1. [S1] **The doctor's fix string names step 5.** A documented sentence that is now false; one word in `factory918.sh`.
2. [S2] **AGENTS.md "Verifying" lacks the two new tests.** The list a contributor runs must match CI; two lines.
3. [P1] **An Ask item has no path back to zero without a new round.** Counting it is right (readiness waits for the human), but after the human answers, `review-comment.sh` must be rerunnable on the same reports with the re-sorted judgment, without two new reviewer lanes; the script takes the review dir as an argument when the state is gone, and step 5 says the answered item moves bucket citing the answer.
4. [P2] **Fix-alongside has no home in the judgment.** One sentence in step 5: a Fix-alongside item goes to Act on when an Act on fix touches the same code, otherwise Noted; that is the criterion's conditional half.
5. [P3] **"Cheaper than the writer's lane" is false in the opus preset.** Reword models.md to "no dearer than the writer's lane"; the row's reason is context over model, not price.
6. [S3] **`spec` is a flag and a sentence.** Fixed alongside P1, which touches that script; rename to `has_spec` and format the summary from the counts.

## Ask

## Consider

1. [S5] **Tests land non-executable.** CI and AGENTS.md both invoke them with `bash`; a `chmod +x` is free and can ride the same fix commit, but nothing breaks today.
2. [P4] **An off-shape report costs a round.** The P1 fix makes the script rerunnable; step 6 should also say an off-shape report goes back to its reviewer with the refusal text rather than starting a round. Same change, so it rides with P1.

## Noted

1. [S4] **The definition sentence exists in four copies.** The test pins the script to SKILL.md, and the patch copy is generated by sync; the test's own copy is the one that would drift, and it is the mitigation.
2. [P5] **Four criteria are not in this diff.** The ticket says one concern per PR; PRs B and C carry them.

## Dismissed

1. [P6] **Shape and reference validation exceed the ticket's words.** They are what makes "sorts every finding" and a visible Dismissed list checkable; without them a typo drops items from the count silently, which is the hole the ticket closes.

Standards: 0 would break of 5; Spec: 2 would break of 6; judged: act on 6, ask 0, consider 2, noted 2, dismissed 1; fixed point main.
act-on items: 6
