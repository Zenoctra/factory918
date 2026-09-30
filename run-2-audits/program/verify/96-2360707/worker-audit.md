verdict: PASS+NOTES

# Verifier report, slice "receipts-and-diff audit", PR #96 (ticket #88) at 2360707

Independent audit of the diff, the ticket's criteria, the review receipts and the PR body shape. I did not
write the code. Everything below is from commands run in my own detached worktree at
`2360707f9bf56e4216f81ec652f20d4682ba24c4`, with a private `TMPDIR` (`/tmp/claude-501/vtmp`) for every gate
run. I found no defect that should block the PR. Six notes follow, none of them a broken behaviour; two are
judgment calls for Manuel.

## Setup

- `git rev-parse HEAD` -> `2360707f9bf56e4216f81ec652f20d4682ba24c4`. Exit 0. Matches the brief.
- `git rev-parse origin/main` -> `ab47eb91fa42a896c1eec054e526b615b5cbf316`; `git merge-base --is-ancestor origin/main 2360707` exit 0, so the base is still the patch base and no rebase is owed.
- `gh pr view 96 --json mergeable,mergeStateStatus,isDraft,baseRefName` -> `mergeable=MERGEABLE state=CLEAN draft=false base=main`. Exit 0.
- `gh pr checks 96` -> Factory pass, Fixture pass (run 35753462947, `completed success`, on the head SHA). Exit 0.

## 1. The six acceptance criteria against the diff

- **AC1, factory CI, pinned to an exact version.** Met. `.github/workflows/factory-ci.yml:18-19` replaces the `bash -n` step with `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`. `.github/shellcheck.sh` is a symlink (mode `120000`, `git ls-tree`) to `../template/.github/shellcheck.sh`. The pin is `version=0.11.0` at `template/.github/shellcheck.sh:16`; the two release checksums at `:17-18`. The PATH binary is used **only** on exact version equality: `if ! "$bin" --version 2>/dev/null | grep -qx "version: $version"` at `:21` -- `grep -qx` anchors the whole line, so 0.11.1 or 0.9.0 falls through to the pinned download at `:22-34`, and an unpinned platform is refused at `:25`. The download is checksum-verified on **every** run that takes that branch (`:32-33`), not only on the run that fetches, and a tarball that fails is removed before exit 1.
  - Coverage check: the five globs match exactly `factory918.sh` (1) + `template/.github/shellcheck.sh` (1) + 5 hooks + 5 skill scripts + 8 tests = 20.
  - Run, exit 0: `TMPDIR=/tmp/claude-501/vtmp bash template/.github/shellcheck.sh factory918.sh 'template/.github/shellcheck.sh' 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` -> `ShellCheck 0.11.0, files checked: 20`, exit 0.
  - CI log, run 35753462947, job Factory, step ShellCheck -> `ShellCheck 0.11.0, files checked: 20`.
  - The glob `template/.agents/skills/*/scripts/*.sh` covers every `scripts/*.sh` under the skills tree: `find template/.agents/skills -path '*/scripts/*.sh'` returns the same five files the one-level glob matches. The only other `.sh` there is `wizard/template.sh`, which is not under `scripts/` and is declared out of scope in the PR body.
- **AC2, template CI + fixture.** Met. `template/.github/workflows/ci.yml:17-18` adds `ShellCheck` as the first step of `check`, running the zero-argument form, whose default set at `template/.github/shellcheck.sh:37` is `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`. `cmd_apply` copies every template file with `cp -p` (`factory918.sh:131-138`), so a project gets `.github/shellcheck.sh` at mode 755. `.github/workflows/factory-ci.yml:54-56` adds `The shell gate a project runs` inside `/tmp/fx`; CI log of run 35753462947, job Fixture -> `ShellCheck 0.11.0, files checked: 11`. Exit 0.
- **AC3, the Opening a PR playbook through its patch.** Met, and the patch is a true regeneration. The `**PRs.**` paragraph at `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` gains "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens". I regenerated the patch from the pinned upstream with the exact command in `patches/README.md`:
  `diff -u --label a/... --label b/... research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/playbooks/opening-a-pr.md template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` and `diff`ed it against `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` -> byte identical, exit 0. `SOURCES.md` item 3 records the sentence. The patch is already in `patches/series`.
- **AC4, doctor line, NOTE not FAIL.** Met. `factory918.sh:274-276`. I ran the two lines verbatim with the repo's own `note()` (`factory918.sh:239`) in a scratch script: with `shellcheck` on PATH -> `PASS  shellcheck 0.11.0`, exit 0; with `PATH=<emptydir>:/usr/bin:/bin` -> `NOTE  shellcheck` plus `      fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); ...`, exit 0. `note()` only echoes; it touches no failure counter, unlike `chk`. So the doctor's exit is unchanged either way.
- **AC5, directive reason; CI does not enforce it, the Standards axis does.** Met. `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` is the model and now carries its reason. `CODING_STANDARDS.md:15` states the rule, and that file's header says "Read at review time by `spec-review`'s Standards axis", which is the enforcement path. `template/CODING_STANDARDS.md:37` carries the project-side rule. No CI step greps for a reason: the only new steps in either workflow are the gate and `tests/shellcheck/gate.sh`, and `tests/shellcheck/gate.sh` asserts nothing about reasons. Every one of the 12 directives the diff adds or edits has the `# shellcheck disable=SCnnnn # <reason>` shape.
- **AC6, `AGENTS.md` Verifying plus a dated M0 line.** Met. `AGENTS.md:38-39` lists the gate command and `bash tests/shellcheck/gate.sh`. `docs/M0-findings.md:170-172`, `## ShellCheck (2026-09-22)`, records 0.11.0, both checksums and the measurements. I reproduced its three load-bearing measurements against the base tree (`git archive ab47eb9` into scratch, no worktree touched):
  - 57 findings at the default severity over the 18 files: `shellcheck --external-sources factory918.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh` -> exit 1, **57** findings. Exact.
  - `--severity=warning` -> **6**; `--severity=error` -> **1**. Both exact as M0 states.
  - Without `-x`, a per-file run of `tests/spec-review/review-brief.sh` reports SC1091 and SC2154 on three distinct variables (`hooks`, `skill`, `source_skill`); with the whole set they vanish. Confirms the `-x` claim and the reason the gate runs from the repository root.

## 2. Scope: every file the diff touches, grouped

27 files, 201 insertions, 18 deletions. Groups:

- **The gate (the ticket's core):** `template/.github/shellcheck.sh` (new, 49 lines), `.github/shellcheck.sh` (new symlink), `tests/shellcheck/gate.sh` (new, 99 lines), `.github/workflows/factory-ci.yml`, `template/.github/workflows/ci.yml`.
- **The 57 findings resolved:** `factory918.sh`, `template/.claude/hooks/delegation.sh`, `template/.agents/skills/spec-review/scripts/review-brief.sh`, `.../review-comment.sh`, `template/.agents/skills/poteto-mode/scripts/overlap.sh`, `tests/poteto-mode/overlap.sh`, `tests/spec-review/fake-gh.sh`, `tests/spec-review/layout.sh`, `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`.
- **Prose the criteria name:** `AGENTS.md`, `CODING_STANDARDS.md`, `SOURCES.md`, `docs/M0-findings.md`, `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`, `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`.
- **Prose the criteria do not name:** `template/AGENTS.md` (a Shell bullet), `template/CODING_STANDARDS.md` (Suppressions), `docs/knowledge/core/DECISIONS.md` (P25), `docs/agents/ledger.md` (two rows).
- **Generated:** `docs/knowledge/INDEX.md`, `template/docs/factory918/DECISIONS.md`.

Nothing is outside the ticket's ask in a way I would flag as a second concern:

- `bash -n` removed from CI and `AGENTS.md`: a substitution, not an addition. AC1 says ShellCheck runs over that set; ShellCheck's set is a superset and it refuses at error level what `bash -n` refuses. The PR body carries it as a named tradeoff.
- `template/CODING_STANDARDS.md` and `template/AGENTS.md`: justified by the Decision quote on the ticket ("it should be present in pretty much every project that inits factory in it too... a universally designed feature"). The template's CI now runs the gate, so a project needs the rule and the bullet.
- Directive-reason edits on `overlap.sh` and its test: AC5 names `overlap.sh`'s directive as the model, so bringing it to the shape is in scope. It does overlap PR #94; the PR body's `## Overlap` section records it and the go covers both tickets.
- P25, the ledger rows and the M0 section: the repository's standing rules (root `AGENTS.md`, "Pull requests") require them.

**The 57 findings, all of them, not a sample.** The base-tree run breaks down as 45 SC2016, 3 SC2086, 3 SC2034, 2 SC2148, 2 SC2115, 2 SC2088, 2 SC2015, 1 SC2012. The diff resolves them with exactly **five code edits** and twelve directives; the "wide diff" the slice anticipated is not there. Each code edit:

1. `factory918.sh:274` -- `[ -f ... ] && echo "PASS  models sheet" || note ...` becomes `if`/`else` (SC2015). Behaviour preserving, and strictly safer: in the old form a failing `echo` would have run `note` as well.
2. `factory918.sh:388` -- `rm -rf "$skills/$n"` becomes `rm -rf "${skills:?}/$n"` (SC2115). Behaviour preserving: `skills="$TEMPLATE/.agents/skills"` (`factory918.sh:381`) with `TEMPLATE="$F918_DIR/template"` (`:9`) is never empty, so `:?` states an invariant and never fires.
3. `factory918.sh:390` -- the same substitution at the second `rm -rf`. Same reasoning.
4. `factory918.sh:402` -- `ls -d "$skills"/*/ | wc -l` becomes `local -a dirs; dirs=("$skills"/*/); ${#dirs[@]}` (SC2012). Behaviour preserving on every reachable path; see Note 2 for the one unreachable difference.
5. `tests/spec-review/fake-gh.sh:15` -- `[ -f ... ] && cat ... || { echo ...; exit 1; }` becomes `if`/`else` (SC2015). Test fixture; behaviour preserving on the tested paths. The one difference is the unreachable case of `cat` failing on a file that exists and is readable.

None of the five changes semantics on a reachable path. The remaining 52 findings are closed by comments only (`# shellcheck disable=` with a reason, `# shellcheck shell=bash disable=SC2034` on `tests/spec-review/layout.sh`, `# shellcheck source-path=SCRIPTDIR source=layout.sh` in the two sourcing tests). I checked each reason against the code it sits above and all twelve are true, including the three `set -f` claims in `delegation.sh`: `set -fuo pipefail` is at `template/.claude/hooks/delegation.sh:7` and there is no `set +f` in the file.

## 3. Receipts

Three comments on PR #96, all by `Zenoctra` (the author's account), none by anyone else:

| # | URL | created | `round:` | `act-on items:` | stated fixed point |
|---|---|---|---|---|---|
| 1 | `#issuecomment-5779416046` | 2026-09-22T15:39:28Z | `round: 1 of 3` | `act-on items: 3` | `ab47eb9` |
| 2 | `#issuecomment-5779650623` | 2026-09-22T15:55:30Z | `round: 2 of 3` | `act-on items: 4` | `ab47eb9` |
| 3 | `#issuecomment-5779871731` | 2026-09-22T16:10:37Z | `round: 3 of 3` | `act-on items: 0` | `ab47eb9` |

Each ends with `Claude Fable 5.1 on Claude Code` and no `approved by`, which is correct for a comment the human did not pre-approve (P22).

Commit trail, `git log ab47eb9..2360707` with committer timestamps (CDT = UTC-5):

```
1208407 10:14:23  Add the shell gate, its test and the three CI steps that call it
741bc89 10:17:51  Resolve every ShellCheck finding on the factory's shell files
992ce94 10:18:51  Give the doctor a shellcheck line
f156229 10:20:41  Name the shell gate in the playbook, the standards and both AGENTS.md
69bd412 10:22:59  Record the ShellCheck pin, the gate decision and a lost lane      <- round 1 reviewed this
01e5386 10:41:44  Refuse a glob that matches nothing even beside globs that match   <- round 1 fix
72953c0 10:52:49  Expand a gate argument without splitting it on spaces             <- round 2 fix (Would-break)
a64c7e6 10:54:38  Verify the downloaded ShellCheck tarball on every run             <- round 2 fix
1362b48 11:00:22  Keep the checksum tool's OK line off the gate's stderr            <- round 2 CI-only fix
3f3814c 11:09:40  Record the CI proof of the download path and a lane's proof gap
2360707 11:19:16  Remove a cached tarball that fails its checksum ...
```

The sequence matches the report: round 1 at 10:39 on `69bd412`, fix `01e5386`; round 2 at 10:55 on `01e5386`, fixes `72953c0` / `a64c7e6` / `1362b48`; round 3 at 11:10, `act-on items: 0`.

**The two commits after round 3, exactly what each changes:**

- `3f3814c` -- records only, 2 files, 3 insertions / 2 deletions. `docs/M0-findings.md`: the ShellCheck section's last sentences now cite the four Factory CI runs (35747640954, 35749314626, 35750682737, 35751339998), including the one red run and what it caught. `docs/agents/ledger.md`: the model cell of the 2026-09-22 row corrected to `fable`, and one new row about proving a change to the download path on a machine that never runs it. No code, no CI config.
- `2360707` -- 2 files. `template/.github/shellcheck.sh`: the two-branch inline checksum call becomes `verify() { ... }` plus `echo "$sha  $tarball" | verify || { rm -f "$tarball"; exit 1; }` (`:32-33`), so a tarball that fails its check is deleted and the next run re-downloads; the header comment gains the sentence. `tests/shellcheck/gate.sh`: case 9's last assertion flips from "the tarball is not downloaded again" to `[ ! -e "$fx/tmp/shellcheck-0.11.0/sc.tar.xz" ]`, plus the header comment. I read the change: it is correct and minimal, the refusal stream is unchanged (the tool's warning on stderr, nothing on stdout), and `rm -f` cannot fire on a good tarball because `verify` returns 0.

Both post-round-3 commits are allowed by the three-round rule (after `round: 3 of 3` with `act-on items: 0`, the rest is fixed unreviewed). Both are covered by a green CI run on the final head.

**Rule 7 and round 3's fixed point.** Round 2 did fix a Would-break item (Standards `## Would break` 1, "An argument with a space is split, so the gate refuses a file that exists"), so rule 7 owed another round on that fix. A round 3 did follow and found nothing, so no round 4 is owed. But **round 3's fixed point was `ab47eb9`, not the round-2 head `01e5386`**, which is the letter of rule 7 ("reviewing only the fix (the previous reviewed commit as the fixed point)"). Evidence: the round-3 comment's last summary line reads `... fixed point ab47eb9.`, identical to rounds 1 and 2. This over-covers rather than under-covers -- a diff from `ab47eb9` contains `72953c0`, `a64c7e6` and `1362b48`, and round 3's Spec walk items 10 and 12 quote the post-fix code at `shellcheck.sh:30-33` and `:39-46` -- so the fix was demonstrably reviewed. I record it as a deviation in form, not in substance. See Note 1.

## 4. PR body shape, against `AGENTS.md` "Pull requests" at the SHA

All checks pass.

- Plain-sentence title: "Run ShellCheck at a pinned version in the factory, in every project and before a PR opens". No `type(scope):`, which is right for this repository (root `AGENTS.md`, "Pull requests": "A plain-sentence title (P14; the `type(scope):` form is for projects)").
- Problem then fix: `## Why` paragraph 1 is the problem and Manuel's decision, paragraph 2 is the fix.
- Top-level headings in order, from `grep -n '^## '` on the fetched body: `## Why` (1), `## Scope` (7), `## Tradeoffs` (22), `## Blast Radius` (31), `## Overlap` (94), `## Verification` (103). `## Overlap` precedes `## Verification`. OK
- No `## ` heading inside `## Blast Radius`: awk from `^## Blast Radius` to the next `^## ` lands on line 94, `## Overlap`. The five sub-sections inside are `### `, which `review-brief.sh`'s section awk does not terminate on. OK
- `## Verification` quotes each of the six criteria and names what ran and its outcome, including the CI run ids and the per-test assertion counts. OK
- Tail, in order: `Closes #88`, blank, the Claude Code attribution line, blank, `Claude Fable 5.1 on Claude Code`. OK
- `gh api graphql ... pullRequest(number:96).closingIssuesReferences` -> exactly one node, `{"number":88,"title":"Run ShellCheck in the factory, in every project, and before a PR opens"}`. OK One concern, one ticket.

## 5. Blast radius: the hook claim, reproduced

One hook file is in the diff: `template/.claude/hooks/delegation.sh`. Nothing else under any `hooks/` path is touched.

```
git show ab47eb9:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#' > old
git show 2360707:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#' > new
diff old new     -> exit 0, no output
shasum -a 256    -> bd4e05c0a785e3f30b4b44aa85f31a6ee66d834eb63674afc42bdaf7f7c1787c  (both)
```

Byte-identical with comment lines stripped, so the four added lines are comments and nothing else. Mode unchanged at `100755` (`git ls-tree`). No hook changed behaviour. The three `set -f` directive reasons cite "line 7" and `set -fuo pipefail` is still at line 7 after the insertions (`sed -n '1,10p'`). No tracked Markdown anywhere in the repository cites `delegation.sh:<n>` or `factory918.sh:<n>`, so the inserted lines break no documented line reference (`grep -rn 'delegation\.sh:[0-9]' --include='*.md'` and the same for `factory918.sh` -> no hits outside `.scratch`).

## 6. Forbidden edits and the rebuild

- `git diff --name-only ab47eb9...2360707 | grep -E '^(docs/knowledge/(spec|pages|notes)/|research/)'` -> no match. Nothing hand-edited under the generated spec/pages/notes trees or the read-only corpus.
- `python3 tools/check_knowledge.py` -> `knowledge ok: 118 files`, exit 0.
- `python3 tools/build_knowledge.py` -> `knowledge files: 118 -> docs/knowledge`, exit 0, then `git status --porcelain` -> empty. `tools/build_knowledge.py:125` writes `template/docs/factory918`, so the clean status proves both `docs/knowledge/INDEX.md` and `template/docs/factory918/DECISIONS.md` match a rebuild of the edited `docs/knowledge/core/DECISIONS.md`.
- The one vendored file the diff changes, `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`, goes through `patches/` + `series` + `SOURCES.md`, and I proved the patch is a byte-exact regeneration (section 1, AC3). The other edited skill scripts (`overlap.sh`, `review-brief.sh`, `review-comment.sh`) are all in `cmd_sync`'s `keep_files` (`factory918.sh:380`), so editing them directly is correct and `sync` preserves them. I did not run `./factory918.sh sync` (it mutates the tree, and my brief is read-only); the patch regeneration and the `keep_files` membership are the static equivalent.
- `tests/shellcheck/gate.sh` lands mode `100755` and `template/.github/shellcheck.sh` mode `100755`; `.github/shellcheck.sh` is `120000`. The round-1 mode-bit finding is closed.

Gates I ran at the head, each exit 0:

- `TMPDIR=/tmp/claude-501/vtmp bash template/.github/shellcheck.sh <the five factory globs>` -> `ShellCheck 0.11.0, files checked: 20`.
- `TMPDIR=/tmp/claude-501/vtmp bash tests/shellcheck/gate.sh` -> `ok 17 assertions`.

## 7. The owner report's `## Attention` items

1. **Stale PR body when the trail reviewer read it.** Mostly closed, a residue left. The dated addendum is present and correct: it names `a64c7e6`+`1362b48` for risk 1, `01e5386` for risk 3, retracts the "with the hooks deleted, 6" Cleared line and adds the `2360707` finding. What is still stale is small: the grounding block still reads `bash tests/shellcheck/gate.sh -> ok 10 assertions` (17 at the head), and the `## Scope` bullet for `gate.sh` lists seven cases and omits 3b, 8, 8b and 9. Both numbers are explicitly attributed to `69bd412` in `## Verification`, so neither is a false statement at the commit that landed it. **Nothing**, bordering on a judgment for Manuel if he wants the grounding refreshed at the final head.
2. **"Test before implementation" overclaimed.** **A judgment for Manuel**, and the report is right to raise it. The ticket's run-under rule 3 says "The test is written from the table before the implementation, one assertion per cell, and the commit order shows it." Commit `1208407` contains the gate, its test and the three CI steps together, so the commit order does not show it; the report and the PR body both now say plainly that inside commit 1 the script came first and that what holds is the gate-and-test-before-the-fixes order. That is an honest restatement, not a cover, but it is a deviation from rule 3's letter and only Manuel can accept it.
3. **The wedged cached tarball, fixed by `2360707` unreviewed.** **Not a defect.** The fix is allowed by the three-round rule, it is two lines plus a flipped assertion, I read it and it is correct, and CI is green on the head. I would only observe that the fix was found by the trail review, not by any of the three rounds, which is evidence the download branch is hard to review on a machine carrying the pin -- the very lesson `3f3814c` put in the ledger.
4. **Two gates sharing one TMPDIR.** **Not reachable by CI; reachable in principle by concurrent lanes on a machine without the pin, and loud rather than silent when it happens.**
   - CI cannot hit it. The two jobs (`Factory`, `Fixture`) run on separate runners, so they share no filesystem. Inside the `Factory` job the two gate steps run sequentially. Inside `tests/shellcheck/gate.sh`, case 9 sets its own `TMPDIR="$fx/tmp"` and case 6 is refused at the platform check before any `TMPDIR` use, so the test never races the steps around it.
   - A lane on Manuel's machine cannot hit it today: `shellcheck --version` is `0.11.0`, the pin, so `template/.github/shellcheck.sh:21` short-circuits and the `TMPDIR` branch never runs.
   - It is reachable on a machine without the pin running parallel lanes (autopilot-stack does run lanes in parallel, and macOS `TMPDIR` is per-user, shared across every process of that user). Two concurrent runs can `tar -xJf` over each other's binary, or one can `rm -f` a tarball the other's `curl` is still writing. I traced both: after a `rm -f` the other run's `verify` re-reads the path, finds nothing, the checksum tool errors, `rm -f` is a no-op and it exits 1 with a message. So the failure mode is a loud non-zero exit on both runs, not a silent pass over an unverified binary -- the sha is re-checked on every run since `a64c7e6`. Leaving it as a known risk is a reasonable call; it is worth one sentence in `docs/M0-findings.md` or the ledger if the factory ever runs lanes on a machine without the pin.
5. **Round 2's "not a design hole" call.** **A judgment for Manuel**, and I agree with the report that it is the one stretch. The call is defensible on its face: the ticket's `## Design` Signature already said the gate "checks its sha256, and runs that", so the shipped code failing to do that on a cache hit is the code disagreeing with the artifact, which rule 5 makes a code fix. The tension is that the ticket's `## Design` was nevertheless amended afterwards ("Amended by the agent 2026-09-22 after review round 2"), which is the motion rule 5 reserves for a hole going back to architect. The amendment's own last sentence, "No row's prints, exit or caller changed", is the defence. Manuel's call whether an amendment that only clarifies counts as changing the artifact.
6. **Round-3 items, ledger rows and M0 counts checked.** **Nothing.** I re-derived the M0 counts independently (57 / 6 / 1, and the three SC2154 variables) and they are exact; see AC6.

## Issues

None.

## Notes

1. Round 3 used `ab47eb9` as its fixed point, not the round-2 head `01e5386` that rule 7 names ("reviewing only the fix (the previous reviewed commit as the fixed point)"). Evidence: the round-3 comment's summary line, `... fixed point ab47eb9.` It over-covers rather than under-covers -- the round-3 Spec walk quotes the post-fix code (`shellcheck.sh:30-33`, `:39-46`) -- so the Would-break fix was reviewed, but the form differs from the rule as written.
2. `factory918.sh:402`, the SC2012 fix, has one unreachable behaviour difference the round-2 review already noted and left: `ls -d "$skills"/*/ | wc -l` printed `0` when the glob matched nothing, whereas `dirs=("$skills"/*/); ${#dirs[@]}` leaves the unexpanded literal and prints `1`. Unreachable in practice (the vendored set is never empty, and `sync` fails earlier on a missing skill), and the line is a summary `echo` only.
3. `tests/spec-review/fake-gh.sh:15`, the SC2015 fix, drops the old form's fallback when `cat` itself fails on a file that exists. Test fixture only; the file is written by the test that reads it, so the case is unreachable.
4. The PR body's blast-radius grounding still reads `bash tests/shellcheck/gate.sh -> ok 10 assertions`; the head produces `ok 17 assertions`. The count is attributed to `69bd412` in `## Verification`, so it is true at the commit it describes, but a reader of the grounding alone gets a stale number. Same for the `## Scope` sentence listing `gate.sh`'s cases, which omits 3b, 8, 8b and 9.
5. The three review comments open with a person-facing paragraph but not under the literal label `For a person:` that `template/AGENTS.md`, "Pull requests", asks of a comment over about forty lines. `review-comment.sh` does not check for the label (no `For a person` string in it), so this is the skill's own shape rather than a lapse by this lane; flagging it only because the rule and the tool disagree.
6. `template/.agents/skills/show-me-your-work/scripts/log.sh` and `template/.agents/skills/poteto-mode/scripts/worktree-audit.sh` are now linted by CI but are not in `cmd_sync`'s `keep_files`, so a future upstream version of either with a finding turns the factory CI red with no local edit to show for it. The PR body's Cleared section says this; no action needed now, both are clean at the head.
