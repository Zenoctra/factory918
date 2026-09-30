# #107 reading pack: upper candidate

Candidate design for the `## Reading pack` section of both review briefs. Every claim marked *ran* was run against real git (2.51.2, macOS) with the prototype `pack.sh` beside this file (`upper/pack.sh`, fixtures `upper/exp*.sh`); the prototype is the design below, less the empty-file line and the file split.

Three moves beat the owner's draft, each on measured evidence:

1. **Bytes, not lines.** `SKILL.md` is 161 lines and 32 KB; `DECISIONS.md` rows are 1 KB lines. A line cutoff let one Markdown window carry 26,572 bytes in a real run (86d156a). Every cutoff here is in bytes, and the separate WINDOW constant is gone: the fallback window is also bounded by the unit cutoff.
2. **Smallest entries first.** In the diff's file order with stop-at-first-overflow, the five most recent merges (86d156a, b329d45, bd39a68, aed8fae, c5ce8fd) each filled the pack with `SOURCES.md`, `docs/agents/ledger.md` and `docs/knowledge/*` before reaching the scripts. In all five, `review-brief.sh`, `review-comment.sh` and the tests were not carried. Taking the smallest entries first carries the most entries for the budget, which is the most places a reviewer does not have to open. The carried entries still print in the diff's order. At the chosen cutoffs this carried 44/55, 32/33, 54/68, 33/35 and 29/38 entries of those merges.
3. **One block rule for all code, indentation-based.** "The enclosing function" is the outermost block around the change, found from indentation and a short closer list, that fits the unit cutoff. For a shell file this is the function, or the whole top-level `if`/`while`/assignment statement with its comment lines. That fixes the two cases the draft left to a window: `review-brief.sh` (almost all top-level) and `tests/spec-review/review-brief.sh` (one 1,300-line unindented `suite()`). *Ran* on real merges: `review-brief.sh` units came out as exact top-level statements with their comment blocks, and `common()` came out whole.

## 1. Scenario table

Columns are the three round kinds that fix the diff range:

- **W**, the whole-diff round: rounds 1 and 2, and round 3 without `fix only after`. The range is `git diff <fixed>...HEAD`.
- **F**, the fix-only round: round 3 after `fix only after <sha>`, and rounds 4 and 5. The range is `<sha>...HEAD`, the fix commits alone.
- **S**, the sweep form: `--paths P... --commits SHA...`. The file list is `git show --name-only <commits> -- <paths>`.

Fixture files are under `pk/` (section 3). K0 is the base commit, P is the change commit, and F1 is the fix commit on top of P. W runs from K0, F runs from P, and S runs over P and F1 with `--paths pk`.

| # | Shape | W (from K0) | F (from P, round 3 fix-only) | S (sweep over P, F1) |
|---|---|---|---|---|
| 1 | Small file, changed in P and F1 (`pk/t.sh` changed in F1 only; `pk/s.sh` in P only) | `s.sh` WHOLE; `t.sh` WHOLE | `t.sh` WHOLE; `s.sh` NONE | `s.sh` WHOLE; `t.sh` WHOLE |
| 2 | Large shell file, one changed function body (`f10` in P, `f50` in F1) | UNIT(`# f10 does a thing` .. its `}`); UNIT(f50 likewise) | UNIT(f50); no f10 entry | NOTEXT(sweep) |
| 3 | Large shell, a change inside a top-level `if` block, and the one-line function right after it | one UNIT(`# the top-level block` .. `one() { echo ONE; }`), merged | NONE for it | NOTEXT(sweep), the same line as row 2 |
| 4 | Large shell, a heredoc whose body holds a column-0 `}` (`middle`→`MIDDLE`) | UNIT(`cat <<EOF` .. `EOF`) | NONE for it | the row 2 line |
| 5 | Large shell, unindented function body (suite style), a changed inner line of a multi-line double-quoted string at column 0 | UNIT(`# assert a` .. `line three" "label"`) | NONE for it | the row 2 line |
| 6 | Large shell, a function over the unit cutoff (`huge()`, nested `if`s; `huge 90` changed) | UNIT: the `if` block around the change, widened a line at a time on each side inside `huge()` while ≤ 4096 bytes | NONE for it | the row 2 line |
| 7 | Large shell, a single statement over the unit cutoff (a 120-line `<<'DOC'` heredoc; `doc 60` changed) | UNIT: the lines around `DOC 60` inside that statement, ≤ 4096 bytes | NONE for it | the row 2 line |
| 8 | Large shell, a pure-deletion hunk (`f30` removed; hunk `+c,0`) | UNIT(`# f29 does a thing` .. f31's `}`): the units of lines c and c+1, merged | NONE for it | the row 2 line |
| 9 | Large Markdown, one changed section (`Body 7` in P, `Body 20` in F1) | UNIT(`## Section 7` .. `BODY 7 …`), trailing blanks dropped; UNIT(Section 20) | UNIT(Section 20); no Section 7 entry | NOTEXT(sweep) |
| 10 | Large Markdown, a changed line inside a fenced block that holds `## not a heading` and a ```` ``` ```` line | UNIT(`## Fenced` .. `after fence`), in a 5-backtick fence | NONE for it | the row 9 line |
| 11 | Large Markdown, a section over the unit cutoff (`- item 100` changed) | UNIT: the lines around it inside the section, ≤ 4096 bytes | NONE for it | the row 9 line |
| 12 | Large Markdown with CRLF line ends (`Body 7` changed) | UNIT(`## Section 7` .. `BODY 7 …`), CRs kept in the text | NONE for it | NOTEXT(sweep) |
| 13 | Large Python file, one changed `def` (`return 40`→`400`) | UNIT(`def f40(x):` .. `    return 0`) | NONE for it | NOTEXT(sweep) |
| 14 | Small file holding ```` ```` ````, ```` ``` ```` and a mid-line run of 5 backticks | WHOLE, in a 6-backtick fence | NONE for it | WHOLE, 6-backtick fence |
| 15 | Small file with no final newline (`b`→`B`) | WHOLE; the text ends `no newline` then a newline, then the fence | NONE for it | WHOLE, the same |
| 16 | Large file renamed with an edit, path with a space (`pk/old name.sh`→`pk/new name.sh`, `f20` changed) | UNIT(f20) under `pk/new name.sh, renamed from pk/old name.sh, lines …` | NONE for it | NOTEXT(sweep) for `pk/new name.sh` |
| 17 | Large file, pure rename (`pk/pure.sh`→`pk/pure-renamed.sh`) and large file, mode only (`pk/mode.sh` +x) | NOTEXT(`N lines, no line changed`) for each; the rename says `renamed from pk/pure.sh` | NONE for them | NOTEXT(sweep) for each |
| 18 | Added small file (`pk/added small.sh`) and added large file (`pk/added-big.sh`) | WHOLE; NOTEXT(added) | NONE for them | WHOLE; NOTEXT(sweep) |
| 19 | Deleted file (`pk/gone.sh`) | NOTEXT(deleted) | NONE for it | NOTEXT(deleted) |
| 20 | Binary (`pk/bin.dat`) and generated (`pk/gen/out.txt`, `linguist-generated`) | NOTEXT(binary); NOTEXT(generated) | NONE for them | NOTEXT(binary); NOTEXT(generated) |
| 21 | Symbolic link retargeted (`pk/link`) and gitlink moved (`pk/sub`) | NOTEXT(link to `t.sh`); NOTEXT(submodule) | NONE for them | the same two |
| 22 | Path holding a newline (`pk/odd⏎name`), and a file emptied (`pk/empty.txt`) | NOTEXT(newline path); NOTEXT(empty) | NONE for them | NOTEXT(newline path); NOTEXT(empty) |
| 23 | Every brief of the run: the section's place and sameness | `## Reading pack` after `## Diff` and before `## Standards` / `## The ticket`; the Standards and Spec copies are byte for byte the same | after `## Diff`, before `## Settled in earlier rounds`; same in both | after `## Diff`; same in both |
| 24 | Every brief of the run: the Report sentence | both briefs carry it word for word | both | both |
| 25 | Stdout and state | stdout is exactly what it was before (the `ticket:`, `round:` and path lines); exit 0; `<dir>/pack.md` holds the section | the same (the `settled:` line as #106 prints it) | the same |

The budget rows use their own fixture, `pk2/`. O0 is its base, O1 adds eight files, O2 adds a 2-byte file and changes one 70,000-byte line. Both runs are W from O0. F and S follow the same selection code, so they get no separate budget cells.

| # | Shape | W at O1 | W at O2 |
|---|---|---|---|
| 26 | Eight 8,192-byte files (`pk2/a.txt` .. `h.txt`): exactly the total | all eight WHOLE; no `Not carried` line | (see 27) |
| 27 | The same, plus `pk2/i.txt` (2 bytes) | | `i.txt` and `a`..`g` WHOLE, printed in path order; `h.txt` not carried (ties go in path order) |
| 28 | One entry larger than the total (`pk2/long.txt`, one line of 70,000 bytes, changed) | | named on the `Not carried` line as `pk2/long.txt lines 1-1`, after `pk2/h.txt whole`; the line is exactly `Not carried, over the pack's 65536 bytes: pk2/h.txt whole; pk2/long.txt lines 1-1. Read these at HEAD from the repository.` |

Criterion 4's five named shapes are rows 1 (small file), 2 (large shell file, one changed function), 9 (large Markdown file, one changed section), 27 and 28 (a diff over the total), and 20 (binary or generated).

### Legend

- **WHOLE**: an entry `### <path>, whole, <n> lines` (`1 line` when n is 1), a blank line, a fence line, the file's whole text at HEAD, and the same fence line.
- **UNIT(x .. y)**: an entry `### <path>, lines <a>-<b> of <n>`, then the fenced text of lines a to b at HEAD. Its first text line is x and its last is y.
- **NOTEXT(reason)**: the entry's header line alone, as the contract spells it per reason (`sweep`, `added`, `deleted`, `binary`, `generated`, `link`, `submodule`, `newline path`, `empty`, `no line changed`).
- **NONE**: no header line starting `### <path>,` for that path.
- **Not carried**: the one line that ends the section when an entry did not fit.
- **Every cell** also means: exit 0, stdout unchanged, both briefs carry the same section, and the caller hands the briefs to the lanes as today. No cell refuses. A failure of git inside the pack is the one refusal (contract, "Failure"), and no fixture reaches it.

## 2. Contract

**Where it lives.** `template/.agents/skills/spec-review/scripts/reading-pack.sh` is a new file. `review-brief.sh` gains four things: the call, the `cat` in `common()`, the Report sentence, and the header comment line. `factory918.sh`'s `keep_files` gains `spec-review/scripts/reading-pack.sh`, or `factory918 sync` deletes the file (the `./factory918.sh sync` check in AGENTS.md would catch it).

```
reading-pack.sh <fixed-point>                   # the section for git diff <fixed-point>...HEAD
reading-pack.sh --paths P... --commits SHA...   # the section for the sweep
```

The script prints the section, heading included, on stdout, and nothing on stderr. It exits 1 with a `reading-pack: ` message on a usage error or a git failure. `review-brief.sh` runs it once, after the blast-radius checks and before any state is written:

```bash
if [ "$fixed" = paths ]; then pack=(--paths "${paths[@]}" --commits "${commits[@]}"); else pack=("$fixed"); fi
bash "$skill/scripts/reading-pack.sh" "${pack[@]}" > "$dir/pack.md" || { rm -rf "$dir"; echo "review-brief: the reading pack failed (above); nothing written" >&2; exit 1; }
```

`common()` prints `cat "$dir/pack.md"` right after the `## Diff` block's trailing `echo`, before `## Settled in earlier rounds`. Both briefs therefore carry the text computed once. A separate file keeps #108's edits to `review-brief.sh` from colliding with about 150 lines of pack logic.

**Constants.** They sit on one line in `reading-pack.sh`, which the test reads: `pack_whole=8192 pack_unit=4096 pack_total=65536`. All three count bytes: a line's bytes plus one for its newline, with a CR counted as a byte.

- A file of `pack_whole` bytes or less at HEAD is carried whole.
- A unit of `pack_unit` bytes or less fits.
- The carried text sums to `pack_total` bytes or less. Only text counts, not headers or fences.

**File list and order.** For W and F, `git diff -z -M --name-status --no-ext-diff <fixed>...HEAD`, in its order. `R*` and `C*` records carry the old and new paths; the entry is for the new path. For S, `git show -z --name-only --format= <commits> -- <paths> | sort -zu`; a path is `D` when `HEAD:<path>` does not exist, and `M` otherwise.

**Per file, first match wins.** The *path* is the HEAD path.

1. The path holds a newline: `### <path as printf %q prints it>: no text; the path holds a newline, so read it from the repository`.
2. Status `D`, or absent at HEAD in S: `### <path>, deleted at HEAD: no text`.
3. Mode 120000 at HEAD (`git ls-tree HEAD -- ":(literal)<path>"`): `### <path>, a symbolic link to <target>: no text`.
4. Mode 160000: `### <path>, a submodule: no text`.
5. `git check-attr linguist-generated -- <path>` is `set` or `true`: `### <path>, generated (linguist-generated): no text`.
6. `git diff --numstat <empty tree> HEAD -- ":(literal)<path>"` gives `-`: `### <path>, binary: no text`.
7. 0 bytes at HEAD: `### <path>, empty at HEAD: no text`.
8. Size ≤ `pack_whole`: WHOLE. This applies in every column, to added, renamed and mode-only files too.
9. S: `### <path>, <n> lines, <size> bytes: no text; a sweep carries whole files only, so read it at HEAD`. A sweep's diff numbers lines as the older commits did, so a unit taken at HEAD would name different lines.
10. Status `A`: `### <path>, added, <n> lines, <size> bytes: no text; the diff's added lines are the whole file`.
11. The changed lines are empty (pure rename, mode only): `### <path>[, renamed from <old>], <n> lines, no line changed: no text`.
12. Otherwise, units (below), one entry per merged range: `### <path>[, renamed from <old>], lines <a>-<b> of <n>`.

For `R` and `C` records, `, renamed from <old>` (or `copied from`) follows the path in every header form. Paths are printed raw, never in backticks, so a path holding a backtick cannot break the header.

**Changed lines.** They come from `git diff --no-color --no-ext-diff -M -U0 <fixed>...HEAD -- ":(literal)<old>" ":(literal)<new>"`, the hunk headers' new side `+c[,d]`. A hunk with d > 0 gives lines c .. c+d-1. A pure deletion (d = 0) gives lines c and c+1. Every line is clipped to 1 .. n.

**Kind.** `.md` and `.markdown` files are Markdown. `.sh` and `.bash` files, and any file whose first line is a shebang naming `sh` or `bash`, are shell. Everything else is code. Each line is read with any trailing CR removed. The CR stays in the carried text.

**Markdown unit.** A heading is a line matching `^#{1,6}([ \t]|$)` outside fenced text. A fence opens on a line that, after leading spaces or tabs, starts with three or more backticks or tildes. It closes on a line of the same character, at least as long, followed by nothing but spaces or tabs. This is the script's existing `fenced` rule, with leading whitespace allowed so a fence inside a list item counts. The section of line L runs from the nearest heading at or above L (line 1 if none) to the line before the next heading, less trailing blank lines. A section over `pack_unit` is replaced by the *window*.

**Code unit.** These definitions apply to shell and code files.

- *Indent* is the count of leading spaces and tabs.
- A *comment* line starts, after its indent, with `#` or `//`.
- A *continuation* line has one of these properties:
  - it is blank;
  - after its indent it starts with `}`, `)`, `]`, `'`, `"` or `;;`;
  - its first word is `fi`, `done`, `esac`, `else`, `elif`, `then`, `do`, `except` or `finally`;
  - it is a shell-only continuation (the shell list below).
- An *opener* is a non-blank line that is neither a comment nor a continuation.
- Shell-only continuations are these lines:
  - the body and terminator of a heredoc (`<<WORD`, `<<-WORD`, `<<'WORD'`, `<<"WORD"`; not `<<<`), with the terminator matched after stripping leading tabs for `<<-`;
  - a line that starts inside an open single- or double-quoted string. The tracker walks each line outside heredocs. Outside quotes, `\` skips a character, `#` after a space or tab ends the line, and `'` or `"` opens a quote. Inside `"`, `\` skips and `"` closes. Inside `'`, only `'` closes;
  - a line after one ending in `\`.
- The *anchor* A of a changed line L is L. When L is blank or a comment, A is the first opener below L, else the last above it.
- The *chain* of A: the innermost opener at or above A, then each opener above it with a strictly smaller indent, up to indent 0.
- The *block* of an opener s at indent k runs from s to the line before the first opener after A with indent ≤ k. Trailing blank lines are dropped. The block also takes the comment lines at indent k directly above s.
- The unit is the block of the outermost chain entry whose bytes are ≤ `pack_unit`. When a chain entry further out did not fit, the unit is widened one line on each side at a time, inside that outer block, while it stays ≤ `pack_unit`. When no block fits, the unit is the *window* inside the innermost block.

**Window.** The window is the widest range L-r .. L+r, clipped to the enclosing section or block, whose bytes are ≤ `pack_unit`. It is always at least line L, even when that line alone is larger.

**Merge.** A file's units are sorted by start. Units that overlap or touch (next start ≤ end + 1) become one entry.

**Selection and the total.** Each text entry's size is the bytes of its text as printed, with a missing final newline counted as present. Entries are taken in ascending size, ties in the order they were produced, and each is kept while the kept sizes sum to ≤ `pack_total`. Kept entries and text-less entries print in production order: the diff's file order, then line order. When anything was not kept, the section ends with exactly one line:

`Not carried, over the pack's 65536 bytes: <label>; <label>. Read these at HEAD from the repository.`

Each label is `<path> whole` or `<path> lines <a>-<b>`, in production order.

**Fence rule.** Each text entry sits between two identical lines of backticks. The count is one more than the longest run of backticks anywhere in the text, and at least three. There is no info string. The text always ends in a newline before the closing fence; the script adds one when the file lacks it.

**Section layout.** Each part is followed by one blank line: the `## Reading pack` line, each header, each fence-text-fence group, and the `Not carried` line. The section has no preamble. The headers say what each entry is.

**Failure.** Any git command in the script failing ends it with exit 1 and git's message on stderr. `review-brief.sh` then removes `$dir` and refuses with `review-brief: the reading pack failed (above); nothing written`. No state is written, the same as the blast-radius refusals.

**The Report sentence.** `report_rules()` prints it after Manuel's five sentences and their blank line, before `Write the report as Markdown…`, as its own paragraph. Word for word:

> The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository only for what the pack does not carry, and then read that one function or section, not the file.

The existing "Read nothing beyond this brief unless a finding needs the code around a hunk…" sentences stay as they are. They agree with the new sentence, since the pack is part of the brief. Rewording them would widen the drift guard for no gain.

**The SKILL.md step 4 bullet.** It goes under **Both briefs** carry, right after the diff bullet, through `patches/mattpocock/spec-review.SKILL.md.patch`. Word for word:

> - `## Reading pack`, after the diff: the code the diff changes as it stands at the reviewed commit, computed once by `scripts/reading-pack.sh`, each entry under a line naming the file and the range. A file of 8192 bytes or less is carried whole; a larger one carries each changed function, block or Markdown section whole, the outermost enclosing block of 4096 bytes or less, else the lines around the change up to 4096 bytes. A binary, generated (`linguist-generated`), deleted, empty, linked or submodule path gets its line and no text. The pack carries at most 65536 bytes of text, the smallest entries first; the rest are named on one line as paths to read at HEAD. The sweep form carries whole files only. The `## Report` section then says, word for word: "The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository only for what the pack does not carry, and then read that one function or section, not the file."

**Generated files in the factory.** The factory has no `.gitattributes`, so its generated copies (`template/docs/factory918/*`, `docs/knowledge/{spec,pages,notes}/`) are carried today. In 86d156a they cost 7 KB of the pack as duplicates of `docs/knowledge/core/DECISIONS.md`. The PR adds a root `.gitattributes` with those four paths as `linguist-generated`, which also collapses them in GitHub's PR view. It is a separate commit, and the owner may split it out.

## 3. Test list

The helpers are added next to `has`, `lacks` and `printed`:

- `entry <brief> <header> <first> <last> <label>`: the brief holds a line exactly `### <header>`, then a blank line, then a fence line F of three or more backticks. The text runs from there to the next line equal to F. Its first line is `<first>` and its last is `<last>`. The helper counts one assertion.
- `fence <brief> <header> <F> <label>`: the fence line after that header is exactly F.
- `none <brief> <path> <label>`: no line starts with `### <path>,`.
- `notext <brief> <line> <label>`: the brief holds that exact header line, followed by a blank line and then a line that is not a fence.

The fixture is built at the end of `suite()`, after 3B, so no existing `lacks` sees it. `mkpk` writes K0 with `awk`/`printf` only, no python, exactly as the table's shapes read. It uses `big.sh` from the section 1 text and `mkdir pk/sub` with `git update-index --add --cacheinfo 160000,<HEAD sha>,pk/sub`. `echo 'pk/gen/** linguist-generated' >> .gitattributes` is added, then `git add -A`. P and F1 are the edits named in the rows, with `git add -A` and messages naming `#7`. `w`, `f` and `s` are the brief dirs: `.scratch/review/<K0 sha>`, `.scratch/review/<P sha>` and `.scratch/review/sweep-<P short>`. The runs:

- `review-brief.sh "$k0" --ticket 7`
- `fo_comment previous-3-spec.md "$p" > pk-2f.md; review-brief.sh "$p" --ticket 7 --previous pk-2f.md`
- `review-brief.sh --paths pk --commits "$p" "$f1" --ticket 7`

Each numbered row runs over both briefs (`for b in standards spec`) unless it says otherwise. Every assertion names its cell, as `(2W)`.

1. **1W** `entry $w/*-brief.md "pk/s.sh, whole, 3 lines" "#!/bin/sh" "echo s2"`; the same for `pk/t.sh`. **1F** `entry` for `pk/t.sh`; `none` for `pk/s.sh`. **1S** `entry` for both.
2. **2W** `entry "pk/big.sh, lines <a>-<b> of <n>" "# f10 does a thing" "}"` with the text containing `  local x=100`; `entry` for f50. **2F** `entry` for f50; the brief lacks `  local x=100`. **2S** `notext "### pk/big.sh, <n> lines, <size> bytes: no text; a sweep carries whole files only, so read it at HEAD"`.
3. **3W** `entry` from `# the top-level block` to `one() { echo ONE; }` (one merged entry). **3F** the brief lacks `echo top-two`. **3S** covered by 2S: the one line, no second `pk/big.sh` header.
4. **4W** `entry` from `cat <<EOF` to `EOF`. **4F** lacks `MIDDLE`. **4S** as 3S.
5. **5W** `entry` from `# assert a` to `line three" "label"`. **5F** lacks `line 2`. **5S** as 3S.
6. **6W** `entry` whose text contains `HUGE 90`, whose first line is not `huge() {`, and whose text is ≤ 4096 bytes and > 4096 minus the next line's bytes (the widening is maximal). **6F** lacks `HUGE 90`. **6S** as 3S.
7. **7W** `entry` whose text contains `DOC 60`, has neither `cat <<'DOC'` nor the `DOC` terminator line, and is ≤ 4096 bytes. **7F** lacks `DOC 60`. **7S** as 3S.
8. **8W** `entry` from `# f29 does a thing` to `}`, with the text holding `f31() {` and not `f30() {`. **8F** lacks `f29() {`. **8S** as 3S.
9. **9W** `entry "pk/big.md, lines …" "## Section 7" "BODY 7 …"`; `entry` for Section 20. **9F** `entry` Section 20; lacks `BODY 7`. **9S** `notext` sweep line for `pk/big.md`.
10. **10W** `entry` from `## Fenced` to `after fence`; `fence` is exactly 5 backticks. **10F** lacks `STILL inside`. **10S** as 9S.
11. **11W** `entry` containing `- ITEM 100`, first line not `## Huge section`, ≤ 4096 bytes. **11F** lacks `ITEM 100`. **11S** as 9S.
12. **12W** `entry "pk/crlf.md, lines …" "## Section 7"$'\r' "BODY 7 …"$'\r'`. **12F** `none pk/crlf.md`. **12S** `notext` sweep line for `pk/crlf.md`.
13. **13W** `entry "pk/code.py, lines …" "def f40(x):" "    return 0"`. **13F** `none pk/code.py`. **13S** `notext` sweep line.
14. **14W** `entry "pk/fences.md, whole, …"`; `fence` is 6 backticks. **14F** `none`. **14S** `fence` is 6 backticks.
15. **15W** `entry "pk/nonl.txt, whole, 3 lines" "a" "no newline"`, and the line after `no newline` is the fence. **15F** `none`. **15S** the same as 15W.
16. **16W** `entry "pk/new name.sh, renamed from pk/old name.sh, lines …" "# f20 does a thing" "}"`. **16F** `none "pk/new name.sh"`. **16S** `notext` sweep line for `pk/new name.sh`.
17. **17W** `notext "### pk/pure-renamed.sh, renamed from pk/pure.sh, <n> lines, no line changed: no text"`; `notext "### pk/mode.sh, <n> lines, no line changed: no text"`. **17F** `none` for both. **17S** a `notext` sweep line for each.
18. **18W** `entry "pk/added small.sh, whole, 1 line" "echo added" "echo added"`; `notext "### pk/added-big.sh, added, <n> lines, <size> bytes: no text; the diff's added lines are the whole file"`. **18F** `none` for both. **18S** `entry` for the small file; `notext` sweep line for the big one.
19. **19W** `notext "### pk/gone.sh, deleted at HEAD: no text"`. **19F** `none`. **19S** the same line as 19W.
20. **20W** `notext "### pk/bin.dat, binary: no text"`; `notext "### pk/gen/out.txt, generated (linguist-generated): no text"`. **20F** `none` for both. **20S** both lines as in 20W.
21. **21W** `notext "### pk/link, a symbolic link to t.sh: no text"`; `notext "### pk/sub, a submodule: no text"`. **21F** `none` for both. **21S** both lines.
22. **22W** `notext "### \$'pk/odd\\nname': no text; the path holds a newline, so read it from the repository"`; `notext "### pk/empty.txt, empty at HEAD: no text"`. **22F** `none` for both. **22S** both lines.
23. **23W** In each brief, the line numbers satisfy `## Diff` < `## Reading pack` < `## Standards` (Standards brief) or `## The ticket (#7)` (Spec brief). The two briefs' sections, from `## Reading pack` to the next `## ` line outside fences, are byte for byte equal and equal `$w/pack.md`. **23F** `## Diff` < `## Reading pack` < `## Settled in earlier rounds`, plus the equality. **23S** the order and the equality.
24. **24W** `has` the Report sentence in both briefs, and its line number is greater than the fifth Manuel quote's. **24F** the same. **24S** the same.
25. **25W** `printed` stdout is `ticket: #7`, `round: 1 of 3`, then the two paths. **25F** `printed` is the #106 `r3_fix` form with this run's dir and settled count. **25S** `printed` is `ticket: #7`, `round: 1 of 3`, then the two sweep paths.
26. **26W** (O1) `entry` WHOLE for each of `pk2/a.txt` .. `h.txt`; the brief lacks `Not carried`.
27. **27W** (O2) `entry` WHOLE for `pk2/i.txt` and `a` .. `g`; `none pk2/h.txt`; `i.txt`'s header line comes after `g.txt`'s (path order, not size order).
28. **28W** (O2) `has` the exact `Not carried` line from row 28; `none pk2/long.txt`.

Drift guard, next to the existing SKILL.md asserts:

- `has "$source_skill/SKILL.md"` the bullet, word for word.
- `has "$source_skill/SKILL.md"` the Report sentence.
- `has "$source_skill/scripts/reading-pack.sh" "pack_whole=8192 pack_unit=4096 pack_total=65536"`.

Refusal, written after 28 with no cell of its own because no fixture reaches it: `PATH` holds a `git` wrapper that fails on `check-attr`. The run exits 1 with `review-brief: the reading pack failed (above); nothing written`, and no `.claude/state/review` exists. This one is *not* run. It is the contract's Failure paragraph, and the writer confirms the wrapper reaches only the pack.

In the commit order, the test and the fixtures come first, failing, then `reading-pack.sh` and the `review-brief.sh` call, then the SKILL.md patch and `keep_files`, then `.gitattributes`.

## 4. Adversarial inputs

Each line says what the design does and whether it was run.

- **A file whose text holds fence lines.** The entry gets a 6-backtick fence around text holding 4- and 3-backtick lines and a mid-line run of 5. Ran (`fences.md`).
- **Headings inside fenced blocks.** Not a boundary: the `## Fenced` section runs past `## not a heading` to `after fence`, in a 5-backtick fence. Ran.
- **A pure-deletion hunk.** Lines c and c+1 are both mapped, so f29 and f31 merge into one entry. Ran. At the file's start or end the lines are clipped. Not run separately; it is the clip in the same awk.
- **A rename with edits.** The header reads `new name.sh, renamed from old name.sh, lines 100-104 of 867`, and the hunks come from the two-path `-M` diff. Ran. The first fixture had identical renamed files, and git paired them the other way. The test's fixture files carry distinct first lines for that reason.
- **Mode only, and pure rename, large.** `no line changed: no text`. Ran. Small ones are carried WHOLE. Ran (rule 8).
- **A path with spaces.** `-z` records, `":(literal)"` pathspecs and a raw header. Ran (`added small.sh`, `new name.sh`). A path with a newline gets the `%q` line. Ran. A path with glob characters is safe through `:(literal)`. Not run; it is the same form `review-brief.sh` already uses at its line 371.
- **A symlink.** `a symbolic link to nonl.txt: no text`. Ran. A submodule, both a real `git submodule add` and a bare gitlink over an empty directory. Ran (exp3, exp5).
- **A file with no trailing newline.** The text gets a newline before the fence, and the byte count includes it. Ran.
- **CRLF text.** Headings and fences are detected on CR-stripped lines, and the CR is kept in the text. Ran (`crlf.md`, section 7).
- **A heredoc holding a column-0 `}`.** The unit is `cat <<EOF` through `EOF`. Ran. Without the heredoc rule, `}` is a closer anyway, but `middle` would split the block. With `<<-` and a quoted word the rule is the same. Only `<<EOF` was run.
- **A multi-line double-quoted string at column 0** (the test file's `printed out.txt "…` statements). Without the quote tracker the unit was the lone changed line (ran). With it, the unit is the whole statement with its comment (ran).
- **A one-line function.** It is its own block, and it merges with the top-level `if` block it touches. Ran.
- **A 1,300-line function.** Flat and indented, the unit is the changed statement widened inside the function to 4,096 bytes (`flat.sh, lines 680-724 of 1505`). Ran. Unindented (suite style), the unit is the statement with its comments. Ran. Nested, the unit is the innermost `if` block widened to 4,096 bytes. Ran (`huge()`, 180 blocks).
- **A statement over the unit** (a 200-line heredoc). A window inside the statement. Ran.
- **Minified text** (one 72,000-byte line). The window is the line alone, too big for the total, so it is named on the `Not carried` line while every other entry is carried. Ran (`mini.js`, `long.txt`).
- **A diff that fills the total exactly.** Eight 8,192-byte files give 65,536 bytes, all carried, and no line. Ran (exp4).
- **An entry larger than the total.** Named on the line, and the smaller entries are still carried. Ran.
- **Long-line Markdown** (DECISIONS rows about 900 bytes each). The window is 3 lines, 2.7 KB. Ran. The draft's 20-line window carried 26,572 bytes of the real `DECISIONS.md`. Ran with the earlier prototype.
- **An empty file.** Before rule 7, it printed an empty fenced block. Ran. Rule 7 is not in the prototype.
- **`diff.renames=copies` in the user's config.** `C` records are read like `R`. Not run.
- **Worktree `.gitattributes` differing from HEAD.** `git check-attr` reads the worktree. The review runs on a clean checkout, so the difference is outside the path. Not run.
- **Speed.** A 68-entry real diff took 2.0 s, including a checkout. Ran.

## 5. Module map

- `scripts/reading-pack.sh` is new, about 150 lines, and owns everything in section 2 except placement. Its functions:
  - `units <kind> <line>...` is one awk program: blocks, chain, widen, window, Markdown sections, merge.
  - `one_file <status> <old> <new>` applies rules 1 to 12.
  - `emit <header> [<label> <textfile>]` appends to the entry list.
  - The tail selects entries, fences them and prints.
- `scripts/review-brief.sh` gets the call, `cat "$dir/pack.md"` in `common()`, the sentence in `report_rules()`, and one header comment line naming the pack.
- `patches/mattpocock/spec-review.SKILL.md.patch` gets the step 4 bullet, and `SOURCES.md` item 6 names the pack.
- `factory918.sh` gets `keep_files` plus `spec-review/scripts/reading-pack.sh`.
- `.gitattributes` is new, with the four generated paths.
- `tests/spec-review/review-brief.sh` gets the helpers, `mkpk`, and rows 1 to 28 with the drift guard.

## 6. Rationale

The pack exists to spare a reviewer the file opens, so each choice is judged by opens saved per byte of brief.

- **Bytes.** Bytes are what a lane holds, and line counts in this repository range from 20 to 1,000 bytes per line.
- **Smallest first.** For a fixed budget, the number of carried entries is maximized by taking the smallest first, the standard greedy optimum for counting items. The real merges showed that path order starves the code files.
- **One indentation rule.** It covers shell, Python, YAML and the test file's unindented `suite()` without a parser per language. The shell-only heredoc and quote tracking are the two places indentation lies in this repository's own files.
- **Headers and preamble.** The header line format is plain text, so no path can break it. The section has no preamble, because each header already says what its text is.
- **Sweep.** The sweep carries whole files only. HEAD is what a sweep finding is fixed against, but its diff's line numbers belong to older commits, so a unit at HEAD would name different lines.
- **Cutoffs.** 8192 / 4096 / 65536 were chosen from the five merges above. 16384 / 8192 carried 22 to 39 entries per merge. 8192 / 4096 carried 29 to 54, and every missed entry was named in one line. The pack plus a 500-line inline diff stays near 100 KB, which a reviewer lane holds easily.

Principles applied:

- **Build the lever.** The prototype and real-history runs decided the cutoffs, the order rule and the unit rule. Argument alone did not.
- **Model the domain.** The unit is one structure (a chain of blocks with a byte cap), not a branch per file type.
- **Separate before serializing shared state.** The pack is its own file with a one-call interface, so #108's work on `review-brief.sh` does not collide with it.
- **Single source of truth.** The constants live on one line, and the drift guard reads that line.
- **Fail fast and loud.** A git failure in the pack refuses the run before state is written. The pack never produces a silent short section.
