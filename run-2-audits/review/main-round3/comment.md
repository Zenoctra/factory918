Third and last round on this PR: nothing found breaks the code in normal use, and the five items worth acting on (a fence-closing rule, one doc line, one ordering, one test pin, one comment) are filed as #79 and fixed on #78, which already edits the same script. Reviewed commit c60596c; the count line below is produced by the script as #78 defines it, because the round-three rule this stack introduces is what turns remaining items into a ticket instead of a fourth round.

## Standards

## Would break

## Standards breaches

1. **Step 6's refusal list omits the numbering refusal.** `numbered()` is a real exit-1 path with its own fixture (`tests/spec-review/review-comment.sh`, "numbering restarts under the second heading"), but SKILL.md step 6 enumerates the refusals and leaves it out, so an orchestrator that hits it has no documented reason. CODING_STANDARDS.md, Markdown: skills are written with `/writing-for-agents`; the script's own documentation should list what it refuses.

```
It exits 1, printing why and clearing nothing, when a report is missing or has no `hard findings:` line (...); when a report's `hard findings: N` is larger than its `## Would break` item count (...); when a report's or the judgment's `## ` headings are not the shape above; when `judgment.md` is missing; when the judgment's item count differs from the reports'; or when a `[S<n>]` or `[P<n>]` reference is missing, repeated or points at no item.
```

## Fix alongside

2. **The fixed point prefers a foreign state over the dir's own copy.** Judgement call. On a rerun (`review-comment.sh <dir>`) while a *different* review holds the state, the summary prints that other review's fixed point. `review-brief.sh` now writes `$dir/fixed-point` precisely so the dir is self-describing; the two branches are in the wrong order. The script already guards the same mismatch one line below when clearing the state.

```sh
if [ -f "$state/fixed-point" ]; then fixed="fixed point $(cat "$state/fixed-point")"
elif [ -f "$dir/fixed-point" ]; then fixed="fixed point $(cat "$dir/fixed-point")"
```

3. **Duplicated Code: the report shape lives in two files, one sentence of it pinned.** `review-brief.sh` writes the heading bullets and SKILL.md step 4 repeats them verbatim, but `tests/spec-review/review-brief.sh` asserts only `$definition` against SKILL.md. The heading descriptions can drift silently. Extend the existing `has "$skill/SKILL.md" ...` line to the three bullets.

```sh
has "$skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
```

4. **The CommonMark claim is wider than the code.** A closing fence may not carry an info string; this treats ```` ```sh ```` inside a ``` block as a close. The longer-fence case is tested, so the behavior is fine, but the comment overstates it.

```sh
# same character at least as long (CommonMark), so a hunk that quotes a fence stays inside its
```

hard findings: 0

## Spec

## Would break

1. **`act-on items` now counts Ask, but babysit is still told to fix a nonzero count on this PR.** The judgment's Ask bucket is by definition the human's call ("You never dismiss one of these; it waits for the human"), yet it is added into `act-on items`, and the babysit patch this PR leaves untouched reads that line as an agent-fixable blocker. A round whose only finding is an Ask leaves babysit looping on a question it is forbidden to answer, with no documented "ask the human" exit. The ticket puts the babysit wording in the three-rounds criterion, but the Ask bucket ships here, so the gap is live on `main` the moment this merges.

```
4. `playbooks/babysit.md`: ... step 6 adds `act-on items: 0` on the latest commit's `spec-review` comment to merge-ready, with a nonzero count or a missing review comment a blocker of the same class as a red check, fixed on this PR.
```

2. **The fence parser closes on an info string, so a report that quotes fenced code is refused.** The script says it follows CommonMark, where a closing fence may carry no info string. Its rule accepts any line of the same character and length, so a hunk quoting ```` ```sh ```` inside a ``` ``` ``` block ends the block early and the rest of the hunk parses as headings and items — a shape or numbering refusal of a correct report. The briefs never tell reviewers to use a longer outer fence, and quoting fenced code is normal in this repository. (Indented fences, which CommonMark allows up to three spaces, are also unrecognized.)

```
# a fence opens on a line of three or more backticks or tildes and closes only on a line of the
# same character at least as long (CommonMark), so a hunk that quotes a fence stays inside its
```

## Latent

3. **In the `opus` preset the Spec axis is not cheaper than the writer.** Both are `claude:opus@high`, so the row buys nothing there; `models.md` silently softens the ask to "no dearer".

```
- [ ] **A models row for the Spec axis.** `spec reviewer` has its own row in both presets ... so its finder can run cheaper than the writer's lane
```

4. **The Spec report has no `## Fix alongside`.** A smell found on the Spec axis has no bucket, and adding one is refused by the shape check.

```
Smells go under `## Fix alongside`, are not counted, and are fixed only when a would-break fix already touches that code.
```

5. **Five of eight criteria are absent:** blast-radius grounding, carry-forward, the author's ticket comments, three rounds, the ledger line. Consistent with "a stack of PRs, one concern each", but nothing in the diff records which PR carries them.

## Not asked for

6. **The `P17 | (promoted)` row** in both `DECISIONS.md` copies is a table-numbering cleanup the ticket does not ask for.

hard findings: 2

## Judgment

## Act on

1. [S1] **Step 6 omits the numbering refusal.** A documented list that is short by one; fixed on #78. ticket: #79
2. [S2] **The fixed point prefers a foreign state over the dir's own.** The dir is self-describing since round one; read it first. ticket: #79
3. [P2] **A closing fence may not carry an info string.** Real: a quoted ```sh inside a fenced hunk ends the block early and a correct report is refused. ticket: #79
4. [S3] **The heading bullets are not pinned by the test.** Rides with the same ticket, since the test is edited for it. ticket: #79
5. [S4] **The CommonMark comment overstates the code.** One line, alongside [P2]. ticket: #79

## Ask

## Consider

1. [P3] **In the opus preset the spec reviewer is not cheaper than the writer.** Raised in round two as well; the choice is Manuel's and the doc says "no dearer".

## Noted

1. [P1] **An Ask item leaves babysit looping under the old text.** #78, stacked on this PR, carries the babysit sentence that an Ask item waits for the human; the stack lands together.
2. [P4] **The Spec report has no Fix-alongside heading.** Smells are the Standards axis's job; a Spec reviewer that spots one says so under Not asked for, and the judge sorts it.
3. [P5] **Five criteria are not in this diff.** #78 carries three of them and the ledger line; the blast-radius grounding is the third PR of the stack.

## Dismissed

1. [P6] **The P17 row was not asked for.** The round-two Standards reviewer flagged the gap; one row that says why the number is retired is the smaller cost.

Standards: 0 would break of 4; Spec: 2 would break of 6; judged: act on 5 (5 with a ticket), ask 0, consider 1, noted 3, dismissed 1; fixed point main.
round: 3 of 3
act-on items: 0
