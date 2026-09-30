# Post-mortem, qualitative lane: what each delegate did and who caught what

Reconstruct, for each of the five tickets of the 2026-09-22 autopilot-stack run (#88 -> PR #96, #89 -> PR #94,
#90 -> PR #99, #91 -> PR #101, #93 -> PR #102), every delegate lane its owner launched, and judge what each one
contributed. Write for Manuel, who owns the factory but did not watch the run and does not want code-level detail:
name each finding in plain words (what would have gone wrong for a user of the factory, not which regex), and say
who found it. Write nothing under version control; the report goes to
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/postmortem/delegates.md`.

Sources, in this order:
- The owners' reports and trails under `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/{88,89,90,91,93}/` (report.md, decisions.tsv, todo.md, the writer/fix/explorer reports, design and arena files; #88's extra files are in `.claude/worktrees/owner-88/.scratch/program/88/`, #93's in `.claude/worktrees/agent-a8edee7d294766f8f/.scratch/program/93/`; a first #93 lane died and its scratch is under `.scratch/program/93/prior/`).
- The review comments on the five PRs (`gh pr view N --repo Zenoctra/factory918 --comments`), each carrying two reports and a judgment per round, and the root's verifier verdict comments.
- The root's verifier reports under `.scratch/program/verify/*/worker-*.md`.
- The owners' transcripts, only through grep/jq, never read whole: `/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/subagents/agent-<id>.jsonl` with `agent-<id>.meta.json` beside it (the meta gives the description and parent). Owner ids: #88 a942479d6cfa804a9, #89 a97eb18e88a1b4bcd, #90 a7e863dda12fb2374, #91 a1fb85ddeb81fc326, #93 a8edee7d294766f8f (and the dead first #93 owner a73dbb8e2f9e6aec5). Use `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | .input.description + " | " + (.input.prompt|.[0:300])'` on an owner's file to list its launches, and grep the children's meta for the parent.

For each ticket write:
1. A table of delegates: role, model, what it was asked in one line, roughly how long it ran, what it returned.
2. For each delegate, one of: "found something that changed the outcome" (say what, in plain words, and what
   would have shipped wrong without it), "did the work asked" (produced the artifact, nothing surprising),
   "rediscovered" (spent its time re-reading or re-deriving what the owner or a sibling already knew; name what),
   "wasted" (produced nothing used, or was killed).
3. The count the question asks: how many delegates the ticket had, and how many of them independently found
   something radically important that saved the ticket's execution on its own.
4. The three review rounds (or fewer) and the root's verification: for every finding that led to a fix, one
   plain sentence, who found it (the lane's own reviewers or the root's verifiers), and whether the other side had
   missed it.
5. What the owner itself rediscovered that a brief could have told it (reading AGENTS.md, the playbooks, ticket #42
   and PR #92, the review skill, the shellcheck gate's own behavior, GitHub's linking rule), with an estimate of
   the minutes each cost, from the trail timestamps.

Then a closing section across all five: the delegates that mattered most, ranked; the patterns of wasted lanes;
the information the root could have passed in each brief to save the most rediscovery; and the one change per
ticket that would have cut the most time. Reply with only the report path.
