Amended 2026-09-23 by #125 (review round 1, hole at table 2/B): an item is inside the fix only when it quotes at least one `+` line of four characters or more, every such marked line (`+` or `-`) is a `+` line whose text the fix commits added and which occurs exactly once across the HEAD versions of `<dir>/files`, and every `path:N` it names, its `Documented step:` included, lies in one new-side range of the fix commits in the one file of `<dir>/files` it names. Unmarked quoted lines, the plain-code shape of most Standards items, now decide nothing, so a plain quote can never read as inside (the reproduction in the PR #125 audit, section 7). Removed lines are no longer fix lines. The brief also writes `<dir>/fix-ranges`, and `ff` in table A means both files. Why: the old rule let one plain quoted line that matched a fix line (`exit 0`, `else`) make a finding in unchanged code look like part of the fix. Round three then skipped that code, against "at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews." Moved assertions: in the comment test, the `inside` fixture, 6B (now no `FO`), and 3B's context case (same outcome, new reason). In the brief test, the `ff` and `no_ff` helpers (2A to 3C and 22) and the second fix commit's `a.txt`. Also added: the reproduction as 14B, the location cells as 15B, and an assertion or a one-line reason for each table A cell listed under point 2.

### Terms (amended 2026-09-23)

The "fix lines" are written by round two's brief to `<dir>/fix-lines` when the deciding comment is a round-one comment (`top` = 1) carrying the RV line, the round being briefed is 2, the RV sha resolves and it is an ancestor of `HEAD`. A fix line is a line that `git diff --no-color --no-ext-diff --no-renames -U0 <rv> HEAD` adds, less its `+` marker and trimmed of surrounding blanks. It is kept only when at least four characters remain and that text occurs exactly once across the HEAD versions of the files in `<dir>/files` (each version trimmed the same way), and it is listed once. A line the fix removed is not a fix line. In round two's whole diff, a removed line shows only when it existed before the PR, and nothing in the text can tell a removal by the fix apart from a removal by round one's code. The uniqueness test replaces the idea that `}`, `fi` and `done` identify nothing. A text that occurs twice in the files the reviewer was shown, such as `exit 0`, `else` or a line repeated in two hunks, cannot say which hunk a quote came from, so it locates nothing. In the same run the brief writes `<dir>/fix-ranges`: for each file of `git diff --no-renames -z --name-only <rv> HEAD`, one line `start<TAB>end<TAB>path` for each hunk of that file's `-U0` diff whose new side is non-empty. In every other case neither file is written, and a missing or empty file is an empty set. In table A, `ff` means both files are written from the sha named, and `no ff` means neither file exists.

A hard item's "quoted lines" are the lines inside its fenced blocks, between its opening line and the next item or heading. The fence rule is the `fenced` fragment both scripts share. A quoted line is "marked" when it starts with `+` or `-`. Its "text" is the line less that marker, trimmed. It counts only when the text has at least four characters and the line is not a fence delimiter or a hunk header (starting `@@`). An unmarked quoted line counts for nothing. The item's "named locations" are the tokens `path:N` and `path:N-M` in its unfenced lines: the opening line, prose, `Documented step:`, `Result:` and `spec:` alike. A token is a run of letters, digits, `_`, `.`, `/` and `-` holding at least one letter, then `:` and a line number, with an optional `-` and a second number. A named location is "in the fix" when exactly one path in `<dir>/files` equals `path` or ends in `/path`, and N (and M) lie in one range of `<dir>/fix-ranges` for that path.

A hard item is "inside the fix" when three things all hold. It has at least one counted marked line. Every counted marked line starts with `+` and its text is a fix line. Every named location is in the fix. In every other case the item is outside. Examples: it quotes nothing; it quotes only plain code, whatever lines that code shares with the fix; it quotes a `-` line; it quotes a `+` line the fix did not add, or one whose text is not unique; it quotes a `---` or `+++` header; or it names a `file:line` outside the fix ranges, outside `<dir>/files`, or matching more than one file there. That includes the `file:line` of its `Documented step:`, which for a finding about a surface the PR missed is where the bug is. Every uncertain case falls toward outside, which means a whole-diff round three: more review, never less. In practice round three is fix-only when round two reports no hard item. It is also fix-only when every hard item quotes, as a `+` hunk, only lines the fix added and points nowhere else. The real reports under `tests/eval/reviewer/rounds/` quote plain code or ticket checkboxes, so the second case is rare.

### Table B rows (amended 2026-09-23)

Legend addition. Column B has a non-empty `<dir>/fix-lines`, with `<dir>/fix-ranges` and `<dir>/files` beside it. Column C has `<dir>/fix-lines` absent or empty. It is now empty also when the fix added no line of four characters or more whose text is unique across the HEAD versions of `<dir>/files`.

| Reports and judgment | A. `<dir>/round` absent or `1` | B. `2`, fix lines | C. `2`, no fix lines | D. `3`, `4`, `5` |
|---|---|---|---|---|
| 2. Every hard item inside the fix (Standards and Spec both, whatever the judgment): at least one `+` line of four characters or more, every marked line a `+` fix line, unmarked context and marked lines under four characters (`+fi`) neutral, every named location (its `Documented step:` included) in one fix range | `RV` / 0 | `FO` / 0 / round three fix-only | no `FO` / 0 / round three whole diff | `T` |
| 3. One hard item quoting a marked line that is not a `+` fix line: code the rest of the PR added, a `-` line (the fix's removals included), an added line whose text occurs twice in `<dir>/files` at HEAD, a `---` or `+++` header; or quoting only unmarked lines; under Act on, Noted or Dismissed alike | `RV` / 0 | no `FO` / 0 / round three whole diff (criterion 2) | no `FO` | `T` |
| 5. A Spec hard item quoting its ticket line, plain or as a `- [ ]` checkbox | `RV` | no `FO`: a plain quote has no marked line, and `- [ ] …` is a `-` line | no `FO` | `T` |
| 6. A hard item quoting a line the fix removed (bare or `-`-prefixed), or an added line `+`-prefixed and indented, with unmarked context lines around it that the fix did not touch | `RV` | the removed line: no `FO` (a bare line is plain, a `-` line is never a fix line). The added line alone: `FO` when that is every hard item, since context lines are neutral | no `FO` | `T` |
| 7. An Act on item marked `fixed:` under any heading (criterion 4) | `OW(2)`, `RV` / 0 / not review-ready at any count | `OW(3)`, then `FO` per rows 1 to 6, 14 and 15 / 0 / not review-ready | `OW(3)`, `FO` per row 1C or 2C | `T`: no owed line (the last-round path, #93) |
| 8. A Would-break fix (#93 row 3) | WB, `OW(2)`, `RV` / 0 | WB, `OW(3)`, `FO` per rows 1 to 6, 14 and 15 / 0 | WB, `OW(3)`, `FO` per 1C/2C | `T` (#93 3B to 3D) |
| 14. A hard item quoting plain code (no `+` or `-` line) in which a line's text is in `<dir>/fix-lines`: `exit 0`, `else`, the item located at `old.sh:40` (the PR #125 audit's reproduction) | `RV` | no `FO`: no marked line, so outside | no `FO` | `T` |
| 15. A hard item whose marked lines are all `+` fix lines but which names a location outside the fix: `old.sh:40` (not in `<dir>/files`), `a.sh:9` (in it, outside every range), `SKILL.md:2` (two files end in it), a range `a.sh:2-9` that leaves the fix range, or a `Documented step:` citing a doc line the fix did not touch | `RV` | no `FO` | no `FO` | `T` |

### Contract (amended 2026-09-23)

**`review-brief.sh`, edit 5 replaced.** After `git rev-parse HEAD > "$dir/reviewed"`, under the same condition as before:

```sh
if [ "$round" -eq 2 ] && [ "$top" -eq 1 ] && [ -n "$rv" ] && git rev-parse --verify -q "$rv^{commit}" >/dev/null && git merge-base --is-ancestor "$rv" HEAD; then
  awk 'FILENAME == ARGV[1] { s = $0; sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); n[s]++; next }
    /^\+\+\+ / { next }
    /^\+/ { s = substr($0, 2); sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); if (length(s) >= 4 && n[s] == 1 && !seen[s]++) print s }' \
    <(while IFS= read -r p; do git show "HEAD:$p" 2>/dev/null || true; done < "$dir/files") \
    <(git diff --no-color --no-ext-diff --no-renames -U0 "$rv" HEAD) > "$dir/fix-lines"
  : > "$dir/fix-ranges"
  while IFS= read -r -d '' p; do
    git diff --no-color --no-ext-diff --no-renames -U0 "$rv" HEAD -- ":(literal)$p" |
      P="$p" awk '/^@@ / { split(substr($3, 2), r, ","); c = (r[2] == "") ? 1 : r[2] + 0
        if (c > 0) printf "%d\t%d\t%s\n", r[1], r[1] + c - 1, ENVIRON["P"] }' >> "$dir/fix-ranges"
  done < <(git diff --no-renames -z --name-only "$rv" HEAD)
fi
```

`FILENAME == ARGV[1]` rather than `FNR == NR`, so an empty first stream (every file of `<dir>/files` deleted at HEAD) cannot make the diff be read as file text. The path goes through `ENVIRON` because `-v` would expand backslashes. It goes through `:(literal)` because a path holding `*` or `?` would otherwise act as a pathspec pattern. The comment above the block becomes: "Round two after a round-one comment carrying `reviewed: <sha>`: the lines the commits since that commit (the fix commits) added, less their markers and surrounding blanks, kept when four characters or more remain and the text occurs once across the HEAD versions of the files this round reviews, so a quote of it can have come from nowhere else; and the new-side line ranges of those commits per file. review-comment.sh reads both to decide whether round three may review the fix alone. The brief writes them because it runs at the reviewed commit, and the comment script stays free of git." The header clause "added or removed to `<dir>/fix-lines`" becomes "added, and where, to `<dir>/fix-lines` and `<dir>/fix-ranges`".

**`review-comment.sh`, `outside()` replaced.**

```sh
# outside: the number of Would-break and Fails-open items in both reports (the Spec report only
# with a spec) that are not inside the fix. An item is inside when it quotes a `+` line of four
# characters or more, every `+` or `-` line of four or more it quotes is a `+` line whose text,
# less the marker and trimmed, is a fix line (<dir>/fix-lines: lines the fix commits added whose
# text is unique in the files this round reviewed), and every path:N or path:N-M outside its
# fences, its Documented step included, names exactly one file of <dir>/files at lines inside one
# range of <dir>/fix-ranges. Unmarked quoted lines decide nothing, so a plain-code quote is outside;
# every uncertain case reviews more. The capture rule runs before `$fenced`, which skips the fenced
# lines it reads; the location scan runs after it, on unfenced lines only.
outside() {
  local f total=0
  for f in "$dir/standards-report.md" ${has_spec:+"$dir/spec-report.md"}; do
    total=$((total + $(awk -v fixf="$dir/fix-lines" -v rangef="$dir/fix-ranges" -v filesf="$dir/files" '
      BEGIN {
        while ((getline l < fixf) > 0) fix[l] = 1
        while ((getline l < filesf) > 0) path[++np] = l
        while ((getline l < rangef) > 0) { t = index(l, "\t"); lo[++nr] = substr(l, 1, t - 1) + 0; l = substr(l, t + 1)
          t = index(l, "\t"); hi[nr] = substr(l, 1, t - 1) + 0; at[nr] = substr(l, t + 1) }
        loc = "[A-Za-z0-9_./-]*[A-Za-z][A-Za-z0-9_./-]*:[0-9]+(-[0-9]+)?"
      }
      function in_fix(tok,   p, n, a, b, d, i, k, want) {
        match(tok, /:[0-9]+(-[0-9]+)?$/); p = substr(tok, 1, RSTART - 1); n = substr(tok, RSTART + 1)
        a = n + 0; b = a; d = index(n, "-"); if (d) b = substr(n, d + 1) + 0
        k = 0; for (i = 1; i <= np; i++) if (path[i] == p || substr(path[i], length(path[i]) - length(p)) == "/" p) { k++; want = path[i] }
        if (k != 1) return 0
        for (i = 1; i <= nr; i++) if (at[i] == want && lo[i] <= a && b <= hi[i]) return 1
        return 0
      }
      function done() { if (hard && !(marked && ok)) out++; hard = 0; marked = 0; ok = 1 }
      fence != "" && hard && /^[+-]/ { s = substr($0, 2); sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s)
        if (length(s) >= 4) { marked = 1; if (!/^\+/ || !(s in fix)) ok = 0 } }
    '"$fenced"'
      /^## / { done(); next }
      /^[0-9]+\. / { done(); hard = (h == "Would break" || h == "Fails open") }
      hard { t = $0; while (match(t, loc)) { tok = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH); if (!in_fix(tok)) ok = 0 } }
      END { done(); print out + 0 }
    ' "$f")))
  done
  echo "$total"
}
```

A fence delimiter and an `@@` line never start with `+` or `-`, so the capture rule needs no exclusion for them. The token is copied and `t` advanced before `in_fix` runs, because its `match` overwrites `RSTART`. The opening-line rule no longer ends in `next`, so the location scan reads the item's first line. The script's header clause "when no Would-break or Fails-open item of either report is outside the fix (`<dir>/fix-lines`)" becomes "...outside the fix (`<dir>/fix-lines`, `<dir>/fix-ranges`)".

**Prose.** `spec-review/SKILL.md` step 6, through its patch: the clause "when no Would-break or Fails-open item in either report quotes a line outside those fix commits (an item that quotes no code, as a Spec item quoting its ticket line does, counts as outside)" becomes "when every Would-break and Fails-open item in either report quotes, as `+` lines of a hunk, only lines those fix commits added, and names no `file:line` outside them (an item that quotes plain code or no code, as a Spec item quoting its ticket line does, counts as outside)". The step 1 sentence is unchanged, and so are both round briefs (criterion 1). P106's record of the location rule, in the owner's records commit, takes the Terms paragraph "inside the fix" above in one sentence. The description of the accepted false-inside in the PR's Decided section is removed, since the case no longer exists.

### Tests (amended 2026-09-23)

**`tests/spec-review/review-comment.sh`, the #106 block.**

- `at()` writes `exit 1 # miss` alone to `<dir>/fix-lines`, since the brief no longer writes the removed `exit 0`. It also writes `printf 'a.sh\nold.sh\nlib/SKILL.md\ndocs/SKILL.md\n' > "$dir/files"` and `printf '1\t3\ta.sh\n' > "$dir/fix-ranges"`. `item()` is unchanged, and its `Documented step: `a.sh:2`` now sits inside the range.
- `inside` becomes ` if [ -f "$1" ]; then`, `+  exit 1 # miss`, `+fi`. The expected output of every cell using it stays the same (2A, 2B, 2D, 5B, 7A to 7D, 8A, 8B, 9A, 9B, 12, 13).
- 3B, `context`: same output, relabeled "a hard item quoting only unmarked lines: no marked line (3B)".
- 3B, new: an item quoting `--- a/a.sh`, `+++ b/a.sh` and `+  exit 1 # miss` gives no `FO`. With `exit 0` added to `fix-lines` by hand, an item quoting `-  exit 0` also gives no `FO`, which shows a `-` line never counts.
- 3B, new: with `printf 'exit 1 # miss\n'` and the item quoting `+  exit 2 # elsewhere` alone, no `FO`. The existing `outside` case stays.
- 4B, new: an item quoting only `+fi` and `+}` gives no `FO`, since short marked lines are neutral and none is counted.
- 5B, new: the Spec item quoting `- [ ] The brief carries the ticket body.` with empty Standards gives no `FO`. This is the shape of `pr94-r1`'s four Spec items.
- 6B moves. The item quoting ` if …`, `-  exit 0`, ` fi` beside the added-line item now gives no `FO` ("a removed line is never a fix line (6B)"). New: the added-line item (` if [ -f "$1" ]; then`, `+  exit 1 # miss`) alone gives `FO` (6B).
- 14B, the reproduction. With `printf 'exit 1 # miss\nexit 0\nelse\n'` in `fix-lines` (what the pre-amendment brief could write) and an item with `Documented step: `old.sh:40`` quoting the plain ```` ```sh ```` block `if [ -z "$dir" ]; then` / `  exit 0` / `fi`, there is no `FO`. The same with `Documented step: `a.sh:2`` gives no `FO`, which isolates the plain-quote rule from the location rule. A plain block holding `else` also gives no `FO`. Label: "the PR #125 audit's reproduction: a plain quote sharing a fix line (14B)".
- 15B, the `inside` quote with a location added to the item's prose. `old.sh:40`, `a.sh:9`, `SKILL.md:2`, `a.sh:2-9`, and a `Documented step:` of `docs/x.md:3` each give no `FO`. `a.sh:1-3` gives `FO`, and so does `lib/SKILL.md:2` with `printf '1\t3\ta.sh\n1\t3\tlib/SKILL.md\n'` in `fix-ranges`. With `fix-ranges` removed, the plain `inside` item gives no `FO`, since its `a.sh:2` is then in no range.

**`tests/spec-review/review-brief.sh`, the #106 block.**

- The second fix commit writes `printf '  hook fixed\n  walk fixed\nok\n  walk fixed\n' > a.txt`, so the fix adds `walk fixed` twice.
- `fix_lines='hook fixed'`. `four` is removed and `walk fixed` is not unique. `fix_ranges="$(printf '1\t4\ta.txt')"`: a.txt at `r1` is the single line `four`, and HEAD's four lines all differ from it.
- `ff` compares both files. `no_ff` asserts that neither exists. The cells 2A, 2B, 2C, 3A to 3C and 22 move through the helpers and keep their labels.

**Point 2, the table A cells with an outcome and no assertion.** All are in the brief test.

- 6B, 6C: no assertion. Row 6's history is byte-identical to row 5's, because the brief never reads a hard item, and 5B and 5C run it.
- 7C: `refused "(2F) from --previous, the original fixed point (7C)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7 --previous previous-2f.md`.
- 8B: `refused` the `FR(3)` text with `"$r2" --ticket 7 --round 3` over `previous-2f-gone.md`. 8C: the same through `--previous previous-2f-gone.md`.
- 9B: on the `no-ticket` branch, `refused` the `FT(3)` text with `"$r2" --round 3`. 9C: the same through `--previous previous-2f.md`.
- 10B, 10C: the row-10 block's empty-diff check, repeated with `--round 3` and with `--previous previous-2f-head.md`.
- 11B: `refused … "$(fp3 "$r2" paths)" --paths a.txt --commits HEAD --round 3`. 11C: the same with `--previous previous-2f.md`.
- 12B, 12C: inside the row-12 loop, for the four single-file variants, `has out.txt "round: 3 of 3"` and `lacks` the fix section with `--round 3`, then again with `--previous <file>`. The stranger and rebuilt-(2) variants have no `--previous` form, since a file is trusted as the author's (#93), and 12B runs them by the gh path.
- 13C: `--previous` of a file concatenating (1R) and (2 with RV) gives `R(3)`, the whole diff, and no ff.
- 15C: `--previous` of (1R), (2F), (3W s) concatenated, with `"$s3"`: `round: 4 of 5`, and `fixed_section` with round three's line only.
- 16B: `refused … "$(fp 4 "$s3" "$r2")" "$r2" --ticket 7 --round 4`. 16C: the same through `--previous`.
- 17C: `refused … "$f4" "$s3" --ticket 7 --previous` of (1R), (2F), (3).
- 18B: `--round 5` with `"$t"` gives `round: 5 of 5`. 18C: `--previous` of the four comments gives the same, and with (5) appended, `refused "$f6"`.
- 19B, 19C: `--round 3`, and `--previous` of (1), (2), each giving `R(3)`, the whole diff and no ff. Cheap, and it is the old-history path that criterion 1 rests on.
- 20B, 20C: no assertion. Round three with `top` = 2 never reads the round-one comment for a line, and S over (1) differs from S over (1R) by the RV line alone, which 5B and 5C already carry.
- 21A: `pr me me:previous-1r.md me:previous-2f-crlf.md`, then `"$r2" --ticket 7` gives the 21C lines. This is the gh path's `split`, which 21C does not exercise.
- 21B: no assertion. `--round 3` over the CRLF gh history takes 21A's input path, plus the flag that 5B already covers.
