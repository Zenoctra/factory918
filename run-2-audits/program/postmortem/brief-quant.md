# Post-mortem, quantitative lane: where the time and tokens went

Build one script (Python, no third-party packages) under
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/postmortem/parse.py`
that reads every transcript of the 2026-09-22 autopilot-stack run and writes tables. The script is the artifact a
reviewer reruns; keep it readable. Do not read the transcripts yourself with Read or cat: they total 87 MB. Inspect
their shape with `head -c 4000` on one file and `jq -c 'keys' | sort | uniq -c` style probes, then let the script do
the rest. Write nothing under version control; outputs go beside the script.

Inputs:
- Root session log: `/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5.jsonl`
- Subagent logs: `/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/subagents/agent-*.jsonl`, each with an `agent-*.meta.json` beside it (read one to learn what it holds: description, parent, model, timestamps).
- Owner decision trails, one per ticket: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/{88,89,90,91,93}/decisions.tsv` (columns ts, phase, decision, why, evidence, result; some timestamps are wrong or out of order, say so where you see it).
- The run's registry with the root's own timeline: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/state/todo-program.md` (read it whole; it is untracked).

Each JSONL line is a message with a timestamp, a type (user/assistant), an agentId, and for assistant messages a
`message.content` list of text and `tool_use` blocks plus a `message.usage` object (input, output, cache read, cache
create tokens); tool results come back as user messages with `tool_use_result` or `tool_result` content. Verify the
exact field names before coding; the first JSONL line of an owner is its brief.

Tables to write (markdown, under the same directory), each with a one-paragraph reading guide for a person who did
not watch the run:
1. `agents.md`: one row per agent (root included): id, description from meta, model, parent agent id (an owner's
   children carry the owner as parent; find the link in meta.json or in the parent's `Agent` tool_use blocks whose
   result carries the child id), role guess (owner / writer / fix / explorer / explainer / arena runner / reviewer /
   verifier / other, from the description), first and last timestamp, wall clock, number of assistant turns, tool
   calls, total input / output / cache-read / cache-create tokens, and the share of input that was cache reads.
2. `tree.md`: the launch tree: root -> owners -> their children -> grandchildren, indented, with each node's wall
   clock and tokens, and per owner the sum over its subtree. Say which owner's subtree cost most and why.
3. `timeline.md`: one Gantt-like table per owner (rows = the owner's phases from decisions.tsv `phase` column and
   its Agent launches, columns = start, end, minutes), plus the root's timeline from the registry and the root log
   (launches, verifications, rebases, the rate-limit pause 13:15 to 13:50 CDT). Timestamps in CDT.
4. `waits.md`: for every agent, the ten longest gaps between consecutive messages, classified as: model latency
   (assistant message after a tool result), tool time (tool result after a tool_use; name the tool and, for Bash,
   the first 80 chars of the command), waiting on children (the gap spans a child's run), or turn ended (the agent's
   last message before a later resume). Sum each class per agent and overall. This is the "where does the time go"
   table; make it the clearest one.
5. `reads.md`: which files were read by which agents (Read tool file_path; Bash commands with cat, sed -n, head,
   git show, gh issue view N, gh pr view N): a matrix of file/resource versus number of distinct agents that read
   it and total reads, sorted by agents descending, top 60. This shows what every lane rediscovers. Separate a
   sub-table for the ticket bodies (#42, #88 to #93), PR #92, AGENTS.md, the playbooks and SKILL.md files.
6. `tools.md`: tool-call counts per tool per role, and the mean tool time per tool.
7. `summary.md`: totals (wall clock of the run, sum of agent wall clocks, sum of tokens by role, tokens per PR),
   the five biggest single costs, and the five biggest single waits, each with one plain sentence on what it was.

When the JSONL lacks a field you need, say so in the table's reading guide rather than inventing it. Reply with
only the path of `summary.md`.
