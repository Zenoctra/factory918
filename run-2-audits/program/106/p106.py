import sys
p = sys.argv[1]
lines = open(p).read().split("\n")
idx = [i for i, l in enumerate(lines) if l.startswith("| P106 |")]
assert len(idx) == 1
lines[idx[0]] = ("| P106 | Where a round-two finding sits | A hard item is inside round two's fix only when it quotes at least one `+` line of four characters or more, every `+` or `-` line of four or more it quotes is a `+` line whose text the fix commits added and occurs exactly once across the HEAD versions of the files round two reviewed (`<dir>/fix-lines`), and every `path:N` or `path:N-M` in its unfenced lines, its `Documented step:` included, names exactly one of those files at lines inside one new-side range of the fix commits (`<dir>/fix-ranges`). Unmarked quoted lines decide nothing, so a plain-code quote is outside; a removed line is never a fix line; every other case is outside, so round three reviews the whole diff "
    "| Manuel on #106: \"wait until a review came back only with hard findings on fixes\" and \"at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews\". The round-one and round-two briefs must stay byte for byte (criterion 1), so no report rule could ask for a code location; the reviewer's quoted hunk and the `file:line` it names are the locations every report already carries. Amended 2026-09-23 by #125 (review round 1, a design hole found by the root's audit verifier): the first rule counted an unmarked quoted line that equalled a fix line, so a plain quote of untouched code sharing `exit 0` or `else` with the fix read as inside and round three would have skipped it. Rejected: an `at: <path>:<line>` field on the judgment (the orchestrator's word, and the hook bars it from the reviewed files); any unmarked line counting; removed lines as identifying (a removal by round one's code cannot be told apart); uniqueness across the whole tree (adds the corpus, catches nothing); fix-only only when round two reports no hard item (drops cells beyond the hole; the corpus gives the same verdict, so a follow-up ticket if Manuel agrees). Of the 13 hard items in `tests/eval/reviewer/rounds/`, none would read inside: fix-only in practice means round two found no hard bug. #106, 2026-09-23. |")
open(p, "w").write("\n".join(lines))
t = open(p).read()
old = "`<dir>/fix-lines` (the lines the commits after round one's `reviewed: <sha>` changed)"
assert t.count(old) == 1
t = t.replace(old, "`<dir>/fix-lines` and `<dir>/fix-ranges` (what the commits after round one's `reviewed: <sha>` added, and where; P106)")
open(p, "w").write(t)
