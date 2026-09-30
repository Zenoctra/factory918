# Writer brief, ticket #109 (eco tier)

Repository: Zenoctra/factory918. Read AGENTS.md first (nesting rule; vendored skills change only through
patches/ + patches/series + SOURCES.md; never edit template/docs/factory918/, docs/knowledge/spec|pages|notes,
research/). Base: `origin/main` (a9ebdac). Work on a new branch `wt/109-writer` created from `origin/main` in
your own worktree. Do not touch `template/.agents/skills/spec-review/scripts/review-brief.sh` or its test
(ticket #108 edits them in parallel). Do not edit `docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md`,
`docs/M0-findings.md`: the owner writes those records.

The spec is the ticket: `gh issue view 109 --repo Zenoctra/factory918`. Its `## Testing decisions` section is
the scenario table you implement; read it whole. The table is the test: write the tests from it before
anything else, one assertion per cell in the table's order. If a cell cannot be implemented as written, stop
and report the cell; never fill it in.

Decisions already made (do not reopen): the delegation hook `template/.claude/hooks/delegation.sh` does NOT
change. The tier is stated once, in Ticket step 0, with one-sentence pointers at the steps that launch lanes.

## Commits, in this order (each its own commit; message a plain sentence, ending with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`)

### 1. Tests first: `tests/hooks/delegation.sh`

Table B: 7 calls x 3 fixture tiers = 21 `expect` lines. Insert them after the sub-agent group and before the
line `echo planning > .claude/state/mode` (the phase is `execute` there and the review state is live). Order:
for each tier fixture (`none` = `rm -f .claude/state/tier`, `eco` = `echo eco > .claude/state/tier`,
`junk` = `printf 'ECO\nfast\n' > .claude/state/tier`), assert rows B1..B7; label each with the tier and the row
(e.g. `"tier eco: B1 orchestrator one-line Edit of small.md"`). Add an Edit input builder beside `path()`,
`ranged()`, `bash_cmd()`: `edit() { jq -cn --arg p "$fx/$1" --arg o "$2" --arg n "$3" '{file_path:$p,old_string:$o,new_string:$n}'; }`.
Reuse `write_msg` for the block texts. `rm -f .claude/state/tier` before `echo planning`. A loop over the three
fixtures is fine if each cell stays one `expect` call with its own label; do not hide the expected values.
Run `bash tests/hooks/delegation.sh`: green against the unmodified hook, and the final count grows by 21. If any
row is not what the table says, stop and report the row with the hook's actual output.

### 2. `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, edit directly, no patch)

a. Step 0, a fifth bullet after the `gh issue edit --body-file` bullet, this text (you may tighten wording per
/writing-for-agents, but keep every rule):

   - **The tier.** A ticket runs `eco` when `[ "$(cat "$(git rev-parse --git-common-dir)/../.claude/state/tier" 2>/dev/null)" = eco ]` holds as its digest is written, and `safe` otherwise; that path is the main checkout's file from any worktree, so an owner reads the root's word. An eco digest's first line is `Tier: eco`. Under Autopilot-stack the root writes it into each owner's brief, and the brief wins over the file, because a run never changes tier halfway. A file holding anything but `eco` or `safe` reads `safe`, and the digest names the value it did not read. `safe` is every step as written. `eco` changes these and nothing else:
     1. `how` and `why` (step 5, Feature step 1) are your own reading: launch no explorer, explainer or investigator lane.
     2. `architect` Phase B and Design hole step 2 are one runner and one judge on another model, briefed to read that candidate adversarially against the ticket, the grounding and `architect`'s design red flags and to return its defects, which you fix in the synthesis. Feature step 4 briefs one writer, never an arena; Feature step 7's `interrogate` is not run, the judge stands in.
     3. You run `spec-review` without a review lane: its step 1 script, its two reviewers launched by you with their briefs' paths and polled per the poll rule, its judgment and its comment. Read no brief and no diff while the review state exists; the two reviewers are the fresh context.
     4. An owner that is a subagent writes its small fixes (a round's Act on items, a CI fix, its slice of a rebase) and its records commit itself, proved on the path CI takes (Feature step 5). In the root session the delegation hook blocks a lane's file in both tiers, so a ticket run there briefs a fix lane as in `safe` (P109).
     5. Every hand-back, the Reply below and each STACK-READY report, is one page under Autopilot-stack step 7's headings: `## Head`, `## Criteria`, `## Review`, `## CI`, `## Flags`.

     In both tiers the writer, `blast-radius`, both reviewers every round, the architect judge and the trail review are fresh lanes, and step 6's table-first, tests-first order is unchanged. So an eco ticket launches at most one writer, one blast-radius lane, one runner and one judge, two reviewers per round and one trail review, and logs each launch as a trail row so the trail review can count them.

b. Pointers, one clause each:
   - Step 5, after "`how` and `why` over the affected subsystem come first in all of them.": "In `eco` you read them yourself (step 0, the tier)."
   - Step 6, after the sentence naming `architect`'s first deliverable (the scenario table): "In `eco` the architect step is one runner and an adversarial judge (step 0, the tier); the table comes first in both tiers."
   - Step 8, after "poll each review lane's result file per the poll rule (step 0);": "in `eco` there is no review lane, you run `spec-review` yourself (step 0, the tier);"
   - Design hole step 2: "Two runners; the judge is skipped when they converge." becomes "Two runners, the judge skipped when they converge; in `eco`, one runner and the judge (step 0, the tier)."
   - The `**Reply:**` line of the Ticket section, appended: "In `eco` it is step 0's one page."

### 3. Two vendored files, through their existing patches

- `template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md` step 1: "then reading the digest (Ticket step 0) its brief carries;" becomes "then reading the digest (Ticket step 0) its brief carries, whose first line is `Tier: eco` when the root's tier file read `eco` as that owner launched, and following that tier for its whole run;". Check the exact current wording first and keep the sentence grammatical.
- `template/.agents/skills/architect/SKILL.md`, after the "**Design it twice.**" paragraph, a new sentence or short paragraph: "A caller whose tier asks for one runner (Factory918's `eco`, Ticket step 0) keeps the cross-judge and briefs it to read that one candidate adversarially against the rubric and the grounding; the judge's defects stand in for the second candidate."
- Regenerate each patch with the `diff -u --label` form in `patches/README.md`, against `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/...`, never against `template/`: `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch` and `patches/pstack/architect/SKILL.md.patch` (the architect edit is a second hunk, outside the existing `@@ -29,7` one). Both are already in `patches/series`; no new line.
- `SOURCES.md`: item 11 (autopilot-stack step 1) and item 14 (architect Phase B) each gain one clause naming the tier sentence and #109.
- `./factory918.sh sync` must leave `git status` clean.

### 4. `docs/knowledge/core/MANUAL.md` "Execution"

A new paragraph between the `/poteto-mode "#42"` paragraph and **Several at once.**:

   **Safe and eco.** A run has a tier. `safe`, the default, is every playbook as written. `eco` keeps in fresh context every lane whose job is finding someone else's mistakes (the writer, blast radius, both reviewers every round, the architect judge and the trail review) and has the owner do the rest itself: its own `how` reading, one architect runner instead of two, the review without a wrapper lane, its small fixes and records, and a one-page report. The table-first, tests-first design step is the same in both. `echo eco > .claude/state/tier` in the main checkout sets it; `rm .claude/state/tier` goes back to `safe`. A ticket reads the tier when it starts, and each autopilot-stack owner's brief carries it, so a change reaches only tickets started after it. `safe` is the fallback: when a model struggles in `eco` (a restart, a fifth review round, a verifier finding what the owner missed), run the next ticket, or this one again, in `safe`. The delegation hook guards the session you type into the same way in both tiers, so in a ticket you run directly a small fix still goes to a fix lane; an autopilot-stack owner writes its own. The full list is Ticket step 0, "The tier", and `DECISIONS.md` P109.

Plus one sentence after the `## Models and cost` table: "The tier (Execution, **Safe and eco.**) decides how many of these roles a ticket launches; `eco` drops the explorer, explainer, review wrapper, fix and records lanes."

Then `python3 tools/build_knowledge.py` (renumbers `## Contents`, regenerates `template/docs/factory918/MANUAL.md`;
commit what it changes) and `python3 tools/check_knowledge.py` must pass. P109 does not exist until the
owner's records commit; if check_knowledge refuses a dangling `P109` mention, report it rather than working around it.

## Before you hand back

- Run /deslop on your diff and /unslop on the prose you added.
- Run: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`, `bash tests/hooks/delegation.sh`, `bash tests/shellcheck/gate.sh`, `bash tests/poteto-mode/overlap.sh`, `./factory918.sh sync` then `git status --porcelain` (empty), `python3 tools/build_knowledge.py` then `git status --porcelain` (empty), `python3 tools/check_knowledge.py`.
- Your report is an act-on list: every deviation from this brief, every cell you could not implement, every
  edge you noticed outside the table, each as a numbered flag.

Write your report with Bash (`cat > FILE`) to exactly
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/writer/report.md`
(create the directory): the branch name, the output of `git log --oneline origin/main..HEAD`, each check and its
outcome, and the flags. Push nothing. Launch no agents. Reply with only the report path.
