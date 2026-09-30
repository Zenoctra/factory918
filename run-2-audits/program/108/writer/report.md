# Writer report, ticket #108

For a person: the three commits make `review-brief.sh` refuse a brief while a risk line or a writer flag has no `fixed: <sha>` or `accepted: <reason>`. Every cell of tables A, B and C passes, the existing suite passes, and `factory918 sync` reproduces the template.

Branch `wt/108-writer`, based on a9ebdac034bc8389895096b7b93d9cd52ea19588 (checked). Nothing was pushed.

## Commits

1. `7cfdceb` Test every risk and writer flag for a disposition before the brief. Changes `tests/spec-review/fake-gh.sh` (`FAKE_ISSUE_BODY`, `issue-error`; unset, the output is the same as before), `tests/spec-review/review-brief.sh` (the #108 section at the end of `suite`, one assertion per non-blank cell in table order, the #91 fixtures gain `accepted: fixture`, the new `risk_rule`, the two criterion-5 pins, and the header comment), `tests/spec-review/no-stale-wording.sh` (the retired tail), and `.github/workflows/factory-ci.yml` (see flag 1).
2. `4ad87b9` Refuse a brief while a risk or a writer flag has no disposition. Changes `template/.agents/skills/spec-review/scripts/review-brief.sh`: `disposed` (runner A's prototype awk) and `undisposed` beside `$fenced`, `where` hoisted to the top of the crossing block, the risk check after the Risks-heading check, the ticket fetch moved before the reading pack, then the flag check, the new `risk_rule`, and the header comment.
3. `bf459a9` Show the disposition line where risks and writer flags are written. Changes spec-review SKILL.md (a risk refusal in step 1's cross-cutting paragraph, a new step-1 paragraph for the flag refusal, and the step-4 sentence), opening-a-pr.md, blast-radius SKILL.md (with the new patch `patches/pstack/blast-radius/SKILL.md.patch`, its `series` line and SOURCES.md item 19), the four playbook pointers, ticket.md steps 5 and 6, and SOURCES.md items 3 and 6. Every vendored edit was regenerated as a patch against the pre-patch base.

## Verification (at bf459a9)

- ShellCheck at the pin over 26 files: `ShellCheck 0.11.0, files checked: 26`, exit 0.
- `tests/spec-review/review-brief.sh`: `ok 1720 assertions`.
- `tests/spec-review/review-comment.sh`: `ok 298 assertions`.
- `tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`.
- `tests/shellcheck/gate.sh`: `ok 17 assertions`.
- `tests/hooks/delegation.sh`: `ok 55 assertions`.
- `tests/poteto-mode/overlap.sh`: `ok 57 assertions`.
- `tests/eval/reviewer/refusals.sh`: `all 230 checks passed`.
- `tests/show-me-your-work/check-trail.sh`: `ok 66 assertions`. `tests/knowledge/provisional-ids.sh`: `26 assertions passed`.
- `./factory918.sh sync`: 34 patches applied, none failed, and `git status --porcelain` stayed empty relative to the edited tree. The template diff was unchanged, 8 files, +12/-10.
- `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`. `build_knowledge.py` changed nothing.
- By hand on the real ticket: `review-brief.sh origin/main --ticket 108` printed the two brief paths and exited 0. The live body has no Writer flags list, and its table rows, `### Legend` and prose all passed.
- By hand with a bare flag: the live #108 body plus `### Writer flags 2026-09-23` with `1. ... fixed: <HEAD>` and `2. mawk is not exercised locally`, served through the fake gh. The script exited 1 with the flag header and `  no disposition: 2. mawk is not exercised locally`, and it wrote no `.claude/state/review` or review directory. The empty parent `.scratch/review` was removed afterwards.

## Failing first (the test commit against HEAD's script)

I made a keep-going copy of the suite (each `exit 1` replaced by `true`), ran it at 7cfdceb, then deleted the copy. Both layouts failed on the same cells:

- Table A: every cell of A3 to A8. The passing cells, whose outcome does not change, were A1/F, A1/P, A2/F, A2/P, A9/F, A9/P, A10/F and A10/P.
- Table B: every r cell (B1 to B22), plus B3/f, B15/f and B16/f. B1/f and B6/f passed, since they are B.
- Table C: every r cell, and C1/f to C5/f including both C4/f cells. C6/f and C7/f passed, since they are B.
- #91's cells 1A, 2A, 3A, 7A and 8A failed on the new risk sentence in the Walk bullet.
- These pins failed: SKILL.md step 4's risk sentence, the opening-a-pr.md disposition line and the blast-radius hand-back line.
- At 4ad87b9 (the script without the prose), the same copy fails only those three pins. Every table cell and every earlier cell passes. The plain suite stops at the SKILL.md pin until bf459a9.

## Writer flags

1. `.github/workflows/factory-ci.yml`, a file the brief did not name, changed. The fixture step's `/tmp/blast.md` risk line gained `accepted: a fixture`. Without it, CI's apply-diff brief (cross-cutting) would hit the new risk refusal. I made the change in the test commit.
2. A6/F's exact stderr is today's `not cross-cutting; blast8.md is not pasted` line followed by the RF refusal. The not-pasted line prints in the grounding block, before the fetch. The ticket writes "RF[as A5]". I asserted both lines.
3. The refusal headers are my wording. The design's header covered only "indent a continuation and fence a proof". The ticket's contract also asks for the exact opener, so both headers end "indent a continuation, fence a proof, and write the heading exactly that way:". SKILL.md step 1 quotes each first clause, then "...".
4. Commit order means the script commit alone does not pass the plain suite. The three prose pins stay red until the prose commit (see "Failing first").
5. Fixtures, table A. F, P and R use the text commit t8 as the fixed point, and the hook commit sits on it. R reads `--previous` with a round-two `fix only after <t8>` comment (#106's `fo_comment`). S uses `--paths <hook> --commits HEAD`. Non-cross-cutting runs detach to t8 and run from the commit before it. Each template writes `<H>` for the HEAD of that run, so "fixed: <HEAD short sha>" is literal in every run. The commits name no ticket, so every run passes `--ticket 7` except A9's.
6. The f cells of tables B and C run with no grounding and no PR body, so stderr is empty. The tables name no form for column f.
7. C7/f uses three lines taken from this ticket's body: criterion 2, `Writer flags are recorded by the orchestrator.`, and the C1 table row. The test does not contain the whole body. The hand run covers the whole live body.
8. mawk was not exercised. There is no mawk or gawk here; macOS awk ran everything. I did not pull an Ubuntu image. The awk uses no interval expressions and nothing gawk-specific. I wrote the near-miss bracket as `[.:]`, not the prototype's `[:.]`, so no awk can read `[:` as the start of a class. CI on Ubuntu is the first mawk run.
9. `refused8` checks `.scratch/review/<id>`, not `.scratch/review`. Today's refusals (RG included) leave the empty parent directory, and the legend names `<id>`.
10. The ticket fetch block moved with its text unchanged. Only the blank line before it went away.
11. `issue-error` in the fake fails every `gh issue view`, both the body call and the comments call.
12. The four playbook pointers read "(Ticket step 6 gives the form; `review-brief.sh` refuses the review while one has none)", the brief's example. The sentence covers risks and flags, but Ticket step 6 gives only the flag form. The risk form is Ticket step 5 and Opening a PR.
13. The blast-radius Risks bullet also gained "one per line" and "fenced under its risk" (design 4.3 item 6), besides the disposition sentence. Its patch is the last line of `patches/series`.
14. The flag refusal is its own paragraph in spec-review step 1, right after the cross-cutting paragraph. It says a ticket with no list is unaffected and the risk check runs first.
15. I did not touch DECISIONS.md, the ledger or M0-findings. The owner still has to write P108 and the P28 amendment.
