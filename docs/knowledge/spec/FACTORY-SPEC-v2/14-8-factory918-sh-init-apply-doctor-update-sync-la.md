<!-- lines: 44 | source: spec/FACTORY-SPEC-v2.md | part 14/17 | title: The Factory spec, v2 — 8. `factory918.sh`: init, apply, doctor, update, sync, labels -->

## Contents (line numbers are for the Read tool's offset)
- L9: 8. `factory918.sh`: init, apply, doctor, update, sync, labels
- L11: 8.1 Commands
- L24: 8.2 `update`: the merge you described, made precise
- L40: 8.3 What `doctor` checks (also the M1 acceptance list)

## 8. `factory918.sh`: init, apply, doctor, update, sync, labels

### 8.1 Commands

- `factory918 init <dir> [--template vite:application|vite:library|vite:monorepo] [--no-github]` — `vp create <template> --no-interactive --git --hooks` **[primary: vp create flags]**, then `apply`, then `gh repo create` (if `--no-github` absent), `labels`, and a wizard (Matt's `wizard` skill output) for the human-only steps: branch protection, secrets, any provider dashboards.
- `factory918 models [fable|opus]` — switches the active preset of pstack's role sheet, or names the active one; pstack never falls back on its own, so a lane that drops out on quota is followed by this.
- `factory918 install` — once per machine: links `~/.factory918` to the clone, puts `factory918` in `~/.local/bin`, writes the models sheet (§7.12) if missing.
- `factory918 apply [<dir>] [--scaffold] [--profile react-native|python] [--name <pkg>]` — copies `template/` into the project (`--scaffold`, used by `init`, replaces the files `vp create` just wrote that Factory918 owns: `AGENTS.md`, `CLAUDE.md`, `vite.config.ts`, `.vite-hooks/pre-commit`) (and, with `--profile`, the profile's files: workflow, `eas.json.example` or `pyproject.toml`, `python.yml`, `.pre-commit-config.yaml`), records applied profiles in the manifest, creates the `.claude/skills` symlink, writes `.factory/manifest.json` (template version + sha256 of every managed file as applied), and runs `doctor`. Additive on existing projects; never overwrites a file that exists locally unless it is byte-identical to the template.
- `factory918 doctor` — the M1 acceptance checks (below) as a script; prints a table; exits non-zero on any failure.
- `factory918 update` — three-way merge (§8.2).
- `factory918 sync` — re-vendor upstream skills from `SOURCES.md` pins and re-apply `patches/`; bumps the template version.
- `factory918 labels` — the `gh label create --force` loop from `.github/labels.json`.
- `factory918 knowledge` — runs `tools/build_knowledge.py` to regenerate `docs/knowledge/` (all but the hand-maintained `core/`) and the slim copies in `template/docs/factory918/` after any core, spec or research change; `factory918 update` copies the four slim core files into projects.
- `factory918 sync-repos` — shallow-clones `.repos/sources.json` entries read-only.

### 8.2 `update`: the merge you described, made precise

State: `.factory/manifest.json` holds, for each managed path, the template version and the hash of the template file at apply time. The factory repo holds every template version under a git tag.

For each managed path `p` with old template file `O` (at the project's recorded version), new template file `N`, and local file `L`:

| Case | Action |
|---|---|
| `N` exists, `O` did not | New in the template: add `L := N`, mark `added` (you may delete it; a later update will not re-add a path recorded as `deleted`) |
| `O` existed, `L` missing | Deleted locally on purpose: skip, record `deleted` in the manifest so future updates never re-add it |
| `L == O` (hash) | Untouched locally: `L := N` |
| `L != O` and `N == O` | Edited locally, template unchanged: keep `L` |
| `L != O` and `N != O` | Both changed: `git merge-file -p L O N > merged`; on clean merge, `L := merged`; on conflict, write `L.factory-merge` with conflict markers, leave `L` untouched, and list it for human review |

Vendored skill files and patches are managed the same way, except that `patches/` are re-applied to `N` before the merge so your patches are part of the new template rather than a local edit. Run `doctor` at the end. This is `git merge-file`, which is the same three-way merge git uses for branches, so a reviewer can read the conflict markers with tools they know.

### 8.3 What `doctor` checks (also the M1 acceptance list)

`vp --version` and the pinned `vite-plus` match; `vp hooks status` shows the dispatcher and `core.hooksPath`; `.claude/skills` resolves to `.agents/skills`; every skill directory has a `SKILL.md` with a `name:`; no two skill names collide; `jq` and `gh` are on PATH and `gh auth status` succeeds; the seven planning labels exist (`gh label list`); `.github/workflows/ci.yml` present; `vp check`, `vp test run`, `vp run -r build` and `pnpm sg:test` all exit 0; `.claude/settings.json` parses and each hook script is executable; `.claude/state/` and `.artifacts/` are git-ignored; `~/.claude/pstack-models.md` exists; `AGENTS.md` contains no `<slot>` markers (i.e. `/factory-start` has run); `docs/factory918/PHILOSOPHY.md` and `MANUAL.md` are present; the `factory918`, `factory-start` and `knowledge` skills resolve; `docs/agents/ledger.md` exists; every applied profile's files are present (`eas.json`, `pyproject.toml`) and, for the python profile, `uv --version` succeeds.

---
