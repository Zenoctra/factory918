## What to build

Split from #104 (2026-09-22) at Manuel's request.

> agent: "Reviewers rebuild context the owner already has. Fifty lanes opened the same script because the brief carried the diff and not the surrounding code. A reading pack generated once per ticket, the touched functions in full plus the table, cuts a reviewer's eight minutes toward four without changing what it is asked to find. This is the one place fresh context and speed are not in tension."

> user: "The guys whose thing is to find surprises should stay in fresh context, but maybe the other lanes dont need to."

> user: "I agree with your choices here."

Facts the lane starts from. In the 2026-09-22 run the review brief script was opened by 50 distinct lanes and the comment script by 37 (`.scratch/program/postmortem/reads.md` in the main checkout, untracked); a reviewer's typical profile was six minutes of reading and under two of tools. The brief today carries the diff (inline under about 500 lines, else by path), the commit list, the stat, the ticket body and the settled items. The script is `template/.agents/skills/spec-review/scripts/review-brief.sh`, the test `tests/spec-review/review-brief.sh`. This ticket shares those files with #106 and #108: the three run one at a time, or as a stack under a go.

## Acceptance criteria

- [ ] Both briefs carry a `## Reading pack` section after the diff: for every changed file under a size the table fixes, the file's full text at the reviewed head; for a larger file, each changed function or section whole (the enclosing shell function, or the Markdown section under its nearest heading), each under a line naming the file and the range.
- [ ] The pack is bounded: a total the table fixes, beyond which the brief hands paths instead and says so in one line, so a brief never grows past what a reviewer lane can hold.
- [ ] A reviewer is told, in the brief's `## Report` section, that the pack is the code to read and that opening the repository is for what the pack does not carry.
- [ ] The scenario table on this ticket has one row per shape (a small file, a large shell file with one changed function, a large Markdown file with one changed section, a diff over the total, a binary or generated file) and `tests/spec-review/review-brief.sh` has one assertion per cell, written before the script changes, in the commit order.
- [ ] `spec-review/SKILL.md` step 4 (through its patch) names the section and the cutoffs.

## Blocked by

None.


## Testing decisions

Posted by the agent 2026-09-23

The table below is the spec for the reading pack; the contract under it defines every term the cells use, and the test list has one assertion per cell. A review finding that changes a cell, adds a row or a column, or changes a term the cells use (a unit, a text entry, the total, the section's place) is a design hole under #90's rule: it returns to architect and this section is amended with a dated line. A finding that leaves the table standing while the code fails a cell is an implementation bug fixed on the PR. Every cell of #90's table, #91's table, #93's tables A and B and #106's tables A and B keeps its outcome: the pack adds a section to the briefs and changes nothing the script prints, refuses or writes as state. Synthesized from two architect candidates: from the upper-tier one, the byte cutoffs, the smallest-entries-first selection, the separate script, the header forms and the Report sentence; from the lower-tier one, the comment-led block for top-level and long-function shell code and the sweep with no pack; the owner kept the Markdown section rule and the placement, and dropped the upper candidate's `.gitattributes` and indentation parser and the lower candidate's unbounded `<dir>/pack.md` and rewritten read-nothing sentence. The trail is under `.scratch/program/107/` of the owner lane.

### Legend

Columns are the two round kinds that fix the diff range. **W** is a whole-diff round: `review-brief.sh <o>` over `git diff <o>...HEAD`. **F** is a fix-only round: round three after `fix only after <sha>` (#106), or round four or five after `would-break fixed after <sha>` (#93); the range is `<sha>...HEAD`, the fix commits alone. The sweep form is row 25.

- `WHOLE` = an entry `### <path>, whole, <n> lines` (`1 line` when n is 1), a blank line, a fence line, the file's whole text at HEAD, the same fence line, a blank line.
- `UNIT(x .. y)` = an entry `### <path>, lines <a>-<b> of <n>`, then the fenced text of lines a to b at HEAD, laid out as `WHOLE`; its first text line is x and its last is y.
- `NOTEXT(reason)` = the header line alone, as the contract spells it for that reason, then a blank line.
- `NONE` = no line in the section starts with `### <path>,`.
- `OVER` = the one line that ends the section when an entry is not carried.
- Every cell also means: exit 0, stdout byte for byte what it is without the pack, and both briefs carry the same section.

### Scenario table

Fixtures: in the test's temp repo, commit K0 holds every file under `pk/`; commit P changes each as its row says; commit F1, on P, changes only `pk/t.sh`, function `f50` of `pk/big.sh` and section 20 of `pk/big.md`. W runs from K0, F from P as a fix-only round three (#106's `fix only after` comment naming P).

| Row | Shape | W | F |
|---|---|---|---|
| 1 | Small file (8192 bytes or less at HEAD): `pk/s.sh` changed in P, `pk/t.sh` changed in P and F1 | `WHOLE` for each | `pk/t.sh` `WHOLE`; `pk/s.sh` `NONE` |
| 2 | Large shell file, a change inside a function of 4096 bytes or less (`f10` in P, `f50` in F1 of `pk/big.sh`) | `UNIT(f10() { .. })`; `UNIT(f50() { .. })` | `UNIT(f50() { .. })`; no entry holds `f10() {` |
| 3 | Large shell file, a change in top-level code outside any function | `UNIT` of the comment-led block: from the first line of its column-0 `#` run to the line before the next run | `NONE` for it |
| 4 | Large shell file, a change inside a function over 4096 bytes whose body has column-0 `#` runs (the test file's `suite()` style) | `UNIT` of the comment-led block around the change, inside the function | `NONE` for it |
| 5 | Large shell file, a change inside a heredoc of function `g`, above a column-0 `}` line in that heredoc | `UNIT(g() { .. })` whose last line is the heredoc's `}`: the first column-0 `}` ends the function by the rule | `NONE` for it |
| 6 | Large shell file, a change where no rung fits 4096 bytes (a block over the cutoff, no function) | `UNIT` of the window: the widest range around the line, inside the block, of 4096 bytes or less | `NONE` for it |
| 7 | Large shell file, a pure-deletion hunk (`+c,0`) | the units of lines c and c+1, merged into one entry | `NONE` for it |
| 8 | Large Markdown file, one changed section (section 7 in P, section 20 in F1 of `pk/big.md`) | `UNIT(## Section 7 .. its last line)`; `UNIT(## Section 20 ..)` | `UNIT(## Section 20 ..)`; no entry holds `## Section 7` |
| 9 | Large Markdown file, a change in a section whose fenced block holds `## not a heading` and a three-backtick line | `UNIT(## Fenced .. the line before the next heading)`, past the fenced heading, in a fence longer than any backtick run in its text | `NONE` for it |
| 10 | Large Markdown file, a section over 4096 bytes | `UNIT` of the window inside the section | `NONE` for it |
| 11 | Large file of another kind (`pk/code.py`) | `UNIT` of the window | `NONE` for it |
| 12 | Two changes in one file whose units overlap or touch | one entry covering both | `NONE` for it |
| 13 | Small file whose text holds lines of three and four backticks and a mid-line run of five | `WHOLE` in a fence of six backticks | `NONE` for it |
| 14 | Small file with no final newline, and one with CRLF line ends | `WHOLE`; a newline is added before the closing fence; the CRs stay in the text | `NONE` for them |
| 15 | Large shell file renamed with an edit, its path holding a space (`pk/old name.sh` to `pk/new name.sh`) | `UNIT` under `### pk/new name.sh, renamed from pk/old name.sh, lines <a>-<b> of <n>` | `NONE` for it |
| 16 | Large file with no changed line: a mode change, and a pure rename | `NOTEXT(no line changed)` for each; the rename's line names the old path | `NONE` for them |
| 17 | Added small file, added large file | `WHOLE`; `NOTEXT(added)` | `NONE` for them |
| 18 | Deleted file | `NOTEXT(deleted)` | `NONE` for it |
| 19 | Binary file; generated file (`linguist-generated` set in `.gitattributes`) | `NOTEXT(binary)`; `NOTEXT(generated)` | `NONE` for them |
| 20 | Symbolic link retargeted; submodule (gitlink) moved | `NOTEXT(link)`; `NOTEXT(submodule)` | `NONE` for them |
| 21 | File emptied; path holding a newline | `NOTEXT(empty)`; `NOTEXT(newline path)` | `NONE` for them |
| 22 | Entries whose text sums to exactly 65536 bytes (eight files of 8192 bytes, `pk2/`) | all `WHOLE`; no `OVER` | n/a: F selects with the same code over its own entries |
| 23 | The same plus one 2-byte file | the 2-byte file and seven of the eight `WHOLE`, printed in path order; the eighth in path order named on `OVER` | n/a: as row 22 |
| 24 | One entry larger than 65536 bytes (a single 70000-byte line) | named on `OVER` after row 23's; every other entry still carried | n/a: as row 22 |
| 25 | The sweep form (`--paths ... --commits ...`) | the section is `## Reading pack`, a blank line, the sweep line, and nothing else | n/a: the sweep has no fix-only round (#106 row 11) |
| 26 | Every brief: where the section sits | after `## Diff`, before `## Standards` (Standards brief) or `## The ticket (#N)` (Spec brief); the two briefs' sections byte for byte equal | after `## Diff`, before `## Settled in earlier rounds`; equal in both |
| 27 | Every brief: the Report sentence | both briefs carry it word for word, after Manuel's fifth sentence and before `Write the report as Markdown` | the same |
| 28 | Stdout, state and the earlier tables | stdout, exit code, `.claude/state/review/` and `<dir>/round`, `reviewed`, `fix-lines`, `fix-ranges` as without the pack; every earlier assertion passes unchanged | the same |
| 29 | A git command inside the pack fails (a `git` on `PATH` that fails on `check-attr`) | `review-brief: the reading pack failed (above); nothing written` on stderr, exit 1, no `.claude/state/review/` and no `<dir>` | the same |

Criterion 4's five shapes are rows 1 (a small file), 2 (a large shell file with one changed function), 8 (a large Markdown file with one changed section), 23 and 24 (a diff over the total), and 19 (a binary or generated file).

### Contract

**Where it lives.** A new script, `template/.agents/skills/spec-review/scripts/reading-pack.sh`, takes `<fixed-point>` or `--paths P... --commits SHA...`, prints the whole section, heading included, on stdout, and exits 1 with git's message on stderr when a git command fails. `review-brief.sh` runs it once, after the blast-radius checks and before any state is written, into `<dir>/pack.md`; on failure it removes `<dir>` and refuses with row 29's line. `common()` prints `<dir>/pack.md` right after the `## Diff` block. `factory918.sh`'s `keep_files` names the new script so `factory918 sync` keeps it.

**Cutoffs.** One line in `reading-pack.sh`, which the test reads: `pack_whole=8192 pack_unit=4096 pack_total=65536`. All three count bytes, a missing final newline counted as present. A file of `pack_whole` bytes or less at HEAD is carried whole; a unit of `pack_unit` bytes or less fits; the carried text sums to `pack_total` bytes or less (headers and fences do not count).

**Files and their order.** `git diff -z -M --name-status --no-ext-diff <fixed>...HEAD`, in its order; a rename's entry is for the new path. Per file, the first match wins: a path holding a newline (`NOTEXT(newline path)`, the path as `printf %q` prints it); status `D` (`deleted at HEAD`); mode 120000 at HEAD (`a symbolic link to <target>`); mode 160000 (`a submodule`); `git check-attr linguist-generated` set or true (`generated (linguist-generated)`); binary by `git diff --numstat` (`binary`); 0 bytes at HEAD (`empty at HEAD`); `pack_whole` bytes or less (`WHOLE`, added, renamed and mode-only files included); status `A` (`added, <n> lines; the diff carries it whole`); no changed line (`<n> lines, no line changed`); otherwise units. A `NOTEXT` line reads `### <path>[, renamed from <old>], <reason>: no text`. Paths are printed raw, never in backticks.

**Changed lines.** The new side `+c[,d]` of each hunk header of `git diff --no-color --no-ext-diff -M -U0 <fixed>...HEAD -- ":(literal)<old>" ":(literal)<new>"`: lines c to c+d-1, or for a pure deletion (d = 0) lines c and c+1, each clipped to 1..n.

**Kinds.** `.md` and `.markdown` are Markdown. `.sh`, `.bash` and a first line that is a shebang naming `sh` or `bash` are shell. Everything else is other. Line tests read each line less a trailing CR; the text keeps it.

**Units.** A changed line takes the first rung whose range is `pack_unit` bytes or less.
- Shell: (1) the function: from a column-0 line `name()` (optional spaces, optional `{`) or `function name`, to the first later column-0 line starting `}`; a function on one line is not matched. (2) The comment-led block: from the first line of the nearest column-0 `#` run at or above the line to the line before the next such run, clipped to the function when the line is in one. (3) The window.
- Markdown: (1) the section: from the nearest heading (`^#{1,6}` then a space, a tab or the line's end) at or above the line, outside fenced text, to the line before the next heading, less trailing blank lines; lines above the first heading are a section. Fenced text uses the scripts' `fenced` rule with up to three leading spaces allowed. (2) The window, inside the section.
- Other: the window.
- The window: the widest range from line L-r to L+r, clipped to the file and to the rung it falls back from, of `pack_unit` bytes or less; always at least line L.

A file's units are sorted and merged when they overlap or touch; each merged range is one entry.

**Selection.** Entries are taken smallest first (ties in production order) while the carried sizes sum to `pack_total` or less. Carried entries and `NOTEXT` lines print in production order: the diff's file order, then line order. When an entry is not carried, the section ends with exactly one line: `Not carried, over the pack's 65536 bytes: <label>; <label>. Read these at HEAD from the repository.`, each label `<path> whole` or `<path> lines <a>-<b>`, in production order.

**Fence.** A line of backticks, one more than the longest backtick run anywhere in the text and at least three, no info string; the same line closes it. The text ends in a newline before the closing fence.

**Sweep.** The section holds one line: `The sweep form carries no reading pack: its diff numbers lines as the swept commits did, so the files at HEAD are not the code it shows.`

**The Report sentence**, in `report_rules()` after Manuel's five sentences, as its own paragraph, word for word: "The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository only for what the pack does not carry, and then read that one function or section, not the file." The existing "Read nothing beyond this brief" sentences stay as they are.

**SKILL.md step 4** gains, under "Both briefs carry", after the diff bullet and through `patches/mattpocock/spec-review.SKILL.md.patch`, a bullet naming `## Reading pack`, `scripts/reading-pack.sh` and the three cutoffs (8192, 4096 and 65536 bytes), and the Report sentence word for word; the test holds both copies to the script's.

### Tests

In `tests/spec-review/review-brief.sh`, written before `reading-pack.sh` in the commit order, one assertion per cell in the table's order, each labelled with its cell (`(2W)`), run in both layouts. New helpers beside `has`, `lacks` and `printed`: `entry <brief> <header> <first> <last> <label>` (the header line, a blank line, a fence line, text from `<first>` to `<last>`, the same fence line), `fence <brief> <header> <fence> <label>`, `none <brief> <path> <label>` and `notext <brief> <line> <label>`. Rows 1 to 21 build `pk/` (K0, P, F1) at the end of `suite()`, after every existing assertion, so no earlier `lacks` sees it; rows 22 to 24 build `pk2/`; row 25 runs the sweep over P; rows 26 to 28 run over the row 1 to 21 briefs; row 29 puts a failing `git` wrapper on `PATH`. The drift guard asserts the SKILL.md bullet, the Report sentence in SKILL.md and in both briefs, and the cutoffs line in `reading-pack.sh`. F cells marked n/a have no assertion.


Amended 2026-09-23 by the agent in #126 (writer flags 2, 4 and 5, filling gaps the contract left open; no cell moves and no assertion changes): the `NOTEXT(newline path)` line reads `### <path as printf %q prints it>, a path holding a newline: no text`. A shell function header is `name()` (the name `[A-Za-z_][A-Za-z0-9_]*`, no space before `()`) or `function name`, and a header with no later column-0 `}` line is not a function; when no column-0 `#` run is above the line, the comment-led block starts at line 1. The 4096-byte cutoff bounds each unit before merging; a merged entry of units that overlap or touch can exceed it, and only the 65536-byte total bounds it.

