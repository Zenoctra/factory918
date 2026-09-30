verdict: PASS+NOTES

Live runtime floor for PR #142 (ticket #139) at 30bdcae4913d0911e3aec2b2902611c2cf89c443.
`git merge-base --is-ancestor origin/main HEAD` exits 0; origin/main is 9846844d838403b8d0c0f9b4686852965dba6a40.

Method: a scratch `git init` repository per run under a private `mktemp -d`, laid out by
`tests/spec-review/layout.sh` (project form), `tests/spec-review/fake-gh.sh` copied onto PATH as
`gh`, the ticket body supplied through `FAKE_ISSUE_BODY`, and the skill's own
`scripts/review-brief.sh <fixed> --ticket 7` run against a non-cross-cutting two-commit diff.
Drivers: `.../scratchpad/drive.sh` (shape sweep) and `.../scratchpad/compare.sh` (main vs HEAD,
same input, same scratch repo shape), under this session's scratchpad directory.
Nothing was edited, commented on, merged or closed.

## (a) Shapes that hide the list from #136's check

33 shapes run live. Every one is refused with exit 1, no `.claude/state/review/` and no
`.scratch/review/<id>/`, except the five named under "passes" below.

Refused by #139's new guard (stderr `... has a writer flags heading and no flag could be read from
its body ...`, each offending line indented two spaces, in text order):

- unclosed fence above the heading (```` ```sh ```` opened, never closed) — `### Writer flags 2026-09-23`
- heading and list inside a closed ```` ```md ```` fence (#108's cell C6/f, which briefed on main)
- heading and list inside a closed `~~~md` fence
- blockquote `> ### Writer flags 2026-09-23`
- blockquote wrapping a fence, `> ``` ` then `> ### Writer flags ...`
- hyphenated `### Writer-flags 2026-09-23`
- singular `### Writer flag 2026-09-23`
- possessive `### Writer's flags 2026-09-23`, plural `### Writers flags 2026-09-23`
- bold `### **Writer flags** 2026-09-23`
- two spaces `### Writer  flags 2026-09-23`
- non-breaking space `### Writer flags 2026-09-23`
- no space after the hashes `###Writer flags 2026-09-23`
- trailing/leading text `### Round two Writer flags 2026-09-23`
- four-space indented and tab-indented headings (Markdown renders these as a code block)
- list-marker headings `- ### ...` and `1. ### ...`
- heading with no list under it at all
- CRLF body whose heading is fenced

Refused loudly by #136's pre-existing near-miss check instead (stderr `... has Writer flags without
a disposition ... not the heading `### Writer flags <YYYY-MM-DD>`: <line>`), which is the same
loud, state-free refusal: `## Writer flags 2026-09-23`, `#### ...`, `# ...`, `###### ...`,
`### Writer flags` (no date), `### WRITER FLAGS ...`, `### writer flags ...`, a setext
`Writer flags 2026-09-23` over `---`, `## Writer flags, conflicting`. A plain CRLF body with a
readable heading is read normally and refuses per flag (`no disposition: 1. flag one, unreadable`),
so `\r` is handled.

Passes (a list stays hidden and the brief is written) — five shapes, all outside the documented
rule, none an honest-mistake shape except possibly the third:

1. Unicode lookalike in the word: Cyrillic `е` in `### Writеr flags 2026-09-23`. exit 0, state written.
2. Zero-width space inside the word: `### Wr<U+200B>iter flags 2026-09-23`. exit 0.
3. Fullwidth hashes: `＃＃＃ Writer flags 2026-09-23`. exit 0. GitHub does not render this as a
   heading either, so the list is visibly not a list.
4. HTML comment: `<!-- ### Writer flags 2026-09-23 -->` over an unfenced list. exit 0. The author
   commented the heading out on purpose; the list below is then orphaned and unread.
5. Word order reversed: `### Flags from the writer 2026-09-23`, and non-hash decoration
   (`——— Writer flags 2026-09-23`). exit 0. `writer` before `flag` is the documented rule
   (P139, `review-brief.sh:447-450`).

1 and 2 need a deliberately pasted invisible or homoglyph character; they are evasion, not a shape
a writer reaches by accident. Nothing here is a regression: all five brief on main too.

Multiple hidden headings in one body are all named, in text order, two-space indented (verified
with a fenced `### Writer flags 2026-09-23`, a quoted `> ### Writer-flags 2026-09-24` and a bare
`## Writers flag things` in one body — three lines, one refusal).

## (b) False refusals across this repository's own tickets

`gh issue list --state all --limit 200 --json number` returns 99 tickets (1..141). All 99 bodies
were fetched and run through the script at this SHA.

**Wrongly refused by #139's guard: 0 of 99.**

- Applying the guard's own matcher to all 99 bodies, exactly one line in the whole corpus matches:
  `108.md:124: ### Writer flags 2026-09-23` — the real, readable list. The guard does not fire on it.
- Widening to any heading line mentioning `writer` **or** `flag` at all
  (`grep -icE '^ *#+ .*(writer|flag)'`): the same single line. No other ticket in the repository's
  history has a heading containing either word.
- The one refusal in the 99-body run is `108.md`, and it is #136's check, not #139's: the body's
  `fixed: d016a2e` and `fixed: 6e5c539` do not resolve inside the scratch repository. Both resolve
  in the real repository (`git cat-file -t` → `commit`), so #108 briefs there. Scratch-repo artifact.
- Ticket #139 itself, the meta-ticket that quotes `### Writer flags 2026-09-23` fifteen times, is
  **not** refused: every quote sits inside a table cell or backticks, so no line starts with hashes.

So the number Manuel needs is **zero realistic false positives in 99 tickets**. What the loose
match costs is future prose, and it is broader than the accepted example. Live, refused with no
list present:

- `## The writer should flag risks` (the owner's accepted case)
- `` ## How `Writer flags` are read `` — a heading a follow-up ticket about this very feature is
  likely to write
- `## Should the writer flag this?`
- `## The writer of the flagship module` — no flag concept at all; `flag` matched inside `flagship`
- `## Writerflag` (no separator)

Not refused (word order): `## Flags the writer raised`, `## Flags from the writer`. The cost of a
hit is one reworded heading, and the message names the one heading form that is read.

## (c) A body with no writer-flags heading: main vs HEAD

Same scratch-repo shape, same body, same fixed commit dates, skill trees taken with
`git archive origin/main` and `git archive 30bdcae`.

- Body with no heading and no list: exit 0 both. stderr empty both (0 bytes, identical).
  After replacing every 7-to-40 hex run with `<SHA>` (the two scratch repos necessarily have
  different commit ids, since their skill trees differ): stdout identical (102 bytes,
  md5 0a759f14c1c03d431210c4f285cac826), `standards-brief.md` identical (5420 bytes,
  md5 41cdeac6f1e6513297a1acc009071d28), `spec-brief.md` identical (3643 bytes,
  md5 927193351fef60aa16136ca04e0d543e). The only raw differences were the scratch repo's own
  commit id in `## Commits` and in the `.scratch/review/<id>/` paths.
- Body with a readable, settled list (`### Writer flags 2026-09-23` + one `accepted:` flag): the
  same, identical after normalisation (standards 5420, spec 3671 bytes).

Byte for byte, the briefs are unchanged.

## (d) Composition with #136, #106, #107, #137

- `bash tests/spec-review/review-brief.sh` → `ok 1872 assertions`, exit 0. It carries #136's tables
  A/B/C, #106's round-two and fix-only rounds, #107's reading pack, and #137's clean-brief
  assertions (both briefs' `## ` heading set at round two and fix-only, and the four "no count, cap
  or reading limit" `lacks` assertions on SKILL.md), alongside the new table D.
- `bash tests/spec-review/review-comment.sh` → `ok 298 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 76`. `bash tests/poteto-mode/overlap.sh` → `ok 57`.
  `bash tests/shellcheck/gate.sh` → `ok 17`.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh
  'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` →
  `ShellCheck 0.11.0, files checked: 24`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119`, `git status --porcelain` empty
  afterwards; `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`.
- On the diff itself: `git diff origin/main..30bdcae -- .../review-brief.sh` adds one guarded block
  at `template/.agents/skills/spec-review/scripts/review-brief.sh:442-452` and a comment; it adds no
  text to either brief and no new `printf` into a brief template. #137's rule (no text in a
  reviewer's brief that primes, caps or limits) is untouched by construction, and (c) proves it
  empirically.

## Issues

None. Every documented refusal fires loudly with exit 1 and leaves no review state, no false
refusal exists in 99 real ticket bodies, the no-heading path is byte-for-byte unchanged, and every
named check passes.

## Notes

1. **D10's hole is live and is the original bug at round two.** Confirmed with a body holding a
   settled `### Writer flags 2026-09-23` list followed by a fenced `### Writer flags 2026-09-24`
   with a bare line: exit 0, both briefs written, nothing said. The guard is "at least one flag read
   in the whole body", so once round one's list is readable, a round-two list hidden by a fence is
   silently ignored — exactly the failure #139 was filed against, one round later. P139 records this
   as accepted (`docs/knowledge/core/DECISIONS.md`, P139: "one readable list lets a second,
   unreadable one pass (table D, D10)"), and D10 is asserted in the test suite, so it is a stated
   limit, not a defect. Manuel may want to know that the accepted hole reopens the original failure
   mode on any ticket that has already settled one list — which is every ticket past round one.
2. Five shapes pass (a, "passes" list). Two are homoglyph/zero-width evasion, one is fullwidth
   hashes, one is an HTML-commented heading, one is reversed word order. None is a regression and
   all are consistent with P139's stated rule, but the DECISIONS row's phrase "any line of two or
   more `#`" does not warn that the two words must appear in order — the SKILL.md sentence the test
   pins does say "holds `writer` and, after it, `flag`", so the narrower statement exists.
3. The false-positive surface is wider than the accepted example implies: `## The writer of the
   flagship module` is refused because `flag` matches inside `flagship`. Zero such headings exist in
   99 tickets, so the practical cost today is nil.
4. The new awk uses `[ \t]` inside an ERE literal. This is the file's pre-existing idiom (12
   occurrences on origin/main), so it is not a new portability risk, but it was only exercised here
   under macOS BSD awk; no gawk or mawk is installed on this host, so CI's awk was not reached from
   this slice.
5. The guard reads the ticket **body** only, never the ticket author's comments (`spec` is set from
   `gh issue view --json body`). A flags list posted as a comment is invisible to both #136's check
   and #139's guard. Pre-existing to #136 and outside #139's scope; noted because a writer could
   reasonably post flags as a comment.
