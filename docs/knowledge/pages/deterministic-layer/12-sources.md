<!-- lines: 34 | source: pages/deterministic-layer.md | part 12/12 | title: The Deterministic Layer (reference page) — Sources -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sources

## Sources

The full extraction (about 16,000 words of verbatim config, workflow YAML, rule messages and skill text with local paths) is in the companion bundle as `notes/6-deterministic-layer.md`.

#### T3 Code (primary)

* [.github/workflows/ci.yml](https://github.com/pingdotgg/t3code/blob/main/.github/workflows/ci.yml) · [pr-size.yml](https://github.com/pingdotgg/t3code/blob/main/.github/workflows/pr-size.yml) · [pr-vouch.yml](https://github.com/pingdotgg/t3code/blob/main/.github/workflows/pr-vouch.yml) · [docs/internals/ci.md](https://github.com/pingdotgg/t3code/blob/main/docs/internals/ci.md)
* [vite.config.ts](https://github.com/pingdotgg/t3code/blob/main/vite.config.ts) (staged, fmt, lint, debt ceilings) · [oxlint-plugin-t3code/](https://github.com/pingdotgg/t3code/tree/main/oxlint-plugin-t3code) · [.macroscope/](https://github.com/pingdotgg/t3code/tree/main/.macroscope) · [AGENTS.md](https://github.com/pingdotgg/t3code/blob/main/AGENTS.md) · [.agents/skills/](https://github.com/pingdotgg/t3code/tree/main/.agents/skills) · [TransferBudgetReport.integration.ts](https://github.com/pingdotgg/t3code/blob/main/apps/server/integration/TransferBudgetReport.integration.ts) · [triage PLAYBOOK.md](https://github.com/pingdotgg/t3code/blob/main/.github/triage/PLAYBOOK.md)

#### pstack and ports (primary)

* [principle-encode-lessons-in-structure](https://github.com/cursor/plugins/blob/main/pstack/skills/principle-encode-lessons-in-structure/SKILL.md) · [create-verification-skill](https://github.com/cursor/plugins/blob/main/pstack/skills/create-verification-skill/SKILL.md) · [blast-radius](https://github.com/cursor/plugins/blob/main/pstack/skills/blast-radius/SKILL.md) · [interrogate](https://github.com/cursor/plugins/blob/main/pstack/skills/interrogate/SKILL.md) · [playbooks/](https://github.com/cursor/plugins/tree/main/pstack/skills/poteto-mode/playbooks) (opening-a-pr, babysit, shipping) · [bugbot-triage.md](https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/references/bugbot-triage.md) · [guide 06](https://github.com/cursor/plugins/blob/main/pstack/docs/guide/06-verify-and-ship.md)
* [open-pstack](https://github.com/ericlitman/open-pstack) (README, docs/reference.md, CHANGES.md, UPSTREAM.md, plugins/pstack/hooks/) · [pstack-claude](https://github.com/michael-denyer/pstack-claude) (README, models.json, hooks/) · [pstack-skills](https://github.com/IgorKhramtsov/pstack-skills) (README, PORTING.md)

#### Matt Pocock (primary)

* [tdd](https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md) (+ tests.md, mocking.md) · [codebase-design](https://github.com/mattpocock/skills/blob/main/skills/engineering/codebase-design/SKILL.md) · [code-review](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md) · [ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md) · [diagnosing-bugs](https://github.com/mattpocock/skills/blob/main/skills/engineering/diagnosing-bugs/SKILL.md)
* [setup-pre-commit](https://github.com/mattpocock/skills/blob/main/skills/misc/setup-pre-commit/SKILL.md) · [git-guardrails-claude-code](https://github.com/mattpocock/skills/blob/main/skills/misc/git-guardrails-claude-code/SKILL.md) · [setup-ts-deep-modules](https://github.com/mattpocock/skills/blob/main/skills/in-progress/setup-ts-deep-modules/SKILL.md) · [retro](https://github.com/mattpocock/skills/blob/main/skills/in-progress/retro/SKILL.md) · [docs: triage (labels by hand)](https://github.com/mattpocock/skills/blob/main/docs/engineering/triage.md)

#### Ras Mic (primary)

* [evidence-driven-testing](https://github.com/michaelshimeles/skills/blob/main/evidence-driven-testing/SKILL.md) · [greploop](https://github.com/michaelshimeles/skills/blob/main/greploop/SKILL.md) · [before-and-after](https://github.com/michaelshimeles/skills/blob/main/before-and-after/SKILL.md) · [AGENTS.md](https://github.com/michaelshimeles/skills/blob/main/AGENTS.md) · [new-feature](https://github.com/michaelshimeles/skills/blob/main/new-feature/SKILL.md)

#### Platform docs and the ladder (primary / secondary)

* [Claude Code hooks reference](https://code.claude.com/docs/en/hooks) · [Claude Code skills reference](https://code.claude.com/docs/en/skills) (frontmatter semantics, collision rules)
* [Announcing Vite+ (VoidZero)](https://voidzero.dev/posts/announcing-vite-plus-alpha) · [voidzero-dev/vite-plus](https://github.com/voidzero-dev/vite-plus)
* Boris Cherny, Steps of AI Adoption (Anthropic, 2026-07-16), via [explainx](https://www.explainx.ai/blog/boris-cherny-steps-ai-adoption-claude-code-july-2026) and [Shelly Palmer](https://shellypalmer.com/2026/07/boris-chernys-steps-of-ai-adoption-a-roadmap/) (secondary)
* Theo, "Stop letting your agents write Markdown" (2026-05-13) and the 2026-08-11 breakdown, via [BigGo](https://finance.biggo.com/podcast/6f71ab363f4b2ede) summaries (secondary; the "file and babysit" dating)
