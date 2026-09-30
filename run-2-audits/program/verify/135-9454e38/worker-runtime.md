verdict: PASS+NOTES

# Live runtime floor, PR #135 (ticket #109) at 9454e3849fadd5e69c9414b5a555fa316a6b5870

Setup confirmed: `git rev-parse HEAD` = `9454e3849fadd5e69c9414b5a555fa316a6b5870`; `git merge-base --is-ancestor a9ebdac HEAD` exit 0.
Diff read: `git diff a9ebdac..9454e38` (16 files, +81/-35).

## (a) Safe is today

The rule, `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`:

> A ticket runs `eco` when the main checkout's tier file holds exactly `eco` (trailing newlines aside) as its digest is
> written, and `safe` otherwise. [...] A file holding anything but `eco` or `safe` reads `safe`, and the digest names the
> value it did not read. A read that fails is `safe` too, and the digest says it failed. `safe` is every step as written.

Mechanically walked in a fixture main checkout with the contract's predicate (`[ "$(cat "$f" 2>/dev/null)" = eco ]`,
ticket #109 Contract):

| file state | `cat` rc | value read | tier |
|---|---|---|---|
| no file | 1 | (read failed) | safe, digest says it failed |
| empty | 0 | `` | safe, digest names the value |
| `ECO\n` | 0 | `ECO` | safe, digest names `ECO` |
| ` eco\n` | 0 | ` eco` | safe (the rule excuses trailing newlines only, not a leading space) |
| `eco\n\n` | 0 | `eco` | **eco** |
| `safe\n` | 0 | `safe` | safe, silently (the rule names `safe` as a recognised value) |

All six match the rule as written. The live main checkout has `.claude/state/` with no `tier` file (it holds `mode`,
`program`, `todo-program.md`, `todo-run2.md`), so the factory is `safe` today.

Every added sentence in the text a safe owner reads is guarded by `eco`. Checked one by one against a9ebdac:

- `ticket.md` step 5 `+In eco you read them yourself`; step 6 `+In eco the architect step is one runner and an adversarial
  judge (step 0, the tier); the table comes first in both tiers` (the second clause restates step 6's existing
  "`architect`'s first deliverable is the scenario table"); step 8 `+in eco you run spec-review yourself, with no review
  lane`; Reply `+In eco it is step 0's one page`.
- `ticket.md` Design hole step 2 is the only reworded safe sentence: `Two runners; the judge is skipped when they
  converge.` becomes `Two runners, the judge skipped when they converge; in eco, one runner and the judge`. Same
  instruction.
- `architect/SKILL.md:36` adds `unless the caller's tier asks for one runner (below)` and a new paragraph opening `A
  caller whose tier asks for one runner`. In safe no tier asks, so "Design it twice" still binds.
- `autopilot-stack.md:3`, `review-ladder.md` rungs 1 and 3, both `AGENTS.md`, `MANUAL.md` rungs 1 and 6: every addition
  is inside an `eco` clause or the new `Safe and eco.` paragraph.

Two real differences a safe agent acts on, both intended and small:

1. It now runs two extra commands (the tier read) at step 0.
2. On a junk tier file the safe digest gains a line naming the value it did not read (table A4). With no file, today's
   state, the digest is unchanged.

No instruction a safe-mode agent follows changed otherwise.

## (b) Eco against Manuel's settled list

Everything Manuel settled is honoured; no lane he kept fresh is dropped. Quoting `ticket.md:10-17`:

- Writer, blast radius, both axes every round, the judge, the trail review, table-first/tests-first, both tiers:
  > In both tiers the writer, `blast-radius`, both reviewers every round, the architect judge and the trail review are
  > fresh lanes, and step 6's table-first, tests-first order is unchanged.

  Right. Step 5's blast-radius paragraph and step 9's trail review are otherwise untouched from a9ebdac.
- Owner does `how`: item 1, `how and why [...] are your own reading; launch no explorer, explainer or investigator lane`.
  Right for `how`; `why` is an extra, see (c).
- Owner does the synthesis: item 2, `to return its defects, which you fix in the synthesis`. Right.
- Owner does the writer's brief: already the owner's job in safe (`feature.md:13`, "Delegate code-writing ... with a
  specific scope"), so nothing moved; item 2 only forecloses the arena. Right.
- Owner does small fixes and the records commit: item 4, `An owner that is a subagent writes its small fixes (a round's
  Act on items, a CI fix, its slice of a rebase) and its records commit itself, proved on the path CI takes (Feature
  step 5). In the root session the delegation hook blocks a lane's file in both tiers, so a ticket run there briefs a fix
  lane as in safe (P109).` Right, and it matches the hook's real behavior (see (e)).
- One-page report: item 5, headings `## Head`, `## Criteria`, `## Review`, `## CI`, `## Flags`, identical to
  `autopilot-stack.md:11` step 7's list. Right.
- Architect one runner plus adversarial judge: item 2 plus `architect/SKILL.md:38`, `keeps the cross-judge and briefs it
  to read that one candidate adversarially against the rubric and the grounding and to return its defects, not a base`.
  Right; the judge is `one judge on another model`, so it is still a fresh adversarial read.
- Reviewers stay two per round and the owner only judges: item 3, `its two reviewers launched by you with their briefs'
  paths and polled per the poll rule, its judgment and its comment. Read no brief and no diff while the review state
  exists; the two reviewers are the fresh context.` Right, and consistent with the hook, which blocks the root
  orchestrator from the code under review (`delegation.sh:76,98`) while allowing the script and the state directory.

The override clause names every step the items contradict (`Feature steps 4, 5 and 7, the how fan-out, spec-review's fix
lane, Opening a PR's interrogate`) and each named step exists: `feature.md:13,14,16`, `opening-a-pr.md:31`,
`spec-review/SKILL.md:134,140`. No orphan pointer, and no uncovered launch point turned up grepping `interrogate`,
`fresh context` and `spec-review` across `template/.agents/skills/` and `template/docs/`.

## (c) The owner's three extra drops

1. `why` investigators. `ticket.md:11` item 1: `how and why, wherever a step runs them (step 5, Feature step 1, Bug
   fix's investigation, architect Phase A), are your own reading; launch no explorer, explainer or investigator lane.`
   Manuel's quotes and criterion 2 name `how` only. Criterion 4's ceiling ("at most the writer, the blast-radius lane,
   the runner and judge, two reviewers per round and the trail review") leaves no room for an investigator lane, so the
   drop is required by it. It is also table C1 on the ticket, posted as the approved artifact.
2. The writer arena. `ticket.md:12` item 2: `Feature step 4 briefs one writer, never an arena.` Criterion 4 allows one
   writer, so an arena of writers (table C3's safe cell) cannot fit. Required. The writer itself stays fresh.
3. `interrogate`. `ticket.md:12` item 2: `you skip interrogate wherever a step launches it (Feature step 7, Opening a
   PR's subagent line, review-ladder rung 3), and the judge stands in`, mirrored at `review-ladder.md:8` (`Not run in
   eco`) and `MANUAL.md:98`. Criterion 4's list has no interrogate reviewers, so required. Worth the human knowing that
   `opening-a-pr.md:31` is unconditional in safe ("A subagent that opens a PR runs `interrogate`"), so this is the one
   drop that removes a mandatory multi-model adversarial rung rather than a conditional one, and that interrogate
   reviewers do read someone else's work, which is P109's own test for keeping a lane fresh. Criterion 4's ceiling
   settles it, and P109 records the architect judge as the stand-in.

## (d) The tier file lookup

From this linked worktree:

    $ git rev-parse --git-common-dir
    /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.git

Fixture with a main checkout holding `eco` and a linked worktree holding `safe` in its own `.claude/state/tier`:

    $ cd /tmp/claude-501/tierfx/wt
    $ d=$(git rev-parse --git-common-dir); echo "$d"; cat "$d/../.claude/state/tier"; cat .claude/state/tier
    /private/tmp/claude-501/tierfx/main/.git
    eco            # the main checkout's word
    safe           # the worktree's own file, ignored

The same read works from the main checkout root (`--git-common-dir` prints `.git`) and from a subdirectory (`../.git`);
both printed `eco`. So an `eco` written inside a worktree does nothing, as the owner accepts.

The rule's stated reason for two plain commands is true of this harness. The nested form is refused:

    $ if [ "$(cat "$(git rev-parse --git-common-dir)/../.claude/state/tier" 2>/dev/null)" = eco ]; then ...
    Refusing to run it - a worktree-isolated agent's git operations must target its own worktree.

The two-command form ran without a prompt.

## (e) The hook

- `template/.claude/hooks/delegation.sh` is byte-identical to a9ebdac: both `a0a20486a43d27e8ea72c576ca3c68320d2f03be`
  (shasum). `git diff --stat a9ebdac..9454e38 -- template/.claude/hooks .claude/hooks` prints nothing.
- The hook reads no tier: grepping `tier` in it returns nothing, and `.claude/state/*` is classed `untracked`
  (`delegation.sh:47`), which is why B5 (writing the tier file) passes under every tier.
- `bash tests/hooks/delegation.sh` exits 0, `ok 76 assertions` (55 before, plus 3 tiers x 7 table-B rows).
- Read the loop at `tests/hooks/delegation.sh:128-142`: it sits after the sub-agent group, with `mode` = `execute` and
  the review state live from line 97, exactly as the ticket's table B says, and it removes the tier file before the
  planning group. The fixture is a `mktemp -d` with a `trap rm -rf`, so it never touches the real checkout.
- Commit order is tests-first: `96901b9 Assert the delegation hook answers the same under every tier file.` is the first
  commit after a9ebdac and touches only `tests/hooks/delegation.sh`.

## (f) Autopilot-stack step 1

`template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md:3`:

> An owner's first action is invoking the poteto-mode skill, then reading the digest (Ticket step 0) its brief carries,
> whose first line is `Tier: eco` when the root's tier file read `eco` as that owner launched, and following that tier
> for its whole run.

Replacement owners, `ticket.md:10`:

> Under Autopilot-stack the root writes it into each owner's brief, and the brief wins over the file, because a run never
> changes tier halfway. [...] A replacement owner for the same ticket takes the tier line of the brief it replaces, never
> the file.

Both facts are stated and reachable: autopilot-stack step 2 is where a replacement is dispatched, and step 1 points that
reader at Ticket step 0 for the digest.

## Issues

None.

## Notes

1. `ticket.md:10` excuses trailing newlines only, so ` eco` with a leading space is `safe`. That is what the rule says
   and what the contract's predicate does, but an owner reading the file by eye could plausibly trim it. If the human
   wants whitespace forgiven, that sentence is the place to say so; as written the strict reading is unambiguous and I
   graded it correct.
2. The instruction that makes the root read the tier file is phrased descriptively in autopilot-stack step 1 ("whose
   first line is `Tier: eco` when the root's tier file read `eco`") rather than as an imperative; the imperative lives in
   Ticket step 0 ("the root writes it into each owner's brief"), which step 1 points at. Reachable, but the root has to
   follow the pointer.
3. `interrogate` is the one dropped lane whose job is reading someone else's work, which is P109's own criterion for
   keeping a lane fresh. Criterion 4's ceiling forces the drop and P109 names the architect judge as the stand-in;
   flagged so the human sees the trade, not because the change is wrong.
4. In safe the digest changes only when the tier file holds a junk value. With no file, today's state, the digest and
   every lane are unchanged.
