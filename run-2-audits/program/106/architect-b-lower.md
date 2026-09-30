# Architect Phase B, ticket #106, design hole at table B row 2 column B ("inside the fix")

Lower-tier runner. Read-only: nothing in the repository was edited, nothing posted.

## Evidence the rule is built on

The only real reports this system has are `tests/eval/reviewer/rounds/*/review/*-report.historical.md`
in the worktree at `caecbc4`. They hold thirteen items under `## Would break` or `## Fails open`
across six PRs. How they quote:

- Plain fenced block, no `+`/`-` anywhere, quoting a spec line or a documented step. Eight items,
  for example `pr94-r1/review/spec-report.historical.md` item 1 (a ```` ``` ```` block holding the
  single checkbox line `- [ ] The Ticket playbook's architect step ...`) and
  `pr99-r1/review/spec-report.historical.md` item 1 (a checkbox from the ticket).
- Plain ```` ```sh ```` block of code copied from the file at HEAD, no markers. Four items, for
  example `pr96-r2/review/standards-report.historical.md` item 1 (five lines of the `for g in "$@"`
  loop) and item 2 (three lines of the cache block), and
  `pr99-r1/review/standards-report.historical.md` item 1 (the three `holed()` lines).
- One item, `pr99-r1b/review/standards-report.historical.md` item 1, quotes a single line carrying a
  `+` marker: `+act-on items: 0" "two holes print one restart line and both are left out"`.

So twelve of thirteen quotes carry no marker at all, and none is a `-`/`+` pair from a hunk. Under
today's rule every one of those twelve is one text coincidence away from reading as inside, with
`ok` never able to bite, which is exactly the reproduction in `worker-audit.md` section 7.

Second fact from the same corpus: `file:line` in the item's own prose is routine, and it is almost
always written as a bare basename, not a repository path. `review-brief.sh:222`, `shellcheck.sh:17`,
`review-comment.sh:114`, `architect/SKILL.md:32`, `template/.github/shellcheck.sh:37-39`,
`docs/knowledge/core/MANUAL.md:103`. Six of the thirteen items name at least one outside their
`Documented step:` line. A location check that matches only full paths from `<dir>/files` would
catch none of these; it has to match on the basename too.

Third fact, for frequency: of the round-two reports in the corpus (`pr94-r2`, `pr96-r2`, `pr99-r2`,
`pr102-r2`, plus `pr94-r3` and `pr96-r3` as the rounds that followed them), five of the six reports
that a round-two comment would have read hold no hard item at all, and one (`pr96-r2`) holds three,
all quoted as plain code. So under the amended rule round three goes fix-only through table B row 1
(no hard item) in five of six cases, and the "every hard item inside" path fires in none of them.
The amendment costs the feature almost nothing measured, and it removes the whole class Manuel's bar
is about.

## The amendment, as it is appended to `## Testing decisions`

Amended 2026-09-23 by #125 (review round 1, hole at table 2/B): an item now reads as inside the fix
only when it quotes a real diff hunk, because reviewers quote plain code and the old rule let one
coincidental line (`else`, `exit 0`) inside, so a hard finding in untouched code could send round
three fix-only; a quoted line counts only when it carries its own `+` or `-`, only against fix lines
of that same sign, and only when the fix line's text occurs nowhere else on that side of round two's
diff, and a `path:N` named in the item's prose at a line no fix hunk covers vetoes the item; moved
assertions: table B 2B, 2C, 3B, 5B and 6B are rebuilt on marked fixtures, new cells 14, 15 and 16
carry the reproduction, the location veto and the `---`/`+++` case, table A 2A and 22 gain
`fix-ranges`, and table A 7C, 8B, 8C, 9B, 9C, 10B, 10C, 11B, 11C, 12B, 12C, 13C, 15C, 16B, 16C, 17C,
18B, 18C and 21A gain the assertions they lacked.

### Terms (amended 2026-09-23)

These three paragraphs replace the paragraphs "The 'fix lines' are written by round two's brief…",
"A hard item's 'quoted lines' are…" and "A hard item is 'inside the fix' when…". Every other term
stands.

The "fix lines" are written by round two's brief to `<dir>/fix-lines` when the deciding comment is a
round-one comment (`top` = 1) carrying the RV line, the round being briefed is 2, the fixed point is
not the sweep form, the RV sha resolves and it is an ancestor of `HEAD`. A candidate fix line is an
added or removed line of `git diff --no-color --no-ext-diff -U0 <rv> HEAD`, less its `+` or `-`
marker and trimmed of surrounding blanks, kept when at least four characters remain (`}`, `fi`,
`done` are in every diff and identify nothing). A candidate is a fix line only when it is
**identifying**: its text occurs on its own side of round two's whole diff
(`git diff --no-color --no-ext-diff -U0 <fixed>...HEAD`) exactly as often as it occurs on that side
of the fix's diff. A text the rest of the PR also added, or also removed, therefore identifies
nothing, and neither does a line the fix re-added after round one removed it. Each fix line is
stored with its sign as its first character, so `+exit 1` and `-exit 1` are different fix lines.
`<rv>..HEAD` is the commits round two reviews that round one did not: the fix commits. In every
other case the file is not written, and a missing or empty file is an empty set. A removed line is a
fix line, because a finding that quotes what the fix took out is a finding about the fix. The same
pass writes `<dir>/fix-ranges`, one line `path start end` per hunk of `git diff -U0 <rv> HEAD` whose
new side is non-empty, `path` as the `+++ b/` header names it: the lines of the fix as they stand at
`HEAD`.

A hard item's "quoted lines" are the lines inside its fenced blocks, and its "prose" is its other
lines, both taken between its opening line and the next item or heading; the item's own opening line
is prose. The fence rule is the `fenced` fragment both scripts share. A quoted line is "marked" when
it starts with `+` or `-`; its "text" is the line less that one marker, trimmed, and it counts only
when the text has at least four characters and the line is not a fence delimiter or a hunk header
(starting `@@`). A marked line "is a fix line" when its marker and its text together are one of
`<dir>/fix-lines`. An unmarked quoted line counts nothing at all, whatever its text: it is the
context of a hunk, or plain code a reviewer copied out of the file, and neither says the finding is
about the fix. A `path:N` or `path:N-M` token in the item's prose, other than on its
`Documented step:` and `spec:` lines, is "cited" when `path` names a file of `<dir>/files`, by that
path or by a basename the path ends with; the token is "outside" when no `fix-ranges` line for a
file it names holds `N`.

A hard item is "inside the fix" when it has at least one marked quoted line, every marked quoted
line of four characters or more is a fix line, and no cited token of its prose is outside.
Otherwise the item is outside: it quotes nothing, it quotes only plain code with no marker (the
ordinary shape in this repository's reports), it quotes a marked line the fix did not add or remove
under that sign, a diff header (`--- a/app.sh` reads as a marked line `- a/app.sh`, which is no fix
line), or a line whose text the rest of the PR touched too, or its prose locates the finding at a
line of a changed file that no fix hunk covers. The location check can only ever push an item
outside; it never makes one inside. Every uncertain case falls toward outside, which means a
whole-diff round three, which is more review and never less. Manuel's words set the direction: "at
least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only
reviews."

### Table B rows (amended 2026-09-23)

These replace rows 2, 3, 5 and 6 and add rows 14 to 16. Rows 1, 4, 7 to 13 and every column D cell
stand. Column B still means `<dir>/round` = 2 with a non-empty `<dir>/fix-lines`, column C the same
round with the file absent or empty.

| Reports and judgment | A. `<dir>/round` absent or `1` | B. `2`, fix lines | C. `2`, no fix lines | D. `3`, `4`, `5` |
|---|---|---|---|---|
| 2. Every hard item inside the fix: each quotes a hunk holding at least one marked line, every marked line of four characters or more is a fix line of its own sign, and no cited token of its prose is outside (Standards and Spec both, whatever the judgment) | `RV` / 0 | `FO` / 0 / round three fix-only | no `FO` / 0 / round three whole diff | `T` |
| 3. One hard item quoting a marked (`+`/`-`) line that is not a fix line of that sign: code the rest of the PR added or removed, a line whose text the rest of the diff touched too, or an added line quoted with a `-`; under Act on, Noted or Dismissed alike | `RV` / 0 | no `FO` / 0 / round three whole diff (criterion 2) | no `FO` | `T` |
| 5. A Spec hard item quoting its ticket line, or any item quoting plain code with no marked line at all | `RV` | no `FO`: an unmarked line counts nothing, so the item quotes no fix line | no `FO` | `T` |
| 6. A hard item quoting a hunk in which the line the fix removed carries its `-` and the line it added carries its `+`, with unmarked context lines around them that the fix did not touch | `RV` | `FO` when that is every hard item: added and removed lines are both fix lines under their own sign, and context lines are neutral | no `FO` | `T` |
| 14. A hard item in untouched code, quoted as a plain code block, one of whose unmarked lines happens to be a fix line (`worker-audit.md` section 7: a bare `exit 0`, `else` or `done`) | `RV` | no `FO` / 0 / round three whole diff: the hole this amendment closes | no `FO` | `T` |
| 15. A hard item quoting a fix hunk whose prose names `<path>:<n>` at a line no fix hunk covers, `<path>` a file of `<dir>/files` by full path or by basename, outside its `Documented step:` and `spec:` lines | `RV` | no `FO` / 0 / the finding is located outside the fix | no `FO` | `T` |
| 16. A hard item quoting a full diff block, its `--- a/<file>` and `+++ b/<file>` headers included, around lines that are all fix lines | `RV` | no `FO` / 0 / the headers read as marked lines that are no fix line | no `FO` | `T` |

Neutral, and named so no reader has to infer it: a cited token in a file not in `<dir>/files`
(`CODING_STANDARDS.md:12`), one on the `Documented step:` or `spec:` line, one inside a fenced
block, and one at a line a fix hunk does cover, none of them changes anything. A marked line under
four characters (`+fi`, `+}`) still counts nothing, neither hit nor break, so an ordinary hunk's
braces do not push it outside.

One table A row changes, row 22 ("Any run that writes state"): `ff` now names both `<dir>/fix-lines`
and `<dir>/fix-ranges`, written together in rows 2 and 3 and their B and C cells and nowhere else; a
refusal writes neither. Neither file is read by any brief and neither appears in stdout or in a
brief, so criterion 1 is untouched.

### Contract (amended 2026-09-23)

**`review-brief.sh`, edit 5 replaced.** After `git rev-parse HEAD > "$dir/reviewed"`:

```sh
if [ "$round" -eq 2 ] && [ "$top" -eq 1 ] && [ -n "$rv" ] && [ "$fixed" != paths ] &&
   git rev-parse --verify -q "$rv^{commit}" >/dev/null && git merge-base --is-ancestor "$rv" HEAD; then
  : > "$dir/fix-ranges"
  { git diff --no-color --no-ext-diff -U0 "$fixed...HEAD"; echo '--8<-- fix'
    git diff --no-color --no-ext-diff -U0 "$rv" HEAD; } |
    awk -v rngf="$dir/fix-ranges" '
      $0 == "--8<-- fix" { fix = 1; next }
      /^(\+\+\+|---) / { if (fix && /^\+\+\+ /) { p = substr($0, 5); sub(/^b\//, "", p) } next }
      /^@@ / { if (fix && match($0, /\+[0-9]+(,[0-9]+)?/)) { t = substr($0, RSTART + 1, RLENGTH - 1)
          c = index(t, ","); s = (c ? substr(t, 1, c - 1) : t) + 0; n = (c ? substr(t, c + 1) : 1) + 0
          if (n > 0) print p, s, s + n - 1 > rngf } next }
      /^[-+]/ { t = substr($0, 2); sub(/^[ \t]+/, "", t); sub(/[ \t\r]+$/, "", t)
        if (length(t) < 4) next; k = substr($0, 1, 1) t; if (fix) f[k]++; else d[k]++ }
      END { for (k in f) if (f[k] == d[k]) print k }
    ' > "$dir/fix-lines"
fi
```

The first diff is the one the reviewer read (`<dir>/diff` covers exactly those files), so
`f[k] == d[k]` says every occurrence of that text on that side of what the reviewer could quote
belongs to the fix. `[ "$fixed" != paths ]` keeps the sweep form out, where `$fixed` is not a ref.
The header comment's clause gains, after "…added or removed to `<dir>/fix-lines`": "each with its
`+` or `-`, and only when the rest of the PR's diff does not carry the same text on the same side;
the fix's new-side line ranges go to `<dir>/fix-ranges`".

**`review-comment.sh`, `outside()` replaced.** The block that sets `owed` and `record` is unchanged.

```sh
outside() {
  local f total=0
  for f in "$dir/standards-report.md" ${has_spec:+"$dir/spec-report.md"}; do
    total=$((total + $(awk -v fixf="$dir/fix-lines" -v rngf="$dir/fix-ranges" -v filesf="$dir/files" '
      BEGIN { while ((getline l < fixf) > 0) fix[l] = 1
        while ((getline l < rngf) > 0) if (split(l, a, " ") == 3) { rp[++nr] = a[1]; rs[nr] = a[2] + 0; re[nr] = a[3] + 0 }
        while ((getline l < filesf) > 0) pf[++nf] = l }
      function done() { if (hard && !(hit && ok)) out++; hard = 0; hit = 0; ok = 1 }
      function cited(p, n,   i, j, seen, covered) {
        for (i = 1; i <= nf; i++) if (pf[i] == p || index(pf[i], "/" p) == length(pf[i]) - length(p)) { seen = 1
            for (j = 1; j <= nr; j++) if (rp[j] == pf[i] && n >= rs[j] && n <= re[j]) covered = 1 }
        return (seen && !covered) }
      function scan(t,   tok, c) { while (match(t, /[A-Za-z0-9_.\/-]+:[0-9]+/)) { tok = substr(t, RSTART, RLENGTH)
          t = substr(t, RSTART + RLENGTH); c = index(tok, ":")
          if (cited(substr(tok, 1, c - 1), substr(tok, c + 1) + 0)) ok = 0 } }
      fence != "" && hard && !/^(```|~~~)/ && !/^@@/ && /^[-+]/ {
        s = substr($0, 2); sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s)
        if (length(s) >= 4) { if ((substr($0, 1, 1) s) in fix) hit = 1; else ok = 0 } }
    '"$fenced"'
      /^## / { done(); next }
      /^[0-9]+\. / { done(); hard = (h == "Would break" || h == "Fails open"); if (hard) scan($0); next }
      hard && !/^(Documented step:|spec:)/ { scan($0) }
      END { done(); print out + 0 }
    ' "$f")))
  done
  echo "$total"
}
```

`$fenced` ends with `fence != "" { next }`, so the trailing `scan` rule sees prose only; the capture
rule stays ahead of it because `$fenced` would otherwise skip the fenced lines it reads.
`index(pf[i], "/" p) == length(pf[i]) - length(p)` is the basename match, which the corpus needs:
reviewers write `review-comment.sh:114`, not the path. The comment above `outside()` is replaced
with: "outside: the number of Would-break and Fails-open items in both reports (the Spec report only
with a spec) that are not inside the fix. An item is inside when it quotes at least one `+` or `-`
line whose marker and trimmed text are one of `<dir>/fix-lines`, every other `+` or `-` line it
quotes of four characters or more is one too, and its prose names no `<path>:<n>` of a file in
`<dir>/files` at a line outside `<dir>/fix-ranges`. An unmarked quoted line counts nothing: plain
code a reviewer copied says nothing about the fix. Every uncertain case reviews more."

Nothing else in either script moves. No new refusal, no new exit code, no change to any brief's
text or to either script's stdout at rounds one and two beyond the three lines #106 already added,
so criterion 1 stands as the runtime check (a) proved it.

### Tests (amended 2026-09-23)

**`tests/spec-review/review-comment.sh`.** The new block's setup gains `<dir>/files` holding
`app.sh` and `other.sh`, `<dir>/fix-ranges` holding `app.sh 40 42`, and `<dir>/fix-lines` holding
`-  exit 0` and `+  exit 1 # miss` written with their signs (the assertions above that read
unsigned fix lines are rewritten in the same commit).

Rewritten reports: `inside_std` keeps its ```` ```diff ```` block (` if [ -f "$1" ]; then` context,
`-  exit 0`, `+  exit 1 # miss`). `outside_std` keeps its two `+` lines. `ctx_std` becomes the
reproduction. New `hdr_std` carries `inside_std`'s hunk with `--- a/app.sh` and `+++ b/app.sh` above
it. New `loc_std` is `inside_std` with `other.sh:12` in its opening sentence.

Cells, replacing assertions 7, 10 and 12 of the old list and adding four:

- 2B, 2C, 6B: unchanged in outcome, rebuilt on the signed fixtures.
- 3B, second half: `inside_std` with its `+  exit 1 # miss` changed to `-  exit 1 # miss`: no line,
  the sign is part of the fix line.
- 5B: `inside_std` with every marker stripped from its quote: no line.
- 14B: `ctx_std`, a plain ```` ```sh ```` block holding ` if [ -f "$1" ]; then`, `  exit 0` and `fi`,
  the item located at `old.sh:40`, `fix-lines` as set up: no line, exit 0. This is
  `worker-audit.md` section 7 run as a cell, and it fails against the code at `caecbc4`.
- 14C: the same with `fix-lines` removed: no line.
- 15B: `loc_std`: no line. Then three neutral variants, each `fix only after $r2`: the token moved
  to the `Documented step:` line, the token changed to `app.sh:41` (inside a fix range), and the
  token changed to `CODING_STANDARDS.md:12` (a file not in `<dir>/files`).
- 16B: `hdr_std`: no line.
- 13 (the rerun cell) gains 14B and 15B, so the veto reproduces from the dir alone.

**`tests/spec-review/review-brief.sh`.** Assertion 4 (cell 2A) changes: `fix-lines` holds each fix
line with its `+` or `-`; a line the fix adds that an earlier commit of the PR also adds is absent;
`fix-ranges` holds one `path start end` line per fix hunk with a non-empty new side, and no line for
a delete-only hunk. Assertion 29 (row 22) names both files everywhere it named `fix-lines`. Setup
gains one commit before `$r1` that adds the duplicate line, so the identifying rule has something to
reject.

**Point 2, the table A cells with an outcome and no assertion.** Twenty gain one; six need none.

- 6B, 6C: none. Row 6 differs from row 5 only in the reports behind the comment, which no brief
  reads; 5B and 5C are literally the same runs over the same comment.
- 7C: `--previous previous-2f.md` with `HEAD~2 --ticket 7`, `refused $(fp3 "$r2" HEAD~2)`.
- 8B, 8C: the `sed "s/$r2/000…0/"` history with `--round 3`, and the same file through `--previous`;
  each `refused` with the `FR(3)` text.
- 9B, 9C: the no-ticket history with `--round 3`, and `--previous previous-2f.md "$r2"` with no
  `--ticket`; each `refused` with the `FT(3)` text.
- 10B, 10C: the (2F) naming HEAD with `--round 3`, and through `--previous`; each the empty-diff
  refusal naming `$r2`.
- 11B, 11C: `--paths a.txt --commits HEAD` after (2F) with `--round 3`, and with
  `--previous previous-2f.md`; each `refused $(fp3 "$r2" paths)`.
- 12B, 12C: one representative variant each, the FO line inside a fence, with `--round 3` and
  through `--previous`: `R(3)`, whole diff. The other four variants need none in these columns; they
  exercise the line parser, which runs before anything reads the round or the input path, and 12A
  runs all five.
- 13C: assertion 20's first half, "(1F) as a `--previous` file", is that cell and is relabelled 13C;
  13A gains the same history through the fake `gh`.
- 15C: `--previous` of (1R), (2F), (3W s) with `"$s"`: `R(4)`, `FIX` with round three's `fixed:`
  line only.
- 16B, 16C: row 16's history with `--round 4`, and through `--previous`; each
  `refused $(fp 4 "$s" "$r2")`.
- 17C: `--previous` of (1R), (2F), (3): `refused $f4`.
- 18B, 18C: (1R), (2F), (3W), (4W) with `"$s4"` and `--round 5`, and the same four through
  `--previous`: `R(5)`; with (5) appended, `refused $f6`.
- 19B, 19C: none. Those fixtures carry no RV and no FO line, so the new gate is never entered and
  the columns differ from 19A only by the round argument and the input path, which #93's own
  `--round` and `--previous` assertions over the same fixtures already run.
- 20B, 20C: none. Row 20 reaches the same comment as row 5 through an older round-one comment, which
  the gate does not read; 5B and 5C cover both columns.
- 21A: a CRLF copy of (2F) served through the fake `gh`, `"$r2" --ticket 7`: as 5A. This is the cell
  the web UI actually produces, so it is worth its run.
- 21B: none. `--round 3` over that history adds nothing to 21A and 5B: the CR is stripped in
  `split`, before any column differs.

No existing assertion outside the three named above moves, and no fixture of #93's changes.

---

## For the owner: what I rejected, and why

**The owner's candidate, taken with two corrections.** The marked-line rule is right and the corpus
proves it: twelve of thirteen real hard items quote plain code, so "at least one quoted line is a
fix line" is a coin toss on text, and requiring a marker is what makes "inside" mean "about the
fix". I changed two things in it.

*Uniqueness belongs to the diff, not to the files at HEAD.* The candidate makes an added line
identifying when its text occurs exactly once across the HEAD versions of `<dir>/files`. That is the
wrong universe in both directions. A reviewer can only put a marker on a line that appears in
`<dir>/diff`, so duplicates that never appear in the diff cost legitimate fix lines for nothing: a
fix that adds `  exit 1` in a file already holding `  exit 1` elsewhere would make its own hunk read
outside. And the removed side gets a different rule under the candidate (nowhere at HEAD, once at
RV), which needs a second pass over old file contents. Counting occurrences per side of
`<fixed>...HEAD` against the same side of `<rv>..HEAD` is one awk over two diffs the script already
knows how to take, it covers both signs with one comparison, and it is exactly the threat: a text
the reviewer could have quoted from somewhere the fix did not touch. So: neither `<dir>/files` at
HEAD nor the whole tree. The whole tree is cost with no gain at all, since an untouched file's line
can never carry a marker in a quote of this PR's diff.

*Signs are part of a fix line.* The candidate compares texts. An item quoting `-  exit 1 # miss`
when the fix added that line is a finding about removing something the fix put in, which is not the
fix's own line. Storing `+text` and `-text` separately costs one character per line and closes it.

**The location check earns its code, narrowly, and only as a veto.** Given the marked-line rule, the
residue it catches is one shape: an item that quotes the fix's hunk to illustrate, while the finding
itself sits at a line it names in prose. That shape is plausible precisely because six of thirteen
corpus items name a `file:line` in their prose. It can never make an item inside, so it cannot
introduce a new false-inside of its own, and it is about ten lines of awk plus one file the brief
writes in the pass it already runs. I would have dropped it if it needed its own git call. The one
thing it cannot be is path-exact: the corpus writes `shellcheck.sh:17` and `review-comment.sh:114`,
so a check that matches only full `<dir>/files` paths would fire on nothing and be dead code. It
matches a basename too, which slightly over-vetoes when two changed files share a name, and
over-vetoing means a whole-diff round three, which is the direction the bar asks for.

**Rejected: an unmarked line that is a fix line still counting as a hit.** This is the ticket's
current rule and the hole. Rejected on the corpus: it makes the commonest quote shape decide
fix-only by coincidence, and the four-character floor does not save it, because `else`, `done`,
`exit 0` and `esac` clear it.

**Rejected: requiring the quote to be a `diff`-fenced block.** It would be simpler to say "the fence
info string must be `diff`". Rejected: the corpus's one marked quote
(`pr99-r1b/review/standards-report.historical.md`) uses a bare fence, and the reports' own rule never
told reviewers what info string to use. Pinning behaviour to a fence label the prose does not
require would fail items that are genuinely about the fix.

**Rejected: a location-only rule (inside iff the item names a `path:N` and every one is in a fix
range).** Rejected because most items name no `path:N` outside their `Documented step:` line at all,
so it decides nothing on its own, and because an item's prose can name three files for three
different reasons. As a veto over the marked-line rule it is sound; as the rule it is guesswork.

**The one option worth your decision: delete the inside rule.** If "fix only after" printed only
when round two reported no hard item at all, then `fix-lines`, `fix-ranges`, `outside()`, both awk
programs and about twenty test assertions all disappear, and by the corpus the feature would fire in
five of the six round-two reports this repository has, against six of six for the amended rule. The
whole apparatus is buying one case in six, and that case has never actually occurred: no round-two
report in the corpus holds a hard item quoted as a hunk. I did not take it because it is wider than
the hole I was sent to close, because criterion 2 of #106 asks for the distinction in so many words,
and because the reports may quote hunks more often once `spec-review`'s step 4 prose says to. But
if you want the subtraction, this is the moment it is cheapest, and the amended Terms above are
exactly what you would be deleting.
