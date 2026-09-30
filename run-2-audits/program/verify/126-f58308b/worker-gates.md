verdict: PASS

Slice: gates. PR #126 (ticket #107), head `f58308b5eae3f6617cf3a5200e7679e5737a5702`, base `0edf8c8`.
Run in my own worktree `.claude/worktrees/agent-a2a0d7ee9aa092f63`, detached at the head; fixture work in a
private `mktemp -d` (`/private/tmp/v126gates.AFGtOg`, removed afterwards).

## Setup

- `git rev-parse HEAD` -> `f58308b5eae3f6617cf3a5200e7679e5737a5702`. Exit 0. SHA confirmed.
- `git merge-base --is-ancestor 0edf8c8952e7563ec862e460f71becde4506bd96 HEAD` -> exit 0. Base is an ancestor.
- `git log --oneline 0edf8c8..f58308b` -> six commits: `8a40823` (tests), `3b8c81b` (script + briefs), `94f4847`
  (SKILL.md + `keep_files`), `e0e1130` (P107), `3fbc71b` (SIGPIPE fix), `f58308b` (ShellCheck count). Exit 0.
- `git diff --stat 0edf8c8..f58308b` -> 11 files, +611/-9. Exit 0.

## 1. Every line of AGENTS.md "Verifying" at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh'
  'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` -> `ShellCheck 0.11.0, files checked:
  24`. Exit 0. The AGENTS.md line at this SHA says 24; at `0edf8c8` the same command reported 23 and the line said
  23. The count line and the reality agree at both ends.
- `bash tests/shellcheck/gate.sh` -> `ok 17 assertions`. Exit 0.
- `bash tests/hooks/delegation.sh` -> `ok 55 assertions`. Exit 0.
- `bash tests/spec-review/review-comment.sh` -> `ok 298 assertions`. Exit 0.
- `bash tests/spec-review/review-brief.sh` -> `ok 1294 assertions`. Exit 0. Matches the owner's report.
- `bash tests/poteto-mode/overlap.sh` -> `ok 57 assertions`. Exit 0.
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`. Exit 0.
- `bash tests/knowledge/provisional-ids.sh` -> `provisional-ids: 26 assertions passed`. Exit 0.
- `bash tests/eval/reviewer/refusals.sh` -> `all 230 checks passed`. Exit 0.
- `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`. Exit 0.
- `python3 tools/build_knowledge.py` -> `knowledge files: 119 → docs/knowledge`, then `git status --porcelain`
  empty. Exit 0.
- `./factory918.sh sync` -> `vendored: 72 skills`, then `git status --porcelain` empty (0 lines). Exit 0.
- Fixture flow, run with the relative `--directory` per #123, from `/private/tmp/v126gates.AFGtOg`:
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` (vp v0.3.1, node 24.21.0,
    pnpm 12.5.1) -> `Scaffolded fx`. Exit 0. Then `git add -A && git commit -qm "chore: initial commit"` -> `c8ec988`.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` -> every doctor line PASS except the two
    that cannot pass without a GitHub remote or a `/factory-start` interview (`labels present`, `slots filled`),
    the same two CI tolerates (it pipes the step through `tail -30`).
  - In fx: `bash .github/shellcheck.sh` -> `files checked: 12`, exit 0. `vp check` -> 63 files formatted, no lint
    or type errors, exit 0. `vp test run` -> `Test Files 2 passed / Tests 10 passed`, exit 0. `pnpm sg:test` ->
    `2 passed; 0 failed`, exit 0. `pnpm sg` -> clean, exit 0.
  - In fx/python/demo (the steps of the Python workflow): `uv sync --frozen` exit 0; `uv run ruff format --check .`
    -> `2 files already formatted`; `uv run ruff check .` -> `All checks passed!`; `uv run pyright` -> `0 errors, 0
    warnings, 0 informations`; `uv run pytest` -> `1 passed`; `uv audit` -> `Found no known vulnerabilities`. All exit 0.
- `docs/M0-findings.md` is unchanged by this PR and nothing here was verified against a new tool version, so the
  dated-line rule does not bite.

## 2. Every test under tests/, assertion counts at head and at 0edf8c8

| test | 0edf8c8 | f58308b |
|---|---|---|
| `tests/shellcheck/gate.sh` | 17 | 17 |
| `tests/hooks/delegation.sh` | 55 | 55 |
| `tests/spec-review/review-comment.sh` | 298 | 298 |
| `tests/spec-review/review-brief.sh` | **1104** | **1294** (+190) |
| `tests/poteto-mode/overlap.sh` | 57 | 57 |
| `tests/spec-review/no-stale-wording.sh` | (no count, ok) | (no count, ok) |
| `tests/knowledge/provisional-ids.sh` | 26 | 26 |
| `tests/eval/reviewer/refusals.sh` | 230 | 230 |

All eight exit 0 at both ends. 1294 matches the owner's report; the change adds 190 assertions and moves no
existing count. `find tests -name '*.sh'` lists three more files that are not gates and were not run:
`tests/spec-review/layout.sh` (sourced helper, no shebang), `tests/spec-review/fake-gh.sh` (the `gh` stub the
suite and CI copy onto PATH), `tests/eval/reviewer/rebuild.sh` (a corpus rebuild tool needing `refs/keep/103/*`).

## 3. Knowledge, sync, and the patch reproducing byte for byte

- `check_knowledge.py` and `build_knowledge.py` -> clean, above.
- `./factory918.sh sync` -> `git status` 0 lines, which is itself the byte-for-byte proof for all 72 vendored skills.
- Independently for the changed patch: upstream is
  `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` (`factory918.sh:391` copies exactly
  that path into `template/.agents/skills/spec-review`; there is no `spec-review` directory under `research/`, the
  rename is what the patch does). Copied it to a private dir, `patch -p1 -s < patches/mattpocock/spec-review.SKILL.md.patch`
  -> exit 0, then `cmp <patched> template/.agents/skills/spec-review/SKILL.md` -> exit 0.
- The pstack upstream path `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/` is referenced at
  `factory918.sh:382`; no pstack patch changed in this diff, and all 19 applied cleanly during sync.
- `SOURCES.md` item 6 gains the description of the new behaviour (`git diff --word-diff`): the reading-pack section,
  its cutoffs, the sweep exception, the refusal before writing state, and the SKILL.md sentence. The vendored-skill
  rule (patch + `series` + `SOURCES.md`) is satisfied.

## 4. ShellCheck on every touched *.sh

- `git diff --name-only 0edf8c8..f58308b | grep '\.sh$'` -> `factory918.sh`,
  `template/.agents/skills/spec-review/scripts/reading-pack.sh`,
  `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/spec-review/review-brief.sh`.
- `bash .github/shellcheck.sh` over exactly those four -> `ShellCheck 0.11.0, files checked: 4`, exit 0.
- The AGENTS.md line's count is 24 and the run reports 24 (see 1).

## 5. CI, and the SIGPIPE fix

- `gh run view 35858370668 --repo Zenoctra/factory918 --json headSha,conclusion,status,jobs` -> headSha
  `f58308b5eae3f6617cf3a5200e7679e5737a5702`, `completed success`; jobs `Factory success`, `Fixture success`. Both
  jobs, no others. `gh pr view 126 --json statusCheckRollup` -> `Factory SUCCESS`, `Fixture SUCCESS`, `MERGEABLE`.
- `gh run list --branch feat/review-reading-pack` -> only two runs: `35857124541` at `e0e1130` failure, then
  `35858370668` at `f58308b` success.
- `3fbc71b` fixes the cause. `tests/spec-review/review-brief.sh:87` `section()` streams the whole pack section into
  a reader; the old `fence` and `notext` readers called `awk ... exit` on their first answer, killing `section`
  with SIGPIPE on its next write, which under `set -o pipefail` failed the helper. The commit rewrites both as
  state machines with no `exit`, deciding in `END`, and adds a comment at `:85-86` stating the invariant. It did
  not disable `pipefail`, add `|| true`, or trap the signal. `at()` was changed from `grep ... | head -1` to
  `grep -m 1 ... | cut` for the same reason (`:143`).
- Swept the rest for the same shape. In `tests/spec-review/review-brief.sh` the four readers of `section` (`entry`
  `:96`, `fence` `:108`, `none` `:119`, `notext` `:126`) now all run to `END` with no `exit`; `section` itself,
  `close_of` and `line_of` read files, not pipes. In `reading-pack.sh` no reader of a pipe exits early:
  `:152` `git diff | awk` (awk reads to EOF), `:163` `units ... < blob > units` (no pipe), `:182`
  `while ... | sort -n | awk` (awk reads to EOF), `:142` `read < <(awk)` (awk emits one line). One residual is
  noted below.

## 6. DECISIONS

- `grep -c '^| P107 ' docs/knowledge/core/DECISIONS.md` -> 1. `grep -o '^| P[0-9]*[b-z]\? ' | sort | uniq -d` ->
  empty: no duplicate id in the table. `check_knowledge.py` (which refuses duplicates and malformed ids) passes.
- `git diff 0edf8c8..f58308b -- docs/knowledge/core/DECISIONS.md | grep -E '^[-+]\| P(20|103|105|106|110) '` ->
  empty. P20 (`:89`), P105 (`:101`), P110 (`:102`), P103 (`:103`), P106 (`:104`) are all present and untouched;
  the only row change is the appended P107, mirrored into `template/docs/factory918/DECISIONS.md`, with
  `docs/knowledge/INDEX.md` and the DECISIONS header line count moved 104 -> 105 by the build.
- Tests before the script: `git checkout --detach 8a40823` (the test commit, parent of `3b8c81b` which adds
  `reading-pack.sh`), then `bash tests/spec-review/review-brief.sh` -> exit 1 with
  `FAIL (1W): pk-w.standards-brief.md has no entry / ### pk/s.sh, whole, 1 line`. `(1W)` at
  `tests/spec-review/review-brief.sh:1556` is the first assertion of the first new cell ("Row 1: the small files").
  The test genuinely fails before the script exists, at its first new cell.

## 7. The script in keep_files and in a fixture project

- `factory918.sh:385` `keep_files` gains `spec-review/scripts/reading-pack.sh`, so `sync` preserves it across the
  `rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review"` at `:391`. Proven live: the sync run above
  left `git status` empty with the script still present.
- After `factory918.sh apply` into the fixture, `find <fx> -name reading-pack.sh` ->
  `<fx>/.agents/skills/spec-review/scripts/reading-pack.sh`, mode `-rwxr-xr-x`, and `cmp` against
  `template/.agents/skills/spec-review/scripts/reading-pack.sh` -> exit 0.
- End to end in the fixture (the CI fixture step, run locally): `PATH=<fake-gh>:$PATH
  .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --ticket 1 --blast-radius <blast.md>` -> exit 0,
  printing round 1 and both brief paths. `<dir>` holds `pack.md` (83,648 bytes). The section carries 158 `### `
  entries and one `Not carried, over the pack's 65536 bytes: ...` line naming 117 entries. Measured carried text
  inside the fences: 64,887 bytes, at or under the 65,536 budget. Both briefs' fences balance and the only
  top-level headings outside fences are the brief's own, in order: `## Commits`, `## Changed files`,
  `## Blast radius`, `## What it does`, `## Risks`, `## Diff`, `## Reading pack`, then the axis sections and
  `## Report`. So the carried Markdown's own `## ` lines, which land inside the fences, do not break the brief's
  structure.

## Issues

(none)

## Notes

- One residual early-exiting reader, judged harmless: `reading-pack.sh:160`
  `head -n 1 "$tmp/blob" | tr -d '\r' | grep -qE '^#!.*[/ ](ba)?sh([[:space:]]|$)'`. `grep -q` exits on its first
  match and can SIGPIPE `tr` under `pipefail`. It bites only if the blob's first line is larger than the pipe
  buffer *and* is a shebang, which cannot happen in practice; and the pipeline sits in an `if`, so the worst case is
  `kind=other` instead of `kind=shell`, never a crash. Not worth a fix on this PR.
- `rm -rf "$dir"` on a pack failure (`review-brief.sh:352`) destroys nothing pre-existing: `:289` already does
  `rm -rf "$dir"; mkdir -p "$dir"` before anything is written, and the round number and settled items come from the
  PR comments, not from `<dir>`.
- Brief size grows substantially: in the fixture the standards brief is 109,115 bytes, of which 83,648 is the pack.
  That is what P107 designs for (65,536 bytes of carried text plus headers and fences), not a defect, but it is the
  cost a reviewer's context now pays on every round.
- `./factory918.sh apply` into the fixture reports `FAIL labels present` and `FAIL slots filled`. Both are expected
  for a throwaway repo with no GitHub remote and no `/factory-start` run, and CI's step ignores the exit code the
  same way. Pre-existing, unrelated to this PR.
- The Factory CI workflow is the only one on this branch; there is no separate lint or docs workflow to check.
