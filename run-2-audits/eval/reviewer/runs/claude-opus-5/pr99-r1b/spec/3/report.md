## Walk

1. `review-brief.sh` fetches the PR author's comments carrying `act-on items:` into `bodies` (the jq filter is unchanged, so a hand-written `restart` with no count line is still never fetched: table A row 12).
2. The new awk between the fetch and the round derivation records every line that is exactly `restart` outside fenced text, prints the number of comments cut, then the comments after the last such one; `cut`/`bodies` split that output and set `restarted`.
3. `[ -z "$restarted" ] || echo "restart: the round and the settled items count from the last restart comment"` prints after `ticket:` and before `round:`, including under `--round N`.
4. `top`, the three-round refusal and the `settled:` derivation all read the sliced `bodies`, so a restart gives round 1, no `settled:` line, no settled section, and a refusal counting only the new series (rows 5-8, 13).
5. A shared `ref=` line (`table <row>/<column>`, `design <signature>`, `criterion <k>`) is added to both scripts; `cites:` gains the `#N <ref>` alternative (rows 14-17), held identical by `fragment()`.
6. `spec_rule` is echoed one blank line after `step_rule`: guarded by `[ -n "$spec" ]` in the Standards brief, unconditional in the Spec brief, before the report-path and count lines.
7. `review-comment.sh` sets `has_spec` from `spec-brief.md`; `report()` runs the parameterised `stepless` twice, the step refusal first, the `spec:` refusal only with a spec (table B rows 2-4, 7A).
8. `holed()` takes judgment items whose line does not end in a `fixed:`/`ticket:` field and carries `hole:`; refusals fire in order: no-spec, outside Act on, no form, not word for word the judged item's `spec:` (rows 1D-1G, 5D-5G, 7D).
9. `holes` is subtracted beside `fixed_here` and `ticketed` (the three sets are disjoint, so the count cannot go negative), and `restart` prints after the summary, before `round:`.
10. Prose lands in `SKILL.md` steps 1/4/5/6, review-ladder rung 1, the Ticket playbook's step 8 pointer and `### Design hole`, the two byte-identical babysit sentences, `SOURCES.md` items 4/6/12, and the `no-stale-wording.sh` blacklist.

## Would break

## Fails open

## Not asked for

hard findings: 0
