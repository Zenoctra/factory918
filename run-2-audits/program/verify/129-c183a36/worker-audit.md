verdict: PASS+NOTES

For a person: I re-read the whole diff and the ticket without trusting the PR body, re-ran every gate, and found no defect. Three small things are worth a look, none of them blocking: the PR body quotes a stale row count for its own trail, the skill paragraph still omits exit 64, and the "no slack" bounds can refuse an honest trail when a lane is resumed in a second session.

Setup: `git fetch origin feat/trail-clock feat/review-reading-pack main`, `git checkout --detach c183a362e73b88758bdf468a4169619158b47c1d` → `HEAD is now at c183a36`; `git rev-parse HEAD` = `c183a362e73b88758bdf468a4169619158b47c1d`; `git merge-base --is-ancestor f58308b5eae3f6617cf3a5200e7679e5737a5702 HEAD` → exit 0. Worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1771b831cf5fbc10`.

## 1. The three acceptance criteria

- **Criterion 1** ("a row is appended only through `scripts/log.sh`, which stamps `ts` from `date -u`, and a lane never types a timestamp; the patch, `series` and `SOURCES.md` carry it"). Met. `template/.agents/skills/show-me-your-work/SKILL.md:37` ("Append every row with `scripts/log.sh ...`, and only with it: a lane never types a row or a timestamp"), and the removed sentence "A bare `printf` appending a row works too" is gone (`git diff f58308b..c183a36 -- template/.agents/skills/show-me-your-work/SKILL.md`). `patches/pstack/show-me-your-work/SKILL.md.patch` (new, 32 lines) carries the same two hunks; `patches/series:33` is `pstack/show-me-your-work/SKILL.md.patch`; `SOURCES.md:30` is item 18. `./factory918.sh sync` → `applied  pstack/show-me-your-work/SKILL.md.patch` … `vendored: 72 skills`, exit 0, then `git status --porcelain` printed nothing, so the patch reproduces the vendored copy byte for byte and `keep_files` restores `check-trail.sh`.
- **Criterion 2** ("a trail whose rows are out of order or carry a timestamp outside the lane's run is refused by the trail review with a line naming the rows"). Met. `template/.agents/skills/show-me-your-work/scripts/check-trail.sh` (new, 36 lines, mode 100755); the order rule is line 205 (`ts < prev` → `earlier than line <m> (<ts>)`) and the bounds rule line 206 (`ts < first || ts > last` → `outside the run <first> to <last>`), one line per row via `print "line " NR " " ts ": " why`. The trail review runs it first: `SKILL.md:68`. `bash tests/show-me-your-work/check-trail.sh` → `ok 66 assertions`, exit 0.
- **Criterion 3** ("`docs/agents/evidence.md` or the skill names the trail as the timing record the post-mortem tooling reads"). Met by the skill: `SKILL.md:16` — "the timing record the post-mortem tooling reads for how long each phase took". `docs/agents/evidence.md` is untouched, which the criterion allows.

## 2. The table on #111: one labeled assertion per cell, tests before script

- Cell coverage. `tests/show-me-your-work/check-trail.sh` has 66 labeled `check`/`check_err` assertions asserting exit code, exact stdout and exact stderr. Counting by hand: rows 1, 2, 4–15 give 4 cells each (56) and row 3 gives 7 (its four cells plus the CRLF variant under own/every writer/wrong) = 63, plus the `log.sh`-between-two-records assertion (line 195) and the two index-mode assertions (line 201) = 66, matching the printed total. Every cell name carries its row number and column ("`6 wrong`", "`11 every writer`"), and the assertions appear in table order.
- Table order and legend match. USE = exit 64 with the usage line (rows 1–15, "no transcript"); ERR = exit 2, empty stdout (rows 1, 13, 14); REF = exit 1 with the reason codes H/C/O/X/N in the order the design fixes (columns, then stamp-or-earlier, then outside) — seen in `10 own`: `line 3 ...: earlier than line 2 (...); outside the run ...`.
- Tests before script. `git log --oneline f58308b..c183a36` in apply order: `54c65ac Test the trail clock check cell by cell` (one file, `tests/show-me-your-work/check-trail.sh`, +208) then `27bb48e Add check-trail.sh …` (`factory918.sh`, `check-trail.sh`). I proved the test is genuinely red at `54c65ac`: `git archive 54c65ac` into a temp tree, `bash tests/show-me-your-work/check-trail.sh` → `FAIL 1 no transcript … exit 127 … No such file or directory`, exit 1.

## 3. Scope

- Files touched, grouped, all inside the ask: the change itself (`template/.agents/skills/show-me-your-work/SKILL.md`, `.../scripts/check-trail.sh`, `patches/pstack/show-me-your-work/SKILL.md.patch`, `patches/series`, `SOURCES.md`, `factory918.sh` `keep_files`); the test and its CI step (`tests/show-me-your-work/check-trail.sh`, `.github/workflows/factory-ci.yml`, `AGENTS.md` "Verifying" plus the ShellCheck count 24→26); the records AGENTS.md requires (`docs/knowledge/core/DECISIONS.md` P111, `docs/M0-findings.md` dated line, and the two generated copies `docs/knowledge/INDEX.md` and `template/docs/factory918/DECISIONS.md`). Nothing outside the ask; `log.sh` is unchanged, as the design says.
- Vendored edits. The only vendored file changed is `show-me-your-work/SKILL.md`, and it changes through `patches/` + `series` + `SOURCES.md`; `sync` leaving `git status` clean is the proof. `check-trail.sh` is ours, so it correctly sits in `keep_files` (`factory918.sh:385`) rather than in a patch.
- #128 exists and says what the PR claims. `gh issue view 128` → open, `needs-triage`, "Keep Hillclimb's attempt table apart from the decision trail", body blocked by #111, criteria include `grep -n "decision.tsv" …/hillclimb.md` printing nothing. The PR's last paragraph describes it accurately.

## 4. Receipts

- Round one. `gh api repos/Zenoctra/factory918/issues/comments` on PR 129 returns exactly one comment, id 5795711852, author Zenoctra, 2026-09-23T13:27:51Z. Its tail is `reviewed: c183a362e73b88758bdf468a4169619158b47c1d`, `round: 1 of 3`, `act-on items: 0`. Counts line: act on 0, ask 0, consider 1, noted 2, dismissed 0; both reports `hard findings: 0`.
- No round two owed. There is no `next round owed:` line in the comment, and none is due: `review-comment.sh:279` prints it only when `fixed_here` is non-zero, and `spec-review/SKILL.md:145` says it is printed "when any Act on item is marked `fixed:`". There are no Act on items at all, so no `fixed:` marks. I confirmed the comment history parses as expected by feeding the real comment body to the real script through `--previous` (the fake-gh substitute; a fake `gh` on PATH was not reachable because the isolation guard refuses a `bash <script>` run under a modified PATH): `bash template/.agents/skills/spec-review/scripts/review-brief.sh c183a36… --ticket 111 --previous <real comment>` → `round: 2 of 3`, `settled: carried 0, dropped 2 without a citation`, then exit 1 with "the diff is empty". So round two is *available*, not *owed* — which is the #125 rule read correctly.
- CI. `gh api repos/.../commits/c183a36…/check-runs` → `Fixture success`, `Factory success`, both completed 2026-09-23T13:2x.
- PR metadata. `gh pr view 129 --json …` → base `feat/review-reading-pack`, head `feat/trail-clock`, state OPEN, `closingIssuesReferences` = `[111]` only.

## 5. PR body against AGENTS.md "Pull requests"

- Plain-sentence title: "Stamp decision trail rows with the clock and check them in the trail review". No `type(scope):`.
- Problem (the two typed timestamps, the broken post-mortem timing) then fix (four bullets), then `## Overlap`, then `## Verification` — Overlap before Verification, both present once.
- `## Blast Radius` is correctly absent: the diff is not cross-cutting. The predicate (`patches/mattpocock/spec-review.SKILL.md.patch:22`) is a `.claude/hooks/` file, a `.claude/settings.json` or a file of the `factory918` skill at any depth; none is in the diff. Proof: `review-brief.sh` refuses a cross-cutting diff before writing state, and it wrote both briefs here without complaint.
- Outcomes, not command names, in Verification (`ok 66 assertions`, `files checked: 26`, `knowledge ok: 119 files`, run id, comment URL).
- Last three lines are `Closes #111`, the Claude Code attribution line, `Claude Opus 5.5 on Claude Code`.

## 6. Forbidden edits and generated files

- No path under `research/`, `docs/knowledge/spec/`, `pages/` or `notes/` is in the diff.
- Generated files match a rebuild: `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, then `git status --porcelain` printed nothing; `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`.
- `template/docs/factory918/DECISIONS.md` is generated and its P111 row matches the core copy (same rebuild-clean run).

## 7. The owner's Decided items

- **Bounds from the transcripts, no slack.** Sound, and detect-only, so a false refusal costs a line under Attention and nothing else. The truncation is a floor on both ends (`.[0:19] + "Z"` in jq, `%S` in `date -u`), and the test exercises `.900Z`/`.100Z` on both ends, so a sub-second boundary cannot flip a verdict. I ran the script on the PR's own trail with the owner lane's real transcript, both absolute paths containing spaces: `ok: 11 rows in order inside the run 2026-09-23T13:04:03Z to 2026-09-23T13:33:37Z`, exit 0.
- **Clock skew between `date -u` and the transcript timestamps.** Not a real risk here: both come from the same host clock while the lane runs locally. It would become one only for a lane whose shell runs on a different machine from the harness writing the transcript.
- **A row logged just before the transcript's first record.** Cannot happen for the lane's own session: the first record predates any tool call. The real false-refusal path is a *resumed* lane — a session pickup writes a second transcript file, and rows from the first session are outside the run unless both files are passed. The skill says "the transcript of every lane that appended to the log", which covers it only if the reviewer reads "lane" as "session". Judgment for Manuel, not a defect; see Notes.
- **`log.sh` unchanged.** Confirmed: not in the diff. Its literal header `printf` and the template file `references/decision-log-template.tsv` are byte-equal (`od -c`), and the live assertion at test line 192–199 ties the two formats together, so a future drift is caught.
- **The blank-row message** (`line 4 : has 0 columns, expected 6; not a log.sh stamp`, test line 145). Cosmetic as the owner says: the double space around the empty `ts` is ugly but unambiguous, and the table's row 11 specifies exactly this. Nothing.

## Issues

None.

## Notes

- The PR body's last Verification bullet says `check-trail.sh` on this PR's own trail gives `ok: 8 rows`; the trail now has 11 rows and the script prints `ok: 11 rows …` (`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/111/decisions.tsv`, 12 lines). The trail is append-only, so the receipt was true when written, but a reviewer reproducing it gets a different number. Cosmetic.
- The skill paragraph (`SKILL.md:68`) documents exits 0, 1 and 2 but not 64, which the ticket's Contract lists. Round one raised this (S3) and the owner dismissed it; the script's own header comment lists all four and exit 64 prints its own usage line, so a reviewer who hits it is told what to do. Judgment for Manuel.
- A lane resumed in a second session writes two transcript files. Passing only the live one refuses every row written before the pickup, with `outside the run`. The refusal is detect-only, but the skill sentence says "every lane that appended", not "every session", so the reviewer has to infer it. Worth a follow-up ticket if Manuel wants it tightened; out of scope here.
- Round one's Consider (S1: the test passes only relative paths from a spaced fixture root, so no absolute path with a space is ever exercised) is a real coverage gap in the test, and it stays open. I closed it by hand instead: the script run above used two absolute paths, both containing "Under The Sun Collective", and behaved correctly. No code change is needed.
- Extra gates I ran beyond the PR's claims, all green at this SHA: `bash .github/shellcheck.sh …` → `ShellCheck 0.11.0, files checked: 26`; `bash tests/shellcheck/gate.sh` → `ok 17 assertions`; `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`; `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`.
- The `AGENTS.md` fixture line at this SHA still carries the absolute `--directory /tmp/fx` that `vp` refuses (filed as #123); unchanged by this PR and outside its scope.
