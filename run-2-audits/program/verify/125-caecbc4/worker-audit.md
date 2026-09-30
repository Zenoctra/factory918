verdict: PASS+NOTES

For a person: the change does what #106 asked and every command in the PR body reproduces. One thing is worth Manuel's eye: the rule that decides "the finding is inside the fix" also fires when a hard finding in untouched code is quoted as a plain code block that happens to share one line of text with the fix, and that makes round three fix-only when it should stay whole-diff. It is what #106's own Terms and P106 say, so it is not a bug in the code, but the owner's report describes the exposure more narrowly than it is.

## Setup

- `git fetch origin feat/fix-only-from-round-two feat/reviewer-model-eval feat/provisional-ticket-ids feat/speed-lessons main` then `git checkout --detach caecbc448983e071d4289d252f515993c4978cbf` in my own worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aeb704404d3fb6a4f`. `git rev-parse HEAD` = `caecbc448983e071d4289d252f515993c4978cbf`. Exit 0.
- `git merge-base --is-ancestor 01a1e5f46891d10b234fe9ee80cbd9e8c67d4438 HEAD` → exit 0. `git diff --stat 01a1e5f..caecbc4`: 18 files, 807 insertions, 47 deletions.
- `git log --oneline 01a1e5f..caecbc4`: `7b7d1fb` tests, `aa155fc` scripts, `dcb9055` item filter, `5f9a598` prose, `caecbc4` records.

## 1. The seven acceptance criteria

- **Criterion 1 (rounds one and two byte for byte).** Met. The `same` helper (`tests/spec-review/review-brief.sh:864-880`) runs the brief over a history and over a `sed '/^reviewed: /d; /^fix only after /d; /^next round owed: /d'` copy of it and `cmp`s stdout, `diff`, both briefs and `round` — a real byte comparison, not a grep. Used at cells 2A, 3A, 4A, 12A. In the code the gate leaves `from` empty at rounds one and two (`review-brief.sh:234,245`), and `common()` keys the fix section on `[ -n "$from" ]` (`review-brief.sh:413`). `bash tests/spec-review/review-brief.sh` → `ok 986 assertions`, exit 0.
- **Criterion 2 (the fix-only decision, from the comment and the commits, never from a human's word).** Met. `review-comment.sh:240-256` (`outside()`) reads only the two report files and `<dir>/fix-lines`; the judgment file is never opened by it. Cell 3B's Dismissed case asserts judgment-independence. **"Once a round is fix-only every later round is" with no code: the owner's judgment is correct.** Round three is the only round the new gate can decide (`review-brief.sh:245`, `round -eq 3 && top -eq 2`). Rounds four and five exist only when the previous comment carries the WB line, and that line always makes them fix-only (`review-brief.sh:243`); a round four without it is refused (`F4`). So no whole-diff round can follow a fix-only one, and the criterion's converse clause ("a hard finding in unchanged code makes the next round whole-diff") can only act at round three. Rows 15 to 18 of the test cover the sequel rounds.
- **Criterion 3 (fixed point, fix section, refusals unchanged).** Met. `review-brief.sh:248-256` is one block for both cases, with `$via` parameterising the `FP` text; at rounds four and five `via` is `would-break fixed after`, so #93's strings stay byte-identical, asserted by cells 16A (`fp 4 …`, #93's unchanged helper) and 15A/15B. `FR`, `FP`, `FT` all run before `rm -rf "$dir"`/`mkdir -p "$dir"` (`review-brief.sh:287-288`), so a refusal writes no state — asserted at row 22.
- **Criterion 4 (the owed line, and babysit reads it).** Met. `review-comment.sh:260-262` and `:297`. Both babysit copies carry the identical sentence, pinned as a fixed string by `tests/spec-review/review-brief.sh` (`babysit_owed`, both `template/.agents/skills/poteto-mode/playbooks/babysit.md` and `template/.agents/skills/babysit/SKILL.md`). `docs/knowledge/core/MANUAL.md:103` and `template/docs/agents/review-ladder.md` rung 1 both gained the `next round owed:` clause.
- **Criterion 5 (one assertion per cell, tests first, in commit order).** Met in order, partially met in coverage — see Issues. `git show --stat 7b7d1fb` is the two test files alone; `git show --stat aa155fc` is the two scripts alone. At `7b7d1fb` the brief test fails (`FAIL (1R) (2A): .scratch/review/HEAD_2/fix-lines is not the lines r1..HEAD changed`) and the comment test exits 1, so the tests do fail before the scripts land.
- **Criterion 6 (#93's 13B, 5C, 5D).** Met. 13B at `tests/spec-review/review-brief.sh:742-753` (both from the PR and from `--previous`). 5C and 5D at `tests/spec-review/review-comment.sh:938-948` (`for r in 4 5`, `restart`, `round: $r of 5`, `act-on items: 0`).
- **Criterion 7 (SKILL.md step 1; P20 retitled and amended).** Met. `template/.agents/skills/spec-review/SKILL.md:25` carries the dictated step-1 paragraph, `:77` step 4's "in a fix-only round (step 1)" / "Absent otherwise", `:144` step 6's three lines. P20's title is now "Review rounds: three, five after a Would-break fix, fix-only from round three" with an `Amended 2026-09-23 (#106)` clause, in `docs/knowledge/core/DECISIONS.md` and the generated `template/docs/factory918/DECISIONS.md`.

## 2. The scenario table, cell by cell

- Table A: labeled assertions exist for rows 1A/1B/1C, 2A/2B/2C, 3A/3B/3C, 4A/4B/4C, 5A/5B/5C, 6A, 7A/7B, 8A, 9A, 10A, 11A, 12A, 13A/13B, 14A/14B, 15A/15B, 16A, 17A/17B, 18A, 19A, 20A, 21C, 22. That is exactly the set the ticket's `### Tests` list enumerates, and it is a subset of the table's cells (see Issues).
- Table B: labeled assertions for 1A-1D, 2A-2D, 3B/3C, 4B, 5B, 6B, 7A-7D, 8A/8B, 9A/9B, 10A/10B, 11 (via 3E, relabeled `#106 11D`), 12, 13 — `tests/spec-review/review-comment.sh:992-1200`. Pre-existing round-two accepts were relabeled 3C (`:277`, `:297`) rather than moved, as the ticket directed.
- Tests before scripts, in the commit order: confirmed above.

## 3. Scope

Grouped, every file in `git diff --stat 01a1e5f..caecbc4`:
- Scripts (the ask): `template/.agents/skills/spec-review/scripts/review-brief.sh`, `review-comment.sh`.
- Tests (the ask): `tests/spec-review/review-brief.sh`, `review-comment.sh`, `no-stale-wording.sh` (adds the one stale phrase `From round four on both briefs carry`, in scope).
- Vendored prose, each through its patch: `template/.agents/skills/spec-review/SKILL.md` + `patches/mattpocock/spec-review.SKILL.md.patch`; `template/.agents/skills/babysit/SKILL.md` + `patches/pstack/babysit/SKILL.md.patch`; `template/.agents/skills/poteto-mode/playbooks/babysit.md` + `patches/pstack/poteto-mode/playbooks/babysit.md.patch`. `SOURCES.md` items 4, 6 and 12 describe all three.
- Sources: `template/docs/agents/review-ladder.md`, `docs/knowledge/core/MANUAL.md`, `docs/knowledge/core/DECISIONS.md`.
- Generated: `docs/knowledge/INDEX.md`, `template/docs/factory918/DECISIONS.md`, `template/docs/factory918/MANUAL.md`.
Nothing outside the ticket's `### Files touched`. No new script, no new refusal in `review-comment.sh`, no renumbered step, `tests/eval/reviewer/` and the delegation hook untouched — as the ticket required.

## 4. Receipts

- `gh api repos/Zenoctra/factory918/issues/125/comments`: exactly two, both by `Zenoctra`.
- The voided one, `5792617219`, now reads "Posted in error: this comment held another pull request's review text…" plus the model line. `grep -nE '^(round:|act-on items:|restart|would-break|fix only after|next round owed)'` over its body: no match. No `act-on items:` and no `restart`.
- **`review-brief.sh` ignores it, proved by running it.** I rebuilt `pr.json` from the two live comment bodies with `jq` and ran `PATH=<fake-gh>:$PATH FAKE_GH_DIR=… bash template/.agents/skills/spec-review/scripts/review-brief.sh 01a1e5f4… --ticket 106` (the repo's own `tests/spec-review/fake-gh.sh` as `gh`). Output: `round: 2 of 3`, whole diff, `settled: carried 0`. `<dir>/standards-brief.md` has no `## The fix under review`; `<dir>/reviewed` = `caecbc44…`; `<dir>/fix-lines` written but empty, correct because the RV sha is `HEAD`. If the voided comment were read the round would be higher, so it is not read.
- The real round one, `5792623153`: ends `reviewed: caecbc448983e071d4289d252f515993c4978cbf` / `round: 1 of 3` / `act-on items: 0`; two Consider items, no Act on. The new `reviewed:` line is dogfooded on this very PR.
- `gh pr checks 125`: `Factory pass 1m25s`, `Fixture pass 41s` (run 35844249945).
- `gh pr view 125 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`: head `caecbc44…`, base `feat/reviewer-model-eval`, `MERGEABLE`, not draft, closes `#106` and nothing else.

## 5. PR body against AGENTS.md "Pull requests"

- Plain-sentence title: "Review only round two's fix at round three when round two found nothing outside it". OK (P14, not `type(scope):`).
- Problem then fix in the opening two paragraphs. OK.
- No `## Blast Radius`. The diff is not cross-cutting (`review-brief.sh` did not refuse for a missing grounding in my live run, which it does for a cross-cutting diff). OK.
- `## Overlap` sits before `## Verification`. OK. Its `go:` block matches the three branches' file sets I checked against the diff.
- Verification names each criterion with the evidence, and every outcome given there reproduced for me (below).
- `Closes #106` is present, but the model-and-harness line sits **before** it, so the body does not end with the model and harness. See Issues.
- Attribution line present.

## 6. Forbidden edits

- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, then `git status --porcelain` empty. `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`. So `docs/knowledge/spec|pages|notes`, `docs/knowledge/INDEX.md` and `template/docs/factory918/` match a rebuild; nothing was hand-edited there.
- `./factory918.sh sync` → `vendored: 72 skills`, exit 0, `git status --porcelain` empty. So the three vendored files are reproduced by their patches; no vendored file was hand-edited.
- Nothing under `research/` or `tools/bootstrap/` touched.

## 7. Judgment on the location rule (P106) and its false-inside

The rule as implemented (`review-comment.sh:245-247`): an item is inside when some quoted line's trimmed text (four characters or more) is a fix line **and** no `+`/`-` quoted line is a non-fix line. `ok` starts at 1, so an item with **no marked lines at all** — a reviewer quoting plain code rather than a diff hunk, which is the ordinary shape in this repo's reports — is "inside" as soon as a **single** line of its quote coincides with a fix line.

I reproduced it. With `<dir>/round` = 2, `<dir>/fix-lines` holding `exit 1 # miss` and `exit 0`, and a Standards report whose one Would-break item is located at `old.sh:40` (untouched code) and quoted as a plain ```` ```sh ```` block:

```
if [ -z "$dir" ]; then
  exit 0
fi
```

`bash template/.agents/skills/spec-review/scripts/review-comment.sh <dir>` printed `fix only after 0123…4567` with `act-on items: 2`. A second run with fix lines `exit 1 # miss` and `else`, and a quote containing an ordinary `else`, printed the same line. So a round-two Would-break finding in unchanged code makes round three fix-only whenever one quoted line of it — including a bare `else`, `done`, `esac`, `return` or `exit 0` — happens to be a line the fix commits touched. Round three then never re-reads that code, which is precisely what Manuel's "at least one pass with zero new happy-path hard bugs" was meant to prevent.

Likelihood: not remote. The floor is four characters, so `else` (4) and `done` (4) qualify, and any round-two fix that adds or removes a branch touches one of them. The `ok` guard never bites on a plain-code quote because there are no marked lines to fail it.

Classification: **judgment for Manuel, not a defect on this PR.** The behavior is exactly what #106's `### Terms` specifies ("at least one quoted line's text is a fix line and every marked quoted line's text is a fix line") and what P106 records word for word. Under #90's rule, changing the meaning of "inside the fix" is a design hole, so it belongs to `architect` and an amendment, not to a fix here. What is wrong on this PR is only the owner's description of it: the report's Decided says the miss "misleads only when every marked quoted line coincides", which understates the case above, where there are no marked lines at all.

## Issues

- The PR body's model-and-harness line sits before `Closes #106`, so the body does not end with it, against `template/AGENTS.md:75` ("End with the model and harness that did the work") and against the house order used by merged PRs #124 and #102 (`Closes #N`, attribution, model line last).
- Criterion 5 asks for "one assertion per cell" of the table; the tests implement the subset the ticket's own `### Tests` list enumerates. Table A cells 6B, 6C, 7C, 8B, 8C, 9B, 9C, 10B, 10C, 11B, 11C, 12B, 12C, 13C, 15C, 16B, 16C, 17C, 18B, 18C, 19B, 19C, 20B, 20C, 21A and 21B have no assertion, though the table gives each an outcome ("same", "as A"). The gap is in the ticket's Testing decisions, not a deviation from it, so it is a design-level shortfall, not an implementation miss.
- The owner's Decided item on the accepted false-inside describes only the marked-line case; the reproducible and likelier case is an item with no marked lines at all (section 7). The text should say so before Manuel reads it as a narrow cost.

## Notes

- `docs/agents/ledger.md` gains nothing on this branch. The owner's report states the ledger line for the shared-scratchpad incident is deliberately left to the root so no unreviewed commit follows the reviewed head. That is a reasoned deviation from `AGENTS.md` "a surprise goes to `docs/agents/ledger.md`"; the root must actually add it.
- The shared scratchpad is still shared. Mid-audit, two files I had written under `…/48857ffb-…/scratchpad/` (`c1.txt`, `c2.txt`) were overwritten by another lane between two of my reads, which briefly produced a wrong `round: 3 of 3` from my fake-gh run. I redid every receipt check under a private subdirectory `audit-125-private/`. The verdict above rests only on the private-directory runs.
- The babysit sentence writes the placeholder as `round <N>` while `SKILL.md` step 6 and the script write `round <N+1>`. Both are prose placeholders for the same line and the test pins the sentence, so nothing breaks; it is the ticket's dictated wording.
- `SKILL.md` step 6 says the FO line prints "when no Would-break or Fails-open item in either report quotes a line outside those fix commits". Read strictly against the code that is not the rule (a quoted context line outside the fix does not make the item outside). Again the ticket's dictated text.
- Commands I ran at `caecbc4`, all exit 0: `bash tests/spec-review/review-brief.sh` → ok 986; `bash tests/spec-review/review-comment.sh` → ok 264; `bash tests/spec-review/no-stale-wording.sh` → ok; `bash tests/hooks/delegation.sh` → ok 55; `bash tests/poteto-mode/overlap.sh` → ok 57; `bash tests/shellcheck/gate.sh` → ok 17; `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 21`, no findings. The PR body says 23 files for that command; the glob set at this SHA is 21. Cosmetic.
- `review-brief.sh:287` does `rm -rf "$dir"` before `mkdir -p`, so a stale `fix-lines` from an earlier run in the same dir cannot survive into a later round. Row 2B's `no_ff` assertion therefore tests real behavior.
- The working tree was left clean (`git status --porcelain` empty) and detached at `caecbc448983e071d4289d252f515993c4978cbf`. Nothing was merged, commented, edited or closed.
