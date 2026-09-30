# spec-review: rounds, judgment marks and carry-forward, end to end

Grounding for the #90 design runners. All paths are relative to the worktree root
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a7e863dda12fb2374`.
Line numbers are as they stand on `feat/design-hole-restart` (HEAD `ab47eb9`). Every quoted string below
was checked against the file, not taken from the explorer notes alone.

### Overview

`spec-review` is a six-step skill whose two ends are shell scripts and whose middle is three sub-agents
(a Standards reviewer, a Spec reviewer, and the orchestrator acting as judge). Step 1 runs
`review-brief.sh`, which reads the PR's earlier review comments, derives the round number, decides what
carries forward as settled, and writes two briefs into `.scratch/review/<id>/`. Steps 2–5 are prose: the
two reviewers write `standards-report.md` and `spec-report.md`; the orchestrator writes `judgment.md`.
Step 6 runs `review-comment.sh`, which validates all three files against a fixed shape, refuses anything
off-shape, and prints the review comment the orchestrator posts on the PR.

The system has no database. **The PR's own comment history is the only memory.** The round number is
recomputed from the comments on every run; the settled-item list is recomputed from the comments on every
run; `.scratch/review/<id>` is `rm -rf`'d and rebuilt each time (`review-brief.sh:163`). The only durable
state is `.claude/state/review/`, which exists purely to tell the delegation hook that a review is in
flight, and `review-comment.sh` deletes it when it finishes.

Two lines of the printed comment close the loop: `round: N of 3` feeds the next run's round arithmetic,
and `act-on items: N` is what babysit, the review ladder and the MANUAL read to decide whether the PR is
merge-ready. Four prose surfaces restate this contract in words, and a drift test forces several of the
strings emitted by the script to appear verbatim in `SKILL.md`.

```
 PR comments ──gh pr view──▶ review-brief.sh ──▶ .scratch/review/<id>/{briefs,round,diff,…}
   ▲   (author's only,             │                            │
   │    must carry an              │ writes                     │ reviewers write *-report.md
   │    `act-on items:` line)      ▼                            │ orchestrator writes judgment.md
   │                       .claude/state/review/{dir,files,      ▼
   │                                fixed-point}  ──▶ review-comment.sh ──▶ stdout: the comment
   │                          (read by delegation.sh, mode.sh)   │   (clears .claude/state/review)
   └────────── orchestrator posts the comment ───────────────────┘
                                    │
                                    └─ last line `act-on items: N` ──▶ babysit / review-ladder / MANUAL
```

### Key Concepts

**Round.** A number from 1 to 3, derived — never stored between runs. A round is over when its comment is
posted. `SKILL.md:25` states the rule; `review-brief.sh:128-145` implements it.

**Fixed point.** The commit/branch/tag the diff is taken against. It becomes the review dir's id
(`review-brief.sh:59`: `id="$(printf '%s' "$fixed" | tr -c 'A-Za-z0-9._-' '_')"`, which is why `HEAD~1`
becomes `.scratch/review/HEAD_1`).

**The two axes.** Standards (does the code follow this repo's documented standards?) and Spec (does it
match the originating ticket?). The Spec axis only exists when a ticket was inferred or passed and `gh`
returned a body; otherwise step 6 prints `no spec: Standards axis only`.

**Hard finding.** Defined once, in the shell variable `definition` at `review-brief.sh:232`, emitted into
both briefs and repeated word for word at `SKILL.md:77` and in rung 1 of the ladder:

> A hard finding is one of two things: the documented path gives a wrong or silent result, or an input
> outside it proceeds silently (fails open). An input outside the documented path that is refused with a
> message saying how to correct it is not a finding; it is the design. Zero items is the expected result
> for a clean change.

**Report items vs. judgment items.** A report item is one line matching `^[0-9]+\. ` under a `## ` heading
that is not `Walk`; its continuation lines (`Documented step:`, `Result:`) are not items. Items are
numbered continuously 1..N across the headings of that report, in document order. A judgment item opens
`N. [S2] **Title.** reason`, where `[S2]` names the Standards report's second item.

**The three trailing fields.** `SKILL.md:130` introduces them: "Three trailing fields, each with one
grammar:". They are `cites:` (Noted/Dismissed, `SKILL.md:132`), `ticket: #N` (Act on, `:133`) and
`fixed: <sha>` (Act on, `:134`). Each is trailing text on the item's own single line, anchored at end of
line. `ticket:` and `fixed:` are read by `review-comment.sh`; `cites:` is read only by `review-brief.sh`.

**Settled.** A Noted or Dismissed item whose `cites:` field matches the grammar. Settled items are pasted
verbatim into both briefs of every later round under `## Settled in earlier rounds`, so a decision made in
round one still reaches round three.

**The count.** `act-on items: N`, the last printed line, where
`N = |Act on| − |Act on with fixed:| − |Act on with ticket:| + |Ask|`.

### How It Works

#### 1. Deriving the round from the PR's comments

`review-brief.sh:82-107` fetches the earlier comments. With `--previous FILE` it just reads the file
(`:91-92`); otherwise it runs one jq program through `gh` (`:94`):

```
ended='.author.login as $a | [.comments[] | select(.author.login == $a and (.body | test("(^|\n)act-on items:")))] | .[] | .body, ""'
```

Two filters and one separator, all load-bearing:

- **Author.** Only comments by the PR's author (the account the orchestrator posts under) survive. A
  stranger's comment can neither advance a round nor carry an item. The comment block at `:82-88` states
  this as the rule.
- **`act-on items:`.** The body must contain a line starting `act-on items:`. A comment that is not a
  finished review comment is invisible to this whole subsystem.
- **Separator.** Each qualifying body is emitted, then a line holding only US-ASCII 30 (`rs` at `:89`).

`gh` failures are handled at `:100-105`: `*"no pull requests found"*` is silent (round 1, nothing
carried); any other failure prints `review-brief: gh could not read the PR's review comments (<err>);
round 1 unless --round says otherwise, nothing carried` on stderr and the run continues.

Parsing uses two awk fragments concatenated as `"$split$fenced"`. `split` (`:116-119`) strips CR and
trailing blanks, and on the separator line resets `fence`, `h`, `j` and the per-comment round `r`, folding
`r` into `top`. It deliberately does **not** reset `seen[]` — that asymmetry is what makes carry-forward
"each distinct line once" across comments. `fenced` (`:120-126`) is CommonMark-ish fence tracking plus
`^## ` heading capture; it is **byte-identical** to `review-comment.sh:41-47`, and the duplication is
enforced by `tests/spec-review/review-brief.sh:341-347`.

The round itself is `review-brief.sh:128-145`:

```sh
top=0
if [ -n "$bodies" ]; then
  top="$(printf '%s\n' "$bodies" | awk -v sep="$rs" "$split$fenced"'
    BEGIN { r = 1 }
    /^round: [0-9]+ of 3$/ { r = substr($0, 8) + 0 }
    END { if (r > top) top = r; print top }
  ')"
fi
[ -n "$round" ] || round=$((top + 1))
if [ "$round" -gt 3 ]; then
  echo "review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked \`fixed: <sha>\`, not reviewed in a fourth round" >&2
  exit 1
fi
[ -z "$ticket" ] || echo "ticket: #$ticket"
echo "round: $round of 3"
```

Facts a design has to respect:

- The regex `^round: [0-9]+ of 3$` is anchored both ends; `substr($0, 8)` drops the seven characters of
  `round: `; `+ 0` numifies. Inside one comment the **last** matching line wins (`r` is overwritten), so a
  quoted earlier `round:` line before the comment's own is harmless. Across comments `top` is the max.
- `BEGIN { r = 1 }` means a comment with no `round:` line counts as round 1. Therefore **any** qualifying
  comment forces `top >= 1`, and the computed round is ≥ 2 whenever `bodies` is non-empty. There is no way
  to compute round 1 once one review comment exists, except `--round`.
- `--round N` (parsed at `:33`, validated `[ "$round" -gt 0 ]`) overrides the computation entirely. It has
  no upper bound at parse time; `--round 4` is caught by the gate above.
- The three-round refusal fires **before** anything is written to stdout and before `.scratch/review/<id>`
  or `.claude/state/review` are created. That "no state written" property is asserted by the test.
- `<dir>/round` is written later, at `:217`, purely so `review-comment.sh` can echo it back. It is not a
  counter; the dir is destroyed at `:163` on every run.

#### 2. Carry-forward: the `cites:` grammar and the settled section

`review-brief.sh:146-161`:

```sh
cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2})$'
settled=""
if [ -n "$bodies" ]; then
  judged="$(printf '%s\n' "$bodies" | awk -v sep="$rs" "$split$fenced"'
    /^## / { if (h == "Judgment") j = 1; next }
    j && (h == "Noted" || h == "Dismissed") && /^[0-9]+\. / && !seen[$0]++
  ')"
  settled="$(printf '%s\n' "$judged" | grep -E -- "$cites" || true)"
  carried="$(printf '%s' "$settled" | grep -c . || true)"
  echo "settled: carried $carried, dropped $(( $(printf '%s' "$judged" | grep -c . || true) - carried )) without a citation"
fi
```

Three citation forms, each anchored to end of line: `user: "<words>" on #N`, `DECISIONS.md <row>` where a
row is `[A-Z]?[0-9]+` (so both `P17` and `19`), and `#N comment YYYY-MM-DD`. The same three, restated in
prose, are `SKILL.md:132`. Note `grep -E --` : the `--` matters because the pattern starts with a word but
the flag discipline is already there.

The `judged` awk collects, from every comment, the numbered item lines under `## Noted` and `## Dismissed`
**after** a `## Judgment` heading has been seen. `!seen[$0]++` dedupes by whole line across all comments,
so a comment rebuilt in the same round repeats nothing — and, as a consequence, an item whose wording
changed even slightly (including renumbering `1.` → `2.`) carries as a second line. Fenced text is never
an item, so a quoted review hunk containing `## Noted` and `1. … cites: …` lines is inert.

The printed line is exactly `settled: carried <C>, dropped <D> without a citation`, with
`D = |judged| − C`, printed whenever `bodies` is non-empty, including when both are 0.

The section itself is written by `common()` at `review-brief.sh:273-280`, into **both** briefs and only
when `settled` is non-empty, positioned **after `## Diff`** (i.e. after a possibly 500-line fenced diff):

```
## Settled in earlier rounds

These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm.

<the settled lines, verbatim, in comment order>
```

`SKILL.md:76` carries that paragraph word for word and adds the reason: "The section tells a reviewer what
is closed, never what to find: a brief that named an expected result would be leading the witness."

#### 3. The `## Report` block written into both briefs

Five shared strings are defined once, at `review-brief.sh:232-243`, and each appears word for word in
`SKILL.md` step 4 — the drift is what the brief test pins.

- `definition` (`:232`) — quoted under Key Concepts above.
- `quotes` (`:233-239`) — Manuel's five sentences, in this exact order:
  ```
  - Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
  - Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
  - Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
  - Manuel: "An edge case outside the intended path being unsupported is not a flag."
  - Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."
  ```
- `step_rule` (`:240`), the **only per-item extra-line rule today**:
  > Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the
  > ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what
  > happens instead; an item without its `Documented step:` line is sent back.
- `blast_rule` (`:242`) — the blast-radius grounding paragraph.
- `count_rule` (`:243`):
  > End the report with exactly one line `hard findings: N`, where N is the number of items under
  > `## Would break` and `## Fails open` and nothing else.

`report_rules()` (`:283-292`) emits, in order: `## Report`, blank, `$definition`, blank, the five quotes,
blank, the sentence "Write the report as Markdown with exactly these `## ` headings, in this order, each
holding numbered items or nothing:", blank. Both briefs call it.

The **Standards brief** then emits its four heading bullets (`:317-320`): `## Would break`,
`## Fails open`, `## Standards breaches`, `## Fix alongside` — the last with "they never count". Then the
item-form sentence (`:322`, naming `[S3]`), blank, `$step_rule` (`:324`), blank, the report-path line
(`:326`) and `$count_rule` (`:327`) — those last two with **no blank line between them**. The block closes
into `$dir/standards-brief.md` at `:328`.

The **Spec brief** (`:329-356`, only when a spec exists) has the same `report_rules()` call (`:344`), then
four bullets (`:345-348`): `## Walk` ("A walk, not findings: its lines are numbered 1..K on their own and
count nothing"), `## Would break`, `## Fails open`, `## Not asked for`; then the Spec item-form sentence
(`:350`, naming `[P3]`), blank, `$step_rule` (`:352`), the report-path line (`:354`) and `$count_rule`
(`:355`).

The structural point for #90: **`step_rule` is one shell variable emitted at two call sites**
(`:324`, `:352`), each time immediately after the axis's item-form sentence and immediately before the
report-path line, and it has one word-for-word twin in `SKILL.md:84` (which carries both the step rule and
the count rule inside one sentence, introduced "then the step rule, word for word: …").

`common()` (`:244-282`) lays out the rest of both briefs in this order: the "Read nothing beyond this
brief…" sentence → `## Commits` → `## Changed files` → `## Blast radius` (conditional) → `## Diff` (inline
in a ```diff fence when the diff is under 500 lines, otherwise a pointer sentence) → `## Settled in
earlier rounds` (conditional).

#### 4. The judgment grammar and the three trailing fields

Step 5 (`SKILL.md:112-134`) sorts every report item into exactly one of `## Act on`, `## Ask`,
`## Consider`, `## Noted`, `## Dismissed`, numbered 1..N continuously across the five headings. Each item
is `1. [S2] **Title.** reason`.

- `cites:` is Noted/Dismissed only, three grammars, and is the *settled* mechanism. "An item you cannot
  cite is not settled, however sure you are." (`SKILL.md:132`)
- `ticket: #N` is Act on only: the finding is outside this PR's scope, filed as its own ticket, not
  counted (`:133`).
- `fixed: <sha>` is Act on only, not counted; at round three the remaining Act on items are fixed on the
  PR by a fix lane and marked with the commit (`:134`). "An Ask item is never fixed or filed away; it
  waits for the human."

An answered Ask is re-sorted and `review-comment.sh` rerun on the same reports — "that is the same round,
not a new one" (`SKILL.md:128`).

#### 5. `review-comment.sh`: parse, refusals, count, layout

`review-comment.sh` is 159 lines. `set -euo pipefail` at `:16`; `cd` to the repo root at `:17-18`;
`state=.claude/state/review` at `:19`; `fail() { echo "review-comment: $*" >&2; exit 1; }` at `:20`. Every
refusal is a single stderr line prefixed `review-comment: `, exit 1, emitted before any stdout and before
the state is touched.

The dir comes either from `$1`, normalized (trailing slashes stripped `:24`, an absolute path under the
root made relative `:25`, a leading `./` stripped `:26`) or from `$state/dir` (`:29-30`). Normalization is
what makes the state-equality check at `:159` work for all three spellings.

The parser (`:41-51`) is the shared `fenced` fragment plus three helpers:

- `headings()` (`:48`) — the `## ` headings in order.
- `items()` (`:50`) — `/^## / { next } h != "" && h != "Walk" && /^[0-9]+\. / && (want == "" || h == want)`.
  **An item is exactly one line.** Continuation lines are never items; `## Walk` is excluded
  unconditionally, so the Spec walk is neither counted, numbered nor judged.
- `count()` (`:51`) — `items | wc -l`.

Three structural checks:

- `stepless()` (`:54-62`) — an awk `flush()` that, on each new item line or heading or EOF, prints
  `"<heading>: <item line>"` for the first `## Would break` / `## Fails open` item that saw no
  `^Documented step:` line before the next item or heading, then `exit`s. Only one offender is ever named
  per run. Fenced lines are excluded, so a `Documented step:` inside a quoted hunk does not satisfy it.
  **This is the existing template for "a counted item carries an extra line".**
- `numbered()` (`:65-71`) — reads `items "$f"` and compares `${line%%.*}` to a running counter.
- `shape()` (`:73-78`) — `headings` must equal the expected list exactly, in order.

`report()` (`:81-92`) composes them: shape, numbering, the count line
(`grep -E '^hard findings: [0-9]+$' "$f" | tail -1` — the **last** such line wins, and this grep is *not*
fence-aware), the one-sided ceiling check `[ "$n" -le $((wb + fo)) ]`, then `stepless`.

Reports are read at `:94-107`: Standards is mandatory, shape
`"Would break" "Fails open" "Standards breaches" "Fix alongside"`; Spec is conditional on
`$dir/spec-brief.md` existing (`:100`), shape `"Walk" "Would break" "Fails open" "Not asked for"`.

The judgment is read at `:109-127`: existence, shape
`"Act on" "Ask" "Consider" "Noted" "Dismissed"`, numbering, the item-count identity
`[ "$j_total" -eq $((s_total + p_total)) ]` (`:113`), per-item reference extraction with
`sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p'` (`:117` — the reference must come immediately after
`N. `), and a sorted set comparison against the generated `S1..Ss P1..Pp` (`:121-126`), whose failure names
`missing` and `unknown or repeated` via `comm`.

Round handling is `:128-132`: default 1; if `$dir/round` exists it is read and checked
`[ "$round" -gt 0 ] 2>/dev/null` or it fails with
`$dir/round holds '<text>', not a round number; rerun scripts/review-brief.sh`.

Every refusal, in source order:

| Line | Condition | Message (after the `review-comment: ` prefix) |
|---|---|---|
| 27 | argument is not a directory | `<dir> is not a directory; pass the .scratch/review/<id> review-brief.sh wrote` |
| 29 | no argument and no `$state/dir` | `no review in progress (.claude/state/review/dir is missing); run scripts/review-brief.sh first, or pass the review dir to rerun a finished review` |
| 69 | numbering not 1..N | `<f> item '<line>' is numbered <k> where <i> was expected; number the items 1..N continuously across the headings, in document order` |
| 77 | headings off shape | `<f> has the headings [a\|b]; the shape is [w\|x\|y\|z], in that order, each holding numbered items or nothing` |
| 85 | no `hard findings: N` line | `<f> has no 'hard findings: N' line; ask the reviewer for it` |
| 89 | count above Would break + Fails open | `<f> says 'hard findings: <n>' but has <wb> items under '## Would break' and <fo> under '## Fails open'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount` |
| 91 | hard item with no `Documented step:` | `<f> item '<N. **Title.**>' under '## <heading>' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both` |
| 94 | missing Standards report | `<dir>/standards-report.md is missing; wait for the Standards reviewer` |
| 101 | spec brief present, no Spec report | `<dir>/spec-report.md is missing; wait for the Spec reviewer` |
| 109 | missing judgment | `<dir>/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun` |
| 113 | item-count mismatch | `<dir>/judgment.md has <j> items; the reports have <s+p> (Standards <s>, Spec <p>). Every report item appears exactly once in the judgment` |
| 118 | item without `[S<n>]`/`[P<n>]` | `<dir>/judgment.md item '<line>' does not open with [S<n>] or [P<n>], the report item it judges` |
| 126 | reference-set mismatch | `<dir>/judgment.md does not name every report item exactly once: missing [<list\|none>], unknown or repeated [<list\|none>]; the reports have <s> Standards items and <p> Spec items` |
| 131 | `<dir>/round` holds no number | `<dir>/round holds '<text>', not a round number; rerun scripts/review-brief.sh` |

`SKILL.md:140` enumerates the same list in prose, in one sentence.

Output, `:134-158`, in exactly this order: `## Standards`, blank, the Standards report verbatim, blank,
`## Spec`, blank, the Spec report verbatim or `no spec: Standards axis only`, blank, `## Judgment`, blank,
the judgment verbatim, blank, the summary line, then:

```sh
act="$(count "$dir/judgment.md" "Act on")"
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
ask="$(count "$dir/judgment.md" "Ask")"
…
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed + ask))"
```

So `fixed:` and `ticket:` are `$`-anchored trailing text on an item's own single line, read only under
`## Act on`; at most one can match a line. `cites:` is **not read here at all** — inside the judgment it is
opaque text passed through verbatim; only `review-brief.sh:151` validates its grammar.

**The "last line is act-on items" contract.** `:158` is the last `echo`; nothing prints after it. Three
prose surfaces state it:

- `SKILL.md:138`: "…and the final line `act-on items: N`, where N is the number of items under `## Act on`
  without a `fixed:` or `ticket:` field plus the number under `## Ask`; then it clears
  `.claude/state/review/`. Zero is written as `act-on items: 0`. Babysit reads this line, so it is always
  present and always last."
- `template/docs/agents/review-ladder.md:6`: "The report is posted as a comment on the PR, names the commit
  it reviewed, and ends with the lines `round: N of 3` and `act-on items: N`."
- `template/.agents/skills/poteto-mode/playbooks/babysit.md:16` and
  `template/.agents/skills/babysit/SKILL.md:40`, both of which read only `act-on items: 0`.

`docs/knowledge/core/MANUAL.md:103` (generated twin `template/docs/factory918/MANUAL.md:84`) states the
human's readiness test the same way: "`spec-review`'s last line on the latest commit reads
`act-on items: 0`".

The two merge-ready sentences, verbatim. `babysit.md:16`:

> Merge-ready also needs the `spec-review` comment on the PR's latest commit to read `act-on items: 0`. A
> nonzero count, or no review comment on the latest commit, is a blocker of the same class as a red check,
> and the fix lands on this PR. Step 4's follow-up PR is not the route for it unless the reviewed PR has
> already merged. The review runs at most three rounds on one PR; a comment reading `round: 3 of 3` and
> `act-on items: 0` makes the PR review-ready even when the fix commits it names come after the reviewed
> commit. An item under `## Ask` in that comment waits for the human and is not fixed on the PR; once the
> human answers, the orchestrator re-sorts it in the judgment with the answer as its reason and reruns
> `scripts/review-comment.sh <dir>` on the same reports, which is the same round.

`babysit/SKILL.md:40` is the same sentence set as the first bullet of step 4 ("When to stop"), opening
"- Build is green, every comment resolved, the `spec-review` comment on the latest commit reads
`act-on items: 0`, branch merges cleanly → call it ready." Watch out: the adjacent `babysit/SKILL.md:41` is
a *different*, upstream three-round rule about CI fix → push → recheck cycles. Only `:40` is in scope.

Rung 1 of the ladder, `template/docs/agents/review-ladder.md:6`, is one long bullet; the round-relevant
part reads:

> The report is posted as a comment on the PR, names the commit it reviewed, and ends with the lines
> `round: N of 3` and `act-on items: N`. One PR gets at most three rounds, and the review stops earlier at
> `act-on items: 0`; a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready
> even when the fix commits it names come after the reviewed commit. An Ask item waits for the human.
> Fixes land on the PR that was reviewed, never on a PR above it. […] A finding outside the PR's scope
> becomes a ticket, not a commit here.

It also carries the hard-finding definition in its own words ("the documented path gives a wrong or silent
result, or an input outside it proceeds silently (fails open)…").

#### 6. `.claude/state/review/` and `.scratch/review/<id>/`

`review-brief.sh:210-217` wipes and rebuilds `.claude/state/review/` with three files: `fixed-point`,
`files` (copied from `$dir/files`) and `dir` (holding the `$dir` path). It is read by
`template/.claude/hooks/delegation.sh:27,76,98` — which blocks the orchestrator from reading the files
under review — and by `template/.claude/hooks/mode.sh:32-34` for the REVIEW status line.
`review-comment.sh:159` clears it, but only when it names this dir:

```sh
if [ -f "$state/dir" ] && [ "$(cat "$state/dir")" = "$dir" ]; then rm -rf "$state"; fi
```

so rerunning an old review while a newer one is in flight prints the old comment and leaves the newer
state intact. The whole `$state` directory is removed, not just `dir` — that is what unblocks the hook.

The review dir, `.scratch/review/<id>/`, is `rm -rf`'d and recreated at `review-brief.sh:162-164` and holds
`diff`, `stat`, `log`, `files` (`:166-174`), `fixed-point` and `round` (`:216-217`), `ticket.md` (`:223`),
`standards-brief.md` (`:328`) and `spec-brief.md` (`:356`). The reviewers add `standards-report.md` and
`spec-report.md`; the orchestrator adds `judgment.md`.

Ordering matters: the empty-diff refusal (`:176-180`) and the cross-cutting/blast-radius refusal
(`:202-206`) both `rm -rf "$dir"` and exit before the state is written, so a refusal leaves nothing behind.
But note the asymmetry — the three-round refusal fires before *any* stdout, while the cross-cutting
refusal fires *after* `ticket:` and `round:` are already printed. The tests pin both.

#### 7. How the tests are written

Both tests build a throwaway git repo through `tests/spec-review/layout.sh` (27 lines, sourced, no
shebang), which copies `template/.agents/skills/spec-review` into either a **project** layout
(`.agents/skills/spec-review/`, `.claude/hooks/`, `.claude/skills -> ../.agents/skills`) or a **factory**
layout (the same under `template/`), then `git init` and commit. Each test defines one `suite()` and calls
it twice, `suite project` and `suite factory`, so the scripts are proven identical under both layouts.
Neither script reads its own location; both use `git rev-parse --show-toplevel`.

**`tests/spec-review/review-brief.sh`** (441 lines, prints `ok 334 assertions`, 167 per layout). Its
helpers: `pr <author> [login:file …]` (`:30-34`) writes a `pr.json` consumed by the fake `gh`;
`has`/`lacks` (`:37-52`) are `grep -qF --` assertions; `printed` (`:54-59`) is exact stdout equality;
`quoting` (`:311-322`) splices a hunk under a cited item to prove fence edge cases;
`fragment()` (`:342`) extracts the `fenced='…'` block from each script and compares the two copies
(`:343-347`). `tests/spec-review/fake-gh.sh` (24 lines) is put on `PATH` as `gh`; crucially, for
`pr view*` it runs **the script's own jq program** over `pr.json`, so the author filter and the
`act-on items:` filter are what is under test, not a stub.

One case, verbatim (`tests/spec-review/review-brief.sh:222-237`), which pins the settled-carry contract:

```sh
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous.md --round 2 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "second round from --previous and --round"
[ "$(cat .scratch/review/HEAD_1/round)" = 2 ] || { echo "FAIL: the round file does not say 2"; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  has "$f" "## Settled in earlier rounds" "$f has the settled section"
  has "$f" "$settled_rule" "$f carries the settled paragraph"
  has "$f" "1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17" "$f carries the cited Noted item"
  has "$f" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "$f carries the cited Dismissed item"
  lacks "$f" "Bare number" "$f drops the uncited item"
  lacks "$f" "Not an item" "$f skips the fenced hunk"
done
```

The `previous.md` heredoc at `:177-221` is the canonical shape of a posted review comment — two lead
sentences, `## Standards` with its four headings, `hard findings: 1`, `## Spec` reading
`no spec: Standards axis only`, `## Judgment` with the five headings, a summary line, then
`round: 1 of 3` and `act-on items: 0`. A new case for #90 is written the same way: extend or copy that
heredoc, run with `--previous` (+ `--round`) or through `pr me me:<file>`, assert with
`printed`/`has`/`lacks`. The groups in order are: no PR and empty PR (`:72-90`), an `HTTP 401` gh failure
(`:92-98`), the report-shape and anti-drift block (`:100-173`, which asserts the same five strings against
`$source_skill/SKILL.md` at `:112-120` and `:153-160`), `--previous` including CRLF and trailing-blank
variants (`:175-250`), the gh path including the rebuilt comment, a stranger's comment, a fourth round and
`--round 3` (`:252-305`), fence edge cases (`:307-339`), the shared-fragment equality (`:341-347`), the
`--round 4` refusal (`:349-360`), and blast radius (`:362-436`).

**`tests/spec-review/review-comment.sh`** (546 lines, prints `ok 82 assertions`, 41 per layout). Its
helpers are `rearm()` (`:22-28`) and `reset()` (`:30-33`) for the dir and the state; `run()` (`:35-40`),
which **folds stderr into stdout**; `refuse <message> <label> [dir]` (`:41-53`), which asserts exit 1, that
the whole captured output equals exactly `review-comment: <message>` on one line, and that the state's
presence is unchanged; and `accept <stdout> <label> [dir]` (`:55-64`), which asserts exit 0, exact stdout,
and that `.claude/state/review` is gone. Because `refuse` compares the entire output to one line, any
stray stderr chatter fails every refusal assertion at once.

One refusal case, verbatim (`tests/spec-review/review-comment.sh:93-97`) — the closest existing model for
a per-item line rule:

```sh
# A Would-break or Fails-open item without a `Documented step:` line is refused by name; a line
# inside a quoted hunk does not count; a body sentence is not the item's title.
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
printf '## Would break\n\n1. **One.** a\nDocumented step: ticket line\nResult: r\n\n## Fails open\n\n2. **Open, silently.** the guard returns. More.\n\n```sh\nDocumented step: inside the hunk\n```\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Fails-open item without a Documented step line, the fenced one not counting"
```

The counting contract is pinned at `:315-351`, whose judgment heredoc carries `fixed: abc1234` on `[S1]`
and `ticket: #12` on `[P1]` and whose expected output ends:

```
Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 1 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 3 of 3
act-on items: 1
```

`cites:` appears once in this whole test (`:429`, `:431`) as inert trailing text on a Dismissed item — it
is there to show that moving and renumbering an answered Ask item still parses, not to test `cites:`.

CI runs both: `.github/workflows/factory-ci.yml:24-25` (`review-comment.sh`), `:26-27`
(`review-brief.sh`), preceded by ShellCheck over `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`
(`:18-19`) and followed by `tests/spec-review/no-stale-wording.sh` (`:30-31`), the knowledge gate
(`:32-33`) and the vendoring gate (`:34-35`). The `fixture` job (`:36-87`) additionally runs the
*installed* `review-brief.sh` inside `/tmp/fx` with the fake `gh` on PATH and greps both briefs for the
definition, `` `## Fails open` ``, `` `## Walk` `` and the absence of `## Latent`. `review-comment.sh` is
not exercised by the fixture job.

#### 8. Patched file vs. kept file, and the check that catches a mismatch

`factory918.sh:385` names four **keep files**:

```sh
local keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh"
```

`cmd_sync()` (`factory918.sh:379-405`) copies those four to a temp dir (`:387`), then blows away each
vendored skill directory and recopies it from `research/` — for spec-review that is
`research/1-matt-pocock/skills-repo/skills/engineering/code-review` (`:391`) — restores the keep files
(`:392`), and finally replays every patch in `patches/series` order with `git apply` from inside
`template/.agents/skills` (`:395-399`), `--check` first; a patch that no longer applies prints
`FAILED <p> (upstream moved; rewrite the patch)` and sets the command's exit code without aborting the
loop.

So: **the two scripts are ours and are edited directly, with no patch.** `spec-review/SKILL.md` is *not* a
keep file — it is regenerated from the 87-line upstream and rebuilt by
`patches/mattpocock/spec-review.SKILL.md.patch` (139 lines, last entry of `patches/series`). Reading that
patch against the 155-line template file, every region #90 wants to touch is already inside a `+` hunk:
step 1's round rule (template `:21-29`), both briefs and the report shape (`:68-110`), step 5 with the
three trailing fields (`:112-134`), and step 6 (`:136-146`). There is no upstream text there.

A change to `SKILL.md` therefore lands in **both** the patch and the template file, in the same commit.
The gate is `.github/workflows/factory-ci.yml:34-35`:

```yaml
- name: Vendored skills equal the pins plus the patches
  run: ./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"
```

Editing only the template makes `sync` revert the edit; editing only the patch makes `sync` introduce it.
Either way `git diff` is non-empty and CI fails. `SOURCES.md:18` (patch item 6) is the prose description of
what the spec-review patch does and is maintained in lockstep — commit `82dc11e` is the closest precedent
for a change of #90's shape: three patches, three template files, both scripts, `AGENTS.md`,
`template/AGENTS.md`, `template/docs/agents/review-ladder.md`, `SOURCES.md` and both tests, one commit.

A second, independent gate at `factory-ci.yml:32-33` (`check_knowledge.py && build_knowledge.py &&
git diff --exit-code`) catches a `docs/knowledge/core/*.md` edit without a rebuild of
`template/docs/factory918/`.

### Where Things Live

**Owned, edited directly (keep files — `sync` preserves them, no patch):**

| Path | Role |
|---|---|
| `template/.agents/skills/spec-review/scripts/review-brief.sh` (362 lines) | step 1: rounds, carry-forward, both briefs, review state |
| `template/.agents/skills/spec-review/scripts/review-comment.sh` (159 lines) | step 6: validation, refusals, the count, clearing state |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md` (24 lines) | the nine-step ticket loop; step 9 delegates to babysit |
| `template/.agents/skills/poteto-mode/scripts/overlap.sh` | unrelated to this subsystem |

**Vendored + patched (change patch and template together):**

| Path | Patch |
|---|---|
| `template/.agents/skills/spec-review/SKILL.md` (155 lines) | `patches/mattpocock/spec-review.SKILL.md.patch`, `patches/series:17` |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md` (`:16`) | `patches/pstack/poteto-mode/playbooks/babysit.md.patch:7` |
| `template/.agents/skills/babysit/SKILL.md` (`:40`) | `patches/pstack/babysit/SKILL.md.patch:8` |
| `template/.agents/skills/arena/SKILL.md` | **no patch exists**; a change there needs a new patch file and a new `series` line |
| `template/.agents/skills/architect/SKILL.md` | patched (per `SOURCES.md`); Phase B is `:30-42`, Phase C's re-ground sentence is `:52` |

**The factory's own docs under `template/docs/` — not vendored, edited directly, copied wholesale into
projects by `factory918.sh:131-141`:**

- `template/docs/agents/review-ladder.md` (13 lines; rung 1 is `:6`). There is **no** root
  `docs/agents/review-ladder.md`; editing the template copy is complete for the factory.
- `template/docs/agents/{domain,issue-tracker,triage-labels}.md` — these three *do* have root copies per
  `AGENTS.md:51`.

**Core docs, edited then rebuilt (`python3 tools/build_knowledge.py`):**

- `docs/knowledge/core/DECISIONS.md` — P18 (`:85`, what a review counts), **P19** (`:86`, the judgment and
  the count), **P20** (`:87`, three rounds at most), **P21** (`:88`, what carries into the next round),
  P23 (`:89`, the Spec walk). Provisional starts at `:66`; rows are not in numeric order; a promoted row
  keeps its number as a tombstone; amendments are written inline as "Amended <date> (#N): …" and rationales
  end `Ticket #N, <date>.` and name what was rejected.
- `docs/knowledge/core/MANUAL.md:103` — the human's merge-readiness test.
- Generated twins, never edited: `template/docs/factory918/DECISIONS.md:78-80` and
  `template/docs/factory918/MANUAL.md:84`.

**Tests:** `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`,
`tests/spec-review/layout.sh` (the shared fixture builder, sourced only),
`tests/spec-review/fake-gh.sh` (used by the brief test and by the CI fixture job),
`tests/spec-review/no-stale-wording.sh` (13 lines, a fixed-string blacklist over `template` and
`docs/knowledge/core`, currently pinning only `## Latent` and `A hard finding is wrong behavior in normal
use`). `AGENTS.md` "Verifying" lists the two suites but **not** `no-stale-wording.sh`, although CI runs it.

**Records:** `docs/agents/ledger.md` (pipe-delimited `<date> | <model> | <what it did> | <what was
wanted>`), `docs/M0-findings.md` (`## <area> (<date>)` sections, for anything verified against a real tool).

**Read-only upstream:** `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md`.

### Gotchas

**Existing traps, before #90 touches anything.**

1. Any qualifying comment forces the round to ≥ 2. `BEGIN { r = 1 }` plus `round = top + 1` means round 1
   is unreachable once one review comment exists, except via `--round`. This is precisely the knob a
   restart has to turn.
2. `.scratch/review/<id>` is destroyed on every run (`review-brief.sh:163`), so `round` is never a durable
   counter. A restart cannot be recorded in state; it must be a line in a posted comment.
3. The jq filter (`review-brief.sh:94`) requires a line starting `act-on items:` for a comment to be seen
   at all. **A restart comment without that line is invisible to both the round scan and carry-forward.**
4. Refusal ordering is asymmetric: the three-round gate (`:140-143`) fires before any stdout; the
   cross-cutting gate (`:202-206`) fires after `ticket:` and `round:` are printed. Tests pin both.
5. `seen[]` is not reset on the record separator, while `fence`, `h`, `j` and `r` are (`:118`). Dedup is by
   whole line, so a re-worded or renumbered item carries twice.
6. `grep -E '^hard findings: [0-9]+$' | tail -1` (`review-comment.sh:85`) is **not** fence-aware, unlike
   the item parser. A `hard findings:` line inside a quoted hunk would be picked up if it were last.
7. The count ceiling at `:89` is one-sided (`-le`): `hard findings: 0` with three Would-break items passes.
8. `stepless()` `exit`s after the first offender, so a reviewer gets one refusal round per missing step.
9. `items()` returns single lines only. Any mark read by a `grep -cE … $` must sit on the item's own line;
   a mark on a continuation line is invisible to the counting greps.
10. The briefs' item-form sentences hard-code `[S3]`/`[P3]` as the example, tying reviewer numbering to the
    `[S<n>]`/`[P<n>]` grammar `review-comment.sh:117` enforces.
11. `--previous FILE` bypasses both jq filters entirely and is trusted wholesale; multi-comment
    `--previous` would need literal RS bytes and no test does that.
12. The brief test's positional assertion (`tests/spec-review/review-brief.sh:126-129`) pins that the first
    quote follows the definition two lines later — inserting anything between them breaks CI.
13. `no-stale-wording.sh` is the only prose grep, and it pins two #81 strings. **Nothing today pins that
    the round sentence in `SKILL.md`, the ladder and `DECISIONS.md` agree.** The vendoring gate catches
    drift between a patch and its template file, not drift between separate documents.
14. `of 3` is a literal in roughly eleven hand-edited places plus ~30 test assertions, and
    `review-comment.sh:157` hard-codes `echo "round: $round of 3"`.
15. `babysit/SKILL.md:41` is a different, upstream three-round rule (CI fix → push → recheck). Easy to
    confuse with `:40`; only `:40` is the review cap.
16. `arena/SKILL.md` has no judge-skip clause; Phase C is unconditional, and the convergence rule skips the
    graft, not the judge. `architect/references/runner-prompt.md:20` explicitly warns against converging.
    `architect/SKILL.md:52` is the closest existing precedent for a re-ground-and-re-run trigger, but it is
    triggered by the human, not by a review finding.
17. The Ticket playbook never mentions rounds, `act-on items:` or `spec-review`'s count at all; its step 9
    delegates wholly to `babysit.md`, and its step 5 names the four downstream playbooks rather than
    invoking `architect` directly (the invocations live in `feature.md` step 2, `bug-fix.md` step 3,
    `refactoring.md` step 3, `perf-issue.md` step 3 — all patched files).

**Open questions the explorers raised and could not settle from the code.**

- Whether `hole:` belongs on an Act on item (like `ticket:`/`fixed:`) or is a bucket of its own. Nothing in
  the current code or prose reserves either shape.
- Where a printed `restart` line sits relative to `round:` and `act-on items:`. Nothing reserves a slot,
  and three prose surfaces plus 18 `accept` expectations per suite currently say `act-on items:` is last.
- Whether a `hole:` mark should also suppress its item from carry-forward. Carry-forward reads only Noted
  and Dismissed, and `hole:` would sit under Act on, so today the question does not arise mechanically.
- Whether `spec:` is a checked `Documented step:`-class line or free-form. If checked, its refusal text
  joins `SKILL.md:140`'s list (patched prose) and the `review-comment.sh` test.
- Where the restart step lives: a new step 10 in `ticket.md`, a clause inside step 9, or a rung-1 sentence
  in `review-ladder.md:6`. All three are prose surfaces with no current owner for this transition.
- Whether `template/docs/agents/review-ladder.md` now needs a root copy at `docs/agents/review-ladder.md`.
  `AGENTS.md:51` names only three files as copied, and the factory's own `babysit.md:8` reads a file that
  is absent at the root.
- Whether the "two runners; the judge is skipped when they converge" rule is written into `arena/SKILL.md`
  (which would need a brand-new patch file and `series` line) or stated only in the restart step's brief.
- Whether `MANUAL.md:103`'s merge-readiness sentence needs a clause if a hole can leave a PR not-ready in a
  new way.
- Nothing in the repository currently contains `spec:`, `hole:` or `restart` as review marks, so there is
  no existing implementation to read.
- Nobody verified how GitHub renders a comment body containing an ASCII RS; the separator exists only in
  the `gh -q` output stream, not in the posted comment, so this is almost certainly moot.

**Seams where #90's four mechanisms attach.** Stated as attachment points and constraints, not as designs.

*The `spec:` line on hard findings.* It is a per-item **continuation line**, so its home on the writing
side is a fifth shell variable beside `step_rule`/`count_rule` at `review-brief.sh:240-243`, emitted at the
same two call sites (`:324` for Standards, `:352` for Spec), with a word-for-word twin inside
`SKILL.md:84`'s sentence — which already carries the step rule and count rule verbatim — or CI's drift
assertions (`tests/spec-review/review-brief.sh:112-120`, `:153-160`) fail. On the checking side it is a
sibling of `stepless()` (`review-comment.sh:54-62`) with a refusal beside `:91`, and a prose entry in
`SKILL.md:140`'s refusal list. It must not: break the test's positional pin at brief-test `:126-129`; break
the "no blank line between the report-path line and the count rule" layout (`:326-327`, `:354-355`); or
make `items()` see the new line as an item (it cannot, since `items()` requires `^[0-9]+\. `). It also has
to leave the one-sided ceiling check and the `## Walk` exclusion alone.

*The `hole:` mark on Act on items.* Mechanically it fits `review-comment.sh:149-150` exactly: one more
`items … | grep -cE 'hole: …$' || true` beside `fixed_here` and `ticketed`, plus a term in the arithmetic
at `:158`. Constraints: the mark must be trailing text on the item's own single line and `$`-anchored, or
the greps cannot see it; `fixed:`/`ticket:`/`hole:` are mutually exclusive per line by construction, and
`act - fixed_here - ticketed` could go negative if that ever stopped being true. The prose side is
`SKILL.md:130`, whose opening "Three trailing fields, each with one grammar:" becomes false with a fourth —
that line is `+` text of the patch, so both copies change together. A refusal for a `hole:` on an item with
no `spec:` reference needs the reports and the judgment cross-referenced, which `review-comment.sh` already
does structurally (`:115-126` maps `[S<n>]`/`[P<n>]` back to report items) but not textually.

*The `restart` line and the round reset.* Two places, both in `review-brief.sh`. The awk at `:133-137` is
where a `restart` line would have to set `r`/`top` back to 0, and the jq filter at `:94` is what decides
whether the restart comment is fetched at all — today a comment without an `act-on items:` line never
reaches the parser. Anything printed by `review-comment.sh` has to keep `act-on items: N` as the final
line, because `SKILL.md:138`, `babysit.md:16`, `babysit/SKILL.md:40` and `review-ladder.md:6` all say so and
every `accept` case in the comment test compares the whole stdout block. Putting `restart` above
`round: N of 3` (or between it and `act-on items:`) is the only shape that leaves the two babysit sentences
byte-identical, which is what acceptance criterion 7 asks for. Whatever the shape, the `--round N` override
(`:33`) and the three-round refusal string at `:141` — asserted verbatim twice, at brief-test `:295` and
`:355` — must keep working for a PR with no restart, and the "refuses nothing it did before" clause of the
ticket means the fourth-round refusal must still fire when no restart is present.

*The new `cites:` forms.* One line: the regex at `review-brief.sh:151`. The three new forms
(`#N table <row>/<column>`, `#N design <signature>`, `#N criterion <k>`) are siblings of the existing third
alternative, which already begins `#[0-9]+`. The `$` anchor and the `grep -E --` call both matter, and
`cites:` must remain the **last** field on its item line. The prose twin is `SKILL.md:132`, which restates
the same three alternatives, plus `SOURCES.md:18` and DECISIONS P21. `review-comment.sh` and its test are
untouched by this — they treat `cites:` as opaque text. Test coverage goes in the brief test, extending the
`previous.md` heredoc at `tests/spec-review/review-brief.sh:177-221` and asserting through
`printed`/`has`/`lacks` on the `settled: carried N, dropped M without a citation` line and the two briefs.
