<!-- lines: 34 | source: notes/3-pstack.md | part 8/11 | title: Research note: pstack — Running it in Claude Code -->

## Contents (line numbers are for the Read tool's offset)
- L6: Running it in Claude Code

## Running it in Claude Code

**Upstream support: none, by design.** Upstream is a Cursor plugin; its own guide says "In a Cursor chat, run: /add-plugin pstack" (`docs/guide/01-setup.md`) and the README never mentions Claude Code. The concepts port (SKILL.md is a shared format), but the skill bodies reference Cursor's `Task` tool, `generalPurpose`, `readonly`, `environment: "cloud"`, `AskQuestion`, `/loop`, `/goal`, `/deslop`, `control-ui`/`control-cli`, `create-skill`, `~/.cursor/...`, Bugbot, and Cursor cloud agents. Copying the raw tree into `~/.claude/skills/` would leave dozens of dangling references (Flavio Copes: with the Claude Code port "You lose the Cursor-only pieces" such as per-task model assignment and `/loop`).

**Recommended path for Manuel (Claude Code): open-pstack** (closest to upstream, most recently synced, keeps the multi-model idea). Steps from `open-pstack/README.md` and `docs/reference.md`:

1. Inside Claude Code: `/plugin marketplace add ericlitman/open-pstack`, then `/plugin install pstack@open-pstack`, then `/reload-plugins`.
2. Install system tools the playbooks call: `gh` (GitHub CLI, `gh auth login`), `bun` (for `watch-pr`, `orch`, the external runner), `node` (for `check-plan.mjs`); optionally `jq` and `rg` for the worktree audit. `gt` only if you use Orchestrate.
3. Optional companion: `/plugin marketplace add anthropics/claude-plugins-official` and `/plugin install plugin-dev@claude-plugins-official` (only the skill-authoring routes need it).
4. Run `/pstack:setup-pstack`. It writes `~/.claude/pstack-models.md` and adds `@~/.claude/pstack-models.md` to `~/.claude/CLAUDE.md`. The first-run panel is "Fable max, GPT-5.6 Sol max, Grok 4.6 xhigh, and Opus xhigh". Sol and Grok lanes run through their own signed-in CLIs (Codex CLI, Grok Build CLI) via the bundled `pstack-runner`; "Open Pstack does not quietly replace a failed model with a weaker one." If you only have Claude, set the non-Claude roles to `inherit-parent`/`auto` or to Claude models; multi-model review then degrades to Claude-only diversity.
5. Start a new session. The `SessionStart` hook injects a ~0.3k-token mandate ("Before responding to any non-trivial engineering task ... invoke the pstack:poteto-mode skill"), so you can just talk; or type `/pstack:poteto-mode <goal>`, `/pstack:how ...`, `/pstack:teach ...`, `/pstack:unslop`. Opt out of auto-fire by deleting `hooks/hooks.json` from the installed copy under `~/.claude/plugins/cache/open-pstack/pstack/<version>/`.

**Alternative: pstack-claude** (`/plugin marketplace add michael-denyer/pstack-claude`, `/plugin install pstack@pstack-claude`). Simpler and Claude-only: panels are `claude-opus-5` / `claude-fable-5` / `claude-sonnet-5`, the "harsher pass" is the bundled `thermo-nuclear-code-quality-review` skill instead of another vendor. Also installable without a plugin via `npx skills add https://github.com/michael-denyer/pstack-claude/tree/main/plugins/pstack/skills --skill "*" --agent "*" --yes`, or symlinked into `~/.agents/skills/` (which Codex, opencode, Gemini CLI, Prime Agent also read). Synced only to upstream 0.14.2 (missing the 0.14.7 forge-neutral and Fable 5.1 changes).

**Lightest option: IgorKhramtsov/pstack-skills**: symlink each `skills/*` dir into `~/.claude/skills/` and invoke `/poteto-mode`; adds a `pstack-runtime` contract skill; older (0.13.0), no hook, no cursor-team-kit imports.

**What changes or breaks in Claude Code, whichever port you pick** (from `pstack-claude/README.md` "What's substituted", `open-pstack/docs/reference.md`, `pstack-skills/PORTING.md`):

- No sticky mode; the SessionStart hook is the analog (or invoke the skill each task).
- No Cursor cloud agents: `/swarm`, the autopilots, and Shipping's per-PR verifiers run as local background subagents isolated by worktree; your machine does all the work.
- No `/loop` or `/goal`: Claude's built-in `loop` skill replaces `/loop`; `/goal` becomes standing orders in the todo list. Long unattended runs are less robust than on Cursor.
- No `control-ui` / `control-cli`: replaced by Claude Code's `verify` / `run` skills. `/create-verification-skill` still works and matters more here.
- No `/deslop` upstream; both plugin ports import it from cursor-team-kit.
- `Comment Sicko`→`comment-sicko`; `AskQuestion`→`AskUserQuestion`; transcripts live at `~/.claude/projects/<encoded-cwd>/*.jsonl` (affects `recall`, `reflect`, `automate-me`, the `show-me-your-work` audit).
- Model diversity: real cross-vendor panels only with open-pstack plus extra CLIs and subscriptions; otherwise `interrogate`/`arena`/`architect` are one vendor at several tiers.
- Not available outside Cursor: Benny, `make-bot-ui`, the `docs/guide/` tutorial (read it upstream), Bugbot integration (the triage rubric still applies to whatever review bots you have).
- Cost: every panel is four frontier calls; `arena` adds a judge and grafting (Theo's word: "token burners").

---
