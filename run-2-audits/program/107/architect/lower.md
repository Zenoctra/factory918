# Candidate (lower tier): the reading pack as a file, with a three-rung unit ladder

Everything below was run. The prototype is `pack.sh` in a throwaway repo (`mktemp -d`,
`/tmp/pack107.l9e7kF`), against real git on macOS, over two fixture repositories built by
`setup.sh` and `setup2.sh`. Where a row says "ran", the outcome in the cell is the prototype's
actual output, not a prediction.

Three things differ from the owner's draft on purpose.

1. **The pack is a file first.** `<dir>/pack.md` always holds every entry whole. The brief's
   section inlines what fits. Overflow hands one path plus the ranges, not a list of repository
   files to open, so a reviewer at the cutoff reads one more file instead of N, and reads it at
   the reviewed commit rather than at whatever the working tree now holds.
2. **A different unit for top-level shell code.** The owner falls back to a 20-line window the
   moment a line is outside a function. Measured against this repository that is the common case,
   not the rare one. The unit here is the **comment-led block**: a column-0 run of `#` lines and
   the code under it, to the next such run. Measured (ran): it partitions
   `template/.agents/skills/spec-review/scripts/review-brief.sh` into 21 blocks, median 19 lines,
   max 91, covering all 548 lines; and `tests/spec-review/review-brief.sh` into 117 blocks,
   median 10, max 66, covering all 1398. A window never produces a self-explaining chunk; a
   comment-led block in this repository always does, because the comment is the block's docstring.
3. **Skip and keep filling, not stop at the first overflow.** Ran at TOTAL=100 on fixture 2:
   stop-at-first carries zero lines (the first entry is 205 lines); skip-and-continue carries 81
   lines across two later entries. The cost of the other policy is the whole pack held hostage by
   whichever large file sorts first.

One number changed on measurement, not taste. Over the 1210 tracked files of this repository,
p95 of line count is 420 and p90 is 212 (ran). FULL = 400 therefore carries roughly nineteen files
in twenty whole, and leaves out exactly the four that should be left out: `review-brief.sh` (548),
`factory918.sh` (428), `tests/spec-review/review-comment.sh` (1338),
`tests/spec-review/review-brief.sh` (1398). The owner's 300 pushes `factory918.sh` and a dozen
research notes into unit mode for no gain.

---

## 1. Scenario table

Rows are the file and diff shapes. Columns are the three round kinds that change the diff range:

- **whole diff** — rounds one and two, `fixed` is the fixed point, diff `git diff "$fixed...HEAD"`.
- **fix only** — round three after `fix only after <sha>`, rounds four and five after
  `would-break fixed after <sha>`; `fixed` is that sha, so the changed-file set and every hunk
  range are the fix commits alone.
- **sweep** — `--paths P... --commits SHA...`, `fixed=paths`.

Cells use the legend below. `E(p, a-b)` is one entry; `L(p, reason)` is one no-text line.

| # | Row (shape) | whole diff | fix only | sweep |
|---|---|---|---|---|
| 1 | File at most FULL lines at HEAD (`small.txt`, 2 lines) | `E(p, 1-N)`, header `lines 1-2 of 2` | same rule over the fix's files: `E` iff the fix touched it, else absent | `NOPACK` |
| 2 | File over FULL, change inside a function at most FULL (`big.sh` 665 lines, `small()`) | `E(p, 127-130)`, the function whole | `E` over the fix's hunks only, same unit | `NOPACK` |
| 3 | File over FULL, change at top level, no enclosing function (`big.sh`, `a30=1`) | `E(p, 5-65)`, the comment-led block whole | same, from the fix's hunks | `NOPACK` |
| 4 | File over FULL, change inside a function over FULL that has comment-led blocks (`big.sh`, `big()` 405 lines, `d100`) | `E(p, 194-394)`, the inner block, clipped to the function | same | `NOPACK` |
| 5 | File over FULL, no function and no comment-led block at most FULL around the line (`over.sh` 2000 lines) | `E(p, 1-31)` and `E(p, 1970-2000)`, WINDOW either side, clipped | same | `NOPACK` |
| 6 | Markdown over FULL, change inside a section; a heading inside fenced text (`bal.md` 457 lines) | `E(p, 202-406)`, nearest heading to the line before the next; the fenced `## not a heading` starts nothing | same | `NOPACK` |
| 7 | Two changed units in one file that touch or overlap (`hd.sh`, blocks at 4-44 and 45-53) | one `E(p, 4-53)`, merged | same | `NOPACK` |
| 8 | Text holding fence lines (`fences.md`, runs of 3 and 4 backticks) | `E(p, 1-7)` in a fence of 5 backticks | same | `NOPACK` |
| 9 | Pure-deletion hunk, file still over FULL at HEAD | `E(p, a-b)` around `max(c,1)` of the `+c,0` header | same | `NOPACK` |
| 10 | Rename with edits, new side over FULL (`-M` reports `R`) | `E(new, a-b)`; ranges and text both from the new path | same | `NOPACK` |
| 11 | File over FULL with no changed lines at HEAD (mode-only, pure rename) | `L(p, "no changed lines at the reviewed head")` | same | `NOPACK` |
| 12 | Binary or generated (`bin.dat`; `gen.md` with `linguist-generated=true`) | `L(p, "binary")` / `L(p, "generated")` | same | `NOPACK` |
| 13 | No blob at HEAD: deleted, symlink, submodule (`gone.txt`, `link.txt`, `sub` mode 160000) | `L(p, "deleted at the reviewed head")` / `L(p, "a symlink")` / `L(p, "a submodule")` | same | `NOPACK` |
| 14 | Path with spaces, CRLF text, or no trailing newline (`has space.sh`, `crlf.txt`, `nonewline.txt`) | entries as rows 1-5; CR kept, closing fence on its own line | same | `NOPACK` |
| 15 | Total carried text would pass TOTAL (fixture 1, TOTAL=1200) | entries in order until one does not fit; it is skipped, filling continues; `OVER` line names every skipped entry | same | `NOPACK` |
| 16 | One entry larger than TOTAL on its own (fixture 2 at TOTAL=100, entry 205) | never inlined; named in `OVER`; whole in `<dir>/pack.md`; later entries still fill | same | `NOPACK` |
| 17 | Entries fill TOTAL exactly (fixture 2 at TOTAL=205) | the exact-fitting entry is inlined; the next is skipped; `OVER` present | same | `NOPACK` |

### Legend

- `E(p, a-b)` — the section holds, in this order: the header line for `p` and the range `a-b`, a
  blank line, an opening fence, the text of lines `a..b` of `p` at HEAD verbatim, a closing fence,
  a blank line. Nothing else about that entry is printed.
- `L(p, reason)` — the section holds one line, `` `p`: <reason>. ``, and no text for `p`.
- `NOPACK` — the section holds exactly `SWEEP_LINE` (below) and nothing else. No entries, no
  `OVER`, no `<dir>/pack.md`.
- `OVER` — the one overflow line, `OVER_LINE` (below).
- "same" — the same rule, evaluated over the fix-only diff range, so the changed-file set and the
  hunk ranges are the fix commits' and a file the earlier rounds changed is absent unless the fix
  touched it too.
- Every cell is the content of `## Reading pack` in **both** briefs. The two briefs share it
  because `common()` writes it once.

---

## 2. The contract

Every term the cells use, defined once.

### Fixed numbers

- **FULL = 400.** A file whose text at HEAD is at most 400 lines is carried whole. A unit longer
  than 400 lines is not a unit; the rung below it is used. Grounded on p95 = 420 over this
  repository's 1210 tracked files (ran).
- **WINDOW = 30.** The last rung: lines `max(1, k-30)` to `min(N, k+30)` around a changed line `k`.
- **TOTAL = 1200.** The most lines of entry text the brief's section inlines. It bounds the
  section alone: headers, fences, blank lines, `L` lines and `OVER` are outside the count, so the
  number a reader can check against `wc -l` on the fenced text is the number in the contract.

### Terms

- **the diff range** — exactly what the brief already computes: `"$fixed...HEAD"` in both the
  whole-diff and the fix-only round. The pack adds no second notion of what changed.
- **changed file** — a record of `git diff -M -z --name-status <range>`, in git's order, which is
  the order the section prints. For an `R` or `C` record the path is the new one.
- **N** — `git show "HEAD:<path>" | awk 'END { print NR }'`: the line count at HEAD, counting a
  final line with no newline (`wc -l` undercounts it by one).
- **carries no text** — the file produces `L` and no entry. Five reasons, checked in this order:
  deleted by the range (`D`); no entry in `git ls-tree HEAD -- ":(literal)<path>"` or mode
  `160000` (a submodule) or mode `120000` (a symlink); binary, meaning `git diff -M --numstat
  <range>` printed `-` for both counts; generated, meaning `git check-attr -z linguist-generated`
  reports `set` or `true`.
- **changed line** — a new-side line number from `git diff -U0 -M <range> -- ":(literal)<path>"`.
  A header `@@ -a,b +c,d @@` contributes `c .. c+d-1`; `d = 0` (a pure deletion) contributes the
  single line `max(c, 1)`.
- **unit** — the range a changed line resolves to, by the first rung that yields at most FULL
  lines:
  1. **shell function**, for a shell file: from a column-0 line matching
     `^[A-Za-z_][A-Za-z0-9_:.-]*[ \t]*\(\)[ \t]*\{?[ \t]*$` or `^function[ \t]+[A-Za-z_]` to the
     first following column-0 `}` line. A function written on one line does not match and is
     covered by its comment-led block instead, which is the better unit anyway.
  2. **comment-led block**, for a shell file: from the first line of the nearest column-0 run of
     `#` lines at or above the changed line, to the line before the next such run; clipped to the
     enclosing function when there is one. Blocks partition the file, so every changed line has
     one and there is no "outside any unit" case.
  2'. **Markdown section**, for `.md` or `.markdown`: from the nearest `^#{1,6} ` line at or above
     the changed line that is outside fenced text, to the line before the next such line. Lines
     above the first heading are a section. Fenced text is read with the repository's own fence
     rule (below).
  3. **window**: WINDOW lines either side, clipped to `1..N`. Reached when the rungs above give
     nothing or give more than FULL lines, and for every file type that is neither shell nor
     Markdown.
  A **shell file** is `.sh`, `.bash`, or a first line matching `^#!.*[ /](ba)?sh( |$)`.
- **entry** — a maximal merge of units. Units of one file are sorted and merged when they overlap
  or touch (`s <= end + 1`). A merged entry may exceed FULL; only TOTAL bounds an entry's inlining.
- **whole-file entry** — a file with `N <= FULL` produces exactly one entry, `1-N`, with no hunk
  parsing at all. This is why row 11 (no changed lines) only exists for a file over FULL.

### The header line

One format, always, no second form for a whole file:

```
### `<path>` lines <a>-<b> of <N>
```

A whole-file entry reads `lines 1-N of N`, which tells the reviewer it is complete without a
second spelling for the test and the reviewer to learn. The path is in backticks so a path with
spaces reads as one token (ran: `has space.sh`).

### The fence rule

The entry's text opens with a run of backticks whose length is one more than the longest run of
backticks that begins a line of that text, after up to three leading spaces, and at least three.
No info string. This is the rule `review-comment.sh` and `review-brief.sh` already close a fence
with, so a fence inside the carried text cannot close the entry's fence (ran: `fences.md`, inner
runs of 3 and 4, fence of 5). The text is printed verbatim: CR characters stay, and a file with no
final newline gets one added so the closing fence is on its own line (both ran).

### The overflow rule

`<dir>/pack.md` is written first and always holds **every** entry and every `L` line, whole,
unbounded. The section then inlines entries in git's order, keeping a running total of entry text
lines. An entry whose size would take the total past TOTAL is not inlined; it is recorded and
filling continues with the next entry. An entry that fits exactly is inlined. If anything was
recorded, the section ends with one line:

```
OVER_LINE = The pack does not carry <path> lines <a>-<b>[, <path> lines <a>-<b>]...; those entries stand whole in `<dir>/pack.md`.
```

### Where the section sits

`## Reading pack`, written by `common()`, immediately after `## Diff` and before
`## Settled in earlier rounds`, in both briefs, in every round. The diff says what changed; the
pack says what it changed inside; the settled section says what not to raise.

### The sweep

```
SWEEP_LINE = This is a sweep over commits already on the branch's base, so the files at the reviewed head are not the code these commits changed; the pack carries nothing and the diff above is the whole of it.
```

No `<dir>/pack.md` is written. The owner's call is right and I keep it: a pack at HEAD for a
commit that main has since moved past would be confidently wrong context, which is worse than none.

### The Report sentence, word for word

Added to `report_rules()`, after Manuel's five sentences, in both briefs, only when a pack was
written (absent in the sweep form):

```
The `## Reading pack` section above is the code to read: it carries every changed file, or the unit around every hunk, as it stands at the reviewed commit. Open the repository only for an entry that section says it does not carry.
```

### The read-nothing sentence

The existing sentence `Read nothing beyond this brief unless a finding needs the code around a
hunk, and then read that one function or section, not the file.` appears three times as a literal
(the brief's opening line, and the item paragraph of each brief). With a pack it is false: the
brief now carries that function or section. It becomes one shell variable used in all three
places, with two values.

With a pack:

```
Read nothing beyond this brief. The `## Reading pack` section carries the code around every hunk at the reviewed commit; open the repository only for an entry that section says it does not carry. Run nothing.
```

Sweep form, unchanged from today:

```
Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.
```

This is the one place the candidate goes past the five criteria, and criterion 3 forces it: a
brief that tells the reviewer in one section to read the pack and in three other places to open
the file is a contradiction the reviewer resolves by guessing. Folding three literals into one
variable also removes a drift surface `tests/spec-review/no-stale-wording.sh` currently has to
police by hand.

### The SKILL.md step 4 bullet, word for word

Added to the **Both briefs** list, after the diff bullet, through
`patches/mattpocock/spec-review.SKILL.md.patch`:

```
- `## Reading pack`, after the diff: for every changed file at most 400 lines long at the reviewed commit, its whole text; for a longer one, each changed unit whole, which is the enclosing shell function, else the comment-led block of shell around it, else the Markdown section under its nearest heading, else 30 lines either side of the changed line, with units that touch merged; each entry under a line `### `<path>` lines A-B of N` and fenced. A binary, generated, deleted, symlinked or submodule path gets one line saying it carries no text. The section inlines at most 1200 lines of carried text; an entry past that is named by path and range in one line and stands whole in `<dir>/pack.md`, which always holds the pack complete. A sweep (`--paths`) carries no pack and says so.
```

---

## 3. Test list

One assertion per cell, in the table's order, each naming the fixture state it needs. Fixtures are
built in the existing temp repo of `tests/spec-review/review-brief.sh`, inside `suite()`, by one
new helper `pack_fixture` that commits the base tree and the change described. `has`, `lacks` and
`printed` are the existing helpers; `pack` is the path `.scratch/review/<id>/pack.md`.

Ordering rule for the commit: the whole test list lands in the commit **before** the script
changes, as criterion 4 requires, so the commit that adds them fails and the next makes it pass.

**Whole-diff column** (fixture: `pack_fixture whole`, base and one change commit, brief run with
the base as the fixed point).

1. `has $std '### `small.txt` lines 1-2 of 2'` — row 1. Fixture: `small.txt`, 2 lines, one line
   appended.
2. `has $std '### `big.sh` lines 127-130 of 665'` — row 2. Fixture: `big.sh` with `small()` at
   127-130; `echo one` changed.
3. `has $std '### `big.sh` lines 5-65 of 665'` — row 3. Same fixture; `a30=1` changed, no
   enclosing function.
4. `has $std '### `big.sh` lines 194-394 of 665'` — row 4. Same fixture; `big()` is 405 lines and
   holds `# inner block D`; `d100=4` changed.
5. `has $std '### `over.sh` lines 1-31 of 2000'` and `has $std '### `over.sh` lines 1970-2000 of
   2000'` — row 5. Fixture: `over.sh`, 2000 lines, no comment and no function, first and last
   line changed.
6. `has $std '### `bal.md` lines 202-406 of 457'` — row 6. Fixture: `bal.md` with `## Fenced` at
   202, a fenced `## not a heading` inside it, `## Last` at 407; `body 100` changed.
7. `has $std '### `hd.sh` lines 4-53 of 454'` — row 7. Fixture: `hd.sh`, two adjacent comment-led
   blocks each holding a change.
8. `has $std` the five-backtick fence on the entry of `fences.md` — row 8. Fixture: `fences.md`,
   7 lines holding a 3-backtick and a 4-backtick run, last line changed.
9. `has $std '### `puredel.sh` lines 271-331 of 500'` — row 9. Fixture: `puredel.sh`, 500 lines at
   HEAD, lines 301-400 deleted by the change, no comments, so the window rung around `max(c,1)`.
10. `has $std '### `newname.sh` lines'` and `lacks $std '### `oldname.sh`'` — row 10. Fixture: a
    500-line file renamed with a one-line edit, similarity over 50% so `-M` reports `R`.
11. `has $std '`modeonly.sh`: no changed lines at the reviewed head'` — row 11. Fixture: a
    500-line `modeonly.sh`, `chmod +x` only.
12. `has $std '`bin.dat`: binary'` and `has $std '`gen.md`: generated'` — row 12. Fixture:
    `bin.dat` two random blobs, `.gitattributes` with `gen.md linguist-generated=true`.
13. `has $std '`gone.txt`: deleted at the reviewed head'`, `has $std '`link.txt`: a symlink'`,
    `has $std '`sub`: a submodule'` — row 13. Fixture: a deleted file, a retargeted symlink, a
    gitlink added with `git update-index --cacheinfo 160000`.
14. `has $std '### `has space.sh` lines'` — row 14. Fixture: `has space.sh` 500 lines, `crlf.txt`
    with CRLF, `nonewline.txt` with no final newline; the assertion also checks the closing fence
    is the last line of the `nonewline.txt` entry.
15. `has $std 'The pack does not carry'` — row 15. Fixture: the same `whole` fixture, whose
    entries pass 1200 lines.
16. `has $pack '### `bal.md` lines 202-406 of 457'` with `lacks $std` the same header — row 16.
    Fixture: `pack_fixture over`, one entry of 205 lines with TOTAL unreachable by it, and a
    smaller later entry that is still inlined.
17. `has $std` the header of the exactly-fitting entry and `has $std 'The pack does not carry'` —
    row 17. Fixture: `pack_fixture exact`, entries summing to exactly 1200 followed by one more.

**Fix-only column** (fixture: the existing `fix only after <sha>` round-three fixture of #106,
extended so the fix commits touch each shape).

18-34. One assertion per row, each the whole-diff assertion re-aimed at the round-three brief with
the fix sha as the fixed point, plus, on rows 1 and 2, `lacks $std` the header of a file the
earlier rounds changed and the fix did not. Fixture for every one: `pack_fixture whole` followed
by a fix commit that touches `small.txt`, `big.sh`, `over.sh`, `bal.md`, `hd.sh`, `fences.md`,
`puredel.sh`, the renamed file, `modeonly.sh`, `bin.dat`, `gen.md`, the symlink and `has space.sh`.

**Sweep column** (fixture: the same repo, `--paths ... --commits ...` over the change commit).

35-51. One assertion per row: `has $std 'This is a sweep over commits already on the branch's
base'` once, then `lacks $std '### `<path>`'` for each row's path, and `[ ! -f "$pack" ]` for the
`NOPACK` guarantee. Fixture for all of them: `pack_fixture whole`, swept.

**Drift guard** (the existing pattern: the script's strings and SKILL.md's copies asserted
together).

52. The Report sentence appears in `$std`, in `$spec`, and in the source `SKILL.md`.
53. The read-nothing sentence's pack form appears three times in `$std` and three times in
    `$spec`, and its sweep form appears in a swept brief and nowhere in a packed one.
54. The SKILL.md step 4 bullet's three numbers, `400`, `30` and `1200`, appear in SKILL.md and in
    a brief that exercises each rung.

---

## 4. Rationale

**What the reviewer gets.** A lane opens its brief and the code it needs is already there, at the
commit under review, in the same file. In the 2026-09-22 run 50 lanes opened the same script to
rebuild context the brief could have handed them. Rows 2, 3 and 4 are exactly the reads those
lanes made, and the unit ladder is tuned so the block they land in is the block whose comment
explains it.

**What the maintainer inherits.** One new function in `common()`'s neighbourhood, three named
numbers, and a pack file that can be read on its own when the brief's copy is truncated. The unit
resolution is a pure function from (text at HEAD, changed line numbers) to ranges, so it is
testable without a brief and without git beyond the four plumbing calls at the boundary.
Everything after those calls is line arithmetic.

**Where I beat the draft, and where I did not.** The comment-led block is the real win, and it is
measured rather than argued: it covers all of both large shell files in this repository with a
median unit of 10 and 19 lines. Skip-and-continue is the second, proven by a run where
stop-at-first carries nothing. The pack file is the third: it turns criterion 2's failure mode
from "go read the repository" into "read one more file". I kept the owner's Markdown section rule,
his placement after the diff, and his refusal to pack a sweep, because each is already right.

**The cost I am not hiding.** Seventeen rows times three columns is 51 assertions plus three drift
guards on a test file already at 1398 lines. The sweep column's 17 are one-liners over one
fixture, and the fix-only column's 17 reuse #106's fixture, so the real new fixture work is the
`whole` tree and the `over` and `exact` variants. If the orchestrator wants the table smaller,
rows 16 and 17 fold into row 15's contract without losing a behaviour, taking it to 45.

**The adversarial inputs, and what happens.** Every one was run except where noted.

- A file whose text holds fence lines: fence of `max(3, longest opening run + 1)`; ran, 5
  backticks around text holding 3 and 4.
- Headings inside fenced blocks: not section starts; ran, `bal.md` row 6.
- Unbalanced fences in Markdown (a closing run longer than the opener, then a third run): the
  fence stays open to EOF and the section grows to EOF; if it passes FULL the window rung takes
  over, so the outcome degrades to a window, never to a wrong range. Ran, fixture 1's `big.md`.
- A pure-deletion hunk: `+c,0` maps to `max(c,1)`; ran on `puredel.sh`, which shrank below FULL
  and so came out whole, which is why the test fixture for row 9 keeps it over FULL.
- A rename with edits: `-M` reports `R` and both the ranges and the text come from the new path.
  Ran, though my fixture's similarity fell under 50% and git reported `D` plus `A`, which the
  design handles as a delete plus a new file; the row's fixture must be built over 50%
  deliberately.
- A mode-only change: no changed lines, so `L`; ran, and note the file must be over FULL for the
  row to be visible, since a small file is carried whole regardless of its hunks.
- A path with spaces: `":(literal)$p"` and `"HEAD:$p"` both hold; ran, `has space.sh`.
- A symlink: mode `120000`, `L`; the blob would otherwise print the target as if it were the file.
  The owner's draft misses this. Ran.
- A submodule: mode `160000`, `L`; `git ls-tree` confirmed the mode (ran), though in my fixture
  the gitlink was reported deleted and took the earlier branch, so the `160000` arm itself is
  checked only by the mode read and needs the test's own fixture to exercise it.
- A file with no trailing newline: a newline is added so the closing fence stands alone; ran.
- CRLF text: carried verbatim, CR included, as the diff already carries it; ran.
- A heredoc holding a column-0 `}`: the function rung ends the function early at that line, so
  lines after it fall out of the function; the comment-led block rung catches them and the merged
  entry still covers the whole heredoc contiguously. Ran, `hd.sh` row 7, entry 4-53. This is why
  the block rung sits under the function rung rather than beside it.
- A one-line function: does not match the function pattern, is covered by its comment-led block;
  ran, inside `hd.sh`'s entry.
- A 1300-line function: over FULL, so its inner comment-led blocks are used, and where the body
  has no comments the window is; ran, `huge.sh`, entry 673-733 around a change at 700.
- A diff that fills the total exactly: inlined, and the next entry overflows; ran at TOTAL=205.
- An entry larger than the total: never inlined, named in `OVER`, whole in `<dir>/pack.md`, and
  later smaller entries still fill; ran at TOTAL=100.
- Not run, stated as a claim: `git check-attr` output parsing breaks on a path containing a colon
  and a space. The contract therefore specifies `git check-attr -z`, which is NUL-delimited and
  immune. The implementer should run one fixture on it rather than trust this line.

**Principles that changed a decision.** *Model the domain* put the three rungs in one table from
(text, line) to range, instead of the draft's scattered special cases, which is what made the
"line outside any unit" branch disappear. *Prove it works* forced the FULL and block numbers to
come from measuring 1210 real files and two real scripts rather than from a plausible 300 and 20.
*Minimize reader load* collapsed the two header spellings into one and the three read-nothing
literals into one variable. *Make operations idempotent* is why `<dir>/pack.md` is rewritten whole
on every run alongside the rest of `<dir>`, which `rm -rf` already clears.
