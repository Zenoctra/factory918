# Factory918

A template and a small command-line tool that put an agent-driven development workflow into any project: Matt Pocock's skills for planning (interview → spec → tickets on GitHub), pstack's skills for execution (one ticket → one verified pull request), a Theo-style layer of formatter, linter, type checks, tests and CI underneath that decides what passes without a model reading a word, profiles for React Native and Python, and the glue that makes them one system. It is Manuel's, assembled from four people's published work, and it is opinionated on purpose: the choices are recorded, with reasons, so you can disagree with one on the record.

## What you need

Claude Code, a GitHub account, and a shell with `bash`, `git`, `jq` and `python3`. Developed and tested on macOS. Linux is expected to work unchanged (the project-side checks already run on Ubuntu in CI). Windows is untested: use WSL, or Git Bash with those four tools on its PATH. About fifteen minutes the first time.

## Start here

1. Clone this repository and, inside the clone, run `./factory918.sh install`. Add `~/.local/bin` to your `PATH` if it tells you to, then open a new terminal.

       git clone https://github.com/Zenoctra/factory918.git && cd factory918 && ./factory918.sh install

2. Create a project: `factory918 init <dir>`. Or add Factory918 to a repository you already have: `factory918 apply` inside it.
3. Open Claude Code in the project and type `/factory918`. It checks what is set up on this machine and in the project, gives you the next step, and says what the step is for. The first one is `/factory-start`, a short interview about the project.

If anything is off, `factory918 doctor` is the checklist: every line that fails says how to fix it. `/factory918` reads it for you.

## Read the manual next

`docs/knowledge/core/MANUAL.md` is the one document to read before your first project. It shows the whole loop on one screen (plan → tickets → execute → review → merge), says what you do at each point and what the agent does, and covers the day-0 steps above in full. Its last sections are "Updating the factory" and "Troubleshooting". It ends with a map of the other documents and when each one is worth opening, so you can stop there or keep going.

## Keeping it current

The factory lives once per machine at `~/.factory918`. To take an update: `git -C ~/.factory918 pull`, then `factory918 update` inside each project. `update` merges the new template into your project three ways and never overwrites an edit you made; a real collision lands beside the file as `<file>.factory-merge`.

## Layout

    factory918.sh             the CLI: install | init | apply [--scaffold] [--profile name] [--name n] | doctor | update | sync | sync-repos | labels | knowledge
    template/                 everything `factory918 apply` copies into a project: AGENTS.md, CLAUDE.md,
                              CONTEXT.md, CODING_STANDARDS.md, .agents/skills/ (72 skills), .claude/ (hooks,
                              agents, settings), docs/agents/, docs/adr/, vite.config.ts, sgconfig.yml, the
                              oxlint plugin, ast-grep/, .vite-hooks/, .github/ (CI, labels, PR template), .repos/
    profiles/                 vite-plus (default), react-native, python
    machine/                  per-machine files `factory918 install` writes: pstack's model sheet
    patches/                  unified diffs against the upstream pins, applied in `series` order by `factory918 sync`
    docs/knowledge/           the corpus the `knowledge` skill reads: INDEX.md, core/ (hand-maintained),
                              spec/ pages/ notes/ (generated, chunked, with mini-TOCs)
    docs/FACTORY-SPEC-v2.md   the implementation spec; docs/M0-findings.md is what was verified against it
    research/                 read-only corpus: notes/, pages/, and the pinned upstream sources
    tools/build_knowledge.py  regenerates docs/knowledge/ and the slim copies in template/docs/factory918/
    tools/bootstrap/          frozen: how template/ and profiles/ were first generated
    AGENTS.md  CLAUDE.md     how to work on the factory itself; the factory runs on its own skills and hooks
    SOURCES.md  VERSION  manifest.schema.json  LICENSE
    .claude/                  links to the template's skills and hooks, plus settings.json, for sessions in this clone
    tools/check_knowledge.py  the knowledge-base checks CI and the maintainer run

## Status

Milestones M0 to M7 are done and their acceptance checks ran (`docs/M0-findings.md`). M8 is the first real project. The React Native profile's Expo app and simulator step have not run yet; the Python CI job has run locally but not on GitHub.

## License

MIT (`LICENSE`). The vendored skills and files from Matt Pocock's skills, pstack, open-pstack and T3 Code are MIT too; their notices are kept beside the copies under `research/`, and the edits made to them are the patches listed in `SOURCES.md`.
