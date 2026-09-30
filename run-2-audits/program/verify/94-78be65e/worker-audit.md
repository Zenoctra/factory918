verdict: ISSUES

Slice: receipts-and-diff audit, PR #94 (ticket #89) at 78be65edc94f22b257d3c220b74482c7e884806b.
All checks run in my own worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a81b22fecd79daf16`, detached at that SHA. Nothing under version control was changed: `git status --porcelain` is empty after every run below.

## Setup

- `git fetch origin feat/design-artifact-on-ticket main` then `git checkout --detach 78be65e...` → `git rev-parse HEAD` prints `78be65edc94f22b257d3c220b74482c7e884806b`; exit 0.
- `git merge-base 78be65e origin/main` → `ab47eb91fa42a896c1eec054e526b615b5cbf316`, the stated patch base; exit 0.

## Repository verification list (AGENTS.md "Verifying")

- `bash -n factory918.sh` → no output; exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`; exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 82 assertions`; exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 334 assertions`; exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`; exit 0. (The PR's claim of 57 is exact.)
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`; exit 0.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`; exit 0. `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`; exit 0. `git status --porcelain` and `git diff --stat` both empty afterwards, so `docs/knowledge/INDEX.md`, the core headers and every file under `template/docs/factory918/` are a faithful rebuild, not hand-edited.
- `./factory918.sh sync` → no `FAILED` line, ends `vendored: 72 skills`; `git status --porcelain` empty afterwards. The seven patches therefore reproduce the vendored tree.
- `shellcheck` 0.11.0 on `template/.agents/skills/poteto-mode/scripts/overlap.sh` and `tests/poteto-mode/overlap.sh` → no output; exit 0 each.
- Each of the seven patches regenerated with the `patches/README.md` command and compared with `cmp`: `architect/SKILL.md`, `architect/references/runner-prompt.md`, `poteto-mode/playbooks/{bug-fix,feature,perf-issue,refactoring}.md`, `mattpocock/to-spec/SKILL.md` — all seven byte-identical; exit 0 each. The widened `feature.md.patch` hunk reproduces exactly, as the PR's Tradeoffs claim.
- `diff docs/agents/issue-tracker.md template/docs/agents/issue-tracker.md` → no output; exit 0.

## 1. The six acceptance criteria against the diff

1. **Met.** `template/.agents/skills/architect/references/runner-prompt.md:7` is the "With state" bullet (table, then contract, then test list, with the situations/inputs/cell shape and the legend, contract and one-assertion-per-cell test list); `:8` is the stateless "usage and signature sketch" bullet; `:10` names `## Testing decisions` and `## Design` as the destinations. Carried by `patches/pstack/architect/references/runner-prompt.md.patch`, listed in `patches/series`, described as `SOURCES.md` item 14.
2. **Met.** Same file, `:7`: `grep -c "refused with the tool's own message"` → 1, and the sentence "Cut such a cell only after the refusal was run and seen" follows it.
3. **Met in substance; the placement is a fair reading, not a dodge.** `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6) carries every element the criterion names: the state test, `## Testing decisions`, `Posted by the agent <date>` / `Approved by <name> <date>`, "before implementation", the human edits it, `/architect with checkpoint` as the only stop, and "The Spec brief carries the table because `review-brief.sh` pastes the ticket body". The criterion says "the Ticket playbook's architect step"; the Ticket playbook has no architect step (step 5 selects a playbook, and the architect step belongs to the selected one). Step 6's own wording, "The selected playbook's architect step adds the ticket's own", names the right actor, so the rule sits where a ticket run reads it before implementation. I judge this satisfies the intent. **Residual gap, worth naming:** the four playbooks' *architect* steps (Feature step 2, Bug fix step 3, Refactoring step 3, Perf issue step 3) still say nothing about posting; only their *delegation* steps reference "Ticket step 6". A playbook run started outside the Ticket playbook never meets the posting rule. Out of the criterion's letter, inside its intent; a note, not a block.
4. **Met.** `grep -c "one assertion per cell"` → 1 in each of `template/.agents/skills/poteto-mode/playbooks/{feature.md,bug-fix.md,refactoring.md,perf-issue.md}`, at Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3; each sentence also carries "stops and reports the cell, and never fills it in". The four patches regenerate byte for byte and `SOURCES.md` item 13 is amended.
5. **Met.** `template/.agents/skills/to-spec/SKILL.md:66`, a fourth bullet under `## Testing Decisions`, names the scenario table and its shape. Patch `patches/mattpocock/to-spec/SKILL.md.patch`, listed in `patches/series`, `SOURCES.md` item 15.
6. **Met.** `docs/knowledge/core/SCENARIO-TABLE.md` (88 lines: What it is, The shape, Where it goes, The #42 example verbatim, Why), its `CORE_DOCS` tuple at `tools/build_knowledge.py:42`, its row in `docs/knowledge/INDEX.md:12`, the slim copy `template/docs/factory918/SCENARIO-TABLE.md`, the `Scenario table` glossary entry at `docs/knowledge/core/GLOSSARY.md:51`, and the `MANUAL.md` "Where to read more" bullet. `/knowledge scenario table` reaches it through the index row (step 1) and the grep (step 2).

## 2. Scope: every file the diff touches

35 files. Judgment per group:

**In the ticket's ask** — `template/.agents/skills/architect/references/runner-prompt.md` + patch (c1, c2); `template/.agents/skills/poteto-mode/playbooks/ticket.md` (c3); the four playbooks + their four patches (c4); `template/.agents/skills/to-spec/SKILL.md` + patch (c5); `docs/knowledge/core/SCENARIO-TABLE.md`, `tools/build_knowledge.py`, `docs/knowledge/INDEX.md`, `docs/knowledge/core/GLOSSARY.md`, `docs/knowledge/core/MANUAL.md`, `AGENTS.md`, `template/.agents/skills/knowledge/SKILL.md`, `template/docs/factory918/SCENARIO-TABLE.md` (c6 and the counts it moves); `patches/series` and `SOURCES.md` items 13–15 (AGENTS.md's vendored-skill rule requires them).

**Outside the letter of the ask, each defensible:**
- `docs/agents/issue-tracker.md` + `template/docs/agents/issue-tracker.md` (one paragraph each, identical). Not asked for, but the ticket body shape is the document that defines where `## Testing decisions` may appear. **Belongs.**
- `template/.agents/skills/architect/SKILL.md` + new patch (Phase B, one sentence). A round-1 Consider item [P2], not a criterion. Criterion 1 names the runner prompt only, and the runner prompt was already met. **Belongs**: the skill's Output shape would otherwise contradict the prompt it hands to its own runners.
- `template/.agents/skills/poteto-mode/scripts/overlap.sh` (two-token awk alternation plus a header comment rewrap) and `tests/poteto-mode/overlap.sh` (one new cell, +1 assertion). Forced by a round-1 Would-break that this PR's own rule creates (a posted table carries backticked paths). **Belongs** — the finding was on the PR that was reviewed and its fix is two tokens. See Issue 2 for what the fix misses.
- `docs/knowledge/core/DECISIONS.md` + `template/docs/factory918/DECISIONS.md`: new P25, and a dated amendment inside P24 for the awk change. **Belongs** (AGENTS.md: a decision goes under Provisional; a count or a rule in prose is true at the commit that lands it).
- `docs/agents/ledger.md` (two lines) and `docs/M0-findings.md` (two dated paragraphs). **Belongs** (AGENTS.md: a surprise goes to the ledger; anything verified against a tool version gets a dated line in M0-findings). Both are orchestrator-owned append-only files, so they are cheap merge conflicts with PR #96, which the PR body's `## Overlap` names.
- The amendment of closed ticket #42's body is on GitHub, not in this diff; see Attention item 3 below.

No file in the diff is outside the ticket's concern. "One concern per PR" holds for the *diff*; it does **not** hold for what the PR closes — see Issue 1.

## 3. Receipts

- Exactly two issue comments on PR #94, both by `Zenoctra`, `authorAssociation: OWNER`, the PR author's own account (`gh pr view 94 --json author -q .author.login` → `Zenoctra`). Neither has been edited: `created_at == updated_at` for both.
- Comment 1, `2026-09-22T15:19:58Z`, ends exactly `... ab47eb9.\nround: 1 of 3\nact-on items: 5\n`. Standards `hard findings: 1`, Spec `hard findings: 4`, five Act on items, fixed point `ab47eb9`.
- Comment 2, `2026-09-22T15:37:57Z`, ends exactly `... c83f166.\nround: 2 of 3\nact-on items: 0\n`. Both axes `hard findings: 0`, fixed point `c83f166`.
- The four fix commits sit between the rounds, by author date: `b368116` 10:22:21, `3f5033f` 10:24:18, `ca2c106` 10:25:09, `0c63fa6` 10:26:09 (CDT, = 15:22–15:26 Z), all after comment 1 (15:19:58 Z) and before comment 2 (15:37:57 Z). The six writer commits `3b48036 5c0f2bf 02af48c 0cf6b34 1662392 c83f166` precede them (09:55–10:02). Exit 0 on `git log --reverse --format='%h %ad %s' --date=iso-strict ab47eb9..78be65e`.
- **`78be65e` is unreviewed: confirmed.** Its author date is 10:38:16 CDT = 15:38:16 Z, nineteen seconds after comment 2. It changes exactly two files, three added lines: `docs/agents/ledger.md` +1 (the drained-lanes lesson) and `docs/M0-findings.md` +2 (a blank line and the dated `gh issue edit N --body-file F` paragraph). No skill, script, test, patch or generated file. `git show --stat 78be65e` → `2 files changed, 3 insertions(+)`.

## 4. PR body shape against AGENTS.md "Pull requests"

- Title "Put a design artifact on the ticket before implementation": plain sentence, no `type(scope):`. **OK** (P14).
- Opening paragraph is the problem (PR #87's prose sketch, three redesign rounds) then the fix. **OK.**
- Headings in order: `## Why`, `## Scope`, `## Tradeoffs`, `## Blast Radius`, `## Overlap`, `## Verification`. `## Overlap` before `## Verification` as Ticket step 8 requires. **OK.**
- `## Verification` names each command and its outcome (`vendored: 72 skills`, `knowledge ok: 119 files`, `ok 57 assertions`, `shellcheck` 0.11.0 clean, the seven patch `cmp`s) and then quotes each criterion with its evidence. Every claim I re-ran matched. **OK.**
- `Closes #89` is the last line before the attribution; the attribution line is present. **OK.**
- **Missing:** the model-and-harness line. AGENTS.md "Pull requests" ends "end with the model and harness", and both sibling PRs carry it after the attribution (`gh pr view 92` and `gh pr view 96` both end `🤖 Generated with [Claude Code]...` then `Claude Fable 5.1 on Claude Code`). PR #94's body ends at the attribution line. Minor, but it is the one shape rule the PR breaks.

## 5. Forbidden edits

- `git diff --name-status ab47eb9...78be65e` lists nothing under `docs/knowledge/spec/`, `docs/knowledge/pages/`, `docs/knowledge/notes/` or `research/`. **Clean.**
- The two generated trees that do change, `docs/knowledge/INDEX.md` and `template/docs/factory918/` (`DECISIONS.md`, `GLOSSARY.md`, `MANUAL.md`, `SCENARIO-TABLE.md`), are exactly what `tools/build_knowledge.py` emits: the build left `git status --porcelain` empty at this HEAD. **They match a rebuild; nothing was hand-edited.**
- `template/docs/factory918/` holds exactly the five documents `build_core` copies (every core document except `CONVERSATION-DIGEST.md`), which is what the amended `MANUAL.md` "Where to read more" and the `build_knowledge.py` docstring now say.

## Issues

1. **PR #94 will close ticket #88 on merge, which it does not implement.** `gh api graphql` on `pullRequest(number:94).closingIssuesReferences` returns **#88 (OPEN, "Run ShellCheck…") and #89**. The cause is the `## Overlap` prose at body line 36: "PR #96 closes #88, which the `autopilot-stack` go covers" — GitHub reads `closes #88` as a closing keyword wherever it appears in the body. Merging #94 would close the shellcheck ticket that PR #96 implements, and it makes `overlap.sh`'s `closingIssuesReferences` read two tickets for this PR. Breaks AGENTS.md "one concern per PR" and Ticket step 8's `Closes #N`. Fix is one word in the body ("PR #96 addresses #88"); no code change.
2. **The overlap fix does not cover the worked example the PR amends.** The awk skips only `^## (Diff|Testing decisions|Design)$` (`template/.agents/skills/poteto-mode/scripts/overlap.sh:48`) and `skip` clears at the next `## ` heading. Ticket #42's body puts the artifact under three sibling H2s — `## Testing decisions` (line 30), `## Scenario table` (line 36), `## Contract` (line 57). Running the shipped awk over #42's live body still yields the pathspecs `AGENTS.md`, `DECISIONS.md`, `.claude/state/program`, `GIT_LITERAL_PATHSPECS=1`, `origin/main` and others, so `overlap.sh 42` would still match open PRs on `AGENTS.md`. The dated paragraph this run appended to #42 (line 34: "the check skips `## Testing decisions` and `## Design` … so a posted table's example paths do not count") is therefore not true of #42's own body. Nothing on the documented path stops a future agent from posting the contract or test list under its own `## ` heading, since neither Ticket step 6 nor `SCENARIO-TABLE.md` "Where it goes" says to keep the whole artifact inside the one section or to use `###` for its parts. #42 is closed, so nothing breaks today; the rule going forward has the hole.
3. **The PR body omits the model-and-harness line** that AGENTS.md "Pull requests" requires and that PRs #92 and #96 both carry. One line.

## Notes

- The two review comments are genuine, unedited, from the author's account, with the counts and round markers the report claims; the four fix commits are correctly placed between the rounds; `78be65e` is unreviewed and touches only two append-only record files.
- The four playbooks' architect steps still do not carry the posting rule (criterion 3 residual, above). A standalone Feature run never reaches it.
- Round 2's Noted item (the awk is case-sensitive, `to-spec/SKILL.md:59` spells the spec section `## Testing Decisions`) is off the path as it says: `grep -rn "Testing [Dd]ecisions" template/.agents/skills/to-tickets/` returns nothing, so no skill copies the spec's heading into a ticket body. Recording it was the right call.
- Test case 17's two cells differ in expected output for a real reason, not by mistake: the `## Diff` body keeps a `## Notes` section with `README.md` outside the skip, so `paths` is non-empty and the script prints `go:` + `base:`; the new body is entirely inside the two skipped sections, so it takes the empty-`paths` branch and prints `paths: none`. Both assertions are correct.

## The owner's report `## Attention` items

1. **Row `review-1` (the `overlap.sh` fix made the PR touch a stateful script with no table of its own).** *Judgment for Manuel, with a defect attached.* The treatment given — extending #42's row 7 and the contract's "Named paths" rather than writing a fresh table — is proportionate for a two-token regex change, and the new test cell is the assertion for it. But the extension is incomplete: see Issue 2. Manuel decides whether the rule needed its own table; the incompleteness is a defect either way.
2. **Row `ticket-8-pr` (the step-8 record was only rerun at 78be65e after a reviewer flagged it).** *Nothing, except that it produced Issue 1.* The `## Overlap` section is accurate — PR #96 is open on `feat/shellcheck`, closes #88, and shares all nine listed files with this branch. The defect is the sentence that follows the code block, not the record.
3. **Row `fix-1` (an agent amended a closed, merged ticket's human-approved design record).** *Judgment for Manuel.* #42 is CLOSED; the amendment sits on its own dated paragraph at line 34 and changes no cell, and the before/after bodies are saved beside the report. No rule in AGENTS.md forbids it, and no rule authorises it either. Manuel should decide whether a closed, approved record is writable by an agent at all. Note the amendment's factual problem in Issue 2.
4. **Row `records` (commit 78be65e unreviewed).** *Judgment for Manuel, low stakes.* Verified: three added lines, two append-only record files, no skill, script, test or generated file, CI green on it. A strict read of the ticket's rule 7 owes a round; nothing in the commit can break anything.
5. **Row `feature-2-architect` (the ticket that strengthens `architect` skipped `architect`).** *Judgment for Manuel.* The skip is recorded with a reason, and ticket #89's own "Run under" says rule 2 yields no table for a prose-and-patches change. The PR did end up touching a stateful script, but only through a review fix that arrived after the design step. Defensible; the optics are Manuel's call.
6. **The criterion counts rerun at 78be65e, one line number corrected.** *Nothing.* I re-ran every grep the PR body cites and every count matched, including the corrected `## Design` sentence at `runner-prompt.md:10`.
