# Fix 6 report, ticket #109 (PR #135)

The fix lane made eco keep `interrogate` in fresh context and took the expected count out of the trail review's brief. The branch has three local commits and nothing was pushed.

Branch: `wt/109-fix6`, from `origin/feat/eco-tier` at dfdf587. Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a0ebaf08c1521bbf3`.

```
e9b70cc Regenerate the template manual from the core manual.
0a277f2 Say in the manual that eco keeps interrogate's reviewers fresh.
1cfb14b Keep interrogate fresh in eco, and give the trail review no expected list to compare against.
```

The brief asked for two commits. The third happened because commit 0a277f2 staged only `docs/`. That left out the regenerated `template/docs/factory918/MANUAL.md`, and I added it as a new commit rather than rewrite 0a277f2. Squash 0a277f2 and e9b70cc if you want two.

## Changed sentences

1a. `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 0, the override list in the lead-in.
- Before: `(Feature steps 4, 5 and 7, the `how` fan-out, `spec-review`'s fix lane, Opening a PR's `interrogate`)`
- After: `(Feature steps 4 and 5, the `how` fan-out, `spec-review`'s fix lane)`

1b. Same file, item 2, closing sentence.
- Before: "Feature step 4 briefs one writer, never an arena; you skip `interrogate` wherever a step launches it (Feature step 7, Opening a PR's subagent line, review-ladder rung 3), and the judge stands in."
- After: "Feature step 4 briefs one writer, never an arena."

1c. Same file, the closing paragraph.
- Before: "In both tiers the writer, `blast-radius`, both reviewers every round, the architect judge and the trail review are fresh lanes, and step 6's table-first, tests-first order is unchanged. So an eco ticket launches at most one writer, one blast-radius lane, one runner and one judge per architect round (a Design hole restart runs another), two reviewers per round and one trail review, and logs each launch as a trail row, and its brief to the trail review asks for that count against this list."
- After: "In both tiers the writer, `blast-radius`, both reviewers every round, the architect judge, `interrogate`'s reviewers when a step launches it, and the trail review are fresh lanes, and step 6's table-first, tests-first order is unchanged. Log each lane you launch as a trail row. The trail review's brief asks it to list every lane launch it finds in the trail and the transcripts, and gives it no list, ceiling or count to compare against; you compare its list with this tier's rule in your hand-back, after it reports."

2. `template/docs/agents/review-ladder.md` rung 3.
- Before: "... Multi-tier review on this account's models. Not run in `eco` (Ticket step 0, "The tier")."
- After: "... Multi-tier review on this account's models." This matches `origin/main` byte for byte, with no trailing space. `git diff origin/main` on the file now shows only the rung 1 clause.

3a. `docs/knowledge/core/MANUAL.md` ladder item 6.
- Before: "... It is the expensive rung, so it is conditional. Not run in `eco` (Ticket step 0, "The tier")."
- After: "... It is the expensive rung, so it is conditional." This matches `origin/main`.

3b. Same file, **Safe and eco.** paragraph.
- Before: "(blast radius, both reviewers every round, the architect judge, the trail review)"
- After: "(blast radius, both reviewers every round, the architect judge, `interrogate`'s reviewers, the trail review)"

3c. `python3 tools/build_knowledge.py` regenerated `template/docs/factory918/MANUAL.md`, committed in e9b70cc.

## Checks

- `bash .github/shellcheck.sh ... 'tests/*/*/*.sh'`: exit 0, "ShellCheck 0.11.0, files checked: 26".
- `bash tests/hooks/delegation.sh`: exit 0, "ok 76 assertions".
- `./factory918.sh sync`: exit 0, status empty after e9b70cc.
- `python3 tools/build_knowledge.py`: exit 0, status empty.
- `python3 tools/check_knowledge.py`: "knowledge ok: 119 files".
- `git diff origin/main -- template/docs/agents/review-ladder.md`: only the rung 1 line changes, adding "(in `eco` its two reviewers are the fresh context, Ticket step 0)".

## Act on

1. `docs/knowledge/core/DECISIONS.md` P109 still says eco runs "(no writer arena, no `interrogate`)". The brief forbids edits to DECISIONS.md, so I left it. It now contradicts the playbook and must change to drop "no `interrogate`" (the regenerated `template/docs/factory918/DECISIONS.md` follows).
2. `docs/knowledge/core/MANUAL.md` line 147, "The tier ... decides how many of these roles a ticket launches". This is about which roles run, not an expected answer handed to a judging lane, so I left it. Its "how many" wording is close to a count, so reword it if you read it differently.
3. As briefed, I left the `architect/SKILL.md` one-runner sentence ("return its findings, not a base; the findings stand in for the second candidate") and its patch unchanged. I touched no vendored file, so no patch changed.
4. Item 4's search found no other place in the branch diff that skips or limits `interrogate` in eco, or that gives a reviewer, judge, trail review or blast-radius lane an expected list, cap or count.
