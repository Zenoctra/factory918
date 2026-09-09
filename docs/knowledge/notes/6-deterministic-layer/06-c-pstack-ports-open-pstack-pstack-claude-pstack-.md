<!-- lines: 141 | source: notes/6-deterministic-layer.md | part 6/10 | title: Research note: deterministic layer (verbatim config) — C. pstack ports — open-pstack, pstack-claude, pstack-skills -->

## Contents (line numbers are for the Read tool's offset)
- L10: C. pstack ports — open-pstack, pstack-claude, pstack-skills
- L12: C.1 open-pstack — `research/3-pstack/open-pstack-claude-code-port/`
- L75: C.2 pstack-claude — `https://github.com/michael-denyer/pstack-claude/blob/273d217/`
- L105: C.3 IgorKhramtsov/pstack-skills — `https://github.com/IgorKhramtsov/pstack-skills/blob/ce47cec/`
- L119: C.4 Comparison table (sourced)

## C. pstack ports — open-pstack, pstack-claude, pstack-skills

### C.1 open-pstack — `research/3-pstack/open-pstack-claude-code-port/`

**Hook.** `plugins/pstack/hooks/hooks.json`, verbatim:
```
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```
`hooks/session-start` is three effective lines: `set -euo pipefail` then `exec cat "$(cd "$(dirname "$0")" && pwd)/session-start-context.md"` ("prints the poteto-mode dispatch mandate to stdout, which Claude Code injects as session context directly"). `hooks/run-hook.cmd` is a polyglot batch/bash wrapper "Adapted from the superpowers plugin (MIT)".

Injected mandate, `plugins/pstack/hooks/session-start-context.md`, verbatim:
```
<EXTREMELY_IMPORTANT>
You have pstack.

Before responding to any non-trivial engineering task — a feature, bug fix, refactor, debugging, performance work, or any multi-step code change — invoke the `pstack:poteto-mode` skill with the Skill tool and follow it. It is the default entry point and routes to the specific pstack skills from there. Pure questions and trivial one-line edits don't need it.

When the intent is already specific, enter directly: `pstack:tdd` (bug with a reproducible failure), `pstack:architect` (types and module shape before code that crosses a function boundary), `pstack:how` (how a subsystem works), `pstack:why` (why it was built this way), `pstack:arena` (N parallel attempts at one task), `pstack:interrogate` (multi-model diff review).

If you were dispatched as a subagent to execute a specific task, ignore this block — poteto-mode governs the orchestrating session, and it already shaped your dispatch.

User instructions (CLAUDE.md, AGENTS.md, direct requests) take precedence over this mandate. Other session-start mandates (such as superpowers) compose with it: their skill-check discipline stands, and poteto-mode is the implementation entry point they route to for non-trivial code work.
</EXTREMELY_IMPORTANT>
```

Disable: `docs/reference.md` line 25: "To opt out, delete `hooks/hooks.json` from the installed copy at `~/.claude/plugins/cache/open-pstack/pstack/<version>/hooks/hooks.json`; a plugin update restores it." Codex: "The `hooks/` SessionStart injection is Claude Code-only; Codex has no plugin hook runtime. Enter `pstack:poteto-mode` by name, or add a standing instruction to `~/.codex/AGENTS.md`".

**Frontmatter in the port.**
- `plugins/pstack/skills/poteto-mode/SKILL.md`: `name: poteto-mode`, `description: …` — no `disable-model-invocation`, no `mode`, no `reminder`. The body starts with a "## Platform Adaptation" section pointing at `references/provider-dispatch.md` and `references/codex-tools.md`, and uses `AskUserQuestion` instead of `AskQuestion`.
- `how/SKILL.md`: `name`, `description` only.
- `principle-prove-it-works/SKILL.md`: `name`, `description`, `user-invocable: false`. All 21 `principle-*` leaves carry `user-invocable: false` (grep count). `CHANGES.md` (1.0.1): "The 21 `principle-*` leaves declare `user-invocable: false`; Claude hides them, while Codex 0.149.0 currently ignores that picker metadata ([#8])." and (Maintenance): "They must not carry `disable-model-invocation`, which would make them unreachable to the model."
- `typescript-best-practices/SKILL.md`: `name`, `description`, `paths: ["**/*.ts", "**/*.tsx"]` (kept), no disable flag.
- Why the flag was dropped (`CHANGES.md`, 0.9.8 entry): "the flag on a **skill** makes the Skill tool refuse the invocation outright. Net effect: the 0.9.5 SessionStart mandate ("invoke `pstack:poteto-mode` with the Skill tool") was refused every session". `UPSTREAM.md`: "Four `disable-model-invocation: true` lines from `73f8be4` are not applied to `how`, `why`, `unslop`, or `typescript-best-practices`. Poteto-mode invokes those skills by name, and the flag blocks that route on Claude Code."

**Model defaults.** No `models.json`; the source of truth is `plugins/pstack/skills/poteto-mode/references/provider-dispatch.md` "Model matrix": `fable` → `claude`/`fable`/default effort `max`; `sol` → `codex`/`gpt-5.6-sol`/`max`; `grok` → `grok`/`grok-4.6`/`xhigh`; `opus` → `claude`/`opus`/`xhigh`. Descriptors are `<provider>:<model>@<effort>`. Route table: on Claude Code, `claude:*` is native `Agent`, `codex:*` and `grok:*` go through the external runner `skills/poteto-mode/scripts/runner/pstack-runner`; on Codex, `codex:*` is native `spawn_agent` and the others are external. "The launcher never falls back." `docs/reference.md`: "The `bug-fix`, `perf-issue`, and `hillclimb` roles stay on GPT-5.6 Sol max instead of upstream's Fable default because Sol costs less for these frequent delegated code roles." Native Claude agents are shipped as `plugins/pstack/agents/pstack-fable-{low,medium,high,xhigh,max}.md` and `pstack-opus-*.md`.

**Install methods** (`README.md`, `docs/reference.md`):
- Claude Code: `/plugin marketplace add ericlitman/open-pstack`, `/plugin install pstack@open-pstack`, `/reload-plugins`.
- Codex: `codex plugin marketplace add ericlitman/open-pstack --ref main`, `codex plugin add pstack@open-pstack`, plus `[features] multi_agent = true` in `~/.codex/config.toml`.
- Symlink (dev only): `for s in plugins/pstack/skills/*/; do ln -s "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done` — "Direct links are only for testing a checkout before publishing it."
- No `npx skills add` instruction in this repo.

**Sync state.** `UPSTREAM.md`: Commit `efa2a531985e0a8084d36ff3cf87233be8a9f34b`, Upstream version `0.14.7`, open-pstack version `1.3.0`. Last commit `56bfd14 2026-09-03 release: sync Cursor pstack 0.14.7 (#44)`; tag `v1.3.0`.

**Substitution table** (`docs/reference.md` "What's substituted in skill bodies"): `Task` tool / `subagent_type: generalPurpose` / `readonly` → "`Agent` tool with model selection, requested effort, and `disallowedTools`; access mode is assigned by the parent, with writers isolated in worktrees"; `AskQuestion` → `AskUserQuestion`; `/loop` → Claude Code's `loop` skill; `/babysit` → bundled `babysit` skill; `/create-skill` → `plugin-dev:skill-development`; `control-cli` → Claude Code's `run` skill; `control-ui` → Claude Code's `verify` skill; transcripts → `~/.claude/projects/<encoded-cwd>/*.jsonl`; `.cursor/skills/` → `.claude/skills/`; Cursor cloud agents → "Local background subagents (`run_in_background: true`), isolated by git worktree"; `/goal` → standing orders + todolist; model rule `~/.cursor/rules/pstack-models.mdc` → "Override sheet `~/.claude/pstack-models.md`, included from `CLAUDE.md`"; panels → provider-dispatch frontier quad. Added skills imported from cursor-team-kit: `deslop`, `thermo-nuclear-code-quality-review`, `make-pr-easy-to-review`, `fix-ci`, `fix-merge-conflicts`, `get-pr-comments`, `what-did-i-get-done`, plus a bundled `babysit` skill.

**Not ported**: `automations/benny/`, `docs/guide/`, `make-bot-ui`, upstream's Fable code-role defaults (`23a56e2`), sticky mode (`mode`/`icon`/`color`/`reminder` frontmatter — "The port's 0.9.5 SessionStart hook is the analog"), `is_background: true`, the rest of cursor-team-kit.

**Codex statement**: README title claim — "brings … pstack to Claude Code and Codex"; "Both apps read the same pstack skills. Only the way they start those skills and models is different." `AGENTS.md` (repo): "Nothing merges, tags, releases, or rolls out until the exact candidate is installed and the changed behavior passes a live test from the real user surface in every affected harness. Unit tests, validators, source inspection, and self-reports do not satisfy this gate." CI (`.github/workflows/ci.yml`): `bun install --frozen-lockfile`, `bun run test`, `bun run typecheck`, plus static invariants.

### C.2 pstack-claude — `https://github.com/michael-denyer/pstack-claude/blob/273d217/`

**Hook.** `plugins/pstack/hooks/hooks.json`, `hooks/session-start`, and `hooks/session-start-context.md` are byte-for-byte the same text as open-pstack's (same `SessionStart` matcher `startup|clear|compact`, same `run-hook.cmd session-start` command, same `<EXTREMELY_IMPORTANT>` mandate). Disable (`README.md`): "To opt out, delete `hooks/hooks.json` from the installed copy (`~/.claude/plugins/cache/pstack-claude/pstack/<version>/hooks/hooks.json`); a plugin update restores it."

**Frontmatter in the port.**
- `poteto-mode/SKILL.md`: `name: poteto-mode`, `description`, `menu-description: default entry point for any non-trivial task`. No disable/mode/reminder.
- `how/SKILL.md`: `name`, `description`, `menu-description: walk through how a subsystem works`.
- `principle-prove-it-works/SKILL.md`: `name`, `description`, `user-invocable: false`.
- `typescript-best-practices/SKILL.md`: `name`, `description`, `menu-description` — the upstream `paths:` key is **absent** (`grep -rn "^paths:" plugins/pstack/skills/*/SKILL.md` returns nothing).
- `menu-description` is port-specific: `CONTEXT.md` — "the `menu-description:` frontmatter one-liner every public skill carries. Renders as the Codex slash-menu text and the README command-table row".

**Model defaults.** `plugins/pstack/models.json`: `"singleRoleDefault": "claude-opus-5"`, `"panel": ["claude-opus-5", "claude-fable-5", "claude-sonnet-5"]`; roles e.g. `feature, refactoring` → `claude-opus-5`; `bug-fix`, `perf-issue`, `hillclimb`, `strongest judgment` → `claude-fable-5`; `how critics`, `arena runners`, `arena cross-judge pool`, `architect runners`, `interrogate reviewers` → the three-model panel; `"codex": { "singleRoleExample": "gpt-5.6-sol", "panelQuad": ["gpt-5.6-sol", "gpt-5.5", "gpt-5.4", "gpt-5.6-luna"] }`. `README.md` "What's lost in translation": "Claude Code is single-vendor, so the split collapses to three Claude variants by tier. Instead of bridging to an external CLI for that diversity, the rewiring routes the 'harsher pass' to the bundled `thermo-nuclear-code-quality-review` skill".

**Install methods** (`README.md`):
- Claude Code: `/plugin marketplace add michael-denyer/pstack-claude`, `/plugin install pstack@pstack-claude`.
- Shared Agent Skills symlink: `git clone https://github.com/michael-denyer/pstack-claude && cd pstack-claude && mkdir -p ~/.agents/skills && for s in plugins/pstack/skills/*/; do ln -s "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done` — "links all 52 skill directories."
- `npx skills add https://github.com/michael-denyer/pstack-claude/tree/main/plugins/pstack/skills --skill "*" --agent "*" --yes`.
- Codex slash commands: `mkdir -p ~/.codex/prompts && for c in plugins/pstack/.codex-plugin/prompts/*.md; do ln -s "$PWD/$c" ~/.codex/prompts/"$(basename "$c")"; done`; `multi_agent = true` in `~/.codex/config.toml`.
- What a skills-only install loses: "Claude Code's `SessionStart` auto-fire lives in `hooks/`, the Codex slash-command stubs live in `.codex-plugin/prompts/`, and Claude Code's native subagent registration reads `agents/`."

**Sync state.** `VERSION` = `0.9.18`; `README.md`: "The skill tree is synced against upstream `4612556`, pstack v0.14.2." `tools/upstream.json` pins `pstack` sha `4612556` and `cursor-team-kit` sha `e46364b…`. Last commit `273d217 2026-09-02 Name the port maintainer as plugin author (0.9.18) (#52)`; no git tags.

**Substitutions** (`README.md` table): `Task`/`generalPurpose`/`readonly` → "`Agent` tool, `subagent_type: "general-purpose"`, no readonly flag"; `AskQuestion` → `AskUserQuestion`; `/loop` → `loop` skill; `/babysit` → bundled skill; `/create-skill` → `plugin-dev:skill-development`; `control-cli` → `run`; `control-ui` → `verify`; transcripts, skill paths, MCP discovery, cloud agents, `/goal`, agent store, model rule as in open-pstack; `composer-2.5-fast` → `claude-sonnet-4-6`; `claude-opus-4-X-thinking-xhigh` → `claude-opus-5`; `gpt-5.3-codex-high-fast`/`gpt-5.5-high-fast` → `claude-sonnet-4-6`/`claude-haiku-4-5`; panels → the Claude trio. Same seven cursor-team-kit imports and bundled `babysit`.

**Not ported**: `automations/benny/`, `docs/guide/`, sticky mode, `is_background: true`, the rest of cursor-team-kit.

**Other-harness statements**: README title "pstack for Claude Code, Codex, Prime Agent, opencode, and Gemini CLI". Verified/unverified per README: Codex "verified on a live Codex session"; opencode "verified on a live opencode 1.18.25 session"; Prime Agent "not yet run on a live Prime session"; Gemini CLI "has not been run on a live session". "Discovery is not a promise that Claude-specific execution details translate automatically. The skill bodies retain Claude Code tool names, `claude-*` model slugs, and Claude built-in skills. [`codex-tools.md`] maps those names on Codex only."

CI (`README.md` "CI"): `ci.yml` five jobs (static invariants via `tests/skill-collision-repro.sh` under `SKIP_BEHAVIORAL=1`; generated-files job runs `bun tools/generate.mjs` and rejects a diff; skills-only install via the `skills` CLI compared file-by-file; Bun tooling tests; `shellcheck`). `security.yml`: `osv-scanner` on lockfiles ("fails the build if no lockfile was found, because an empty scan reads exactly like a clean one"), rejects action refs not pinned to a 40-char SHA, `zizmor` audits workflows; weekly schedule.

### C.3 IgorKhramtsov/pstack-skills — `https://github.com/IgorKhramtsov/pstack-skills/blob/ce47cec/`

`README.md`: "A host-neutral port of pstack for Claude Code and Oh My Pi (OMP)." Compatibility: "Claude Code: supported through user skills. OMP: supported through its Claude user-skills provider. Other Agent Skills clients: the `skills/` layout is portable, but host-specific delegation and runtime capabilities may need a small adapter in `pstack-runtime`."

Install (only method): `mkdir -p ~/.claude/skills; for skill in "$PWD"/skills/*; do ln -s "$skill" "$HOME/.claude/skills/$(basename "$skill")"; done`. "Claude Code invokes `/poteto-mode`. OMP invokes `/skill:poteto-mode`." Validation: `python3 scripts/validate.py` ("checks the complete inventory, frontmatter names, relative Markdown links, and leaked Cursor-only runtime constructs").

No hook: there is no `hooks.json`, no `.github/`, no plugin manifest; `find . -name hooks.json` returns nothing. Auto-fire is therefore absent; the user must invoke `/poteto-mode`.

Frontmatter: `skills/poteto-mode/SKILL.md` keeps the upstream frontmatter verbatim (`disable-model-invocation: true`, `mode: true`, `icon: crown`, `color: yellow`, `reminder: …`). `skills/how/SKILL.md`: `name`, `description` only. `skills/principle-prove-it-works/SKILL.md`: `disable-model-invocation: true`. Count: 37 of 44 `SKILL.md` files carry `disable-model-invocation: true`; the seven without are `how`, `pstack-runtime`, `setup-pstack`, `show-me-your-work`, `typescript-best-practices`, `unslop`, `why`. (Note: the other two ports state that this flag makes a skill unreachable to the model's Skill tool on Claude Code; this port does not discuss that.)

Sync: `UPSTREAM` file — `commit=b047069f4f3a73e87dd1f11f7913386d25876b91`, `ported=2026-08-02`. Last commit `ce47cec 2026-08-11 fix: preserve requested voice through unslop`. No tags. 44 skill directories (43 upstream skills + `pstack-runtime`; `make-bot-ui` absent).

Substitutions: `PORTING.md` "Adaptation contract" table — subagents "Select host-native agents by capability; batch independent workers; isolate writers"; models "Optional `~/.claude/pstack-models.md` with separate Claude Code and OMP selectors; otherwise inherit host defaults"; long waits "Use supervised host jobs while the session is active; no assumed cross-session wake mechanism"; PR shepherding "Use available source-control tools, normally `gh`; never assume `babysit` exists"; review panels "Prefer independent host-native reviewer specializations… No guessed model fallback". `skills/pstack-runtime/SKILL.md`: "Never invent a tool, agent type, model slug, path, or cloud capability." Model config: "If `~/.claude/pstack-models.md` exists, read the section for the current host… If the host cannot apply the configured selector, fall back to `inherit-parent` and report the mismatch; never guess a replacement slug." No `models.json`, no vendored `watch-pr`/`orch` scripts, no cursor-team-kit imports. Codex is not mentioned anywhere in README/PORTING.

### C.4 Comparison table (sourced)

| Dimension | open-pstack (ericlitman) | pstack-claude (michael-denyer) | pstack-skills (IgorKhramtsov) |
|---|---|---|---|
| Upstream pin | pstack 0.14.7 @ `efa2a53` (`UPSTREAM.md`) | pstack v0.14.2 @ `4612556` (`README.md`, `tools/upstream.json`) | `b047069…`, ported 2026-08-02 (`UPSTREAM`) |
| Last activity in clone | 2026-09-03, tag v1.3.0 | 2026-09-02, VERSION 0.9.18 | 2026-08-11, no tags |
| Auto-fire hook | Yes, `SessionStart` (`plugins/pstack/hooks/hooks.json`) | Yes, identical hook | None |
| Disable auto-fire | delete installed `hooks/hooks.json` (`docs/reference.md`) | same (`README.md`) | n/a |
| Claude Code install | `/plugin marketplace add ericlitman/open-pstack` + `/plugin install pstack@open-pstack` | `/plugin marketplace add michael-denyer/pstack-claude` + `/plugin install pstack@pstack-claude`; also `npx skills add …`; symlink | symlink into `~/.claude/skills/` only |
| Codex support | First-class: `codex plugin marketplace add … --ref main` + `codex plugin add pstack@open-pstack`; `provider-dispatch.md` route table for a Codex parent (`README.md`, `docs/reference.md`) | Symlink into `~/.agents/skills/` + prompt stubs; "verified on a live Codex session"; Claude tool names mapped by `codex-tools.md` | Not mentioned; targets Claude Code and OMP (`README.md`) |
| Multi-vendor review panel on Claude | Yes: Fable + Sol + Grok + Opus via external runner (`provider-dispatch.md`); requires Codex and Grok CLIs + Bun (`README.md` Install) | No: `claude-opus-5`/`claude-fable-5`/`claude-sonnet-5` (`models.json`); harsher pass via `thermo-nuclear-code-quality-review` | Host-native specializations; "No guessed model fallback" (`PORTING.md`) |
| `disable-model-invocation` on skills | Removed (would block Skill-tool invocation, `CHANGES.md` 0.9.8) | Removed | Kept on 37/44 skills |
| Principle leaves | `user-invocable: false` | `user-invocable: false` | `disable-model-invocation: true` |
| `paths:` on typescript-best-practices | Kept | Dropped | Dropped (`skills/typescript-best-practices/SKILL.md` has only `name` and `description`) |
| Vendored `watch-pr`/`orch`/`check-plan` scripts | Yes (`skills/poteto-mode/scripts/`) | Yes (`watch-pr`, `orch`, `worktree-audit.sh`) | No |
| Repo CI on the port itself | Bun tests, typecheck, static invariants (`.github/workflows/ci.yml`) | `ci.yml` + `security.yml` (osv-scanner, SHA-pinned actions, zizmor) + Dependabot | `scripts/validate.py` only, no CI |
| Extra deps documented | `gh`, `bun`, `node`, Claude/Codex/Grok CLIs, `jq`/`rg` (`docs/reference.md`) | `gh`, `bun`, `gt` (stack playbooks), `jq`/`rg` (`README.md`) | `gh` "normally" (`pstack-runtime/SKILL.md`) |

Reading for a Claude-only user: pstack-claude is the most conservative (Claude-only models, no external CLIs, most CI on the port itself, but pinned two upstream minor versions back). open-pstack is newest against upstream and gives the four-vendor panel, at the cost of installing and paying for Codex and Grok CLIs plus Bun. pstack-skills is the lightest (a symlink loop and a validator) but keeps `disable-model-invocation: true` on `poteto-mode` and the principles, which the other two ports say blocks model-side invocation on Claude Code, and it has no hook, no CI, and an older pin.

Reading for a future Claude+Codex user: only open-pstack documents a Codex marketplace install and a parent-owned route table for both harnesses; pstack-claude documents a verified symlink+prompt-stub path for Codex; pstack-skills does not mention Codex.

---
