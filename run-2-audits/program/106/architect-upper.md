# #106 architect candidate (upper tier)

Read against the worktree at `01a1e5f` (branch `feat/fix-only-from-round-two`, #93 and #124 merged in). Everything below the first rule is the section to append to the ticket; the design questions and the notes for the owner come after it.

---

## Testing decisions

Posted by the agent 2026-09-23

The two tables below are the spec for the fix-only third round and for the three new comment lines; the contract under them is what the scripts implement. Table A is `review-brief.sh` over the PR's comment history, table B is `review-comment.sh` over one round's reports and judgment. A review finding that changes a cell, adds a row or a column, or changes the meaning of a term the cells use (a hard item, inside the fix, the fix lines, the deciding comment, a fix-only round) is a design hole under #90's rule: it returns to architect and this section is amended with a dated line. A finding that leaves the tables standing while the code fails a cell is an implementation bug fixed on the PR. Every cell of #93's tables A and B keeps its outcome, and every cell of #90's; the assertions this design moves are named under Tests, each with the cell that moves it.

### Terms

#93's terms stand unchanged: comment, restart comment, history, deciding comment, `top`, would-break item, Would-break fix, reviewed commit, WB line, cap, fix-only round. This design adds the following and widens "fix-only round" to include one case of round three.

A "hard item" is a numbered report item under `## Would break` or `## Fails open` in the Standards or the Spec report, whatever the judgment does with it (Act on, Ask, Noted, Dismissed alike). Criterion 2 says "reported", and the judgment is the orchestrator's word, so the verdict never reads it.

The "RV line" is `reviewed: <sha>`, `<sha>` 40 lowercase hex, outside fenced text, the last such line in a comment being its own. `review-comment.sh` prints it on every round-one comment that marks no hole; `<sha>` is `<dir>/reviewed`, round one's reviewed commit. Its one reader is round two's brief.

The "fix-from commit" is written by round two's brief to `<dir>/fix-from`. It holds the RV line's sha when the deciding comment is a round-one comment (`top` = 1) that carries one and the round being briefed is 2. Otherwise no file is written. It is the commit round one reviewed, so `<fix-from>..<reviewed>` is the commits round two reviewed that round one did not: the fix commits.

The "fix lines" of a round-two dir are the added and removed lines of the non-merge commits in `<fix-from>..<reviewed>` (`git log -p --no-merges --format= -U0`), each less its `+` or `-` marker and trimmed of surrounding blanks, blank lines dropped. The set is empty, and every hard item is outside, when any of these holds: `<dir>/fix-from` is missing or not 40 hex, either commit does not resolve, or the fix-from commit is not an ancestor of the reviewed one (a rewritten branch). A removed line is a fix line, because a finding that quotes what the fix took out is a finding about the fix.

A hard item's "quoted lines" are the lines inside its fenced blocks. The fence rule is the `fenced` fragment both scripts share, and a line counts only when, trimmed, it is not empty, not a fence delimiter (starting with three backticks or tildes), not an elision (`...` or `…`) and not a hunk header (starting `@@`). A quoted line "matches" when it equals a fix line, or when it starts with `+` or `-` and equals a fix line once that one character is dropped and the rest trimmed. That second form covers a hunk quoted from the brief's diff.

A hard item is "inside the fix" when it has at least one quoted line and every quoted line matches. Otherwise it is outside: it has no fenced block, it quotes a line the fix did not touch, or it is a Spec item quoting its spec line. Every uncertain case falls toward outside, which means a whole-diff round three, which is more review and never less. Manuel's words set the direction: "at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews."

The "FO line" is `fix only after <sha>`, `<sha>` 40 lowercase hex, outside fenced text, the last such line in the deciding comment. `review-comment.sh` prints it on a round-two comment that marks no hole when `<dir>/reviewed` holds 40 hex and no hard item in either report is outside the fix. Zero hard items means none is outside, so the line prints with no fix-from commit at all. `<sha>` is round two's reviewed commit.

The "owed line" is `next round owed: round <N+1> reviews the fixes marked here`. `review-comment.sh` prints it on a round-one or round-two comment that marks no hole when any Act on item ends in a well-formed `fixed: <sha>`. A comment carrying it is not review-ready whatever its count (criterion 4).

A "fix-only round" is now one of two cases. The first is round three when the deciding comment is round two's (`top` = 2) and carries the FO line; its fixed point is the FO line's sha, round two's reviewed commit. The second is round four or five, as #93 defines it (the WB line's sha). Rounds one and two are never fix-only. Stickiness needs no code. The rule decides round three alone, and rounds four and five exist only as #93's fix-only rounds licensed by the WB line, so once round three is fix-only every later round is, and a round three that was whole-diff is followed only by fix-only rounds too. The clause "a previous round with a hard finding in unchanged code makes the next round a whole-diff round" therefore acts at round three only. Round four stays #93's, as criterion 3 requires.

The history notation extends #93's. `(1R r1)` is a round-one comment carrying `reviewed: r1`. `(1R+ r1)` is the same with Act on items marked `fixed:` and the owed line. `(2)` is a round-two comment without the FO line. `(2F r2)` is one carrying `fix only after r2`, its judgment holding an unmarked Act on item `1. [S1] **Hook in Python.** Ported.` and a ticketed one. `(3W s)` is as #93 has it. `o` is the original fixed point, `r1` and `r2` the commits rounds one and two reviewed, and `x` any other ref.

### Scenario table

**Legend, table A.** Cell = prints / exit / what the caller does. `R(n)`, `S`, `X`, `FIX` and `paths` are #93's. `FIX3` = both briefs carry `## The fix under review` before `## Blast radius` and `## Diff`: `$fix_rule` word for word as #102 wrote it, then the deciding comment's `## Judgment` Act on lines that do not end in `ticket: #N`, verbatim. `= today` = stdout, `diff`, `standards-brief.md` and `spec-brief.md` byte-identical to the same run over the same history with every RV, owed and FO line deleted. `ff` = `<dir>/fix-from` written, holding the sha named. `no ff` = the file absent. Exit 1 is one line on stderr before any output or state. The refusals are #93's `F4`, `F5`, `F6`, `FM`, `FR` and `FT`, their text unchanged. `FP(n,s,x,L)` is #93's `FP` with the line it names made a parameter: `review-brief: round <n> reviews only the fix from <s>, the commit round <n-1> reviewed (the ` `` `<L>` `` ` line of the last review comment); <x> is not that commit`. `L` is `would-break fixed after` at rounds four and five, so #93's text is byte-identical, and `fix only after` at round three.

The gate order is #93's, with one addition. After `F4`/`F5`, round three is fix-only when `round` = 3, `top` = 2 and the FO line is present. Then `FR`, `FP` and `FT` run for any fix-only round, three, four or five, all before the empty-diff and blast-radius refusals and before `mkdir -p "$dir"`. A malformed FO line is not refused. It is not the line, so round three is whole-diff, which is a legal outcome that reviews more. #93 refuses a malformed WB line because its absence would refuse the round with a misleading `F4`; a missing FO line refuses nothing.

**Table A: `review-brief.sh <fixed-point>` over the comment history**

| Situation | A. default (`gh`) | B. `--round N` | C. `--previous FILE` |
|---|---|---|---|
| 1. No comment (no PR, no comments, only strangers') | `R(1)`, no S, no FIX, `paths` / 0 / round one as today; no ff | `--round 2`: `R(2)`, no ff (`top` 0); `--round 3`: `R(3)`, no FIX, whole diff | an empty file: as A |
| 2. (1R r1), round one without fixes, fixed point `o` | `R(2)`, S, no FIX, `paths` / 0 / round two, whole diff from `o`, `= today`; ff `r1` | `--round 2`: as A; `--round 3`: `R(3)`, no FIX, no ff (`top` 1) | a file holding (1R r1): as A |
| 3. (1R+ r1), round one with fixes marked and the owed line | as row 2: the owed line changes nothing in the brief; ff `r1`; the marked fix commits are inside `r1..HEAD` | as row 2 | as row 2 |
| 4. (1R r1), (2), round two with a hard item outside the fix, fixed point `o` | `R(3)`, S, no FIX, `paths` / 0 / round three, whole diff from `o`, `= today`, last-round path; no ff | `--round 3`: as A | as A |
| 5. (1R r1), (2F r2), round two with hard items only inside the fix, fixed point `r2` | `ticket:`, `R(3)`, S over both, `FIX3` holding `1. [S1] **Hook in Python.** Ported.` and not the ticketed item, `paths` / 0 / round three reviews the fix commits `r2..HEAD` alone, last-round path; `--ticket N` is passed (row 9) | `--round 3`: as A; `--round 2`: `R(2)`, no FIX, no ff (`top` 2: a brief is rerun only before its comment is posted); `--round 4`: `F4` | a file holding (2F r2) alone: `R(3)`, S over it, `FIX3` / 0 |
| 6. (1R r1), (2F r2), round two with no hard item | as row 5: the FO line is the same line; table B row 1 is where the two differ | as row 5 | as row 5 |
| 7. As row 5, fixed point `x` ≠ `r2` (`o`, `HEAD`, `HEAD~1`) | `FP(3,r2,x,fix only after)` / 1 / rerun with `r2` | `--round 3`: same | as A |
| 8. As row 5, `r2` does not resolve in this clone | `FR(3,r2)` / 1 / fetch the PR's branch | same | as A |
| 9. As row 5, no `--ticket`, the fix commits name no `#N`, and (2F) had a spec | `FT(3)` / 1 / rerun with `--ticket N`; when (2F) carries `no spec: Standards axis only` under `## Spec`: `R(3)`, S, `FIX3`, the Standards path, `no spec: Standards axis only` / 0 | same | as A |
| 10. As row 5, no commit after `r2` | the existing empty-diff refusal naming `r2` / 1 / nothing to review | same | as A |
| 11. As row 5, the sweep form (`--paths ... --commits ...`) | `FP(3,r2,paths,fix only after)` / 1 / the sweep has no fix-only round | same | as A |
| 12. The words `fix only after` not as the line: inside a fenced hunk, in a stranger's comment, in a (2F) followed by a rebuilt (2), with a short, uppercase or trailing-text sha, with nothing after them | not the line: row 4's cell (`R(3)`, whole diff, `= today`) / 0 / no refusal | same | as A |
| 13. An FO line on a round-one comment (hand-written, or `--previous`), or an RV line on a round-two comment | not read there: (1F) is row 2 with no ff; (1R),(2 with RV) is row 4 | `--round 3` after (1F): `R(3)`, whole diff (`top` 1) | as A |
| 14. A restart: (1R r1), (2 restart), or (1R), (2F r2), (3 restart) | `X`, `R(1)`, no S, no FIX, no ff / 0 / the redesign's round one, whole diff from `o` | `--round 2` after either: `X`, `R(2)`, no FIX, no ff (`top` 0) | as A |
| 15. Round four after a fix-only round three: (1R), (2F r2), (3W s), fixed point `s` | `R(4)`, S over three, `FIX` with round three's `fixed:` lines / 0: #93 row 3 unchanged (sticky) | `--round 3`: `R(3)`, no FIX (`top` 3, #93 3B) | as A |
| 16. As row 15, fixed point `r2` | `FP(4,s,r2,would-break fixed after)` / 1 / #93's text byte for byte | same | as A |
| 17. (1R), (2F), (3), a plain round three | `F4` / 1 / the cap unchanged: fix what remains, mark `fixed:`, rebuild | `--round 5`: `F5` | as A |
| 18. (1R), (2F), (3W s), (4W t), fixed point `t`; then a fifth comment | `R(5)`, `FIX` with round four's items / 0; after (5) or (5W): `F6` / 1: #93 rows 9 and 11 | same | as A |
| 19. Histories written before this ticket: (1), (2), no RV or FO line | `R(3)` whole diff / 0 / today's round three | same | as A |
| 20. (1), (2F r2): an old round-one comment, then a round-two comment printing the FO line (only possible with no hard item, table B 1C) | as row 5 | as row 5 | as row 5 |
| 21. (2F r2) posted from the web UI (CRLF) | as row 5: `split` strips the CR | same | a CRLF file: as 5C |
| 22. Any run that writes state | #93's `<dir>/reviewed`; ff only in rows 2 and 3 and their B and C cells; a refusal writes neither | same | same |

Rerunning a row in the same round prints the same lines. The FO gate, the ff file and `FIX3` are functions of the fetched comments and the fixed point alone. Rounds one and two never read an FO line, and they read the RV line only to write ff, which neither stdout nor the briefs carry. So every round-one and round-two cell is `= today` (criterion 1).

**Legend, table B.** `T` = #93's tail: the summary line, then `restart` or the WB line as #93 says, then `round: N of <cap>`, then `act-on items: K`, with K unchanged. The new lines sit between the WB line's place and `round:`, in this order. `OW(n)` = the owed line with `<N+1>` = n. `RV` = `reviewed: <sha>`. `FO` = `fix only after <sha>`. `<sha>` in both is `<dir>/reviewed`'s first line, printed as the file holds it when it matches `^[0-9a-f]{40}$`. None of the three is ever printed beside `restart`. None is ever printed from round three on, so every #93 cell at rounds three to five is unchanged. A missing or malformed `<dir>/reviewed` removes RV and FO and refuses nothing, except where #93's `RM` already fires for a Would-break fix. Column B has `<dir>/fix-from` holding an ancestor of `<dir>/reviewed`, with fix lines computed from the two. Column C has `<dir>/fix-from` absent (an old round-one comment, `--round 2`, a rebuild), holding a commit that does not resolve, or holding one that is not an ancestor, so its fix lines are empty.

**Table B: `review-comment.sh [<dir>]` over one round's reports and judgment**

| Reports and judgment | A. `<dir>/round` absent or `1` | B. `2`, fix lines | C. `2`, no fix lines | D. `3`, `4`, `5` |
|---|---|---|---|---|
| 1. No hard item in either report, nothing marked `fixed:` | `RV`, `round: 1 of 3` / 0 / as today plus the record | `FO` / 0 / round three is fix-only if one is owed | `FO` / 0 / none is outside, so no fix line is needed | `T` / 0 / unchanged |
| 2. Every hard item inside the fix (Standards and Spec both, whatever the judgment) | `RV` / 0 | `FO` / 0 / round three fix-only | no `FO` / 0 / round three whole diff | `T` |
| 3. One hard item with a quoted line that matches no fix line (code the fix did not touch), under Act on, Noted or Dismissed alike | `RV` / 0 | no `FO` / 0 / round three whole diff (criterion 2) | no `FO` | `T` |
| 4. One hard item with no fenced block, or with only fence, elision, `@@` or blank lines inside it | `RV` | no `FO`: it has no quoted line, so it is outside | no `FO` | `T` |
| 5. A Spec hard item quoting its ticket line | `RV` | no `FO` unless every quoted line is a fix line | no `FO` | `T` |
| 6. A hard item quoting a line the fix removed, bare or `-`-prefixed, or an added line `+`-prefixed and indented | `RV` | `FO` when that is every hard item: removed and added lines are both fix lines | no `FO` | `T` |
| 7. An Act on item marked `fixed:` under any heading (criterion 4) | `OW(2)`, `RV` / 0 / not review-ready at any count | `OW(3)`, then `FO` per rows 1 to 6 / 0 / not review-ready | `OW(3)`, `FO` per row 1C or 2C | `T`: no owed line (the last-round path, #93) |
| 8. A Would-break fix (#93 row 3) | WB, `OW(2)`, `RV` / 0 | WB, `OW(3)`, `FO` per rows 1 to 6 / 0 | WB, `OW(3)`, `FO` per 1C/2C | `T` (#93 3B to 3D) |
| 9. An Act on item marked `hole:`, with or without a fix | `restart` only: no `OW`, `RV` or `FO` / 0 / #90 unchanged | same | same | `T` (#93 5B to 5D) |
| 10. `<dir>/reviewed` missing, empty, short or not hex, and no Would-break fix | no `RV` / 0 / round two will have no ff, and round three will be whole diff | no `FO` / 0 | no `FO` | `T` / 0 |
| 11. As row 10 with a Would-break fix | #93's `RM` / 1 | `RM` / 1 | `RM` / 1 | `RM` / 1 |
| 12. A `## Walk` line holding a fenced quote or `fixed:` | not an item: never a hard item, never marks a fix | ← | ← | ← |
| 13. A rerun with the dir after the state is cleared | the same output, new lines included: every input is in the dir or is a fixed commit | ← | ← | ← |

The summary line is unchanged, and no new line carries a count, since a count in the comment invites the between-rounds comparison #93 ruled out. `<dir>/round` is trusted as today. Every refusal #90 and #93 list is unchanged, with the same text in the same order; this design adds none to `review-comment.sh`.

Babysit on these cells: RV and FO change nothing about readiness. A round-two comment reading `act-on items: 0` with an FO line is review-ready, and no round three runs. A comment carrying the owed line is not review-ready whatever its count, and the orchestrator runs the round it names. The WB and `restart` sentences are unchanged.

### Contract

**The calls.** Unchanged in arguments. Round three after a comment carrying `fix only after <sha>` is run as `scripts/review-brief.sh <sha> --ticket N`, the form #93 gave rounds four and five. Exit codes as today.

**`review-brief.sh`, five edits.**

1. From the deciding comment, beside `wb_line`, two more reads with the same `fenced` awk. The RV sha `rv` is the last line outside fences that starts `reviewed: `, is 50 characters long and whose rest matches `^[0-9a-f]+$` (`substr($0, 11)`). The FO sha `fo` is the last line outside fences that starts `fix only after `, is 55 characters long and whose rest is lowercase hex (`substr($0, 16)`). Each is empty when there is no such line. Length checks stand in for an interval expression, per #93's amendment.
2. The gate. The existing `if [ "$round" -gt 3 ]` block keeps `F4`/`F5` and ends by setting `from="$wb" via="would-break fixed after"`, with `FR`/`FP`/`FT` lifted out of it. Then `elif [ "$round" -eq 3 ] && [ "$top" -eq 2 ] && [ -n "$fo" ]; then from="$fo" via="fix only after"; fi`, and one block for both cases:
   ```sh
   if [ -n "$from" ]; then
     want="$(git rev-parse --verify -q "$from^{commit}")" || { echo "review-brief: round $round reviews only the fix from $from, the commit round $((round - 1)) reviewed, and that commit does not resolve here; fetch the PR's branch" >&2; exit 1; }   # FR
     [ "$(git rev-parse --verify -q "$fixed^{commit}" 2>/dev/null || true)" = "$want" ] || { echo "review-brief: round $round reviews only the fix from $from, the commit round $((round - 1)) reviewed (the \`$via\` line of the last review comment); $fixed is not that commit" >&2; exit 1; }   # FP
     if [ -z "$ticket" ] && [ -n "$had_spec" ]; then echo "review-brief: round $round reviews only the fix and its commits name no ticket, while round $((round - 1)) had a spec; pass --ticket N so the Spec axis reads the same spec" >&2; exit 1; fi   # FT
   fi
   ```
   At rounds four and five every string is #93's byte for byte.
3. `fixed_items` is computed after the gate. When `via` is `fix only after`, it is the deciding comment's `## Judgment` Act on lines matching `^[0-9]+\. ` and not ending in `ticket: #[0-9]+`. Round two fixes its Act on items after the comment, so they are unmarked, and a marked one (row 3's case, one round later) is a fix too. Otherwise it keeps #93's `fixed: [0-9a-f]+$` filter.
4. `common()`: `if [ "$round" -ge 4 ]` becomes `if [ -n "$from" ]`. The two are equivalent at rounds four and five, since the gate sets `from` there or exits.
5. After `git rev-parse HEAD > "$dir/reviewed"`: `if [ "$round" -eq 2 ] && [ "$top" -eq 1 ] && [ -n "$rv" ]; then echo "$rv" > "$dir/fix-from"; fi`. The brief only copies. The comment script checks the commit, because it computes the verdict.

The header comment gains one clause after the `would-break fixed after` sentence: "Round three is fix-only the same way when round two's comment carries `fix only after <sha>` (review-comment.sh: no hard finding of round two outside the lines of the fix commits it reviewed); round two records the commit round one reviewed, from the round-one comment's `reviewed: <sha>` line, in `<dir>/fix-from`."

**`review-comment.sh`, one block and the tail.** After the WB block, before any output:

```sh
# Rounds one and two only (#106). Round one records the commit it reviewed for round two's brief;
# round two says whether round three may review the fix alone: only when no hard item of either
# report quotes a line outside the fix commits round two reviewed (<dir>/fix-from..<dir>/reviewed).
# A hole outranks every line, as it does the WB line.
owed="" record=""
if [ "$holes" -eq 0 ] && [ "$round" -le 2 ]; then
  [ "$fixed_here" -eq 0 ] || owed="next round owed: round $((round + 1)) reviews the fixes marked here"
  mine=""; [ ! -f "$dir/reviewed" ] || mine="$(head -n 1 "$dir/reviewed")"
  if printf '%s' "$mine" | grep -qE '^[0-9a-f]{40}$'; then
    if [ "$round" -eq 1 ]; then record="reviewed: $mine"
    elif [ "$(outside "$mine")" -eq 0 ]; then record="fix only after $mine"; fi
  fi
fi
```

`fixed_here` is moved above this block from where it sits today. `outside <reviewed>` prints the number of hard items in both reports, the Spec report only when `has_spec`, that are not inside the fix. It builds the fix lines once, into a temp file or a variable, with:

```sh
git log -p --no-merges --no-color --no-ext-diff --format= -U0 "$from..$1" |
  awk '/^diff --git /{ h = 0 } /^@@/{ h = 1; next } h && /^[+-]/ { l = substr($0, 2); sub(/^[ \t]+/, "", l); sub(/[ \t\r]+$/, "", l); if (l != "") print l }'
```

This runs only when `<dir>/fix-from` holds 40 hex, both commits resolve and `git merge-base --is-ancestor "$from" "$1"`; otherwise the set is empty. Then one awk per report. The capture rule goes before `$fenced`, so it sees fenced lines that `$fenced` would skip:

```sh
awk -v fixf="$fixlines" '
  BEGIN { while ((getline l < fixf) > 0) fix[l] = 1 }
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
  function done() { if (hard && !(seen && ok)) out++; hard = 0; seen = 0; ok = 1 }
  fence != "" && hard { q = trim($0)
    if (q != "" && q !~ /^(```|~~~)/ && q != "..." && q != "…" && q !~ /^@@/) {
      seen = 1; r = q; if (sub(/^[+-]/, "", r)) r = trim(r)
      if (!(q in fix) && !(r in fix)) ok = 0 } }
'"$fenced"'
  /^## / { done(); next }
  /^[0-9]+\. / { done(); hard = (h == "Would break" || h == "Fails open"); next }
  END { done(); print out + 0 }
' "$report"
```

The `## Walk` heading is never Would break or Fails open, so its lines are never hard. The tail, in order: the summary line unchanged; `restart` when `holes` is nonzero, else the WB line when `wb_first`; then `$owed` when set; then `$record` when set; then `round: $round of $cap`; then `act-on items: K`. The header comment gains, after the WB clause: "then, at rounds one and two with no hole, the line `next round owed: round <N+1> reviews the fixes marked here` when an Act on item is marked `fixed:`, and at round one `reviewed: <sha>` (`<dir>/reviewed`), at round two `fix only after <sha>` when no Would-break or Fails-open item of either report quotes a line outside the fix commits `<dir>/fix-from..<sha>`".

**Why the verdict lives in `review-comment.sh`.** It has the dir, which holds both reports, the reviewed commit and the fix-from commit. It runs once per round, and its output is posted on the PR, where the next brief, babysit and the human all read the same line. A rerun from the dir reproduces the line, because every input is a file in the dir or a fixed commit. The brief reads one line, as it reads #93's WB line.

**Prose, per file.**

- `spec-review/SKILL.md`, through `patches/mattpocock/spec-review.SKILL.md.patch` and `SOURCES.md` item 6 in the same commit.
  - Step 1, after "…a sixth round in every case: round five's Would-break fixes are the human's to review (step 5).", insert this: "Round three is fix-only too when round two's comment carries `fix only after <sha>` (step 6): run `scripts/review-brief.sh <sha> --ticket N`, and the script refuses any other fixed point with the same message. Round one always reads the whole diff, and so does round two, since round one reviewed no fix. Round three reads only the fix when round two reported no Would-break or Fails-open item, on either axis, outside the lines of the fix commits it reviewed: one full pass found no new hard bug outside a fix before the review narrows to fixes (Manuel, #106). Step 6 decides this from the reports and the fix commits, never from the judgment. Rounds four and five follow a Would-break fix as above, so once a round is fix-only every later round is." "From round four on both briefs carry `## The fix under review` (step 4)" becomes "A fix-only round's briefs carry `## The fix under review` (step 4)".
  - Step 4: the fix-section bullet's "from round four on" becomes "in a fix-only round (step 1)", and its "Absent before round four" becomes "Absent otherwise". The line list becomes "the Act on items the last review comment marks `fixed: <sha>`, or at round three every Act on item not marked `ticket: #N`".
  - Step 6, after the WB clause, insert: "then, at rounds one and two with no hole marked, the line `next round owed: round <N+1> reviews the fixes marked here` when any Act on item is marked `fixed:` (babysit reads it: such a comment is not review-ready at any count), and at round one `reviewed: <sha>` (`<dir>/reviewed`; round two's brief records it as the fix commits' start), at round two `fix only after <sha>` when no Would-break or Fails-open item in either report quotes a line outside those fix commits (an item that quotes no code, as a Spec item quoting its ticket line does, counts as outside),".
- `poteto-mode/playbooks/babysit.md` and `babysit/SKILL.md`, both through their patches with `SOURCES.md` items 4 and 12. After the sentence ending "…until the human answers the report the orchestrator posted on the PR.", insert this sentence, byte-identical in both files: "A round-one or round-two comment carrying the line `next round owed: round <N> reviews the fixes marked here` is not review-ready whatever its count: the orchestrator runs that round (`spec-review` step 1); the lines `reviewed: <sha>` and `fix only after <sha>` only record where the next round starts and change nothing here." #93's sentence stays byte-identical, so its pin holds.
- `docs/knowledge/core/MANUAL.md`, the merge-checklist item: after "…for your report)" insert "and no `next round owed:` line (a round-one or round-two comment whose fixes were marked before posting; the next round reviews them)". Then run `python3 tools/build_knowledge.py`.
- `template/docs/agents/review-ladder.md` rung 1: "One PR gets three rounds, five when…" gains ", round three reviewing only round two's fixes when round two found no hard bug outside them" before "and the review stops earlier", and the ready clause gains "and no `next round owed:` line".
- `docs/knowledge/core/DECISIONS.md` P20 (the owner's records commit): retitle it "Review rounds: three, five after a Would-break fix, fix-only from round three", and add a dated amendment: "Amended 2026-09-23 (#106): round three reviews only round two's fix commits when round two's reports hold no Would-break or Fails-open item outside those commits' lines, decided by `review-comment.sh` (`fix only after <sha>`) from the reports' quoted hunks and the commits `<dir>/fix-from..<dir>/reviewed`; rounds one and two stay whole-diff and print what they printed before; a round-one or round-two comment marking a fix prints `next round owed:` and is not review-ready."

### Tests, one assertion per cell

The tests commit lands before the scripts commit, and each assertion names its cell.

**`tests/spec-review/review-brief.sh`**, a new block after #93's row 20 and before the babysit pins, so #91's block still diffs its own `HEAD~1`. Setup: `r1="$(git rev-parse HEAD)"`; commit `fix the walk, #7` (round one's fix); `r2="$(git rev-parse HEAD)"`; commit `fix the hook, #7` (round two's fix), so `r2..HEAD` is that one commit. Fixtures:
- `previous-1r.md`: `previous.md` with `reviewed: $r1` before its `round:` line.
- `previous-1rp.md`: `previous-1r.md` with S1 moved to Act on as `fixed: <short>` and the owed line.
- `previous-2r.md`: `previous-2.md` unchanged (no FO line).
- `previous-2f.md`: `previous-2.md` with the Spec report of `previous-3-spec.md`, and under Act on `1. [S1] **Hook in Python.** Ported.` plus `2. [S3] **Bare number.** Out of scope. ticket: #12`, renumbered, with `fix only after $r2` before `round: 2 of 3`.
- `previous-2f-nospec.md`.

Two helpers:
- `fp3 <sha> <x>`: `FP(3,…,fix only after)`.
- `same <label> <history...>`: runs the brief over the history and over `sed '/^reviewed: /d; /^fix only after /d; /^next round owed: /d'` of it, then `cmp`s stdout, `diff`, both briefs and `round`.

Assertions in table order:

1. 1A: `pr me` with no comments, `HEAD~1 --ticket 7`: `R(1)` and `[ ! -e .scratch/review/HEAD_1/fix-from ]`.
2. 1B: `--round 2`, no ff; `--round 3`, `printed` `round: 3 of 3`, `lacks` the fix section.
3. 1C: an empty `--previous` file, as 1A.
4. 2A: `pr me me:previous-1r.md`: `printed` `R(2)`, S, paths; `same` over (1R) (criterion 1); `cat fix-from` = `$r1`.
5. 2B: `--round 2`, ff `$r1`; `--round 3`, `R(3)`, no ff.
6. 2C: `--previous previous-1r.md`, ff `$r1`.
7. 3A: `pr me me:previous-1rp.md`: `same`, ff `$r1`. Plus 3B and 3C, as 2B and 2C.
8. 4A: `pr me me:previous-1r.md me:previous-2r.md`, `HEAD~2 --ticket 7`: `R(3)`, `same`, no fix section, the brief's `## Commits` listing both fix commits, no ff.
9. 4B: `--round 3`, as 4A. 4C: `--previous` of the two, as 4A.
10. 5A: `pr me me:previous-1r.md me:previous-2f.md`, `"$r2" --ticket 7`: `printed` "ticket: #7 / round: 3 of 3 / settled: … / .scratch/review/$r2/standards-brief.md / …spec-brief.md", `round` = 3, `fixed_section` both briefs with `1. [S1] **Hook in Python.** Ported.`, `lacks` `ticket: #12` in the section, `only_commit` `fix the hook, #7`, `lacks` `fix the walk`.
11. 5B: `--round 3`, as 5A; `--round 2`, `R(2)`, no fix section, no ff; `--round 4`, `refused` `$f4`.
12. 5C: `--previous previous-2f.md "$r2"`, `R(3)`, `fixed_section`.
13. 6A to 6C: the same comment. One assertion, that row 5's runs hold, labeled 6A, since the brief sees the same line; the difference is asserted in table B row 1.
14. 7A: `refused` `$(fp3 "$r2" HEAD~2)` for `HEAD~2 --ticket 7`, and `$(fp3 "$r2" HEAD)` for `HEAD --ticket 7`. 7B: with `--round 3`.
15. 8A: `sed "s/$r2/000…0/"` of (2F), `refused` `FR(3)` text.
16. 9A: a fix commit naming no ticket, `"$r2"` without `--ticket`, `refused` `FT(3)` text; `previous-2f-nospec.md`, `printed` `round: 3 of 3` … `no spec: Standards axis only`, `fixed_section` Standards.
17. 10A: `(2F)` naming the current HEAD, the empty-diff refusal, as #93 18A.
18. 11A: `--paths a.txt --commits HEAD` after (2F), `refused` `$(fp3 "$r2" paths)`.
19. 12A: five variants, each `printed` `R(3)` from `HEAD~2`, `same` as 4A, no fix section: the FO line in a fence, from `stranger:`, (2F) then a rebuilt (2), the sha short, uppercase or with trailing text, and bare words.
20. 13A: (1F) as a `--previous` file: `R(2)`, no ff. (1R),(2 carrying an RV line): `R(3)`, whole, no ff. 13B: `--round 3` after (1F), `R(3)`, whole.
21. 14A: (1R),(2 restart) and (1R),(2F),(3 restart): `X`, `R(1)`, no ff. 14B: `--round 2` after each, `X`, `R(2)`, no ff.
22. 15A: (1R),(2F),(3W s) with `"$s"`: `R(4)`, `FIX` with round three's `fixed:` line only, the `Ported.` unmarked item absent. 15B: `--round 3`, `R(3)`, no FIX.
23. 16A: the same history with `"$r2"`: `refused` `$(fp 4 "$s" "$r2")`, #93's helper unchanged.
24. 17A: (1R),(2F),(3): `refused` `$f4`. 17B: `--round 5`, `$(f5 5 3)`.
25. 18A: (1R),(2F),(3W),(4W) with `"$s4"`: `R(5)`; then with (5): `refused` `$f6`.
26. 19A: (1),(2) old: `R(3)` whole, as today. This is #93's existing row-2 fixtures reused; the cell's assertion is new.
27. 20A: (1),(2F) old round one: as 5A.
28. 21C: a CRLF copy of (2F): as 5C.
29. 22: after 2A, `fix-from` exists and `reviewed` = HEAD; after 7A's refusal, neither file exists.

The anti-drift pins:
- `has "$source_skill/SKILL.md"` for the step 1 sentence "Round three is fix-only too when round two's comment carries `fix only after <sha>`".
- The new babysit sentence (`babysit_owed`), `has` in both babysit files.

The #93 cells without a direct assertion, placed in #93's block:
- 13B: `pr me me:previous.md me:previous-2.md me:previous-3w.md me:restart-4.md`, then `review-brief.sh HEAD~1 --ticket 7 --round 2`: `printed` "ticket: #7 / $restart_line / round: 2 of 3 / .scratch/review/HEAD_1/standards-brief.md / .scratch/review/HEAD_1/spec-brief.md", and `lacks "$std" "## The fix under review"`.
- Through `--previous both-3w.md --round 2`, the same.

No existing assertion in this file moves. Every existing fixture carries no RV, FO or owed line, and `FP` at rounds four and five keeps its text.

**`tests/spec-review/review-comment.sh`.** A variable `rv="reviewed: 0123456789abcdef0123456789abcdef01234567"` sits beside `$wb`. The header comment names the three lines.

Existing assertions that move, each to the cell that requires it:
- Every `accept` run at round one (no `round` file, or `1`) with no hole marked gains `$rv` immediately before `round: 1 of 3` (table B column A, rows 1 to 8). That is about twenty accepts, all in the fixture blocks before #93's; the writer lists each by label in the commit message.
- Those whose judgment marks an Act on item `fixed:` also gain `next round owed: round 2 reviews the fixes marked here` before `$rv`, and after `$wb` where #93 put it. These are #93's "a counted item with a spec line, fixed" (8A), "a hole before a trailing fixed field counts as fixed" (#93 4A, now 8A here), "a Would-break fix in the sweep form (9)" (8A), and any other round-one `fixed:` accept.
- The two round-two accepts ("two Act on and one Ask, round 2" and "the walk continued with two risk lines") do not move. They hold hard items with no `fix-from`, so they are cell 3C, and they are labeled so.
- Round-one accepts with a hole ("restart" outputs) do not move (9A).

New, in a block after #93's. Setup:
- In the suite's repo, commit `hook.sh` holding `if [ -f "$1" ]; then`, `  exit 0`, `fi` as `r1`.
- Commit a change adding `  exit 1 # miss` and removing `  exit 0` as `r2`.
- `echo 2 > "$dir/round"`, `echo "$r1" > "$dir/fix-from"`, `echo "$r2" > "$dir/reviewed"`.

Reports:
- `inside_std`: one Would-break item quoting `exit 1 # miss` in a ```sh block, with `Documented step:`, `Result:` and `spec: table 2/D` lines.
- `outside_std`: the same item quoting `if [ -f "$1" ]; then` and `exit 1 # miss`.
- `bare_std`: no fenced block.
- A Spec report whose one Would-break item quotes its ticket line.
- `empty_spec`.

Assertions:
1. 1A: empty reports, `round` absent: `…round: 1 of 3` preceded by `reviewed: $r2`.
2. 1B: empty reports at round 2: `fix only after $r2`.
3. 1C: the same with `fix-from` removed: `fix only after $r2`.
4. 1D: at 3, 4 and 5: no new line (three accepts).
5. 2A: `inside_std`: `$rv`-form line with `$r2`.
6. 2B: `inside_std` at 2: `fix only after $r2`.
7. 2C: the same with `fix-from` removed, then holding `0000…0`, then holding a commit not an ancestor (a side branch's commit): no line (three accepts).
8. 2D: `inside_std` at 3: no new line.
9. 3B: `outside_std` at 2: no line. Then the same item moved from Act on to Dismissed: no line, which is the judgment-independence cell.
10. 3C: `outside_std` with no `fix-from`: no line.
11. 4B: `bare_std`: no line. A fenced block holding only `...` and `@@ -1 +1 @@`: no line.
12. 5B: `inside_std` plus the Spec item quoting its ticket line: no line.
13. 6B: an item quoting `-  exit 0` and another quoting `+  exit 1 # miss`: `fix only after $r2`.
14. 7A: an Act on Standards-breaches item marked `fixed: abc1234`, `round` 1: `next round owed: round 2 reviews the fixes marked here`, then `$rv`.
15. 7B: the same at 2 with `inside_std`: `next round owed: round 3 …`, then `fix only after $r2`.
16. 7C: the same with no `fix-from` and `outside_std`: the owed line alone.
17. 7D: the same at 3: neither.
18. 8A: `inside_std`'s item marked `fixed: abc1234` at 1: the WB line naming `$r2`, the owed line, then `reviewed: $r2`, in that order.
19. 8B: at 2: WB, owed, then FO.
20. 9A: `hole: table 2/D` on the Would-break item at 1: `restart`, `round: 1 of 3`, no other new line.
21. 9B: at 2 with `inside_std` and `fix-from`: `restart` alone.
22. 10A: `rm "$dir/reviewed"` at 1 with no Would-break fix: no `reviewed:` line, exit 0. `echo abc1234 >` it: the same.
23. 10B: at 2 with empty reports and no `reviewed`: no FO, exit 0.
24. 11: as 10A with a Would-break fix: the existing `RM` text (#93 3E's assertion, now labeled 11A too).
25. 12: a Walk line with a fenced `exit 0` under it at 2 with `inside_std`: FO still prints.
26. 13: after 2B and 7B, `accept "$out" … "$dir"`: the same output, the new lines included.

The #93 cells 5C and 5D, which had no direct assertion, go in #93's row-5 block:
- `rearm; echo 4 > "$dir/round"; judged " hole: table 2/D" " fixed: abc1234" "" ""`: `accept` with `restart`, `round: 4 of 5`, `act-on items: 0` (5C).
- The same at `echo 5`, `round: 5 of 5` (5D).

**`tests/spec-review/no-stale-wording.sh`**: add `From round four on both briefs carry`. Its one hit, `spec-review/SKILL.md` step 1, is rewritten above.

### Criteria map

1. Table A rows 2 to 4 and every round-one and round-two cell are `= today`, proved by `same`'s byte comparison against the same history without the new lines, and by the unmoved existing round-one and round-two brief assertions.
2. Terms: hard item, fix lines, quoted lines, inside the fix, FO line. Table B rows 1 to 6 are the verdict, from the reports and the commits alone, with row 3B's Dismissed case showing it is independent of the judgment. Table A rows 4 and 5 are the two outcomes. Terms, "fix-only round", and rows 15 to 18 cover stickiness.
3. Table A rows 5 and 7 to 11 (`FP` with the line named, `FR`, `FT`, the sweep), `FIX3`, and rows 15 to 18 (#93 unchanged).
4. Table B row 7 and the babysit sentence in both copies, pinned.
5. Table A rows 1 to 6, 14, 15 and 18, and table B columns A and B, as the Tests list above.
6. #93 13B (in the brief test's #93 block), 5C and 5D (in the comment test's #93 row-5 block).
7. The step 1 prose and the P20 retitle and amendment above.

### Files touched

- `template/.agents/skills/spec-review/scripts/review-brief.sh` and `review-comment.sh`.
- `template/.agents/skills/spec-review/SKILL.md` with its patch.
- `template/.agents/skills/poteto-mode/playbooks/babysit.md` and `template/.agents/skills/babysit/SKILL.md` with their patches.
- `SOURCES.md` items 4, 6 and 12.
- `template/docs/agents/review-ladder.md`.
- `docs/knowledge/core/MANUAL.md`, then `python3 tools/build_knowledge.py`.
- `tests/spec-review/review-brief.sh`, `review-comment.sh` and `no-stale-wording.sh`.
- `DECISIONS.md` P20 and a Provisional row, in the owner's own commit.

No new script, no new refusal in `review-comment.sh`, no renumbered step. `ticket.md`, `tests/eval/reviewer/` (`rebuild.sh` runs the script at each round's pinned `script_at`) and the delegation hook are untouched. The hook reads the commands the orchestrator types, not the `git log -p` inside `review-comment.sh`.

---

## The five design questions, settled

**1. Where a hard finding's code location comes from.** It comes from the reviewer's own quoted hunk, matched by content against the fix commits' added and removed lines. `review-comment.sh` computes it once and prints the FO line, which is option (d) fed by option (b). Option (a), an `at: <path>:<line>` field on the judgment item, was rejected for two reasons. It is the orchestrator's word, and criterion 2 says "never from a human's word"; the script could check that the line number lies in range but not that the finding is at that line. It also asks the orchestrator to locate code while the delegation hook bars it from the files under review. Option (c) cannot reach round two's report, since the round-two brief is `= today`. The quote is the one code location every round-two report already carries: the Standards brief asks for "quote the hunk", and the reviewer who saw the code wrote it. Inside means every quoted line is a line the fix added or removed, and at least one line was quoted. A removed line counts, because a finding about what the fix deleted is a finding about the fix. Round one reviewed no fix, so the rule is never evaluated there: no FO line at round one, and round two is always whole-diff. Matching is by content, not by position. A quote made entirely of lines that happen to equal fix lines elsewhere would be misread as inside; that needs every quoted line to coincide, and it is listed for the owner below.

**2. How each round's reviewed commit reaches the next brief.** Round one's comment carries `reviewed: <sha>`. Round two's brief copies it to `<dir>/fix-from`. Round two's comment carries `fix only after <sha>`, its own reviewed commit, which is round three's fixed point, the way #93's WB line is round four's. Round one needs its own line because its WB line exists only after a Would-break fix, and the round-two verdict needs `r1` in every case. The line is printed at round one only, since round two's sha travels in the FO line and rounds three to five are #93's. Old comments carry neither line: no fix-from means no fix lines, so every hard item is outside and round three is whole-diff, the conservative fallback. The one exception is a round two with zero hard items, where nothing needs locating.

**3. Which items go under `## The fix under review` at round three.** Every Act on item of round two's comment not marked `ticket: #N`. Rounds one and two fix after the comment, so their Act on items are unmarked, and #93's `fixed:` filter would list nothing. An item marked `fixed:` before posting (criterion 4's case) is a fix too. Rounds four and five keep #93's filter unchanged.

**4. Criterion 4's line.** The exact text is `next round owed: round <N+1> reviews the fixes marked here`. It is printed at rounds one and two when any Act on item ends in `fixed:` and no hole is marked, after the WB line when there is one. The babysit change is one new sentence after #93's, byte-identical in both copies, and #93's sentence and pin are unchanged.

**5. How sticky is decided.** It is not decided at all, and that is the design. The FO rule applies to round three only, and a round past three exists only as #93's fix-only round, so every round after a fix-only round is fix-only with no history read and no line. A fix-only round three that still found a hard item outside its fix, followed by a Would-break fix, gives a fix-only round four: row 15, #93 unchanged.

## For the owner, before the lane starts

- Criterion 2's "a previous round with a hard finding in unchanged code makes the next round a whole-diff round again" is read as acting at round three only. Applied to round four, it would contradict criterion 3 ("the round after a Would-break fix … unchanged") and the brief's constraint that rounds four and five stay licensed only by the WB line. If the owner means round four can become whole-diff, that changes #93's table A row 3 and is a different design.
- A Spec hard item quotes its ticket line, not code, so any Spec Would-break or Fails-open item at round two keeps round three whole-diff. This follows criterion 2's "either axis" in the conservative direction. `tests/eval/reviewer/rounds/pr96-r2` shows the shape: its Spec Fails-open item quotes the ticket's design text, and its Standards items quote code in a ```sh block.
- Every round-one comment gains the line `reviewed: <sha>`, so about twenty expected outputs in `tests/spec-review/review-comment.sh` move. The alternative, printing it only when a round two is owed, moves nearly the same set, because most fixtures count Act on items, and it adds a condition. Unconditional is the smaller rule.
- The verdict is content matching. It can read "inside" when every quoted line coincides with a fix line in another place. This is rare, and the cost is one fix-only round three. The cost in the other direction, a correct inside finding read as outside because the reviewer quoted context lines, is one extra whole-diff round.
