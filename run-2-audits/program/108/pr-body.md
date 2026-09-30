A delegate's report reached the owner and sat there. On PR #96 the blast-radius lane named two risks before review, and rounds one and two found them again. On PR #99 the writer's flag 9 was the design hole that restarted the review. #105 wrote the rule that such a report is an act-on list, but nothing refused a review while an item on it had no answer.

`review-brief.sh` now refuses to brief in two cases. The first is a cross-cutting diff whose grounding has a risk line with no disposition. The second is a ticket whose `### Writer flags <YYYY-MM-DD>` list has a flag with no disposition. A disposition ends the line: `fixed: <sha>` names a commit in HEAD's history, and `accepted: <reason>` gives a reason. Either refusal exits 1, names each offending line, and writes no state.

## Why

One line grammar serves both sites, so the two checks cannot drift apart. The design is the scenario table posted on the ticket under `## Testing decisions`. Two architect runners worked on it: runner A (Claude Opus 5.5) is the base, and its grammar was prototyped on 41 inputs. The owner ran 13 more adversarial inputs before the table was posted. The grammar closes the fail-opens a looser rule would leave:

- Every unfenced line of a list that is indented no deeper than the list's first line is an item. A bullet risk or a prose risk is checked, not skipped.
- A heading that looks like an opener and is not one is refused, since it would hide its whole list. So is a fence that opens inside a list and never closes.
- A `fixed:` sha must resolve and be an ancestor of HEAD, so a typo or a commit from another branch is refused.

## Scope

- `template/.agents/skills/spec-review/scripts/review-brief.sh` gains the `disposed` awk and `undisposed`. The risk check runs after the Risks-heading check. The ticket fetch moves, unchanged, to before every state write, and the flag check runs after it. `risk_rule` now asks whether the diff honors each disposition.
- `tests/spec-review/review-brief.sh` asserts one cell of tables A, B and C per assertion, and it comes first in commit order. The #91 fixtures gain `accepted: fixture`. `tests/spec-review/fake-gh.sh` gains `FAKE_ISSUE_BODY` and `issue-error`, and `tests/spec-review/no-stale-wording.sh` pins the retired sentence tail.
- Prose changes through the patches: `spec-review` SKILL.md steps 1 and 4, the Blast Radius bullet in `opening-a-pr.md`, and the Risks bullet in the blast-radius hand-back. The hand-back gets a new patch, `patches/pstack/blast-radius/SKILL.md.patch`, with a `series` line and SOURCES.md item 19. The pointers in `feature.md`, `bug-fix.md`, `refactoring.md` and `perf-issue.md` are also updated. `ticket.md` is ours and changes directly: step 5 gets the risk form, and step 6 gets the writer-flags list.
- `.github/workflows/factory-ci.yml`: the fixture grounding's one risk now carries `accepted: a fixture`. CI's apply-diff brief is cross-cutting, so it has to follow the new rule.

## Tradeoffs

- After a rebase, a PR body's `fixed:` shas no longer sit in HEAD's history. The brief refuses them by name until they are updated. This is a loud, one-edit cost. The alternative, a format-only check, lets a wrong sha pass silently.
- The flag list is read anywhere in the ticket body, not only under `## Testing decisions` or `## Design`. Enforcing the placement would close no fail-open.
- A risk written after a heading of the same level below the list is not read. GitHub renders it under that heading too.

## Blast Radius

The change reaches every `spec-review` run in the factory and in every applied project. The flag check runs whenever the brief has a ticket, at every round and in both forms. A ticket with no Writer flags list is unaffected, and so is a diff that is not cross-cutting whose ticket has no list. A cross-cutting review whose grounding predates this change is refused until each risk line carries a disposition. That is the point of the change, and the message says how to add one. This diff itself is not cross-cutting: it touches no hooks directory, no settings.json and no `factory918` skill file.

## Overlap

```
go: autopilot-stack
#135 feat/eco-tier: SOURCES.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/docs/factory918/DECISIONS.md
```

## Verification

Every check below ran at the head of this branch.

- Criterion 1 (a risk without a disposition is refused, with no state written): table A cells A3 and A4 across the F, P, R and S forms, table B, and table C column r, in `tests/spec-review/review-brief.sh`, which prints `ok 1720 assertions`.
- Criterion 2 (a writer flag without a disposition is refused, and a ticket with no list is unaffected): cells A5, A6, A8, B/f and C/f. By hand, `review-brief.sh origin/main --ticket 108` against the live ticket body exits 0. The same body with a bare flag, served through the fake gh, exits 1 with the line named. The writer lane ran both.
- Criterion 3 (the walk reads each disposition): the A3 cells check that the Spec brief's Walk bullet ends with the new sentence. The SKILL.md pin holds step 4 word for word.
- Criterion 4 (the table on the ticket, and the tests before the script): the table is on #108 under `## Testing decisions`. Commit `7cfdceb` adds the tests. Run against the old script, it fails every new refusal cell and the three prose pins, which the writer's report lists. Commit `4ad87b9` adds the script.
- Criterion 5 (the disposition line in Opening a PR and in the blast-radius hand-back): the two pins pass, and `./factory918.sh sync` reproduces both through their patches.
- ShellCheck 0.11.0 at the pin over 26 files: clean.
- `tests/spec-review/review-comment.sh`: `ok 298 assertions`. `tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`. `tests/shellcheck/gate.sh`: `ok 17 assertions`. `tests/hooks/delegation.sh`: `ok 55 assertions`. `tests/poteto-mode/overlap.sh`: `ok 57 assertions`. `tests/show-me-your-work/check-trail.sh`: `ok 66 assertions`. `tests/knowledge/provisional-ids.sh`: `26 assertions passed`. `tests/eval/reviewer/refusals.sh`: `all 230 checks passed`.
- `./factory918.sh sync` leaves `git status` clean. `python3 tools/build_knowledge.py` leaves it clean, and `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`.
- The Writer flags list on #108 has 15 flags, each with a disposition. This PR's own review is the first run of the flag check on a real ticket.
- CI run 35912356052 at `6e5c539` passed both jobs, Factory and Fixture. That run is the first run of the awk under Ubuntu's mawk. It includes the fixture brief, whose one risk carries `accepted: a fixture`.
- `spec-review` round 1 ([comment](https://github.com/Zenoctra/factory918/pull/136#issuecomment-5802001018)) reported 0 hard findings on either axis and ended `act-on items: 0`. Its brief ran the new flag check over #108's 15 flags and resolved both `fixed:` shas.

## Records

- P108 in `DECISIONS.md` covers the grammar, where the checks sit, and the holes the design accepts.
- P28 is amended: the walk sentence now asks whether the diff honors each disposition.
- One new line in `docs/agents/ledger.md`.

Closes #108

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Claude Opus 5.5 on Claude Code
