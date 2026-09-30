# Fix brief 2, ticket #109, review round one's Act on items

Repository Zenoctra/factory918. Read AGENTS.md first. In your own worktree create branch `wt/109-fix2` from
`origin/feat/eco-tier` (run `git fetch origin` first; head 148aa8a, PR #135). Commits go on top; never rewrite
existing commits. Do not touch `template/.agents/skills/spec-review/scripts/review-brief.sh` or its test, the hook,
`docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md`, `docs/M0-findings.md`, and no vendored file (nothing
under `template/.agents/skills/` except `poteto-mode/playbooks/ticket.md`, which is ours).

Round one's comment: https://github.com/Zenoctra/factory918/pull/135#issuecomment-5801940462 (read it). Fix these:

1. [P1][S1] `interrogate` is dropped only at Feature step 7, but Opening a PR's last line has a subagent that opens a
   PR run `interrogate`, and review-ladder rung 3 and MANUAL ladder item 6 launch it too.
   - `template/.agents/skills/poteto-mode/playbooks/ticket.md`, step 0 "The tier": item 2's clause "you skip Feature
     step 7's `interrogate`, and the judge stands in" becomes "you skip `interrogate` wherever a step launches it
     (Feature step 7, Opening a PR's subagent line, review-ladder rung 3), and the judge stands in". The lead-in's
     override list "(Feature steps 4, 5 and 7, the `how` fan-out, `spec-review`'s fix lane)" gains "Opening a PR's
     `interrogate`".
   - `template/docs/agents/review-ladder.md` rung 3 (line 8): add "Not run in `eco` (Ticket step 0, "The tier")."
   - `docs/knowledge/core/MANUAL.md` ladder item 6 (line 98): add the same pointer clause.
2. [S2] `docs/knowledge/core/MANUAL.md`, the sentence after the `## Models and cost` table becomes: "The tier
   (Execution, **Safe and eco.**) decides how many of these roles a ticket launches: `eco` runs one architect runner
   instead of two, no writer arena and no `interrogate`, and drops the explorer, explainer and review wrapper lanes,
   and under Autopilot-stack the fix and records lanes."
3. [S3][S4] `docs/knowledge/core/MANUAL.md`, replace the **Safe and eco.** paragraph with this, which keeps only what
   a person decides and points at the one list:
   "**Safe and eco.** A run has a tier. `safe`, the default, is every playbook as written. `eco` keeps the writer and
   every lane whose job is reading someone else's work (blast radius, both reviewers every round, the architect judge,
   the trail review) in fresh context, and has the owner do the rest itself; the list is Ticket step 0, "The tier",
   and the reasons are `DECISIONS.md` P109. `mkdir -p .claude/state && echo eco > .claude/state/tier` in the main
   checkout sets it; `rm -f .claude/state/tier` goes back to `safe`. A ticket reads the tier when it starts, and each
   autopilot-stack owner's brief carries it, so a change reaches only tickets started after it. The delegation hook
   guards the session you type into the same way in both tiers: in a ticket you run yourself, a small fix still goes
   to a fix lane. `safe` is the fallback: when a model struggles in `eco` (a restart, a fifth review round, a verifier
   finding what the owner missed), run the next ticket, or this one again, in `safe`."
   Then `python3 tools/build_knowledge.py`; commit what it regenerates.

One commit for item 1, one for items 2 and 3; plain-sentence messages ending with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Run /unslop over the lines you add (load it with the Skill tool).

Checks: `bash tests/hooks/delegation.sh`, `./factory918.sh sync` then status clean, `python3 tools/build_knowledge.py`
then status clean, `python3 tools/check_knowledge.py`. Write your report with Bash to exactly
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/fix2/report.md` (create
the directory): the branch, `git log --oneline origin/feat/eco-tier..HEAD`, each check and its outcome, and an act-on
list of anything you could not do as written. Push nothing. Launch no agents. Reply with only the report path.
