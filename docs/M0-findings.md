# M0 findings

Ground truth for the Factory918 build: the tool versions installed on Manuel's machine, the facts checked against them, and every place the checked fact differs from `FACTORY-SPEC-v2.md`. Milestone M0 in the spec, §9.

Machine: macOS 15.6.1, arm64. Date: 2026-09-09.

Status: **complete**, except the two checks that need a GitHub repository. `factory918 apply` on a fresh `vp create` monorepo now passes every gate: format, lint, types, tests, ast-grep and build.

## Tool versions

| Tool | Version | How it got here | Spec said |
|---|---|---|---|
| vp | 0.3.1 | `https://vite.plus` installer, `VP_VERSION=0.3.1 VP_NODE_MANAGER=yes` | `vite-plus` 0.3.0 |
| node | 24.21.0 | Vite+ node manager (was 22.17.0 on the host) | `engines.node ^24`; T3 Code runs `^24.13.1` |
| pnpm | 12.3.4 | Vite+ node manager | T3 Code pins `pnpm@11.10.0` |
| npm | 10.9.2 | already present | n/a |
| python3 | 3.14.6 | already present | n/a |
| git | 2.51.2 | already present | n/a |
| jq | 1.7.1 | already present | needed by the hook scripts |
| ripgrep | 14.1.1 | already present | n/a |
| gh | 2.100.0 | `brew install gh` | needed by `factory918 labels` and `doctor` |
| uv | 0.12.12 | `brew install uv` | Python profile |
| ast-grep | 0.45.3 | `brew install ast-grep` | cross-language rules, §7.11 |
| xcodebuild, xcrun | present | Xcode | React Native profile evidence capture |

Not installed: the `claude` CLI, adb, eas, expo. `ruff`, `pyright`, and `pytest` need no install; `uv run --with` resolves them per project.

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
11. **The template holds 72 skills, and they reconcile against the pins.** 51 come from the open-pstack port (52 directories there, minus `no-comments`), 14 from mattpocock/skills (13 by name plus `spec-review`, renamed from `code-review`), and 7 are ours: `factory918`, `factory-start`, `knowledge`, `mode-plan`, `mode-build`, `factory-doctor`, `factory-retro` (added 2026-09-17). Source: directory comparison against `research/`.
12. **Every skill directory has a `SKILL.md`, no two declare the same `name:`, and every `name:` matches its directory.** Source: a loop over `template/.agents/skills/*/SKILL.md`.
13. **Eleven skills carry `disable-model-invocation: true` in frontmatter**, and they are exactly the ones decision 3 names: Matt's seven planning entry points, our two mode switches, and `factory-start` and `factory-doctor`. `factory918` and `knowledge` stay model-invocable, so an unsure agent can reach them. `automate-me` mentions the flag in its body only, because it authors skills; that is documentation, not config.
14. **The 21 principle skills carry `user-invocable: false`**, matching §5.1.
15. **Patches 1, 2, 3, and 9 landed.** The Ticket playbook exists and the router routes any issue reference to it; `opening-a-pr.md` keeps comments and names `spec-review` and the review ladder; the only remaining `/no-comments` strings are the deliberate override and the two decision records.
16. **The Python profile's `select` list is valid on ruff 0.16.6, and both encoded opinions fire.** `T201` reports `print("running")`, and `TID251` reports `os.system(cmd)` with the profile's own message, "Use subprocess.run with a list; see CODING_STANDARDS.md". `ruff check` exits 1 on violations. Source: `uv run --with 'ruff>=0.16' ruff check` against `profiles/python/pyproject.toml`.
17. **`per-file-ignores` works as the debt ceiling the profile claims.** Adding `"m.py" = ["T20"]` dropped the `print` finding and left the banned-API finding, so a ceiling silences one rule for one file without weakening the rest.
18. **`ruff format --check` reports an unformatted file** and names how many files would be reformatted.
19. **`pyright` strict flags an untyped function** with `reportMissingParameterType` and `reportUnknownParameterType`, so `typeCheckingMode = "strict"` in `pyproject.toml` reaches the CLI. Version resolved: pyright 1.1 or newer through uv.
20. **The Python profile needs no machine-wide installs.** `uv run --with 'ruff>=0.16' ruff check` resolves and caches the tool per project, which is the invocation §7.10 already specifies. A new machine needs `uv` and nothing else for Python.

### Vite+

21. **`npm install -g vite-plus` fails on this machine.** The npm global prefix is `/usr/local`, owned by `root:wheel`, so a global install needs `sudo`. The vendor installer writes to `~/.local/share/vite-plus` and needs no elevation. Source: `npm config get prefix`, and the EACCES from the install attempt.
22. **Vite+ 0.3.1 requires Node `^20.19.0 || ^22.18.0 || >=24.11.0`.** The host's 22.17.0 missed the range by one patch release, which the node manager resolved by installing 24.21.0. Source: the `EBADENGINE` warning.
23. **`vp env doctor` reports the whole install**: bin, data, cache, config and state directories, managed mode for Node and the package manager, every shim, and PATH resolution. It is the right first line of `factory918 doctor` on a new machine.
24. **`vp create` accepts `--directory <DIR>`, `--no-interactive`, `--git`, `--hooks` and `--no-agent`.** `--hooks` is the default in non-interactive mode. The built-in templates are `vite:monorepo`, `vite:application`, `vite:library` and `vite:generator`. Source: `vp create --help`, `vp create --list`.
25. **`vp create` writes `AGENTS.md`, `vite.config.ts` and `.vite-hooks/pre-commit`**, all three of which Factory918 owns. Its `AGENTS.md` is a 27-line block delimited by `<!--VITE PLUS START-->` and `<!--VITE PLUS END-->`; its `staged` config is `vp check --fix`, a thick hook, against decision 5.
26. **`vp config` only refreshes an existing delimited block.** Run against an `AGENTS.md` with no markers it changes nothing, so the scaffold's `"prepare": "vp config"` is safe beside Factory918's own letter.
27. **`vp hooks enable | status | disable` all exist**, the default hooks directory is `.vite-hooks`, and `status` prints the preference, `core.hooksPath` and the dispatcher state.
28. **`vp check` runs format, then lint, then types, and stops at the first stage that fails.** An unformatted file hides every lint and type error behind it, so anything that writes files must format before the gate runs.
29. **`lint.ignorePatterns` is the key that scopes the linter.** Source: `node_modules/vite-plus/docs/config/lint.md:12`. Vite+ ships its own docs locally, which retires §7.9's plan to vendor them into `docs/tools/vite-plus.md`.
30. **All three lint opinions fire.** A type error reports as `typescript(TS2322)`, `typescript/no-explicit-any` as `typescript(no-explicit-any)`, `no-console` as `eslint(no-console)`, and the custom rule as `project(no-todo-without-issue)`. A stale directive reports as `Unused oxlint-disable directive`.
31. **`options.typeAware` and `options.typeCheck` work together**, and `vp check` catches type errors on its own, so a separate `tsc --noEmit` pass adds nothing.
32. **The `jsPlugins` string form `"./oxlint-plugin-project/index.ts"` loads.** The scaffold's object form is not required.
33. **The commit hook formats on commit.** A file staged as `export const z   =    1;` was committed as `export const z = 1;`.
34. **`vp build` at the repo root asks for a package; the monorepo form is `vp run -r build`.**
35. **pnpm 12 gates the native binary `@ast-grep/cli` builds, and reads the approval from `allowBuilds` in `pnpm-workspace.yaml`**, not from `pnpm.onlyBuiltDependencies` in `package.json`. Unapproved, the binary still runs but warns and resolves itself on every invocation.
36. **A bare `vp create` project passes `vp check` completely.** Every formatting failure seen later came from files Factory918 or pnpm added.
37. **`factory918 apply` on a fresh monorepo now passes format, lint, types, tests, `ast-grep scan`, `ast-grep test` and `vp run -r build`.** The four remaining `doctor` failures need a human: `gh auth login`, a GitHub repository for labels, `/setup-pstack` for the models sheet, and `/factory-start` to fill the `AGENTS.md` slots.

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
| 10 | §7.2 `lint` has no ignore list at all | oxlint linted the vendored skills through the `.claude/skills` symlink and reported 159 errors | Done: `lint.ignorePatterns` added, covering `.repos/**`, `.agents/skills/**` and `.claude/skills/**`. `test.exclude` and `fmt.ignorePatterns` gained the symlink path too. |
| 11 | §8.1 `apply` never overwrites a file that exists locally | `vp create` writes `AGENTS.md`, `vite.config.ts` and `.vite-hooks/pre-commit` seconds earlier, so Factory918's versions never landed and every session loaded Vite+'s blurb instead of Manuel's letter | Done: `init` passes `--no-agent`, and `apply --scaffold` replaces the four files Factory918 owns. `apply` without the flag keeps its additive rule for projects that already exist. |
| 12 | §8.1 `init` runs `vp create <tpl> ... -- "$dir"` | That passes the target directory as a template option, so the project scaffolds into the current directory | Done: `--directory "$dir"`. |
| 13 | §8.3 `doctor` checks for duplicate skill names | macOS `wc -l` pads its output, so `[ "       0" = 0 ]` was false and the check could never pass | Done: compare the text instead of counting it. |
| 14 | §8.3 `doctor` checks that `/factory-start` filled the slots | It greps whatever `AGENTS.md` is present, so it passed on Vite+'s file and hid deviation 11 | Done: a preceding check asserts the file is Factory918's. |
| 15 | §8.1 `apply` merges `package.scripts.json` | It printed a TODO, so no scripts, engines or devDependencies were ever merged | Done: merged with `jq`; the project's own values win. |
| 16 | §7.3 the plugin imports `@oxlint/plugins` | Nothing declared it, so the plugin failed to load and **all** linting stopped before analysis | Done: pinned at 1.82.0 in the template's devDependencies. |
| 17 | §7.3 ships the rule with a test beside it | The test imported `vitest`, which is not resolvable, and asserted `expect(true).toBe(true)` | Done: imports `vite-plus/test`, the scaffold's own idiom, and tests the rule's two real seams in 10 cases. |
| 18 | §7.3 reads `context.options[0]?.maxOccurrences` | `options[0]` is `JsonValue`, so the property access does not typecheck | Done: `debtCeiling()` narrows the value at runtime, with no cast, per `CODING_STANDARDS.md`. |
| 19 | §7.3's rule explains itself in a comment | The comment contains a bare `TODO`, so the rule reported its own source file | Done: reworded. The rule was right. |
| 20 | §7.2 keeps a separate `"typecheck": "tsc --noEmit"` | `typescript` is not a root dependency, so `pnpm typecheck` exits 127, and `vp check` already reports type errors | Done: dropped from the scripts, CI and `doctor`. |
| 21 | §7.8 CI runs `vp build` | At the root of a monorepo that asks for a package | Done: `vp run -r build`. |
| 22 | §7.2 scripts alias `dev`, `build`, `test`, `lint`, `fmt` and `check` | All six are `vp` built-ins, and vp prints a note about the ambiguity | Done: the template now ships only `prepare`, `sg` and `sg:test`. |
| 23 | §7.9 vendors Vite+'s docs into `docs/tools/vite-plus.md` | Vite+ installs its own docs at `node_modules/vite-plus/docs` | Point `AGENTS.md` at the local path instead of copying it. |

## M1 and M2 acceptance (2026-09-16)

M1: the 71 skills reconcile (fact 11), no duplicate names (12), the invocation flags match decision 3 (13), and the patches landed (15). `patches/` now holds eleven unified diffs plus `series`; copying the pins, dropping `no-comments`, renaming `code-review` to `spec-review`, adding `ticket.md` and applying the series reproduces `template/.agents/skills` byte-for-byte.

M2: `INDEX.md` lists all 118 files with exact line counts, no chunk exceeds 240 lines, and every mini-TOC entry resolves to its heading (checked programmatically, not five spot checks). `/knowledge why do comments stay` answered with `DECISIONS.md:19` after 143 lines read. The `factory918` table names an entry point in every row.

Glue-skill fixes from that review: `factory-doctor` duplicated the CLI's check list and drifted within one milestone, so it now runs `factory918 doctor` and reports the table; it is model-invocable because it is read-only, and `factory-start` can reach it. `knowledge` said the index was under 100 lines (it is 127) and named the wrong fallback path (`docs/knowledge`; projects carry `docs/factory918`, with no mini-TOC). The router's last step read `/factory918 doctor`, which is not a command.

## M4 acceptance (2026-09-16)

Each hook was fed the JSON Claude Code sends and checked on exit code, state file and output. `mode.sh`: `/grill-with-docs` and `/to-tickets` set `planning`; `#42`, `/mode-build` and `/poteto-mode` set `execute`; a plain prompt leaves the state alone and prints the current phase. `block-dangerous-git.sh`: exit 2 with a BLOCKED line for pushes to `main` or `master`, `-f` and `--force`, `reset --hard`, `clean -f`, `branch -D`, `checkout .` and `restore .`; exit 0 for a feature-branch push, `--force-with-lease`, `git status`, and a pipeline that merely mentions `main`. `session-start.sh` prints the mandate, which names `factory918`. `format-on-write.sh` formatted a file written as `{a:1,\n b:2}` to `{ a: 1, b: 2 }`, exited 0 on a `.txt`, and left a vendored skill file byte-identical, because it goes through `vp fmt` and the project's ignore list. The interview half of M4 (`/factory-start` on a real project) needs a human in a session and is the first thing to run on Manuel's first project.

## M5 and M6 acceptance (2026-09-16)

M5, on a private throwaway repository `factory918-m5-throwaway` under Manuel's account: `factory918 labels` created the planning, wayfinder and size labels; the push to `main` ran CI green (which confirms the `setup-vp@v1` inputs); a clean PR went green and received `size:XS` from `pr-size.yml`; a PR with a deliberately failing test went red on the `Test` job while `Check` stayed green; the job names GitHub reports are `Check` and `Test`, the contexts branch protection would require. The PR template is in the repository. Three facts came out of it. `vp create --git` uses the machine's git default branch, which is `master` when `init.defaultBranch` is unset, so `init` now runs `git branch -M main`. **GitHub refuses branch protection on a private repository under the free plan** ("Upgrade to GitHub Pro or make this repository public"), so "main refuses a merge while Check is red" cannot be enforced there; see provisional decision P3. The token `gh auth login` issued has no `delete_repo` scope, so the throwaway is still there; `gh auth refresh -s delete_repo` then `gh repo delete Zenoctra/factory918-m5-throwaway --yes` removes it. The ticket run and the `/unslop` auto-fire need a session and belong to the first real project.

M6, Python: `factory918 apply --profile python --name demo` on a fresh monorepo writes `python/demo/` (pyproject, a package, a smoke test, `uv.lock`), `.github/workflows/python.yml`, and the `"*.py": "uv run --project python/demo ruff format"` staged task; all six steps of `python.yml` exit 0 locally; `print()` fails `ruff check` (T201) and `ast-grep scan`; `os.system` fails `ruff check` (TID251) with the profile's message; a `.py` file committed as `x   =   1` lands as `x = 1`. One profile fix: `pytest` could not import the `src/` package because nothing installs it, so `pytest.ini_options` gained `pythonpath = ["src"]`. Multi-glob `staged` in `vite.config.ts` was verified on its own first: a `"*.py"` task ran beside the `"*"` formatter.

M6, React Native: `apply --profile react-native` writes `apps/mobile/eas.json` and `mobile-fingerprint-check.yml`, and prints the `create-expo-app` command. The workflow no longer names T3 Code's paid Blacksmith runner or its package names (`ubuntu-latest`, `packages/shared/**`), so patch 8 in `SOURCES.md` is no longer verbatim. Scaffolding an Expo app under `vp check` and the simulator screenshot are not run here; they are the first checks on Manuel's first mobile project.

## M7 acceptance (2026-09-16)

`update`, run from a throwaway clone of this repository tagged v0.3.0 and v0.4.0 against a project applied at 0.3.0: a local edit to `AGENTS.md` survived and the template's change to the same file merged in cleanly with no `.factory-merge`; `docs/agents/new-in-0.4.md` was added; `docs/agents/feedback-loops.md`, deleted locally, stayed deleted and the manifest records `deleted`; `CODING_STANDARDS.md`, edited on the same line on both sides, produced `CODING_STANDARDS.md.factory-merge` with `<<<<<<< project` / `>>>>>>> template v0.4.0` markers and the project's file untouched; 245 files were unchanged. `git merge-file` supplies the merge, so the markers are the ones every reviewer knows. Profile files (`python/<name>/`, `eas.json`, the profile workflows) are written once by `apply --profile` and not managed by `update`.

`sync`, run in this repository: 51 pstack skills and the agents re-copied from the open-pstack pin with `no-comments` and `comment-sicko.md` dropped, 14 Pocock skills re-copied with `code-review` landing as `spec-review`, our six skills and `ticket.md` kept, all eleven patches applied, and `git status` clean under `template/` afterwards. A patch that no longer applies is reported as `FAILED` and the command exits non-zero.

## The models sheet (2026-09-16)

The vendored `/setup-pstack` requires all four matrix families (Fable, Opus, Codex Sol, Grok) to pass a live probe before it writes anything, and pstack's launcher never falls back, so on a Claude-only machine the Feature playbook's default delegate (`grok:grok-4.6@xhigh`) would drop out on the first ticket. `factory918 install` now writes `~/.claude/pstack-models.md` from `machine/pstack-models.fable.md` (renamed on 2026-09-17 when the opus preset joined it), every role on `claude:opus` or `claude:fable` with effort as the cost lever, and adds the `@` include to `~/.claude/CLAUDE.md`. Native lanes exist for every effort of both families (`.claude/agents/pstack-*-*.md`); nothing at dispatch time requires the other two families. pstack has no Sonnet family, so decision 13's Sonnet roles run `claude:opus@medium`. Decision P5. The first ticket on a real project is the live check of this sheet.

## Guided entry (2026-09-16)

`factory918 doctor` now prints the fix under every failing line and refuses, with one guided line, to run outside a Factory918 project. `/factory918` runs it first and hands a new user the first fix as their only next step; `/factory-start` runs the same preflight before interviewing. In this clone with `~/.local/bin` not yet on PATH, `/factory918 I'm new, what do I do?` produced the PATH line and nothing else, which is the intended behaviour.

## Worklist pass (2026-09-17)

Everything queued after M7 landed in one pass. The spec's §4, §5.5, §7.2, §7.3 and §8.1 now match the template and the CLI; the manifest schema has its real path and the `profiles` and `factory` fields; the Python profile README carries `pythonpath` and says what was verified; branch protection is out of the interview, the router, the manual, the review ladder and `init`'s closing line. The doctor checks the `vp` version against the ADR pin, that the two machine symlinks resolve to the same clone, and that `template/` and `profiles/` are reachable from the command. `apply` records the applying clone's path in the manifest and `update` warns when a different clone runs. `install` names `git`, `jq` and `python3` when they are missing. The README and manual say which platforms this runs on and give Linux and Windows commands beside the macOS ones. The router carries a table of the phrases people use for each setup step and what to do for each.

The pass found one more real bug: run through the `~/.local/bin/factory918` symlink, the script took the link's directory as the factory, so `template/` and `profiles/` were empty from its point of view and `apply` copied nothing. Every earlier test had invoked `./factory918.sh` directly. Fixed by resolving the link; the doctor's first line now catches the class. Two hardenings fell out of the retest: an empty profile file no longer counts as present, and `.venv/` is git-ignored because `uv run` creates it inside the project. With the profile pushed to the M5 throwaway (PR 3), `python.yml` ran on GitHub for the first time and passed every step: `astral-sh/setup-uv@v6`, `uv sync --frozen`, `ruff format --check`, `ruff check`, `pyright`, `pytest`, `uv audit`.

## First spec-review on the factory (2026-09-17)

`/spec-review feat/reviews-read-the-ask` on PR #14 ran to completion with both axes: the Spec axis read issue #8 through the commit's `Closes #8`, the Standards axis read the new `CODING_STANDARDS.md` and `AGENTS.md`. It found four documented breaches and three smells on one axis and six spec findings on the other, six of which were fixed on the branch in the following commit; the report is a comment on #14.

## Merge mechanics and the doctor (2026-09-17)

Verified on the factory repository itself: a stacked PR retargets to `main` only when the merged parent branch is deleted (PR #3 was stranded on `feat/self-host` when it was not); GitHub shows a closing-issue link only on PRs whose base is the default branch, so a stacked PR links its ticket once it retargets. `find -mtime +N` on a directory is supported by both BSD and GNU find and reads the directory's own mtime, which moves only when its direct entries change. 2026-09-17: the doctor's branch line was exercised on the fixture, which has no `origin`, so it compares against local `main`; `main`, and a branch at the same commit as `main`, print PASS. A merged branch prints the `already in main` NOTE, and so does a branch at `main~1` with no commits of its own, since git cannot tell the two apart. A branch whose merged PR was squashed is not an ancestor of `main`, so the doctor asks `gh pr list --head <branch> --state merged` before calling it behind (verified: 1 for `feat/act-on-the-reviews`, 0 for an open branch). A branch with its own commit behind `main` prints the `behind main` NOTE. An unborn `main` and a detached HEAD each get their own NOTE. Against a bare clone of the fixture as `origin`: `main` current prints PASS; `main` one commit behind prints `NOTE  branch main is 1 commit behind origin/main` with `git pull`; the merged and the behind branch print their NOTEs; a remote that cannot be fetched adds `(fetch failed, compared against the last fetch)` to the line. Each line was asserted exactly, not grepped for. 2026-09-17: `gh repo view --json deleteBranchOnMerge` on Zenoctra/factory918 returns `true` with gh 2.100.0; the doctor's delete-branch-on-merge line was exercised on the fixture with the factory's remote added, printing PASS, and with a `gh` shim on PATH answering `false`, printing the NOTE and its `gh repo edit --delete-branch-on-merge` fix. With the query's failure tolerated inside the substitution, the fixture's doctor, which has no remote, prints all 26 lines.

`vp create` 0.3.1 refuses an absolute `--directory` ("Absolute path is not allowed"), so the fixture flow runs from `/tmp` with `--directory fx`.

## What a review costs (2026-09-17)

Measured on PR #37 with the brief shape of #39: the diff, the standards sections and the ticket pasted into each brief, nothing to fetch. The Standards sub-agent (`claude:opus`) cost 65,887 tokens over 2 tool uses; the Spec sub-agent (`claude:fable`) 55,627 over 1; the first run of the same review with a file pointer to the diff cost 70,112 and 57,376. A sub-agent that only replies "ok" with no tool costs 45,963 tokens here, so the floor of one sub-agent is about 46K and comes from the harness's context (the tool schemas and the skill list), not from discovery. Ticket #33 asked for one review under half of 130K; two sub-agents cannot reach it in this harness, whatever the brief. Pasting cuts tool uses, which is where the rest goes: from 4 to 2 on the Standards axis. Getting under 65K means one sub-agent per review, or the orchestrator running one axis itself, which is Manuel's call. To re-measure: dispatch each sub-agent with the Agent tool and read the `subagent_tokens` figure its result carries.

## Hook input and sub-agent identity (2026-09-18)

Verified on Claude Code 2.1.271 inside the desktop app 2.110.0 (Agent SDK 0.3.271), for #74. A `PreToolUse` hook added to `.claude/settings.local.json` fires on the next tool call without a restart. Its stdin JSON from the orchestrating session carries `session_id`, `transcript_path`, `cwd`, `scratchpad_dir`, `prompt_id`, `permission_mode`, `effort`, `hook_event_name`, `tool_name`, `tool_input` and `tool_use_id`, and no agent field. The same call from a sub-agent started with the Agent tool carries two more keys, `agent_id` (the sub-agent's id) and `agent_type` (`general-purpose` for one started without a named type), with the same `session_id` and `transcript_path` as its parent. The environment is identical for both (`CLAUDE_CODE_SESSION_ID`, `CLAUDE_PID`, no agent variable), so the presence of `agent_id` in the JSON is the one way a hook tells a sub-agent from the orchestrator, and the delegation hooks use it. A `Read` with `limit` shows as `tool_input.limit`; a whole-file read has neither `offset` nor `limit`. The desktop app's session has no todo-list tool (no `TodoWrite` in the tool list), so poteto-mode's todo list was kept as a file under `.claude/state/` instead. The CLI harness could not be run from this session (the desktop app's bundled `claude` binary answers `Not logged in`). The docs agent's reading of the Claude Code tools reference (code.claude.com/docs/en/tools-reference, 2026-09-18) and a GitHub report is that the todo tools were removed from Claude Code for current models in 2.1.233 and return only with `CLAUDE_CODE_ENABLE_TODO_TOOLS=1`; not verified against a running CLI. Either way poteto-mode's non-negotiable (playbook steps copied into a todo list) has no tool in the harnesses in use unless that variable is set, and the file under `.claude/state/` is the substitute. Once the hook was registered in the repository's `.claude/settings.json`, it fired on the orchestrating session's next call without a restart: a whole `Read` of `factory918.sh` (423 lines) and a `cat` of it through Bash were blocked with the read-cap line, and a `Read` with `offset` and `limit` passed.

## ShellCheck (2026-09-22)

ShellCheck 0.11.0, Homebrew, macOS arm64, is the pin: `shellcheck-v0.11.0.linux.x86_64.tar.xz` sha256 `8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198`, `shellcheck-v0.11.0.darwin.aarch64.tar.xz` sha256 `56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79`. At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0 after five fixes and the directives; the gate itself, `template/.github/shellcheck.sh`, and `tests/shellcheck/gate.sh` join the 18, so the factory's gate checks 20 files. The severity floor is the default, not `warning`: SC2086, the unquoted expansion the ticket's Problem names, is info level, so `--severity=warning` leaves that class passing (6 findings at `warning`, 1 at `error`). `--external-sources` is required, not optional: without it the two spec-review tests report SC1091 and three SC2154 on the sourced `tests/spec-review/layout.sh`, so a lane checking one changed file would disagree with CI; `-x` resolves the sourced path relative to the working directory, so the gate runs from the repository root, and `# shellcheck source-path=SCRIPTDIR source=layout.sh` above the `.` line lets a per-file run from any directory resolve it too. No `--shell`: forcing `-s bash` hides SC3030 and SC3054 in `tests/spec-review/fake-gh.sh`, which is `#!/bin/sh`. A directive's reason must be a second comment on the same line. `# shellcheck disable=SC2016 # reason` parses, `# shellcheck disable=SC2016 reason` is SC1073 plus SC1072, an error, and `# shellcheck shell=bash disable=SC2034 # reason` on one line clears SC2148 on a file with no shebang. The SC2115 fix, `"${skills:?}/$n"` at the two `rm -rf` lines in `cmd_sync`, states an invariant rather than fixing a live bug, because `$skills` is a literal suffix on `$TEMPLATE` and is never empty. The download path was proven on `ubuntu-latest`, whose image carries an off-pin ShellCheck: Factory CI runs 35747640954, 35749314626, 35750682737 and 35751339998 on PR #96 ran the gate in both jobs, each logging `/tmp/shellcheck-0.11.0/sc.tar.xz: OK` and then `files checked: 20` in the factory job and `files checked: 11` in the fixture. The one red run, 35750682737, was the checksum tool's `OK` line reaching stderr on that path alone, which the gate's test compares exactly; the tool's stdout is discarded now, and a mismatch is refused with the tool's own `WARNING: 1 computed checksum did NOT match` on stderr, which `tests/shellcheck/gate.sh` asserts with a bogus cached tarball. A change to that path is proven with a cached real tarball and ShellCheck hidden from PATH, since a machine with the pin on PATH never runs it.

## Still open

- A review costs two sub-agent floors (about 92K) before any reading; one sub-agent per review, or the orchestrator running one axis, would halve it. Manuel's call (ticket #33).
- The React Native profile's Expo app under `vp check`, the fingerprint workflow on a real PR, and a simulator screenshot (first mobile project). The Python profile has now run end to end on GitHub.
- `vp migrate` on a brownfield repo (M8).
- `gh auth login` and `/setup-pstack` are human steps; `/factory-start` is M4.

2026-09-18. The factory checkout has no `.claude/agents/`, so the `pstack-<family>-<effort>` lanes named in `models.md` do not exist here; the Agent tool's `model` field (`fable`, `opus`) dispatched every lane of #76 and effort could not be set. A project made by `factory918 apply` gets the lanes from `template/.claude/agents/`.

2026-09-22. A sixth core document costs one CORE_DOCS tuple in tools/build_knowledge.py and no other code: build_core copies every core document except CONVERSATION-DIGEST.md into template/docs/factory918/, apply copies that directory, doctor checks only PHILOSOPHY and MANUAL. factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).

2026-09-22. `gh issue edit N --body-file F` (gh 2.100.0) replaces the whole body with F; there is no append. To add a section, read the body first (`gh issue view N --json body -q .body`), add the section at the end and write the whole file back; done on #42 for the #89 amendment, and Ticket step 6 says so (#89).

2026-09-22. The 2026-09-17 finding above (a closing-issue link exists only on a PR whose base is the default branch) reached `overlap.sh`'s coverage rule for #91: PR #96, opened against `main`, linked #88 and kept the link after `gh pr edit --base feat/design-artifact-on-ticket`; PR #99, opened against `feat/shellcheck`, had an empty `closingIssuesReferences` although its body ends with `Closes #90`, so `overlap.sh 91` exited 1 under a go naming #90. Retargeting #99 to `main` created the link within eight seconds and it survived the retarget back; the GraphQL timeline (`BaseRefChangedEvent`, `ConnectedEvent`) shows both. gh 2.x on GitHub.com; ticket #100 makes the check read the body's closing line.
