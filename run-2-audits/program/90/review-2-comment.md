Round one again, after the restart: the Spec axis walks all seven criteria and finds nothing; the Standards axis finds one hard item, that the MANUAL's merge checklist still reads `act-on items: 0` alone and so would call a mid-restart PR ready, two rows of `DECISIONS.md` (P20, P21) no longer true at this commit, and a refusal that shows a space the input lacked. None changes a cell of the ticket's tables, so all four are fixed on this PR next: the three prose items in the records commit (the MANUAL clause with its generated copy rebuilt, a Provisional row for the design hole with P20 and P21 amended inline) and the message with one assertion.

## Standards

## Would break

1. **The human's merge gate still reads only `act-on items: 0`.** Babysit, its playbook and the review ladder all gained the "a `restart` comment is not merge-ready whatever its count" clause. `docs/knowledge/core/MANUAL.md`, the loop the human follows at the merge, did not. A one-hole round prints `restart` and then `act-on items: 0`, which the diff's own test asserts, so every condition on that checklist passes while the design hole is open.
Documented step: `docs/knowledge/core/MANUAL.md:103`, "It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`; ... If any of those is missing, say 'fix that and come back'."
Result: the agent answers "ready" and the human merges a PR mid-restart, the case criterion 4 exists to prevent.
spec: criterion 4

```
+act-on items: 0" "two holes print one restart line and both are left out"
```

## Fails open

## Standards breaches

2. **`DECISIONS.md` P20 is no longer true at this commit.** Its title is "Three review rounds at most" and its body says `review-brief.sh` "refuses a fourth round" and that "`act-on items: 0` with `round: 3 of 3` makes the PR review-ready". After this change a restart resets the count, so one PR can get three rounds, a restart, then three more, and a `round: 3 of 3` comment carrying `restart` is not review-ready. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it."

```
+# exactly `restart` (a design hole returned to architect) ends the history: the round and the
+# settled items are read from the comments after the last such comment, and a `restart:` line says
```

3. **`DECISIONS.md` P21 still lists three `cites:` forms.** The diff adds a fourth, `#N <reference>`, to `review-brief.sh` and to `SKILL.md` step 5. P21 reads "Only a Noted or Dismissed judgment item ending in `cites: user: "..." on #N`, `cites: DECISIONS.md <row>` or `cites: #N comment <date>` is pasted into the next briefs". Same standard as [S2].

```
+cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2}|#[0-9]+ '"$ref"')$'
```

## Fix alongside

4. **The no-form refusal reprints a value that looks well formed.** `holed()` matches the substring `hole:`, but the form check wants `hole: ` and `value()` strips at most one space, so `hole:table 2/D` is refused with a message showing `'hole: table 2/D'`, which does fit a form. Say the space is missing.

```
+value() { local v="${1##*hole:}"; printf '%s' "${v# }"; }
```

hard findings: 1

## Spec

## Walk

1. Criterion 1, the definition: `spec-review/SKILL.md` step 5 gains the design-hole paragraph (three artifacts, intent over criterion, the could-not-run carve-out) and `docs/agents/review-ladder.md` rung 1 gains its one-sentence twin; the patch carries both.
2. Criterion 2, the `spec:` rule: `review-brief.sh` gains `spec_rule`, echoed one blank line after `$step_rule` in both briefs but only inside `if [ -n "$spec" ]`, the same test that writes `spec-brief.md`, so a no-spec Standards brief runs step rule -> report path -> count rule.
3. Criterion 2, the refusal: `review-comment.sh` sets `has_spec` from `$dir/spec-brief.md` before the Standards report is read; `stepless()` now takes the required regex and `report()` calls it twice, step first, `^spec: $ref$` second, and returns early with no spec.
4. Criterion 3, the mark: `holed()` takes judgment item lines not ending in a well-formed `fixed:`/`ticket:` field that contain `hole:`; the checks run no-spec, then placement outside Act on, then form (`hole: $ref$`), then word-for-word equality with `specs()`'s value for the named report item. `holes` is subtracted in the count and `echo restart` lands between the summary and `round:`.
5. Criterion 4, the reset: one awk between the `gh` fetch and the round awk keeps only the lines whose comment index exceeds the last comment holding a bare `restart` outside fenced text, prints the cut count, and sets `restarted`; the `restart:` line prints after `ticket:` and before `round:`. `top`, `settled:` and the fourth-round refusal all read the sliced history, so a PR with no restart behaves exactly as before.
6. Criterion 4, the playbooks: `ticket.md` step 8 points at the new `### Design hole` section (six steps, no step renumbered); the babysit sentence is byte-identical in `poteto-mode/playbooks/babysit.md` and `babysit/SKILL.md` after the list prefix, and both patches plus `SOURCES.md` items 4, 6 and 12 match.
7. Criterion 5, the cite: a fourth alternative `#[0-9]+ $ref` joins the `cites:` group, still `$`-anchored; `fragment()` now holds the `ref=` line of both scripts together.
8. Criterion 6, the tests: table A rows 5 to 8, 11 to 17 and the `--round 4` refusal; table B rows 1 (A to G), 2, 3, 4, 5 (A, D, E, F, G), 6, 7 and the three notes; `no-stale-wording.sh` blacklists `Three trailing fields`, which survives nowhere under `template/` or `docs/knowledge/core/`.
9. Criterion 7: table B columns A to C print exactly as today, and `holed()`'s exclusion keeps `holes` disjoint from `fixed_here` and `ticketed`, so the count cannot go negative and a no-hole PR reads as before.

## Would break

## Fails open

## Not asked for

hard findings: 0

## Judgment

## Act on

1. [S1] **The MANUAL's merge checklist reads the count alone.** Real, and criterion 4's intent covers the human's read as much as babysit's; no cell changes, so it is fixed on this PR: `MANUAL.md:103` gains the clause that the comment carries no `restart` line, with the generated copy rebuilt.
2. [S2] **P20 is no longer true at this commit.** Real breach of "true at the commit that lands it"; fixed on this PR with an inline amendment on P20 and a Provisional row for the design hole, in the same records commit.
3. [S3] **P21 still lists three `cites:` forms.** Real; the same records commit amends P21 inline with the fourth form and the restart rule.
4. [S4] **The no-form refusal inserts a space the input lacked.** Real: a refusal must show the input as written so the correction is visible; fixed on this PR by showing the raw text after the field's name, with one assertion for a mark written without the space.

## Ask

## Consider

## Noted

## Dismissed

Standards: 1 would break, 0 fail open, of 4; Spec: 0 would break, 0 fail open, of 0; judged: act on 4 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point 69bd412.
round: 1 of 3
act-on items: 4

Claude Fable 5.1 on Claude Code
