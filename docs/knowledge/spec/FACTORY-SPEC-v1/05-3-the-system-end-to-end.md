<!-- lines: 25 | source: spec/FACTORY-SPEC-v1.md | part 5/14 | title: The Factory spec, v1 (superseded) — 3. The system, end to end -->

## Contents (line numbers are for the Read tool's offset)
- L6: 3. The system, end to end

## 3. The system, end to end

```
 PLANNING (Matt)                      GITHUB                EXECUTION (pstack, per ticket)               GATES (deterministic)          MERGE
 ─────────────────────────────        ───────               ────────────────────────────────────────     ───────────────────────────    ─────
 /wayfinder (big, foggy)   ─┐                               /poteto-mode "#42"                           on write:  vp fmt (hook)
 /grill-with-docs (a feature)├─► /to-spec ──► /to-tickets ─► Ticket playbook:                           on commit: vp staged → vp fmt   human
   writes CONTEXT.md + ADRs │        (issue, ready-for-agent)  read issue → blockers closed? →           on PR:     CI check+test,      merges
   (human answers, agent     │        tickets w/ Blocked by     falsifiability pass → how/why →            size label, spec-review,       (never
   finds facts)              ┘                                 Feature|Bug fix|Refactor playbook →          bot triage if a bot exists    the agent)
                                                               tdd at the spec's seams → verify-<app> →   interrogate if contested
                                                               Opening a PR ("Closes #42") → Babysit
 mode hook: planning                                          mode hook: execute (reminder every turn)
```

Where the human is: answering grilling questions and approving the ticket breakdown (planning); choosing which ticket next; answering the falsifiability notes the Ticket playbook raises; approving anything irreversible; reading the PR's conversation and Verification section; merging.

**Phase separation is enforced by a hook, not by hope** (§7.4): a `UserPromptSubmit` hook detects planning commands, records the phase in a state file, and prints a one-line reminder every turn. In planning mode the reminder says poteto-mode does not apply; in execute mode it repeats pstack's own sticky reminder. This is the Claude Code analog of Cursor's `mode: true` / `reminder:` and is stronger than the ports' SessionStart-only mandate, which fires three times per session (startup, clear, compact) **[primary: Claude Code hooks reference; open-pstack hooks.json]**.

---
