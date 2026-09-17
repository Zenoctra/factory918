# Profile: python

The TypeScript deterministic layer, rung for rung, for Python packages. Two shapes: a package inside the product monorepo (`python/<name>/`, default) or a standalone repository. Tooling is Astral's: `uv` (project, lockfile, Python version), `ruff` (formatter and linter), plus `pyright` in strict mode and `pytest`. Astral joined OpenAI's Codex team in March 2026; the tools remain open source and actively released (ruff 0.16, July 2026; `uv audit`, June 2026). `ty`, Astral's type checker, was in beta at the time of writing and is the likely future swap for pyright. **[secondary: astral.sh/blog]**

## Rung by rung

| Rung | TypeScript | Python |
|---|---|---|
| Unrepresentable state | discriminated unions, branded types, `never` | `Enum`, `Literal`, `NewType` for IDs, frozen `dataclass`, `match` with exhaustiveness (`assert_never`), pydantic models at boundaries |
| Lint / banned API that fails CI | oxlint + plugin | `ruff check` with a curated `select`; banned imports and calls via `[tool.ruff.lint.flake8-tidy-imports.banned-api]` with a message; cross-language rules via `ast-grep` |
| Debt ceiling | `maxOccurrences` | `[tool.ruff.lint.per-file-ignores]` (whole rule per file) plus a ratchet test that counts occurrences and asserts the count only falls |
| Formatter | `vp fmt` | `ruff format` |
| Type check | `tsc --noEmit` | `pyright` (`strict = true`) |
| Tests | Vitest | `pytest` |
| Security | (later) | `uv audit` in CI |
| Commit hook | `vp staged` → `vp fmt` | monorepo: `staged: { "*.py": "uv run ruff format" }` in `vite.config.ts` (verify multi-glob support at M0); standalone: `pre-commit` (or `prek`) with the official `ruff-pre-commit` format hook only |
| CI | Check + Test jobs | a `python` job: `uv sync --frozen`, `uv run ruff format --check .`, `uv run ruff check .`, `uv run pyright`, `uv run pytest`, `uv audit` |

## Files this profile adds

- `python/<name>/pyproject.toml` (template below).
- `.github/workflows/python.yml` (template below); in a monorepo it runs only when `python/**` changes.
- `.pre-commit-config.yaml` for standalone repos only.
- `ast-grep` rules apply to `.py` files as they do to `.ts`.

### `pyproject.toml` (DRAFT)

```toml
[project]
name = "<name>"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = ["pytest>=8", "pyright>=1.1", "ruff>=0.16"]

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "B", "UP", "N", "SIM", "TID", "RUF", "PL", "PT", "T20"]   # T20: no print in shipped code
ignore = ["PLR0913"]                                                                  # too-many-arguments: judgment, not a rule

[tool.ruff.lint.flake8-tidy-imports.banned-api]
"os.system".msg = "Use subprocess.run with a list; see CODING_STANDARDS.md"
# Add the project's own banned APIs here as corrections recur (the ledger decides).

[tool.ruff.lint.per-file-ignores]
# Debt ceilings for old code; delete the entry when the file is clean.
# "legacy/thing.py" = ["T20"]

[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"
reportMissingTypeStubs = false

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = "-q"
```

### `.github/workflows/python.yml` (DRAFT)

```yaml
name: Python
on:
  pull_request:
    paths: ["python/**", ".github/workflows/python.yml"]
  push:
    branches: [main]
    paths: ["python/**"]
jobs:
  python:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    defaults: { run: { working-directory: python/<name> } }
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v6
        with: { enable-cache: true }
      - run: uv sync --frozen
      - run: uv run ruff format --check .
      - run: uv run ruff check .
      - run: uv run pyright
      - run: uv run pytest
      - run: uv audit
```

### `.pre-commit-config.yaml` (standalone repos only, DRAFT)

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.16.0          # pin to the installed ruff
    hooks:
      - id: ruff-format   # formatter only on commit; CI owns lint, types, tests
```

## Verification and evidence

Same conventions as `docs/agents/evidence.md`. For scripts: the command, stdout, stderr and exit code. For services: an HTTP smoke test in `tests/` using the app's own client, and a read-back of any stored value. `create-verification-skill` interviews the repo and will pick `uv run <entry>` or the service's port; Theo's `test-t3-app` remains the shape.

## Verified and not

Verified on 2026-09-16 (see `docs/M0-findings.md`, M6): the `select` list against ruff 0.16.6, T201 and TID251 firing with the profile's message, `per-file-ignores` as a debt ceiling, pyright strict, `uv audit`, every step of `python.yml` locally, and a `"*.py"` task beside `"*"` in `staged`. `pythonpath = ["src"]` is required: nothing installs the package, so pytest cannot import it otherwise. `setup-uv@v6` on GitHub: first run on the M5 throwaway, 2026-09-17.
