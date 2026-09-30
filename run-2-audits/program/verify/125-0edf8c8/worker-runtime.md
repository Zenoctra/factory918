# Slice: live runtime floor, and the new inside rule under attack — PR #125 at 0edf8c8

verdict: PASS+NOTES

Every run below is in a throwaway repository under a private directory
(`…/scratchpad/rt-a01ce4d9-private/`), with `TMPDIR` inside it and `tests/spec-review/fake-gh.sh`
copied onto `PATH` as `gh`. Nothing outside that directory was written; the checkout stayed detached
at `0edf8c8952e7563ec862e460f71becde4506bd96`, `git status --porcelain` empty, and
`git merge-base --is-ancestor 01a1e5f HEAD` exits 0.

## The fixture

`tests/spec-review/layout.sh` laid the skill into a new repo. `base` holds `a.sh`, `b.sh` and
`old.sh`; `old.sh` is never touched by the PR, so it is not in `<dir>/files`. Commit `r1` (round
one's reviewed commit) appends `guard()` to `a.sh` and `note()` to `b.sh`; commit `r2` (the fix)
appends a `repair()` block to `a.sh` that deliberately re-uses two lines of untouched `old.sh`
(`else` and `echo legacy full`) and one more (`exit 0`), so the audit's collision is real and not
hand-written into `fix-lines`.

- `review-brief.sh <base> --previous <round-one comment with reviewed: r1>` → `round: 2 of 3`,
  exit 0. `<dir>/files` = `a.sh b.sh`; `<dir>/fix-lines` = `repair() {`, `echo repairing the guard
  properly`, `if [ -n "$2" ]; then`, `echo has two`, `else`, `echo legacy full`, `exit 0` (the `}`
  is under four characters and is dropped); `<dir>/fix-ranges` = `13\t21\ta.sh`. The rule's inputs
  are what the brief's header says they are.

## (a) The audit's reproduction

- `a1`, a plain ```` ```sh ```` quote of untouched `old.sh:6-8` (`else` / `echo legacy full` / `fi`),
  Documented step quoting the ticket line: at 0edf8c8 the comment prints **no** `fix only after`
  line (exit 0; `would-break fixed after …`, `next round owed: round 3 …`, `round: 2 of 3`,
  `act-on items: 0`). The same dir against `git show caecbc4:…/review-comment.sh` prints
  `fix only after 258cbae…`. The hole is closed and the old behaviour is reproduced.
- `a2`, the `else` variant (a plain quote of `if [ -z "$1" ]; then` / `echo legacy empty` / `else`):
  same — silent at 0edf8c8, `fix only after 258cbae…` at caecbc4.
- `b9`, a plain quote of code the fix really did add (`echo repairing the guard properly`, no `+`):
  silent at 0edf8c8, `fix only after …` at caecbc4. An unmarked quote now decides nothing, which is
  the conservative direction.

## (b) Fourteen shapes tried against the rule (round two, one Would-break item each)

Safe = the script does not print `fix only after`, so round three reviews the whole diff.

| shape | prints `fix only after`? | safe |
| --- | --- | --- |
| a1 plain quote sharing a fix line | no | yes |
| a2 plain quote sharing `else` | no | yes |
| b1 `+` quote whose text also occurs in untouched `old.sh` | **yes** | see Issues |
| b2 `+` quote of a fix line plus `a.sh:6` (outside the ranges) | no | yes |
| b3 `a.sh:14` (inside) with a `+` quote that is not a fix line | no | yes |
| b4 good `+` quote, Documented step `old.sh:9` | no | yes |
| b5 good `+` quote, two paths `a.sh:14` and `b.sh:2` | no | yes |
| b6 good `+` quote, no path at all | yes | the accepted case |
| b7 the same with CRLF line endings | yes | same as b6, CRLF is stripped |
| b8 a `-` line quoted beside the `+` line | no | yes |
| b9 plain quote of fix code | no | yes |
| b10 a full hunk with `--- a/a.sh`, `+++ b/a.sh`, `@@` headers | no | yes (see Notes) |
| b11 good `+` quote plus `a.sh:10-14` straddling the range | no | yes |
| b12 good `+` quote plus `old.sh:14` (a file not in `<dir>/files`) | no | yes |
| g1 an inside item whose prose says `step:12` | no | yes (over-conservative) |
| g2 the same inside item under `## Fails open` | yes | both hard headings are scanned |
| g3 a hard item in the **Spec** report with no quote | no | yes (both reports are scanned) |

On b1 and b6, the accepted case: the item is inside only because its quote is marked `+` and no
`file:line` anywhere in the item (the `Documented step:` line included) falls outside the fix. A
real bug in untouched code can be reported that way only if the reviewer both prefixes untouched
code with `+` and names no location — b4 and b12 show that a single `file:line` outside the fix, in
the body or in the Documented step, sends the item back outside, and b2/b3/b5/b11 show the path
check is not fooled by a right-looking neighbour. With `## Would break` items required to carry a
`Documented step:` line, the shape survives only when that step quotes the ticket line rather than a
`file:line`. I could not build a plausible reviewer report that lands there by accident.

## (c) The fail-safe direction

- `c1` (quote `+  exit 0`, a unique fix line; `a.sh:20`, inside `13-21`) → `fix only after
  258cbae…` at round two, exit 0.
- `review-brief.sh 258cbae… --previous <that comment>` → `round: 3 of 3`, exit 0,
  `<dir>/fixed-point` = `258cbae…` (round two's reviewed commit), `<dir>/log` = the round-three fix
  commit alone, and `## The fix under review` present at line 14 of **both** `standards-brief.md`
  and `spec-brief.md`, carrying the Act on item. No `fix-lines`/`fix-ranges` written at round three.
- The same comment with `base` as the fixed point is refused, exit 1: `review-brief: round 3 reviews
  only the fix from 258cbae…, the commit round 2 reviewed (the `fix only after` line of the last
  review comment); 97b5e5a… is not that commit`.
- `c2`, a round-two report with no hard items at all, prints `fix only after …` (zero items outside
  is zero). See Notes.

## (d) Rounds one, two and four/five unchanged

- Byte for byte: the same review dir run through `git show 01a1e5f:…/review-comment.sh` and through
  the script at 0edf8c8, `diff`ed after deleting only the three new lines. Identical (`cmp -s`, exit
  0) for round 1 with no fix, round 1 with a fix, round 2 inside, round 2 outside, round 2 with no
  fix, round 3 inside. Nothing else in the comment moved.
- Rounds four and five, as #102 made them: round three's comment carrying `would-break fixed after
  9ffba72…` → `review-brief.sh 9ffba72… --previous` gives `round: 4 of 5` with `## The fix under
  review` in both briefs; round four's comment gives `would-break fixed after 17de2f9…` → `round: 5
  of 5`; a sixth is refused, exit 1, `review-brief: five rounds were run on this PR; round five's
  Would-break fixes are the human's to review (spec-review step 5), not reviewed in a sixth round`.
- A wrong fixed point at round four is refused with #102's message, exit 1: `review-brief: round 4
  reviews only the fix from 9ffba72…, the commit round 3 reviewed (the `would-break fixed after`
  line of the last review comment); 258cbae… is not that commit`. With the `would-break fixed after`
  line deleted from the comment, the old refusal stands: `review-brief: three rounds were run on
  this PR; the remaining Act on items are fixed here and marked `fixed: <sha>`, not reviewed in a
  fourth round`.
- Rounds three, four and five print none of the three new lines.

## (e) `next round owed:` and the babysit sentence

- Round 1, no item marked `fixed:` → absent. Round 1, one marked → `next round owed: round 2
  reviews the fixes marked here`. Round 2, one marked → `next round owed: round 3 …`. Round 2, none
  marked → absent. Round 3 → absent. So: rounds one and two, exactly when an item is marked.
- A `hole:` at round two outranks both: the comment prints `restart`, then `round: 2 of 3`, and
  neither `next round owed:` nor `fix only after`.
- The babysit sentence is present and word for word identical in both copies,
  `template/.agents/skills/babysit/SKILL.md:40` and
  `template/.agents/skills/poteto-mode/playbooks/babysit.md:16`, and in both patches
  (`patches/pstack/babysit/SKILL.md.patch:8`,
  `patches/pstack/poteto-mode/playbooks/babysit.md.patch:10`).

## (f) `fix-lines` / `fix-ranges` in the awkward cases

A second scratch repo whose fix commit renames `moved.sh` to `renamed.sh`, deletes `gone.sh` and
appends a line to `a.sh`:

- Round one's `reviewed:` naming a sha that does not resolve → brief exits 0, writes neither file.
- A sha that resolves but is no ancestor of HEAD (`git commit-tree`) → same, neither file written.
- A malformed (short) `reviewed:` sha → the line is not matched at all, neither file written.
- The real sha → `fix-lines` = `iota the ninth line`, `zeta the sixth line`, `eta the seventh line`;
  `fix-ranges` = `6\t6\ta.sh`, `1\t3\trenamed.sh`. The deleted file contributes nothing (its HEAD
  blob is absent and the read is guarded); `#!/bin/sh` in the renamed file is correctly dropped as
  non-unique.
- In every case above, with `fix-lines` absent, an item quoting anything reads outside, so round
  three reviews the whole diff. Safe direction throughout; no run exited non-zero.

## The repository's own floor at this SHA

- `bash tests/spec-review/review-brief.sh` → `ok 1104 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 298 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.

## Issues

- None that block. (b1 is a judgment call, recorded below, not a defect against the amended rule.)

## Notes

- b1 is the amended rule's remaining false-inside: the fix added `echo legacy full`, untouched
  `old.sh:7` has the same text, and `old.sh` is outside `<dir>/files`, so the brief's uniqueness
  test never sees the collision. An item quoting that line as `+`, with no `file:line`, reads
  inside. The `+` marker is what saves it in practice — a reviewer describing untouched code does
  not prefix it with `+`, and any location in the item closes the door (b4, b12).
- A rename at round two makes the moved file's untouched lines count as fix-added ((f), `zeta`/`eta`
  in `renamed.sh`), since the old path is gone at HEAD. Round three's diff then contains that whole
  file anyway, so the reviewer still reads it. Worth knowing, not worth a fix.
- `c2`: a round-two comment with zero hard items prints `fix only after <sha>` even when the fix
  commits are empty of anything to review. Round three's brief then refuses cleanly with
  `review-brief: the diff is empty; nothing to review since <sha>`, so the path terminates rather
  than skipping a review.
- b10: a reviewer who pastes a whole `git diff` hunk, headers included, gets "outside" — `+++ b/a.sh`
  and `--- a/a.sh` are marked lines that are not fix lines. `review-brief.sh` skips `^+++ ` when it
  builds `fix-lines`; `review-comment.sh` has no matching skip. The direction is safe (more review),
  and the hunk shape SKILL.md asks for has no headers, so this is only a usability note.
- g1: any prose token of the form `word:12` inside a hard item — `step:12`, `URL:8080` — is read as
  a location, fails the path lookup and pushes the item outside. Again the safe direction.
- Carried over from the first pass and still true: the babysit sentence writes the placeholder as
  `round <N>` while `SKILL.md` step 6 and the script write `round <N+1>`. Both are prose
  placeholders for the same line, the test pins the sentence, and nothing breaks.
- `SKILL.md` step 6's description of the line now matches the code, including the parenthesis "an
  item that quotes plain code or no code … counts as outside". The first pass's wording finding is
  addressed.
- Nothing was merged, commented, edited or closed. No file under version control was written.
