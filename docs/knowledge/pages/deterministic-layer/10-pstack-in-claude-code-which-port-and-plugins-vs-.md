<!-- lines: 39 | source: pages/deterministic-layer.md | part 10/12 | title: The Deterministic Layer (reference page) — pstack in Claude Code: which port, and plugins vs files -->

## Contents (line numbers are for the Read tool's offset)
- L9: pstack in Claude Code: which port, and plugins vs files
- L11: First, the three kinds of file, and the invocation question
- L19: open-pstack vs pstack-claude vs pstack-skills
- L35: Plugins versus files, honestly

## pstack in Claude Code: which port, and plugins vs files

### First, the three kinds of file, and the invocation question

Your reading is right. pstack has a **router** (poteto-mode, the one sticky skill), **action skills** (procedures with subagents: how, why, architect, interrogate, tdd, the verification pair, the prose skills), **principle skills** (21 one-page leaves the router reads at task start and cites by name; nothing runs, they constrain decisions), and **playbooks**, which are not skills at all but markdown files inside the router's folder, one per task shape, whose steps the router "copies in verbatim" to the todo list. A playbook step names which action skills fire ("1. `how` over the affected subsystem. 2. `architect` for parallel design exploration"). So: human invokes the router once; the router matches a playbook; the playbook's steps invoke action skills; principles constrain every decision along the way. primary

The apparent contradiction (every skill is non-model-invocable, yet the human is only at the ends) dissolves once you know what the flag means on each harness. Upstream, 43 of 44 skills carry `disable-model-invocation: true`; in Cursor that prevents a skill from firing on its own because its description matched, but the router can still tell the model to read a named skill file, and it does ("Read the leaf skill in full for any principle you apply"). In Claude Code the same flag is stronger. The official docs: "Claude cannot invoke through the Skill tool when this is true, but you still can invoke it directly... If Claude tries anyway, Claude Code blocks the call," and the skill's description is dropped from context entirely. That is why both maintained ports strip the flag from every action skill (open-pstack's changelog: "the flag on a skill makes the Skill tool refuse the invocation outright"), mark the 21 principles `user-invocable: false` instead (hidden from your `/` menu, invocable by the model), and add the SessionStart mandate so the router gets invoked without you typing it. Result in Claude Code: the router is invoked by the hook, everything else by the router, and you are at the ends. primary

The same doc settles a detail worth knowing for Matt's set: a user-invoked skill (`disable-model-invocation: true`) costs zero context, because its description is never loaded. Theo's complaint that descriptions are "injected into context whether or not the skill fires" is true only for model-invocable skills. Matt's fourteen user-invoked skills are free until you type them.

### open-pstack vs pstack-claude vs pstack-skills

|  | open-pstack (ericlitman) | pstack-claude (michael-denyer) | pstack-skills (IgorKhramtsov) |
| --- | --- | --- | --- |
| Upstream sync | v0.14.7, released 2026-09-03 (five minor versions newer) | v0.14.2, last commit 2026-09-02 | a 2026-08-02 commit; last activity 2026-08-11 |
| Invocation flag | removed from action skills; principles `user-invocable: false` | same | kept on 37 of 44 skills including the router and the principles, which per the official docs blocks the model's Skill tool |
| Auto-fire | SessionStart mandate hook; delete `hooks/hooks.json` to opt out | identical hook, byte for byte | none; you type `/poteto-mode` |
| Models on Claude | four-model panel (Fable, GPT-5.6 Sol, Grok 4.6, Opus 5) via an external runner that needs the Codex and Grok CLIs signed in; set roles to `inherit-parent` to stay Claude-only | Claude-only trio (Opus 5, Fable 5, Sonnet 5); the "harsher pass" is a bundled review skill | host-native, "No guessed model fallback" |
| Install as files | symlink loop documented as "only for testing a checkout before publishing"; plugin is the intended path | `npx skills add https://github.com/michael-denyer/pstack-claude/tree/main/plugins/pstack/skills --skill "*"`, or a symlink loop into `~/.agents/skills/`; documented, supported | symlink loop into `~/.claude/skills/`, the only method |
| Codex later | first-class: `codex plugin marketplace add ericlitman/open-pstack`; a route table for a Codex parent | symlink plus prompt stubs, "verified on a live Codex session" | not mentioned |
| Kept `paths:` on the TypeScript skill | yes (auto-loads on `.ts`) | no | no |
| CI on the port itself | Bun tests, typecheck, static invariants | CI plus a security workflow (osv-scanner, SHA-pinned actions, zizmor) | a validator script, no CI |
| Also bundles | deslop and six other cursor-team-kit skills, a babysit skill, the watch-pr and orch scripts | same set | none |

**Verdict.** Rule out pstack-skills: it keeps the flag that Claude Code's docs say blocks the model, has no hook and no CI, and is a month stale. Between the other two the difference is smaller than their READMEs suggest; the hook is identical and the substitution tables nearly so. Choose by what you value: open-pstack for freshness against upstream, the retained `paths:` auto-load, and a documented Codex route when you add it; pstack-claude for a supported files-only install today and a more conservative, Claude-only model table. Given you are Claude-only now, want to read and edit the files, and may add Codex later, the sequence that fits is pstack-claude installed as files now (`npx skills add ... --skill "*"` into the project, or the symlink loop), with the SessionStart hook recreated by hand in `.claude/settings.json` from the JSON above if you want auto-fire, and a move to open-pstack's plugin when Codex arrives. If you would rather not re-create the hook and are fine with a plugin for this one system, open-pstack today is the simpler choice. inferred

### Plugins versus files, honestly

The clash you read about is real but narrower than it sounds. Plugin skills are namespaced (`mattpocock-skills:code-review`) and, per the docs, "can't conflict with other levels"; what happens is that the unqualified `/code-review` then resolves to Matt's in practice and shadows Claude Code's bundled one. Files do not fix that: the docs also say "A skill at any of these levels also overrides a bundled skill with the same name." So whether you install Matt's set as a plugin or as files, a skill directory named `code-review` shadows the built-in, and the fix is the same: rename the directory (`two-axis-review`) and update any skill that names it. What files do give you is exactly what you asked for: you can read every line, edit it, and see which skill calls which by grepping for "Call the Skill tool with." The costs: `npx skills update` overwrites your edits, so either stop updating or keep your edited copies under a different name; plugin-only extras (Matt's marketplace listing, the ports' hooks and agents) have to be re-created by hand; and you own the lag against upstream. For your stated goal, files are the right call for Matt's set and for any skill you intend to modify; a plugin is reasonable for a system you want to run whole and keep current.

One pattern from Theo's repo solves "per project, specialized to the harness" cleanly: keep skills in `.agents/skills/` (the cross-harness convention that Codex, T3 Code and Ras Mic all use) and make `.claude/skills` a symlink to it. T3 Code's two directories are byte-identical for that reason. One folder, every harness, checked into the repo.
