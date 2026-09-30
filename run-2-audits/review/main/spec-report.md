## Walk

1. `review-brief.sh <fixed-point> --ticket N` ends each brief with `report_rules()`: `## Report`, the definition verbatim, then Manuel's five attributed sentences two lines below it, then the shape sentence.
2. The Standards brief then lists `## Would break`, `## Fails open`, `## Standards breaches`, `## Fix alongside`; the Spec brief lists `## Walk`, `## Would break`, `## Fails open`, `## Not asked for`. Each then prints `$step_rule`, the report path and `$count_rule` naming both counted headings.
3. The reviewer writes its report. `review-comment.sh`'s `shape()` demands those headings in that order; `items()` now drops any heading named `Walk`, so `count()`, `numbered()` and the `[P<n>]` set all start at the first `## Would break` item (P23).
4. `report()` compares `hard findings: N` against Would break plus Fails open, then runs `stepless()`, which reports the first counted item with no `Documented step:` line before the next item or heading, fenced hunks excluded, and refuses by heading and item title.
5. The summary prints `N would break, M fail open, of T` for each axis; `round:` and `act-on items:` are untouched.
6. `tests/spec-review/review-brief.sh` and `review-comment.sh` each wrap their assertions in `suite()` and call it for `project` and `factory`. `layout.sh` builds each repo with `.agents/skills/spec-review`, `.claude/hooks` and a `.claude/skills` symlink, at the root or under `template/`; `$hooks` is what the cross-cutting commit touches, and review-brief.sh's `*.claude/hooks/*` glob matches both.
7. CI gains `no-stale-wording.sh` (greps `template` and `docs/knowledge/core` for `## Latent` and the retired definition sentence), and the fixture flow commits `vp create`'s output, applies the factory, commits, then runs `review-brief.sh HEAD~1 --ticket 1 --blast-radius` with `tests/spec-review/fake-gh.sh` on PATH and asserts both briefs, the definition, `` `## Fails open` ``, no `## Latent`, and the walk only in the Spec brief.
8. `DECISIONS.md` P18 (amended) and new P23, in the core copy and the template copy, plus `review-ladder.md` rung 1 and the judgment's `## Act on`, name the two counted kinds in the definition's own words; `INDEX.md` and the `<!-- lines: -->` header record 91.

## Would break

## Fails open

## Not asked for

hard findings: 0
