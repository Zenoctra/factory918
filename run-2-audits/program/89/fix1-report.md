# Fix lane report, PR #94 round 1 (ticket #89)

Four commits on `wt/89-fix1`, branched from `feat/design-artifact-on-ticket` at c83f166. Every check passes at HEAD. Nothing was pushed.

Branch: `wt/89-fix1`
HEAD: `0c63fa6f239ef930abacabe9086b3455a7313b2e`
Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aaed523b3536a08fa`

## Commits (`git log --oneline feat/design-artifact-on-ticket..HEAD`)

```
0c63fa6 Make the architect skill and the to-spec bullet agree with the runner prompt
ca2c106 Count five project documents in the manual and the build script
3f5033f Skip the two artifact sections in the overlap check
b368116 Write the whole ticket body back when posting the design artifact
```

b368116 answers [S1] and [P4]. 3f5033f answers [P1] and [S5]. ca2c106 answers [P3]. 0c63fa6 answers [P2] and [S2].

## Diff stat (`git diff --stat feat/design-artifact-on-ticket..HEAD`)

```
 SOURCES.md                                         |  2 +-
 docs/knowledge/INDEX.md                            |  2 +-
 docs/knowledge/core/DECISIONS.md                   |  2 +-
 docs/knowledge/core/MANUAL.md                      |  5 +++--
 docs/knowledge/core/SCENARIO-TABLE.md              |  4 ++--
 patches/mattpocock/to-spec/SKILL.md.patch          |  2 +-
 patches/pstack/architect/SKILL.md.patch            | 11 +++++++++++
 patches/series                                     |  1 +
 template/.agents/skills/architect/SKILL.md         |  2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  2 +-
 .../.agents/skills/poteto-mode/scripts/overlap.sh  | 14 ++++++-------
 template/.agents/skills/to-spec/SKILL.md           |  2 +-
 template/docs/factory918/DECISIONS.md              |  2 +-
 template/docs/factory918/MANUAL.md                 |  3 ++-
 template/docs/factory918/SCENARIO-TABLE.md         |  4 ++--
 tests/poteto-mode/overlap.sh                       | 23 +++++++++++++++++-----
 tools/build_knowledge.py                           |  2 +-
 17 files changed, 55 insertions(+), 28 deletions(-)
```

## Checks

Run after each of the four commits through one script (`scratchpad/checks.sh`); the list below is the run at HEAD 0c63fa6. Every line passed after every commit.

| Command | Outcome |
|---|---|
| `./factory918.sh sync`, then `git diff --exit-code && test -z "$(git status --porcelain template)"` | PASS. No `FAILED` line; `applied  pstack/architect/SKILL.md.patch` and `applied  pstack/architect/references/runner-prompt.md.patch` both print; `vendored: 72 skills`; tree clean. |
| `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code` | PASS. `knowledge files: 119`. |
| `bash -n factory918.sh` | PASS |
| `bash tests/hooks/delegation.sh` | PASS |
| `bash tests/spec-review/review-comment.sh` | PASS |
| `bash tests/spec-review/review-brief.sh` | PASS |
| `bash tests/poteto-mode/overlap.sh` | PASS, `ok 57 assertions` (56 before this branch). |
| `bash tests/spec-review/no-stale-wording.sh` | PASS |
| Every patch in `patches/series` reproduces byte for byte: `diff -u --label a/<p> --label b/<p> <upstream> template/.agents/skills/<p> \| cmp - patches/<file>` for all 20 entries (pstack upstream `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/`, Pocock upstream `research/1-matt-pocock/skills-repo/skills/<group>/`, `spec-review` from `engineering/code-review`) | PASS, all 20 identical. |
| `diff docs/agents/issue-tracker.md template/docs/agents/issue-tracker.md` | PASS, prints nothing. |
| `shellcheck template/.agents/skills/poteto-mode/scripts/overlap.sh tests/poteto-mode/overlap.sh` | PASS. shellcheck is installed at `/opt/homebrew/bin/shellcheck`; no warnings on either file. |
| Prose scan: added lines of the branch diff and the four commit bodies for the long-dash character and "note that" | 0 hits. |

## What I could not do as written

One thing, in commit 2's test. The brief asked for a `FAKE_BODY` with one real path under `## Testing decisions`, one under `## Design`, "no token elsewhere", and "the same output as check 17". Those two conditions cannot both hold. Check 17's body has `README.md` under `## Notes`, a real token outside the skipped section, so it prints `go: none` and `base: origin/main`. A body with no token outside the skipped sections takes the `paths: none` path (row 7 of the table) and prints `go: none`, `paths: none`, `base: origin/main`. I kept the fixture as specified (no token elsewhere) and asserted the `paths: none` output. That is the stronger proof, since a token leaking from either section would remove the `paths: none` line, and `docs/a.md` under `## Testing decisions` would print `#1 feat-a: docs/a.md` and exit 1. The assertion is named `17 tokens under ## Testing decisions and ## Design ignored`, so the later cases keep their numbers.

## Choices the brief did not settle

- **Where the "skips both sections" sentence sits in Ticket step 6.** The brief said "after the posting clause". The sentence refers to "both sections", and `## Design` is only named one sentence later, so I placed it right after the `## Design` sentence: "...goes under `## Design` the same way. The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change...". Same placement in SCENARIO-TABLE.md "Where it goes", after the `## Design` paragraph's first sentence.
- **Position of the SCENARIO-TABLE.md bullet in MANUAL.md.** After `GLOSSARY.md`, which is the order `CORE_DOCS` in `build_knowledge.py` and the INDEX table use. The sentence now reads "a project carries only the first five".
- **Position of the new patch in `series`.** `pstack/architect/SKILL.md.patch` directly before `pstack/architect/references/runner-prompt.md.patch` (skill before its reference). Sync applies both without a conflict.
- **The to-spec bullet's last sentence.** The brief's wording, "the table is a decision, so...", would have started two consecutive sentences with "The table". I wrote "It is a decision, so the rule above about paths and snippets does not exclude it."; "it" points at the table, the previous sentence's subject.
- **Comment reflow in `overlap.sh` and the test header.** Naming three sections instead of one pushed the header comments past their wrap, so lines 5 to 10 of `overlap.sh` and lines 10 to 15 of the test are rewrapped at the same width. No wording changed beyond the three section names.
- **The stop clause wording in SCENARIO-TABLE.md** is in the third person ("the agent stops and reports the error, and implementation does not start"), since that page is explanation for a person; step 6 has the command form ("stop and report the error; implementation does not start without the artifact on the ticket").

Not touched, per the review's Noted items: `SOURCES.md` line 3 ([S3]) and the repeated writer sentence across the four playbooks ([S4]).
