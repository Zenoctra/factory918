# explorer-2: `review-comment.sh` and its tests

All paths are relative to `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a7e863dda12fb2374`.

### Components Found

- `template/.agents/skills/spec-review/scripts/review-comment.sh` — 159 lines (the brief said 158; it is 159). Step 6 of the skill. Prints the review comment, refuses off-shape inputs, clears the review state.
- `tests/spec-review/review-comment.sh` — 546 lines (brief said 543). Runs the script twice (project layout, factory layout) against fixtures in a temp git repo. Ends `ok 82 assertions` (41 per layout). Verified by running it: exit 0, `ok 82 assertions`.
- `tests/spec-review/layout.sh` — 27 lines, no shebang, sourced by both spec-review tests. Builds the temp repo.
- `tests/spec-review/no-stale-wording.sh` — 13 lines, a grep gate over `template` and `docs/knowledge/core`.
- `tests/spec-review/fake-gh.sh` — 24 lines, a fake `gh` for `review-brief.sh` only; `review-comment.sh` never shells out to `gh`.
- `.github/workflows/factory-ci.yml` — job `factory`, steps at lines 24–25, 26–27, 30–31.

### Flow

**Preamble** (lines 1–20). Header comment lines 1–15 is the spec of the script in prose. `set -euo pipefail` (16); `root="$(git rev-parse --show-toplevel)"; cd "$root"` (17–18) — the script always runs from the repo root, so every path it prints is root-relative; `state=.claude/state/review` (19); `fail() { echo "review-comment: $*" >&2; exit 1; }` (20). Every refusal goes through `fail`, so every refusal line is `review-comment: <message>` on stderr with exit 1, and every refusal happens before any stdout is written and before the state is touched.

**1. Argument handling and where the review dir comes from** (21–31).

- With an argument (21–27): `dir="$1"`; trailing slashes are stripped in a loop `while [ "${dir%/}" != "$dir" ]; do dir="${dir%/}"; done` (24); an absolute path under the root is made root-relative by `case "$dir" in "$root"/*) dir="${dir#"$root"/}" ;; esac` (25); a leading `./` is stripped (26). So `.scratch/review/x`, `./.scratch/review/x/` and `/abs/root/.scratch/review/x` all normalize to the same string, which is what the state comparison at line 159 depends on. Then `[ -d "$dir" ] || fail "$dir is not a directory; pass the .scratch/review/<id> review-brief.sh wrote"` (27) — a plain file at that path fails the same way (test lines 310–313).
- Without an argument (28–31): `[ -f "$state/dir" ] || fail "no review in progress ($state/dir is missing); run scripts/review-brief.sh first, or pass the review dir to rerun a finished review"` (29), then `dir="$(cat "$state/dir")"` (30). The state file's content is used verbatim, not normalized.

**2. The Markdown parser** (33–51). The comment at 33–39 states the fence rule and says `review-brief.sh` carries the same fragment word for word (`review-brief.sh:120–126` is the copy; `tests/spec-review/review-brief.sh` is said to hold the two copies together).

- `fenced` (41–47) is an awk program fragment. A fence opens on `^(```|~~~)` whatever follows it; it closes only on a line of the same character, at least as long as the opening run, followed by only spaces/tabs/CR — so ` ```sh ` inside a ` ``` ` block does not close it, and ` ``` ` inside a ` ```` ` block does not either. `fence != "" { next }` (45) drops all fenced lines. `/^## / { h = substr($0, 4); sub(/[ \t\r]+$/, "", h) }` (46) tracks the current heading with trailing whitespace trimmed.
- `headings() { awk "$fenced"'/^## / { print h }' "$1"; }` (48).
- `items() { awk -v want="${2:-}" "$fenced"'/^## / { next } h != "" && h != "Walk" && /^[0-9]+\. / && (want == "" || h == want)' "$1"; }` (50). **Key fact for #90:** an item is exactly one line matching `^[0-9]+\. ` under a non-`Walk` heading. Continuation lines (`Documented step:`, `Result:`) are *not* items and are never returned by `items()`. `## Walk` is excluded unconditionally, so the Spec report's walk steps are neither counted nor numbered nor judged.
- `count() { items "$@" | wc -l | tr -d ' '; }` (51).

**3. Per-item structural checks.**

- `stepless()` (54–62): awk with a `flush()` that, on each new item line or heading or EOF, prints `"<heading>: <item line>"` for the first `## Would break` / `## Fails open` item that saw no `^Documented step:` line before the next item or heading, then `exit`s. Fenced lines are excluded by `fenced`, so a `Documented step:` inside a quoted hunk does not satisfy it. This is the existing template for a "hard findings carry an extra line" rule — a `spec:` line requirement in #90 would be a sibling of this function.
- `numbered()` (65–71): a bash `while read` over `items "$f"`, incrementing `i` and comparing `${line%%.*}` (the text before the first `.`) to `$i`. Refuses with the message at line 69. Because it reads from `items()`, numbering is continuous 1..N across all headings in document order, the Walk excluded.
- `shape()` (73–78): `printf '%s\n' "$@"` vs `headings "$f"`; the refusal at 77 renders both lists pipe-joined via `paste -sd '|' -`.
- `report()` (81–92) composes: `shape`, `numbered`, then the count line at 85 (`grep -E '^hard findings: [0-9]+$' "$f" | tail -1` — the *last* such line wins; `|| fail` when grep finds none), then the ceiling check at 89, then `stepless` at 90–91.

**4. Reading the reports** (94–107).

- `[ -f "$dir/standards-report.md" ] || fail "..."` (94), then `report "$dir/standards-report.md" "Would break" "Fails open" "Standards breaches" "Fix alongside"` (95). `s_total`, `s_wb`, `s_fo` (96–98).
- The Spec axis is conditional on `$dir/spec-brief.md` existing (100). If it does, `spec-report.md` must exist (101) and the shape is `"Walk" "Would break" "Fails open" "Not asked for"` (102). `p_total`, `p_wb`, `p_fo`, `has_spec=yes` (103–106). With no spec brief the Spec section prints `no spec: Standards axis only` (140) and `p_total=0`, so a `[P<n>]` reference then has no target (test line 133).

**5. Reading the judgment** (109–127).

- Existence (109), shape `Act on / Ask / Consider / Noted / Dismissed` (110), numbering (111).
- Item-count identity: `[ "$j_total" -eq $((s_total + p_total)) ]` (113).
- Reference extraction (115–120): each item line is run through `sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p'`; an empty result fails at 118. Note the reference must be immediately after `N. `.
- The reference set is compared to the generated `S1..Ss P1..Pp` set, both `sort`ed (121–122); on mismatch `comm -23` / `comm -13` build the `missing` / `extra` lists and the refusal at 126 names both. A repeated reference shows as both missing (the one it displaced) and "unknown or repeated".

**6. Round** (128–132). `round=1` default; if `$dir/round` exists it is `cat`ed and checked with `[ "$round" -gt 0 ] 2>/dev/null || fail "$dir/round holds '$round', not a round number; rerun scripts/review-brief.sh"` (131). `$dir/round` is written by `review-brief.sh:217`.

**7. Output** (134–158), in exactly this order:

```
## Standards
<blank>
<standards-report.md verbatim>
<blank>
## Spec
<blank>
<spec-report.md verbatim | "no spec: Standards axis only">
<blank>
## Judgment
<blank>
<judgment.md verbatim>
<blank>
Standards: <s_wb> would break, <s_fo> fail open, of <s_total>; Spec: <p_wb would break, p_fo fail open, of p_total | no spec>; judged: act on <act> (<fixed_here> fixed, <ticketed> with a ticket), ask <ask>, consider <n>, noted <n>, dismissed <n>; <fixed point X | fixed point unknown>.
round: <round> of 3
act-on items: <act - fixed_here - ticketed + ask>
```

The counting lines are 146–151:

```sh
act="$(count "$dir/judgment.md" "Act on")"
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
ask="$(count "$dir/judgment.md" "Ask")"
```

So `fixed:` and `ticket:` are *trailing text on the item's own single line*, anchored at end of line, and only under `## Act on`. A mark on a continuation line would be invisible. `cites:` is **not read by `review-comment.sh` at all** — it is inert trailing text here, passed through verbatim inside the `## Judgment` section; only `review-brief.sh:151` validates its grammar (see Boundaries).

The fixed point (153–155) prefers `$dir/fixed-point`, falls back to `$state/fixed-point`, else `fixed point unknown`.

`echo "round: $round of 3"` (157) and `echo "act-on items: ..."` (158) are the last two `echo`s; nothing prints after 158. Confirmed: the final line is always `act-on items: N`, including `act-on items: 0`.

**8. Clearing the state** (159). `if [ -f "$state/dir" ] && [ "$(cat "$state/dir")" = "$dir" ]; then rm -rf "$state"; fi`. Nothing is cleared when no state exists, or when the state names a different dir (a newer review in progress — test lines 353–365). Because `dir` is normalized at 23–26, all three spellings of the same dir still match the state's string.

### Every refusal, in source order

| Line | Condition | Message (after the `review-comment: ` prefix) |
|---|---|---|
| 27 | argument is not a directory | `<dir> is not a directory; pass the .scratch/review/<id> review-brief.sh wrote` |
| 29 | no argument and no `$state/dir` | `no review in progress (.claude/state/review/dir is missing); run scripts/review-brief.sh first, or pass the review dir to rerun a finished review` |
| 69 | numbering not 1..N (report or judgment) | `<f> item '<line>' is numbered <k> where <i> was expected; number the items 1..N continuously across the headings, in document order` |
| 77 | headings off shape (report or judgment) | `<f> has the headings [a|b]; the shape is [w|x|y|z], in that order, each holding numbered items or nothing` |
| 85 | no `hard findings: N` line | `<f> has no 'hard findings: N' line; ask the reviewer for it` |
| 89 | count above Would-break + Fails-open | `<f> says 'hard findings: <n>' but has <wb> items under '## Would break' and <fo> under '## Fails open'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount` |
| 91 | a hard item with no `Documented step:` | `<f> item '<N. **Title.**>' under '## <heading>' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both` |
| 94 | missing Standards report | `<dir>/standards-report.md is missing; wait for the Standards reviewer` |
| 101 | spec brief present, no Spec report | `<dir>/spec-report.md is missing; wait for the Spec reviewer` |
| 109 | missing judgment | `<dir>/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun` |
| 113 | item-count mismatch | `<dir>/judgment.md has <j> items; the reports have <s+p> (Standards <s>, Spec <p>). Every report item appears exactly once in the judgment` |
| 118 | item without `[S<n>]`/`[P<n>]` | `<dir>/judgment.md item '<line>' does not open with [S<n>] or [P<n>], the report item it judges` |
| 126 | reference set mismatch | `<dir>/judgment.md does not name every report item exactly once: missing [<list|none>], unknown or repeated [<list|none>]; the reports have <s> Standards items and <p> Spec items` |
| 131 | `<dir>/round` holds no number | `<dir>/round holds '<text>', not a round number; rerun scripts/review-brief.sh` |

All exit 1 and clear nothing, because every check precedes line 159 and the first `echo` at 134.

### The test file

`tests/spec-review/review-comment.sh` structure:

- Header comment 2–8 states the contract the file pins.
- `here` (10), sources `tests/spec-review/layout.sh` (12), `tmp="$(mktemp -d)"` with an EXIT trap (13–14), `dir=.scratch/review/x`, `state=.claude/state/review` (15–16).
- Globals `n` (assertion count), `code`, `out` (18–20).
- **`rearm()`** (22–28): recreates `$dir` and `$state`, writes `main` into `$state/fixed-point` and `$dir/fixed-point`, `a.sh` into `$state/files`, `$dir` into `$state/dir`. Keeps the fixture reports.
- **`reset()`** (30–33): `rm -rf "$dir" "$state"` then `rearm` — a fresh review with no reports.
- **`run() { set +e; out="$(bash "$script" "$@" 2>&1)"; code=$?; set -e; }`** (35–40). Note stderr is folded into `out`.
- **`refuse <message> <label> [dir]`** (41–53): records whether `$state/dir` existed, runs with `"${@:3}"`, and asserts `code == 1`, `out == "review-comment: $1"` exactly (one line, nothing else), and the state presence unchanged. Increments `n`.
- **`accept <stdout> <label> [dir]`** (55–64): asserts `code == 0`, `out` equals the expected block verbatim, and `[ -e "$state" ]` is false (state cleared). Increments `n`.
- Fixture helpers (65–67): `empty_standards`, `empty_spec`, `empty_judgment`, each a `printf` of the bare heading shape (`empty_standards` ends `hard findings: 0`).
- **`suite <project|factory>`** (70–542): `layout "$1" "$fx"`, `script="$skill/scripts/review-comment.sh"`, `cd "$fx"`, then all assertions. Called twice at 544–545; `echo "ok $n assertions"` at 546.
- Assertion count per suite: 22 top-level `refuse`, 11 top-level `accept`, 2 `accept`s inside the spelling `for` loop (450–469), 5 `fenced_twin` calls (each one `accept`, 497–522), plus 1 hand-written assertion (358–364) = 41. Two suites = **82**.
- Reports and judgments are written two ways: single-line `printf '...\n'` into `"$dir/standards-report.md"` etc. for the short cases, and `cat > "$dir/judgment.md" <<'EOF'` heredocs for the long ones (171–238, 258–277, 317–336). `hard findings:` is always the last line of a report fixture. Expected `accept` output interpolates `$(cat "$dir/standards-report.md")` so the test asserts "verbatim" without duplicating the fixture text.
- `fenced_twin <label> <hunk>` (477–496) builds the same report with `%s` for a quoted hunk under item 1 and asserts the hunk changes nothing. Five variants at 497–522 cover: no hunk, a ` ``` ` inside a ` ```` ` block, a `~~~` fence quoting ` ``` `, a ` ```sh ` inside a ` ``` ` block, and a fenced hunk carrying `## ` and `1. ` lines.
- Trailing-whitespace headings are pinned at 524–541.
- The hand-written assertion at 355–364 covers the "newer review's state names another dir" case: it checks exit 0, that `$state/dir` still reads `.scratch/review/y`, and that the output contains `; fixed point main.` (the old dir's own `fixed-point`, not the state's).

**Representative refusal case, verbatim** (tests/spec-review/review-comment.sh:96–97; the comment above it is 93–95):

```sh
# A Would-break or Fails-open item without a `Documented step:` line is refused by name; a line
# inside a quoted hunk does not count; a body sentence is not the item's title.
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
printf '## Would break\n\n1. **One.** a\nDocumented step: ticket line\nResult: r\n\n## Fails open\n\n2. **Open, silently.** the guard returns. More.\n\n```sh\nDocumented step: inside the hunk\n```\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Fails-open item without a Documented step line, the fenced one not counting"
```

**Representative count case with `fixed:` and `ticket:`, verbatim** (tests/spec-review/review-comment.sh:315–351):

```sh
# At round three the Act on items are fixed on this PR and marked with the commit; a marked item
# is not counted either. The state is gone, so the rerun names the dir.
cat > "$dir/judgment.md" <<'EOF'
## Act on

1. [S1] **Hook exits 0 on a miss.** The test proves it. fixed: abc1234
2. [P1] **Sweep form ignores --ticket.** The commit list is empty there. ticket: #12

## Ask

3. [P2] **Token in the log.** Data retention is the human's call.

## Consider

## Noted

4. [S3] **Duplicated Code.** Fixed alongside S1 if the loops are touched.

## Dismissed

5. [S2] **Bare number.** The constant is named two lines up.
EOF
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 1 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 3 of 3
act-on items: 1" "an Act on item fixed on this PR is not counted, round 3" "$dir"
```

A `cites:` mark appears once in this test, as inert trailing text on a Dismissed item (429, 431) — it is there to show that moving and renumbering an answered Ask item still parses, not to test `cites:` grammar.

**`tests/spec-review/layout.sh`** (27 lines, no shebang, `# shellcheck shell=bash disable=SC2034`): `source_skill` points at `template/.agents/skills/spec-review` (line 8). `layout <project|factory> <dir>` (9–27) picks `base`, `hooks` and the `skills` symlink target per layout (12–13), copies the skill in, writes an executable no-op hook, symlinks `.claude/skills`, and for the factory layout also symlinks `.claude/hooks` (15–20); sets `skill` (21); then `git init -q`, a test identity, `git add -A`, `git commit -qm "the layout"` (22–26). The git repo is required because the script calls `git rev-parse --show-toplevel`.

**`tests/spec-review/no-stale-wording.sh`, whole (13 lines):**

```sh
#!/usr/bin/env bash
# Greps template/ and docs/knowledge/core/ for the wording #81 retired, the `## Latent` heading and
# the definition sentence that began "A hard finding is wrong behavior in normal use", so a rename
# that leaves the old words behind fails here. Prints each hit as file:line and exits 1 on any;
# prints `ok: no stale wording` otherwise.
set -euo pipefail
cd "$(dirname "$0")/../.."
hits="$(grep -rnF -e '## Latent' -e 'A hard finding is wrong behavior in normal use' template docs/knowledge/core | cut -d: -f1,2 || true)"
if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  exit 1
fi
echo "ok: no stale wording"
```

It is a fixed-string blacklist over two trees. Any wording #90 retires would be added as another `-e`.

### CI and the Verifying list

`.github/workflows/factory-ci.yml`, job `factory` (11–35):

- 18–19 ShellCheck over `factory918.sh`, `template/.github/shellcheck.sh`, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh`, `tests/*/*.sh` — so both `review-comment.sh` and its test are ShellCheck-gated at the pin (0.11.0, `.github/shellcheck.sh:13`).
- 24–25 `- name: review-comment.sh prints and refuses what the test says` / `run: bash tests/spec-review/review-comment.sh`.
- 26–27 `review-brief.sh writes the report shape into both briefs`.
- 30–31 `No retired review wording under template/ or the core knowledge` / `bash tests/spec-review/no-stale-wording.sh`.
- `tests/spec-review/layout.sh` is never run directly; it is sourced by the two tests.
- The `fixture` job (36–87) exercises `review-brief.sh` only (57–73), with `tests/spec-review/fake-gh.sh` copied onto PATH as `gh`; it greps the briefs for the hard-finding definition sentence, `` `## Fails open` ``, `` `## Walk` `` presence/absence, and refuses `## Latent`. `review-comment.sh` is not run in the fixture job.

`AGENTS.md` "Verifying" lists, in order: the ShellCheck command, `bash tests/shellcheck/gate.sh`, `bash tests/hooks/delegation.sh`, `bash tests/spec-review/review-comment.sh`, `bash tests/spec-review/review-brief.sh`, `bash tests/poteto-mode/overlap.sh`, the knowledge build/check, `./factory918.sh sync`, and the fixture flow. **`tests/spec-review/no-stale-wording.sh` and `tests/spec-review/layout.sh` are not in the AGENTS.md list**, although CI runs the former — a gap worth naming if #90 adds a wording gate.

### Prose surfaces that pin this script's output

- `template/.agents/skills/spec-review/SKILL.md:130–134` defines the three trailing fields and their grammars (`cites:`, `ticket:`, `fixed:`); 136–138 describes step 6's output including "Babysit reads this line, so it is always present and always last"; 140 enumerates the refusals in prose (a parallel list of the table above); 142 the rerun-with-a-dir form; 124 the `[S2]`/`[P1]` numbering rule; 128 the answered-Ask re-sort ("that is the same round, not a new one"); 25 the round derivation.
- `template/.agents/skills/poteto-mode/playbooks/babysit.md:16` and `template/.agents/skills/babysit/SKILL.md:40` both require `act-on items: 0` on the latest commit and both carry the same `round: 3 of 3` sentence and the same Ask-item sentence.
- `template/docs/agents/review-ladder.md:6` — "ends with the lines `round: N of 3` and `act-on items: N`".
- `template/docs/factory918/MANUAL.md:84` (and its source `docs/knowledge/core/MANUAL.md:103`) — "`spec-review`'s last line on the latest commit reads `act-on items: 0`".
- `template/docs/factory918/DECISIONS.md:78–80` = `docs/knowledge/core/DECISIONS.md:86–88`: P19 (judgment shape and the count), P20 (three rounds), P21 (what carries forward). The `template/docs/factory918/` copies are generated from `docs/knowledge/core/` by `tools/build_knowledge.py`.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` mentions `spec-review` only at lines 9 and 24, and says nothing about the count; the count lives in babysit and the ladder.

### Boundaries

- **`review-comment.sh` ↔ `review-brief.sh`.** The brief writes `$dir/round` (`review-brief.sh:217`), `$dir/fixed-point`, `$state/dir`, `$state/fixed-point`, `$state/files`; the comment reads them and deletes `$state`. The two share the `fenced` awk fragment, duplicated by hand (comment at `review-comment.sh:38–39`, `review-brief.sh:110–115`).
- **`cites:` is entirely `review-brief.sh`'s.** `review-brief.sh:151` holds the grammar as one regex: `cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2})$`. Carry-forward is 146–161: the awk at 154–157 pulls Noted and Dismissed item lines out of the `## Judgment` section of every earlier comment (deduped with `!seen[$0]++`), `grep -E -- "$cites"` keeps the cited ones (158), and line 160 prints `settled: carried N, dropped M without a citation`. Adding `cites:` forms for #90 touches that one regex, the SKILL.md sentence at 132, DECISIONS P21, and `tests/spec-review/review-brief.sh` — **not `review-comment.sh` and not `tests/spec-review/review-comment.sh`**, which treat `cites:` as opaque text.
- **The round count is read from PR comments, not from a file.** `review-brief.sh:133–139` scans earlier comment bodies for `^round: [0-9]+ of 3$` and takes the max plus one; `review-comment.sh` only echoes whatever `$dir/round` holds. A "restart comment that resets the round count" therefore has to be recognized by `review-brief.sh`'s awk at 133–137 (or by `--round N`, `review-brief.sh:33`), while `review-comment.sh` would only need to emit whatever marker that awk looks for.
- **Where a new mark would have to live.** `items()` returns single lines, and `fixed_here`/`ticketed` grep those lines anchored at `$`. A `hole: <spec ref>` mark on an Act on item fits that pattern exactly (one more `grep -cE ... || true` beside 149–150, and a term in the arithmetic at 158 or a separate printed line). A `spec:` line on hard findings does **not** fit that pattern — it is a continuation line, so it needs a `stepless()`-shaped scanner (54–62) and a refusal beside 91.
- **The "always last line" contract.** Three prose surfaces state it (SKILL.md:138, babysit.md:16, review-ladder.md:6) and the test asserts exact stdout in 18 `accept` cases per suite. A printed `restart` line would either have to come before `act-on items:` or break that contract in all three places and in every `accept` expectation.
- **Two layouts, one script.** `layout.sh` proves the script behaves identically when the skill sits at `.agents/skills/spec-review` (project) and at `template/.agents/skills/spec-review` (factory). Nothing in `review-comment.sh` reads its own location; it only uses `git rev-parse --show-toplevel`, so the layouts differ only in where the *script file* is.

### Non-Obvious Things

1. `grep -E '^hard findings: [0-9]+$' "$f" | tail -1` (85) takes the **last** matching line, and the fence rule does not apply to it — a `hard findings:` line inside a quoted hunk *would* be picked up if it were the last one in the file. The item parser exempts fences; the count-line grep does not.
2. The count check at 89 is one-sided (`-le`). A report saying `hard findings: 0` with three Would-break items passes. The refusal only catches an inflated count.
3. `stepless()` calls `exit` inside `flush()` after printing the first offender, so only one offending item is ever named per run, and the reviewer gets one refusal round per missing step.
4. The refusal at 91 re-derives the title with `sed -E 's/^([0-9]+\. \*\*[^*]+\*\*).*/\1/'`, which cuts at the first `**...**` — the test at 97 pins that a body sentence ("the guard returns. More.") is not shown.
5. The reference regex at 117 requires `[S<n>]` immediately after `N. `; `1. **Title.** [S1]` would be refused.
6. A repeated reference is reported as both missing and extra (test 122–123: "missing [S2], unknown or repeated [S1]"), because the comparison is over sorted multisets via `comm` on sorted lists.
7. `numbered()` uses `${line%%.*}`, the text before the *first* dot. For `12. **A.** x` that is `12`. It would also accept a line like `3` alone, but `items()` requires `^[0-9]+\. ` so that cannot reach it.
8. The state is cleared with `rm -rf "$state"` (the whole `.claude/state/review` directory, including `files` and `fixed-point`), not just `dir`. This is what unblocks the delegation hook.
9. Rerunning with an explicit dir while a *newer* review's state is live prints the old comment and leaves the newer state intact (test 353–365) — the equality check at 159 is what makes this safe.
10. `$dir/fixed-point` is preferred over `$state/fixed-point` (153–154), which is why the "newer review" test can assert the old dir's `fixed point main.` while the live state says `other`.
11. `act - fixed_here - ticketed + ask` can in principle go negative if an item carried both marks, but both regexes are `$`-anchored so at most one can match per line.
12. `Ask` items are counted but can never be marked `fixed:`/`ticket:` out of the count — the greps at 149–150 only look under `## Act on`. SKILL.md:134 states the same rule in prose ("An Ask item is never fixed or filed away").
13. The `empty_spec` helper (66) exists but is used only once (108); most Spec fixtures are written inline.
14. The test's `refuse` helper asserts the entire captured output equals one line. Any extra stderr chatter (a warning, a `set -x` leak) fails every refusal assertion at once.
15. `tests/spec-review/layout.sh` has no shebang and is not executable by design (comment at line 7); running it directly does nothing useful.

### Open Questions

- Where a `restart` line would be printed relative to `round:` and `act-on items:` is a design choice #90 has to make; nothing in the current code or prose reserves a slot for it, and `SKILL.md:138` / `babysit.md:16` / `review-ladder.md:6` all currently say `act-on items:` is last.
- How a restart comment would be distinguished from an ordinary review comment by `review-brief.sh`'s round scan (133–137) is not traceable from today's code — that awk only recognizes `^round: [0-9]+ of 3$` and the `act-on items:` selector in the jq at `review-brief.sh:94`. That selector (`test("(^|\n)act-on items:")`) is what decides which comments count as reviews at all, so a restart comment lacking that line would be invisible to the round scan and to carry-forward. I did not trace `review-brief.sh` in depth — that is explorer-1's slice.
- Whether a `hole:` mark should also suppress the item from the carry-forward in `review-brief.sh` (it sits under Act on, and carry-forward only reads Noted and Dismissed) is unaddressed by anything I read.
- `tests/spec-review/no-stale-wording.sh` is run by CI but absent from the `AGENTS.md` "Verifying" list; I could not find a reason for the omission in the repo.
