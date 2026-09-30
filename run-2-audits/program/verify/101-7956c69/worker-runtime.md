verdict: PASS

# Slice: live runtime floor, PR #101 (ticket #91) at 7956c6964cea8088e02ae8798102ce36b3c15cad

Setup, in my own worktree `.claude/worktrees/agent-a6e196a1e1682c278`:

- `git fetch origin feat/spec-walk-risks feat/design-hole-restart main`, then `git checkout --detach 7956c69…`. `git rev-parse HEAD` printed `7956c6964cea8088e02ae8798102ce36b3c15cad`; exit 0.
- `git merge-base --is-ancestor 52ccd8eb509a2871260827a8514c3a1fcaac4d5d HEAD`; exit 0. Patch verified as `git diff 52ccd8e..7956c69` (15 files, +185 −43).
- Private `TMPDIR` under the session scratchpad. Nothing under version control was written.

Harness: an independent scratch repo (not the tests' own), laid out as a project — the skill at the SHA copied to `.agents/skills/spec-review/`, a `.claude/hooks/noop.sh`, `.claude/skills -> ../.agents/skills`, and `tests/spec-review/fake-gh.sh` copied onto `PATH` as `gh` (its `FAKE_PR_BODY` technique supplies the PR body). Three commits: `base` (layout), `cross` (edits the hook and `lib.sh`, cross-cutting), `HEAD` (edits `lib.sh` only). So `base` is a cross-cutting fixed point and `cross` is not. Every run below is `review-brief.sh` or `review-comment.sh` at the SHA, invoked for real.

## (a) File grounding with `## Risks`, cross-cutting diff

- `review-brief.sh base --ticket 91 --blast-radius <file with '## Risks'>` → exit 0, wrote `standards-brief.md` and `spec-brief.md`.
- The Spec brief's emitted bullet, `spec-brief.md:94`, quoted whole:

  > - `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing. The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing.

  The sentence is one line with the old bullet text, so the assertions that pin the old text still hold as substrings, as the ticket's Contract requires.
- Standards brief: `grep -c 'The diff is cross-cutting:'` → `0`, exit 1; it carries no `## Walk` bullet at all (`grep -c '## Walk'` → 0). The sentence is Spec-only.
- The brief's heading is `## Blast radius`, matching the sentence's backticked reference.

## (b) Demoted `### Risks`, in a file and in a PR body, LF and CRLF

- File with `### Risks` (`--blast-radius`): exit 0, risk sentence present once in Spec, absent from Standards. Pasted section headings: `## Blast radius`, then `### What it does / ### Safe because / ### Risks / ### Cleared / ### Before you merge`, then `## Diff`.
- PR body (`FAKE_PR_BODY`, no `--blast-radius`), LF: exit 0, sentence present once in Spec, `0` in Standards. The section was cut correctly — `## Why` and `## Verification` excluded, `### Cleared` included.
- Same body with CRLF line terminators (verified by `od -c`): exit 0, identical result; headings `## Blast radius / ### What it does / ### Risks / ### Cleared / ## Diff`.
- Extra: a CRLF **file** grounding whose heading is `## Risks` with trailing spaces → exit 0, accepted. CR and trailing blanks are stripped before the match, as the Contract says.

## (c) Refusals: no Risks heading, and Risks only inside a fence

All three exit 1, and after each `ls .claude/state` reported "No such file or directory" — no state written under `.claude/state/review/`. `.scratch/review/<id>` was removed too (the parent was left empty).

- File with the heading renamed (`## Dangers`):

  > review-brief: the blast-radius grounding (<abs path>/g-none.md) has no Risks heading outside fenced text; put the risks under a line that is exactly `## Risks` in the file, `### Risks` in the PR body, where the grounding's headings are demoted one level so the section stays intact
- File whose only `## Risks` sits inside a ```` ```markdown ```` block: the same message, same path, exit 1. Fenced text is not read.
- PR body whose grounding heading is `### Dangers`: the same message with `where` = "the PR body's Blast Radius section", exit 1.

Each message names the file or the body and states both accepted forms, so it says what to correct.

## (d) Non-cross-cutting diff

- `review-brief.sh cross --ticket 91 --blast-radius <good file>` → exit 0, and on stderr:

  > review-brief: the diff is not cross-cutting; <abs path>/g-h2.md is not pasted
- The Spec brief carries the plain Walk bullet (`spec-brief.md:59`), `grep -c 'The diff is cross-cutting'` → `0`, and there is no `## Blast radius` section.
- With a PR body present instead of `--blast-radius`: exit 0, no sentence, no blast section — the body is never fetched.

## (e) `review-comment.sh` on a walk continued with two risk lines

Built one review dir by hand (Standards report 1 item, Spec report 1 item, judgment 2 items, `round` 2, `fixed-point` main), copied it, and appended to the copy's `## Walk` two lines numbered 4 and 5 naming risks.

- Both runs: exit 0, empty stderr.
- `diff` of the two comments: the only difference is lines 25–26, the two quoted walk lines themselves. Every other line is byte-identical, including:

  > Standards: 1 would break, 0 fail open, of 1; Spec: 1 would break, 0 fail open, of 1; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point main.
  > round: 2 of 3
  > act-on items: 1

  So the numbering and the `act-on items:` line are unchanged. The mechanism is structural, not textual: `items()`, `specs()` and `numbered()` all carry `h != "Walk"` (`review-comment.sh:57`, `:76`, `:81`), so a risk line under Walk can never be an item whatever it says.

## (f) The changed prose, and whether an agent can follow it

- `template/.agents/skills/spec-review/SKILL.md:27` (step 1), added sentence:

  > The grounding carries its risks under a line that is exactly `## Risks` in a file or `### Risks` in a PR body, where the file's headings are demoted one level so the `## Blast Radius` section stays intact (Opening a PR); the script reads the grounding outside fenced text and exits 1 the same way when neither line is there: "…"

  Followable: it names both forms, the source each belongs to, the fence rule, and quotes the refusal verbatim. It matches the runtime exactly, message included.
- `template/.agents/skills/spec-review/SKILL.md:101` (step 4) carries the risk sentence word for word, identical to `risk_rule` at `scripts/review-brief.sh:296` and to what (a) emitted. Followable.
- `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:18`:

  > - `## Blast Radius`. … For a cross-cutting diff (Ticket step 5) this section is `.scratch/<ticket>/blast-radius.md` with its `## ` headings demoted to `###`, because an undemoted `## ` line ends the section, and `spec-review`'s `review-brief.sh` reads it from here and finds the risks under `### Risks`.

  Followable, and it gives the reason rather than only the rule. I confirmed the reason is true: a PR body with undemoted headings and nothing but headings after `## Blast Radius` is refused with the older "without a blast-radius grounding" message (the section is empty), and one with prose before the undemoted `## Risks` is refused with the new Risks message. Both exit 1, no state.
- No contradiction with the Ticket playbook step 5 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:9`). It now says the file is written "each part under a `## ` heading and one numbered risk per line under `## Risks`" and that the PR body's section is "that file with its `## ` headings demoted to `###`". The three documents agree on both levels and on which source takes which.

## Extra: the rest of the ticket's scenario table, driven live

The ticket's `## Testing decisions` table names ten rows; I drove the ones my slice did not already cover and all matched their cells.

- 7A, both levels present (`## Risks` then `### Risks`): exit 0, sentence present once. The first unfenced heading satisfies the check.
- 8A, Risks heading with nothing under it: exit 0, sentence present once. No code counts risks, as designed.
- 4A with prose left in the section: the new refusal naming the PR body, exit 1, no state. 4A with nothing left: the older refusal, exit 1, no state. Both as the cell reads.
- 10, `--blast-radius` naming a missing file: the `usage()` block on stderr, exit 1, before anything else.

## Extra: the repo's own gates

- `bash tests/spec-review/review-brief.sh` → `ok 468 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 136 assertions`, exit 0.
- `bash .github/shellcheck.sh` → `ShellCheck 0.11.0, files checked: 6`, exit 0. The default globs are project-relative and so miss the factory's `template/` copies, so I also ran `bash .github/shellcheck.sh 'template/.agents/skills/*/scripts/*.sh' 'template/.claude/hooks/*.sh'` → `files checked: 10`, exit 0. The changed script is clean.

## Issues

None.

## Notes

- The risk sentence says "the Risks heading of the `## Blast radius` section above". That is literally true only for a grounding whose headings are `###` (the PR-body path, and a file pasted back). For the `--blast-radius FILE` + `## Risks` path the brief pastes `## Risks` as a sibling of `## Blast radius`, so the brief's headings read `## Blast radius / ## What it does / ## Safe because / ## Risks / … / ## Diff` and the Risks heading is not strictly inside the section. A reviewer can still find it unambiguously — there is exactly one `## Risks` in the brief — and the ticket's cells 1A and 2A bless both levels on purpose ("the source restricts no level"), so this is a wording looseness, not a defect. Flagging it only because the sentence is pinned word for word in three places and would be awkward to reword later.
- `template/.agents/skills/blast-radius/SKILL.md:43` still documents the hand-back as a bullet list (`- **Risks.**`). I ran that exact shape through the gate and it is refused with the new message, exit 1. This is deliberate — the ticket's table says "`template/.agents/skills/blast-radius/SKILL.md` is vendored and not touched" and cell 5A names the bullet hand-back as the refused case — and Ticket step 5 now carries the correction ("each part under a `## ` heading and one numbered risk per line under `## Risks`"). The cost is that an agent who runs `blast-radius` and pastes its reply without reading Ticket step 5 closely gets refused. The refusal message says what to correct, so the loop closes on the first try, but the two documents now describe different shapes for the same artifact.
- The 4A no-prose case is refused with the older "cross-cutting diff … without a blast-radius grounding" message rather than the Risks message, because the undemoted `## ` line empties the section before the Risks check runs. The ticket's cell predicts exactly this, and Opening a PR explains the demotion, so an author who reads the message and the playbook gets there. Worth knowing that the message in that case does not mention demotion.
- `.claude/state/review` is removed and rebuilt only after both grounding checks pass (`review-brief.sh:262` onward), so a refusal leaves any earlier review's state untouched rather than clearing it. That is the pre-existing arrangement, unchanged by this PR.
