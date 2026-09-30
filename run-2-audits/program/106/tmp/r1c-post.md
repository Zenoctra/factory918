Round one of the redesign found no hard finding on either axis: the Spec walk found every criterion and the amended inside-the-fix rule implemented, and the Standards reviewer raised two smells, both judged Consider. Nothing was fixed before posting, so no further round is owed.

## Standards

# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the fix-line rule is written twice, and the two copies differ.** `review-brief.sh` builds `<dir>/fix-lines` with one trim-and-length rule, and `review-comment.sh`'s `outside()` re-implements the same rule to read a quoted hunk back. The producer skips `+++ ` header lines; the consumer does not, so a reviewer who quotes a hunk with its `+++ b/path` header makes every such item read as outside the fix. That is the conservative direction P106 asks for ("every other case is outside, so round three reviews the whole diff"), so it is not a hard finding, but the shape is one rule in two places and the drift is already visible.

```sh
# review-brief.sh
    /^\+\+\+ / { next }
    /^\+/ { s = substr($0, 2); sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); if (length(s) >= 4 && n[s] == 1 && !seen[s]++) print s }
```

```sh
# review-comment.sh, outside()
      fence != "" && hard && /^[+-]/ { s = substr($0, 2); sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s)
        if (length(s) >= 4) { marked = 1; if (!/^\+/ || !(s in fix)) ok = 0 } }
```

2. **`outside()` cannot tell "no fix corpus" from "nothing outside the fix".** When `<dir>/fix-lines` and `<dir>/fix-ranges` were never written (round one's comment carried no `reviewed:` line, or the recorded commit is no longer an ancestor after a rebase), the `getline` loops load nothing and a report with zero hard items still yields `0`, so `fix only after <sha>` prints. The verdict matches the design — round two found no hard bug — so it is not a finding; a guard on the two files existing would make the reason legible rather than incidental.

```sh
  mine=""; [ ! -f "$dir/reviewed" ] || mine="$(head -n 1 "$dir/reviewed")"
  if printf '%s' "$mine" | grep -qE '^[0-9a-f]{40}$'; then
    if [ "$round" -eq 1 ]; then record="reviewed: $mine"
    elif [ "$(outside)" -eq 0 ]; then record="fix only after $mine"; fi
  fi
```

hard findings: 0

## Spec

## Walk

1. Round one, criterion 1: `review-comment.sh` changes no round-one brief; its comment gains `reviewed: <sha>` from `<dir>/reviewed` (40 hex, first line), and a hole suppresses it. Table B 1A, 9A, 10A.
2. Round two's brief: `rv` is the last unfenced line of length 50 whose `substr($0, 11)` is hex. With `round` 2, `top` 1, `rv` resolving and an ancestor of HEAD, it writes `<dir>/fix-lines` (the `+` lines of `<rv>..HEAD`, trimmed, four characters or more, text unique across the HEAD versions of `<dir>/files`) and `<dir>/fix-ranges` (new-side hunk ranges per file, `:(literal)` pathspec, path through `ENVIRON`). Removed lines are dropped, as the amended Terms require.
3. Round two's comment: `outside()` counts the hard items not inside the fix. The capture rule sits before `$fenced` and counts only `+`/`-` lines of four characters or more; an item is inside when it has at least one such marked line, every one is a `+` whose text is a fix line, and every `path:N` or `path:N-M` in its unfenced lines (opening line and `Documented step:` included, the item rule no longer ending in `next`) names exactly one file of `<dir>/files` inside one range. Zero outside prints `fix only after <sha>`. Table B 2 to 6, 14, 15.
4. Round three's brief: `from`/`via` are set by `round -eq 3 && top -eq 2 && -n "$fo"`, and the shared block raises `FR`, `FP` (with `$via` in its text) and `FT` before `mkdir -p "$dir"` and before the empty-diff and blast-radius refusals. A malformed FO line leaves `fo` empty, so round three reads the whole diff. Table A 5, 7 to 12.
5. The fix section: `common()` now tests `-n "$from"`, and `fixed_items` takes every Act on line not ending in `ticket: #N` when `via` is `fix only after`, else #93's `fixed:` filter. Table A 5, 15.
6. The owed line prints at rounds one and two with no hole when an Act on item carries `fixed:`; `fixed_here` is computed above the block. Table B 7, 8.
7. Rounds four and five keep #93's strings, gate order and stickiness. Table A 15 to 18.
8. Prose: SKILL.md steps 1, 4 and 6 through the patch with `SOURCES.md` 4, 6 and 12; both babysit copies byte-identical; MANUAL, review-ladder, P20's title and amendment, P106; `no-stale-wording.sh` pins the replaced sentence over `template` and `docs/knowledge/core`, where no copy remains.
9. Tests: one assertion per cell of tables A and B, plus #93's 13B, 5C and 5D, in the tests-before-scripts commit order.

## Would break

## Fails open

## Not asked for

hard findings: 0

## Judgment

## Act on

## Ask

## Consider

1. [S1] **Duplicated Code: the fix-line rule is written twice, and the two copies differ.** One rule in two scripts is the design (the brief computes at the reviewed commit, the comment script stays free of git); the `+++` difference fails toward a whole-diff round, which the design keeps on purpose.
2. [S2] **`outside()` cannot tell "no fix corpus" from "nothing outside the fix".** With zero hard items the verdict is the ticket's condition whatever the fix files hold; a guard would name the reason but change no outcome.

## Noted

## Dismissed

Standards: 0 would break, 0 fail open, of 2; Spec: 0 would break, 0 fail open, of 0; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 2, noted 0, dismissed 0; fixed point 01a1e5f46891d10b234fe9ee80cbd9e8c67d4438.
reviewed: 0edf8c8952e7563ec862e460f71becde4506bd96
round: 1 of 3
act-on items: 0

Claude Opus 5.5 on Claude Code
