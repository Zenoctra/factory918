=== [Zenoctra 2026-09-22T02:25:15Z] https://github.com/Zenoctra/factory918/pull/92#issuecomment-5770336359
Round one found two hard items, both real and both fixed on this PR next: the go example in the router row and the autopilot-stack clause reads the ticket numbers as a shell comment, and the one-off go writes the PR number into its label where the check needs the ticket that PR closes. Neither changes a cell of the ticket's scenario table, so neither returns to architect; two cheap standards points go with them.

## Standards

# Standards report

## Would break

1. **The documented `go` command is a shell comment from `#a` on.** In bash and zsh a word beginning `#` starts a comment, so the ticket numbers never reach the script. Verified: `bash -c 'f(){ echo "argc=$#"; }; f go "autopilot-stack" #4 #5 #8'` prints `argc=2` (zsh the same). The script itself accepts `#N` — `tests/poteto-mode/overlap.sh:142` passes it as `'#9'`, quoted, so the test never exercises the documented form. Standard: `CODING_STANDARDS.md`, Bash, "Test a command the way a user types it".

Documented step: `template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md:7` — ``run `.claude/skills/poteto-mode/scripts/overlap.sh go "autopilot-stack" #a #b ...` (the unit tickets)``. Same form at `template/.agents/skills/factory918/SKILL.md:56`, `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch:11`, `SOURCES.md:21`.

Result: `overlap.sh` receives two arguments, `[ $# -ge 3 ] || usage` fires, exit 64, no line is appended to `.claude/state/program`. Every owner lane's Ticket step 1 then reads `go: none` and exits 1 on the first overlap, so the go the human gave covers nothing. The `N...` form used at `ticket.md:5` and in P24 is correct.

```
+3. **Hold the operator gates.** ... and run `.claude/skills/poteto-mode/scripts/overlap.sh go "autopilot-stack" #a #b ...` (the unit tickets), the go owners read in Ticket step 1, ...
```

## Fails open

## Standards breaches

2. **The new script under a vendored skill is not described in `SOURCES.md`.** `overlap.sh` is ours, added to `keep_files` so `sync` preserves it, but no entry records that. The precedent is item 6, "Both scripts are in `sync`'s `keep_files`." Standard: `AGENTS.md`, "Vendored skills … described in `SOURCES.md`, so `factory918 sync` can re-apply it." Item 11 names only the autopilot-stack patch.

```
-  local keep_files="poteto-mode/playbooks/ticket.md spec-review/scripts/review-brief.sh ...
+  local keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh ...
```

3. **Unquoted path in the new test.** `CODING_STANDARDS.md`, Bash, "Quote every path. Paths here contain spaces." `tests/poteto-mode/overlap.sh` quotes everything except `$prog` (lines 140-178, ten occurrences). The value is relative and space-free today, so behavior is unchanged; the fixture root deliberately has a space.

```
same "19 the line" 'sweep: #7 #9' "$(cat $prog)"
rm $prog
```

## Fix alongside

4. **Duplicated Code.** The same `while IFS=$'\t' read -r num head closes; do … done <<< "$prs"` walk appears three times in `overlap.sh` (`:55`, `:65`, `:84`), twice binding `closes` it never reads. Fold the fetch specs and the nearest-base scan into one pass, or parse `$prs` once into arrays.

```
while IFS=$'\t' read -r num head closes; do
```

5. **Mysterious Name.** `l` (the program line), `d` (commits between), `holds`, `toks`, `o`/`h` in `overlap.sh:51,63-70,76,88-93`. The header comment carries the meaning the names do not.

```
l="$(grep -w -- "#$n" "$prog" 2>/dev/null | tail -n 1 || true)"
```

hard findings: 1

## Spec

# Spec report

## Walk

1. `MANUAL.md:79` states the three cases and that overlap is not coupling (criterion 1).
2. `SKILL.md:55-56` routes `#N` to the check and several tickets to the three cases, naming the coverage rule (criterion 2).
3. `ticket.md:5` step 1: fetch, dirty check, then `.claude/skills/poteto-mode/scripts/overlap.sh N`, branch from the `base:` line.
4. `overlap.sh:36-49` validates args: 64 on no N, a third argument, a flag other than `--diff`, a non-numeric ticket.
5. `:52-54` the newest program line naming `#N` becomes the `go:` line; `covered` starts 1 only with a go.
6. `:56-60` no origin: stderr, `go`, `base: main`, exit 0; `gh` never called (row 12).
7. `:63-67` backticked whitespace-free tokens from the body, `## Diff` skipped, deduped; no token → `paths: none`, no PR loop (row 7).
8. `:71-78` `gh pr list --state open --limit 100`, then one forced fetch of `main` and every head (row 9).
9. `:282-292` `nearest` = the open-PR head under the ref with the fewest commits between, the ref's own head never, else `origin/main`.
10. `:303-312` per PR, `git diff --name-only nearest...head -- tokens` → `#n head: paths` ascending; a printed PR that closes no ticket, or whose ticket is on no line, clears `covered` (row 3).
11. `:320-329` exit 1 when uncovered; else `base:` = the printed head containing every other, else the lowest number's, else `origin/main` (rows 2B–2D).
12. `ticket.md:12` step 8 runs `--diff`: own paths from `nearest HEAD...HEAD`, own PR skipped, literal pathspecs (`:294-299`), output pasted as `## Overlap` (rows 1E, 2E).
13. `autopilot-stack.md:7` step 3 writes the program line on the operator's go, the only writer (`:41-46`).
14. `MANUAL.md:81` "Draining the frontier": coupled work only, patch-id keeps a rebase to one re-review (criterion 3).
15. `ledger.md:22` records the seven-re-reviews mis-estimate (criterion 4); P24, the CI step, `sync`'s `keep_files` and the 203-line test carry it.

## Would break

1. **The one-off go the reply offers never covers, so step 1 loops.** Coverage needs the ticket *each printed PR closes* on some line (`overlap.sh:310-311`). `overlap.sh go "stack on #M" N` writes `stack on #M: #N`: the ticket, and the PR *number* inside the label, never that PR's closing ticket. Outside a program there is no other line, so the re-run prints the same `go:` and `L(k)` and exits 1 again. Test 27 passes only because a program line already carried `#7`.

Documented step:

```
`stack #N on #M` is a go for that one stack: run `overlap.sh go "stack on #M" N`, then this step again.
```

```
| 1. No go names N | ... | `G none`, `L(k)` / 1 / stop; reply: merge #k or say `stack #N on #M` |
```

Result: unchanged exit 1 and the same output; the human's only offered alternative to merging #k cannot be taken, and the agent re-runs a step that can never pass.

## Fails open

## Not asked for

hard findings: 1

## Judgment

## Act on

1. [S1] **The documented `go` example is a shell comment from `#a` on.** Real, verified by the reviewer. The contract's `N...` form is unaffected (the table's cell is unchanged), so this is an implementation bug in the example text: the router row, the autopilot-stack clause (through its patch) and SOURCES item 11 show bare numbers, `go "autopilot-stack" 4 5 8`.
2. [S2] **The kept script has no SOURCES entry.** Real; item 6 is the precedent. One sentence under item 11.
3. [S3] **`$prog` unquoted in the test.** Real breach of "Quote every path"; the fixture path has a space by design. Quote the ten occurrences.
4. [P1] **The one-off go never covers outside a program.** Real. The design defined M as the ticket the printed PR closes, but the playbook never says so and the label carries M as text, not as a covered ticket. The cell's outcome (stop, reply) is unchanged, so this is fixed on the PR, not returned to architect; the table's reply text gains the definition. Fix: step 1 says `stack #N on #M`, M the ticket the printed PR closes (the reply names it), and the command is `overlap.sh go "stack on #M" N M`, so the line reads `stack on #M: #N #M`; a test asserts a one-off go alone covers, with no program line present.

## Ask

## Consider

## Noted

5. [S4] **The `$prs` walk appears three times.** Valid; no Act on fix touches those loops, and folding them is a refactor of reviewed code for no behavior.
6. [S5] **Short names in the script.** Valid; the header carries the meaning; renaming is not worth a round.

## Dismissed

Standards: 1 would break, 0 fail open, of 5; Spec: 1 would break, 0 fail open, of 1; judged: act on 4 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point origin/main.
round: 1 of 3
act-on items: 4

Claude Fable 5.1 on Claude Code


=== [Zenoctra 2026-09-22T02:37:43Z] https://github.com/Zenoctra/factory918/pull/92#issuecomment-5770423595
Round two found one hard item, a detached HEAD at the record step that reports the ticket's own PR instead of refusing, and one standards breach, an ancestry test that reads a git error as no. Both are fixed on this PR next under the contract's existing exit 2; no cell of the ticket's scenario table changes, so nothing returns to architect.

## Standards

# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

1. **A git error reads as "not an ancestor".** Both ancestry tests in `overlap.sh` swallow every nonzero exit, so a git failure (128) becomes the semantic answer "no". In `nearest` that drops the parent head and silently falls back to `origin/main`, which widens a stacked PR's "own commits" to include its parent's; in the base loop it silently drops the containing head and leaves the lowest number's. Standard: `CODING_STANDARDS.md`, Bash — "A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command ... never hide it." Behavior on the documented path does not change, because the preceding `git fetch` guarantees every `origin/<head>` exists; the fix is to accept exit 1 and let anything else reach the `ERR` trap.

```
    git merge-base --is-ancestor "origin/$head" "$1" || continue
...
  for o in "${printed[@]}"; do git merge-base --is-ancestor "origin/$o" "origin/$h" || holds=0; done
```

## Fix alongside

2. **Duplicated Code.** The same `prs` walk is written three times — once to build `specs`, once inside `nearest`, once to print. Each repeats the field split and the `[ -n "$num" ]` guard, so a change to the `pr list` columns is three edits. One loop that fills parallel arrays, or one helper both call, would hold the shape once.

```
while IFS=$'\t' read -r num head closes; do
  [ -n "$num" ] || continue
```

3. **`--limit 100` truncates silently.** Past 100 open PRs the check reports `base: origin/main` for a ticket that does overlap, with nothing on stderr. Outside this repository's reality, and the brief grades it unlikely; if it is ever cheap, `--limit` plus a count check that refuses is a two-line fail-loud.

```
prs="$(gh pr list --state open --limit 100 --json number,headRefName,closingIssuesReferences \
```

4. **Mysterious Name.** `l`, `d`, `o`, `h` and `holds` carry the go line, the commit distance, the compared heads and the containment verdict. The script's header prose names all four concepts; the variables do not.

```
l="$(grep -w -- "#$n" "$prog" 2>/dev/null | tail -n 1 || true)"
```

hard findings: 0

## Spec

# Spec report

## Walk

1. `MANUAL.md` Execution now names the three relations and says overlap is not coupling; `template/docs/factory918/MANUAL.md:60` carries the same text (AC1).
2. A new "Draining the frontier" paragraph routes autopilot-stack to coupled work and states the patch-id rule: one re-review, not one per PR above (AC3).
3. Router `factory918/SKILL.md:55` sends `#N` to Ticket step 1 and names the check; `:56` splits the three cases and the `go` line (AC2).
4. `ticket.md:5` step 1 runs `overlap.sh N` after the dirty check, branches from the printed `base:`, stops on exit 1 with the merge-or-`stack #N on #M` reply, and on exit 2 reports stderr.
5. `overlap.sh:33-35` takes the newest program line holding the word `#N` as `go:`; with none, `go: none` and `covered=0`.
6. `:37-41` no origin: notice on stderr, `go`, `base: main`, exit 0, `gh` never called (row 12).
7. `:43-49` tokens are the body's backticked whitespace-free strings, `## Diff` skipped, deduped; none gives `paths: none`, `base: origin/main`, no PR loop (row 7).
8. `:52-59` one `gh pr list` sorted by number, then one forced fetch of `main` and every head (row 9).
9. `:63-73,87` `nearest` is the open-PR head under a ref with the fewest commits, its own never, else `origin/main`; each PR's own commits are diffed against the tokens as pathspecs, ascending.
10. `:91-92` a printed PR clears `covered` unless it closes a ticket whose number is a word on some program line; `:103` exits 1 uncovered, with no base.
11. `:104-110` the base is the printed head containing every other, else the lowest PR number's.
12. `ticket.md:12` step 8 runs `--diff`: own paths from `nearest HEAD` (`:77`), literal pathspecs, the own PR skipped (`:86`); the output is the `## Overlap` section.
13. `autopilot-stack.md:7` step 3 appends the program line on the go; ledger, `SOURCES.md`, `factory918.sh:381` keep-file, CI and `AGENTS.md` follow (AC4).

## Would break

## Fails open

1. **A detached HEAD makes step 8 report the ticket's own PR.** `:75` sets `cur="$(git branch --show-current)"`, which is empty on a detached HEAD and is never checked. `:86`'s `[ "$head" != "$cur" ]` then matches every PR, so the own PR is diffed like any other.

```
`--diff`: own paths = `git diff --name-only $(nearest HEAD)...HEAD`, the own PR's head excluded; the per-PR diff runs with `GIT_LITERAL_PATHSPECS=1`; the PR whose head is the current branch is skipped.
```

Documented step: the Contract's `--diff` rule above, run at `template/.agents/skills/poteto-mode/playbooks/ticket.md:12`.
Result: step 8 writes an `## Overlap` section naming the ticket's own PR and exits 1, so the reply tells the human to merge the PR being opened before opening it. Nothing refuses the empty `cur`; an `exit 2` with "detached HEAD; run from the ticket's branch" would be the refusal.

## Not asked for

hard findings: 1

## Judgment

## Act on

1. [S1] **An ancestry test swallows a git error as "not an ancestor".** Real breach of "never hide it"; the documented path is unaffected because the fetch guarantees the refs, so this is implementation. Fix: both `merge-base --is-ancestor` calls accept exit 1 as "no" and let any other exit reach the ERR trap.
2. [P1] **A detached HEAD at step 8 reports the ticket's own PR.** Real fails-open by the definition: the input is outside the documented path and proceeds to a wrong result. The contract's exit 2, "the check could not run", already covers it, so the fix is a refusal under that clause and no table cell changes: in `--diff` mode an empty current branch exits 2 with `detached HEAD; run from the ticket's branch`, with one assertion. The arena cut this cell on the assumption that git would fail loudly on its own; it did not, and that assumption is the thing to record.

## Ask

## Consider

## Noted

3. [S2] **The `prs` walk is written three times.** Valid; no Act on fix touches those loops.
4. [S3] **`--limit 100` truncates silently.** Valid and outside this repository's reality; a count check is a later two-line change if any project nears it.
5. [S4] **Short names in the script.** Valid; the header carries the meaning.

## Dismissed

Standards: 0 would break, 0 fail open, of 4; Spec: 0 would break, 1 fail open, of 1; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 3, dismissed 0; fixed point origin/main.
round: 2 of 3
act-on items: 2

Claude Fable 5.1 on Claude Code


=== [Zenoctra 2026-09-22T02:50:24Z] https://github.com/Zenoctra/factory918/pull/92#issuecomment-5770524509
Round three, the last, found two hard items and one breach, each fixed on this PR by the commit its judgment names and, per the three-round rule, not reviewed again: the check now refuses when more than 100 PRs are open instead of listing the first hundred, the playbook's record step stops on a failed run instead of opening the PR, and an awk failure in the token pipeline now aborts. No cell of the ticket's scenario table changed in any round; the one design hole of this run was found by the writer at the test, before review, and resolved by architect.

## Standards

# Standards report

## Would break

## Fails open

1. **The PR list is capped at 100 and the cap is never reported.** The script's contract, in its own header and in P24, is every open PR. `gh pr list --limit 100` stops at the hundredth by PR age, and nothing checks whether the list came back full. PRs past it are not listed, not fetched and not diffed, so a shared path in one of them is invisible; the run then takes the `[ -z "$lines" ]` branch and prints a base. Hardening is one test: ask past the cap and refuse loudly when the list is still full.

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` step 1 — "It prints `go: <label or none>`, one line per open PR whose own commits ... touch a path the ticket names in backticks"; `docs/knowledge/core/DECISIONS.md` P24 — "every open PR's head is fetched fresh".

Result: with more than 100 open PRs, step 1 prints `go: none` and `base: origin/main` and exits 0 over a path an unlisted PR owns. The owner branches from `main`, and the check that exists to stop exactly that says nothing.

```
prs="$(gh pr list --state open --limit 100 --json number,headRefName,closingIssuesReferences \
```

## Standards breaches

2. **`|| true` covers the whole token pipeline, not only grep's no-match.** The `|| true` is there because `grep -oE` exits 1 when the body names no path, which is a real case. With `pipefail` it also swallows a failure of `awk`, `tr` or `sort`: `paths` comes back empty and the run prints `paths: none` and `base: origin/main`, exit 0. Let grep's 1 through and let the rest abort.

Standard: `CODING_STANDARDS.md`, Bash — "A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command ..., never hide it."

```
  paths="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip' \
    | grep -oE '`[^`[:space:]]+`' | tr -d '`' | sort -u || true)"
```

## Fix alongside

3. **`--diff` trusts `git diff --name-only` to print raw paths.** With the default `core.quotePath`, a path with a non-ASCII or escaped character comes back C-quoted (`"docs/caf\303\251.md"`). Under `GIT_LITERAL_PATHSPECS=1` that token matches nothing, so step 8 records no `## Overlap` for it. `-z`, or `git -c core.quotePath=false`, removes the class.

```
  paths="$(git diff --name-only "$base...HEAD")"
  [ -n "$paths" ] || exit 0
  export GIT_LITERAL_PATHSPECS=1
```

4. **Duplicated Code.** `while IFS=$'\t' read -r num head closes ... done <<< "$prs"` appears three times, each with the same `[ -n "$num" ] || continue` guard. One parse feeding three uses would keep the record shape in one place.

hard findings: 1

## Spec

# Spec report

## Walk

1. `MANUAL.md:79` states the three relations: `Blocked by` off the frontier, disjoint files parallel off `main`, overlapping files sequenced; "Overlap is not coupling"; only coupled work stacks, on a go.
2. `MANUAL.md:81` routes autopilot-stack to coupled work, says the go appends a program line naming its tickets, that a line needs no removal, that the overlap is recorded in `## Overlap`, and that a rebase re-reviews only a PR whose `patch-id` changed.
3. `factory918/SKILL.md:55-56` carry the same two cases into the router rows, naming `overlap.sh N` and `overlap.sh go "<label>" 4 5 8`.
4. `autopilot-stack.md:7` (via `patches/.../autopilot-stack.md.patch`, hunk recounted to `-2,9 +2,9`) runs `overlap.sh go "autopilot-stack" 4 5 8` on the operator's go.
5. `ticket.md:5` step 1 runs `overlap.sh N` after the dirty check: the script reads the newest program line naming `#N` (`overlap.sh:29-31`), returns `base: main` with no origin (`:33-37`), collects backticked tokens outside `## Diff` (`:40-44`), lists open PRs and force-fetches every head (`:48-55`), and diffs each head from `nearest` (`:61-71`).
6. `overlap.sh:100-110` prints `base: origin/main` when nothing is shared, exits 1 when a printed PR's closing ticket is on no line, else picks the containing head, else the lowest number's.
7. `ticket.md:5` maps those exits: 0 branch from `<ref>`, 1 stop and reply, 2 stop and report stderr; `stack #N on #M` re-runs after a one-off `go`.
8. `ticket.md:12` step 8 runs `overlap.sh N --diff` and pastes the output as `## Overlap` before `## Verification`.
9. `docs/agents/ledger.md:22` records the seven-re-reviews mis-estimate and the stack it justified.

## Would break

## Fails open

1. **Step 8 has no exit-2 branch, so a failed check reads as "no overlap".** Table rows 10E and 11E give exit 2 as "stop, report", and step 1 says so; step 8 keys only on "output, when there is any" and exit 1. On exit 2 stdout is empty, so the agent writes no `## Overlap` section and proceeds to Opening a PR. Nothing distinguishes "the check ran and found nothing" from "the check could not run".

```
| 11. gh fails or is absent | gh's message (or `command not found`) on stderr / 2 / stop, report | | | | / 2 |
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:12`
Result: a PR opens with no Overlap section and no signal that the check failed; a reader reads the absent section as no overlap.

## Not asked for

hard findings: 1

## Judgment

## Act on

1. [S1] **The PR list cap is never reported.** Real fails-open by the definition; noted last round and uncitable, so rightly raised again. Refused under the contract's exit 2 when a 101st open PR exists; no cell changes. fixed: d1e5186
2. [S2] **`|| true` covered the whole token pipeline.** Real breach; the `## Diff` filter now runs on its own so an awk failure reaches the trap, and `|| true` covers only grep's no-match. fixed: 2ed2d18
3. [P1] **Step 8 had no exit-2 branch.** Real fails-open in the playbook text: a failed record run read as no overlap. Step 8 now says exit 2 stops and reports and the PR waits; rows 10E and 11E already said so, no cell changes. fixed: 1df787a

## Ask

## Consider

## Noted

4. [S3] **`git diff --name-only` C-quotes a non-ASCII path.** Valid; a path outside ASCII would be missed by the record run. No Act on fix touches that line and the round is the last; a one-flag hardening for a later ticket if a project has such paths.
5. [S4] **The `prs` walk is written three times.** Valid; no behavior, no Act on fix touches it.

## Dismissed

Standards: 0 would break, 1 fail open, of 4; Spec: 0 would break, 1 fail open, of 1; judged: act on 3 (3 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point origin/main.
round: 3 of 3
act-on items: 0

Claude Fable 5.1 on Claude Code


