# Constraints audit: what every lane is doing

Repository: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918, main at 9846844. This is read-only work: change nothing under version control and post nothing on GitHub. Write only your own lane file under `.scratch/program/constraints-audit/`. You may read anything in the repository, the upstream corpus under `research/`, git history, and GitHub issues through `gh` (read-only), and run any read-only command.

## Why

Manuel ruled on 2026-09-24, in his words:

> "I dont want you telling a reviewer what they CANT look at. You ONLY highlight things they CAN look at. [...] I would literally have you pass a subagent no brief at all than sit there and constrain them to only the files you THOUGHT were important before it started exploring. [...] This is the case with pretty much every subagent. These guys are smart, let them work without neutering them with heavy constraints!"

We are auditing every template through which an orchestrator talks to a subagent (reviewers, verifiers, writers, fix lanes, explorers, how/why lanes, architect runners and judges, arena runners and judges, interrogate, swarm workers, blast radius, trail review, eval runners, the autopilot owner brief, the pstack lane wrappers, and any other), to find the sentences that constrain the subagent. A "template" here is any text an orchestrator hands a subagent: a script that generates a brief, a prompt file, a playbook passage the orchestrator is told to copy or paraphrase into a brief, an agent definition, or a hand-written brief.

## What to record, per template in your area

1. Its path; what fills it (a script such as `review-brief.sh`, prose in a playbook the orchestrator copies, or nothing where the orchestrator writes the brief freehand); which role receives it.
2. Every sentence that tells a subagent what it may not read, open, run, explore or consider, or limits it to a list of files, a section, a function, a word count, an item count, a tool set or a time. Quote it verbatim with file:line. Examples: "read only X", "do not read beyond", "read that one function, not the file", "Run nothing", "under N words", "only the files named", "skip Y", "do not explore". Also count sentences in a playbook that tell the ORCHESTRATOR to put such a limit in the brief it writes (for example "tell the lane to read only the diff"). Classify each:
   - (a) limits what the agent may look at or explore;
   - (b) limits what it may run, when the run is read-only;
   - (c) caps output, effort, or scope of search;
   - (d) a real safety rule about side effects: no push, no merge, no posting, no writes outside its worktree, secrets, destructive git. List these separately and briefly;
   - (e) a format rule for the hand-back, such as headings or a path to write. One line per template saying these exist is enough.
   A sentence that highlights what the agent CAN look at ("the pack carries X", "the ticket is at Y") is fine and is not a finding, unless it is phrased as a limit.
3. Provenance of each (a), (b) or (c) sentence: upstream verbatim (find the same sentence under `research/`, the vendored pstack is under `research/3-pstack/` and Matt Pocock's skills under `research/1-matt-pocock/`; `SOURCES.md` says which upstream each vendored skill came from), our patch (name the file under `patches/`), or ours (run `git log -S '<distinctive phrase>' --oneline -- <path>` to find the commit that introduced it, then read that commit message and say whether a ticket number or a DECISIONS.md row asked for the limit; `gh issue view N --repo Zenoctra/factory918` reads a ticket). Manuel suspects a cost-saving lane added these unasked, so where the introducing commit or its ticket explains why, quote the reason.
4. For each (a), (b) or (c) sentence, propose a replacement that only highlights what the agent can use, or a deletion. Do not propose new constraints.

Be exhaustive within your area: a missed constraint is worse than an extra line. If you meet a template outside your area that looks like no other lane will cover it, include it too.

## Output

Write `.scratch/program/constraints-audit/lane-<your letter>.md` with a Bash heredoc. Structure: a short inventory table of the templates you covered (path, role, filled by, provenance of the template as a whole: upstream verbatim / patched / ours), then one section per template with its (a)/(b)/(c) findings (quote, file:line, class, provenance with commit hash and reason, proposed replacement), a brief (d) list, and a one-line (e) note. Say "none found" for a template that has no (a)/(b)/(c). Your final message is only the path of the file you wrote.
