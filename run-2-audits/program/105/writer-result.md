# Writer result, ticket #105

Branch `wt/105-writer` in worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-acb9c482825f3c72c`, from origin/main 86d156a. Head `982b125388167a7bb4fc4270c66a24a53bea6988`. Not pushed.

## Commits, in order

1. `5c9f4c4` Open the Ticket playbook with a digest and the poll rule (ticket.md only; ours, no patch).
2. `ae1b4b5` Point every lane launch at the poll rule and fold the run's other lessons into the playbooks (19 vendored playbooks, their patches, 10 new patch files appended to `patches/series`, SOURCES.md item 16).
3. `156aae3` Retire "table unchanged" and list the stale-wording test under Verifying (tests/spec-review/no-stale-wording.sh, AGENTS.md).
4. `982b125` Record the notification and conflicted-PR findings from the stack run (docs/M0-findings.md).

## Per criterion (paths under template/.agents/skills/poteto-mode/playbooks/ unless stated)

1. Digest: ticket.md:5-10 (step 0, bullets 6-10; steps 1-9 keep their numbers). `grep -c "replaces the body" ticket.md` = 2.
2. autopilot-stack.md:5 (step 1: invoke poteto-mode, read the digest, poll own lanes; "Owners parallelize" replaced by "Owners start one at a time (step 6)"). :10 (step 6: one at a time from the settled tip; never rewrites a branch another open PR branched from unless the same step rebases that PR and every PR above it; root retargets through trunk until #100, owners never retarget). :11 (step 7: rebase first, verify after; STACK-READY one page under `## Head`, `## Criteria`, `## Review`, `## CI`, `## Flags`). :8 (step 4 points at step 7's shape).
3. Act-on list, #108 named: feature.md:12, bug-fix.md:9, refactoring.md:11, perf-issue.md:16.
4. Poll rule stated once at ticket.md:6; pointers: feature.md:12, bug-fix.md:9 and :15, refactoring.md:11, perf-issue.md:16, autopilot-stack.md:5 and :8, autopilot-full.md:6 and :8, hillclimb.md:12, shipping.md:8, multi-phase-plan.md:7 and :68, orchestrate.md:18, eval.md:22 and :23, visual-parity.md:7, runtime-forensics.md:6, trace-forensics.md:7, session-pickup.md:7, worktree-cleanup.md:7, autonomous-run.md:6. M0 line: docs/M0-findings.md:189.
5. M0: docs/M0-findings.md:189 (notification) and :191 (Actions runs nothing on a conflicted PR). The `Closes #N` default-branch fact was already recorded at :187 and in the 2026-09-17 block; the "closes word beside any ticket number" half has no line because I found no evidence of it in the repo or postmortem to cite.
6. Round one at first push, green CI before merge-ready and STACK-READY: opening-a-pr.md:9, ticket.md:17 (step 8).
7. `gh run watch` or Monitor, no sleep loop: babysit.md:14, ticket.md:17. `grep -rn "sleep 60" .../playbooks/` prints nothing.
8. ticket.md:14 (step 5: blast radius from the design and table, beside the writer; step 8 checks it) and ticket.md:17 (step 8 check against the final diff).
9. tests/spec-review/no-stale-wording.sh:2-7 and :11 ("table unchanged" added, #105 in the header). Grep of template/ for "table unchanged", "skip the Spec", "Standards only" finds only spec-review/SKILL.md:109, the legitimate no-spec case. opening-a-pr.md:9 adds that a round with a ticket runs both axes.
10. Sync clean; every patch regenerates byte for byte (see Verification).
11. Trail review: ticket.md:18 (step 9), naming show-me-your-work's "Cross-model review of the trail".
12. ShellCheck: opening-a-pr.md:9 names files as arguments and states the default globs from .github/shellcheck.sh:37.
13. AGENTS.md:44.
14. Path CI takes: feature.md:13, bug-fix.md:10.
15. Registry `date`: autopilot-stack.md:6 (step 2).
16. Closed ticket's design record: ticket.md:49-51 (new section at the end).

## Verification (all at 982b125)

- `./factory918.sh sync`: no FAILED line; `git status --porcelain` printed nothing.
- Regenerated all 19 playbook patches with the README's `diff -u --label` command (script at the scratchpad `regen.sh`); `git diff --exit-code` clean.
- `bash tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`. With "table unchanged" appended to ticket.md it exits 1 and prints `template/.agents/skills/poteto-mode/playbooks/ticket.md:52`; reverted, status clean.
- `grep -rn "sleep 60" template/.agents/skills/poteto-mode/playbooks/`: no output. `grep -c "replaces the body" ticket.md`: 2.
- AGENTS.md full ShellCheck line: `ShellCheck 0.11.0, files checked: 20`, no findings.
- `bash tests/shellcheck/gate.sh`: ok 17. `bash tests/hooks/delegation.sh`: ok 55. `bash tests/spec-review/review-brief.sh`: ok 648. `bash tests/spec-review/review-comment.sh`: ok 192. `bash tests/poteto-mode/overlap.sh`: ok 57.
- `python3 tools/check_knowledge.py`: knowledge ok, 119 files. `python3 tools/build_knowledge.py` then `git status --porcelain`: empty.
- Fixture flow (vp create / apply / vp check) not run; nothing it exercises changed.

## Act-on list for the owner

1. SOURCES.md was outside the brief's "only if a new patch is needed" gate in spirit only: ten new patches were needed, so item 16 describes them and the edits to the existing patches in one entry. Check it reads right.
2. Poll-rule pointers went into ten playbooks beyond the eight named, so ten new patch files. That is the literal reading of "every playbook step that launches a lane". Not pointed: opening-a-pr.md (it runs spec-review and interrogate, which launch their own lanes inside those skills), and the skills themselves (swarm, arena, architect, spec-review, interrogate), which are outside scope. Report, not edited.
3. Root exception, my choice: the poll rule says only the root session may end its turn on a `/loop` wake, because autopilot roots and the Orchestrate coordinator are woken by notifications by design. Pointers at root-launched steps (autopilot-stack step 4, autopilot-full step 4) still name the rule.
4. Step 6's rewrite rule keeps the criterion's words and adds "unless the same step rebases that PR and every PR above it onto the result", from the run-1 lesson ("chain once at the end, or rebase the children in the same step"). Without it, step 7's bottom-to-top drift rebase would contradict step 6.
5. The STACK-READY shape sits in step 7, per the criterion, and step 4 points at it. The headings are my choice.
6. Digest location, my choice: step 0 as a numbered item before step 1. Under autopilot-stack the brief carries it; otherwise the agent writes `.scratch/<N>/digest.md`.
7. Contradicting "after CI is green" wording outside the playbooks, not edited: `template/AGENTS.md:79`, `template/docs/agents/review-ladder.md:6`, `docs/knowledge/core/MANUAL.md:94`, and the repo's own `AGENTS.md:56` ("After CI is green, `spec-review` in a fresh context"). All four contradict criterion 6 and want a follow-up ticket or an owner call on scope.
8. The closed-record policy names a `## Records` section in the PR body, which Opening a PR's section list does not have. I left Opening a PR alone. The Ticket playbook is the only place that names it.
9. The autopilot-full owner now "reads the digest (Ticket step 0) first", even though Autopilot-full units need not be tickets. The digest step lets a non-stack agent write it. Cut that clause if the owner wants autopilot-full untouched apart from the poll pointer.
