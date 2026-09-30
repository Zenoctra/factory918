# #138 writer result

The runner, the fixtures and the tests for the #138 re-run are on `wt/138-writer`, and every verify command the brief names passes except one. `check` refuses on pr96-r1, because `word-split.patch` does not apply under plain `git apply` unless `unmatched-glob.patch` is applied first. That needs your call (act-on item 1).

Branch: `wt/138-writer`, created from `feat/reviewer-eval-rerun` (e710e99). Head: `c1fdb49f1af9e74d22d1cbc72df3f0ae3a4290c4`. Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a8cb3c8be984ea435`. Nothing was pushed.

## Commits

- 02e1547 Regenerate the three kept rounds' briefs with the fixed review-brief.sh. Keeps pr94-r1, pr96-r1 and pr99-r1 and deletes the other nine rounds. The recipes' script_at is now e710e99. pr96-r1's `inputs/blast-radius.md` keeps `### Risks` with no items. rebuild.sh gains `--write` and `--export`.
- 48e8e37 Run the reviewer measurement as three arms of three passes at effort high. Rewrites reviewer.py and refusals.sh. Adds the truth stub and agents/. Deletes labels and the six `*-report.historical.md` files.
- c1fdb49 Mask with committed fix patches and score against the real ground truth. This follows your course correction. It adds the `fixes` recipe, `fixes.sh` and the 10 patches under `rounds/*/fixes/`. `truth` is your 14 rows, with the fix column naming patches. rebuild.sh `--export` now runs `git apply`. AGENTS.md now says 27 files.

## Verify

- `python3 tests/eval/reviewer/reviewer.py check`: exit 1, by design, on the real truth. The three agents match their installed copies. The 10 patches rebuild identical. All 15 pr94-r1 subsets and all 3 pr99-r1 subsets apply and brief. 4 of the 15 pr96-r1 subsets conflict (act-on item 1). With the stub truth, before c1fdb49, check passed. The run took 1m22s.
- `bash tests/eval/reviewer/refusals.sh`: all 150 checks passed. The tests include the effort refusal, the usage-limit dropout that is prepared again, each contamination rule (with `cd <export> && gh` and a sibling export), the settled position compared with review-brief.sh via --previous, masked patches and a subset that conflicts, patch drift, malformed truth rows, and the table math.
- `bash tests/eval/reviewer/rebuild.sh pr94-r1` / `pr96-r1` / `pr99-r1`: identical, all three.
- `bash tests/eval/reviewer/fixes.sh`: 10 patches identical.
- `REVIEWER_OUT=<tmp> python3 tests/eval/reviewer/reviewer.py next claude:opus-5 --limit 8`: printed 6 pass-1 lines and made 6 exports. Each export holds the head tree, `diff` and only its own axis's brief. I removed the output afterwards.
- ShellCheck over the brief's globs: exit 0, 27 files. That is one more than before, because of fixes.sh. I updated the count in AGENTS.md "Verifying".
- deslop: I read my diff by hand. No unused imports, and no narrating comments.

## Leading-witness grep

The grep of the six regenerated briefs finds 83 hits in total for "expected", "400", "Under ", "Read nothing", "Run nothing", "at most" and "no more than". None comes from the brief's own instructions. Every hit sits inside quoted material: the diff, the reading pack or the ticket.

The hits that matter are old leading lines inside the code under review:
- "Zero items is the expected result for a clean change":
  - pr96-r1 standards and spec briefs, line 178, a test's grep string in the pack.
  - pr99-r1 standards and spec briefs, lines 38, 118, 336, 526 and 595. pr99 changes review-brief.sh and its docs, so the old wording is in its diff and pack.
- "Read nothing beyond this brief": pr99-r1 standards and spec briefs, lines 390 and 420, the old script's echo lines.

The rest are harmless:
- "lines N of 400" pack headers.
- P24's "overlapping".
- "unexpected" in Manuel's quote.
- "at most three rounds" and "at most MAX_LINES".
- Test strings such as "fake gh: unexpected args".

This is the code the reviewer is asked to review, so I left it. Hit list, by line:
pr96-r1 standards 178 289 810 954 1010 1043 1079 1133 1142; pr96-r1 spec 178 289 810 954 1010 1043 1079 1151; pr94-r1 standards 61 151 517 533 642 651; pr94-r1 spec 61 151 517 533 599 646; pr99-r1 standards 38 41 47 71 84 106 117 118 121 149 175 241 330 336 340 348 390 420 526 579 595 599 718 831 840; pr99-r1 spec 38 41 47 71 84 106 117 118 121 149 175 241 330 336 340 348 390 420 526 579 595 599 718 795 803 870 900 901 918.

The runner prompt is unchanged, and the check against BANNED is kept.

## Inputs that name a ground-truth bug

I removed nothing beyond the pr96 Risks items. No other input line names a bug as a risk. Two lines in pr96-r1 `blast-radius.md` "### Cleared" come close:
- "poteto-mode: the playbook sentence lives in the patch (`opening-a-pr.md.patch:8`)". This is the author calling the G4 site clean.
- "Fixture step: the zero-argument form over the template's files gives `files checked: 11`". This touches the bare form that G4 is about.

Both steer away from the bug rather than hand it over. The tickets name none.

## Commits a fresh clone lacks

None beyond refs/keep/103. The patches are committed, so `next` and `check` need only the heads under refs/keep/103 and e710e99, which is on main. fixes.sh, which rebuilds the patches, needs these commits:
- Under refs/keep/103: b368116, c83f166, 715100c, 0c63fa6, ca2c106, 01e5386, 72953c0, a64c7e6, 52ccd8e, 32978fa, 384bb43.
- On main only, not under refs/keep: ae1b4b5.

The fetch hint names refs/keep/103 alone, as your correction says.

## Act on

1. **pr96-r1 word-split.patch.** It is 72953c0 limited to `template/.github/shellcheck.sh`. `git apply` refuses it on 69bd412 without unmatched-glob.patch under it: "error: patch failed: template/.github/shellcheck.sh:35 ... patch does not apply". Its context has 01e5386's `matched=0` line.
   - Failing subsets: {word-split}, {word-split, cached-binary}, {word-split, bare-gate} and {word-split, cached-binary, bare-gate}.
   - Measured: `git apply -C1` and `git apply --3way` apply it alone and with cached-binary, and `patch -p1` applies it. `-C2` fails.
   - I sent you this by message and changed nothing. The choices are -C1, --3way, a G2 fix column of `unmatched-glob.patch,word-split.patch`, or a patch built another way.
2. **Which files each patch holds.** I followed your rule: the `where` file, plus the files the notes say the fix needs.
   - I added the generated copies that carry the same bug text: `template/docs/factory918/SCENARIO-TABLE.md` in body-file.patch and `template/docs/factory918/MANUAL.md` in five-documents.patch and merge-read.patch.
   - bare-gate.patch includes `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`, per the notes.
   - architect.patch and hole-field.patch touch vendored skills (`architect/SKILL.md`, `spec-review/SKILL.md`) but leave out the matching `patches/` files. A masked tree can therefore show a vendored edit with no patch, which a Standards reviewer may file. That would count as "other hard items", not as truth. Say if you want the patch files in.
3. **Masked commit shape.** The patches are folded into the head commit by amend, with the head's committer identity and date. The brief's `## Commits` list keeps the head's lines, and no fix subject reaches the reviewer. The folded sha is recorded as `tree` in run.json.
4. **One chain per brief.** The run identity is (descriptor, brief, step), as the brief says, so each arm has 6 chains per model. The audit's 5c sized for 4 chains per brief, which gives 24 per arm. Adding a chain index to RunId and the directory is a small change if you want it.
5. **Contaminated and usage-limit runs.** `next` moves them to `<out>/dropped/<descriptor>/<round>/<axis>/<step>/<n>/` and prepares them again. This applies to any step, not only prerequisites. The table counts them from there.
6. **Effort.** A receipt is refused unless every served assistant line records `effort: high`. A transcript that records no effort is refused too, since effort high cannot then be shown. Real transcripts carry `effort` on every assistant line (checked on 40 recent ones).
7. **Absolute paths in Bash.** A path whose first component does not exist at `/`, such as awk's `'/^## /'`, is read as a pattern and not flagged. A bare `/` is not flagged either.
8. **Table columns.** I added a "context failures" column to the brief's columns. new, cumulative, demoted and other are means per chain. Pass-1 rows repeat the shared runs in all three arms.
9. **Deleted fixture files.** labels and the six historical reports are gone. check no longer calibrates against them. Git history keeps them, and your truth notes cite them by path at e710e99.
10. **The settled test.** It runs this tree's review-brief.sh, because CI's shallow checkout has no e710e99. If that script's settled paragraph ever changes, the test fails, and SETTLED_RULE (copied from e710e99) needs a decision.
11. **Docs.** I did not touch docs/knowledge, M0-findings or DECISIONS. The docs and CI still describe the old verbs: `run`, labels and Sonnet/Codex. CI runs refusals.sh, which passes.

## Round 2: the owner chose --3way (2026-09-23)

`check` now passes on the real truth, with every masked patch applied by `git apply --3way`. The new head is `11262acafc6ed851999a1fbe925e56ce0a999843`.

- **The change.** Commit 11262ac, "Apply the masked arm's fix patches with git apply --3way". rebuild.sh `--export` runs `git apply --3way` for every patch, in the order given. The clone holds each patch's preimage blobs, so a hunk lands by merge, never by fuzz. A subset that still conflicts exits 3 and `check` refuses it, as before. Nothing else changed. Chains stay one per brief per arm.
- **`python3 tests/eval/reviewer/reviewer.py check`:** exit 0. The 3 agents match, the 10 patches rebuild identical, and 33 subsets apply and brief with 0 conflicts: 15 at pr94-r1, 15 at pr96-r1 and 3 at pr99-r1.
- **`bash tests/eval/reviewer/refusals.sh`:** all 150 checks passed. The test fixture's f2.patch still conflicts alone under --3way, so the conflict refusal stays tested.
- **`rebuild.sh` pr94-r1, pr96-r1, pr99-r1:** identical, all three.
- **`fixes.sh`:** 10 identical.
- **`next claude:opus-5 --limit 8` with a temporary REVIEWER_OUT:** 6 lines and 6 exports. I removed them afterwards.
- **ShellCheck:** exit 0 over 27 files.

Act-on item 1 above is settled by this round. Items 2 to 11 stand.
