# Sources

Upstream pins for everything vendored into `template/`. Pinned copies of each upstream live in `research/` (re-vendor from there); `factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.

| Source | Pin | Taken | License |
|---|---|---|---|
| github.com/ericlitman/open-pstack (copy: `research/3-pstack/open-pstack-claude-code-port/`) | v1.3.0 (2026-09-03; upstream pstack 0.14.7) | `plugins/pstack/skills/*` (51 dirs; `no-comments` excluded by decision 4), `plugins/pstack/agents/*` except `comment-sicko.md`; the session mandate is ours (raw material: `hooks/session-start-context.md`) | MIT |
| github.com/mattpocock/skills (copy: `research/1-matt-pocock/skills-repo/`) | 6654f6b (2026-08-24; v1.2.3) | grilling, grill-me, grill-with-docs, domain-modeling, to-spec, to-tickets, wayfinder, research, prototype, setup-matt-pocock-skills, writing-for-agents, wizard, wait-what, code-review (→ spec-review); setup templates issue-tracker-github.md, domain.md, triage-labels.md; diagnosing-bugs Phase 1 ladder (quoted in docs/agents/feedback-loops.md) | MIT |
| github.com/pingdotgg/t3code (excerpts: `research/2-theo-t3code-excerpts/`) | f559fe0b (2026-09-04) | `.github/workflows/pr-size.yml` verbatim; the shape of `ci.yml`, `vite.config.ts`, `.vite-hooks/pre-commit`, the custom-rule pattern, the AGENTS.md structure | MIT |

## Patches (unified diffs in `patches/`, applied in the order `patches/series` lists; the list below says what each one does)

1. Namespace: `pstack:<name>` → `<name>` in all vendored pstack markdown and the session mandate; mandate gains a PHASES block. The sweep also covers `*.ts` under `poteto-mode/scripts/`, where `model-matrix.test.ts` asserts the `<!-- models:begin -->` markers that `setup-pstack/SKILL.md` writes.
2. Router: Ticket playbook line added before "Opening a PR" in `poteto-mode/SKILL.md`; `playbooks/ticket.md` added.
3. `playbooks/opening-a-pr.md`: "Run `/no-comments` before review." replaced by keep-comments + spec-review + review-ladder; the subagent sentence drops `/no-comments`.
4. `playbooks/babysit.md`: step 8 made conditional on an external bot being listed in `docs/agents/review-ladder.md`; step 6 adds `act-on items: 0` on the latest commit's `spec-review` comment to merge-ready, with a nonzero count or a missing review comment a blocker of the same class as a red check, fixed on this PR.
5. `unslop/SKILL.md`: trigger-focused description so it fires on human-facing text.
6. `code-review` → `spec-review` (directory, `name:`, first heading); and step 2.4 no longer asks the author where the spec is: without a ticket, a passed path or a spec file, the Spec axis skips and says "no spec: Standards axis only"; and step 5 ends the report with the line `act-on items: N`, counting hard findings on both axes, so babysit can read it; and steps 1 and 4 hand each reviewer content instead of commands (the commit list, the `--stat` list and the diff pasted in, the standards sections that apply, the ticket body verbatim), tell it to read nothing beyond the brief, and dispatch the Standards axis through the factory's `standards reviewer` role while the Spec axis stays on the writer's lane.
7. Session mandate replaced by ours (`template/.claude/hooks/session-mandate.md`).
8. `mobile-fingerprint-check.yml` copied into `profiles/react-native/` (T3 Code, MIT) with two edits: `runs-on: ubuntu-latest` instead of T3's Blacksmith runner, and the watched paths reduced to `apps/mobile/**`, `packages/shared/**` and the workspace files.
11. `playbooks/autopilot-stack.md` step 1: when a unit is a ticket, its owner runs the Ticket playbook, so tickets close on merge and blockers are checked under a stack run.
10. `interrogate/SKILL.md` step 2: when a ticket exists, its What to build and Acceptance criteria are the intent verbatim; the author's PR description and commit messages are used only without one.
9. Every remaining `/no-comments` reference removed from `poteto-mode/` (router step list, `playbooks/autopilot-full.md`, `playbooks/autopilot-stack.md`, `playbooks/multi-phase-plan.md`, `references/codex-tools.md`), since the skill is not vendored (decision 4).
12. `babysit/SKILL.md` step 4: ready also requires the `spec-review` comment on the latest commit to read `act-on items: 0`.
