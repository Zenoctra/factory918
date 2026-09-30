verdict: PASS+NOTES

For a person: the receipts on PR #125 hold. The seven criteria are met in the code, the design hole from the first pass is really closed (I read the old rule at caecbc4 and it does read a plain quote as inside; the new rule cannot), the tests were written before the scripts in both waves and genuinely fail without them, and everything the PR body claims ran, ran here. One table A cell (14C) has neither an assertion nor a written reason, and two judgment calls belong to Manuel rather than to a fix.

Setup

- `git rev-parse HEAD` = `0edf8c8952e7563ec862e460f71becde4506bd96`; `git merge-base --is-ancestor 01a1e5f HEAD` exit 0. Nine commits, 18 files, +983/-52 (`git diff --stat 01a1e5f..0edf8c8`).
- Own worktree `.claude/worktrees/agent-a8100148c3e9746e5`, private `TMPDIR`, `.scratch` and `.claude/state` removed after the runs; `git status --porcelain` empty at the end.

## 1. The seven criteria

- **1 (rounds one and two byte for byte).** Met. `tests/spec-review/review-brief.sh:867-883` (`same()`) reruns the same history with `sed '/^reviewed: /d; /^fix only after /d; /^next round owed: /d'` applied and `cmp`s stdout, `diff`, both briefs and `round`; called at cells 2A-4C and 12A. The only round-two path in `review-comment.sh` that could print a new line is the FO line, and the two pre-existing round-two accepts keep their expected output byte for byte — the diff at those lines changes the label only (`tests/spec-review/review-comment.sh:277,297`; `git diff` hunk shows `-…"two Act on and one Ask, round 2; the walk's three lines are not items"` / `+…(#106 3C: hard items, no fix lines)"`). Across the whole test diff only six `-` lines exist, all comment or label text. Caveat under Notes.
- **2 (fix-only from round three, from the comment and the changed ranges, never a human's word, sticky).** Met. Gate: `review-brief.sh:244-245` (`elif [ "$round" -eq 3 ] && [ "$top" -eq 2 ] && [ -n "$fo" ]; then from="$fo" via="fix only after"`). Verdict: `review-comment.sh:242-272` (`outside()`) reads `standards-report.md` and, with a spec, `spec-report.md` — the reviewers' reports, never `judgment.md`; `review-comment.sh:1119-1130` in the test asserts the same item moved from Act on to Dismissed gives the same verdict. Ranges: `review-brief.sh:356-372` writes `fix-lines` and `fix-ranges`. "A previous round with a hard finding in unchanged code makes the next round whole-diff again" acts at round three only, and stickiness needs no code because a round past three exists only as #93's fix-only round — argued in the ticket's Terms and asserted by brief rows 15-18.
- **3 (fixed point, `FIX3`, refusals, #93 unchanged).** Met. One shared block at `review-brief.sh:247-257` raises `FR`, `FP` (with `$via` interpolated, so #93's text is byte-identical at rounds four and five) and `FT`; `common()` switches on `if [ -n "$from" ]` (`review-brief.sh:423`) instead of `round -ge 4`. Round-three item filter at `review-brief.sh:259-266`. Brief-test row 16 pins #93's `FP` text via the unchanged `fp` helper.
- **4 (owed line, babysit reads it).** Met. `review-comment.sh:277-285` prints the owed line at rounds one and two with no hole; the sentence is byte-identical in `template/.agents/skills/babysit/SKILL.md` and `template/.agents/skills/poteto-mode/playbooks/babysit.md` (verified with one `grep -o` over both) and pinned at `tests/spec-review/review-brief.sh:1234-1236`.
- **5 (one row per history, one assertion per cell, tests first).** Met except one cell — see Issues. Tests-first proved by running them: at `7b7d1fb` the comment test exits 1 at "nothing found, no spec, no round file" and the brief test at "(1R) (2A): .scratch/review/HEAD_2/fix-lines is not the lines r1..HEAD changed"; at `8fd83e1` the comment test exits 1 at "a hard item quoting a `-` line whose text is a fix line: a `-` line never counts (3B)" and the brief test at "(1R) (2A): …is not the unique lines r1..HEAD added". Commit order oldest first: 7b7d1fb (tests) → aa155fc (scripts) → … → 8fd83e1 (tests) → f33a08a (scripts); `git log --name-only` confirms 7b7d1fb and 8fd83e1 touch test files only.
- **6 (#93's 13B, 5C, 5D).** Met. 13B: `tests/spec-review/review-brief.sh:743-744` ("13B: --round 2 after the restart, from the PR and from the --previous file"). 5C/5D: `tests/spec-review/review-comment.sh:939-948`, a `for r in 4 5` loop labelling `5C`/`5D` inline.
- **7 (SKILL.md step 1, P20).** Met. `template/.agents/skills/spec-review/SKILL.md:25` carries the new step-1 sentences and the reason ("one full pass found no new hard bug outside a fix before the review narrows to fixes (Manuel, #106)"); step 4 at line 77, step 6 at line 144. `docs/knowledge/core/DECISIONS.md:89` is retitled "Review rounds: three, five after a Would-break fix, fix-only from round three" and carries "Amended 2026-09-23 (#106): …". `tests/spec-review/no-stale-wording.sh` gains `From round four on both briefs carry` and passes.

**Does the new rule honor Manuel's quoted intent?** Yes, on both of his sentences. "Wait until a review came back only with hard findings on fixes" is exactly the FO condition; "at least one pass goes with zero new happy path hard bugs" is satisfied because rounds one and two are whole-diff and the gate vetoes on any hard item outside the fix. In practice the rule collapses to "round two found no hard item", which is stricter than he asked for.

**Where it could still fail open.** Three places, all narrow, two already disclosed by the owner:
- An item that quotes one unique `+` fix line and names no `file:line` reads inside even if the defect is elsewhere. Every hard item must carry a `Documented step:` (`review-comment.sh:122-123` refuses a report with one missing), but that line may quote a ticket line rather than a `file:line`, in which case the location veto never fires. Owner's report line 95 accepts this.
- The location scan's token is `path:N` only (`review-comment.sh:251`, `loc`). A location written in prose as "line 9 of a.sh" is invisible to the veto. Combined with the point above, a `+`-quoting item citing a line in words reads inside.
- A round two that reports zero hard items because the reviewer lane underperformed licenses fix-only unconditionally. `review-comment.sh` refuses a malformed or missing report, so a crashed lane is caught, but a weak one is not. Owner's report line 106 discloses this.

## 2. Tables and test order

- **Table A.** 55 labelled cells present; 10B/10C are generated inside the loop at `tests/spec-review/review-brief.sh:1042` (`for cell in "10A:" "10B:--round 3" "10C:--previous previous-2f-head.md"`), row 22's four assertions at lines 1215-1227. Written reasons for 6B/6C (line 1004), 20B/20C (line 1190) and 21B (line 1211), each also on the ticket. Judging them: 6B/6C is sound — row 6's history is literally row 5's comment, and the brief never reads a hard item; 20B/20C is sound — round three with `top`=2 reads no line of the round-one comment, and 20A asserts the full `$r3_fix` block; 21B is the weakest but still sound as a composition of 21A's input path and 5B's flag. **14C has neither** (Issues).
- **Table B.** Every cell the ticket's Tests section prescribes is present, including rows 12 and 13 whose labels read `(12)` and `(13, after 2B)` / `(13, after 7B)` (`tests/spec-review/review-comment.sh:1293,1104,1223`), and the amendment's 14B (line 1305) and 15B (lines 1313-1333).
- **Tests before scripts, both waves.** Proven by running them at the tests commits — see criterion 5 above. Not a claim taken from the PR body.

## 3. The Design hole route

- The route was followed as the Ticket playbook requires. Comment `5792876117` carries `restart` on its own line and an Act on item `1. [P1] … hole: table 2/B`; ticket #106 carries "Amended 2026-09-23 by #125 (review round 1, hole at table 2/B): …" plus a "### Terms (amended 2026-09-23)", "### Table B rows (amended 2026-09-23)", "### Contract (amended 2026-09-23)" and "### Tests (amended 2026-09-23)"; the new round one is `5793367657` with `act-on items: 0` and `reviewed: 0edf8c8952e7563ec862e460f71becde4506bd96`.
- **Round counting against the real history.** I rebuilt the exact input `gh` would hand the script: `gh api repos/Zenoctra/factory918/issues/125/comments --paginate` into `{author, comments}`, then the script's own filter `jq -r '.author.login as $a | [.comments[] | select(.author.login == $a and (.body | test("(^|\n)act-on items:")))] | .[] | .body, "\u001e"'` (copied verbatim from `review-brief.sh:109`). It selects exactly 3 of the 4 comments — the voided `5792617219` is dropped, because it holds only the "Posted in error" note and no `act-on items:` line. Running the brief over that stream:

  ```
  $ bash template/.agents/skills/spec-review/scripts/review-brief.sh 01a1e5f4… --ticket 106 --previous history.txt
  ticket: #106
  restart: the round and the settled items count from the last restart comment
  round: 2 of 3
  settled: carried 0, dropped 0 without a citation
  ```
  Exit 0. The `round:` line is **`round: 2 of 3`** — the restart is honored (history counts from after `5792876117`, leaving one round-one comment) and the voided comment is ignored. `fix-lines` and `fix-ranges` were written and are empty (the RV sha is HEAD, so the fix diff is empty), and `standards-brief.md` holds no `## The fix under review`.
  I could not run the `gh` binary path itself: this worktree's guard refuses a command that prepends a directory to `PATH`, so the fake `gh` could not be reached. The decomposition above covers everything downstream of the fetch plus the fetch's own jq filter; the remaining untested inch is `gh`'s own record-separator emission, which #93's and this PR's `pr me …` fixtures exercise.

## 4. Scope and vendored edits

- Three vendored files change (`spec-review/SKILL.md`, `babysit/SKILL.md`, `poteto-mode/playbooks/babysit.md`), each with its patch in the same commit (`5f9a598`, `8d3496a`), each patch listed in `patches/series` (lines 4, 5, 20), each described in `SOURCES.md` items 4, 6 and 12 (all three updated in the diff).
- `./factory918.sh sync` re-vendors 72 skills and leaves `git status --porcelain` empty, which is the real proof the patches and the vendored copies agree.
- No file under `research/`, `tools/bootstrap/`, `docs/knowledge/spec|pages|notes/` is touched. Nothing outside the ticket's "Files touched" list is touched.

## 5. PR body

- `Closes #106` is the last content line before the attribution; the attribution `🤖 Generated with [Claude Code](…)` follows, and `Claude Opus 5.5 on Claude Code` is last. `## Overlap` precedes `## Verification`. Title is a plain sentence (P14, not `type(scope):`). One concern.
- `closingIssuesReferences` = `[106]` only; `baseRefName` = `feat/reviewer-model-eval`, whose remote head is `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438` — the patch base.
- CI: run `35849516283` on `0edf8c8…`, conclusion `success`; `gh pr checks 125` shows Factory pass and Fixture pass.
- Every outcome the Verification section claims reproduced here: `review-brief.sh` **ok 1104 assertions**; `review-comment.sh` **ok 298 assertions**; `no-stale-wording.sh` **ok: no stale wording**; `shellcheck.sh` over the AGENTS.md set **ShellCheck 0.11.0, files checked: 21** (the body says 23 — see Notes); `tests/shellcheck/gate.sh` **ok 17**; `tests/hooks/delegation.sh` **ok 55**; `tests/poteto-mode/overlap.sh` **ok 57**; `tests/knowledge/provisional-ids.sh` **26 assertions passed**; `tests/eval/reviewer/refusals.sh` **all 230 checks passed**. All exit 0.

## 6. Forbidden edits, generated files

- `python3 tools/build_knowledge.py` → "knowledge files: 119 → docs/knowledge", `git status --porcelain` empty. `python3 tools/check_knowledge.py` → "knowledge ok: 119 files". `./factory918.sh sync` → `git status --porcelain` empty. The generated `template/docs/factory918/DECISIONS.md` and `MANUAL.md` changes in the diff are exactly what the rebuild produces from the edited core files.

## 7. P106 against the code

P106 (`docs/knowledge/core/DECISIONS.md:104`, under `## Provisional`) reads: "A hard item is inside round two's fix only when it quotes at least one `+` line of four characters or more, every `+` or `-` line of four or more it quotes is a `+` line whose text the fix commits added and occurs exactly once across the HEAD versions of the files round two reviewed (`<dir>/fix-lines`), and every `path:N` or `path:N-M` in its unfenced lines, its `Documented step:` included, names exactly one of those files at lines inside one new-side range of the fix commits (`<dir>/fix-ranges`)."

The code says the same three things:

```awk
fence != "" && hard && /^[+-]/ { s = substr($0, 2); sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s)
  if (length(s) >= 4) { marked = 1; if (!/^\+/ || !(s in fix)) ok = 0 } }
…
hard { t = $0; while (match(t, loc)) { tok = …; if (!in_fix(tok)) ok = 0 } }
function done() { if (hard && !(marked && ok)) out++; … }
```
(`template/.agents/skills/spec-review/scripts/review-comment.sh:261-267`)

`marked && ok` is inside. A `-` line of 4+ sets `marked` but clears `ok`, so `marked` can only survive with a `+` fix line present — which is P106's first clause. Uniqueness lives where P106 puts it, in the brief (`review-brief.sh:366`, `n[s] == 1`). The location scan runs after `$fenced`, so it sees unfenced lines only, and the item's opening line reaches it because the `/^[0-9]+\. /` rule no longer ends in `next`. Match, clause for clause.

**The hole is real and is closed.** At `caecbc4` the capture rule was `if (length(s) >= 4) { if (s in fix) hit = 1; else if (m) ok = 0 }` with `m = /^[+-]/` (`git show caecbc4:…/review-comment.sh:246-247`): an *unmarked* line whose text was a fix line set `hit` and left `ok` at 1, so a plain ```sh block quoting `  exit 0` read as inside. At HEAD only `/^[+-]/` lines are captured and `marked` replaces `hit`, so no unmarked line can make an item inside. Cell 14B (`tests/spec-review/review-comment.sh:1294-1306`) runs exactly that reproduction over three fixtures and asserts no `fix only after` line.

**The owner's Decided items.** Seven of eight need nothing: the inside rule, what counts as outside, the fix files computed by the brief, stickiness, the three comment lines, the round-three fix section, and cell 21A (I confirmed the gh path carries `settled: carried 3` against `carried 1` for `--previous` of (2F) alone — `tests/spec-review/review-brief.sh:898-900` versus `:1201-1205` — so the amended expectation is the correct one, and the ticket carries the dated line). Two are judgment for Manuel, both already surfaced under the report's Blocked section:
- **The simpler rule.** Requiring round two to report *no* hard item would drop `fix-lines`, `fix-ranges`, the `reviewed:` line and the whole inside rule. P106 records that the corpus gives the same verdict either way. That is a real cost/benefit call and it is his.
- **The accepted residual false-inside** (a `+`-quoting item that names no location). Small, but it is the same class of hole that the first design shipped with.

Nothing here is a defect.

## Issues

- Table A cell **14C** (a restart history supplied through `--previous`) has neither a labelled assertion nor a one-line reason, in the test or on the ticket, against criterion 5's "one assertion per cell". The ticket's own amendment list of uncovered cells (7C, 8B…21A) and its reason list (6B, 6C, 20B, 20C, 21B) both omit it. Not blocking: the behaviour is asserted under other labels — `tests/spec-review/review-brief.sh:414` ("a restart comment from a --previous file holding both comments (5C)") and `:482`, `:741` — and `no ff` follows from `top` = 0, which 14A and 14B assert on the gh path. A one-line reason in the test and a dated line on the ticket would close it.

## Notes

- The PR body says ShellCheck ran over "the 23 files AGENTS.md names"; the command AGENTS.md gives reports "files checked: 21" here. The glob expands to what it expands to, and there are no findings either way; the number in the body is wrong, not the run.
- Criterion 1's `same` helper compares the new script against *itself* with the new lines stripped, not against the pre-#106 script. It is the right proxy (the new lines are the only new inputs, and no pre-existing round-one or round-two expectation moved — I checked every `-` line of both test diffs), but it is a proxy, and worth knowing if criterion 1 is ever re-litigated.
- The owner's claim that none of the 13 real hard items under `tests/eval/reviewer/rounds/` would read inside is the load-bearing evidence for "fix-only in practice means round two found no hard bug". I did not re-measure it; it is the one quantitative claim in the Decided section that no assertion pins.
- The ticket's second dated amendment (cell 21A) came from the writer during implementation, not from a review finding, so no second restart was owed; the dated line on the ticket is the right artifact.
- `review-brief.sh` writes `fix-lines`/`fix-ranges` only when the RV sha resolves *and* is an ancestor of HEAD; with neither file `outside()` reads an empty fix set, so any hard item with a marked line is outside. Every uncertain path costs more review, never less — I found no path where a missing input licenses fix-only other than the intended "zero hard items" case.

Claude Opus 5 (1M context) on Claude Code
