# Sources

Upstream pins for everything vendored into `template/`. Pinned copies of each upstream live in `research/` (re-vendor from there); `factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.

| Source | Pin | Taken | License |
|---|---|---|---|
| github.com/ericlitman/open-pstack (copy: `research/3-pstack/open-pstack-claude-code-port/`) | v1.3.0 (2026-09-03; upstream pstack 0.14.7) | `plugins/pstack/skills/*` (51 dirs; `no-comments` excluded by decision 4), `plugins/pstack/agents/*` except `comment-sicko.md`; the session mandate is ours (raw material: `hooks/session-start-context.md`) | MIT |
| github.com/mattpocock/skills (copy: `research/1-matt-pocock/skills-repo/`) | 6654f6b (2026-08-24; v1.2.3) | grilling, grill-me, grill-with-docs, domain-modeling, to-spec, to-tickets, wayfinder, research, prototype, setup-matt-pocock-skills, writing-for-agents, wizard, wait-what, code-review (→ spec-review); setup templates issue-tracker-github.md, domain.md, triage-labels.md; diagnosing-bugs Phase 1 ladder (quoted in docs/agents/feedback-loops.md) | MIT |
| github.com/pingdotgg/t3code (excerpts: `research/2-theo-t3code-excerpts/`) | f559fe0b (2026-09-04) | `.github/workflows/pr-size.yml` verbatim; the shape of `ci.yml`, `vite.config.ts`, `.vite-hooks/pre-commit`, the custom-rule pattern, the AGENTS.md structure | MIT |

## Patches (applied in code by `tools/bootstrap/build_template.py`; to be re-applied by `factory918 sync`)

1. Namespace: `pstack:<name>` → `<name>` in all vendored pstack markdown and the session mandate; mandate gains a PHASES block.
2. Router: Ticket playbook line added before "Opening a PR" in `poteto-mode/SKILL.md`; `playbooks/ticket.md` added.
3. `playbooks/opening-a-pr.md`: "Run `/no-comments` before review." replaced by keep-comments + spec-review + review-ladder; the subagent sentence drops `/no-comments`.
4. `playbooks/babysit.md`: step 8 made conditional on an external bot being listed in `docs/agents/review-ladder.md`.
5. `unslop/SKILL.md`: trigger-focused description so it fires on human-facing text.
6. `code-review` → `spec-review` (directory, `name:`, first heading).
7. Session mandate replaced by ours (`template/.claude/hooks/session-mandate.md`).
8. `mobile-fingerprint-check.yml` copied verbatim into `profiles/react-native/` (T3 Code, MIT).
9. Every remaining `/no-comments` reference removed from `poteto-mode/` (router step list, `playbooks/autopilot-full.md`, `playbooks/autopilot-stack.md`, `playbooks/multi-phase-plan.md`, `references/codex-tools.md`), since the skill is not vendored (decision 4).
