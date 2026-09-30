# Arena frame: design for ticket #90

Read this whole file, then the grounding files it names, then produce one candidate design package at the output path your launcher gave you. You are one of two runners on different models; produce the best design your model can make, do not hedge toward a safe middle.

## The artifact

One Markdown file: a design package shaped per `template/.agents/skills/architect/references/rationale-template.md`, whose `## Shape` section is the text that will be appended to ticket #90 under `## Testing decisions`, in the same form as ticket #42's section (grounding file `ticket-42.md`, from `## Testing decisions` on): a first line `Posted by the agent 2026-09-22`, one paragraph saying what the table is the spec for and how a review finding relates to it, `## Scenario table` with a "Cell = ..." legend, then `## Contract`.

The table is for the round logic: situations down the side are the PR's comment history (no review yet; one, two, three rounds; a restart comment among them, including as the third; two restarts; a comment without a `round:` line; a comment by someone other than the PR's author; the word "restart" inside a comment's prose rather than on its own line; a comment that has a `restart` line but no `act-on items:` anchor; `--previous FILE`; `--round N`); inputs across the top are the judgment's marks (no mark; `fixed:`; `ticket:`; `hole: <ref>` on an Act on item whose report item carries a `spec:` line; `hole:` on an item whose report item has none; `hole:` with a malformed reference; `hole:` on a non Act-on item; a Would-break or Fails-open report item with no `spec:` line; one with a malformed `spec:`; `spec:` on an item that is not counted; `cites:` in each of the three new forms and in one malformed form). Every cell says what `review-brief.sh` prints and its exit code, what `review-comment.sh` prints (the `restart` line, the `act-on items:` count) and its exit code, and what the caller does. A cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. Two tables are fine when one axis is `review-brief.sh` over comment history and the other `review-comment.sh` over the judgment; say which script each cell belongs to.

The `## Contract` names, as the scripts will implement them: the grammar of `spec:` (`table <row>/<column>`, `design <signature>`, `criterion <k>`), of `hole: <ref>` and of the three new `cites:` forms (`cites: #N table <row>/<column>`, `cites: #N design <signature>`, `cites: #N criterion <k>`), each as the regex the scripts will use; the rule text `review-brief.sh` writes into both briefs (one or two sentences, placed next to the existing `Documented step:` rule); each new refusal's message and exit code in `review-comment.sh`; where the `restart` line prints in the comment relative to `round:` and `act-on items:` (the last line is `act-on items:` today and babysit reads it); how `review-brief.sh` derives the round after a restart and what a restart does to `## Settled in earlier rounds`; and the prose edits, per file, as the sentence to add: `spec-review/SKILL.md` step 5 (the definition of a design hole, the `hole:` field, the `spec:` line) and step 6 (the refusals, the `restart` line) and step 1 (the reset); `docs/agents/review-ladder.md` rung 1; the Ticket playbook (`poteto-mode/playbooks/ticket.md`), where a hole returns to `architect` Phase B scoped to the cell, signature or criterion with the finding and the artifact as grounding, two runners and the judge skipped when they converge, the artifact on the ticket amended with a dated line (a criterion by re-deriving it from the intent), and the redesigned work reviewed from round one; and babysit (`poteto-mode/playbooks/babysit.md` step 6, `babysit/SKILL.md` step 4) only if the restart case needs a sentence there.

## Usage first

Before the table, write `## Usage (caller's view)`: three walk-throughs in the orchestrator's own steps. (1) A clean round: what the reviewer writes on a hard item (`Documented step:`, `Result:`, `spec:`), what the orchestrator writes in the judgment, what `review-comment.sh` prints. (2) A round that finds a hole: the judgment item with `hole:`, the comment's tail (`restart`, `round:`, `act-on items:`), the Ticket playbook's return to architect, the dated amendment on the ticket, the next `review-brief.sh` run printing `round: 1 of 3`. (3) The round after the redesign: which earlier Noted/Dismissed items carry as settled and which do not.

## Constraints

- The ticket (`ticket-90.md`): its Decision quotes outrank any criterion. Its acceptance criteria are the finish condition; every one must map to a cell or a named prose edit.
- Out of scope, owned by sibling tickets: rounds four and five after a Would-break fix (#93) and the Spec walk's one line per blast-radius risk (#91). No cell may depend on either.
- `babysit`'s merge-ready condition is unchanged for a PR with no design hole. Say what babysit reads on a restart comment and show that a PR mid-restart cannot read as review-ready.
- No new state file: the round and the settled set derive from the PR's comments by the PR's author; rerunning either script in the same round gives the same output.
- Vendoring: `review-brief.sh`, `review-comment.sh` and `ticket.md` are kept files (ours, edited directly); `spec-review/SKILL.md`, `babysit.md` and `babysit/SKILL.md` are patched files (a change is a change to the patch under `patches/` and to the template copy). `docs/agents/review-ladder.md` lives at `template/docs/agents/review-ladder.md`. The grounding explanation says how.
- Smallest change that satisfies every criterion. No renumbered steps in any playbook. No new files except tests.
- Prefer one grammar per field, used identically by both scripts and the skill text.
- The existing refusal style: exit 1, message on stdout/stderr as the script does today, clearing nothing; an off-shape report goes back to its reviewer. Follow it.

## Facts from the grounding your design must honor

- `review-brief.sh:94`: only the PR author's comments whose body has a line starting `act-on items:` are fetched at all; a restart comment must carry that line or the jq filter never sees it. `:133-137` is the round awk (`^round: [0-9]+ of 3$`, last wins per comment, max across comments, `BEGIN { r = 1 }` so any fetched comment forces round 2 or more); `:140-143` the fourth-round refusal, fired before any output or state. The reset lives there.
- `review-brief.sh:151`: the `cites:` regex, `$`-anchored, so `cites:` is the last field on its line; `:154-157` collects Noted and Dismissed item lines from every earlier comment's `## Judgment`, deduped by whole line across comments (`seen[]` survives the separator); `:160` prints `settled: carried N, dropped M without a citation`.
- `review-brief.sh:240` `step_rule`, echoed at `:324` and `:352`; `:243` `count_rule`. `tests/spec-review/review-brief.sh:112-120,153-160` assert these strings against `SKILL.md` step 4 too (anti-drift), and `:126-129` pins the layout "definition, blank, first quote". `:341-347` asserts the `fenced` awk fragment is byte-identical in both scripts.
- `review-comment.sh:50` `items()`: an item is one line `^[0-9]+\. ` under a non-Walk heading; continuation lines (`Documented step:`, `Result:`) are not items. `:54-62` `stepless()` is the scanner for a required continuation line on Would-break/Fails-open items (refusal at `:91`). `:149-150`: `fixed:` and `ticket:` are `$`-anchored trailing text on the Act on item's own line. `:157-158`: `round:` then `act-on items:` are the last two lines; every refusal goes through `fail()` (`review-comment: <msg>` on stderr, exit 1) before any output and clears nothing; `:159` clears `.claude/state/review` only when it names this dir. `tests/spec-review/review-comment.sh` asserts exact stdout in 18 `accept` cases per layout and exact single-line stderr in `refuse` cases.
- `cites:` is read only by `review-brief.sh`; `review-comment.sh` passes it through.
- `SKILL.md:130` reads "Three trailing fields, each with one grammar:"; `:132-134` the three grammars; `:138` "Babysit reads this line, so it is always present and always last"; `:140` the refusal list in prose; `:25` the round rule. All are `+` lines of `patches/mattpocock/spec-review.SKILL.md.patch`; a change edits the patch, the template file and `SOURCES.md` item 6 in one commit (precedent `82dc11e`); CI runs `./factory918.sh sync && git diff --exit-code`.
- `babysit.md:16` and `babysit/SKILL.md:40` are patched `+` lines; leaving them byte-identical satisfies criterion 7. `review-ladder.md:6` is ours, edited directly; no root copy exists. `ticket.md` is a kept file; it never mentions rounds today; step 9 is its last step.
- `arena/SKILL.md` has no judge-skip clause; "two runners; the judge is skipped when they converge" is new text that belongs in the Ticket playbook's restart sentence, not in arena.
- `DECISIONS.md` P18 (what a finding is), P20 (three rounds), P21 (what carries) are the rows a Provisional entry would amend; that record is the owner's, not the design's.

## Grounding

- `.scratch/program/90/how/explanation.md`: how the round logic, marks and carry-forward work today (with the explorers' raw findings in `how/explorer-1.md`, `how/explorer-2.md`, `how/explorer-3.md` for line numbers).
- `.scratch/program/90/ticket-90.md`: the ticket.
- `.scratch/program/90/ticket-42.md`: the worked example of a Testing decisions section (from `## Testing decisions` on).
- `.scratch/program/90/pr-92-comments.md`: three real review comments in the shape `review-comment.sh` prints.
- The scripts and tests themselves, read-only: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `review-comment.sh`, `tests/spec-review/*.sh`, `template/.agents/skills/spec-review/SKILL.md`, `template/.agents/skills/poteto-mode/playbooks/ticket.md`, `template/docs/agents/review-ladder.md`.

## Rubric (what the judge grades; you only need to satisfy it)

1. Coverage: every acceptance criterion of #90 maps to a cell or a named prose edit; nothing depends on #91 or #93.
2. Cell completeness: every cell names what is printed, the exit code and what the caller does; refusals quote their message.
3. Derivation without new state; idempotent reruns; the restart rule is unambiguous for every listed comment history.
4. One grammar per field, as a regex, identical across `review-brief.sh`, `review-comment.sh` and `SKILL.md` step 5.
5. Babysit safety stated and shown; unchanged for the no-hole PR.
6. Smallest diff: files touched listed, each with the reason; no step renumbered.

## Output

Write the package to the path your launcher names. Sections in order: `## Problem`, `## Usage (caller's view)`, `## Shape` (the Testing decisions text: first line, paragraph, `## Scenario table`, `## Contract`; use `###` for these inner headings so the package stays one document), `## Tradeoffs accepted`, `## Alternatives considered`, `## Open questions and risks`, `## Next implementation step`. Reply with only the path.
