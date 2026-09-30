# #108 design package, runner A

A refusal in `review-brief.sh` for a risk or a writer flag that carries no disposition, built on one line grammar that both checks share. The grammar was prototyped and run against 41 adversarial inputs on macOS awk (section 6). Every outcome below was observed, none assumed.

Shape in one paragraph. A **settled list** is the text under an **opener** heading. For risks the opener is `## Risks` or `### Risks` in the grounding. For flags it is `### Writer flags <YYYY-MM-DD>` in the ticket body. Inside a settled list, every unfenced, non-blank line indented no deeper than the list's first line is an **item**. Every item must end with a **disposition**: `fixed: <sha>`, where the sha is a commit in HEAD's history, or `accepted: <reason>`. A line shaped like an opener that is not exactly one is a **near-miss** and is refused. So is a fence opened inside a list that never closes. One shell function, `undisposed risks|flags`, prints what is wrong. The risk check runs where the Risks-heading check runs today. The ticket fetch moves up to sit before any state is written, and the flag check runs right after it. Both checks exit 1 and leave no state.

---

## 1. Scenario tables

### Legend

- **B** (briefed): exit 0. stdout prints the `ticket:` and `round:` lines (plus `settled:` or `restart:` when applicable), then the brief paths. `.claude/state/review/` and `.scratch/review/<id>/` are written. The caller hands the briefs to the reviewers.
- **B+** is B for a cross-cutting diff. Both briefs carry `## Blast radius` with the grounding verbatim, dispositions included. The Spec brief's Walk bullet ends with the new risk sentence (section 3).
- **B/np** is B plus the existing stderr line `review-brief: the diff is not cross-cutting; <file> is not pasted`.
- **B/ns** is B with `no spec: Standards axis only` as the last stdout line. Only the Standards brief is written.
- **RG** is the existing refusal for a missing grounding: `cross-cutting diff (<paths>) without a blast-radius grounding; ...`. Exit 1, no state, no dir.
- **RR[x]** is the new risk refusal (the message in section 2.4). Its per-line list is exactly `x`. Exit 1, no `.claude/state/review/`, no `.scratch/review/<id>/`. The caller settles the named risks and reruns.
- **RF[x]** is the new flag refusal, with the same shape and the same "nothing written". The caller edits the ticket body and reruns.
- **TOOL** is refused with the tool's own existing message. That path is unchanged and costs no code.
- `nd`, `nc`, `nr`, `nh`, `na`, `fo` and `nm` are the per-line reasons defined in the contract (2.3).
- `<where>` is `blast.md` in the file columns and `the PR body's Blast Radius section` in column P.

### Table A: the criterion's shapes, by review form

Columns (the review form):
- **F** is round 1, the whole diff, `--blast-radius blast.md`.
- **P** is round 1, the whole diff, no `--blast-radius`, with the grounding in the PR body's `## Blast Radius` section demoted to `### Risks` (`FAKE_PR_BODY`).
- **R** is a fix-only round 3. A `--previous` file carries round one's comment and round two's comment, the latter with `fix only after <r2>` (the `fo_comment` shape from #106). The fixed point is `<r2>`, and the cross-cutting commit comes after `<r2>`. `--blast-radius blast.md`.
- **S** is the sweep form: `--paths <hook> --commits HEAD --blast-radius blast.md`.

In the rows, "risks OK" means a grounding with `1. ... fixed: <HEAD short sha>` and `2. ... accepted: the hook exits 0 before any skill`. "One risk bare" means the same grounding with line 2 ending `... runs it` and no disposition. "Flags" is the ticket body that `FAKE_ISSUE_BODY` supplies.

| # | Situation | F | P | R | S |
|---|---|---|---|---|---|
| A1 | not cross-cutting; grounding with one risk bare; ticket with no list | B/np | B | B/np | B/np |
| A2 | cross-cutting; no grounding (F, R, S: a whitespace-only file; P: no PR) | RG | RG | RG | RG |
| A3 | cross-cutting; risks OK; ticket with no list | B+ | B+ | B+ | B+ |
| A4 | cross-cutting; one risk bare | RR[`nd: 2. ... runs it`] | RR[same] | RR[same] | RR[same] |
| A5 | cross-cutting; risks OK; flags list with flag 2 bare | RF[`nd: 2. flag nine: ...`] | RF[same] | RF[same] | RF[same] |
| A6 | not cross-cutting; flags list with flag 2 bare | RF[same as A5] | RF[same] | RF[same] | RF[same] |
| A7 | cross-cutting; one risk bare and flag 2 bare | RR[as A4] (the risk check runs first; no flag message) | RR | RR | RR |
| A8 | cross-cutting; risks OK; every flag dispositioned | B+; the Spec brief carries the list verbatim | B+ | B+ | B+ |
| A9 | cross-cutting; risks OK; no ticket (the commits name none, no `--ticket`) | B/ns (no flag check) | B/ns | TOOL (`round 3 reviews only the fix and its commits name no ticket ...`) | B/ns |
| A10 | cross-cutting; risks OK; `gh issue view` fails | B/ns plus the existing `gh could not fetch #7 (...); no spec` (no flag check) | same | same, run with `--ticket 7` so the round gate passes | same |

A1 through A6 are the criterion's rows: no grounding, grounding with every risk dispositioned, one risk without, a writer flag without, and a diff that is not cross-cutting. A7 through A10 answer the brief's questions about check order, no ticket, and a gh failure.

### Table B: the line grammar, by site

Column **r**: the line sits under `## Risks` in `blast.md`, on a cross-cutting diff, form F, with a ticket that has no list.
Column **f**: the line sits under `### Writer flags 2026-09-23` inside `## Testing decisions` of the ticket body, on a diff that is not cross-cutting.
The two columns share one code path. The second column proves that the flag site uses it. `<H>` is HEAD's short sha. `<X>` is a commit on a side branch, not in HEAD's history.

| # | Lines under the opener | r | f |
|---|---|---|---|
| B1 | `1. text fixed: <H>` | B+ | B |
| B2 | `1. text accepted: out of scope, #130` | B+ | B |
| B3 | `1. text` | RR[`nd: 1. text`] | RF[same] |
| B4 | `- a bullet item` | RR[`nd: - a bullet item`] | RF[same] |
| B5 | `1. first half` then, at column 0, `second half accepted: ok` | RR[`nd: 1. first half`] | RF[same] |
| B6 | `1. a accepted: ok`, an indented continuation, a fenced block holding `## x` and `1. y`, then `2. b fixed: <H>` | B+ | B |
| B7 | `1. the binary is not fixed: it stays stale` | RR[`nc(it stays stale)`] | RF[same] |
| B8 | `1. text fixed: 1234abc` (resolves nowhere) | RR[`nr(1234abc)`] | RF[same] |
| B9 | `1. text fixed: <X>` | RR[`nh(<X>)`] | RF[same] |
| B10 | `1. text accepted:` | RR[`na`] | RF[same] |
| B11 | `1. text accepted: partly, then fixed: <H>` (the last field wins) | B+ | B |
| B12 | `1. text fixed: <H> (the second commit)` | RR[`nc(<H> (the second commit))`] | RF[same] |
| B13 | ``1. text `fixed: <H>` `` (in backticks) | RR[`nd`] | RF[same] |
| B14 | `1. text fixed: ABCDEF1` | RR[`nc(ABCDEF1)`] | RF[same] |
| B15 | `1. a accepted: ok`, then ```` ```sh ```` that never closes, then `2. hidden` | RR[`fo: ```sh`] | RF[same] |
| B16 | `1. a accepted: ok`, `#### Risks` (r) or `#### Writer flags 2026-09-23` (f), then `2. b` | RR[`nm: #### Risks`, `nd: 2. b`] | RF[`nm: #### Writer flags 2026-09-23`, `nd: 2. b`] |
| B17 | `1. a accepted: ok`, `#### Proof` | RR[`nd: #### Proof`] | RF[same] |
| B18 | the opener and no lines (the next heading follows) | B+ (the #91 cell 8A, unchanged) | B |
| B19 | `  1. a accepted: ok`, `  2. b` (the whole list indented two spaces) | RR[`nd:   2. b`] | RF[same] |
| B20 | `1. a accepted: ok`, then a second exact opener, then `2. b` | RR[`nd: 2. b`] | RF[same] |
| B21 | `1. a accepted: ok`, then a heading at the opener's level (`## Cleared` in r, `### Test list` in f), then prose with no disposition | B+ | B |
| B22 | CRLF line ends and trailing spaces: `1. a fixed: <H>  \r` | B+ | B |

### Table C: the markers, by site

Column **r** is a line in `blast.md` that also holds an exact `## Risks` with `1. a accepted: ok`, on a cross-cutting diff. Column **f** is a line in the ticket body, on a diff that is not cross-cutting.

| # | The line | r | f |
|---|---|---|---|
| C1 | a plain marker: `Risks:` (r), `Writer flags:` (f) | RR[`nm: Risks:`] | RF[`nm: Writer flags:`] |
| C2 | the wrong level: `#### Risks` under `## Cleared` (r), `## Writer flags 2026-09-23` (f) | RR[`nm`] | RF[`nm`] |
| C3 | trailing text: `### Risks (two)` (r), `### Writer flags 2026-09-23 (PR #99)` (f) | RR[`nm`] | RF[`nm`] |
| C4 | lowercase: `## risks` (r), `### writer flags 2026-09-23` (f); for f also no date, `### Writer flags`, which is one more assertion | RR[`nm`] | RF[`nm`] ×2 |
| C5 | bold: `**Risks**` (r), `**Writer flags 2026-09-23**` (f) | RR[`nm`] | RF[`nm`] |
| C6 | an opener inside a fenced block, with its bare item | B+ | B |
| C7 | prose: `Risks here are low.` and `- **Risks.** day zero: x.sh:1` (r); ``- [ ] A writer's flags reach the ticket as a dated `Writer flags` list.``, `Writer flags are recorded by the orchestrator.` and `\| Writer flags \| x \|` (f) | B+ | B |

C7/f is the #108 ticket's own body. The review of the PR that ships #108 must not refuse its own ticket.

---

## 2. Contract

### 2.1 Terms

- **Opener.** An unfenced line that, after CR and trailing blanks are stripped, is exactly `## Risks` or `### Risks` (mode `risks`, as today, P28), or matches `### Writer flags YYYY-MM-DD` with four, two and two digits (mode `flags`). The opener's level is its count of `#`. A later opener starts a new list. Every list is checked, not only the first one.
- **Settled list.** The lines after an opener, up to the next unfenced heading (`^#+[ \t]`) whose level is no deeper than the opener's, or to the end of the text. A deeper heading inside the list is not an end. It is an item (B17), unless it is a near-miss (B16).
- **Fence.** The same rule the script already uses (`$fenced`, copied from `review-comment.sh`). Fenced lines are never items, openers or near-misses.
- **Item.** An unfenced, non-blank line in a settled list whose leading-whitespace length is at most the **base**. The base is the leading-whitespace length of the list's first non-blank, unfenced line. A deeper line is a continuation and is never read (B6). A bullet, a prose line, a deeper heading and a table row are all items. "One numbered risk per line" is the documented form. Every other form is still checked and never passes silently.
- **Disposition.** The field that starts at the last match of `(^|[ \t])(fixed|accepted):` on the item. Its value is the rest of the line with leading blanks trimmed. `fixed` needs a value of 7 to 40 lowercase hex characters, all the way to the end of the line. That value must resolve with `git rev-parse --verify -q <v>^{commit}` and be an ancestor of HEAD (`git merge-base --is-ancestor`). `accepted` needs a non-empty value. A token preceded by anything other than start of line, a space or a tab (a backtick, or the `pre` in `prefixed:`) is not a field.
- **Near-miss.** An unfenced line that is not an opener and either (a) is a heading whose text, lowercased, starts with the mode's word (`risks` or `writer flags`) followed by a non-letter or the end of the line, or (b) consists only of the word, optionally wrapped in `*` or `_`, optionally followed by digits, spaces or `-`, with an optional `:` or `.`. Prose that goes on past the word is never a near-miss (C7). A near-miss heading ends the current list when its level is no deeper than the opener's.
- **Unclosed fence.** A fence that opens inside a settled list and is still open at the end of the text. A fence left open outside a list is not this check's business (adversarial input R15), which keeps "a ticket with no list is unaffected" true.

### 2.2 Where the checks sit, and in what order

1. The existing refusals run unchanged, up to and including the Risks-heading check (lines 318-345).
2. New: the risk check. It runs only for a cross-cutting diff that has a grounding with a Risks heading: `printf '%s\n' "$grounding" | undisposed risks`. Non-empty output means RR: `rm -rf "$dir"`, the message, `exit 1`. For a diff that is not cross-cutting the grounding is never read, as today (A1).
3. Moved: the ticket fetch block (today lines 386-395). It moves unchanged to just after the grounding block and before the reading pack, so it runs before `state=`. It still writes `$dir/ticket.md`, which now exists before the refusal and is removed with `$dir`.
4. New: the flag check. It runs when `$spec` is non-empty, at every round and in both forms: `printf '%s\n' "$spec" | undisposed flags`. Non-empty output means RF, with the same cleanup. With no ticket, or when gh fails, `$spec` is empty and the check does not run (A9, A10). The existing `no spec` line says so on stderr in the gh case.
5. The reading pack and the state writes run as today.

The risk check runs before the flag check (A7). One refusal at a time is enough. The fix-then-rerun loop is two short cycles at worst.

Rounds. Neither check branches on the round. Rounds 1 to 5, fix-only rounds and the sweep form all run both checks (Table A, columns R and S). The P20 gates, the round arithmetic and the fix-lines logic are untouched. Both checks run after the round gates, so a refused fourth round is still refused with its own message first.

### 2.3 Per-line reasons (the fixed vocabulary)

| Key | Printed reason |
|---|---|
| nd | `no disposition` |
| nc(v) | `` `fixed: v` is not a commit id (7 to 40 lowercase hex characters) `` |
| nr(v) | `` `fixed: v` does not resolve to a commit here `` |
| nh(v) | `` `fixed: v` is not in HEAD's history `` |
| na | `` `accepted:` has no reason `` |
| fo | `a fence opened here never closes` |
| nm | risks: `` not the heading `## Risks` or `### Risks` ``; flags: `` not the heading `### Writer flags <YYYY-MM-DD>` `` |

Each offending line prints as two spaces, the reason, `: `, then the line as written (with CR and trailing blanks stripped, leading blanks kept). The lines print in text order.

### 2.4 The refusal messages

The risk refusal goes to stderr after the stdout `ticket:`/`round:` lines, as with every refusal today:

```
review-brief: the blast-radius grounding (<where>) has risk lines without a disposition; under a Risks heading every line that is not indented deeper or fenced is a risk, and it ends with `fixed: <sha>` (a commit in HEAD's history) or `accepted: <reason>` as plain text; indent a continuation and fence a proof:
  no disposition: 2. day zero runs it
```

The flag refusal:

```
review-brief: ticket #<N> has Writer flags without a disposition; under a heading that is exactly `### Writer flags <YYYY-MM-DD>` every line that is not indented deeper or fenced is a flag, and it ends with `fixed: <sha>` (a commit in HEAD's history) or `accepted: <reason>` as plain text; indent a continuation and fence a proof:
  no disposition: 2. flag nine: the table misses a row
```

Both headers name every correction the reasons can call for, so one message covers the near-miss and fence lines too.

---

## 3. The risk sentence (criterion 3)

The new text, carried word for word in `review-brief.sh` (`risk_rule`), in `spec-review/SKILL.md` step 4's Walk bullet, and in `tests/spec-review/review-brief.sh` (`risk_rule`, which the `has` check pins):

> The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk, saying what the diff does at that risk, and saying whether the diff honors the disposition the risk's line ends with (for `fixed: <sha>`, whether that commit fixes the risk; for `accepted: <reason>`, whether the reason holds for this diff); a risk line is a walk line and counts nothing.

It stays one fixed sentence, with no level and no count (P28's reason). Its last clause is unchanged, so P23 holds. A disposition the diff does not honor becomes a finding only through the existing definition sentence. The sentence does not add a counting rule. The synthesizer may add "and one the diff does not honor is also an item under `## Would break` or `## Fails open`", but that goes beyond criterion 3.

---

## 4. Usage, signatures, module map

### 4.1 The one new function (in `review-brief.sh`, after `$fenced`)

```bash
# undisposed <risks|flags>: reads Markdown on stdin and prints, in text order, one line
# `  <reason>: <line>` per item of a settled list that lacks a valid disposition, per near-miss
# opener, and per fence opened inside a list that never closes; prints nothing when every list is
# settled. The awk classifies (pure); the loop does the git checks. An item is a line under an
# opener that is neither fenced nor indented deeper than the list's first line.
undisposed() {
  local w=risks; [ "$1" = risks ] || w="writer flags"
  awk -v mode="$1" -v w="$w" "$disposed" | while IFS=$'\037' read -r kind value line; do
    # none | near | fence | accepted | fixed -> reason or continue (section 2.3)
  done
}
```

The awk program `disposed` is the prototype's (below). Its fields are separated by `\037`, not a tab, because `read` collapses consecutive tabs and an empty value field would shift the line into it. This came up while prototyping.

```awk
function field(s,   rest, off, k, v) {        # the last fixed:/accepted: field, or none
  k = ""; off = 0; rest = s
  while (match(rest, /(^|[ \t])(fixed|accepted):/)) {
    k = (substr(rest, RSTART, RLENGTH) ~ /fixed:$/) ? "fixed" : "accepted"
    off += RSTART + RLENGTH - 1; v = substr(s, off + 1); rest = v
  }
  if (k == "") return "none" US
  sub(/^[ \t]+/, "", v); return k US v
}
BEGIN { US = "\037"; base = -1 }
{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }
/^(```|~~~)/ && fence == "" { opened = on ? $0 : "" }
# ... "$fenced" spliced here ...
{ t = tolower($0); lv = 0; if (match($0, /^#+[ \t]/)) lv = RLENGTH - 1 }
(mode == "risks" && ($0 == "## Risks" || $0 == "### Risks")) ||
(mode == "flags" && $0 ~ /^### Writer flags [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) { on = 1; top = lv; base = -1; next }
{ x = t; sub(/^#+[ \t]+/, "", x) }
(lv && index(x, w) == 1 && substr(x, length(w) + 1, 1) !~ /[a-z]/) ||
t ~ ("^[*_]*" w "[ 0-9-]*[*_]*[:.]?[*_]*$") { print "near" US US $0; if (lv && lv <= top) on = 0; next }
lv && lv <= top { on = 0; next }
!on || $0 == "" { next }
{ match($0, /^[ \t]*/); if (base < 0) base = RLENGTH; if (RLENGTH > base) next; print field($0) US $0 }
END { if (fence != "" && opened != "") print "fence" US US opened }
```

The script never uses interval expressions in awk (its comment on the `reviewed:` check says so), and neither does this. The hex length check is `grep -qE '^[0-9a-f]{7,40}$'` in the shell loop.

### 4.2 Call sites (both refusals: `rm -rf "$dir"`, message, `exit 1`)

```bash
# after the Risks-heading check, inside `if [ -n "$crossing" ]`; `where` is hoisted out of that check
bad="$(printf '%s\n' "$grounding" | undisposed risks)"
if [ -n "$bad" ]; then rm -rf "$dir"; echo "review-brief: the blast-radius grounding ($where) has risk lines ...:" >&2; printf '%s\n' "$bad" >&2; exit 1; fi

# the moved ticket fetch, unchanged, then:
if [ -n "$spec" ]; then
  bad="$(printf '%s\n' "$spec" | undisposed flags)"
  if [ -n "$bad" ]; then rm -rf "$dir"; echo "review-brief: ticket #$ticket has Writer flags ...:" >&2; printf '%s\n' "$bad" >&2; exit 1; fi
fi
```

### 4.3 Module map (what the implementation touches)

Commit order, per criterion 4: tests first, then the script, then the prose.

1. `tests/spec-review/fake-gh.sh`. `gh issue view --json body` prints `$FAKE_ISSUE_BODY` when that names a file (the fixed body otherwise), and exits 1 with the contents of `issue-error` on stderr when that file exists. Unset, it behaves as today, so the CI fixture step is unaffected.
2. `tests/spec-review/review-brief.sh`. The three tables, one assertion per cell in table order, plus the updated `risk_rule` and the updated #91 fixtures (section 5).
3. `template/.agents/skills/spec-review/scripts/review-brief.sh`. `undisposed` and `disposed`, the two checks, the moved fetch, the new `risk_rule`, and the header comment.
4. `template/.agents/skills/spec-review/SKILL.md` gets three changes, and then `patches/mattpocock/spec-review.SKILL.md.patch` is regenerated:
   - In step 1's cross-cutting paragraph, one sentence on the disposition refusal with the message's first clause.
   - In step 1, one sentence on the flag refusal, where the ticket is named.
   - In step 4, the Walk bullet's risk sentence.
5. `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`, the Blast Radius bullet, then its patch is regenerated (criterion 5):
   > Each line under `### Risks` is one risk and ends with its disposition as plain text, `fixed: <sha>` (the commit on this branch that fixes it) or `accepted: <reason>`, for example `` 1. A subagent inherits the hook before its skill is installed: `.claude/hooks/x.sh:12`. fixed: 3f2a9c1 ``; a continuation is indented and a proof is fenced, and `review-brief.sh` refuses the review while a risk line has none.
6. `template/.agents/skills/blast-radius/SKILL.md`, the Risks bullet of "What to hand back" (criterion 5). This file has no patch today and is identical to `research/3-pstack/open-pstack-claude-code-port/.../blast-radius/SKILL.md`. So the change needs a new `patches/pstack/blast-radius/SKILL.md.patch`, a `series` line and a new numbered `SOURCES.md` item:
   > - **Risks.** Only the real ones, one per line. Each names how it breaks, the `file:line`, how likely and how bad, and how to check. Paste the proof for the ones that matter, fenced under its risk. Once the author has acted on a risk, its line ends with the disposition: `fixed: <sha>` or `accepted: <reason>`, as in `` 1. A subagent inherits the hook: `.claude/hooks/x.sh:12`, likely, blocks every read. fixed: 3f2a9c1 ``.
7. `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, no patch):
   - Step 5: after "one numbered risk per line under `## Risks`", add "each ending with its disposition once acted on (Opening a PR)".
   - Step 6: add one sentence: "A writer's flags go on the ticket the same way, under a heading that is exactly `### Writer flags <YYYY-MM-DD>` inside the `## Testing decisions` or `## Design` section, one numbered flag per line ending with `fixed: <sha>` or `accepted: <reason>`; `review-brief.sh` refuses the review while a flag has none, or while a heading looks like that one and is not."
8. Recommended: the four "(#108 adds the refusal that enforces it)" parentheticals in `feature.md`, `bug-fix.md`, `refactoring.md` and `perf-issue.md`, and their four patches. Once #108 merges each one is stale. The replacement is "(Ticket step 6 gives the form; `review-brief.sh` refuses the review while one has none)". Skip it if the synthesis wants the smallest diff. The cost is four stale pointers, not a wrong rule.
9. `docs/knowledge/core/DECISIONS.md`:
   - A Provisional row, P108, for the grammar and the placement.
   - Amend P28 with "Amended 2026-09-23 (#108): the sentence also asks whether the diff honors each risk's disposition". Rows P20, P23, P106 and P107 are unchanged.
   - Then run `python3 tools/build_knowledge.py`.
10. `SOURCES.md`: item 3 gets the disposition line and item 6 gets the two refusals and the new sentence. Then run `./factory918.sh sync` to confirm the patches reproduce the template byte for byte.

No new file except the one patch. That patch is forced: every vendored-file edit goes through `patches/`.

---

## 5. Test list (one assertion per cell, in table order)

Shared fixtures, extending #91's block (the `echo 'exit 0' > "$hooks/x.sh"` commit "a hook, #7"):
- `H=$(git rev-parse --short HEAD)`.
- A side commit `X`: `git checkout -q -b side HEAD~1`, commit, record its short sha, `git checkout -q -`.
- `risks-ok.md`: `## Risks` with `1. A subagent inherits it: .claude/hooks/x.sh:1. fixed: $H` and `2. factory-start at day zero runs it accepted: the hook exits 0 before any skill`.
- `risks-bare.md`: the same file with line 2 ending `runs it`.
- `pr-ok.md` and `pr-bare.md`: PR bodies with the same text demoted to `### Risks`.
- `ticket-nolist.md`, `ticket-flags-ok.md` and `ticket-flags-bare.md`. The last two have `## Testing decisions`, then `### Writer flags 2026-09-23`, then `1. flag one fixed: $H` and `2. flag nine: the table misses a row` (with `accepted: filed #130` in the ok variant).
- A helper `form <F|P|R|S> <grounding>` sets the args (and `FAKE_PR_BODY` for P) for the column.
- A helper `refused_disp <label> <expected-output>` asserts exit 1, the combined output byte for byte, and that neither `.claude/state/review` nor the column's `.scratch/review/<id>` exists.
- A helper `briefed <label>` asserts exit 0 and both files present.

Existing cells that change: the #91 fixtures `blast-risks.md`, `blast-risks-demoted.md`, `blast-both.md` and `pr-body.md` gain `accepted: fixture` on each numbered risk line. Otherwise cells 1A, 2A, 7A and 3A would turn into RR. 8A (an empty Risks heading) passes unchanged, and so does B18. 5A, 6A, 9A, 4A and 10 are unchanged.

Table A, rows A1 to A10, each across F, P, R, S:
1. A1: F, R and S carry B/np on stderr and write the briefs. P writes the briefs and prints nothing on stderr.
2. A2: all four print RG, and nothing is written.
3. A3: all four exit 0. The grounding lines, dispositions included, are in both briefs, and the Spec Walk bullet ends with the new `risk_rule`.
4. A4: all four print RR with `  no disposition: 2. factory-start at day zero runs it`. `<where>` is the file for F, R and S, and the PR body for P.
5. A5: all four print RF with `  no disposition: 2. flag nine: the table misses a row`.
6. A6: the same as A5 on the `a.txt` commit, which is not cross-cutting.
7. A7: all four print RR as A4, and the output holds no `Writer flags`.
8. A8: all four brief, and the Spec brief holds `### Writer flags 2026-09-23` and both flag lines.
9. A9: F, P and S end in `no spec: Standards axis only`. R prints the existing `pass --ticket N` refusal.
10. A10 (with `issue-error` present): F, P and S end in B/ns with the `gh could not fetch #7` line. R with `--ticket 7` ends in B/ns.

Table B: rows B1 to B22 across columns r and f, 44 assertions. Each is either `briefed` or `refused_disp` with the exact reason lines from the table. B9 uses `X`.

Table C: rows C1 to C7 across columns r and f, 15 assertions (C4/f has two).

Doc pins (`has`):
- `SKILL.md` step 4 carries the new `risk_rule`. This replaces the old pin.
- `opening-a-pr.md` carries `ends with its disposition as plain text, \`fixed: <sha>\``.
- `blast-radius/SKILL.md` carries `its line ends with the disposition: \`fixed: <sha>\` or \`accepted: <reason>\``.

These pins hold criterion 5 in place.

---

## 6. Adversarial inputs tried (prototype run on macOS awk, in this worktree)

`ON` is `355fea6`, an ancestor of HEAD. `OFF` is `798c91e`, from `feat/review-blast-radius`, not in HEAD's history. Every outcome was observed.

| Input | Outcome |
|---|---|
| R01: one risk `fixed: ON`, one `accepted: ...` | pass |
| R02: the second risk bare | `no disposition: 2. day zero runs it` |
| R03: `- a bullet risk` under `### Risks` | `no disposition` (a numbered-only rule would have passed it silently) |
| R04: a risk wrapped onto a column-0 line that ends `accepted: fine` | the first half is named `no disposition`. The fix is to join the lines or indent the second |
| R05: an indented continuation, then a fence holding `## not a heading` and `1. not a risk`, then `2. ... fixed: ON` | pass |
| R06: `1. the cached binary is not fixed: it stays stale` | `` `fixed: it stays stale` is not a commit id `` |
| R07: `fixed: 1234abc` | `does not resolve to a commit here` |
| R08: `fixed: OFF` | `is not in HEAD's history` |
| R09: `accepted:` with nothing after it, or only spaces | `` `accepted:` has no reason `` for both |
| R10: `accepted: partly, then fixed: ON` | pass (the last field wins, so the value is a valid sha) |
| R11: `fixed: ON (the second commit)` | `not a commit id` |
| R12: `` `fixed: ON` `` in backticks | `no disposition` |
| R13: `fixed: ABCDEF1` | `not a commit id` |
| R14: an unclosed fence under Risks hiding `2. hidden risk` | ``a fence opened here never closes: ```sh`` |
| R15: an unclosed fence before any Risks heading | nothing from this check. The Risks-heading check refuses it, because its heading is fenced (#91 6A) |
| R16: `#### Risks` inside the list, then `2. b` | `nm: #### Risks` and `no disposition: 2. b` |
| R17: `#### Proof` inside the list | `no disposition: #### Proof` |
| R18: an empty Risks heading | pass (#91 8A holds) |
| R19: the whole list indented two spaces, with the second item bare | `no disposition:   2. b`. The base is the first item's indent, so an indented list cannot pass silently |
| R20: a second exact `### Risks` whose item is bare | `no disposition: 2. b` |
| R21: `### Cleared` after the list, then prose | pass (the list ends at the same level) |
| R22: the hand-back bullet `- **Risks.** ...` before the heading | pass (not a near-miss) |
| R23: `the prefixed: path and unfixed: glob` | `no disposition` (neither is a field) |
| R24: CRLF line ends plus trailing spaces | pass |
| R25: `fixed:ON` with no space | pass (unambiguous, so it is accepted) |
| R26: a plain `Risks:` line under `## What` | `nm: Risks:` |
| R27: `Risks here are low.` | pass (prose) |
| R28: `fixed: ` followed by 40 zeros | `does not resolve` |
| F01: a list with every flag dispositioned | pass |
| F02: `2. flag nine: the table misses a row` | `no disposition` |
| F03: `Writer flags:` as plain text | `nm` |
| F04: `## Writer flags 2026-09-23` | `nm` |
| F05: `### Writer flags` with no date | `nm` |
| F06: `**Writer flags 2026-09-23**` | `nm` |
| F07: the opener inside a fence | pass (GitHub renders it as code too) |
| F08: #108's own criteria line, a sentence starting "Writer flags are ...", and a table row | pass |
| F09: a body with no list | pass |
| F10: `### Test list` after the list, then `1. assertion one` | pass (the list ended) |
| F11: `### Writer flags 2026-09-23 (PR #99)` | `nm` |
| F12: two dated lists, where the second has a bare flag | `no disposition: 1. b` |
| F13: `### writer flags 2026-09-23` | `nm` |

These holes remain, and are named and accepted:

1. A risk written under a same-level heading after the Risks list. In a PR body, `### Proof` then `2. b` ends the list, so `2. b` is not read. GitHub renders `2. b` under "Proof" too, and the Spec walk also stops at the list's end, so the refusal and the walk agree.
2. `fixed: <sha>` naming an old commit that is in HEAD's history but is not the fix. The check proves only that the commit is here. The walk sentence asks the reviewer whether that commit fixes the risk. Requiring the commit to be in `fixed..HEAD` instead would refuse every fix-only round, whose fixed point comes after round one's fixes.
3. A flag list posted in a ticket comment instead of the body is not read. The criterion names the body, and Ticket step 6 writes the body.

---

## 7. Rationale and rejected alternatives

- **An item is any unindented line, not only a numbered one.** One rule, no list parsing. Every form an author might use (bullets, prose, tables, deeper headings) is checked or refused. Numbered-only fails open on R03. Refusing every non-numbered line in the list would also refuse legitimate indented proof text.
- **The disposition is the last field on the risk's own line.** The ticket says "on the risk's own line". The judgment's trailing `fixed: <sha>` and `ticket: #N` fields already use this position, and so does `review-comment.sh`'s "last `hole:`" rule, so one reading convention serves all three. A separate disposition line was rejected. It would need pairing logic, and an orphaned disposition line would be ambiguous.
- **The sha must resolve and be an ancestor of HEAD.** A "fixed" risk whose commit is not in the reviewed history is a claim the reviewer cannot check. It is the documented path giving a silent wrong result. Format-only checking passes R07, R08 and R28. `fixed..HEAD` breaks fix-only rounds. The cost of the chosen rule: after a rebase, the PR body's shas go stale and the brief refuses, naming each one. That failure is loud and costs one edit, and a stale claim is exactly what the review should not accept.
- **Near-misses are refused.** A mistyped opener would otherwise hide its whole list, which fails open. The detection is narrow (headings, or a line holding only the word) so that prose never trips it. #108's own ticket body passes (F08).
- **The flag check reads the whole body, not only `## Testing decisions` or `## Design`.** Placement is prose (Ticket step 6). Enforcing it would add a refusal that closes no fail-open.
- **The fetch moves, not a second fetch.** One gh call is kept. The block moves about 40 lines up, unchanged, and `$dir/ticket.md` still exists for anything that reads it (nothing does today).
- **The same grammar serves both sites through one function.** Two grammars would drift. The Table B columns prove both sites share it.
- **Rejected: a separate `dispositions.sh`.** It has one caller and about 30 lines. It stays in `review-brief.sh` beside `$fenced`, which it reuses. P107 split the reading pack out to avoid collisions with #108, and nothing here needs that.
- **Rejected: refusing an unclosed fence anywhere in the ticket.** That would break "a ticket with no list is unaffected". The check covers only a fence opened inside a list.
- **Rejected: counting an undispositioned or dishonored risk in the report.** Criterion 3 asks the reviewer to say it. P23 keeps walk lines uncounted.

## 8. Principles that shaped it

- **Laziness Protocol.** It kept everything to one function and one grammar, with no new script, and it moved the ticket fetch instead of duplicating it.
- **Boundary Discipline.** The checks sit at the script's input boundary, the grounding and the ticket body, before any state is written. The awk is a pure classifier, and git is consulted only in the shell loop.
- **Prove It Works.** Every cell outcome in section 6 was observed by running the prototype awk on macOS. The prototype also caught the tab-separator collapse, which is why fields are separated by `\037`. Ubuntu's mawk in CI is the one runtime not yet exercised, and the writer should run the suite there. Nothing in the program is gawk-specific.
- **Encode Lessons in Structure.** The rule that a delegate's report is an act-on list (#105) becomes a refusal instead of more prose.
