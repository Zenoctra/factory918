# Factory918 (DRAFT v0.2.0)

A template repository and a small CLI that load Manuel's agent-driven development system into any project: Matt Pocock's skills for planning (grill → spec → tickets on GitHub), pstack's skills for execution (one ticket → one verified PR), a Theo-style deterministic layer underneath (Vite+ formatter, oxlint, types, tests, CI, review ladder), profiles for React Native and Python, and the glue that makes them one system (`/factory918`, `/factory-start`, `/knowledge`, the Ticket playbook, a phase hook).

## Start here

1. Clone this repository and run `./factory918.sh install` in it; add `~/.local/bin` to `PATH`; open a new terminal.
2. `factory918 init <dir>` for a new project, or `factory918 apply` inside an existing one.
3. Open Claude Code in the project and type `/factory918`. It checks the setup, tells you the next step, and explains what each step is for. The first one is `/factory-start`.

At any point, `factory918 doctor` is the checklist: every line that fails says how to fix it.

The full design is `docs/FACTORY-SPEC-v2.md`. The reasoning is `docs/knowledge/core/PHILOSOPHY.md`; the day-to-day loop is `MANUAL.md`; the settled choices are `DECISIONS.md`. If you are the model finishing this repo, `CLAUDE.md` tells you where to start.

## Layout

    CLAUDE.md                 instructions for the model working in this repo
    README.md  SOURCES.md  VERSION  manifest.schema.json
    factory918.sh             the CLI: init | apply [--profile] | doctor | update | sync | sync-repos | labels | knowledge
    docs/FACTORY-SPEC-v2.md   the implementation spec (v2.1 layout)
    docs/knowledge/           the corpus the `knowledge` skill reads: INDEX.md, core/ (hand-maintained),
                              spec/ pages/ notes/ (generated, chunked, with mini-TOCs)
    template/                 everything `factory918 apply` copies into a project: AGENTS.md, CLAUDE.md,
                              CONTEXT.md, CODING_STANDARDS.md, .agents/skills/ (71 skills), .claude/ (hooks,
                              agents, settings), docs/agents/, docs/adr/, vite.config.ts, oxlint plugin,
                              ast-grep/, .vite-hooks/, .github/ (CI, labels, PR template), .repos/
    profiles/                 vite-plus (default), react-native, python
    patches/                  unified diffs against the upstream pins, applied in `series` order by `factory918 sync`
    machine/                  per-machine files `factory918 install` writes: pstack's model sheet
    research/                 read-only corpus: notes/, pages/, and the pinned upstream sources
                              1-matt-pocock/  2-theo-t3code-excerpts/  3-pstack/  4-ras-mic/  superseded/
    tools/build_knowledge.py  regenerates docs/knowledge/ and the slim copies in template/docs/factory918/
    tools/bootstrap/          frozen: how template/ and profiles/ were first generated (writes to _out/ only)
    .claude/skills/           links to the writing skills and `knowledge`, for sessions in this repo

## Status

Milestones M0 to M7 are done and their acceptance checks ran; `docs/M0-findings.md` records every tool version and every place the tools disagreed with the spec. M8 is the first real project. `factory918 install` once per machine, then `factory918 init` per project.

## Licenses

Vendored skills and files from Matt Pocock's skills, pstack, open-pstack and T3 Code are MIT; their LICENSE files are kept alongside the copies under `research/` and the patches applied to them are listed in `SOURCES.md`. Factory918's own files are Manuel's.
