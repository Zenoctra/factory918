# M0 findings

Ground truth for the Factory918 build: the tool versions installed on Manuel's machine, the facts checked against them, and every place the checked fact differs from `FACTORY-SPEC-v2.md`. Milestone M0 in the spec, §9.

Machine: macOS 15.6.1, arm64. Date: 2026-09-09.

Status: **incomplete.** ast-grep, the skill manifest, and the Python profile are verified. The Vite+ items wait on installing `vp`; see "Blocked" at the end.

## Tool versions

| Tool | Version | How it got here | Spec said |
|---|---|---|---|
| node | 22.17.0 | already present | `engines.node ^24`; T3 Code runs `^24.13.1` |
| npm | 10.9.2 | already present | n/a |
| python3 | 3.14.6 | already present | n/a |
| git | 2.51.2 | already present | n/a |
| jq | 1.7.1 | already present | needed by the hook scripts |
| ripgrep | 14.1.1 | already present | n/a |
| gh | 2.100.0 | `brew install gh` | needed by `factory918 labels` and `doctor` |
| uv | 0.12.12 | `brew install uv` | Python profile |
| ast-grep | 0.45.3 | `brew install ast-grep` | cross-language rules, §7.11 |
| xcodebuild, xcrun | present | Xcode | React Native profile evidence capture |

Not installed: `vp`, pnpm, the `claude` CLI, adb, eas, expo. `ruff`, `pyright`, and `pytest` need no install; `uv run --with` resolves them per project.

Registry versions, read on 2026-09-09 from `registry.npmjs.org`:

| Package | Latest | Spec said |
|---|---|---|
| `vite-plus` | 0.3.1 | T3 Code pins 0.3.0 |
| `@oxlint/plugins` | 1.82.0 | T3 Code pins `^1.63.0`, which 1.82.0 satisfies |
| `oxlint` | 1.82.0 | n/a |
| `@ast-grep/cli` | 0.45.3 | n/a |
| `expo` | 57.0.21 | profile claims Expo SDK 57 |
| `@anthropic-ai/claude-code` | 2.1.267 | n/a |

## Verified facts

Each fact was checked by running the command named. Two scratch projects: a copy of `template/ast-grep` with one violating TypeScript file and one violating Python file, and a copy of `profiles/python/pyproject.toml` with a module that calls `print` and `os.system`.

1. **`ruleDirs` resolves relative to the directory holding `sgconfig.yml`**, not to the project root. `ast-grep test` with the shipped config failed with `Cannot read rule directory .../ast-grep/ast-grep/rules`. Source: `ast-grep test`, ast-grep 0.45.3.
2. **`ast-grep scan` exits 1 when an `error`-severity rule matches**, and 0 when none match. It is a valid CI gate. Source: `ast-grep scan; echo $?`.
3. **`ast-grep test` exits 4 when a rule has no snapshot**, and reports `No <rule-id> baseline found`. The `valid:` and `invalid:` lists alone do not make a passing test. Source: `ast-grep test; echo $?`.
4. **`ast-grep test --update-all` writes snapshots to `<testDir>/__snapshots__/<rule-id>-snapshot.yml`.** With those files committed, `ast-grep test` exits 0. Source: `ast-grep test --update-all`, then `ast-grep test`.
5. **The `files:` and `ignores:` keys scope a rule by glob from the repo root, and they work as drafted.** With `files: ["python/**/*.py"]` and `ignores: ["**/tests/**", "**/scripts/**"]`, `print()` was reported in `python/app/m.py` and skipped in `python/app/tests/t.py`, `scripts/s.py`, and `other/o.py`. Source: `ast-grep scan`.
6. **`severity: error`, `language: TypeScript`, `language: Python`, and the `pattern` form `console.log($$$ARGS)` are all accepted** by ast-grep 0.45.3. Both starter rules matched their targets and passed their valid cases.
7. **The CLI is `ast-grep`. The short alias `sg` is a different program on macOS**, so scripts and CI must spell out `ast-grep`. Source: `sg --version` printed unrelated output on this machine.
8. **`vite-plus` publishes the `vp` binary directly on npm** with per-platform optional dependencies and no install scripts, so `npm install -g vite-plus@0.3.1` is a pinnable alternative to `curl -fsSL https://vite.plus | bash`. Source: `npm view vite-plus --json`.
9. **The Vite+ installer takes `VP_NODE_MANAGER=yes|no`** to skip its interactive prompt. With `yes` it installs `node`, `npm`, `npx`, `pnpm`, `pnpx`, `yarn`, `yarnpkg`, `bun`, and `bunx` shims and selects the version each project declares. Source: lines 1072 to 1135 of the installer script served by `https://vite.plus`.
10. **`gh` is installed but not authenticated.** `gh auth status` reports no logged-in host. `factory918 labels`, `doctor`, and every PR step need `gh auth login` first.
11. **The template holds 71 skills, and they reconcile against the pins.** 51 come from the open-pstack port (52 directories there, minus `no-comments`), 14 from mattpocock/skills (13 by name plus `spec-review`, renamed from `code-review`), and 6 are ours: `factory918`, `factory-start`, `knowledge`, `mode-plan`, `mode-build`, `factory-doctor`. Source: directory comparison against `research/`.
12. **Every skill directory has a `SKILL.md`, no two declare the same `name:`, and every `name:` matches its directory.** Source: a loop over `template/.agents/skills/*/SKILL.md`.
13. **Eleven skills carry `disable-model-invocation: true` in frontmatter**, and they are exactly the ones decision 3 names: Matt's seven planning entry points, our two mode switches, and `factory-start` and `factory-doctor`. `factory918` and `knowledge` stay model-invocable, so an unsure agent can reach them. `automate-me` mentions the flag in its body only, because it authors skills; that is documentation, not config.
14. **The 21 principle skills carry `user-invocable: false`**, matching §5.1.
15. **Patches 1, 2, 3, and 9 landed.** The Ticket playbook exists and the router routes any issue reference to it; `opening-a-pr.md` keeps comments and names `spec-review` and the review ladder; the only remaining `/no-comments` strings are the deliberate override and the two decision records.
16. **The Python profile's `select` list is valid on ruff 0.16.6, and both encoded opinions fire.** `T201` reports `print("running")`, and `TID251` reports `os.system(cmd)` with the profile's own message, "Use subprocess.run with a list; see CODING_STANDARDS.md". `ruff check` exits 1 on violations. Source: `uv run --with 'ruff>=0.16' ruff check` against `profiles/python/pyproject.toml`.
17. **`per-file-ignores` works as the debt ceiling the profile claims.** Adding `"m.py" = ["T20"]` dropped the `print` finding and left the banned-API finding, so a ceiling silences one rule for one file without weakening the rest.
18. **`ruff format --check` reports an unformatted file** and names how many files would be reformatted.
19. **`pyright` strict flags an untyped function** with `reportMissingParameterType` and `reportUnknownParameterType`, so `typeCheckingMode = "strict"` in `pyproject.toml` reaches the CLI. Version resolved: pyright 1.1 or newer through uv.
20. **The Python profile needs no machine-wide installs.** `uv run --with 'ruff>=0.16' ruff check` resolves and caches the tool per project, which is the invocation §7.10 already specifies. A new machine needs `uv` and nothing else for Python.

## Deviations from the spec, and the fix

| # | Spec says | Truth | Fix |
|---|---|---|---|
| 1 | §4 layout puts `sgconfig.yml` inside `ast-grep/` | `ruleDirs` then resolves to `ast-grep/ast-grep/rules` and every command fails | Done: `sgconfig.yml` moved to the project root. `ast-grep scan` and `ast-grep test` now take no flags from anywhere in the project. Update the §4 layout block. |
| 2 | §7.11 ships two rules and their tests | The tests fail out of the box, because ast-grep requires committed snapshots | Done: `ast-grep/rule-tests/__snapshots__/` added to the template, and `template/ast-grep/README.md` states that a snapshot is part of a rule. |
| 3 | `ci.yml` runs `vp dlx @ast-grep/cli scan --config ast-grep/sgconfig.yml` | `dlx` resolves the latest version, so CI silently upgrades the rule engine. Spec §0 rule 1 says to pin what you install. | Done: `@ast-grep/cli` pinned to `0.45.3` in `package.scripts.json` devDependencies, with `sg` and `sg:test` scripts. CI runs `pnpm sg`; `doctor` runs `pnpm sg:test`. One command, same version everywhere. |
| 4 | §7.2 pins `engines.node ^24` | The machine runs Node 22.17.0 | Enable the Vite+ node manager, which selects each project's declared version. Decided with Manuel on 2026-09-09; containers were considered and rejected. |
| 5 | §8.3 `doctor` checks `claude --version` | The `claude` CLI is not on PATH; Manuel runs the Claude Code desktop app | Make the check advisory, not a failure. A desktop-app user has no CLI binary and needs none. |
| 6 | T3 Code pins `vite-plus@0.3.0` | Latest is 0.3.1 | Pin 0.3.1, the version actually installed, and record it in `docs/adr/0001-toolchain.md`. |
| 7 | §9 M1 accepts "69 skill directories minus `no-comments` (68)" | The true count is 71, and it reconciles: 51 + 14 + 6 | Correct the M1 acceptance number to 71. The README already says 71. |
| 8 | §5.4.1 sweeps the `pstack:` namespace across `.agents/skills/**/*.md` | The sweep skipped `.ts`, so `setup-pstack/SKILL.md` wrote `<!-- models:begin -->` while `model-matrix.test.ts` still asserted `<!-- pstack:models:begin -->` | Done: markers fixed and the widened scope recorded in `SOURCES.md`, so `factory918 sync` re-applies it. |
| 9 | §7.2 excludes only `.repos/**` from the test run | The skills tree holds 11 vendored `*.test.ts` files, so `vp test run` would run pstack's own suite in every project and fail on defect 8 | Done: `.agents/skills/**` added to `test.exclude` and `fmt.ignorePatterns`. Vendored code is read-only upstream and belongs to neither the project's suite nor its formatter. |
| 10 | §7.2 `lint` has no ignore list at all | oxlint would lint both `.repos/**` and `.agents/skills/**` | Blocked: the key that ignores paths in `vite.config.ts` `lint` needs `vp` to confirm. Add it as soon as `vp` is installed. |

## Blocked

`npm install -g vite-plus@0.3.1` needs Manuel to run it or approve it; auto mode refuses machine-wide installs. Until `vp` exists, these spec items are unverified:

- `vp create --no-interactive` flags, and whether `--git` and `--hooks` exist.
- `vp hooks enable` and `vp hooks status`, and whether `vp install` already installs hooks (which would retire the `prepare` script).
- Multi-glob `staged`, needed by the Python profile's `"*.py": "uv run ruff format"`.
- `vp lint` rule names: `typescript/no-explicit-any` and `no-console`.
- Whether `options.typeAware` and `options.typeCheck` work together on this toolchain.
- `@oxlint/plugins` exports: `definePlugin`, `defineRule`, and `context.sourceCode.getAllComments()`.
- The subcommand that enables the node manager after an npm install of `vp`.
- `voidzero-dev/setup-vp@v1` inputs, which can only be confirmed on a real CI run.
- The `lint` key that ignores `.repos/**` and `.agents/skills/**` in `vite.config.ts` (deviation 10).
