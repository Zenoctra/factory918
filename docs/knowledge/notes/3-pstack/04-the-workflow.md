<!-- lines: 54 | source: notes/3-pstack.md | part 4/11 | title: Research note: pstack — The workflow -->

## Contents (line numbers are for the Read tool's offset)
- L6: The workflow

## The workflow

```
 you: "/poteto-mode <goal + how you'll know it's done>"
   │
   ▼
 poteto-mode (router; sticky across turns)
   ├─ todo #1: read the Principles index in full
   ├─ match task → ONE playbook; copy its steps verbatim into the todo list
   │     (skipped step stays listed as `skip: <reason>`)
   ├─ large / cross-cutting / "trust it when i'm back" → figure-it-out designs a bespoke playbook
   └─ standing multi-day program → Orchestrate
   │
   ▼
 UNDERSTAND   how (+ why for history)            ← read-only explorers on cheap model
   │
   ▼
 DESIGN       name the data shape (model-the-domain)
              crosses a function boundary? → architect → arena (N runners, cross-judge, graft)
              throughput checkpoint (what blocks, what parallelizes, what state is shared)
   │
   ▼
 BUILD        delegate to subagent (poteto-agent, explicit model per role), review its diff yourself
              tdd when a cheap failing test exists; typescript-best-practices auto-loads on .ts
   │
   ▼
 VERIFY       prove-it-works on the real surface (control-ui / control-cli / verify-<app> skill)
              blast-radius for scary small diffs; swarm to fan verification lanes out
   │
   ▼
 REVIEW/CLEAN interrogate (multi-model adversarial) if contested
              /deslop diff → /no-comments (Comment Sicko) → technical-writing + unslop on prose
   │
   ▼
 SHIP         Opening a PR (worktree, small ordered commits, Conventional Commits, evidence in body)
              Babysit (conflicts → threads → CI, stops at merge-ready)  →  Shipping (independent
              per-PR verdict, land only the contiguous verified run from the bottom)
   │
   ▼
 REPLY        short declarative sentences, principle citations tied to decisions, framed for the
              consumer and the maintainer; show-me-your-work trail + cross-model "Attention" section
              for unattended runs
```

Where the human sits: at the front (goal + finish condition), at the back (auditing evidence, decision log, PR), and at hard gates only. Per the Autonomy section: "Just do it. Use any MCP tool. Reversible work and external actions ... proceed without asking. Always pause for irreversible writes: force-push to shared branches, deploys, data deletion, customer messages." (`skills/poteto-mode/SKILL.md`, lines 79–81). Even design forks are not the human's to answer if an experiment can settle them: "If the answer is a fact you could observe by running something ... it is not the human's to answer. Sketch it via the Prototype playbook" (line 20). Babysit "never merges, even with everything green, because merging is a different decision" (`docs/guide/06-verify-and-ship.md`). The one explicit "stop and show me" is opt-in: "/architect with checkpoint" (`skills/architect/SKILL.md`, Phase C).

Sources: `skills/poteto-mode/SKILL.md`; `docs/guide/02-poteto-mode.md` (mermaid of the router); `docs/guide/07-overnight.md` (loop diagram).

---
