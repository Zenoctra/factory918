---
name: factory-start
description: Day-0 interview for a project that just received the Factory918 template. Asks only the decisions the template cannot make, then writes them into AGENTS.md, ADR 0001, .repos/sources.json and the review ladder.
disable-model-invocation: true
argument-hint: "Optional: one line about the project to seed the interview"
---

# Factory918 start

The template has been applied and the files below still contain `<slots>`. Your job is to fill them by interviewing the human, not by guessing. Explore the repo first so you ask only what you cannot observe.

## 1. Explore (silently)

Read `AGENTS.md`, `package.json`, `vite.config.ts`, `pnpm-workspace.yaml` if present, the directory tree two levels deep, and `git remote -v`. Note: which surfaces exist (`apps/*`), whether `apps/mobile` or `python/` exist, which dependencies look uncommon (not in the top thousand npm packages, or pinned to an unusual major), and whether `~/.claude/pstack-models.md` exists.

## 2. Interview

Call the Skill tool with "grilling" over exactly these decisions, in this order, presenting what you found as the recommended answer where you have one. Decisions, not facts, go to the human:

1. **The one paragraph.** What the project is, who uses it, what it must never compromise on (four lines). Seed from the argument if given.
2. **Surfaces.** Web, admin, mobile, CLI, scripts, jobs, Python packages. For each: its entry point and how a user or operator reaches it. This becomes "Hit every surface."
3. **Profiles in play.** `vite-plus` (always), `react-native` (if a mobile surface), `python` (if Python). Confirm each; explain in one line what each adds.
4. **Uncommon dependencies to vendor.** For each candidate from exploration: vendor its source and agent guide into `.repos/` (yes/no), and its git URL and ref.
5. **Review ladder.** Any external review bot to list (default none). Whether `interrogate` should run on every PR or only when contested (default contested).
6. **Models.** Confirm the defaults in `docs/agents/models.md` or change a role. Fable 5.1 is reserved by default.
7. **Repository.** Private (default). Branch protection on `main` requiring `Check` and `Test` (human-only step; offer `/wizard`).
8. **Anything the human already knows will hurt.** Existing invariants, forbidden directories, data that must never be touched. These become "The ways to hurt yourself" entries.

Stop when the frontier of questions is empty and the human confirms.

## 3. Write

- `AGENTS.md`: replace every `<slot>` with the answers. Do not rewrite sections that had no slot.
- `docs/adr/0001-toolchain.md`: fill the version pins from `vp --version`, `node --version`, `pnpm --version`, and `package.json`.
- `.repos/sources.json`: one entry per vendored dependency (`name`, `url`, `ref`); then run `factory918 sync-repos` if the CLI is installed.
- `docs/agents/review-ladder.md`: the "External bots configured for this repo" list.
- `docs/agents/ledger.md`: create it with a header line if missing.
- If `apps/mobile` exists and `profiles/react-native` is not applied, or `python/` exists and `profiles/python` is not applied, say so and stop; `factory918 apply --profile <name>` is the next step.

## 4. Report

List every file written, the human-only steps still open, and the first planning command to run (`/grill-me` for an empty project, `/grill-with-docs` once code exists). Then run `factory918 doctor` and include its table.
