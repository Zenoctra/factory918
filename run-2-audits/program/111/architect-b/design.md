# Architect runner B, ticket #111: stamp trail rows with the clock

Candidate design package. Base: `origin/feat/review-reading-pack` (f58308b). No repository code written.

The shape in one sentence: one new script of ours, `show-me-your-work/scripts/check-trail.sh`, turns
criterion 2 into a deterministic exit code; the skill patch closes the loophole that licensed hand-typed
rows; `log.sh` does not change.

Every cell below was run, on macOS 15 (bash 3.2, BSD awk) and on `ubuntu:24.04` in Docker (mawk 1.3.4,
what the CI runner has). The two outputs are byte-identical after masking the temp path and the clock.
`date -u -d` does not exist on macOS (`date: illegal option -- d`, exit 1, run today), which is why no
part of this design parses a timestamp with `date`.

---

## 1. Scenario table

The situation is the state of the trail file. The input shape is which bounds the caller passed.
Every cell gives what is printed, the exit code, and what the caller does next.

Legend, used by every cell:

- **clean** prints `check-trail: <file>: <N> rows, clean` on stdout, exit 0. Caller: the trail review
  proceeds to its judgment bullets, quoting that line as its evidence.
- **refused** prints one line per offending row on stdout, in file order, then a last line
  `check-trail: <file>: refused, <n> findings; a trail row is stamped by scripts/log.sh, never typed`,
  exit 1. Caller: the trail review copies those lines verbatim into the Attention section, and the PR
  is not merge-ready until a later check is clean.
- **rejected** prints one line on stderr, exit 2, nothing checked. Caller: fix the call, rerun; the
  review cannot report on a trail it did not read.
- **row line** is `<file>:<line>: <reason>`, the line number counted from 1 at the header.
- **bounds**: `run-start` and `run-end` are ISO8601 UTC (`YYYY-MM-DDTHH:MM:SSZ`). `run-end` defaults
  to `date -u` at check time. `run-start` defaults to the first row, which is the same as not
  checking a lower bound.

| Trail state | `check-trail.sh <trail>` | `… <trail> <run-start>` | `… <trail> <run-start> <run-end>` |
|---|---|---|---|
| Header is the six columns, rows non-decreasing, two rows in the same second, trailing blank line | clean, `3 rows, clean` | clean | clean |
| Header only, no rows | clean, `0 rows, clean` | clean | clean |
| Header is `ts what why evidence result` (the #91 and #93 shape), rows have five columns | refused: `:1: header is "ts\twhat\twhy\tevidence\tresult", expected "ts\tphase\tdecision\twhy\tevidence\tresult"` and `:2: has 5 columns, expected 6` | same | same |
| A row with seven columns (a tab typed into a cell) | refused: `:2: has 7 columns, expected 6` | same | same |
| A `ts` cell reading `TBD`, `17:45`, or any non-stamp | refused: `:2: ts TBD is not a log.sh stamp (YYYY-MM-DDTHH:MM:SSZ)` | same | same |
| A row earlier than its predecessor (the #91 drift) | refused: `:3: ts 2026-09-22T17:30:00Z is before line 2, 2026-09-22T17:45:00Z` | same | same |
| A row stamped ahead of the clock (#93 wrote `19:35:00Z` at 17:46) | refused only while now is before it; after the fact the row is inside `now` and only the order finding remains | same | refused: `:4: ts 2026-09-22T19:35:00Z is after the run ended (2026-09-22T17:46:03Z)` |
| A row before the lane started (a copied or inherited trail) | clean on this axis; the first row is the lower bound | refused: `:2: ts 2026-09-22T09:32:05Z is before the run started (2026-09-22T10:00:00Z)` | same |
| Several offenders | refused, one line each, in file order, then the count | same | same |
| No such file, a directory, or a file the caller cannot read | rejected: `check-trail: <path>: not a readable file` | same | same |
| No arguments, or four | rejected: `usage: check-trail.sh <logfile> [<run-start> [<run-end>]]` | same | same |
| A bound that is not a stamp (`yesterday`, `2026-09-22`) | n/a | rejected: `check-trail: yesterday is not an ISO8601 UTC timestamp (YYYY-MM-DDTHH:MM:SSZ)` | same |

Two cells carry the design's only real weakness, and both are honest in the table. A trail checked
with no bounds long after the run keeps its order guarantee and loses the future guarantee, because
`now` has overtaken the invented stamp. A trail checked with no bounds has no lower bound at all.
Both are answered by passing `run-start`, and the review step that calls this does pass it whenever
the launcher recorded one. Nothing here refuses a real run: a lane that appends through `log.sh` is
non-decreasing and inside its own bounds by construction.

## 2. Contract

**Terms.**

- **trail**: a show-me-your-work decision log, a TSV whose first line is exactly
  `ts<TAB>phase<TAB>decision<TAB>why<TAB>evidence<TAB>result`, and whose other non-blank lines are rows.
- **stamp**: a `ts` cell matching `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$`, which is
  exactly what `date -u +%Y-%m-%dT%H:%M:%SZ` in `log.sh` writes.
- **run bounds**: the wall-clock interval the lane occupied, as two stamps, `run-start` and `run-end`.
- **offending row**: a row breaking one of the four row invariants below. A row can offend more than
  once and then prints more than one line.
- **finding**: one printed `<file>:<line>: <reason>` line. The header can produce one.

**Invariants the script enforces**, in this order per row:

1. Six tab-separated columns.
2. `ts` is a stamp.
3. `ts` is not before the previous row's `ts`. Equal is allowed: `log.sh` has one-second resolution
   and two decisions in the same second are ordinary.
4. `run-start <= ts <= run-end`, with the defaults above.

Plus one file invariant, the header line, checked once.

**Comparison is arithmetic on the digits, never a date library.** `2026-09-22T17:45:00Z` becomes the
integer `20260922174500` by deleting `-`, `:`, `T` and `Z`. Fixed-width UTC stamps compare correctly
that way, all values are under 2^53 so both mawk and BSD awk hold them exactly, and the result does
not depend on locale collation, on GNU versus BSD `date`, or on a `TZ` the runner happens to set. This
is the single decision that makes the check portable, and it is why the script rejects any bound that
is not already in that exact shape rather than trying to be helpful about `yesterday`.

**Exit codes.** 0 clean. 1 refused, at least one finding. 2 rejected, the call itself is wrong and no
trail was read. Findings go to stdout so the reviewer can paste them; rejections go to stderr.

**Idempotent and read-only.** The script never writes, so running it twice, or after a crash, says the
same thing about the same file and the same bounds. Nothing in the design edits trail history, which
would break the skill's append-only rule.

**Where the bounds come from**, best first. The review uses the best it has.

1. `run-end` defaults to the clock at check time. No bookkeeping, nothing circular, and it is the
   bound that catches the real defect: on 2026-09-22 the #93 owner wrote `19:35:00Z` at 17:46, and the
   trail review runs at hand-back, minutes later, when `now` is still 17:4x.
2. `run-start` from whoever launched the lane. Under autopilot the root already stamps its registry
   lines with `date` (SOURCES item 16), and an orchestrator that opened its own trail has a row for
   the launch. Ticket step 9 passes it when the parent recorded one.
3. Neither: the check still refuses order breaks and stamps in the future, and says so by printing
   nothing about bounds.

Rejected as a bounds source: reading the lane's transcript JSONL, which is how `parse.py` does it
after the fact. It needs the encoded-cwd path, a JSON parser and a five-minute slack window, all in a
shell script that runs on every PR. The post-mortem is the right place for that work; the gate is not.

## 3. Test list

One assertion per cell, in the order of the table, in `tests/show-me-your-work/trail-clock.sh`, in the
style of `tests/poteto-mode/overlap.sh`: build fixtures under one `mktemp -d`, compare exit code and
the exact output, exit 1 on the first miss. Each fixture is a trail file written with `printf`.

1. Six-column header, three rows, two sharing a second, trailing blank line, no bounds. Exit 0,
   output `check-trail: clean.tsv: 3 rows, clean`.
2. The same file with `run-start` only. Exit 0, same line.
3. The same file with both bounds around it. Exit 0, same line.
4. Header only. Exit 0, `0 rows, clean`.
5. `ts what why evidence result` header and one five-column row. Exit 1, the header line then the
   column line then the count, in that order.
6. A seven-column row. Exit 1, `:2: has 7 columns, expected 6`.
7. A `ts` of `TBD`. Exit 1, `:2: ts TBD is not a log.sh stamp (YYYY-MM-DDTHH:MM:SSZ)`.
8. The #93 fixture (17:45, 17:30, 19:35) with bounds 17:26 to 17:46. Exit 1, two lines: the order
   line naming line 3 and line 2, the after-the-run line naming line 4.
9. The same fixture with no bounds. Exit 1, the order line only. This asserts the weakness in the
   table is the behaviour, not an accident.
10. One row stamped `2099-01-01T00:00:00Z`, no bounds. Exit 1, the after-the-run line, whose bound
    text is the clock, so the assertion matches on the prefix up to `(`.
11. One row at 09:32 with bounds 10:00 to 11:00. Exit 1, the before-the-run line.
12. No arguments. Exit 2, the usage line on stderr.
13. Four arguments. Exit 2, the usage line.
14. `yesterday` as a bound. Exit 2, the bound line.
15. A path that does not exist. Exit 2, `not a readable file`.
16. A directory as the logfile. Exit 2, the same line. (No unreadable-permissions cell: under Docker
    and on a CI runner the test can run as root, where `chmod 000` still reads. Verified today: the
    macOS run refused it and the Ubuntu root run read it. The `-r` guard stays, the assertion does not.)
17. `grep -q` on `template/.agents/skills/show-me-your-work/SKILL.md`: it carries the sentence that a
    row is appended only through `scripts/log.sh` and that a lane never types a `ts`, and it no longer
    carries the words `A bare `printf` appending a row works too`. This is criterion 1 as a check
    rather than a reviewer's memory, in the manner of `tests/spec-review/no-stale-wording.sh`.
18. `grep -q` on `factory918.sh`: `keep_files` names `show-me-your-work/scripts/check-trail.sh`, so a
    later `sync` cannot silently drop the script.

Then the repository's own gates, which the PR's Verification section names: the ShellCheck line (the
new script is already inside `template/.agents/skills/*/scripts/*.sh` and the new test inside
`tests/*/*.sh`, so only the count in `AGENTS.md` changes, 24 to 26), `./factory918.sh sync` leaving
`git status` clean with the new patch applied, and `python3 tools/build_knowledge.py` clean.

## 4. Usage, caller first

The reviewer's call, the only one that matters. From the trail review in `show-me-your-work/SKILL.md`:

```sh
# In the cross-model reviewer's brief, before it reads anything else:
bash .claude/skills/show-me-your-work/scripts/check-trail.sh .scratch/111/decisions.tsv
# with the launch time when the parent recorded one:
bash .claude/skills/show-me-your-work/scripts/check-trail.sh .scratch/111/decisions.tsv 2026-09-22T09:30:01Z
```

A lane can run it on itself before hand-back; it is read-only and cheap:

```sh
bash .claude/skills/show-me-your-work/scripts/check-trail.sh decisions.tsv || echo "fix the trail before the review sees it"
```

The post-mortem, or a human, checks a finished trail against bounds taken from the transcript:

```sh
bash template/.agents/skills/show-me-your-work/scripts/check-trail.sh \
  .scratch/program/93/decisions.tsv 2026-09-22T13:20:11Z 2026-09-22T17:46:03Z
```

**Signature.**

```
check-trail.sh <logfile> [<run-start> [<run-end>]]
  <logfile>     path to a decision trail (TSV)
  <run-start>   ISO8601 UTC stamp; default: the first row's ts
  <run-end>     ISO8601 UTC stamp; default: date -u at check time
  exit 0 clean | 1 refused (findings on stdout) | 2 rejected (message on stderr)
```

There is no flag parsing, no `--verbose`, no `--slack`. Three positional arguments carry everything
the callers need, and the absence of a slack window is deliberate: the bounds a caller passes are the
lane's own launch and the check's own clock, which already contain every honest row.

## 5. Module map and the files a writer touches

```
template/.agents/skills/show-me-your-work/
  SKILL.md                      patched: the rule text (3 edits, below)
  scripts/log.sh                unchanged
  scripts/check-trail.sh        new, ours, ~50 lines of bash + awk
tests/show-me-your-work/trail-clock.sh   new, the 18 assertions
patches/pstack/show-me-your-work/SKILL.md.patch   new, appended to patches/series
patches/series                  one line appended
SOURCES.md                      item 18
factory918.sh                   keep_files gains show-me-your-work/scripts/check-trail.sh
template/docs/agents/evidence.md  criterion 3, a Timing bullet
template/.agents/skills/poteto-mode/playbooks/ticket.md  step 9, ours, no patch
.github/workflows/factory-ci.yml  one step
AGENTS.md                       the new test line; ShellCheck count 24 to 26
```

The call chain is two files deep: the reviewer's brief calls `check-trail.sh`, which calls `awk`.
Nothing imports anything.

**Ours via `keep_files`, not created by a patch.** `sync` copies upstream over the skill directory,
restores `keep_files`, then applies `series`. A patch that adds a whole new file would carry the
script's entire body as a diff hunk, would have to be regenerated on every edit to the script (the
`diff -u` recipe in `patches/README.md` has no source file to diff against), and would fail loudly on
an upstream bump that touched nothing relevant. `keep_files` is precisely the precedent this case
matches: `poteto-mode/scripts/overlap.sh` and the three `spec-review/scripts/*.sh` are ours the same
way. The SKILL.md change is the opposite case and stays a patch, since upstream owns that file.

**`log.sh` does not change.** It already stamps `date -u` and already writes the header. The defect
was not in the helper, it was lanes not using it, so the fix is the rule plus the gate, not another
patched vendored file to rebase on every upstream bump. I considered making `log.sh` refuse an append
that would go backwards. It is four lines and it would enforce the invariant at write time, which the
encode-lessons-in-structure principle likes. I rejected it: it only fires for a clock that jumped
backwards, which is not the defect, it cannot help a trail written by hand (the case that happened),
and it adds a second patch against a vendored script for no assertion the gate does not already make.
If a later run shows a backwards clock, that is its own ticket.

**SKILL.md, the three edits.** All in the vendored file, carried by patch item 18.

1. In **Logging a row**, the sentence beginning `A bare `printf` appending a row works too` is replaced.
   That sentence is the loophole that licensed the hand-typed rows; deleting it is most of the fix:
   > Append every row with the helper. A lane never types a `ts`: the column is the run's clock, and
   > `log.sh` stamps it from `date -u`. A trail whose stamps were typed is refused by the trail review
   > below. Never edit a `ts` afterwards; the append-only rule covers the clock first.
2. In **The format**, the `ts` bullet gains its reader: `The timeline axis, and the timing record the
   post-mortem reads to tell how long each phase took.` (criterion 3, the skill half.)
3. In **Cross-model review of the trail**, a first instruction before the four bullets:
   > The reviewer's first act is `scripts/check-trail.sh <logfile> [<run-start>]`. Exit 1 is a refusal:
   > its lines go into the Attention section word for word, above the reviewer's own flags, and the run
   > does not hand back clean until a later check passes. Exit 2 means the call was wrong, not the
   > trail; fix it and rerun.

**`ticket.md` step 9** (ours, edited directly) gains one sentence: the trail review's brief names the
trail path and the lane's launch stamp when the program registry recorded one, and a refusal blocks
merge-ready exactly as a red check does.

**`evidence.md`** gains one bullet, criterion 3's other half:
> **Timing.** The decision trail (`decisions.tsv`, show-me-your-work) is the timing record. Every row
> is stamped by `scripts/log.sh` from `date -u`, never typed, and the post-mortem tooling reads those
> stamps as the run's clock. A trail that fails `scripts/check-trail.sh` is not evidence of timing.

## 6. The script, as verified

Not repository code: this is the body both platforms ran today, for the writer to start from.

```bash
#!/usr/bin/env bash
# Check a show-me-your-work decision trail is a clock record and not a story: the six columns,
# every ts in the shape log.sh stamps, non-decreasing, and inside the run's bounds.
# Usage: check-trail.sh <logfile> [<run-start> [<run-end>]]
# Bounds are ISO8601 UTC (YYYY-MM-DDTHH:MM:SSZ). run-end defaults to now, run-start to the
# first row, so a trail checked with no bounds is still refused for order and for the future.
set -euo pipefail

stamp='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
	printf 'usage: check-trail.sh <logfile> [<run-start> [<run-end>]]\n' >&2
	exit 2
fi
logfile="$1"
if [ ! -f "$logfile" ] || [ ! -r "$logfile" ]; then
	printf 'check-trail: %s: not a readable file\n' "$logfile" >&2
	exit 2
fi
for bound in "${2:-}" "${3:-}"; do
	if [ -n "$bound" ] && ! printf '%s' "$bound" | grep -Eq "$stamp"; then
		printf 'check-trail: %s is not an ISO8601 UTC timestamp (YYYY-MM-DDTHH:MM:SSZ)\n' "$bound" >&2
		exit 2
	fi
done

awk -v file="$logfile" -v start="${2:-}" -v end="${3:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}" \
	-v header="$(printf 'ts\tphase\tdecision\twhy\tevidence\tresult')" -F '\t' '
	function num(t) { gsub(/[-:TZ]/, "", t); return t + 0 }
	function bad(line, msg) { printf "%s:%d: %s\n", file, line, msg; n += 1 }
	NR == 1 {
		if ($0 != header) bad(NR, "header is \"" $0 "\", expected \"" header "\"")
		next
	}
	/^[ \t]*$/ { next }
	{
		rows += 1
		if (NF != 6) { bad(NR, "has " NF " columns, expected 6"); next }
		if ($1 !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/) {
			bad(NR, "ts " $1 " is not a log.sh stamp (YYYY-MM-DDTHH:MM:SSZ)"); next
		}
		t = num($1)
		if (prevline && t < prev) bad(NR, "ts " $1 " is before line " prevline ", " prevts)
		if (start != "" && t < num(start)) bad(NR, "ts " $1 " is before the run started (" start ")")
		if (t > num(end)) bad(NR, "ts " $1 " is after the run ended (" end ")")
		prev = t; prevts = $1; prevline = NR
	}
	END {
		if (n) {
			printf "check-trail: %s: refused, %d findings; a trail row is stamped by scripts/log.sh, never typed\n", file, n
			exit 1
		}
		printf "check-trail: %s: %d rows, clean\n", file, rows
	}
' "$logfile"
```

## 7. Rationale

**Why a script and not a reviewer's judgment.** Criterion 2 asks for a refusal with a line naming the
rows. A subagent asked to eyeball timestamps gives a different answer on different days, and the
2026-09-22 run is the evidence: three of five lanes ran the trail review at all. An exit code is the
same on every PR, costs no tokens, and gives the reviewer a sentence it can paste instead of a
judgment it has to form. The reviewer keeps the work it is actually good at, the four
weak-evidence-and-risk bullets.

**Why the header is checked.** The post-mortem's own caveat is that #91 and #93 used
`ts, what, why, evidence, result`, so their phase cells came out blank and the per-phase timing had to
fall back to decision text. A trail with the wrong header is not the record criterion 3 names, and the
check is one string comparison. It also catches CRLF, which would otherwise pass every row check and
quietly corrupt the last column.

**Why `now` is the default upper bound.** It is the only bound available with no bookkeeping anywhere,
and it is exactly the one that catches an invented future stamp at the moment it matters, at hand-back.
Everything else about the run's wall clock lives in the transcript, which belongs to the post-mortem.

**Data structure first.** The trail is a list of (stamp, row) pairs with one ordering invariant and one
containment invariant. Encoding the stamp as a 14-digit integer makes both invariants integer
comparisons, which is what removed the whole `date -d` versus `date -j` problem rather than working
around it. Every other candidate shape I tried (parse to epoch, compare strings under the locale's
collation) would have needed a portability caveat in the contract.

**Smallest thing that satisfies the criteria.** One new script, one patched skill file, one doc bullet,
one playbook sentence, one test. No change to `log.sh`, no change to the four playbooks that open
trails (they reference the skill by name and the skill owns the format), no new dependency, no state
written anywhere.

**Risks.**

- A lane could still hand-write a trail whose stamps are plausible and ordered. Nothing short of the
  transcript catches that, and the design says so rather than pretending. What it removes is the easy
  failure: placeholders, round numbers, drift, and the wrong header.
- The `run-end` default makes the clean result depend on when the check runs. That is intended and the
  test asserts both sides of it (cells 8 and 9).
- One more patch to rebase on an upstream `show-me-your-work` bump. Mitigated by keeping the script
  out of the patch; the patch is three prose edits.

**Where I would take a graft from another runner.** A one-line change to the clean output naming the
bounds it used (`… 14 rows, clean (2026-…Z to 2026-…Z)`) would make the reviewer's evidence self
describing; I left it out because I did not run it. If another candidate has the reviewer's brief
wording, take theirs; mine is deliberately three sentences.

## 8. Verification evidence for this design

- `date -u -d '2026-01-01'` on macOS 15: `date: illegal option -- d`, exit 1. Run 2026-09-23.
- `shellcheck --external-sources check-trail.sh` at the repository's pinned 0.11.0: clean.
- All 16 runtime cells run on macOS 15 (bash 3.2, BSD awk) and on `ubuntu:24.04` (mawk); outputs
  byte-identical after masking the temp directory and the clock stamp.
- Scratch copies of the script and the cell runner:
  `/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad/final/check-trail.sh`
  and `…/final/probe.sh`.
