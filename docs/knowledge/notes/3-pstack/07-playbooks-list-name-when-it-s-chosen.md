<!-- lines: 36 | source: notes/3-pstack.md | part 7/11 | title: Research note: pstack — Playbooks list (name + when it's chosen) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Playbooks list (name + when it's chosen)

## Playbooks list (name + when it's chosen)

From `skills/poteto-mode/SKILL.md` (lines 112–140) and the files in `skills/poteto-mode/playbooks/`:

1. **Investigation** — read-only: "how does X work, why was Y built this way, are we sure about Z, should we do X or Y." No PR.
2. **Bug fix** — "A reported defect to reproduce, root-cause, and fix with runtime evidence." Reproduce yourself first; binary-search the cause; failing repro lands before the fix in history.
3. **Perf issue** — "A measured slowness to trace and improve against a baseline." Eight strategy families (elimination, divide and conquer, caching, indirection, batching, redundancy, lazy evaluation, scheduling) as hypothesis generators.
4. **Hillclimb** — "Sustained, scientific improvement of one metric against a target ... one commit per accepted win." Frozen harness, decision.tsv, "a plateau means pivot, not stop".
5. **Runtime forensics** — "Diagnose a runtime symptom (leak, idle-CPU spin, glitch) from live instrumentation. The deliverable is a diagnosis, not a fix."
6. **Trace forensics** — a dropped `.cpuprofile`, trace, spindump or heap snapshot; "the artifact is a fixed dataset, read it, don't re-run it."
7. **Feature** — "New or changed behavior, built from a named data shape."
8. **Refactoring** — "A behavior-preserving change to structure or shape (rename, extract, inline, dedupe, move)." Pin behavior first; "If the diff does not lower reader load somewhere, revert it."
9. **Prototype** — throwaway sketch to settle a design or "an empirical fork by observing it instead of asking the human"; "The one playbook where the Laziness Protocol's 'smallest change' and the verification bar invert."
10. **Visual parity** — "Pixel-exact UI equivalence"; image diff, baseline is the spec, "/loop per component until the diff is zero."
11. **Authoring or modifying a skill** — writing/editing a SKILL.md via Cursor's `create-skill`; "prose earns its keep by changing a decision."
12. **Eval** — blinded test of a skill/prompt change; "No `eval`, `test`, `judge` ... in any directory, file, or prompt the candidate sees."
13. **Babysit** — "Driving a PR or a stack to merge-ready: conflicts, review threads, CI." Modes `drive` / `background` / `threads-only` / `check`. Never merges.
14. **Shipping** — "Independently verifying a green stack, then landing the contiguous verified run bottom-up".
15. **Autonomous run** — "run until done", "/loop until X"; predicate first.
16. **Orchestrate** — "A standing project handed to one coordinator chat: multi-day, many stacked PRs, dozens to hundreds of subagents". Explicitly not for anything one agent could finish in a session.
17. **Autopilot-full** — "A queue of independent PRs run to merged with full autonomy: one owner per PR ... the root swarm-verifies each merge-ready head before its owner merges".
18. **Autopilot-stack** — same owner loop, "delivered as one linear reviewed base-branch stack the operator lands herself".
19. **Session pickup** — resuming a prior agent's work from a transcript, cloud-agent URL, or pushed branch.
20. **Pause safely** — explicit pause / going offline / imminent context compaction; `wip:` commit plus a resume note.
21. **Multi-phase or multi-PR plan** — "The plan is the deliverable. Do not implement." Validated by `check-plan.mjs`; mandates ten live verification lanes per PR.
22. **Worktree and simulator cleanup** — "what's using my disk"; audit script, human gate on uncommitted work.
23. **Opening a PR** — "Invoked at the end of every other playbook."

Routing rules that sit above the list: large/cross-cutting work or "work the user steps away from to trust later" → `figure-it-out` "even when a narrower playbook like Feature fits"; standing programs → Orchestrate; any PR-status phrasing ("check on PR X") → Babysit, never Cursor's built-in; "land"/"ship" → Shipping.

---
