# The blast-radius grounding inside spec-review's brief assembly

Paths are relative to the checkout root: `template/.agents/skills/spec-review/scripts/review-brief.sh` is `brief`, `.../review-comment.sh` is `comment`, plus `./SKILL.md` and `tests/spec-review/review-brief.sh` (`test`).

## Crossing, and where the grounding comes from

The predicate is a shell `case` over the changed-file list, one path per line, at brief:219-223: a path matching `*.claude/hooks/*`, `*.claude/settings.json` or `*.agents/skills/factory918/*` appends to `crossing`. The leading `*` is what makes one pattern cover a project's `.claude/hooks/` and the factory's `template/.claude/hooks/` copy; `layout.sh:12-13` sets `hooks` to each in turn and the suite runs twice (test:582-583). The predicate lives only here; `poteto-mode/playbooks/ticket.md:9` and `SKILL.md:27` restate it in words.

When `crossing` is non-empty the grounding is `cat` of `--blast-radius FILE` whole (brief:226-227), else the `## Blast Radius` section of the PR body (brief:229-231). The PR-body awk prints a line when `p` is set and the line is either fenced or not a `## ` heading, then lets the shared `fenced` fragment update `h`, then sets `p = (h == "Blast Radius")` on each `## ` line. So the section starts after its own heading line and ends at the next **level-2** heading, matched literally as `^## ` — `### Risks` does not match, and neither does a `## ` line inside a fence (test:553 pins the fenced case, test:554-555 the bounds). That is why the real hand-back survives a paste: PR #92's and PR #87's bodies demote the blast-radius skill's bullets (`blast-radius/SKILL.md:41-45`) to `### What it does`, `### Risks`, `### Cleared`, and the extractor keeps them. A grounding pasted with its own `## `-level headings would be truncated at the first one. `--blast-radius FILE` is not parsed at all, so a file with `## ` headings passes through intact.

Leading blank lines are stripped (`sed '/./,$!d'`, brief:233); an all-whitespace result counts as missing (brief:234). The refusal removes `$dir` and exits 1 before any state is written (brief:234-238), after the `ticket:` and `round:` lines have already gone to stdout — test:538-544 asserts exactly that stdout plus the message. `gh` failures here are swallowed (`2>/dev/null`), so a broken `gh` reads as "no grounding". A non-crossing diff with `--blast-radius` is a warning on stderr only (brief:239-241, test:574-575).

## Where it lands

`common()` emits, in order: the read-nothing sentence, `## Commits`, `## Changed files`, then `## Blast radius` when `grounding` is non-empty — the fixed paragraph `blast_rule` (brief:276) first, the grounding verbatim after (brief:289-296) — then `## Diff`, then `## Settled in earlier rounds`. The heading in the brief is lower-case `radius`; the PR-body heading it is matched from is `Blast Radius`, case-sensitive. Both briefs get it, because `common` is called from both (brief:330, 369). The test pins the paragraph in the two briefs and in the source `SKILL.md`, and pins the section before `## Diff` (test:116, 122, 522-530).

## The Walk bullet

It is a literal `echo` at brief:381, not a variable, unlike `definition`, `step_rule`, `spec_rule`, `blast_rule` and `count_rule`. `SKILL.md:101` carries the same sentence. The test holds them together through the `spec_bullets` array (test:163-168) asserted against `$source_skill/SKILL.md` — the repo's `template/` copy, not the temp one (`layout.sh:8`) — and against the generated Spec brief (test:173-176), plus `lacks "$std"` and a first-bullet check (test:177-179).

## Walk in review-comment.sh

`items()` (comment:59) is `h != "" && h != "Walk" && /^[0-9]+\. /`, so Walk lines are never items. Everything downstream is built on `items`: `count()` (60), `numbered()` (87-93), `specs()` (76-84), the judgment's `[S<n>]`/`[P<n>]` reference set (140-151) and the totals (127-129). A walk of forty lines therefore changes no count and no numbering; findings start again at 1 under `## Would break`. `shape()` still requires `Walk` as the Spec report's first heading (comment:126), so an absent Walk is refused while an empty one is fine.

## The shared fence rule

`fenced` is one awk fragment copied word for word between brief:122-128 and comment:44-50, together with the `ref=` line; test:483-490 extracts both from each script and compares them, so an edit to one alone fails. A fence opens on three or more backticks or tildes and closes only on the same character, at least as long, with no info string. Inside a fence, `## Risks` is text: it does not end the PR-body section, never becomes `h`, and in a report is neither a heading nor an item. Unfenced, `## Risks` ends the PR-body section; `### Risks` does neither, anywhere.

## Reusable in the test

`blast.md` (test:510-514, with a leading blank line that exercises the strip), `pr-body.md` (test:549, CRLF, a fenced `## ` line, a following `## Verification`), `pr-body-empty.md` (557), the `pr()` helper (34-38), `FAKE_PR_BODY` into `fake-gh.sh:15`, and `--previous`/`--round` everywhere above. Placement matters: the cross-cutting commit lands at test:507-509 and the README commit at 571-573, so `HEAD~1` is cross-cutting only between them. `bash tests/spec-review/review-brief.sh` currently prints `ok 414 assertions`; `n` accumulates across both suites, so one new assertion adds two.

## What a newcomer gets wrong

A finding misfiled under `## Walk` is silently dropped — no count, no reference, no refusal. The brief text is never parsed, only the reports are, so `## ` inside a grounding hurts the reader, not the pipeline. `--blast-radius` with a missing file is a bare `usage` (brief:36), not a message. And the wording assertions include line-offset checks (test:143-150): the spec rule must sit exactly two lines after the step rule and the count rule three after it, so inserting a paragraph between them fails the test even when every string is present.
