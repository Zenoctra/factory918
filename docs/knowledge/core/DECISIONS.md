<!-- lines: 46 | source: core/DECISIONS.md | part 1/1 | title: Factory918: decisions -->

## Contents (line numbers are for the Read tool's offset)
- L12: Settled (2026-09-09)
- L34: Defaults accepted by silence
- L38: Provisional (added by agents; Manuel promotes or overrules)

# Factory918: decisions

The choices Manuel has made, with the reason each was made, so no agent re-derives them. Decisions override every vendored source. Add to "Provisional" when you decide something the spec left open; Manuel promotes or overrules from there.

## Settled (2026-09-09)

| # | Decision | Choice | Reason |
|---|---|---|---|
| 1 | Where planning lives | Matt Pocock's skills only: `/wayfinder`, `/grill-with-docs`, `/grill-me`, `/to-spec`, `/to-tickets`, until tickets exist | Front-loaded alignment: the human decides in an interview, the agent finds facts. pstack does not plan ("the best spec is code"), so the two do not overlap. |
| 2 | Where execution lives | pstack, whole, via `/poteto-mode`; a ticket enters through the Ticket playbook | The most complete execution system of the four; Theo's verdict after trying both was that he was "much more philosophically aligned" with it. |
| 3 | Who invokes what | Planning skills and mode switches are user-invoked (`disable-model-invocation: true`); everything pstack routes to is model-invocable; the hook invokes the router | In Claude Code the flag blocks the Skill tool outright, so a router cannot reach a flagged skill. |
| 4 | Comments | Keep them. `/no-comments` is not run and the Comment Sicko agent is not vendored | Manuel: comments are a smell only for people who read code like a novel; that is not him. The other smells still apply at review. |
| 5 | Commit hook | Thin: formatter only (`vp staged` → `vp fmt`; `*.py` → `ruff format`). CI owns lint, types, tests | Agent-authored repos produce many commits; one full gate (CI) beats a slow hook. This is Theo's shape; pstack ships no hook. |
| 6 | Autonomy | Never block on the human, except irreversible actions (force-push, deletes, deploys, external messages) | Manuel: being burned is a steering lesson, not a reason to change philosophy. Decisions were already made in planning. |
| 7 | Tickets and PRs | A ticket is the ask: ticket work auto-opens a PR that says `Closes #N`; conversation work ends in a commit unless asked to file; the agent never merges | Reconciles pstack's auto-PR with Theo's "never make a PR unless asked." |
| 8 | Repositories | GitHub, private by default; one monorepo per product (`apps/*`, `packages/*`, `scripts/`, `python/`); separate repos only when deployment or ownership forces it, with a `system` repo for maps | One CI and one deterministic layer per product; T3 Code's shape. |
| 9 | Toolchain | Vite+ (`vp`) on pnpm and Node 24 for all TypeScript surfaces | Bundled, minimal weight, one config; T3 Code runs it in production. |
| 10 | Mobile | Expo / React Native, not Flutter | One language across surfaces; the deterministic layer carries unchanged (T3 Code Mobile runs Expo SDK 57 with Vitest, tsc and oxlint under Vite+); far more training data for agent-written code; an exemplar exists. Flutter is a documented later profile. |
| 11 | Python | Supported as a profile: `uv`, `ruff` (format + lint, banned APIs via TID251), `pyright` strict, `pytest`, `uv audit`; in a monorepo the same commit hook formats `*.py` | Python comes up often; the profile mirrors the TypeScript one rung for rung. `ty` is the likely future swap for pyright once it is stable. |
| 12 | Cross-language custom rules | `ast-grep` for structural rules that apply in more than one language; the oxlint plugin for TypeScript-only rules | One rule engine for opinions that should hold everywhere; verify at M0. |
| 13 | Models | Opus 5 default; Sonnet 5 for mechanical delegates and explorers; Fable 5.1 reserved for spec synthesis, contested review and hard architecture; panels Opus + Sonnet; `arena` off | $200 plan; Fable burns the shared limit fastest. One file to change. |
| 14 | Knowledge base | Full corpus in the Factory918 repo; each project carries `PHILOSOPHY.md`, `MANUAL.md` and the `/knowledge` skill pointing at the factory clone | Projects stay light; one place to update. |
| 15 | Name | Factory918 (`/factory918` router, `factory918` CLI) | Manuel's choice. |
| 16 | Voice | "A note from Manuel" in `AGENTS.md` is written from his own sentences | Theo's rule that a copied voice is nobody's voice. |
| 17 | The Ticket playbook | Kept as one file wrapping pstack's playbooks rather than four edits to upstream files | Three new behaviours (read ticket, check blockers, falsifiability pass) and one line (`Closes #N`); one file survives `factory918 sync` cleanly. |

## Defaults accepted by silence

Mobile profile Expo/RN (decision 10); Python supported both as a monorepo package and standalone, monorepo first (11); full knowledge base in the factory repo only (14).

## Provisional (added by agents; Manuel promotes or overrules)

| # | Decision | Choice | Reason |
|---|---|---|---|
| P1 | Dev environment isolation | No containers for the dev toolchain. Vite+'s node manager selects the Node and package-manager version each project declares. A `compose.yml` slot covers backing services when a project needs one | Decision 10 makes mobile Expo/RN, and an iOS simulator cannot run in a Linux container, so containers would split the environment in two from day one. The write hook calls `vp fmt` on every agent edit, and routing that through `docker exec` costs latency on every write. On a brownfield repo a container is the opposite of `apply` being additive. Vite+ already gives per-project version isolation for the JavaScript toolchain, `uv` gives it for Python, and CI is the gate that has to be clean. Revisit if a project brings conflicting system-level dependencies. Manuel, 2026-09-09. |
| P3 | Branch protection on private repositories | Not enforced by GitHub until Manuel chooses: GitHub Pro, public repositories, or none. Until then "the agent never merges" rests on `AGENTS.md`, the git guard hook and the human; `factory918 init` prints the protection step as a human-only step | GitHub's free plan refuses branch protection and rulesets on private repositories (verified 2026-09-16 on the M5 throwaway). Decision 8 makes repositories private by default, so the two collide and only Manuel can pick. |
| P4 | Python package name | `factory918 apply --profile python` names the package after the project directory; `--name <name>` overrides | The spec says `python/<name>` and never says where the name comes from. A default that needs no question keeps Day 0 short. |
| P5 | The models sheet on a Claude-only machine | `factory918 install` writes `~/.claude/pstack-models.md` from `machine/pstack-models.md`, every role on `claude:opus` or `claude:fable` with effort as the cost lever, plus the `@` include in `~/.claude/CLAUDE.md`. `/setup-pstack` is not used | The vendored `/setup-pstack` writes nothing unless Fable, Opus, Codex Sol and Grok all answer a live probe, and Manuel has neither Codex nor Grok. Without a sheet the Feature playbook delegates to `grok:grok-4.6@xhigh` and pstack's launcher never falls back, so execution would drop out on the first ticket. pstack's matrix has no Sonnet family, so decision 13's "Sonnet for mechanical delegates" becomes `claude:opus@medium`. Verified 2026-09-16 against open-pstack v1.3.0's setup-pstack and provider-dispatch. |
| P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
