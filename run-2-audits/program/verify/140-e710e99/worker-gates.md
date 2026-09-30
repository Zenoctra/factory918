verdict: PASS+NOTES

Slice: gates. PR #140 (ticket #137) at `e710e99ce4293ff2d057b7c9d639a82e97c88f04`.
`git merge-base --is-ancestor 6e5c539 HEAD` -> exit 0. `git status --porcelain` empty at start and at end.
Diff `6e5c539..e710e99`: 10 files, +105 -32.

## 1. AGENTS.md "Verifying", every line at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` -> exit 0, `ShellCheck 0.11.0, files checked: 26`. The line's own count (26) matches.
- `bash tests/shellcheck/gate.sh` -> exit 0, `ok 17 assertions`.
- `bash tests/hooks/delegation.sh` -> exit 0, `ok 55 assertions`.
- `bash tests/spec-review/review-comment.sh` -> exit 0, `ok 298 assertions`.
- `bash tests/spec-review/review-brief.sh` -> exit 0, `ok 1836 assertions`.
- `bash tests/poteto-mode/overlap.sh` -> exit 0, `ok 57 assertions`.
- `bash tests/show-me-your-work/check-trail.sh` -> exit 0, `ok 66 assertions`.
- `bash tests/spec-review/no-stale-wording.sh` -> exit 0, `ok: no stale wording`.
- `bash tests/knowledge/provisional-ids.sh` -> exit 0, `provisional-ids: 26 assertions passed`.
- `bash tests/eval/reviewer/refusals.sh` -> exit 0, `all 230 checks passed`.
- `python3 tools/check_knowledge.py` -> exit 0, `knowledge ok: 119 files`. `python3 tools/build_knowledge.py` -> exit 0, `knowledge files: 119 -> docs/knowledge`, `git status --porcelain` empty after.
- `./factory918.sh sync` -> `vendored: 72 skills`, `git status --porcelain` empty after.
- Fixture flow, run the way CI does (relative `--directory fx` from a private parent `mktemp -d`, #123), parent `/tmp/fxparent.Kftlw7`:
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` -> `Scaffolded fx`, Node 24.21.0, pnpm 12.6.0.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` -> every gate PASS except the two that need a GitHub remote and `/factory-start` (`labels present`, `slots filled`), which is what CI also sees (the step pipes to `tail -30`).
  - `bash .github/shellcheck.sh` inside fx -> exit 0, `ShellCheck 0.11.0, files checked: 13`.
  - CI's `review-brief.sh briefs the apply diff inside the project` step, reproduced verbatim with `tests/spec-review/fake-gh.sh` on PATH: `review-brief.sh HEAD~1 --ticket 1 --blast-radius ...` -> `ticket: #1`, `round: 1 of 3`, both briefs written. Every assertion of that step passes, including the two this PR tightened or added: `grep -qxF` of the hard-finding definition (the sentence is now the whole line, i.e. the count clause is gone), and `grep -qF` of ``An edge case that proceeds silently fails open: file it under `## Fails open`.`` and of `You may open any file in the repository and run read-only commands, such as grep or the test suite.`; the two negative greps (`Under 400 words`, `Read nothing beyond this brief unless`) find nothing.
  - `vp check && vp test run && pnpm sg:test && pnpm sg` -> exit 0 (63 files formatted, 9 files clean, 2 test files / 10 tests, 2 ast-grep cases pass).
  - `python/demo`: `uv sync --frozen && uv run ruff format --check . && uv run ruff check . && uv run pyright && uv run pytest && uv audit` -> exit 0 (0 errors pyright, 1 passed pytest, no known vulnerabilities).
  - CI's "The rules fire" step -> `no-todo-without-issue fired`, `ast-grep fired`.
- `docs/M0-findings.md`: the PR verifies nothing against a new tool version, so no dated line is owed. Not touched.

## 2. Every test under `tests/`; counts head vs 6e5c539

`tests/eval/reviewer/rebuild.sh` (usage: `rebuild.sh <round>`), `tests/spec-review/fake-gh.sh` and `tests/spec-review/layout.sh` are helpers, not suites (`layout.sh` exits 0 silently).

| test | 6e5c539 | e710e99 |
| --- | --- | --- |
| tests/eval/reviewer/refusals.sh | 230 (run at head; the base copy needs a git repo) | 230 |
| tests/hooks/delegation.sh | 55 | 55 |
| tests/knowledge/provisional-ids.sh | 26 | 26 |
| tests/poteto-mode/overlap.sh | 57 | 57 |
| tests/shellcheck/gate.sh | 17 | 17 |
| tests/show-me-your-work/check-trail.sh | 66 (run at head; the base copy needs a git repo) | 66 |
| tests/spec-review/no-stale-wording.sh | ok | ok |
| tests/spec-review/review-brief.sh | 1720 | 1836 (+116) |
| tests/spec-review/review-comment.sh | 298 | 298 |

The base copy was `git archive 6e5c539 | tar -x` into a scratch dir; `refusals.sh` and `check-trail.sh` need a real `.git` and fail there for that reason alone. Neither is touched by the diff (`git diff --stat 6e5c539..e710e99` lists neither), and both pass at head.

`no-stale-wording.sh` refuses each phrase this PR removed. Method: `git archive HEAD` into a scratch copy, append one phrase at a time to `template/.agents/skills/spec-review/SKILL.md`, run the check, restore. Baseline on the untouched copy: `ok: no stale wording`. All eleven new needles refuse:

```
phrase=Zero items is the expected result                       exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=Read nothing beyond this brief unless                   exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=read that one function or section, not the file         exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=Run nothing.                                            exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=reads one file and runs nothing                         exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=read nothing beyond the brief but the code around a hunk exit=1 template/.agents/skills/spec-review/SKILL.md:166
phrase=Under 400 words                                         exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=under 400 words                                         exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=a report that is all nits means                         exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=more than five Act on items                             exit=1  template/.agents/skills/spec-review/SKILL.md:166
phrase=zero items is the expected result                       exit=1  template/.agents/skills/spec-review/SKILL.md:166
```

A repo-wide `grep -rnF` for the same phrases outside `.git` hits only `research/` (the read-only pinned corpus), `docs/knowledge/notes/6-deterministic-layer/07-d-...md` (generated from that corpus), `tests/eval/reviewer/rounds/*/review/*` (frozen transcripts of past reviews), `patches/mattpocock/spec-review.SKILL.md.patch` (the `-` side, i.e. upstream text being removed), and the checks themselves (`tests/spec-review/no-stale-wording.sh`, `tests/spec-review/review-brief.sh:231,246`, `.github/workflows/factory-ci.yml:76,77`). Nothing live under `template/` or `docs/knowledge/core/`.

## 3. Knowledge, sync and the patch

- `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` then `git status --porcelain` -> empty.
- `./factory918.sh sync` then `git status --porcelain` -> empty (72 skills, every patch in `series` applied clean, including `mattpocock/spec-review.SKILL.md.patch`).
- The spec-review SKILL.md patch reproduces byte for byte. Upstream is `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` (SOURCES.md line 8, pin `6654f6b`, `code-review (-> spec-review)`). Copied it to a scratch `spec-review/SKILL.md`, `patch -p1 < patches/mattpocock/spec-review.SKILL.md.patch` -> `patching file 'spec-review/SKILL.md'`, no fuzz, no reject. `cmp` against `template/.agents/skills/spec-review/SKILL.md` -> identical; both sha256 `469ba621c638baa88bbfe78336778a136622fcc2bea1a376ca0c91da01b3b0be`.

## 4. ShellCheck on the touched shell files

Touched `*.sh` in the diff: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/spec-review/no-stale-wording.sh`, `tests/spec-review/review-brief.sh`. `shellcheck -x` (0.11.0) over the three -> exit 0, no output. All three are inside the AGENTS.md glob set; the `files checked: 26` the gate prints matches the count written in the AGENTS.md line at this SHA.

## 5. CI at this head

`gh run list --repo Zenoctra/factory918 --commit e710e99...` returns exactly one run, `databaseId 35917215163`, `Factory CI`, `status completed`, `conclusion success`. Both jobs and every step success:

- Factory: 14 steps, including `No retired review wording under template/ or the core knowledge`, `review-brief.sh writes the report shape into both briefs`, `Knowledge base is consistent and built from its sources`, `Vendored skills equal the pins plus the patches`.
- Fixture: 10 steps, including `review-brief.sh briefs the apply diff inside the project` (the step this PR changed).

## 6. DECISIONS

- `docs/knowledge/core/DECISIONS.md:87` (P18) carries a dated amendment: "Amended 2026-09-23 (#137): the definition no longer says how many items to expect; the briefs no longer cap the report's words or items, and no longer limit what a reviewer opens or which read-only commands it runs; the judge step no longer says what a report of nits means or how many Act on items are too many. Manuel's 'not a flag' quote stays word for word, followed by the fails-open line. Later rounds stay as blind as before." Followed by three Manuel quotes: "Zero items is expected is absolutely HORRENDOUS. [...] You are guiding the witness."; "400 word cap sounds like trying to save money on output tokens when thinking tokens make up the vast majority of token costs, not output."; "We are keeping them equally blind. I HATE leading witness prompts."
- The "not a flag" quote is intact word for word at `template/.agents/skills/spec-review/SKILL.md:86` and `template/.agents/skills/spec-review/scripts/review-brief.sh:488` (`- Manuel: "An edge case outside the intended path being unsupported is not a flag."`), and `review-brief.sh:490` sets ``edge_rule='An edge case that proceeds silently fails open: file it under `## Fails open`.'`` as the line after Manuel's five sentences. The fixture run confirms both land in both briefs.
- Ids unique: 36 rows in `docs/knowledge/core/DECISIONS.md` and 36 in `template/docs/factory918/DECISIONS.md`, no duplicates in either. The P18 row is identical in both copies.

## Issues

None.

## Notes

1. `AGENTS.md:50` still describes the fixture as `vp create vite:monorepo --directory /tmp/fx ...`, while `.github/workflows/factory-ci.yml:57` runs `(cd /tmp && vp create vite:monorepo --directory fx ...)`. The same line also omits `pnpm sg` (CI's gate step is `vp check && vp test run && pnpm sg:test && pnpm sg`), the `review-brief.sh briefs the apply diff inside the project` step and the `The rules fire` step, and points at `.github/workflows/python.yml` where CI inlines those commands. Pre-existing drift, untouched by this PR; not a gate failure (I ran the CI form and it passes).
2. `tests/eval/reviewer/rounds/*/review/*brief.md` are frozen transcripts of earlier reviews and still carry the retired wording (`Read nothing beyond this brief unless`, `Zero items is the expected result`). `no-stale-wording.sh` scans only `template` and `docs/knowledge/core`, so they are out of scope by design. Worth knowing if a future eval round is rebuilt with `tests/eval/reviewer/rebuild.sh`: it would regenerate briefs in the new wording, and the historical rounds would no longer be comparable to them.
3. The CI assertion on the definition moved from `grep -qF` to `grep -qxF`, so the sentence now has to be the whole line. That is stricter than before, and it holds in the fixture run.
