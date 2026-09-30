verdict: PASS+NOTES

# Slice: live runtime floor, PR #99 (ticket #90) at 0ff73f0

Independent verifier, slice `slice-runtime.md`. Every line below was run live at the SHA.

## Setup

- `git fetch origin feat/design-hole-restart feat/shellcheck main` then `git checkout --detach 0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93` in my own worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a58bc08e4ccf33b94`. `git rev-parse HEAD` → `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`. Exit 0.
- `git merge-base --is-ancestor 070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42 HEAD` → exit 0. Patch base confirmed.
- Live harness, built with the harness the slice names: `tests/spec-review/fake-gh.sh` copied to `$TMPDIR/bin/gh` on PATH, and `tests/spec-review/layout.sh`'s `layout project` used to lay a scratch repo out as a project holding the skill at this SHA, with a ticket-bearing commit (`second, for #42`). Driver scripts: `/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/live/{setup,a,a2,b,c,d,e,f,f2,h,rt}.sh`. Nothing under version control was written.

## (a) `review-brief.sh`: the `spec:` rule in the briefs

- With a ticket — `review-brief.sh HEAD~1 --ticket 42`, exit 0, stdout `ticket: #42` / `round: 1 of 3` / both brief paths. Both briefs carry the rule, at `standards-brief.md:68` and `spec-brief.md:67`, byte-identical:

  > The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

  Layout as the contract pins it: the item-form paragraph, blank, `$step_rule`, blank, `$spec_rule`, blank, the report-path line, `$count_rule`.
- With no ticket — a commit naming no `#N`, `review-brief.sh HEAD~1`, exit 0, stdout `round: 1 of 3` / `.scratch/review/HEAD_1/standards-brief.md` / `no spec: Standards axis only`. No `spec-brief.md` in the dir (contents: `diff files fixed-point log round standards-brief.md stat`); `grep -cF` of the rule in the Standards brief → `0`; the brief runs step rule → blank → report path → count rule. Criterion 2's amendment holds.

## (b) `review-comment.sh`: the `spec:` line on a counted item

Each run is `review-comment.sh .scratch/review/<id>` on a hand-built review dir.

- Well-formed `spec: table 2/D` on a counted Would-break item → exit 0, comment printed, tail `round: 2 of 3` / `act-on items: 1`.
- No `spec:` line → exit 1, nothing on stdout, and `.claude/state/review` untouched:
  `review-comment: <dir>/standards-report.md item '1. **Open, silently.**' under '## Would break' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it`
- The same message and exit 1 for each malformed form: `spec: cell 12A`, `spec: table 12A`, `spec: criterion 0`, `spec: table 2/D trailing`, and for a well-formed `spec: table 2/D` written **inside a fenced block**. Five refusals, one message, naming the three forms.
- With no Spec brief (`<dir>/spec-brief.md` absent): the same item with **no** `spec:` line → exit 0, `Spec: no spec`, `act-on items: 1`. A `hole: table 2/D` on it → exit 1:
  `review-comment: <dir>/judgment.md item '1. [S1] **Open, silently.**' carries a 'hole:' field, but this review has no spec (<dir>/spec-brief.md is missing): a hole names an artifact on the ticket the work was built against, and this review has none. Fix the finding on this PR, or rerun scripts/review-brief.sh <fixed-point> --ticket N and judge again`
  A malformed `hole: table 2` in the same dir gives the *same* message, so the no-spec check runs before the form check, as the second amendment pins.
- Clearing nothing, checked directly: with `.claude/state/review/dir` naming the dir, a refused run left `dir fixed-point` in place; the accepted run cleared the directory.

## (c) `hole:` on an Act on item

- `hole: table 2/D` equal to the item's `spec:`, under `## Act on` → exit 0. Stdout ends exactly:
  ```
  Standards: 1 would break, 0 fail open, of 2; Spec: 0 would break, 0 fail open, of 0; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point HEAD~1.
  restart
  round: 2 of 3
  act-on items: 0
  ```
  `restart` sits between the summary and `round:`; the held item is out of `act-on items:`.
- Two holes (`hole: table 2/D`, `hole: criterion 3`) → **one** `restart` line, `act-on items: 0`, exit 0.
- Wrong placement, under `## Noted` → exit 1: `... item '2. [S2] **Long line.**' carries a 'hole:' field under '## Noted', 'hole: table 2/D'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do: move the item, or reword a reason that says 'hole:'`. The same under `## Ask`.
- Wrong form, value shown **as written**, three cases, all exit 1:
  - `hole: table 2` → `... has a 'hole:' field that fits no form, 'hole: table 2' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded`
  - `hole:table 2/D` (no space) → the value renders `'hole:table 2/D'`; the missing space is visible. The 2026-09-22 third amendment, honoured.
  - a prose reason `Not a design hole: the table stands.` under Act on → `'hole: the table stands.'`, refused. A reason cannot fall through as a silent fix-on-the-PR.
- `spec:` mismatch → exit 1: `... is marked 'hole: criterion 4' but [S1] rests on 'table 2/D'; the mark repeats the report item's 'spec:' line word for word`.
- Last-field rule: `hole: table 2/D fixed: abc1234` → exit 0, **no** `restart`, counted as a fix (`act on 1 (1 fixed, ...)`, `act-on items: 0`). The `hole:` is text, as the note under table B says.
- Extra probes past the slice, all correct: a hole on a **Spec-report** item `[P2]` past two `## Walk` lines resolves to the right `spec:` (`design overlap.sh N --diff`) and prints `restart`; the same with a wrong reference is refused naming `[P2] rests on 'design overlap.sh N --diff'`; a hole on a **not-counted** item under `## Not asked for` → `... but [P3] carries no 'spec:' line: it is under '## Not asked for' in <dir>/spec-report.md, not a counted item`; a `spec:`/`hole:` written on a `## Walk` line is invisible (exit 0, nothing counted, no restart).

## (d) The round reset read from comments

All through the fake `gh`'s `pr.json`, so the script's own jq author filter is what runs. `review-brief.sh HEAD~1 --ticket 42`.

- `(1), (2 restart)` → exit 0, `restart: the round and the settled items count from the last restart comment`, `round: 1 of 3`, **no** `settled:` line, both brief paths.
- `(1), (2), (3 restart)` → the same three lines. A restart as the third author comment resets the same way.
- `(1), (2 restart), (1'), (2'), (3')` → exit 1, stdout empty, stderr exactly the unchanged message: ``review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked `fixed: <sha>`, not reviewed in a fourth round``. Three post-restart rounds still refuse a fourth.
- Control `(1), (2), (3)` with no restart → the identical message, exit 1. `--round 4` on a PR with no restart → the identical message, exit 1.
- Resets nothing, four ways, each exit 0 with no `restart:` line: `restart` in prose (`the writer asked for a restart`) → `round: 3 of 3`; inside a fenced block → `round: 3 of 3`; with trailing text (`restart: table 2/D`) → `round: 3 of 3`; a body with `restart` but **no** `act-on items:` anchor → not fetched, `round: 2 of 3`. A restart comment by a non-author login → not fetched, `round: 2 of 3`.
- Round trip, the strongest evidence that the two scripts speak one protocol: the exact stdout `review-comment.sh` printed for a held item, fed back unedited, both as `--previous FILE` (no separator, cuts at EOF) and through the fake `gh` → `restart:` + `round: 1 of 3` in both. The same round trip with a no-hole comment → no `restart:`, `round: 3 of 3`.

## (e) `cites:` in the three new forms

One comment carrying three well-formed cites and five malformed ones → exit 0, `settled: carried 3, dropped 5 without a citation`. The three lines are pasted verbatim under `## Settled in earlier rounds` in **both** briefs:

```
1. [S1] **A cell.** settled. cites: #42 table 12/A
2. [S2] **A signature.** settled. cites: #42 design overlap.sh N --diff
3. [S3] **A criterion.** settled. cites: #42 criterion 3
```

Dropped and counted in that same `settled:` line (on stdout, not stderr — see Notes): `cites: #42 cell 12A`, `cites: table 12/A` (no `#N`), `cites: #42 criterion 0`, `cites: #42 table 12/A trailing`, and a `cites:` not last on its line.

## (f) The real PR

- `gh pr view 99 --repo Zenoctra/factory918 --json author,comments`: author `Zenoctra`; three comments, all by the author, all carrying `act-on items:`. Comment `5780539782` (2026-09-22T16:55:59Z) carries a bare `restart` at body line 88, then `round: 1 of 3`, `act-on items: 0`. The other two: `5781120649` (17:38:20) `round: 1 of 3`; `5781309601` (17:52:21) `round: 2 of 3`.
- The script's own jq filter kept all three (3 separators, 1 bare `restart` line). `review-brief.sh HEAD~1 --ticket 90 --previous <that file>` → exit 0: `ticket: #90`, `restart: the round and the settled items count from the last restart comment`, **`round: 3 of 3`**, `settled: carried 1, dropped 2 without a citation`.
- Against the first two comments alone — the history the slice describes — the same command prints `restart:` and **`round: 2 of 3`**, `settled: carried 0, dropped 0 without a citation`. The slice's expected string was right for a two-comment history; the third comment (`round: 2 of 3`, posted 17:52) advances the next round to three. The post-restart series did end at round two; the line names the round to run next.
- Control that the reset is doing work on the real data: the same three comments with the `restart` line stripped → `round: 3 of 3`, `settled: carried 1, dropped 3`. The restart drops the pre-restart comment's items (the dropped count falls by one) and, on the two-comment prefix, drops the whole carry (`carried 0`).

## (g) The changed prose

Every quotation is from the file at 0ff73f0; the diff against 070c1fa is additive in the babysit files.

- **Ticket playbook step 8 pointer** (`template/.agents/skills/poteto-mode/playbooks/ticket.md:8`), inserted after "Then run **Opening a PR**.": "A `spec-review` comment carrying the line `restart` names a design hole: go to **Design hole** below, not on to step 9." Followable: it names the trigger (the printed line the agent has just posted), the destination and the step not to take.
- **`### Design hole`** (`ticket.md:26-35`), six numbered steps, opening "**A finding whose fix changes the artifact is not fixed on the PR.**": 1 read the `hole:` reference, "That is the scope; nothing wider is redesigned"; 2 `architect` Phase B scoped to it, "Two runners; the judge is skipped when they converge"; 3 amend the artifact with the literal template `Amended <date> by #N (review round <r>, hole at <reference>): <what changed and why>; <which assertions moved>`; 4 rewrite the tests from the amended artifact before the code, "the PR stays open"; 5 "`review-brief.sh` reads the restart from the PR's comments and starts the count over; nothing from before it carries as settled"; 6 "Then step 9. A PR mid-restart is never merge-ready." Followable: every step names an actor, an input and an artifact, and step 5 matches what (d) and (f) show the script doing.
- **`spec-review/SKILL.md` step 5 definition** (`:130`): "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it. Three artifacts, and every ticket has at least one: the scenario table under `## Testing decisions` ...; the usage and signature sketch under `## Design` ...; the acceptance criteria (what a criterion asks for). The ticket's intent, its What to build or Decision quotes, outranks any one criterion ... A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; test for all three. Every counted report item names what it rests on in its `spec:` line (step 4): the finding is a hole when its fix changes that thing, and an implementation bug when the artifact stands and the code fails it." Followable, and it gives a judge a procedure rather than a definition alone: the last sentence turns the `spec:` line into the test. The list lead became "Four trailing fields, each with one grammar:" and the new `hole:` bullet matches the runtime exactly, including "The text from the last `hole:` on an Act on line is the field, so a reason does not write `hole:`; a value in no form is refused with the value shown" and the no-spec clause.
- **`review-ladder.md` rung 1** (`template/docs/agents/review-ladder.md:6`), inserted after "An Ask item waits for the human.": "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a cell of the ticket's scenario table (its expected outcome, a new row or column, or the meaning of a term the cells use), a signature or a usage in its `## Design` sketch, or an acceptance criterion; the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change is a hole and `architect` re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; all three are marked the same way. A hole is never fixed on the PR: the judgment marks it `hole: <reference>`, the comment carries the line `restart`, the work returns to `architect` scoped to that cell, signature or criterion, and the redesign is reviewed from round one." Followable; it is one long block in an already-long rung, a readability nit, not a defect.
- **The two babysit paragraphs**, `template/.agents/skills/babysit/SKILL.md:41` (a bullet under "4. **When to stop.**") and `template/.agents/skills/poteto-mode/playbooks/babysit.md:18` (an indented paragraph): "A review comment carrying the line `restart` names a design hole and is not a merge-ready comment whatever its count: the Ticket playbook's Design hole section returns the work to `architect`, and the PR is ready only when a later review comment without a `restart` line reads `act-on items: 0`." `cmp` of the two, after stripping the list marker and the indent: identical. Criterion 7's byte-identity holds.
- **The babysit merge-ready sentences are unchanged.** Both files are additive in this diff (`babysit/SKILL.md | 1 +`, `playbooks/babysit.md | 2 ++`; `git diff 070c1fa..0ff73f0` shows no `-` line in either). The existing "Build is green, every comment resolved, the `spec-review` comment on the latest commit reads `act-on items: 0` ..." bullet and the "Merge-ready also needs ..." paragraph, including the `round: 3 of 3` and Ask-item clauses, stand word for word. A PR with no design hole reads exactly as before.
- **`MANUAL.md`'s merge read**, changed in both copies (`docs/knowledge/core/MANUAL.md:103`, `template/docs/factory918/MANUAL.md:84`), step 2: "... `spec-review`'s last line on the latest commit reads `act-on items: 0` **and that comment carries no `restart` line (a design hole returned to `architect`; the PR is ready only when a later review comment without one reads `act-on items: 0`)**; ...". Followable by a person: one parenthetical inside the existing checklist item, saying both the condition and the way out.

## Gate runs at the SHA (context, outside the slice)

- `bash tests/spec-review/review-brief.sh` → `ok 422 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 148 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, exit 0.

## Issues

None found in this slice.

## Notes

- The slice's (f) expected `round: 2 of 3`; the live run prints `round: 3 of 3` because a third author comment (`5781309601`, `round: 2 of 3`) was posted at 2026-09-22T17:52:21Z, after the slice was written. Against the two-comment history the slice describes, the script prints `round: 2 of 3` exactly. No code defect; the brief's expected string is stale.
- The slice's (e) says the malformed forms are "counted in the script's stderr line". They are counted on **stdout**, in `settled: carried 3, dropped 5 without a citation` (`template/.agents/skills/spec-review/scripts/review-brief.sh:192`). The count is there and correct; only the stream in the slice's wording is wrong.
- The real-PR history in (f) does not by itself discriminate the reset in the round number: the restart comment is the first comment and carries `round: 1 of 3`, so reset and no reset give the same next round. The reset is proven on that data by the `restart:` line, by the settled carry falling (`dropped 2` with the restart against `dropped 3` without, and `carried 0` on the two-comment prefix), and by the synthetic histories in (d).
- `bash .github/shellcheck.sh` with no arguments fails in this repository (`shellcheck.sh: no file matched .agents/skills/*/scripts/*.sh; the gate checked nothing`, exit 1): the default globs are the shape of a *project*, and the factory passes its own globs, as `AGENTS.md:38` and `.github/workflows/factory-ci.yml:19` both do. Pre-existing and by design, not this PR's doing; recorded because `common.md` names the bare command.
- `holed()` reads only an item's opening line (`items()` matches `^[0-9]+\. `), so a `hole:` written on a continuation line of an Act on item is invisible. This matches the contract's "the judgment field on an Act on item's own line" and the existing behaviour of `fixed:` and `ticket:`; no cell covers it and none needs to.
- Ticket playbook step 8's pointer sits in a step that runs before the review exists, so on a first pass through step 8 there is no comment to check. It reads as a rule for the return trip, and the ticket's contract asked for exactly that placement ("Step 8, after 'Then run **Opening a PR**.'"). Legibility nit only.
