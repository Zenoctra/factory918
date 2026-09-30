# #139 fix round 3 report

The guard now counts any heading line of two or more `#` whose lowercased text holds `writer` and, later, `flag`, so possessive and plural spellings refuse. All verification passed, and the ticket sweep matched only #108's expected heading.

Branch: `wt/139-fix3`, from origin/feat/unreadable-writer-flags at bc5a7e6. Not pushed.

## Commits
- a68ef03: tests first. Adds D15 (`### Writer's flags 2026-09-23` / `1. bare`) and D16 (`### Writers flags 2026-09-23` / `1. a accepted: ok`), each expecting the `rz8` refusal naming that line. It also rewraps the suite's header comment so the #137 sentence stays within the block's width.
- f494d2b: script. The guard match in `template/.agents/skills/spec-review/scripts/review-brief.sh` over `tolower($0)` is now `^([ \t>]|[-*+]|[0-9]+[.)])*##+.*writer.*flag`. The comment states the rule: two or more `#`, after any spaces, `>` quote markers and list markers, and text holding `writer` with `flag` anywhere after it on the line, in any case.
- 42476d3 (head): SKILL.md step 1's #139 sentence now reads: "A ticket body that holds a line of two or more `#` whose text holds `writer` and, after it, `flag` (in any case, fenced, quoted or after a list marker) and from which no flag is read is refused the same way, naming each such line". The commit regenerates the patch with the `diff -u --label` command and rewords SOURCES.md patch 6's #139 clause to match ("a line of two or more `#` whose text holds `writer` and, after it, `flag`"). A new `has "$source_skill/SKILL.md"` assertion pins the sentence word for word, placed next to the existing step-4 pins.

## Failed before the script change
- D15: `FAIL (D15): exit 0, wanted 1, the refusal and no state`.
- D16, with D15 temporarily removed: `FAIL (D16): exit 0, wanted 1, the refusal and no state`.

## Verification (at 42476d3)
- `bash tests/spec-review/review-brief.sh`: ok 1872 assertions, exit 0. Every earlier cell keeps its outcome, including D12, C7/f and D9.
- ShellCheck over the full set, including `tests/*/*/*.sh`: 26 files checked, exit 0.
- `bash tests/spec-review/no-stale-wording.sh`: ok, exit 0.
- `bash tests/spec-review/review-comment.sh`: ok 298 assertions, exit 0.
- `./factory918.sh sync`: exit 0, and `git status --porcelain` afterwards is empty.
- `python3 tools/check_knowledge.py`: knowledge ok, 119 files, exit 0.

## The new match over live ticket bodies
Tickets #90 #93 #103 #105 #106 #107 #108 #109 #110 #111 #137 #139. The only matching line is `#108: ### Writer flags 2026-09-23`, which was expected. No other line matched.

## Act on (owner)
- Push `wt/139-fix3` to feat/unreadable-writer-flags. It is a fast-forward of bc5a7e6.
- The pinned SKILL.md sentence is new, and no reviewer has seen its wording. Read it once.
- Header lines 7 and 11 of the suite are 101 characters, from before this change. I left them as they are.

Claude Opus 5.5, Claude Code.
