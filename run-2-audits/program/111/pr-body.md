On 2026-09-22 two owner lanes typed timestamps into their decision trails. One wrote `17:45:00Z` at 17:25 and `19:35:00Z` at 17:46. Their rows came out of order and outside the run, and the post-mortem could not time their phases. The show-me-your-work skill allowed this: it said a bare `printf` works as well as `scripts/log.sh`, and nothing checked the result.

This PR makes `log.sh` the only way a row is added, and gives the trail review a check it can run.

- The skill now says every row is appended through `scripts/log.sh`, which stamps `ts` from `date -u`, and that a lane never types a row or a timestamp. The `ts` column is named as the timing record the post-mortem tooling reads. The skill changes through a new patch, `patches/pstack/show-me-your-work/SKILL.md.patch`, listed in `series` and described as item 18 in `SOURCES.md`.
- A new script of ours, `show-me-your-work/scripts/check-trail.sh <trail> <transcript>...`, takes the run's bounds from the `timestamp` fields of the transcripts it is given, so nobody types a bound. It exits 0 with one `ok` line. It exits 1 with one line per offending row for these problems: a header other than the template's, a row without six columns, a `ts` that is not a `log.sh` stamp, a row earlier than the one above it, or a row outside the run. It parses no dates, so macOS and Linux behave the same. It is in `sync`'s `keep_files`, like `overlap.sh`.
- The trail review runs the script first and puts a refusal first under Attention. The refusal does not block merge-ready, because the log is append-only and its rows cannot be repaired.
- `tests/show-me-your-work/check-trail.sh` has one assertion per cell of the scenario table posted on the ticket, and it runs in CI.

`log.sh` is unchanged. Hillclimb step 3 still has agents write a nine-column `decision.tsv` by hand, which this check would refuse. That is filed as #128 rather than widened here.

## Overlap

```
go: autopilot-stack
#120 feat/speed-lessons: AGENTS.md SOURCES.md docs/M0-findings.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/series template/docs/factory918/DECISIONS.md
#121 feat/provisional-ticket-ids: .github/workflows/factory-ci.yml AGENTS.md docs/M0-findings.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
#124 feat/reviewer-model-eval: .github/workflows/factory-ci.yml AGENTS.md SOURCES.md docs/M0-findings.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/series template/docs/factory918/DECISIONS.md
#125 feat/fix-only-from-round-two: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
#126 feat/review-reading-pack: AGENTS.md SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md factory918.sh template/docs/factory918/DECISIONS.md
```

Stacked on #126 (`feat/review-reading-pack`).

## Verification

- "The skill says a row is appended only through `scripts/log.sh`, which stamps `ts` from `date -u`, and a lane never types a timestamp; the patch, `series` and `SOURCES.md` carry it." See the "Logging a row" paragraph and the `ts` bullet in `template/.agents/skills/show-me-your-work/SKILL.md`, `patches/pstack/show-me-your-work/SKILL.md.patch`, the last line of `patches/series`, and `SOURCES.md` item 18. `./factory918.sh sync` applies the patch and leaves `git status` clean.
- "A trail whose rows are out of order or carry a timestamp outside the lane's run is refused by the trail review with a line naming the rows." `bash tests/show-me-your-work/check-trail.sh` gives `ok 66 assertions`. Rows 8 to 10 of the table cover order and bounds. The writer lane ran the same test in `ubuntu:24.04` with mawk (the CI path) and with gawk: `ok 66 assertions` on both. The design lane ran the script on the #88 to #93 trails with their owners' transcripts: #88 to #90 pass, and #91 and #93 are refused, which matches the post-mortem.
- "`docs/agents/evidence.md` or the skill names the trail as the timing record the post-mortem tooling reads." See the `ts` bullet in the skill.
- `bash .github/shellcheck.sh ...` (the AGENTS.md line): `ShellCheck 0.11.0, files checked: 26`.
- `bash tests/shellcheck/gate.sh`: `ok 17 assertions`.
- `python3 tools/build_knowledge.py` leaves `git status` clean. `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`.
- `bash tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`.
- CI run 35866744150 on c183a36: Factory and Fixture both pass.
- `spec-review` round one on c183a36: `act-on items: 0` (https://github.com/Zenoctra/factory918/pull/129#issuecomment-5795711852).
- `check-trail.sh` on this PR's own decision trail against the owner's transcript: `ok: 8 rows in order inside the run`.

## Records

- Provisional P111 in `docs/knowledge/core/DECISIONS.md`.
- A dated line in `docs/M0-findings.md` on the platforms the check ran on and the transcript `timestamp` field.

Closes #111
🤖 Generated with [Claude Code](https://claude.com/claude-code)
Claude Opus 5.5 on Claude Code
