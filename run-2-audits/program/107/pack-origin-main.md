## Reading pack

### docs/knowledge/core/DECISIONS.md, lines 1-1 of 104

```
<!-- lines: 104 | source: core/DECISIONS.md | part 1/1 | title: Factory918: decisions -->
```

### factory918.sh, lines 379-405 of 428

```
cmd_sync() {
  need git
  local skills="$TEMPLATE/.agents/skills"
  local pstack="$F918_DIR/research/3-pstack/open-pstack-claude-code-port/plugins/pstack"
  local matt="$F918_DIR/research/1-matt-pocock/skills-repo/skills"
  local ours="factory918 factory-start knowledge mode-plan mode-build factory-doctor factory-retro"
  local keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh spec-review/scripts/reading-pack.sh"
  local tmp; tmp="$(mktemp -d)"
  for k in $keep_files; do mkdir -p "$tmp/keep/$(dirname "$k")"; cp "$skills/$k" "$tmp/keep/$k"; done
  for d in "$pstack"/skills/*/; do n="$(basename "$d")"; [ "$n" = no-comments ] && continue; rm -rf "${skills:?}/$n"; cp -R "$d" "$skills/$n"; done
  for n in grilling grill-me grill-with-docs domain-modeling to-spec to-tickets wayfinder research prototype setup-matt-pocock-skills writing-for-agents wizard wait-what; do
    src="$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1)"; rm -rf "${skills:?}/$n"; cp -R "$src" "$skills/$n"; done
  rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review" "$skills/spec-review"
  for k in $keep_files; do mkdir -p "$skills/$(dirname "$k")"; cp "$tmp/keep/$k" "$skills/$k"; done
  rm -rf "$TEMPLATE/.claude/agents"; mkdir -p "$TEMPLATE/.claude/agents"; cp "$pstack"/agents/*.md "$TEMPLATE/.claude/agents/"; rm -f "$TEMPLATE/.claude/agents/comment-sicko.md"
  local failed=0
  while read -r p; do
    [ -n "$p" ] || continue
    if git -C "$skills" apply --check "$F918_DIR/patches/$p" 2>/dev/null; then git -C "$skills" apply "$F918_DIR/patches/$p"; echo "applied  $p"
    else echo "FAILED   $p (upstream moved; rewrite the patch)"; failed=1; fi
  done < "$F918_DIR/patches/series"
  rm -rf "$tmp"
  for n in $ours; do [ -f "$skills/$n/SKILL.md" ] || { echo "missing our skill: $n" >&2; failed=1; }; done
  local -a dirs; dirs=("$skills"/*/)
  echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
  return $failed
}
```

### patches/pstack/babysit/SKILL.md.patch, whole, 12 lines

```
--- a/babysit/SKILL.md
+++ b/babysit/SKILL.md
@@ -37,7 +37,8 @@
    - Idle but want to catch new comments: hourly.
 
 4. **When to stop.**
-   - Build is green, every comment resolved, branch merges cleanly → call it ready.
+   - Build is green, every comment resolved, the `spec-review` comment on the latest commit reads `act-on items: 0`, branch merges cleanly → call it ready. The review runs three rounds on one PR, five when round three or four fixed a Would-break item; a comment reading `round: 3 of 3`, `round: 4 of 5` or `round: 5 of 5` with `act-on items: 0` and no `would-break fixed after <sha>` line makes the PR review-ready even when the fix commits it names come after the reviewed commit. A comment carrying the line `would-break fixed after <sha>` is not review-ready whatever its count: below round five another round is owed and the orchestrator runs it (`spec-review` step 1 says its fixed point); at `round: 5 of 5` it is the human's line, a wait like an `## Ask` item and not a blocker to fix here, until the human answers the report the orchestrator posted on the PR. A round-one or round-two comment carrying the line `next round owed: round <N> reviews the fixes marked here` is not review-ready whatever its count: the orchestrator runs that round (`spec-review` step 1); the lines `reviewed: <sha>` and `fix only after <sha>` only record where the next round starts and change nothing here. An item under `## Ask` in that comment waits for the human and is not fixed on the PR; once the human answers, the orchestrator re-sorts it in the judgment with the answer as its reason and reruns `scripts/review-comment.sh <dir>` on the same reports, which is the same round.
+   - A review comment carrying the line `restart` names a design hole and is not a merge-ready comment whatever its count: the Ticket playbook's Design hole section returns the work to `architect`, and the PR is ready only when a later review comment without a `restart` line reads `act-on items: 0`.
    - You've run three rounds of fix → push → recheck and it still isn't fully green → stop, summarise what's still broken, and hand control back.
    - The next fix would force a design choice → pause and put it to the user with `AskUserQuestion`.
 
```

### patches/pstack/poteto-mode/playbooks/autonomous-run.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/autonomous-run.md
+++ b/poteto-mode/playbooks/autonomous-run.md
@@ -3,7 +3,7 @@
 **You own the exit condition. Define done, then drive to it without stopping.** For "going to bed" / "run until done" / "/loop until X".
 
 1. State the exit condition as a checkable predicate before the first iteration (tests green, repro fixed, all N PRs merged, pixel-diff zero). A vague goal stalls; a predicate lets you stop.
-2. Pick the wake mechanism using Claude Code's `loop` skill (built-in). An event to watch (CI, a merge, a ref advancing) gets a watcher subagent that wakes you on the event, with a long time-based heartbeat as fallback. No event gets a fixed-interval heartbeat sized to when the result is worth re-checking.
+2. Pick the wake mechanism using Claude Code's `loop` skill (built-in). An event to watch (CI, a merge, a ref advancing) gets a watcher subagent that wakes you on the event, with a long time-based heartbeat as fallback. The wake reaches only the root session; a run inside a lane polls the watcher's result file per the poll rule (Ticket step 0) instead. No event gets a fixed-interval heartbeat sized to when the result is worth re-checking.
 3. Each iteration makes the smallest change the evidence justifies, verifies it against the predicate, commits if it advanced, discards changes that didn't help. Belt-and-suspenders that "might help" gets reverted, not left to ride.
    Sequence the work via the **sequence-verifiable-units** principle skill, verifying each unit before the next instead of batching checks at the end.
 4. Mid-run discoveries are yours. Address broken skills, related bugs, flaky verifiers, review noise, tooling failures, orphaned follow-ups, and fixable drift yourself via poteto-mode. Put out-of-band fixes in their own PR. Do not park reversible work for the human or use `AskUserQuestion`. Surface only irreversible actions, genuine product or preference calls no experiment can settle, or a real dead end. Keep the predicate as the main drive, and return to it after each side fix.
```

### patches/pstack/poteto-mode/playbooks/eval.md.patch, whole, 13 lines

```
--- a/poteto-mode/playbooks/eval.md
+++ b/poteto-mode/playbooks/eval.md
@@ -19,8 +19,8 @@
 1. **Frame.** State what variant is under test and what behavior counts as success. Write the rubric (3-6 concrete criteria) for the judge only. Hold it back from candidates.
 2. **Set up sanitized environments.** Per-candidate working dir with the variant in place. Plant any context an organic task would have: a project skeleton, the skills the candidate would naturally read.
 3. **Author one organic prompt.** What a user would type. No leakage of what's being measured.
-4. **Spawn N parallel candidates** on different models per the **arena** skill's Phase B. Each works in its own sanitized dir; same prompt to each.
-5. **Spawn one blinded judge** on a different model family per the **arena** skill's Phase C. Judge sees outputs by sanitized label and the rubric, never a model name.
+4. **Spawn N parallel candidates** on different models per the **arena** skill's Phase B. Each works in its own sanitized dir; same prompt to each. Poll each lane's result file per the poll rule (Ticket step 0).
+5. **Spawn one blinded judge** on a different model family per the **arena** skill's Phase C. Judge sees outputs by sanitized label and the rubric, never a model name. Poll its result file per the poll rule (Ticket step 0).
 6. **Verify the chain from transcripts, not self-report.** Read each candidate's local transcript under Claude Code's per-project transcripts directory at `~/.claude/projects/<encoded-cwd>/` (one `*.jsonl` per session for this workspace). Do not glob across `~/.claude/projects/`; that crosses workspace boundaries and reads private chats from unrelated projects. Look at which files each candidate actually opened. Citing a principle is not reading its leaf skill, and reading it is not applying it. Grade chain-following from the files it really read plus the shape of the code, never from the candidate's own claims.
 7. **Read every candidate output yourself** end to end. Compare to the judge's verdict. Disagreement means a model is biased or the rubric is ambiguous. Synthesize.
 
```

### patches/pstack/poteto-mode/playbooks/investigation.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/investigation.md
+++ b/poteto-mode/playbooks/investigation.md
@@ -4,7 +4,7 @@
 
 Read-only requests: "how does X work?", "why was Y built this way?", "are we sure about Z?", "should we do X or Y?". They produce a cited explanation or a recommendation, not a code change.
 
-1. Route through the **how** skill (Explain mode for narrow questions, Critique mode for "are we sure?"). For motivation questions, also route through the **why** skill.
+1. Route through the **how** skill (Explain mode for narrow questions, Critique mode for "are we sure?"). For motivation questions, also route through the **why** skill. Poll each lane's result file per the poll rule (Ticket step 0).
 2. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only investigation`. The four-item version is for code-shaped work.
 3. Produce the `how`-shaped output (Overview / Key Concepts / How It Works / Where Things Live / Gotchas), or a recommendation with a tradeoffs table if the request is a decision between alternatives.
 4. Apply the **unslop** skill to the reply.
```

### patches/pstack/poteto-mode/playbooks/runtime-forensics.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/runtime-forensics.md
+++ b/poteto-mode/playbooks/runtime-forensics.md
@@ -3,7 +3,7 @@
 **You own the diagnosis. Instrument the live process, don't theorize from source.** For "why is X leaking / spinning / slow at runtime", heap snapshots, idle-but-busy processes, intermittent glitches. The deliverable is a cited diagnosis, not a fix.
 
 1. Capture the live signal on the matching surface via the driver skill (`run` for CLIs/TUIs, `verify` for UIs): a CPU profile for a spinning process, a heap snapshot for a leak, a CDP trace for a visual glitch. A real artifact, not a guess.
-2. Reduce the artifact to the smoking gun: the function on the hot path, the retainer chain from the leaked object to a GC root, the loop firing without input. Parse large artifacts in a subagent (the **guard-the-context-window** principle skill), keep the reduced finding in the main thread.
+2. Reduce the artifact to the smoking gun: the function on the hot path, the retainer chain from the leaked object to a GC root, the loop firing without input. Parse large artifacts in a subagent (the **guard-the-context-window** principle skill), keep the reduced finding in the main thread, and poll the subagent's result file per the poll rule (Ticket step 0).
 3. Prove the mechanism before believing it. Inject instrumentation via CDP eval on the running process, or hotfix the live code without reloading, to confirm the hypothesis cheaply. A plausible-but-unconfirmed cause can be wrong while the real one sits one layer over.
 4. Map the finding back to source: file, symbol, the line that allocates or schedules.
 5. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only forensics`.
```

### patches/pstack/poteto-mode/playbooks/shipping.md.patch, added, 11 lines; the diff carries it whole: no text

### patches/pstack/poteto-mode/playbooks/trace-forensics.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/trace-forensics.md
+++ b/poteto-mode/playbooks/trace-forensics.md
@@ -4,7 +4,7 @@
 
 Distinct from **Runtime forensics**, which instruments the live process. Here the capture already exists; the artifact is a fixed dataset, read it, don't re-run it. Keep tooling generic so the playbook stays portable: a DevTools or trace parser for cpuprofile and `.json.gz`, a text editor for a spindump, your heap tooling for a heapsnapshot.
 
-1. Identify the format and load it with the right tool. Parse large artifacts in a subagent (the **principle-guard-the-context-window** skill) and keep the reduced finding in the main thread.
+1. Identify the format and load it with the right tool. Parse large artifacts in a subagent (the **principle-guard-the-context-window** skill), keep the reduced finding in the main thread, and poll the subagent's result file per the poll rule (Ticket step 0).
 2. Transform the raw artifact into a form you can query. Dump the trace or heap snapshot into sqlite, one row per sample, frame, or node. Reach the queryable shape before you read.
 3. Narrow to the cause. Query for the frames that hold the most time and walk the call tree to the hot path. For a leak, follow the retainer chain from the leaked object to a GC root. For a spindump, find the thread stuck on-CPU or blocked and its wait reason.
 4. Attribute to source. Map the hot frame to file, symbol, and line via the artifact's own symbols. A frame with no source mapping is not yet a diagnosis; resolve the symbols, or say plainly the artifact does not carry them.
```

### patches/pstack/poteto-mode/playbooks/visual-parity.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/visual-parity.md
+++ b/poteto-mode/playbooks/visual-parity.md
@@ -4,7 +4,7 @@
 
 1. Establish the baseline first, before any migration: a visual regression harness that screenshots the current component across its states, plus the target when matching two implementations. No baseline, no parity claim. A blocking prerequisite, not a follow-up.
 2. Anti-shortcut clauses, stated and held: no harness modifications, no baseline tampering, no component restructuring to make a diff pass. If the baseline looks wrong, stop and ask, don't edit it.
-3. Migrate one component at a time. Each is an independent artifact, so parallelize across worktrees, one owner per component (the **separate-before-serializing-shared-state** principle skill). Shared primitives migrate first as a blocking phase.
+3. Migrate one component at a time. Each is an independent artifact, so parallelize across worktrees, one owner per component (the **separate-before-serializing-shared-state** principle skill). Poll each lane's result file per the poll rule (Ticket step 0). Shared primitives migrate first as a blocking phase.
 4. Verify each component against its baseline via image diff on the matching surface via the driver skill (`run` for CLIs/TUIs, `verify` for UIs). A nonzero diff is a fail; investigate the pixel delta, don't wave it through. `/loop` per component until the diff is zero.
 5. Run **Opening a PR** per component or per safe batch.
 
```

### patches/series, whole, 32 lines

```
pstack/poteto-mode/SKILL.md.patch
pstack/poteto-mode/playbooks/autopilot-full.md.patch
pstack/poteto-mode/playbooks/autopilot-stack.md.patch
pstack/poteto-mode/playbooks/babysit.md.patch
pstack/babysit/SKILL.md.patch
pstack/poteto-mode/playbooks/multi-phase-plan.md.patch
pstack/poteto-mode/playbooks/opening-a-pr.md.patch
pstack/poteto-mode/playbooks/bug-fix.md.patch
pstack/poteto-mode/playbooks/feature.md.patch
pstack/poteto-mode/playbooks/perf-issue.md.patch
pstack/poteto-mode/playbooks/refactoring.md.patch
pstack/architect/SKILL.md.patch
pstack/architect/references/runner-prompt.md.patch
pstack/poteto-mode/references/codex-tools.md.patch
pstack/poteto-mode/references/provider-dispatch.md.patch
pstack/poteto-mode/scripts/runner/model-matrix.test.ts.patch
pstack/interrogate/SKILL.md.patch
pstack/setup-pstack/SKILL.md.patch
pstack/unslop/SKILL.md.patch
mattpocock/spec-review.SKILL.md.patch
mattpocock/to-spec/SKILL.md.patch
pstack/poteto-mode/playbooks/autonomous-run.md.patch
pstack/poteto-mode/playbooks/eval.md.patch
pstack/poteto-mode/playbooks/hillclimb.md.patch
pstack/poteto-mode/playbooks/orchestrate.md.patch
pstack/poteto-mode/playbooks/runtime-forensics.md.patch
pstack/poteto-mode/playbooks/session-pickup.md.patch
pstack/poteto-mode/playbooks/shipping.md.patch
pstack/poteto-mode/playbooks/trace-forensics.md.patch
pstack/poteto-mode/playbooks/visual-parity.md.patch
pstack/poteto-mode/playbooks/worktree-cleanup.md.patch
pstack/poteto-mode/playbooks/investigation.md.patch
```

### template/.agents/skills/poteto-mode/playbooks/autonomous-run.md, whole, 13 lines

```
### Autonomous run

**You own the exit condition. Define done, then drive to it without stopping.** For "going to bed" / "run until done" / "/loop until X".

1. State the exit condition as a checkable predicate before the first iteration (tests green, repro fixed, all N PRs merged, pixel-diff zero). A vague goal stalls; a predicate lets you stop.
2. Pick the wake mechanism using Claude Code's `loop` skill (built-in). An event to watch (CI, a merge, a ref advancing) gets a watcher subagent that wakes you on the event, with a long time-based heartbeat as fallback. The wake reaches only the root session; a run inside a lane polls the watcher's result file per the poll rule (Ticket step 0) instead. No event gets a fixed-interval heartbeat sized to when the result is worth re-checking.
3. Each iteration makes the smallest change the evidence justifies, verifies it against the predicate, commits if it advanced, discards changes that didn't help. Belt-and-suspenders that "might help" gets reverted, not left to ride.
   Sequence the work via the **sequence-verifiable-units** principle skill, verifying each unit before the next instead of batching checks at the end.
4. Mid-run discoveries are yours. Address broken skills, related bugs, flaky verifiers, review noise, tooling failures, orphaned follow-ups, and fixable drift yourself via poteto-mode. Put out-of-band fixes in their own PR. Do not park reversible work for the human or use `AskUserQuestion`. Surface only irreversible actions, genuine product or preference calls no experiment can settle, or a real dead end. Keep the predicate as the main drive, and return to it after each side fix.
5. Checkpoint every iteration via the **show-me-your-work** skill, a row for what changed and whether the predicate moved. A run with no trail can't be audited or resumed.
6. Stop when the predicate is met. A plateau is not a stop, so keep going and pivot your approach to push past it. Surface a genuine dead end rather than spinning, and never relax the predicate to declare victory.

**Reply:** the exit condition, iterations run, what landed, what was discarded, final predicate state.
```

### template/.agents/skills/poteto-mode/playbooks/investigation.md, whole, 14 lines

```
### Investigation

**You own the answer. Plan, route, write.**

Read-only requests: "how does X work?", "why was Y built this way?", "are we sure about Z?", "should we do X or Y?". They produce a cited explanation or a recommendation, not a code change.

1. Route through the **how** skill (Explain mode for narrow questions, Critique mode for "are we sure?"). For motivation questions, also route through the **why** skill. Poll each lane's result file per the poll rule (Ticket step 0).
2. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only investigation`. The four-item version is for code-shaped work.
3. Produce the `how`-shaped output (Overview / Key Concepts / How It Works / Where Things Live / Gotchas), or a recommendation with a tradeoffs table if the request is a decision between alternatives.
4. Apply the **unslop** skill to the reply.

No PR, no babysit, no `architect` unless the investigation precedes a code change. If it does, hand back to the user and re-route to Bug fix or Feature.

**Reply:** the investigation output. For "are we sure?" answers, include your real judgment with reasons. Push back if the premise is wrong (see Autonomy).
```

### template/.agents/skills/poteto-mode/playbooks/runtime-forensics.md, whole, 11 lines

```
### Runtime forensics

**You own the diagnosis. Instrument the live process, don't theorize from source.** For "why is X leaking / spinning / slow at runtime", heap snapshots, idle-but-busy processes, intermittent glitches. The deliverable is a cited diagnosis, not a fix.

1. Capture the live signal on the matching surface via the driver skill (`run` for CLIs/TUIs, `verify` for UIs): a CPU profile for a spinning process, a heap snapshot for a leak, a CDP trace for a visual glitch. A real artifact, not a guess.
2. Reduce the artifact to the smoking gun: the function on the hot path, the retainer chain from the leaked object to a GC root, the loop firing without input. Parse large artifacts in a subagent (the **guard-the-context-window** principle skill), keep the reduced finding in the main thread, and poll the subagent's result file per the poll rule (Ticket step 0).
3. Prove the mechanism before believing it. Inject instrumentation via CDP eval on the running process, or hotfix the live code without reloading, to confirm the hypothesis cheaply. A plausible-but-unconfirmed cause can be wrong while the real one sits one layer over.
4. Map the finding back to source: file, symbol, the line that allocates or schedules.
5. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only forensics`.

**Reply:** the signal captured, the reduced finding, how you proved the mechanism, the source location, artifact paths. No fix unless asked; hand back to Bug fix or Perf once the cause is known.
```

### template/.agents/skills/poteto-mode/playbooks/shipping.md, lines 8-8 of 17

```
2. **Freeze and disarm the queue before verification.** Freeze an explicit bottom-to-top PR list. Confirm a same-repository stack against its base-branch chain. For fork heads, take the order from the verified local parent ancestry because every PR targets trunk and the forge bases do not encode the stack. Before launching any verifier, inspect every PR in the frozen list through the active forge, disarm every pre-existing merge-when-ready or auto-merge request, and confirm each request is off. On GitHub, query each PR through GraphQL for `id`, `headRefOid`, `baseRefName`, `autoMergeRequest`, and `mergeQueueEntry`. When `autoMergeRequest` is non-null, run `gh pr merge "$pr" --disable-auto --repo "$base_repo"`. When `mergeQueueEntry` is non-null, invoke the `dequeuePullRequest` mutation with `gh api graphql -F "id=$pr_node_id" -f query='mutation($id:ID!){dequeuePullRequest(input:{id:$id}){mergeQueueEntry{id}}}'`. The mutation takes the pull request node ID. Re-query and require that both `autoMergeRequest` and `mergeQueueEntry` are null. A null `autoMergeRequest` alone does not prove that the pull request is unarmed. On Origin, use its reported cancel operation and inspect every separately reported queue state. Stop if the active forge cannot confirm the whole list is unarmed. One subagent per PR, not batched, each in its own worktree, exercises the real surface against that PR's parent versus head. Poll each lane's result file per the poll rule (Ticket step 0). The bottom PR's patch base is trunk. Each child's patch base is the preceding PR's exact head, including when a fork child targets trunk at the forge. Each subagent returns `PASS`, `PASS+NOTES` or `FAIL` and posts that verdict on its own PR so the record outlives the chat. Safe means a verdict from an agent that did not write the code. CI green is not a verdict, and an approving bot review is not a verdict. Walk up from the bottom and stop at the first PR without a passing verdict, where both `PASS` and `PASS+NOTES` pass. Report that ceiling and what breaks the chain.
```

### template/.agents/skills/poteto-mode/playbooks/ticket.md, lines 33-42 of 53

```
### Design hole

**A finding whose fix changes the artifact is not fixed on the PR.** When a round's review comment carries a `restart` line, before babysit:

1. Read the `hole:` reference on each marked item: a cell, a signature or a criterion. That is the scope; nothing wider is redesigned.
2. Run `architect` Phase B scoped to it, with the judgment item, its report item and the artifact (the ticket's `## Testing decisions` table, its `## Design` sketch, or the criterion with the ticket's What to build and Decision quotes) as grounding. Two runners; the judge is skipped when they converge. Poll each lane's result file per the poll rule (step 0).
3. Amend the artifact on the ticket with a dated line, never a rewrite: `Amended <date> by #N (review round <r>, hole at <reference>): <what changed and why>; <which assertions moved>`. A criterion is re-derived from the ticket's intent and the line shows the old and the new wording.
4. Rewrite the tests from the amended artifact before the code (step 6), then redo the work on this branch; the PR stays open.
5. Review the redesigned work from round one: `review-brief.sh` reads the restart from the PR's comments and starts the count over; nothing from before it carries as settled, so a decision still needed is cited again in the new round one's judgment.
6. Then step 9. A PR mid-restart is never merge-ready.
```

### template/.agents/skills/poteto-mode/playbooks/trace-forensics.md, whole, 14 lines

```
### Trace forensics

**You own the diagnosis from the artifact. Load it, shape it, narrow to the cause, attribute to source.** For a dropped `.cpuprofile`, `Trace-*.json.gz`, `Spindump.txt`, or `.heapsnapshot` paired with "why is this slow / unresponsive / leaking / crashing".

Distinct from **Runtime forensics**, which instruments the live process. Here the capture already exists; the artifact is a fixed dataset, read it, don't re-run it. Keep tooling generic so the playbook stays portable: a DevTools or trace parser for cpuprofile and `.json.gz`, a text editor for a spindump, your heap tooling for a heapsnapshot.

1. Identify the format and load it with the right tool. Parse large artifacts in a subagent (the **principle-guard-the-context-window** skill), keep the reduced finding in the main thread, and poll the subagent's result file per the poll rule (Ticket step 0).
2. Transform the raw artifact into a form you can query. Dump the trace or heap snapshot into sqlite, one row per sample, frame, or node. Reach the queryable shape before you read.
3. Narrow to the cause. Query for the frames that hold the most time and walk the call tree to the hot path. For a leak, follow the retainer chain from the leaked object to a GC root. For a spindump, find the thread stuck on-CPU or blocked and its wait reason.
4. Attribute to source. Map the hot frame to file, symbol, and line via the artifact's own symbols. A frame with no source mapping is not yet a diagnosis; resolve the symbols, or say plainly the artifact does not carry them.
5. Confirm against a paired capture when you have one. Diff a before and after artifact so the attribution is the real regression, not background noise. Without one, mark the finding as the strongest hypothesis the artifact supports, not a confirmed cause.
6. Hand back a cited diagnosis, no fix unless asked. Route to Bug fix or Perf issue once the cause is known. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only forensics`.

**Reply:** the artifact and format, the reduced finding, the source location, the artifact paths, and whether a paired capture confirmed it.
```

### template/.agents/skills/poteto-mode/playbooks/visual-parity.md, whole, 11 lines

```
### Visual parity

**You own pixel-exact equivalence. The baseline is the spec; you do not touch it.** For "make X match Y exactly", styling-system migrations, porting a UI across frameworks. Equivalence is verified by image diff, not by eye.

1. Establish the baseline first, before any migration: a visual regression harness that screenshots the current component across its states, plus the target when matching two implementations. No baseline, no parity claim. A blocking prerequisite, not a follow-up.
2. Anti-shortcut clauses, stated and held: no harness modifications, no baseline tampering, no component restructuring to make a diff pass. If the baseline looks wrong, stop and ask, don't edit it.
3. Migrate one component at a time. Each is an independent artifact, so parallelize across worktrees, one owner per component (the **separate-before-serializing-shared-state** principle skill). Poll each lane's result file per the poll rule (Ticket step 0). Shared primitives migrate first as a blocking phase.
4. Verify each component against its baseline via image diff on the matching surface via the driver skill (`run` for CLIs/TUIs, `verify` for UIs). A nonzero diff is a fail; investigate the pixel delta, don't wave it through. `/loop` per component until the diff is zero.
5. Run **Opening a PR** per component or per safe batch.

**Reply:** components migrated, the diff result for each, the baseline harness location, what's left.
```

### template/.agents/skills/poteto-mode/references/provider-dispatch.md, lines 9-25 of 104

```
## Model matrix

| Family | Upstream pstack choice | Provider | Model | Default effort | Selectable efforts | Claude-native agent stem |
|---|---|---|---|---|---|---|
| fable | fable | claude | fable | max | low medium high xhigh max | fable |
| sol | gpt-5.6-sol-max | codex | gpt-5.6-sol | max | low medium high xhigh max | - |
| grok | grok-4.6-fast-xhigh | grok | grok-4.6 | xhigh | low medium high xhigh max | - |
| opus | opus | claude | opus | xhigh | low medium high xhigh max | opus |

The allowed effort universe is exactly `low`, `medium`, `high`, `xhigh`, `max`. First-run requested efforts are the Default effort cell of each row. A Claude-native agent stem of `-` means the family has no Claude-native agent. Otherwise the shipped agent name is `pstack-<stem>-<effort>`.

`fable` and `opus` are Claude Code's rolling aliases. Claude resolves each alias to the latest available family revision. A runner receipt keeps the requested alias in `model` and the concrete provider-reported revision in `reportedModel`; verification accepts only a numeric `claude-fable-*` or `claude-opus-*` revision from the matching family.

Probed 2026-09-22. The `opus` alias resolves to Opus 5.5, reported as `claude-opus-5-5`; Opus 5 is reported as `claude-opus-5`. Both verify as the `opus` family, and no descriptor distinguishes them, so reach Opus 5 only through an agent definition pinned to `claude-opus-5`.

Probed 2026-09-22. Codex CLI 0.154.0 on a ChatGPT account refuses `gpt-6-terra` and `gpt-6-sol`. Each warns that model metadata was not found, then fails with HTTP 400, `The '<model>' model is not supported when using Codex with a ChatGPT account`. `gpt-6-astra` is the served GPT-6 model on that account. None of the three has a row: the `sol` row stays on `gpt-5.6-sol` until a GPT-6 model is both served and configured for a role.

```

### template/.agents/skills/poteto-mode/references/provider-dispatch.md, lines 91-104 of 104

```
## Completion and dropouts

Success requires all of these:

1. Exit status `0`.
2. Receipt status `complete`.
3. Either `modelVerified: true` with `modelEvidence: "provider-report"`, or a Codex receipt with `reportedModel: null`, `modelVerified: false`, and `modelEvidence: "pinned-argv"`. For Claude's `fable` and `opus` aliases, the concrete provider report must belong to the requested family. Codex 0.149.0 and 0.154.0 accept the exact `--model` argument but do not report the served model in their JSONL stream.
4. A non-empty output file.

The receipt also carries elapsed time, token usage when the CLI exposes it, and cost when available. Keep it with the arena or review artifacts so parent-harness comparisons are evidence-based.

Any missing CLI, failed login, unavailable model, explicit timeout, cancellation, catchable post-reservation launcher failure, non-zero child exit, malformed result, or model mismatch is a receipt-bearing dropout. Record it and apply the calling skill's existing dropout policy. A `cancelled` receipt proves that the runner received the signal; its `signal` field is non-null only when the runner sent that signal to a still-active direct CLI child, and remains null when cancellation only stopped a post-exit pipe drain. The provider CLI owns any processes it starts beneath that direct child; the receipt does not claim a process-tree kill. Do not delete or overwrite the receipt. Never substitute the parent model, retry another provider, or reinterpret an external descriptor as a native model slug.

Start native and external lanes in the same fan-out phase, then wait for all of them before judging. A judge must not read candidate paths while their owners are still writing.
```

### template/.agents/skills/spec-review/scripts/reading-pack.sh, added, 211 lines; the diff carries it whole: no text

### template/.agents/skills/spec-review/scripts/review-brief.sh, lines 421-470 of 563

````
# The sentence over the reading pack, after Manuel's words; SKILL.md step 4 carries it word for word
# (the same test holds them together).
pack_rule='The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository only for what the pack does not carry, and then read that one function or section, not the file.'
common() {
  echo "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing."
  echo
  echo "## Commits"
  echo
  cat "$dir/log"
  echo
  echo "## Changed files"
  echo
  cat "$dir/stat"
  echo
  if [ -n "$from" ]; then
    echo "## The fix under review"
    echo
    echo "$fix_rule"
    echo
    printf '%s\n' "$fixed_items"
    echo
  fi
  if [ -n "$grounding" ]; then
    echo "## Blast radius"
    echo
    echo "$blast_rule"
    echo
    printf '%s\n' "$grounding"
    echo
  fi
  echo "## Diff"
  echo
  if [ "$(wc -l < "$dir/diff")" -lt 500 ]; then
    echo '```diff'
    cat "$dir/diff"
    echo '```'
  else
    echo "The diff is $(wc -l < "$dir/diff" | tr -d ' ') lines; read it from \`$dir/diff\`."
  fi
  echo
  cat "$dir/pack.md"
  if [ -n "$settled" ]; then
    echo "## Settled in earlier rounds"
    echo
    echo "These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."
    echo
    printf '%s\n' "$settled"
    echo
  fi
}
````

### template/.agents/skills/spec-review/scripts/review-brief.sh, lines 472-483 of 563

```
report_rules() {
  echo "## Report"
  echo
  echo "$definition"
  echo
  printf '%s\n' "${quotes[@]}"
  echo
  echo "$pack_rule"
  echo
  echo "Write the report as Markdown with exactly these \`## \` headings, in this order, each holding numbered items or nothing:"
  echo
}
```

### template/AGENTS.md, lines 71-80 of 102

```
## Pull requests

- Work that started from a ticket ends in a PR that says `Closes #N`. Work that started from a conversation ends in a commit on a branch unless you are asked to file; if it is going to end in a PR, file a quick ticket first (Ticket playbook, "Quick ticket"), so the PR closes it and the reviewers can read the ask.
- Conventional commit titles in plain language: `fix(web): new sessions no longer spike CPU`.
- Body: the problem in a sentence or two, then how you fixed it, then a **Verification** section quoting each acceptance criterion with the evidence path. End with the model and harness that did the work. A comment the agent posts on a PR or a ticket ends the same way, with "approved by <name>" added when the human approved it before posting; only an approved comment posted from the author's account is the author's words.
- UI changes need before/after images. Motion or timing needs a short video. Upload them; never commit them.
- One concern per PR. If the description says "also", split it.
- Any comment or report you write that runs longer than about forty lines opens with two plain sentences for a person, under the label `For a person:`. PR bodies are exempt: their problem-then-fix opening is that summary. Reviewers ignore body prose by design, so the label is for people, not a signal to models.
- At the first push, run `spec-review` round one in a fresh context, with CI running alongside; a green CI is required before merge-ready, not before round one. Then babysit: poll checks and comments newer than the last push, verify each bot finding against the source, fix real ones, dismiss false positives with a written reason. Stop when the bots are green on the latest commit. Fixes land on the PR that was reviewed, the chain above it is rebased and re-verified, and a finding outside its scope becomes a ticket. The review ladder is `docs/agents/review-ladder.md`.
- You never merge. Merging is the human's act.
```

### tests/eval/reviewer/refusals.sh, added, 750 lines; the diff carries it whole: no text

### tests/eval/reviewer/reviewer.py, added, 949 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr101-r1/inputs/previous.txt, empty at HEAD: no text

### tests/eval/reviewer/rounds/pr101-r1/inputs/recipe, whole, 5 lines

```
script_at=7956c6964cea8088e02ae8798102ce36b3c15cad
fixed_point=52ccd8eb509a2871260827a8514c3a1fcaac4d5d
ticket=91
round=1
pr=101
```

### tests/eval/reviewer/rounds/pr101-r1/inputs/ticket.md, added, 69 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr101-r1/review/diff, added, 503 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr101-r1/review/spec-brief.md, added, 131 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr101-r1/review/spec-report.historical.md, whole, 18 lines

```
## Walk

1. Criterion 1, the Walk rule. `review-brief.sh` defines `risk_rule` as one sentence and, in the Spec brief only, appends it to the Walk bullet on the same line: `walk='- `## Walk`: ...'` then `[ -z "$grounding" ] || walk="$walk $risk_rule"`. The bullet's own text is unchanged, so the `spec_bullets[0]` substring assertion still holds.
2. Criterion 1, the wording. The sentence is byte-identical in the script, `SKILL.md` step 4, the mattpocock patch and the test's `risk_rule` (diffed all four). It names no level and no count, so `review-comment.sh` learns nothing new.
3. Criterion 2, detection. Inside the `[ -n "$crossing" ]` block, after the empty-grounding check and before `state=.claude/state/review`, an awk over `$grounding` with the shared `fenced` fragment (CR and trailing blanks stripped, fenced lines skipped by `fence != "" { next }`) accepts the first line that is exactly `## Risks` or `### Risks`. `### Risks` never matches `/^## /`, so `fenced`'s heading rule cannot swallow it.
4. Criterion 2, the refusal. Not found: `rm -rf "$dir"`, then the message naming `$blast` when the grounding came from a file and "the PR body's Blast Radius section" otherwise, stderr, exit 1. Word for word in `SKILL.md` step 1 and the test.
5. Criterion 2, only with a grounding. `grounding` is set only inside the cross-cutting block, so a non-cross-cutting diff keeps today's `plain`/`ignored` behaviour.
6. Criterion 2, the test. One assertion per cell, named by row and column: 1A, 1B, 2A, 3A, 3B, 4A (both halves), 5A, 6A, 7A, 8A, 9A, 9B, 10. `blast.md` is left as the bullet hand-back and now drives 5A.
7. Criterion 3. `review-comment.sh` excludes the `Walk` heading in `items()`, `stepless()` and `specs()`, so the two risk lines the new `review-comment.sh` fixture inserts after step 3 leave every count and the whole comment unchanged.
8. Criterion 4. The Opening a PR bullet, in the template and in its patch, says the file's `## ` headings are demoted to `###` and why. `ticket.md` step 5 and `SOURCES.md` items 3 and 6 say the same; the CI fixture's grounding gains the heading.

## Would break

## Fails open

## Not asked for

hard findings: 0
```

### tests/eval/reviewer/rounds/pr101-r1/review/standards-brief.md, added, 111 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr101-r1/round, whole, 8 lines

```
pr=101
ticket=91
label=round: 1 of 3
fixed_point=52ccd8eb509a2871260827a8514c3a1fcaac4d5d
head=7956c6964cea8088e02ae8798102ce36b3c15cad
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/101#issuecomment-5781207159
brief_source=regenerated
```

### tests/eval/reviewer/rounds/pr102-r1/inputs/previous.txt, empty at HEAD: no text

### tests/eval/reviewer/rounds/pr102-r1/inputs/recipe, whole, 5 lines

```
script_at=7b01fd6480b3e54a78611db4aca23bf55b4726be
fixed_point=d8e382ca37233bce98724c785ecdbb677abc4e2a
ticket=93
round=1
pr=102
```

### tests/eval/reviewer/rounds/pr102-r1/inputs/ticket.md, added, 195 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r1/review/diff, added, 1153 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r1/review/spec-brief.md, added, 261 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r1/review/standards-brief.md, added, 115 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r1/round, whole, 8 lines

```
pr=102
ticket=93
label=round: 1 of 3
fixed_point=d8e382ca37233bce98724c785ecdbb677abc4e2a
head=7b01fd6480b3e54a78611db4aca23bf55b4726be
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/102#issuecomment-5783722681
brief_source=regenerated
```

### tests/eval/reviewer/rounds/pr102-r2/inputs/recipe, whole, 5 lines

```
script_at=fc75ac69712119bb0e921e348a54b4d857c41b07
fixed_point=d8e382ca37233bce98724c785ecdbb677abc4e2a
ticket=93
round=2
pr=102
```

### tests/eval/reviewer/rounds/pr102-r2/inputs/ticket.md, added, 198 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r2/review/diff, added, 1153 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r2/review/spec-brief.md, added, 265 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r2/review/standards-brief.md, added, 116 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr102-r2/review/standards-report.historical.md, whole, 33 lines

````
# Standards review report

## Would break

## Fails open

## Standards breaches

1. **The new step-4 bullet sits out of emission order.** `CODING_STANDARDS.md`, Markdown: "Written with `/writing-for-agents` when an agent reads it." Step 4's bullet list has until now run in the order the brief prints its sections (commits, changed files, blast radius, diff, settled). The new bullet is listed after `## Settled in earlier rounds`, but `common()` prints the section between the `--stat` list and `## Blast radius`. The bullet's own words carry the truth ("before the diff"), so nothing breaks; the list no longer reads as the file it describes. Move the bullet above the blast-radius one.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, under exactly this paragraph: ...
```

## Fix alongside

2. **Duplicated Code: the report-item heading lookup is written twice.** `review-comment.sh` already resolves a judgment line to its report item's heading in the `hole:` loop (lines 186-195); the new Would-break-fix loop repeats the same four steps (`ref_id` by sed, the `case` picking the file, `specs | sed -n Np`, the `at`/`want` split). → one helper, `rests <judgment line>`, called from both.

```
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
+  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
+  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
```

3. **The header comment rewraps ragged.** `review-comment.sh` lines 6-8 leave a four-word line mid-sentence where the rest of the header fills to the margin. → rewrap the paragraph when the next edit touches it.

```
+# reviewed; the next round's fixed point), the round (`of 5` from round four), then act-on items
+# counted from the judgment's Act on items
 # neither fixed on this PR (`fixed: <sha>`), filed as a ticket (`ticket: #N`) nor marked a hole,
```

hard findings: 0
````

### tests/eval/reviewer/rounds/pr102-r2/round, whole, 8 lines

```
pr=102
ticket=93
label=round: 2 of 3
fixed_point=d8e382ca37233bce98724c785ecdbb677abc4e2a
head=fc75ac69712119bb0e921e348a54b4d857c41b07
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/102#issuecomment-5783855182
brief_source=surviving
```

### tests/eval/reviewer/rounds/pr94-r1/inputs/previous.txt, empty at HEAD: no text

### tests/eval/reviewer/rounds/pr94-r1/inputs/recipe, whole, 5 lines

```
script_at=c83f166578a35e61d0b686c1ae1ed652b051dba6
fixed_point=ab47eb9
ticket=89
round=1
pr=94
```

### tests/eval/reviewer/rounds/pr94-r1/inputs/ticket.md, added, 44 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r1/review/diff, added, 572 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r1/review/spec-brief.md, added, 118 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r1/review/standards-brief.md, added, 123 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r1/round, whole, 8 lines

```
pr=94
ticket=89
label=round: 1 of 3
fixed_point=ab47eb91fa42a896c1eec054e526b615b5cbf316
head=c83f166578a35e61d0b686c1ae1ed652b051dba6
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779120191
brief_source=surviving
```

### tests/eval/reviewer/rounds/pr94-r2/inputs/previous.txt, added, 127 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r2/inputs/recipe, whole, 5 lines

```
script_at=0c63fa6f239ef930abacabe9086b3455a7313b2e
fixed_point=c83f166
ticket=89
round=2
pr=94
```

### tests/eval/reviewer/rounds/pr94-r2/inputs/ticket.md, added, 44 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r2/review/diff, added, 289 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r2/review/spec-brief.md, added, 394 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r2/review/standards-brief.md, added, 399 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r2/review/standards-report.historical.md, whole, 22 lines

````
# Standards report

The change is documentation plus one awk filter and its test. I checked the filter against the script, the new patch against its pinned upstream, and the build script's docstring against its code; the documented path holds in each.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The skipped headings are matched case-sensitively, and the repo spells the section two ways.** `to-spec/SKILL.md:59` writes the spec heading as `## Testing Decisions`; Ticket step 6 and the awk both use `## Testing decisions`. The documented path is consistent, so nothing breaks, but a body that carries the spec's spelling is not skipped, and the mismatch is invisible at the call site.

```
-  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
+  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
```

Checked and clean, so not reported: the awk alternation is POSIX ERE and drops the heading line itself, so the new fixture body yields no tokens and the expected `paths: none\nbase: origin/main` (`template/.agents/skills/poteto-mode/scripts/overlap.sh`, the empty-`paths` branch); `patches/pstack/architect/SKILL.md.patch` matches the pinned upstream exactly at line 32 (`research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md`), is listed in `patches/series` and is described in `SOURCES.md` item 14, as AGENTS.md "Vendored skills" requires; `tools/build_knowledge.py`'s new docstring line matches its code, which copies every core document except `CONVERSATION-DIGEST.md` (`build_core`, the `p.name != "CONVERSATION-DIGEST.md"` guard), so "the first five" in both manuals is the true count; `docs/knowledge/core/MANUAL.md` is 175 lines, the number the header and `INDEX.md` now carry; the generated copies under `template/docs/factory918/` and `docs/knowledge/INDEX.md` were rebuilt rather than hand-edited, and reusing the number 17 for the new case follows the file's existing convention (19, 22, 23 are each reused).

hard findings: 0
````

### tests/eval/reviewer/rounds/pr94-r2/round, whole, 8 lines

```
pr=94
ticket=89
label=round: 2 of 3
fixed_point=c83f166578a35e61d0b686c1ae1ed652b051dba6
head=0c63fa6f239ef930abacabe9086b3455a7313b2e
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779392389
brief_source=surviving
```

### tests/eval/reviewer/rounds/pr94-r3/inputs/previous.txt, added, 199 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r3/inputs/recipe, whole, 5 lines

```
script_at=715100c12a8eef8d9f2eb547769404c1f9ce7ab1
fixed_point=78be65e
ticket=89
round=3
pr=94
```

### tests/eval/reviewer/rounds/pr94-r3/inputs/ticket.md, added, 44 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r3/review/diff, added, 140 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r3/review/spec-brief.md, added, 232 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r3/review/spec-report.historical.md, whole, 24 lines

```
# Spec report

The commit only adds a rule to prose and one test case; the script's behaviour is unchanged. I walked the rule against the code that enforces it and found nothing that breaks or fails open.

## Walk

1. Ticket step 6 tells the orchestrator to append the artifact under `## Testing decisions` (or `## Design`), and now to keep the whole artifact inside that one section with its parts under `###` headings.
2. `docs/agents/issue-tracker.md:26` and its template copy state the same rule and give the reason: the overlap check skips a section up to the next `## ` heading.
3. `SCENARIO-TABLE.md` repeats it for the table's parts (legend, table, contract, test list) and records that #42's record predates the rule.
4. `template/.agents/skills/poteto-mode/scripts/overlap.sh:5-6` documents the skip as running "up to the next `## ` heading"; the code is untouched by this commit.
5. `overlap.sh:49` is the enforcement: `awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip'`. Only a line beginning `## ` (hash, hash, space) re-evaluates `skip`.
6. `### Contract` has `#` in the third position, so it does not match `^## `; `skip` stays set and the whole subsection is dropped, exactly as the three documents now claim.
7. The next `## ` heading outside the three names clears `skip`, so the rule's stated boundary is the real one.
8. With every token skipped, `paths` is empty and the script prints `go: ...` / `paths: none` / `base: origin/main` and exits 0 — the expectation the new test asserts.
9. `tests/poteto-mode/overlap.sh:151-161` quotes `src/x/y.txt` inside the `### Contract` subsection. Fixture PR #2 touches that path, so a token leaking out of the skip would give exit 1 and a `#2 feat-b:` line; the test is falsifiable, not decorative.
10. Generated copies stay in step: `template/docs/factory918/SCENARIO-TABLE.md` carries the identical sentence, the core document is still 88 lines as `docs/knowledge/INDEX.md:12` records, and the worktree is clean.

## Would break

## Fails open

## Not asked for

hard findings: 0
```

### tests/eval/reviewer/rounds/pr94-r3/review/standards-brief.md, added, 237 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr94-r3/review/standards-report.historical.md, whole, 29 lines

````
# Standards report

The change is prose plus one test fixture; the script's behavior is untouched (only its header comment moved). I checked the documented claim against the code that implements it.

## Would break

None.

## Fails open

None.

## Standards breaches

None. The core source (`docs/knowledge/core/SCENARIO-TABLE.md`) and its generated copy (`template/docs/factory918/SCENARIO-TABLE.md`) carry the same sentence, and the two `docs/agents/issue-tracker.md` copies match, so the generated-and-vendored rule in `CODING_STANDARDS.md` ("Markdown") holds.

## Fix alongside

None.

Checked, not filed: the sentence the three documents now add ("the skip ends at the next `## ` heading") is what the code does. `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` turns the skip on and off only on a line matching `/^## /`, which a `### Contract` line does not match, so a `###` part stays inside the skipped section.

```
outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
```

The new fixture proves it rather than asserting it: the `### Contract` part quotes `src/x/y.txt`, which PR 2 touches in the same fixture (test 18 prints `#2 feat-b: src/x/y.txt`), so a skip that ended at the `###` heading would make test 17 exit 1 instead of 0.

hard findings: 0
````

### tests/eval/reviewer/rounds/pr94-r3/round, whole, 8 lines

```
pr=94
ticket=89
label=round: 3 of 3
fixed_point=78be65edc94f22b257d3c220b74482c7e884806b
head=715100c12a8eef8d9f2eb547769404c1f9ce7ab1
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779823400
brief_source=surviving
```

### tests/eval/reviewer/rounds/pr96-r1/inputs/previous.txt, empty at HEAD: no text

### tests/eval/reviewer/rounds/pr96-r1/inputs/recipe, whole, 5 lines

```
script_at=69bd41230e0f62e0824403196243c013118fb302
fixed_point=ab47eb9
ticket=88
round=1
pr=96
```

### tests/eval/reviewer/rounds/pr96-r1/inputs/ticket.md, added, 58 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r1/review/diff, added, 537 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r1/review/spec-brief.md, added, 193 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r1/review/standards-brief.md, added, 184 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r1/review/standards-report.historical.md, whole, 29 lines

````
## Would break

## Fails open

1. **One argument that matches nothing is dropped, and the gate still passes.** The gate's own header makes an unmatched glob a failure; the code enforces that only when *every* argument misses. One glob out of five that names nothing (a renamed directory, a typo, or a path with a space, which splits on the unquoted `$g` and matches no file) is skipped without a word, and the run exits 0 over a smaller set. `files checked: N` is the only tell, and nothing in CI or the playbook asserts N. Standard: `CODING_STANDARDS.md`, Bash, "Quote every path. Paths here contain spaces"; and the file's own rule at `template/.github/shellcheck.sh:10-11`, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass."

Documented step: `AGENTS.md:38`, "`bash .github/shellcheck.sh factory918.sh ... 'tests/*/*.sh'`, ShellCheck at the pin over 20 files"; `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens".
Result: after a rename, the factory's CI step checks 15 files and stays green; a lane that names a changed file the gate cannot see reports the gate as passed on a file nobody linted.

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
```

## Standards breaches

## Fix alongside

2. **Duplicated Code: the factory's five globs live in two files.** `.github/workflows/factory-ci.yml:20` and `AGENTS.md:38` carry the same list; the gate holds a zero-argument default for a project but not for the factory, so the two copies drift apart on the next rename. A factory default inside the gate would leave one copy.

```yaml
run: bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
```

3. **`tests/shellcheck/gate.sh` lands mode 100644.** Every other test script is 100755, and test 7 asserts the mode bit on the gate it tests. CI invokes it through `bash`, so nothing breaks today.

hard findings: 1
````

### tests/eval/reviewer/rounds/pr96-r1/round, whole, 8 lines

```
pr=96
ticket=88
label=round: 1 of 3
fixed_point=ab47eb91fa42a896c1eec054e526b615b5cbf316
head=69bd41230e0f62e0824403196243c013118fb302
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779416046
brief_source=regenerated
```

### tests/eval/reviewer/rounds/pr96-r2/inputs/recipe, whole, 5 lines

```
script_at=01e538672e645e670dda4d9707845cc9a761019f
fixed_point=ab47eb9
ticket=88
round=2
pr=96
```

### tests/eval/reviewer/rounds/pr96-r2/inputs/ticket.md, added, 58 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r2/review/diff, added, 542 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r2/review/spec-brief.md, added, 194 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r2/review/standards-brief.md, added, 185 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r2/round, whole, 8 lines

```
pr=96
ticket=88
label=round: 2 of 3
fixed_point=ab47eb91fa42a896c1eec054e526b615b5cbf316
head=01e538672e645e670dda4d9707845cc9a761019f
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779650623
brief_source=regenerated
```

### tests/eval/reviewer/rounds/pr96-r3/inputs/previous.txt, added, 211 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r3/inputs/recipe, whole, 5 lines

```
script_at=1362b48fa2d50ab1d5989f4126d4ba729ff227ea
fixed_point=ab47eb9
ticket=88
round=3
pr=96
```

### tests/eval/reviewer/rounds/pr96-r3/inputs/ticket.md, added, 58 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r3/review/diff, added, 557 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r3/review/spec-brief.md, added, 197 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r3/review/standards-brief.md, added, 188 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr96-r3/round, whole, 8 lines

```
pr=96
ticket=88
label=round: 3 of 3
fixed_point=ab47eb91fa42a896c1eec054e526b615b5cbf316
head=1362b48fa2d50ab1d5989f4126d4ba729ff227ea
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779871731
brief_source=surviving
```

### tests/eval/reviewer/rounds/pr99-r1/inputs/previous.txt, empty at HEAD: no text

### tests/eval/reviewer/rounds/pr99-r1/inputs/recipe, whole, 5 lines

```
script_at=52ccd8eb509a2871260827a8514c3a1fcaac4d5d
fixed_point=69bd412
ticket=90
round=1
pr=99
```

### tests/eval/reviewer/rounds/pr99-r1/inputs/ticket.md, added, 127 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1/review/diff, added, 966 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1/review/spec-brief.md, added, 186 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1/review/standards-brief.md, added, 108 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1/review/standards-report.historical.md, whole, 29 lines

````
## Would break

1. **A judgment reason that says "hole:" is read as a `hole:` field.** `fixed:` and `ticket:` are detected `$`-anchored, so those words are safe in prose; `holed()` instead greps `hole:` anywhere on the line, then refuses every match that does not end in a reference. An unmarked item whose one-line reason uses the term this change introduces ("Not a design hole: the table stands.") is refused as a malformed mark under Act on, and as a misplaced mark under Ask, Consider, Noted or Dismissed. The refusal names a field the item does not carry, so it does not say how to correct it.
Documented step: ticket #90, table B, row 1 column A, "as today; counted / 0 / fix on the PR, unchanged"; the contract reads "the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`".
Result: `review-comment.sh` exits 1 with "has a 'hole:' field that fits no form" (or "carries a 'hole:' field under '## Noted'"), clears nothing, and the round's comment cannot be built until the reason is reworded.
spec: table 1/A

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
# holed <heading>: the judgment items under the heading whose line carries a `hole:` field.
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

## Fails open

## Standards breaches

## Fix alongside

2. **Three globals reused inside the hole loop.** `want` held the expected `[S<n>]`/`[P<n>]` set twenty lines up, and `f` and `at` are new globals in a file whose other helpers declare `local`. Names of their own would keep the reader from carrying two meanings of `want`.

```sh
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

3. **The human's merge checklist still reads the count alone.** `docs/knowledge/core/MANUAL.md:103` says a PR is ready when "`spec-review`'s last line on the latest commit reads `act-on items: 0`"; a comment whose only Act on items are holes prints `restart` and `act-on items: 0`. The ticket's Files touched leaves `MANUAL.md` to the owner, so this is noted, not asked for.

hard findings: 1
````

### tests/eval/reviewer/rounds/pr99-r1/round, whole, 8 lines

```
pr=99
ticket=90
label=restart round: 1 of 3
fixed_point=69bd41230e0f62e0824403196243c013118fb302
head=52ccd8eb509a2871260827a8514c3a1fcaac4d5d
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/99#issuecomment-5780539782
brief_source=regenerated
```

### tests/eval/reviewer/rounds/pr99-r1b/inputs/recipe, whole, 5 lines

```
script_at=32978fa675e82300bbed01b323011da49d135b0e
fixed_point=69bd412
ticket=90
round=1
pr=99
```

### tests/eval/reviewer/rounds/pr99-r1b/inputs/ticket.md, added, 131 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1b/review/diff, added, 1080 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1b/review/spec-brief.md, added, 193 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1b/review/standards-brief.md, added, 111 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r1b/round, whole, 8 lines

```
pr=99
ticket=90
label=round: 1 of 3
fixed_point=69bd41230e0f62e0824403196243c013118fb302
head=32978fa675e82300bbed01b323011da49d135b0e
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/99#issuecomment-5781120649
brief_source=regenerated
```

### tests/eval/reviewer/rounds/pr99-r2/inputs/previous.txt, added, 182 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r2/inputs/recipe, whole, 5 lines

```
script_at=384bb43a872c1bca7b63a27aab2590ac37d46fae
fixed_point=69bd412
ticket=90
round=2
pr=99
```

### tests/eval/reviewer/rounds/pr99-r2/inputs/ticket.md, added, 131 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r2/review/diff, added, 1174 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r2/review/spec-brief.md, added, 202 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r2/review/standards-brief.md, added, 120 lines; the diff carries it whole: no text

### tests/eval/reviewer/rounds/pr99-r2/round, whole, 8 lines

```
pr=99
ticket=90
label=round: 2 of 3
fixed_point=69bd41230e0f62e0824403196243c013118fb302
head=384bb43a872c1bca7b63a27aab2590ac37d46fae
head_source=recorded
comment=https://github.com/Zenoctra/factory918/pull/99#issuecomment-5781309601
brief_source=surviving
```

### tests/spec-review/no-stale-wording.sh, whole, 17 lines

```
#!/usr/bin/env bash
# Greps template/ and docs/knowledge/core/ for retired wording, so a rename that leaves the old
# words behind fails here: #81's `## Latent` heading and the definition sentence that began "A hard
# finding is wrong behavior in normal use", #90's "Three trailing fields", the judgment's field
# count before `hole:`, and #93's "at most three rounds", the cap before a Would-break fix earned
# a fourth and fifth, #105's "table unchanged", the reason a later round once gave for skipping
# the Spec axis, and #106's "From round four on both briefs carry", from before round three could
# be fix-only. Prints each hit as file:line and exits 1 on any; prints `ok: no stale wording`
# otherwise.
set -euo pipefail
cd "$(dirname "$0")/../.."
hits="$(grep -rnF -e '## Latent' -e 'A hard finding is wrong behavior in normal use' -e 'Three trailing fields' -e 'at most three rounds' -e 'table unchanged' -e 'From round four on both briefs carry' template docs/knowledge/core | cut -d: -f1,2 || true)"
if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  exit 1
fi
echo "ok: no stale wording"
```

### tests/spec-review/review-brief.sh, lines 374-386 of 1765

```
# Ticket #110, row 5: a Provisional id is P<ticket> with an optional b-z sibling letter, and a cite of
# either carries; an off-form id is dropped.
for id in P110 P110b; do
  sed "s/DECISIONS.md P17\$/DECISIONS.md $id/" previous.md > "previous-$id.md"
  bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous "previous-$id.md" --round 2 > out.txt
  has out.txt "settled: carried 2, dropped 1 without a citation" "cites: DECISIONS.md $id is counted as carried (5A, 5B)"
  has "$std" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md $id" "cites: DECISIONS.md $id carries (5A, 5B)"
done
sed 's/DECISIONS.md P17$/DECISIONS.md P-110/' previous.md > previous-P-110.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous-P-110.md --round 2 > out.txt
has out.txt "settled: carried 1, dropped 2 without a citation" "cites: DECISIONS.md P-110 is counted as dropped (5C)"
lacks "$std" "cites: DECISIONS.md P-110" "cites: DECISIONS.md P-110 does not carry (5C)"

```

### tests/spec-review/review-brief.sh, lines 808-820 of 1765

```
# 13B: --round 2 after the restart, from the PR and from the --previous file: round two of the
# redesign, the whole diff.
pr me me:previous.md me:previous-2.md me:previous-3w.md me:restart-4.md
for src in pr both-3w.md; do
  if [ "$src" = pr ]; then prev=(); else prev=(--previous "$src"); fi
  bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 ${prev[@]+"${prev[@]}"} --round 2 > out.txt
  printed out.txt "ticket: #7
$restart_line
round: 2 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "--round 2 after a restart that followed (3W), from $src (13B)"
  lacks "$std" "## The fix under review" "--round 2 after a restart, from $src: no fix section (13B)"
done
```

### tests/spec-review/review-brief.sh, lines 1299-1304 of 1765

```
# #106: the owed line's sentence, byte-identical in both babysit copies, and step 1's fix-only round three.
babysit_owed='A round-one or round-two comment carrying the line `next round owed: round <N> reviews the fixes marked here` is not review-ready whatever its count: the orchestrator runs that round (`spec-review` step 1); the lines `reviewed: <sha>` and `fix only after <sha>` only record where the next round starts and change nothing here.'
has "$here/template/.agents/skills/poteto-mode/playbooks/babysit.md" "$babysit_owed" "the babysit playbook carries the owed sentence (#106)"
has "$here/template/.agents/skills/babysit/SKILL.md" "$babysit_owed" "the babysit skill carries the owed sentence (#106)"
has "$source_skill/SKILL.md" 'Round three is fix-only too when round two'"'"'s comment carries `fix only after <sha>`' "SKILL.md step 1 says round three is fix-only after the line (#106)"

```

### tests/spec-review/review-comment.sh, lines 183-191 of 1338

```
## Dismissed

Standards: 0 would break, 0 fail open, of 0; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "nothing found, no spec, no round file"

reset
cat > "$dir/standards-report.md" <<'EOF'
```

### tests/spec-review/review-comment.sh, lines 271-277 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 2 of 3
act-on items: 3" "two Act on and one Ask, round 2; the walk's three lines are not items (#106 3C: hard items, no fix lines)"
```

### tests/spec-review/review-comment.sh, lines 291-301 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 2 of 3
act-on items: 3" "the walk continued with two risk lines: the same counts (#91, criterion 3; #106 3C)"

rearm
echo 3 > "$dir/round"
cat > "$dir/judgment.md" <<'EOF'
```

### tests/spec-review/review-comment.sh, lines 427-435 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 2; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "Dismissed only"

```

### tests/spec-review/review-comment.sh, lines 447-456 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "rerun with the dir argument after the state was cleared" "$dir"
accept "$out" "the same with a trailing slash on the dir" "$dir/"

```

### tests/spec-review/review-comment.sh, lines 469-483 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 1, consider 0, noted 0, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "an Ask item, counted" "$dir"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n2. [S2] **Middle Man.** one caller, kept inline\n1. [S1] **Mysterious Name.** the human says the name is the domain term. cites: #7 comment 2026-09-18\n' > "$dir/judgment.md"
refuse "$dir/judgment.md item '2. [S2] **Middle Man.** one caller, kept inline' is numbered 2 where 1 was expected; number the items 1..N continuously across the headings, in document order" "an Ask item moved without renumbering" "$dir"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n1. [S2] **Middle Man.** one caller, kept inline\n2. [S1] **Mysterious Name.** the human says the name is the domain term. cites: #7 comment 2026-09-18\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

```

### tests/spec-review/review-comment.sh, lines 488-496 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 2; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "an Ask item moved and renumbered, the same round" "$dir"

```

### tests/spec-review/review-comment.sh, lines 511-520 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "rerun with the dir spelled $spelling" "$spelling"
done

```

### tests/spec-review/review-comment.sh, lines 527-547 of 1338

```
fenced_twin() {
  reset
  printf '## Would break\n\n1. **One.** a\nDocumented step: t\nspec: criterion 1\n\n%s\n\n## Fails open\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\n3. **Three.** c\n\nhard findings: 1\n' "$2" > "$dir/standards-report.md"
  printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S3] **Three.** later\n\n## Dismissed\n\n3. [S2] **Two.** no\n' > "$dir/judgment.md"
  accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "$1"
}
```

### tests/spec-review/review-comment.sh, lines 586-594 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 0; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "headings with trailing whitespace"

```

### tests/spec-review/review-comment.sh, lines 628-640 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 1; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "a counted item with no spec line in a review with no spec, counted (7A)"
rearm
for mark in 'hole: table 2/D' 'hole: table 2'; do
  printf '## Act on\n\n1. [S1] **One.** yes %s\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' "$mark" > "$dir/judgment.md"
  refuse "$dir/judgment.md item '1. [S1] **One.**' carries a 'hole:' field, but this review has no spec ($dir/spec-brief.md is missing): a hole names an artifact on the ticket the work was built against, and this review has none. Fix the finding on this PR, or rerun scripts/review-brief.sh <fixed-point> --ticket N and judge again" "an Act on item marked '$mark' in a review with no spec (7D)"
done
```

### tests/spec-review/review-comment.sh, lines 651-661 of 1338

```
## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 1; Spec: no spec; judged: act on 1 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 0" "a Would-break item fixed in a review with no spec carries the line (3F)"

```

### tests/spec-review/review-comment.sh, lines 719-745 of 1338

```
# above: the comment above its summary line, from the fixture files.
above() { printf '## Standards\n\n%s\n\n## Spec\n\n%s\n\n## Judgment\n\n%s' "$(cat "$dir/standards-report.md")" "$(cat "$dir/spec-report.md")" "$(cat "$dir/judgment.md")"; }
judged "" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 2" "counted items with spec lines and no mark, the walk's spec and hole text invisible (1A, row 6)"
rearm
judged " fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 1" "a counted item with a spec line, fixed (1B; #93 3A: S1 is a Would-break item)"
rearm
judged "" " ticket: #12" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 1 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "a counted item with a spec line, ticketed (1C)"
```

### tests/spec-review/review-comment.sh, lines 765-777 of 1338

```
# Only the field that ends the line is a field: a `hole:` before a trailing `fixed:` is text, and
# the fixed Would-break item puts the line in the comment (#93, table B, 4A).
rearm
judged " hole: table 2/D fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 1" "a hole before a trailing fixed field counts as fixed"
rearm
```

Not carried, over the pack's 65536 bytes: .github/workflows/factory-ci.yml whole; AGENTS.md whole; SOURCES.md lines 15-18; SOURCES.md lines 21-29; docs/M0-findings.md lines 174-200; docs/M0-findings.md lines 204-220; docs/agents/issue-tracker.md whole; docs/agents/ledger.md lines 30-37; docs/knowledge/INDEX.md lines 1-29; docs/knowledge/core/DECISIONS.md lines 66-78; docs/knowledge/core/DECISIONS.md lines 89-89; docs/knowledge/core/DECISIONS.md lines 98-104; docs/knowledge/core/MANUAL.md lines 87-108; patches/mattpocock/spec-review.SKILL.md.patch lines 19-21; patches/mattpocock/spec-review.SKILL.md.patch lines 25-81; patches/mattpocock/spec-review.SKILL.md.patch lines 131-137; patches/pstack/poteto-mode/playbooks/autopilot-full.md.patch lines 1-14; patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch lines 1-22; patches/pstack/poteto-mode/playbooks/babysit.md.patch lines 1-12; patches/pstack/poteto-mode/playbooks/bug-fix.md.patch whole; patches/pstack/poteto-mode/playbooks/feature.md.patch whole; patches/pstack/poteto-mode/playbooks/hillclimb.md.patch whole; patches/pstack/poteto-mode/playbooks/multi-phase-plan.md.patch whole; patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch whole; patches/pstack/poteto-mode/playbooks/orchestrate.md.patch whole; patches/pstack/poteto-mode/playbooks/perf-issue.md.patch whole; patches/pstack/poteto-mode/playbooks/refactoring.md.patch whole; patches/pstack/poteto-mode/playbooks/session-pickup.md.patch whole; patches/pstack/poteto-mode/playbooks/worktree-cleanup.md.patch whole; patches/pstack/poteto-mode/references/provider-dispatch.md.patch whole; template/.agents/skills/babysit/SKILL.md whole; template/.agents/skills/poteto-mode/playbooks/autopilot-full.md lines 5-9; template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md lines 4-11; template/.agents/skills/poteto-mode/playbooks/babysit.md lines 13-18; template/.agents/skills/poteto-mode/playbooks/bug-fix.md whole; template/.agents/skills/poteto-mode/playbooks/eval.md whole; template/.agents/skills/poteto-mode/playbooks/feature.md whole; template/.agents/skills/poteto-mode/playbooks/hillclimb.md whole; template/.agents/skills/poteto-mode/playbooks/multi-phase-plan.md lines 2-12; template/.agents/skills/poteto-mode/playbooks/multi-phase-plan.md lines 52-84; template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md whole; template/.agents/skills/poteto-mode/playbooks/orchestrate.md lines 15-21; template/.agents/skills/poteto-mode/playbooks/perf-issue.md whole; template/.agents/skills/poteto-mode/playbooks/refactoring.md whole; template/.agents/skills/poteto-mode/playbooks/session-pickup.md whole; template/.agents/skills/poteto-mode/playbooks/ticket.md lines 1-23; template/.agents/skills/poteto-mode/playbooks/ticket.md lines 44-53; template/.agents/skills/poteto-mode/playbooks/worktree-cleanup.md whole; template/.agents/skills/spec-review/SKILL.md lines 24-26; template/.agents/skills/spec-review/SKILL.md lines 69-94; template/.agents/skills/spec-review/SKILL.md lines 143-152; template/.agents/skills/spec-review/scripts/review-brief.sh lines 1-61; template/.agents/skills/spec-review/scripts/review-brief.sh lines 185-267; template/.agents/skills/spec-review/scripts/review-brief.sh lines 271-385; template/.agents/skills/spec-review/scripts/review-comment.sh lines 1-44; template/.agents/skills/spec-review/scripts/review-comment.sh lines 208-318; template/docs/agents/issue-tracker.md whole; template/docs/agents/review-ladder.md whole; template/docs/factory918/DECISIONS.md lines 58-70; template/docs/factory918/DECISIONS.md lines 81-81; template/docs/factory918/DECISIONS.md lines 90-96; template/docs/factory918/MANUAL.md lines 68-89; tests/eval/reviewer/labels whole; tests/eval/reviewer/rebuild.sh whole; tests/eval/reviewer/rounds/pr101-r1/review/standards-report.historical.md whole; tests/eval/reviewer/rounds/pr102-r1/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr102-r1/review/standards-report.historical.md whole; tests/eval/reviewer/rounds/pr102-r2/inputs/previous.txt whole; tests/eval/reviewer/rounds/pr102-r2/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr94-r1/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr94-r1/review/standards-report.historical.md whole; tests/eval/reviewer/rounds/pr94-r2/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr96-r1/inputs/blast-radius.md whole; tests/eval/reviewer/rounds/pr96-r1/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr96-r2/inputs/blast-radius.md whole; tests/eval/reviewer/rounds/pr96-r2/inputs/previous.txt whole; tests/eval/reviewer/rounds/pr96-r2/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr96-r2/review/standards-report.historical.md whole; tests/eval/reviewer/rounds/pr96-r3/inputs/blast-radius.md whole; tests/eval/reviewer/rounds/pr96-r3/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr96-r3/review/standards-report.historical.md whole; tests/eval/reviewer/rounds/pr99-r1/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr99-r1b/inputs/previous.txt whole; tests/eval/reviewer/rounds/pr99-r1b/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr99-r1b/review/standards-report.historical.md whole; tests/eval/reviewer/rounds/pr99-r2/review/spec-report.historical.md whole; tests/eval/reviewer/rounds/pr99-r2/review/standards-report.historical.md whole; tests/knowledge/provisional-ids.sh whole; tests/spec-review/review-brief.sh lines 1-44; tests/spec-review/review-brief.sh lines 84-147; tests/spec-review/review-brief.sh lines 879-1294; tests/spec-review/review-brief.sh lines 1451-1765; tests/spec-review/review-comment.sh lines 1-38; tests/spec-review/review-comment.sh lines 784-832; tests/spec-review/review-comment.sh lines 909-949; tests/spec-review/review-comment.sh lines 967-1338; tools/check_knowledge.py whole. Read these at HEAD from the repository.

