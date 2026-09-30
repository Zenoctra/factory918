verdict: PASS+NOTES

For a person: I drove the two scripts at this SHA against a scratch git repository with a real
history and a fake `gh`, and compared every round against the same run at the patch base. Round
three goes fix-only exactly when round two's hard findings all sit inside the fix commits, rounds
one, two, four and five are unchanged, and the four edges I could construct all fall toward
reviewing more, not less.

Setup: `git checkout --detach caecbc4` in this worktree; `git rev-parse HEAD` =
`caecbc448983e071d4289d252f515993c4978cbf`; `git merge-base --is-ancestor 01a1e5f HEAD` exit 0.
Private `TMPDIR`, scratch repositories under the session scratchpad, nothing written under version
control. Harness: `mk.sh` (a project-layout repo holding the skill of either SHA, `.gitignore`ing
`.scratch/` and `.claude/state/`, three commits, then fix commits), `flow.sh` (round 1 -> comment ->
fix commit -> round 2 -> comment -> round 3), `f.sh` (rounds four to six), `g.sh`, `h.sh`,
`cmp-comment.sh`, all under
`/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad/`.
`tests/spec-review/fake-gh.sh` copied onto PATH as `gh`; the fix commits produce
`fix-lines` = `beta line two`, `beta line two REPAIRED`, `epsilon added by the fix`.

- (a) Rounds one and two byte for byte, same repository and history, skill directory swapped
  between `caecbc4` and `01a1e5f` (`a.sh`). Round 1: stdout, stderr and `diff -r` over the whole
  `.scratch/review` tree IDENTICAL (exit 0 both). Round 2 (`--previous` a round-one comment
  carrying `reviewed: <r1head>`): stdout and stderr IDENTICAL, `diff -r` reports one difference,
  `Only in ...new.dir/<id>: fix-lines`. Both briefs (`standards-brief.md`, `spec-brief.md`) are
  byte identical at both rounds. Criterion 1 of the ticket holds at runtime, not only in the test.
- (a, extra) `review-comment.sh` at rounds one and two (`cmp-comment.sh`): the new output with the
  lines matching `^(next round owed:|reviewed: |fix only after )` deleted is byte identical to
  `01a1e5f`'s output on the same reports and judgment; exit 0. New-only lines at round 1:
  `next round owed: round 2 reviews the fixes marked here` + `reviewed: <sha>`; at round 2:
  `next round owed: round 3 reviews the fixes marked here` + `fix only after <sha>`.
- (b) Round two, one Standards Would-break item whose fenced hunk is `-beta line two` /
  `+beta line two REPAIRED` (both fix lines): the comment's last lines are
  `fix only after 1e129544218091bfbb7b26008e7fd3f8701e5163`, `round: 2 of 3`, `act-on items: 1`
  (exit 0). Round three from that commit: `round: 3 of 3` on stdout, `<dir>/round` = `3`,
  `## The fix under review` present once in `standards-brief.md`, carrying the fix paragraph and
  `1. [S1] **A hard one.** yes`; exit 0. The fixed point is round two's reviewed commit.
- (c) Same flow, round two's reports varied (`all.sh`):
  - hard item in unchanged code (hunk of two unmarked context lines that are not fix lines): no
    `fix only after` line; round three from the whole diff, `<dir>/round` = 3, no
    `## The fix under review` (grep -c = 0), exit 0.
  - Spec Would-break item quoting its ticket line (`- [ ] The brief carries the ticket body.`): no
    `fix only after` line; round three whole-diff, no fix section. Matches P106's accepted cost.
  - no hard items in either report: `fix only after <r2head>` printed; round three fix-only,
    `## The fix under review` present.
- (d) Edges of the inside rule, each run end to end:
  - false-inside (`+epsilon added by the fix` quoted with no file context, i.e. the same text
    elsewhere): counted inside, `fix only after` printed, round three fix-only. This is the
    owner's accepted false-inside and matches P106 as written (P106 names no location, only the
    line text).
  - hunk mixing a fix `+` line and a non-fix `+` line: outside, no `fix only after`, whole-diff
    round three. Matches P106 ("every `+` or `-` line it quotes is one").
  - context-only quote whose unmarked lines are fix lines: counted inside, `fix only after`
    printed, round three fix-only. Matches P106 as written ("one of its quoted fenced lines, less
    one `+`, `-` or space marker ... is a line the fix commits added or removed"); an unmarked line
    can be the hit, while an unmarked line that is not a fix line stays neutral.
    `docs/knowledge/core/DECISIONS.md:104`.
  - quote whose only marked lines are under four characters (`+fi`, `+}`): they count nothing, the
    item quotes no fix line, so it is outside and round three reads the whole diff. Matches P106.
  - added case: a hunk quoted with its `--- a/app.sh` / `+++ b/app.sh` headers around the two fix
    lines is outside, so no `fix only after`. See Notes.
- (e) Round three fix-only with the wrong fixed point: `review-brief.sh <base> --ticket 77
  --previous <two comments>` exits 1 with
  `review-brief: round 3 reviews only the fix from 07fc0fb2ba55823172858db7af72852ba7213a7c, the
  commit round 2 reviewed (the \`fix only after\` line of the last review comment);
  4f7285d00f3143602a0ec824398342646e2a12b2 is not that commit` — #102's message, naming the
  expected commit and the line it came from, and refusing before any state is written.
- (f) Rounds four and five after a Would-break fix (`f.sh`, both SHAs in the same repository):
  round 4 from the `would-break fixed after` commit — stdout (`round: 4 of 5`), stderr and
  `diff -r` over the review dir all IDENTICAL, exit 0 both; `## The fix under review` carries only
  the item marked `fixed:`. Round 5: `round: 5 of 5`, IDENTICAL, exit 0 both. Round 4 at a wrong
  fixed point: exit 1 both, same message. A sixth round: exit 1 both,
  `review-brief: five rounds were run on this PR; ...`. Nothing in #102's behaviour moved.
- (g) `review-comment.sh` owed line (`g.sh`, same reports, round file varied):
  - round 1, one Act on item marked `fixed:` -> `next round owed: round 2 reviews the fixes marked
    here`; without the mark, absent.
  - round 2, marked -> `next round owed: round 3 reviews the fixes marked here`; without the mark,
    absent.
  - round 3, marked or not -> absent.
  - round 1 with a `hole:` on an Act on item -> `restart` and no owed line; the hole outranks it.
  - Both babysit copies carry the sentence that reads the line word for word, once each
    (`template/.agents/skills/babysit/SKILL.md:40` and
    `template/.agents/skills/poteto-mode/playbooks/babysit.md:16`), checked as a fixed string.
- (h) Restart (`h.sh`): a history of round 1 (`reviewed:`), round 2 (`fix only after <c1>`) and a
  comment holding `restart` -> the next brief prints `restart: the round and the settled items
  count from the last restart comment` and `round: 1 of 3`, `<dir>/round` = 1, no `fix-lines`
  written; the stale `fix only after` grants nothing. Adding a fresh round-one comment
  (`reviewed: <c1>`) gives `round: 2 of 3` and a `fix-lines` file holding only the post-restart
  line `zeta added after the restart`; adding a fresh round-two comment with
  `fix only after <c2>` gives `round: 3 of 3` from `<c2>` with `## The fix under review` present.
  The round-three logic starts over from zero.
- Repo suites at this SHA: `bash tests/spec-review/review-brief.sh` -> `ok 986 assertions`, exit 0;
  `bash tests/spec-review/review-comment.sh` -> `ok 264 assertions`, exit 0.

## Issues

(none)

## Notes

- A Would-break item that quotes a full diff block including the `--- a/<file>` and `+++ b/<file>`
  headers is judged outside even when every real changed line is a fix line: `outside()` strips one
  leading marker, so `--- a/app.sh` becomes `-- a/app.sh`, a marked line that is not a fix line, and
  `ok` is cleared (`template/.agents/skills/spec-review/scripts/review-comment.sh:246`). The
  briefs only say "quote the hunk", so a reviewer who pastes headers silently costs the PR its
  fix-only round three. The bias is toward reviewing more, which is what P106 asks for, so this is
  a note and not a finding.
- At round three the fix section carries every Act on item not marked `ticket:`, so a round two
  with no Act on items at all still gets `## The fix under review` with the paragraph and an empty
  list. Reachable only if a round three is run after a round two that was already review-ready
  (`act-on items: 0`), so it costs nothing in the documented flow.
- A round-two comment can carry both `next round owed: round 3 reviews the fixes marked here` and
  `fix only after <sha>`. Babysit's sentence covers it ("the lines `reviewed: <sha>` and `fix only
  after <sha>` only record where the next round starts"), so a reader is not left guessing.
- `fix-lines` is written only when `round == 2 && top == 1` and the `reviewed:` sha is an ancestor
  of HEAD; when it is missing, `outside()` reads the empty set, so any item quoting code is outside
  and only a round with no hard items at all can be fix-only. That is the safe direction.
