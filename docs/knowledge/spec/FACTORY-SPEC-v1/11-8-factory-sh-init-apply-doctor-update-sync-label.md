<!-- lines: 40 | source: spec/FACTORY-SPEC-v1.md | part 11/14 | title: The Factory spec, v1 (superseded) — 8. `factory.sh`: init, apply, doctor, update, sync, labels -->

## Contents (line numbers are for the Read tool's offset)
- L9: 8. `factory.sh`: init, apply, doctor, update, sync, labels
- L11: 8.1 Commands
- L20: 8.2 `update`: the merge you described, made precise
- L36: 8.3 What `doctor` checks (also the M1 acceptance list)

## 8. `factory.sh`: init, apply, doctor, update, sync, labels

### 8.1 Commands

- `factory init <dir> [--template vite:application|vite:library|vite:monorepo] [--no-github]` — `vp create <template> --no-interactive --git --hooks` **[primary: vp create flags]**, then `apply`, then `gh repo create` (if `--no-github` absent), `labels`, and a wizard (Matt's `wizard` skill output) for the human-only steps: branch protection, secrets, any provider dashboards.
- `factory apply [<dir>]` — copies `template/` into the project, creates the `.claude/skills` symlink, writes `.factory/manifest.json` (template version + sha256 of every managed file as applied), and runs `doctor`. Additive on existing projects; never overwrites a file that exists locally unless it is byte-identical to the template.
- `factory doctor` — the M1 acceptance checks (below) as a script; prints a table; exits non-zero on any failure.
- `factory update` — three-way merge (§8.2).
- `factory sync` — re-vendor upstream skills from `SOURCES.md` pins and re-apply `patches/`; bumps the template version.
- `factory labels` — the `gh label create --force` loop from `.github/labels.json`.

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

`vp --version` and the pinned `vite-plus` match; `vp hooks status` shows the dispatcher and `core.hooksPath`; `.claude/skills` resolves to `.agents/skills`; every skill directory has a `SKILL.md` with a `name:`; no two skill names collide; `jq` and `gh` are on PATH and `gh auth status` succeeds; the seven planning labels exist (`gh label list`); `.github/workflows/ci.yml` present; `vp check`, `pnpm typecheck`, `vp test run`, `vp build` all exit 0; `.claude/settings.json` parses and each hook script is executable; `.claude/state/` and `.artifacts/` are git-ignored; `~/.claude/pstack-models.md` exists.

---
