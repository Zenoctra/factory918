# Architect task, ticket #109 (eco tier)

Repository (read only for you): /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a2ce71454fd0910f0
(branch feat/eco-tier at origin/main). Read its AGENTS.md first.

The ticket: `gh issue view 109 --repo Zenoctra/factory918`. Its What to build quotes the conversation that settled
which lanes each tier keeps; those choices are settled by Manuel and are not yours to reopen. Build a design that
meets all five acceptance criteria.

Grounding (read whole): /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/how/how.md
Also: the run's numbers in /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/digest.md

Constraints the design must respect:
- The design has state (a tier value some file holds, the delegation hook's exit codes, more than one actor:
  root session, owner subagent, lanes). So the first deliverable is the scenario table, its legend and contract,
  then the test list (one assertion per cell), per architect's runner prompt.
- Criterion 3: the hook's eco behavior is decided and tested. Two options the ticket allows: the hook allows the
  orchestrator's small fixes in eco under a stated size, or small fixes in a root-run ticket still go to a fix lane.
  Pick one and defend it. Known facts: the hook binds only the root session (a subagent carrying agent_id passes);
  the hook parses no edit body today; Bash heredoc bodies are dropped by its tokenizer; ticket #132 (open) says the
  hook misses an interpreter (python, node) writing a lane's file. Do not fix #132 and do not rely on the hook's
  current Bash matching to enforce a size rule. Each row you add to the hook's behavior must be an `expect` line in
  `tests/hooks/delegation.sh`.
- Do not touch `template/.agents/skills/spec-review/scripts/review-brief.sh` or its test (another ticket, #108,
  edits them in parallel).
- Vendored files (everything under template/.agents/skills except the keep_files named in how.md section 4) change
  only through a patch regenerated against research/, a `patches/series` line for a new patch, and a SOURCES.md item.
  `template/.agents/skills/poteto-mode/playbooks/ticket.md` is ours and edited directly. Fewer vendored files
  touched is better; #105 set the precedent of stating a rule once (Ticket step 0 digest) and pointing at it
  (DECISIONS P105).
- The tier file placement must survive an autopilot-stack owner running in its own worktree (how.md section 1 trap);
  criterion 4 wants the owner brief to name the tier.
- Criterion 4 also asks that a run under eco with the five tickets' shape launch per ticket at most: the writer,
  the blast-radius lane, the runner and judge, two reviewers per round, the trail review. Say how that is proven
  (a count derived from the playbooks, a test, or a walk in the PR's Verification).
- Criterion 1: DECISIONS Provisional row P109 naming both tiers and what each keeps; MANUAL.md "Execution" says how
  to set the tier and that safe is the fallback when a model struggles. Criterion 5 is the ledger line (the owner
  writes it; not your concern beyond noting it).
- Safe must stay byte-for-byte today's behavior where the tier file is absent.

Deliver: a design package per `template/.agents/skills/architect/references/runner-prompt.md` and
`rationale-template.md`: scenario table (legend, table, contract, test list), then the file-by-file change list
(each file, vendored or ours, the patch it goes through, and the exact sentence or code added), then rationale.
Keep it under about 300 lines.
