# Writer brief, ticket #108 on Zenoctra/factory918

You implement ticket #108 in your own worktree. The owner designed it and reviews your diff; you do not open a PR, push, or touch GitHub beyond reading.

## Start

1. Read `AGENTS.md` (the nesting rule, generated and vendored files, Verifying).
2. `git fetch origin`, then `git switch -c wt/108-writer origin/main` (origin/main is a9ebdac; the owner's branch `feat/risk-dispositions` is the same commit). Confirm `git rev-parse HEAD` is a9ebdac034bc8389895096b7b93d9cd52ea19588; if not, stop and report.
3. Read the ticket with its design: `gh issue view 108 --repo Zenoctra/factory918 --json body -q .body`. Its `## Testing decisions` section (tables A, B, C, the contract, the test list) is the spec you implement. Read it whole.
4. Read runner A's design package, `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/108/architect-a/design.md`: sections 2 (contract, reasons, messages), 4 (the awk prototype `disposed`, the `undisposed` function, call sites, module map) and 5 (fixtures). It is the base design. Where it and the ticket disagree, the ticket wins: the ticket trims the test grid (blank R, S and f cells are not asserted) and adds the no-stale-wording pin. The prototype awk was run on macOS awk; CI runs Ubuntu (mawk). Use nothing gawk-specific and no interval expressions in awk.

## Data shape

One grammar, two sites. The organizing structure is a classifier: a pure awk program that reads Markdown and emits one record per offender, `kind US value US line` (US = `\037`), kinds `none | near | fence | fixed | accepted`, and a thin shell function `undisposed <risks|flags>` that turns records into the reason lines (`  <reason>: <line>`, reasons fixed by the ticket's legend) and does the two git checks for `fixed`. Both call sites use that function; no second parser.

## What to change

In this commit order (criterion 4 needs the tests before the script, visible in `git log`):

1. **Tests commit.** `tests/spec-review/fake-gh.sh`: an issue-body fixture hook (for example `FAKE_ISSUE_BODY` naming a file, and a way to make `gh issue view` fail) that leaves today's behaviour unchanged when unset (CI's fixture flow copies this file as its `gh`; see `.github/workflows/factory-ci.yml` near line 67). `tests/spec-review/review-brief.sh`: one assertion per non-blank cell of tables A, B, C in table order, each labelled by row and column, with the helpers the design names; the #91 fixtures gain `accepted: fixture` on each risk line so their cells keep their outcome; the pins for the new risk sentence in SKILL.md step 4 and in the script, the disposition line in `opening-a-pr.md` and in the blast-radius SKILL.md; update the header comment. `tests/spec-review/no-stale-wording.sh`: the retired tail of the old risk sentence (`each naming the risk and saying what the diff does at that risk;`). This commit's new cells fail against HEAD's script; say which in the report.
2. **Script commit.** `template/.agents/skills/spec-review/scripts/review-brief.sh`: `disposed` and `undisposed` beside `$fenced`; the risk check after the Risks-heading check (hoist `where`); the ticket fetch block moved unchanged before the reading pack and every state write, then the flag check; the new `risk_rule`; the header comment. Nothing else moves: every cell of #90's, #91's, #93's, #106's and #107's tables keeps its outcome, and the whole existing suite must pass.
3. **Prose commit.** Each vendored file changes through its patch (`patches/`, `series`, `SOURCES.md`), then `./factory918.sh sync` must reproduce the template byte for byte and leave `git status` clean:
   - `template/.agents/skills/spec-review/SKILL.md` (patch `patches/mattpocock/spec-review.SKILL.md.patch`): step 1's cross-cutting paragraph gains the risk refusal, and step 1 gains the flag refusal, each with its message's first clause in the voice of the refusals already quoted there; step 4's Walk bullet carries the new risk sentence word for word.
   - `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` (its patch): the Blast Radius bullet shows the disposition line, with an example risk line ending `fixed: <sha>` or `accepted: <reason>` (criterion 5).
   - `template/.agents/skills/blast-radius/SKILL.md`: it has no patch today; add `patches/pstack/blast-radius/SKILL.md.patch`, its `series` line, and a new numbered `SOURCES.md` item; the "What to hand back" Risks bullet shows the disposition line (criterion 5).
   - `feature.md`, `bug-fix.md`, `refactoring.md`, `perf-issue.md` (their patches): the "(#108 adds the refusal that enforces it)" parenthetical becomes a present-tense pointer, for example "(Ticket step 6 gives the form; `review-brief.sh` refuses the review while one has none)".
   - `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, no patch): step 5's "one numbered risk per line under `## Risks`" gains that each ends with its disposition once acted on; step 6 gains one sentence: a writer's flags go on the ticket under a heading that is exactly `### Writer flags <YYYY-MM-DD>` inside `## Testing decisions` or `## Design`, one numbered flag per line ending `fixed: <sha>` or `accepted: <reason>`, and `review-brief.sh` refuses the review while a flag has none or a heading looks like that one and is not.
   - `SOURCES.md` items 3 and 6 describe the new lines.
   Do not edit `docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md` or `docs/M0-findings.md`: the owner writes the records. Never edit generated or vendored paths (`AGENTS.md`, "The ways to hurt yourself").

Prose follows `/writing-for-agents` (it is agent-facing). Comments per poteto-mode's **Comments**: a comment only for a non-obvious why. Run `/deslop` over your code before each commit. Commit messages: a plain sentence title, a short body, ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Rules

- A cell you cannot implement as written: stop and report the cell; never fill it in your own way.
- Anything you notice that the design did not settle is a **writer flag**: number it in your report, one per line, with what you did. The owner dispositions each before review.
- Never push, never open a PR, never merge, never `reset --hard`, `clean -f`, `branch -D`, `--force`.

## Verify, and name each outcome in your report

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`
- `bash tests/spec-review/review-brief.sh`, `bash tests/spec-review/review-comment.sh`, `bash tests/spec-review/no-stale-wording.sh`, `bash tests/shellcheck/gate.sh`, `bash tests/hooks/delegation.sh`, `bash tests/poteto-mode/overlap.sh`, `bash tests/eval/reviewer/refusals.sh`
- `./factory918.sh sync` then `git status --porcelain` empty.
- `python3 tools/check_knowledge.py`.
- The test commit alone against HEAD's script: which new cells fail (run the suite at that commit).
- Run the new refusal by hand once on a real grounding and a real ticket body: `review-brief.sh <fixed-point> --ticket 108` from your branch (the ticket carries no Writer flags list yet, so it must brief), and a copy of this ticket's body with a bare flag through the fake gh.

## Output

Write your report (commits with shas, what each verification printed, the failing-first cells, writer flags numbered) to a file in your worktree, then `cp` it to exactly `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/108/writer/report.md`. Reply with only that path. Leave your commits on `wt/108-writer`.
