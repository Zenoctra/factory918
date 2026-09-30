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
