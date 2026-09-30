# Fix brief 6, ticket #109: eco keeps interrogate; the trail review gets no expected list

Repository Zenoctra/factory918. Read AGENTS.md first. In your own worktree run `git fetch origin`, then create
branch `wt/109-fix6` from `origin/feat/eco-tier` (head dfdf587, PR #135). New commits only; never rewrite; push
nothing; launch no agents. Do not touch DECISIONS.md, the ledger, the hook, `tests/hooks/delegation.sh`,
`review-brief.sh` or its test, or any upstream pstack wording.

Manuel, 2026-09-23: "This sounds EXACTLY like prioritizing the verification step pass over the philosophy of the
feature/factory itself. And like prioritizing a predicted result of a feature over the actually designed feature
itself." And: "Tail review is probably a 'No expected list' desire as well." The ruling: `interrogate` reads
someone else's work, so it stays fresh in both tiers; eco no longer skips it. The drops of the `why` investigators
and the writer arena stay. A judging lane's brief carries no expected list, ceiling or count.

## Edits

1. `template/.agents/skills/poteto-mode/playbooks/ticket.md`, step 0 "The tier":
   a. The lead-in's override list "(Feature steps 4, 5 and 7, the `how` fan-out, `spec-review`'s fix lane, Opening a
      PR's `interrogate`)" becomes "(Feature steps 4 and 5, the `how` fan-out, `spec-review`'s fix lane)". Read the
      current text first and keep its exact form apart from this.
   b. Item 2: delete the clause that skips `interrogate` ("; you skip `interrogate` wherever a step launches it
      (Feature step 7, Opening a PR's subagent line, review-ladder rung 3), and the judge stands in"), so the
      sentence ends "Feature step 4 briefs one writer, never an arena."
   c. The closing paragraph (line 17) becomes, in substance:
      "In both tiers the writer, `blast-radius`, both reviewers every round, the architect judge, `interrogate`'s
      reviewers when a step launches it, and the trail review are fresh lanes, and step 6's table-first, tests-first
      order is unchanged. Log each lane you launch as a trail row. The trail review's brief asks it to list every
      lane launch it finds in the trail and the transcripts, and gives it no list, ceiling or count to compare
      against; you compare its list with this tier's rule in your hand-back, after it reports."
2. `template/docs/agents/review-ladder.md` rung 3: remove the added sentence "Not run in `eco` (Ticket step 0, "The
   tier")." so the line reads exactly as on `origin/main` (check with `git diff origin/main -- <file>`; any trailing
   space you leave behind must go too).
3. `docs/knowledge/core/MANUAL.md`:
   a. Ladder item 6 (Rung 3): remove the added "Not run in `eco` (Ticket step 0, "The tier")." so the line reads as
      on `origin/main`.
   b. The **Safe and eco.** paragraph: the parenthesis "(blast radius, both reviewers every round, the architect
      judge, the trail review)" becomes "(blast radius, both reviewers every round, the architect judge,
      `interrogate`'s reviewers, the trail review)".
   c. `python3 tools/build_knowledge.py`; commit what it regenerates.
4. Search the whole branch diff against `origin/main` (`git diff origin/main -- . ':!research'`) for any other place
   this PR skips or limits `interrogate` in eco, or hands a judging lane (a reviewer, judge, trail review, blast
   radius, interrogate) an expected answer, list, cap or count; fix any in the same spirit and report each. Leave
   the `architect/SKILL.md` one-runner sentence as it is (it says "findings", no expectation). If you touch a
   vendored file, regenerate its patch with the `diff -u --label` form against `research/`.

Commits: one for items 1 to 2 and 4's playbook edits, one for item 3; plain-sentence messages ending with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Run /unslop over the lines you add.

Checks, each with its outcome: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`,
`bash tests/hooks/delegation.sh`, `./factory918.sh sync` then status empty, `python3 tools/build_knowledge.py` then
status empty, `python3 tools/check_knowledge.py`, and `git diff origin/main -- template/docs/agents/review-ladder.md`
showing only the rung 1 clause. Write your report with Bash to exactly
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/fix6/report.md`: the
branch, `git log --oneline origin/feat/eco-tier..HEAD`, each changed sentence (before and after), each check's
outcome, and an act-on list of anything you found under item 4 or could not do as written. Reply with only the path.
