# Explorer 1 — `review-brief.sh` and its test

All paths absolute under the worktree root
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a7e863dda12fb2374`
(abbreviated below as `<root>`). Line numbers are from the files as they stand on
`feat/design-hole-restart` (HEAD = ab47eb9 merge).

### Components Found

| Thing | Path | Size |
| --- | --- | --- |
| Step-1 script | `<root>/template/.agents/skills/spec-review/scripts/review-brief.sh` | 362 lines |
| Step-6 script (sibling, other explorer's slice) | `<root>/template/.agents/skills/spec-review/scripts/review-comment.sh` | 159 lines |
| Its test | `<root>/tests/spec-review/review-brief.sh` | 441 lines |
| Sourced fixture helper | `<root>/tests/spec-review/layout.sh` | 27 lines (no shebang, sourced) |
| Fake `gh` | `<root>/tests/spec-review/fake-gh.sh` | 24 lines (`/bin/sh`) |
| Stale-wording grep gate | `<root>/tests/spec-review/no-stale-wording.sh` | 13 lines |
| Prose twin (word-for-word) | `<root>/template/.agents/skills/spec-review/SKILL.md` | steps 1 (l.17-29), 4 (l.66-110), 5 (l.112-134), 6 (l.136-146) |
| CI | `<root>/.github/workflows/factory-ci.yml` | l.26-27 (unit), l.57-73 (fixture) |
| Settled rules of record | `<root>/docs/knowledge/core/DECISIONS.md` P19 (l.86), P20 (l.87), P21 (l.88); mirrored in `<root>/template/docs/factory918/DECISIONS.md` l.78-80 |

---

### Flow

#### 1. Argument parsing and usage (l.19-59)

`usage()` at l.19-23 prints two lines to stderr and `exit 1`:

```
usage: review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N] [--blast-radius FILE]
       review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...] [--blast-radius FILE]
```

Note the second (sweep) usage line does **not** advertise `--previous` / `--round`, but the parser
accepts them in either form. That is an existing inconsistency, not a guard.

- l.24: `skill="$(cd "$(dirname "$0")/.." && pwd -P)"` — the skill dir, used only to read `SKILL.md`
  for the smell baseline (l.62).
- l.25-26: `root="$(git rev-parse --show-toplevel)"`, then `cd "$root"`. Every path the script writes
  or prints is repo-relative from there.
- l.27-28 initialise `fixed ticket list previous round blast` and the arrays `paths commits standards`.
- The loop (l.29-47) is a single `while [ $# -gt 0 ]` with `shift` at l.46:
  - `--ticket` (l.31): takes `${2:-}`, `usage` if empty, **`list=""`**, extra `shift` (consumes 2).
  - `--previous` (l.32): `[ -f "$previous" ] || usage` — a missing file is a usage error, not a message.
  - `--round` (l.33): `[ "$round" -gt 0 ] 2>/dev/null || usage` — non-numeric or ≤ 0 is usage. There is
    no upper bound here; `--round 4` parses and is caught later by the round gate (l.140).
  - `--blast-radius` (l.34): `[ -f "$blast" ] || usage`.
  - `--standards` / `--paths` / `--commits` (l.35-37): set `list` and consume nothing; every following
    bare word is appended to that array (l.39-44) until another flag resets `list`.
  - `-*` (l.38): any unknown flag → `usage`.
  - A bare word with `list` empty becomes `fixed`; a second one → `usage` (l.43).
  - Consequence worth knowing: the four value-taking flags set `list=""`, so
    `--paths a --ticket 7 b` puts `b` in `fixed`, not in `paths`.
- Sweep form (l.48-54): requires `commits` non-empty and `fixed` empty, verifies each commit with
  `git rev-parse --verify -q "$c^{commit}"` (message `review-brief: $c does not resolve to a commit`,
  exit 1), sets `fixed=paths` and `id="sweep-$(git rev-parse --short "${commits[0]}")"`.
- Normal form (l.55-59): `fixed` required, same `rev-parse` check, and
  `id="$(printf '%s' "$fixed" | tr -c 'A-Za-z0-9._-' '_')"` — this is why `HEAD~1` becomes the dir
  `.scratch/review/HEAD_1` the tests assert on.

Two more preconditions run before any state is touched:

- **Smell baseline** (l.60-66): `sed -n '/^### 3\./,/^### 4\./p' "$skill/SKILL.md" | grep '^- \*\*.*→'`.
  Empty → `review-brief: no smell baseline found in $skill/SKILL.md (no line matching '^- **...→'
  between '### 3.' and '### 4.'); nothing written`, exit 1.
- **Ticket inference** (l.67-81): commit messages come from `git log --format=%B --no-walk --reverse
  "${commits[@]}"` (sweep) or `git log --reverse "$fixed..HEAD" --format=%B`; `grep -oE '#[0-9]+'`
  deduped with `awk '!seen[$0]++'`. Zero numbers → no ticket (Standards axis only); exactly one →
  that ticket; two or more → `review-brief: the commits name more than one ticket (...); pass
  --ticket N to choose; nothing written`, exit 1.

#### 2. Fetching the PR's earlier comments (l.82-107)

- `rs="$(printf '\036')"` (l.89) — ASCII 30, the record separator.
- `--previous FILE` short-circuits gh entirely: `bodies="$(cat "$previous")"` (l.91-92). The file is
  read raw; multiple comments in one `--previous` file would have to be separated by literal RS
  characters (no test does this; every `--previous` test uses one comment).
- Otherwise (l.94-106) the jq program is
  `ended='.author.login as $a | [.comments[] | select(.author.login == $a and (.body | test("(^|\n)act-on items:")))] | .[] | .body, ""'`
  run as `gh pr view --json author,comments -q "$ended"`.
  - **Fields:** `author` and `comments` only.
  - **Author filter:** `.author.login == $a` where `$a` is the PR author's login. A comment by anyone
    else is dropped inside jq, so it can neither advance a round nor carry an item. The comment block
    at l.82-88 states this as the rule ("a stranger's text").
  - **Second filter:** the body must contain a line starting `act-on items:` (`(^|\n)` anchor).
    A comment that is not a finished review comment is invisible. **Relevant to #90:** a restart
    comment that does not carry an `act-on items:` line never reaches this parser at all.
  - **Separator:** each qualifying body is emitted, then a line holding only ``.
  - stdout is redirected to a temp file, stderr captured: `err="$(gh ... 2>&1 >"$out")" || status=$?`.
  - `status == 0` → `bodies="$(cat "$out")"`.
  - Failure whose stderr matches `*"no pull requests found"*` (l.102) → silent; round 1, nothing carried.
  - Any other failure (l.103) → `review-brief: gh could not read the PR's review comments (<err with
    newlines turned to spaces>); round 1 unless --round says otherwise, nothing carried` on stderr, and
    the run continues.
  - `rm -f "$out"` at l.106.

#### 3. The awk fragments (l.108-126)

Two shell strings concatenated into every awk program as `"$split$fenced"`:

- `split` (l.116-119):
  ```awk
  { sub(/\r$/, ""); sub(/[ \t]+$/, "") }
  $0 == sep { fence = ""; h = ""; j = 0; if (r > top) top = r; r = 1; next }
  ```
  CR and trailing blanks are stripped first, so a web-UI comment parses like a `gh` one and the
  `cites:` `$` anchor still holds. The separator line resets fence, heading, judgment flag and the
  per-comment round, and folds the comment's round into `top`. It does **not** reset `seen[]`, which
  is what makes carry-forward "each distinct line once" across comments.
- `fenced` (l.120-126): CommonMark-ish fence tracking — opens on `^(```|~~~)`, closes only on the same
  character, at least as long, with nothing but spaces/tabs after it; `fence != "" { next }` swallows
  fenced lines; `^## ` sets `h` to the heading name minus trailing whitespace.
  This fragment is **byte-identical to the one in `review-comment.sh`**, and the test enforces that
  (test l.341-347, via `sed -n "/^fenced='\$/,/^'\$/p"`).

#### 4. The round computation (l.127-145)

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

Facts:

- The regex is anchored on both ends: `^round: [0-9]+ of 3$`. `substr($0, 8)` drops the 7 characters
  of `round: `; `+ 0` makes it a number.
- **Last wins inside a comment** (`r` is overwritten), so a quoted earlier `round:` line before the
  comment's own is harmless. The awk `top` is the max across comments.
- `BEGIN { r = 1 }` means a comment with no `round:` line counts as round 1. Consequently **any**
  qualifying comment forces `top >= 1`, so the computed round is ≥ 2 whenever `bodies` is non-empty.
- `--round N` overrides the computation entirely (it is set before l.139's `||`).
- The three-round refusal is **before** the `ticket:` / `round:` echoes and before `.scratch/review/<id>`
  and `.claude/state/review` are created — the clean "no state written" property the test asserts.
  Exit code 1; the message is the literal above (backticks around `fixed: <sha>` are literal).
- What is printed on success, in order, to stdout: `ticket: #N` (only if a ticket is known),
  `round: N of 3`, then (if `bodies` non-empty) the `settled:` line, then at the end the brief paths.
- `<dir>/round` is written at l.217 (`echo "$round" > "$dir/round"`), after the diff and blast-radius
  gates. `review-comment.sh` reads it at its l.128-131 and refuses if it holds a non-number
  (`$dir/round holds '...', not a round number; rerun scripts/review-brief.sh`), then prints
  `round: $round of 3` at its l.157.

**Relevant to #90:** the round is a pure function of the PR's comments plus `--round`. There is no
persisted counter — `<dir>/round` is a write-only artifact for `review-comment.sh`, and the whole
`<dir>` is `rm -rf`'d at l.163 on every run. A "restart comment that resets the round count" therefore
has to be recognised **here**, inside the awk at l.133-137 (e.g. a `restart` line that sets `top`/`r`
back to 0), and it must also pass the jq filter at l.94 to be fetched at all.

#### 5. Carry-forward: the `cites:` grammar and the settled section (l.146-161)

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

- Exactly three citation forms, each anchored to end of line (l.151):
  `user: "<words>" on #N` · `DECISIONS.md <row>` where row is `[A-Z]?[0-9]+` (so `P17` and `19`) ·
  `#N comment YYYY-MM-DD`. Used with `grep -E --`.
  **This one line is where #90's three new `cites:` forms (`#N table <row>/<column>`,
  `#N design <signature>`, `#N criterion <k>`) have to be added.** Note the existing `#N` alternative
  (`#[0-9]+ comment ...`) already starts the same way, so the new forms are siblings in that third
  alternative; the anchor `$` and the `--` in the grep call both matter.
- The `judged` awk: `/^## /` sets `j=1` once the `## Judgment` heading has been seen (the `fenced`
  fragment's own `^## ` rule has already updated `h` by then, so `h == "Judgment"` is the heading just
  read), and `next` keeps heading lines out of the output. An item line is a line starting
  `<digits>. ` under `## Noted` or `## Dismissed` **after** `## Judgment`. `!seen[$0]++` dedupes across
  all comments (`seen` survives the separator), so a rebuilt comment repeats nothing.
- Fenced text is never an item (the `fenced` fragment `next`s it), which is what lets a quoted review
  hunk contain `## Noted` / `1. ... cites: ...` lines harmlessly.
- The message printed is exactly `settled: carried <C>, dropped <D> without a citation`, where
  `D = |judged| - C`. It is printed whenever `bodies` is non-empty, including when both counts are 0.
- The section itself is written by `common()` at l.273-280, i.e. **after `## Diff`**, into *both*
  briefs, and only when `settled` is non-empty:
  ```
  ## Settled in earlier rounds

  These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm.

  <the settled lines, verbatim, in comment order>
  ```
  The paragraph string is the literal at l.276; SKILL.md l.76 carries it word for word, and the test
  pins both (`settled_rule`, test l.110, 115, 232).

#### 6. The `## Report` block written into both briefs (l.230-356)

Shared strings, defined once at l.232-243:

- `definition` (l.232), verbatim:
  > A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.
- `quotes` (l.233-239), verbatim, in this order:
  ```
  - Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
  - Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
  - Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
  - Manuel: "An edge case outside the intended path being unsupported is not a flag."
  - Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."
  ```
- `step_rule` (l.240), verbatim:
  > Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.
- `blast_rule` (l.242), verbatim:
  > The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence.
- `count_rule` (l.243), verbatim:
  > End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.

`report_rules()` (l.283-292) emits, in order: `## Report`, blank, `$definition`, blank, the five
quotes, blank, then

> Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

and a blank line. Both briefs call it.

**Standards brief** (l.293-328) then emits, l.317-320, the four heading bullets verbatim:

```
- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.
```

then the item-form sentence (l.322), verbatim:

> Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

then blank, `$step_rule` (l.324), blank, `Write your report to \`$dir/standards-report.md\` and reply
with only that path.` (l.326) and `$count_rule` (l.327) — the last two with **no blank line between
them**.

**Spec brief** (l.329-356), emitted only when `$spec` is non-empty, has the same `report_rules()` call
(l.344) and then, l.345-348:

```
- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.
```

then the Spec item-form sentence (l.350), verbatim:

> Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

then blank, `$step_rule` (l.352), blank, the spec-report path line (l.354) and `$count_rule` (l.355).

**Where a `spec:` rule would sit (#90).** The step rule is the only per-item *line* rule, and it is one
shell variable (l.240) emitted at two call sites (l.324, l.352), immediately after each axis's
item-form sentence and immediately before the report-path line. A `spec:` rule would be a fifth
variable next to `step_rule`/`count_rule` (l.240-243) echoed at the same two points, and — to satisfy
the drift test — a word-for-word copy in SKILL.md l.84, where the step rule and count rule already
live in one sentence ("Then the axis's headings and item form (below), then the step rule, word for
word: ... Then the report path and the count rule, word for word: ...").

Final stdout (l.357-362): with a spec, the two brief paths; without, the standards path plus the line
`no spec: Standards axis only`.

#### 7. Review state and the `<dir>` layout (l.162-217)

`dir=".scratch/review/$id"`, `rm -rf "$dir"`, `mkdir -p "$dir"` (l.162-164) — **every run wipes and
rebuilds the dir**, including `round`.

Files written into `.scratch/review/<id>/`:

| File | Line | Content |
| --- | --- | --- |
| `diff` | 166 / 171 | `git show --format='commit %h %s' <commits> -- <paths>` or `git diff <fixed>...HEAD` (three-dot) |
| `stat` | 167 / 172 | the `--stat` form |
| `log` | 168 / 173 | `git log --oneline` |
| `files` | 169 / 174 | changed paths, one per line (sweep form sorts and uniques) |
| `fixed-point` | 216 | the fixed point (or the word `paths`) |
| `round` | 217 | the computed round |
| `ticket.md` | 223 | `gh issue view <N> --json body -q .body` |
| `standards-brief.md` | 328 | |
| `spec-brief.md` | 356 | only when a spec exists |

Empty diff (l.176-180): `rm -rf "$dir"` then `review-brief: the diff is empty; nothing to review since
$fixed`, exit 1.

`.claude/state/review/` (l.210-215) is `rm -rf`'d and rebuilt with `fixed-point`, `files` (copied from
`$dir/files`) and `dir` (holding the `$dir` path). This is read by
`<root>/template/.claude/hooks/delegation.sh` l.27, 76, 98 (blocking the orchestrator's reads of the
files under review) and by `<root>/template/.claude/hooks/mode.sh` l.32-34 (the REVIEW status line).
`review-comment.sh` clears it.

Ordering matters: the state is written **after** the empty-diff and blast-radius gates, so a refusal
leaves no state behind (both refusals are asserted that way by the test).

#### 8. Spec fetch (l.219-228)

Only when a ticket is known: `gh issue view "$ticket" --json body -q .body` into `$dir/ticket.md`;
empty body → `review-brief: gh could not fetch #$ticket (<err>); no spec` on stderr and the Spec brief
is skipped. When there is a body, the ticket author's own comments come from
`by_author='.author.login as $a | .comments[] | select(.author.login == $a) | "### \(.createdAt[:10])\n\n\(.body)\n"'`
(l.226-227), failures swallowed with `2>/dev/null || true`. They land under
`## Comments by the ticket's author (#N)` (l.338-343).

#### 9. Cross-cutting predicate and blast-radius grounding (l.181-209)

```sh
while read -r p; do
  case "$p" in
    *.claude/hooks/*|*.claude/settings.json|*.agents/skills/factory918/*) crossing="$crossing $p" ;;
  esac
done < "$dir/files"
```

(l.187-191) — three globs, each with a leading `*` so a project's `.claude/hooks/` and the factory's
`template/.claude/hooks/` both match. The comment at l.184 says this is "the one place the predicate
lives; the Ticket playbook says it in words."

Grounding (l.192-209): `--blast-radius FILE` wins; otherwise the PR body's `## Blast Radius` section,
extracted by

```sh
gh pr view --json body -q .body 2>/dev/null | awk '{ sub(/\r$/, "") }
  p && (fence != "" || !/^## /)'"$fenced"'
  /^## / { p = (h == "Blast Radius") }'
```

The print rule sits *before* the `fenced` fragment, so the fence-opening line prints, fenced `## `
lines print (they are "inside" the section), and an unfenced heading ends the section. Leading blank
lines are stripped with `sed '/./,$!d'` (l.201). Note this gh call swallows **all** errors, unlike the
comments call.

Empty grounding on a cross-cutting diff (l.202-206): `rm -rf "$dir"` then

> review-brief: cross-cutting diff (<matching paths>) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE

exit 1 — but this happens *after* the `ticket:` / `round:` lines are already on stdout.

`--blast-radius` on a non-cross-cutting diff (l.207-209) is a stderr note only:
`review-brief: the diff is not cross-cutting; $blast is not pasted`.

The section is emitted by `common()` at l.255-262: `## Blast radius`, the `blast_rule` paragraph, then
the grounding verbatim — placed **before** `## Diff`.

`common()` order, for both briefs: the "Read nothing beyond this brief…" sentence (l.245) → `## Commits`
→ `## Changed files` → `## Blast radius` (conditional) → `## Diff` (inline in a ```diff fence when
`wc -l < diff` < 500, otherwise the sentence "The diff is N lines; read it from `<dir>/diff`.",
l.265-271) → `## Settled in earlier rounds` (conditional).

---

### The test: `<root>/tests/spec-review/review-brief.sh`

**Shape.** A header comment (l.2-17) that states the whole contract in prose, then helpers, then one
`suite()` function (l.62-437) invoked twice at l.439-440 (`suite project`, `suite factory`), and
`echo "ok $n assertions"` at l.441. **Running it now prints `ok 334 assertions`** (verified in this
worktree), i.e. 167 per layout.

**Helpers.**

- `layout` comes from `<root>/tests/spec-review/layout.sh`, sourced at l.22. It sets `source_skill`
  (the repo's `template/.agents/skills/spec-review`) at its l.8, and `layout <project|factory> <dir>`
  (its l.9-27) builds a fresh git repo: for `project`, `.agents/skills/spec-review/` + `.claude/hooks/`
  + symlink `.claude/skills -> ../.agents/skills`; for `factory`, the same under `template/` with
  `.claude/skills` and `.claude/hooks` symlinked there. It exports `skill` (the copy under test) and
  `hooks` (the hooks dir a cross-cutting commit touches), configures git identity, and commits
  "the layout".
- `pr <author> [login:file ...]` (l.30-34) writes `pr.json`: one comment per `login:file` pair,
  in order, with `--rawfile` so the body is the file verbatim; the whole wrapped as
  `{author:{login:$a}, comments:[…]}`.
- `has <file> <text> <label>` (l.37-44): `grep -qF --`, `exit 1` with `FAIL <label>: <file> lacks: …`,
  else `n=$((n+1))`.
- `lacks` (l.46-52): the inverse.
- `printed <file> <expected> <label>` (l.54-59): exact `$(cat …)` string equality against stdout,
  printing both sides on failure.
- Ad-hoc assertions (round-file contents, refusal exit codes, section ordering) are inline `if`/`[ ]`
  blocks that `exit 1` and bump `n` themselves.
- `quoting <label> <hunk>` (l.311-322) splices a hunk under the cited Dismissed item with
  `sed '/cites: DECISIONS.md P17$/r hunk.md'` and re-asserts the same carry, used three times
  (l.323-339) for the fence edge cases.
- `fragment()` (l.342) extracts the `fenced='…'` shell fragment from a script and compares the two
  copies (l.343-347).

**`fake-gh.sh`** (`<root>/tests/spec-review/fake-gh.sh`) is copied to `$tmp/bin/gh` at test l.26-28 and
`PATH` is prefixed. Its cases (its l.14-23):

- `pr view --json body*` → `cat "$FAKE_PR_BODY"` if that env var names an existing file, else
  `no pull requests found for branch "x"` on stderr, exit 1.
- `pr view*` → if `$FAKE_GH_DIR/pr-error` exists, print it to stderr and exit 1; else shift to `-q` and
  `jq -r "$2"` over `pr.json` if present, otherwise over
  `{"author": {"login": "me"}, "comments": []}`. **The script's own jq program runs**, so the author
  filter and the `act-on items:` filter are what is under test, not a stub.
- `*--json body*` → a fixed ticket body (`## What to build` / `## Acceptance criteria`).
- `*--json author,comments*` → two dated comment blocks already in the printed shape.
- anything else → `fake gh: unexpected args: $*`, exit 2.

`FAKE_GH_DIR` defaults to `.`, and the suite `cd`s into the fixture repo, so `pr.json` / `pr-error` are
just files created in the repo root (and `rm`'d when a case is done, l.73/75, 93/95, 305).

**Fixture repo per suite** (l.63-70): `layout`, `cd`, commit `a.txt` twice ("first", "second, no ticket
named"); later a hooks file commit "a hook, #7" (l.364-366) — which is also what makes `--ticket`
optional from l.372 on, since the commit message names `#7` — and a `README.md` commit "a readme, #7"
(l.428-430) for the non-cross-cutting case.

**Case groups, in order.**

1. l.72-90 — no PR (`pr-error` holding the "no pull requests found" text) and a PR with no comments:
   round 1, `<dir>/round` = 1, stderr empty.
2. l.92-98 — `HTTP 401` in `pr-error`: the message is printed, the run continues as round 1, nothing
   carried.
3. l.100-173 — the report-shape assertions: the definition, five quotes, the "quotes follow the
   definition two lines later" positional check (l.126-129), the shape sentence, item format, numbering
   sentence, step rule, count rule, `## Fails open` present, `## Latent` absent, no settled section, no
   blast-radius section; the same five strings plus every heading bullet asserted against
   **`$source_skill/SKILL.md`** (l.112-120, 153-160) — this is the anti-drift gate; heading ordering
   checks (l.161-165); the report-path lines; the ticket body and author comments from the fake gh.
4. l.175-250 — `--previous`: the fixture comment (l.177-221), the carry counts, CRLF variant (l.240-243),
   trailing-space/tab variant (l.246-250).
5. l.252-305 — the gh path: comment with no `round:` line, rebuilt comment, stranger's comment,
   fourth round from the PR's comments, `--round 3` override.
6. l.307-339 — fence edge cases through `quoting`.
7. l.341-347 — the shared `fenced` fragment equality.
8. l.349-360 — `--round 4` refusal.
9. l.362-436 — blast radius: `--blast-radius FILE`, refusal without one, PR-body section (CRLF, fenced
   `## ` kept, next heading ends it), empty section refused, non-cross-cutting `--blast-radius` note.

**Two representative cases, verbatim.**

Round count (test l.261-277):

```sh
# The rebuilt comment repeats round 1 and no longer holds the Noted item (settled, so not re-raised).
grep -v '^1\. \[S1\]' previous.md > previous-rebuilt.md
pr me me:previous.md me:previous-rebuilt.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "two comments both reading round 1 are round 1, so the next is 2, and their items carry once each"
[ "$(cat .scratch/review/HEAD_1/round)" = 2 ] || { echo "FAIL: the round file does not say 2 after a rebuilt comment"; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  has "$f" "1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17" "$f carries the item only the first comment holds"
  has "$f" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "$f carries the item both comments hold"
  [ "$(grep -cF 'cites: DECISIONS.md P17' "$f")" = 1 ] || { echo "FAIL: $f carries the item both comments hold twice"; exit 1; }
  n=$((n + 1))
done
```

Settled carry-forward (test l.222-237), against the `previous.md` fixture at l.177-221:

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

The `previous.md` heredoc (l.177-221) is the canonical shape of a posted review comment: two lead
sentences, `## Standards` / `## Would break` / `## Standards breaches` / `## Fix alongside`,
`hard findings: 1`, `## Spec` with `no spec: Standards axis only`, `## Judgment` with the five
headings, a summary line, then

```
round: 1 of 3
act-on items: 0
```

A new case for #90 is written the same way: extend or copy that heredoc, run the script with
`--previous` (+ `--round`) or through `pr me me:<file>`, and assert with `printed` / `has` / `lacks`.

**CI.** `<root>/.github/workflows/factory-ci.yml`:

- job `factory`, l.26-27: `bash tests/spec-review/review-brief.sh`. Preceded by ShellCheck over
  `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh` (l.19) and the `review-comment.sh` test
  (l.24-25); followed by `no-stale-wording.sh` (l.30-31) and the knowledge/sync `git diff --exit-code`
  gates (l.32-35).
- job `fixture`, l.57-73: runs the *installed* script inside `/tmp/fx` after `factory918 apply`, with
  `fake-gh.sh` copied to `/tmp/fake-gh/gh` and a hand-written `/tmp/blast.md`, then greps both briefs
  for the definition, `` `## Fails open` ``, absence of `## Latent`, presence of `` `## Walk` `` in the
  spec brief and absence in the standards brief, and finally `rm -rf .claude/state/review`.
- `<root>/tests/spec-review/no-stale-wording.sh` greps `template` and `docs/knowledge/core` for
  `## Latent` and the retired definition sentence, exit 1 on any hit.

---

### Files Read

- `<root>/template/.agents/skills/spec-review/scripts/review-brief.sh` (whole, 362 lines)
- `<root>/template/.agents/skills/spec-review/SKILL.md` (steps 1-6, l.17-146)
- `<root>/tests/spec-review/review-brief.sh` (whole, 441 lines)
- `<root>/tests/spec-review/layout.sh`, `fake-gh.sh`, `no-stale-wording.sh` (whole)
- `<root>/.github/workflows/factory-ci.yml` (l.1-87)
- `<root>/template/.agents/skills/spec-review/scripts/review-comment.sh` (grepped: `round`, `cites`,
  `fixed:`, `ticket:` — l.3-13, 128-131, 147-157)
- `<root>/docs/knowledge/core/DECISIONS.md` l.86-88 (P19, P20, P21)
- `<root>/.scratch/program/90/todo.md` (the owner lane's todo for this ticket; read as data)

### Boundaries

- **review-brief.sh ↔ review-comment.sh**: two files, `<dir>/round` and the report/judgment files. The
  `fenced` awk fragment is duplicated verbatim and the duplication is enforced by test l.341-347. Any
  change to fence handling must be made in both.
- **review-brief.sh ↔ SKILL.md**: six strings (definition, five quotes, step rule, count rule, settled
  paragraph, blast-radius paragraph) and eight heading bullets are duplicated between the script and
  SKILL.md step 4, and the test asserts both copies (test l.112-120, 153-160). A new `spec:` rule in
  the briefs must land in SKILL.md l.84's paragraph too, or CI fails.
- **script ↔ gh**: two calls to `gh pr view` (comments at l.97, body at l.197) and two to `gh issue
  view` (l.223, l.227). Only the comments call reports its failure; the other three are silent
  (`2>/dev/null || true` / an empty-body message).
- **script ↔ hooks**: `.claude/state/review/{fixed-point,files,dir}` is the whole interface to
  `delegation.sh` and `mode.sh`; the script only writes it, `review-comment.sh` clears it.
- **script ↔ babysit / MANUAL / review ladder**: those read only the comment's last line
  (`act-on items: N`) — `template/.agents/skills/babysit/SKILL.md` l.40,
  `template/.agents/skills/poteto-mode/playbooks/babysit.md` l.16,
  `template/docs/factory918/MANUAL.md` l.84, `template/docs/agents/review-ladder.md` l.6. Nothing
  downstream reads `<dir>/round` except `review-comment.sh`.
- **Strangers' text**: the jq author filter at l.94 is the only defence; everything downstream trusts
  `bodies`.

### Non-Obvious Things

1. **The refusal order differs between the two gates.** The three-round refusal (l.140-143) fires
   *before* anything is printed to stdout; the cross-cutting refusal (l.202-206) fires *after*
   `ticket:` and `round:` are already printed. The test encodes both (l.295 vs l.395-397).
2. **Any qualifying comment forces round ≥ 2.** `BEGIN { r = 1 }` plus `round = top + 1` means there is
   no way to compute round 1 once a comment with `act-on items:` exists — unless `--round` says so.
   This is exactly the knob #90's restart comment has to turn.
3. **`<dir>` is destroyed on every run** (l.163), so `round` is never a durable counter; the PR's
   comment history is the only memory. A restart therefore cannot be recorded in state — it must be a
   line in a comment that the awk at l.133-137 understands *and* that the jq filter at l.94 lets
   through (i.e. the restart comment needs an `act-on items:` line, or the filter must be widened).
4. **`seen[]` is deliberately not reset on the record separator**, while `fence`, `h`, `j` and `r` are
   (l.118). That asymmetry is what makes "each distinct line once" work across comments while the round
   still resets per comment.
5. **Dedup is by whole line**, so two different rounds' judgments carry both copies of an item whose
   wording changed even slightly (renumbering `1.` → `2.` makes it a different line). The test's
   rebuilt-comment case (l.262) happens to keep the numbering identical.
6. **`substr($0, 8)`** assumes the exact prefix `round: `; a two-digit round still parses because of
   `+ 0`, and the `of 3` suffix is required by the anchor.
7. **`--previous` bypasses the author filter and the `act-on items:` filter entirely.** A file handed to
   `--previous` is trusted wholesale. Multi-comment `--previous` requires literal RS bytes.
8. **The `cites:` grep runs over `judged`, not over the raw bodies**, so a `cites:` line outside a
   judgment's Noted/Dismissed section, or inside a fence, can never carry.
9. **`--standards` with no following words silently yields no standards file**, and the fallback at
   l.229 only applies when the array is empty, so `--standards` followed immediately by another flag
   makes the brief say "This repository documents no coding standards" (l.307).
10. **The brief's item-form sentences hard-code `[S3]` / `[P3]`** as the example reference, tying the
    reviewer's numbering to the judgment's `[S<n>]`/`[P<n>]` grammar checked in `review-comment.sh`.
11. **`common()` puts `## Settled in earlier rounds` after `## Diff`**, i.e. after a possibly 500-line
    fenced diff — it is the last thing before the axis sections.
12. The test's positional assertion at l.126-129 pins the *layout* (definition line, blank, first
    quote), so inserting anything between the definition and the quotes breaks CI.

### Open Questions

- I did not trace `review-comment.sh` beyond its round handling and the `fixed:` / `ticket:` counting
  greps (l.128-131, 147-157) — that file, and `tests/spec-review/review-comment.sh` (546 lines), are
  another explorer's slice. In particular I have not checked how its heading-shape and
  numbering-continuity checks would react to a new `spec:` or `hole:` line on an item, nor whether its
  item regexes would treat `hole: <spec ref>` the way they treat `fixed:`/`ticket:`.
- Nothing in the repository currently contains `spec:`, `hole:` or `restart` as review marks (the
  owner-lane todo's T4 records the same falsifiability check), so there is no existing implementation
  to read for #90 — only the three insertion points named above (l.151, l.133-137, l.240/324/352).
- I did not verify how GitHub renders a comment whose body contains an ASCII RS; the separator only
  exists in the `gh -q` output stream, not in the posted comment, so this is almost certainly moot.
- `<root>/.scratch/program/90/architect/` and `how/` are empty; I found no written design for #90 to
  cross-check against.
