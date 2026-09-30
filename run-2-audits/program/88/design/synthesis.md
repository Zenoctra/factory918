# Synthesis: ticket #88 architect arena

Base: candidate B (`candidate-B.md`). The cross-judge (`judge.md`, opus) scored B 18 to A's 16 and recommended B; I read both end to end and agree, for the reason the judge names: B is the only candidate where the sentence the playbook asks a lane to run is literally the CI step. The writer implements candidate B with the grafts below; where this note and candidate B disagree, this note wins.

## Grafts

1. From A: `# shellcheck source-path=SCRIPTDIR source=layout.sh` on the line above the `.` line in `tests/spec-review/review-brief.sh` (today line 20) and `tests/spec-review/review-comment.sh` (today line 11). Verified by A and by the judge: without it, `shellcheck -x` on one of those tests from another working directory (absolute path) reports SC1091 and SC2154; with it, clean. This harness resets the working directory between commands, so a lane's per-file run must not depend on the cwd. Not a `disable=`, so it carries no reason; the line explains itself.
2. From A: the SC2115 edit stays `"${skills:?}/$n"` at both lines, but its reading in the PR body and the M0 line is A's: `$skills` is a literal suffix on `$TEMPLATE` and is never empty, so this is an invariant stated in code, not a live bug.
3. Mine: a symlink `.github/shellcheck.sh -> ../template/.github/shellcheck.sh` at the factory root, the same nesting rule as `.claude/hooks -> ../template/.claude/hooks` (DECISIONS P7). With it, `bash .github/shellcheck.sh` is a true command in the factory and in every project, so the playbook sentence needs no factory clause, and the factory CI step and the root `AGENTS.md` bullet read `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`. The globs stay against `template/` (never `.claude/`) so nothing is linted twice. The link is outside `template/`, so `apply` never copies it.

## Rejected

- A's lane command `shellcheck -x <files>` (an unpinned local tool with hand-typed flags; lane and CI would drift).
- A's kept-and-widened `bash -n` step (ShellCheck refuses an unparseable file at error level, B's E9; two steps over one set is duplication).
- A's Linux-only script (a lane on macOS without ShellCheck could not run the gate; B carries both measured checksums).
- A's four file-level SC2016 directives (two of those files hold one and two occurrences; B's per-site directives at the verified lines are the narrowest scope).
- B's placement of the `layout.sh` directive above the header prose: put it after the header comment, before the first command (today line 7), as A did; ShellCheck accepts either and the prose keeps line 1.

## Judge's corrections, recorded

- A claimed `-s bash` adds a spurious SC2015 to `fake-gh.sh`; it does not (the same single SC2015 either way). Irrelevant to the design: no `-s` is used.
- B called `factory918.sh:384` SC2115 a live `rm -rf /` risk; overstated, see graft 2.

## The commit plan (five commits on `wt/88-writer`, in this order)

1. **The gate.** `template/.github/shellcheck.sh` (B's script verbatim, mode 755), the root symlink `.github/shellcheck.sh`, `tests/shellcheck/gate.sh`, and the three CI edits: in `.github/workflows/factory-ci.yml` the `Shell syntax` step is replaced by the ShellCheck step plus a step `bash tests/shellcheck/gate.sh`; the fixture job gains `The shell gate a project runs` (`working-directory: /tmp/fx`, `run: bash .github/shellcheck.sh`) right after `Day 0 on a fresh monorepo`; in `template/.github/workflows/ci.yml` the `check` job gains `- name: ShellCheck` / `run: bash .github/shellcheck.sh` as its first step after `actions/checkout@v4`. At this commit the gate over the factory set exits 1 with 57 findings; the writer runs it and pastes the count in the report. This commit is the test.
2. **Every finding resolved.** B's Point 3 table (5 fixes, the directives), the two existing directives given their same-line reasons, the `layout.sh` directive after its header, and graft 1's two `source-path` lines. The gate exits 0 from here; the four behavioural tests still pass.
3. **The doctor line.** B's Point 5 text after the models-sheet line.
4. **The prose.** The playbook sentence (B's Point 6) and the regenerated patch; `SOURCES.md` item 3; the root `CODING_STANDARDS.md` Bash bullet; the template `CODING_STANDARDS.md` Suppressions sentence; the root `AGENTS.md` Verifying bullet (replacing `bash -n factory918.sh`, and adding `bash tests/shellcheck/gate.sh` to the list); the template `AGENTS.md` Verifying bullet. `./factory918.sh sync` leaves `git status` clean.
5. **The records.** `docs/M0-findings.md` new section `## ShellCheck (2026-09-22)` (B's Point 8 text, with graft 2's reading of SC2115) before `## Still open`; `docs/knowledge/core/DECISIONS.md` Provisional row (next free id after the highest present; B's Point 8 text, ending "Ticket #88, 2026-09-22."), then `python3 tools/build_knowledge.py`; `docs/agents/ledger.md` gets the line the orchestrator supplies in the writer brief.

## The `## Design` artifact

Posted on the ticket by the orchestrator before the writer starts (`design-section.md`).
