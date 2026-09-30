# Fix brief 1, ticket #109 (before review round one)

Repository Zenoctra/factory918. Read AGENTS.md first. In your own worktree create branch `wt/109-fix1` from the
local branch `wt/109-writer` (4 commits on `origin/main`, the writer's work; read `git log -p origin/main..wt/109-writer`
first). Your commits go on top; never rewrite the writer's commits. Do not touch
`template/.agents/skills/spec-review/scripts/review-brief.sh` or its test, `template/.claude/hooks/delegation.sh`,
`docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md`, `docs/M0-findings.md`.

These fixes settle the blast-radius lane's risks (file:
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/blast/blast-radius.md`,
read it) and one writer flag. Keep each edit to the sentence named; tighten wording per /writing-for-agents but
keep every rule. The ticket's scenario table (`gh issue view 109 --repo Zenoctra/factory918`, `## Testing decisions`)
does not change.

## Edits

1. `template/.agents/skills/poteto-mode/playbooks/ticket.md`, step 0's "The tier" bullet (risk 1, 6, 7, 8, 10, 13):
   a. Replace the nested one-liner read with a two-command read, because a worktree-isolated agent's guard refuses
      `git` nested in `$(...)` inside `[ ]`: the ticket runs `eco` when the main checkout's tier file holds exactly
      `eco` (trailing newlines aside) as its digest is written, `safe` otherwise; read it in two plain commands,
      `git rev-parse --git-common-dir`, then `cat <that dir>/../.claude/state/tier`. Keep the sentences that follow
      (main checkout's file from any worktree; `Tier: eco` first line; the brief wins; a junk value reads `safe` and
      the digest names it).
   b. Add: a replacement owner for the same ticket takes the tier line of the brief it replaces, never the file.
   c. The list's lead-in becomes: "`eco` changes these and nothing else, and each item overrides any playbook or
      skill step that says otherwise (Feature steps 4, 5 and 7, the `how` fan-out, `spec-review`'s fix lane):".
   d. Item 1: `how` and `why` wherever a step runs them (step 5, Feature step 1, Bug fix's investigation,
      `architect` Phase A) are your own reading; launch no explorer, explainer or investigator lane.
   e. The closing paragraph: "...and logs each launch as a trail row, and its brief to the trail review asks for
      that count against this list."
2. `template/.agents/skills/architect/SKILL.md` (vendored; regenerate `patches/pstack/architect/SKILL.md.patch` with
   the `diff -u --label` form in `patches/README.md` against `research/`) (risk 11, writer flag 5):
   a. "Require at least two structurally distinct candidates before synthesis" gains "unless the caller's tier asks
      for one runner (below)" in the same sentence.
   b. The added tier sentence says the judge returns that candidate's defects, not a base: "A caller whose tier asks
      for one runner (Factory918's `eco`, Ticket step 0) keeps the cross-judge and briefs it to read that one
      candidate adversarially against the rubric and the grounding and to return its defects, not a base; the
      defects stand in for the second candidate."
   c. `SOURCES.md` item 14's #109 clause names the two changes.
3. `docs/knowledge/core/MANUAL.md` (risk 3, 5, 9):
   a. Rewrite the **Safe and eco.** paragraph so its list is conditional where the hook makes it so, and the setter
      works in a fresh project:
      "**Safe and eco.** A run has a tier. `safe`, the default, is every playbook as written. `eco` keeps in fresh
      context every lane whose job is finding someone else's mistakes (the writer, blast radius, both reviewers every
      round, the architect judge and the trail review) and has the owner do the rest itself: its own `how` reading,
      one architect runner instead of two, the review without a wrapper lane, and a one-page report. An
      autopilot-stack owner also writes its own small fixes and records; in a ticket you run directly the delegation
      hook guards your session the same way in both tiers, so a small fix still goes to a fix lane. The table-first,
      tests-first design step is the same in both. `mkdir -p .claude/state && echo eco > .claude/state/tier` in the
      main checkout sets it; `rm -f .claude/state/tier` goes back to `safe`. A ticket reads the tier when it starts,
      and each autopilot-stack owner's brief carries it, so a change reaches only tickets started after it. `safe` is
      the fallback: when a model struggles in `eco` (a restart, a fifth review round, a verifier finding what the
      owner missed), run the next ticket, or this one again, in `safe`. The full list is Ticket step 0, "The tier",
      and `DECISIONS.md` P109."
   b. Line 94 (Rung 1): after "in a fresh context so the reviewer is not the author" add "(in `eco` the two reviewers
      are that fresh context and the owner judges their findings, P109)".
   c. Then `python3 tools/build_knowledge.py`; commit what it regenerates.
4. `template/AGENTS.md` (ours, the product) (risk 4, 5):
   a. Line 37, after "the orchestrator reviews the diff it gets back": add "; in `eco` a subagent owner writes its
      own small fixes and records commit (Ticket step 0, "The tier")".
   b. Line 79, "run `spec-review` round one in a fresh context" gains "(in `eco` its two reviewers are the fresh
      context, Ticket step 0)".
5. `template/docs/agents/review-ladder.md` line 6 (risk 5): the same clause as 4b after "in a fresh context".
6. This repository's `AGENTS.md` line 26 (risk 4): after "the orchestrator reviews the diff it gets back." add
   "In `eco` a subagent owner writes its own small fixes and records commit (Ticket step 0, "The tier")."

Commit per file group (1; 2; 3; 4 to 6), plain-sentence messages ending with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Checks, then hand back

Run /deslop over the whole branch diff against `origin/main` and /unslop over every prose line the writer and you
added (load both skills with the Skill tool; the writer did not). Fix what they find as a separate commit.
Then: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`,
`bash tests/hooks/delegation.sh`, `bash tests/poteto-mode/overlap.sh`, `./factory918.sh sync` then status (clean),
`python3 tools/build_knowledge.py` then status (clean), `python3 tools/check_knowledge.py`.

Write your report with Bash to exactly
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/fix1/report.md`
(create the directory): the branch, `git log --oneline wt/109-writer..HEAD`, each check and its outcome, and an
act-on list of anything you could not do as written or noticed outside it. Push nothing. Launch no agents. Reply
with only the report path.
