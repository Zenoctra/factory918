## Would break

## Fails open

## Standards breaches

1. **Decisions changed, no row amended.** `CODING_STANDARDS.md`, "Commits and pull requests": "a choice to `docs/knowledge/core/DECISIONS.md` under Provisional"; "Markdown": "A count or a version in prose is true at the commit that lands it". P21 still reads "Only a Noted or Dismissed judgment item ending in `cites: user: ...`, `cites: DECISIONS.md <row>` or `cites: #N comment <date>` is pasted into the next briefs", and P20 states the three-round cap with no restart. The diff adds a fourth cite form, the `hole:` field and the restart reset, with no Provisional row and no "amended" clause (P19 shows the form). `docs/knowledge/core/` is source, not generated.

```
+- `cites: <decision>` on a Noted or Dismissed item names the decision it rests on, one of `user: "<quoted words>" on #N` (a `user:` blockquote in the ticket body), `DECISIONS.md <row id>` (`P17`, `19`), `#N comment <YYYY-MM-DD>` (a ticket comment by the ticket's author) or `#N <reference>` (a cell, signature or criterion of the ticket in the `spec:` grammar: ...). Nothing else counts.
```

## Fix alongside

2. **The human's readiness rule does not know `restart`.** Divergent Change: the ladder, both babysits and the Ticket playbook learned that a `restart` comment is not merge-ready whatever its count, but `docs/knowledge/core/MANUAL.md:103` still says a PR is ready when the last line "reads `act-on items: 0`". Two holes print exactly that line under `restart` (the test "two holes print one restart line and both are left out"), so the person's checklist says ready while the agent's says not.

```
+[ "$holes" -eq 0 ] || echo restart
 echo "round: $round of 3"
-echo "act-on items: $((act - fixed_here - ticketed + ask))"
+echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

3. **A pointer that names a step its target does not have.** Mysterious Name, on a context pointer: `architect` Phase B runs `arena`, whose Phase C dispatches the judge after every candidate completes; convergence (arena SKILL.md:62) only drops the graft, and the runner count comes from the model sheet. An agent following this line looks for a skip that no skill defines.

```
+2. Run `architect` Phase B scoped to it, with the judgment item, its report item and the artifact (...) as grounding. Two runners; the judge is skipped when they converge.
```

4. **Prose `hole:` is refused as a field.** Under Ask, Consider, Noted and Dismissed the check is an unanchored `grep 'hole:'`, while the grammar says the field is what ends the line. A Noted reason such as "not a design hole: P3 covers it" is refused, loudly, with a message that calls it a field. Anchor the check like `ending`, or word the refusal for both cases.

```
+holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
+for h in Ask Consider Noted Dismissed; do
+  line="$(holed "$h" | head -1)"
+  [ -z "$line" ] || fail "$dir/judgment.md item '$(title "$line")' carries a 'hole:' field under '## $h'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do"
```

hard findings: 0
