# Fix lane report, PR #94 (ticket #89), round 2

Worktree: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a6171949172dd6b2a

Branch: wt/89-fix2, branched from feat/design-artifact-on-ticket (78be65e).
HEAD: 715100c12a8eef8d9f2eb547769404c1f9ce7ab1

## git log --oneline feat/design-artifact-on-ticket..HEAD

715100c Keep the whole design artifact inside its one ticket section

## git diff --stat feat/design-artifact-on-ticket..HEAD

 docs/agents/issue-tracker.md                           |  2 +-
 docs/knowledge/core/SCENARIO-TABLE.md                  |  4 ++--
 .../.agents/skills/poteto-mode/playbooks/ticket.md     |  2 +-
 template/.agents/skills/poteto-mode/scripts/overlap.sh | 11 ++++++-----
 template/docs/agents/issue-tracker.md                  |  2 +-
 template/docs/factory918/SCENARIO-TABLE.md             |  4 ++--
 tests/poteto-mode/overlap.sh                           | 18 +++++++++++-------
 7 files changed, 24 insertions(+), 19 deletions(-)

docs/knowledge/INDEX.md did not change: the edits stayed inside existing lines, so the header line counts held.

## Edits, as the brief listed them

1. ticket.md step 6: one sentence added after "The step-1 check skips both sections...": the whole artifact (legend, table, contract and test list, or usage and signatures) stays inside the one section, parts under `###`, because the skip ends at the next `## ` heading. Every other sentence kept.
2. template/docs/agents/issue-tracker.md, the #89 paragraph: one sentence added, each section holds the whole artifact with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading. Copied to docs/agents/issue-tracker.md.
3. SCENARIO-TABLE.md "Where it goes": the same rule, one sentence. "The #42 example": #42's record predates the rule, so its table and contract sit under their own `## ` headings there; a table posted from now on keeps them under `###` inside the one section. Rebuilt; template/docs/factory918/SCENARIO-TABLE.md committed.
4. tests/poteto-mode/overlap.sh: the #89 check 17 fixture gains `### Contract` / "Reads `src/x/y.txt` once." after the table rows, before `## Design`. Check renamed to "17 tokens under ## Testing decisions (with ### parts) and ## Design ignored". Expected output unchanged. Header comment says the `###` parts are covered. overlap.sh header comment now says the skip runs "up to the next `## ` heading". The awk line is untouched.
5. shellcheck clean on both scripts.

## Checks and outcomes (all at HEAD 715100c)

- `./factory918.sh sync`: exit 0, 0 lines matching FAILED (run twice, second run's log grepped). Then `git diff --exit-code`: clean; `git status --porcelain template`: empty.
- `python3 tools/check_knowledge.py`: knowledge ok, 119 files. `python3 tools/build_knowledge.py` then `git diff --exit-code`: clean.
- `bash -n factory918.sh`: ok.
- `bash tests/hooks/delegation.sh`: ok 55 assertions.
- `bash tests/spec-review/review-comment.sh`: ok 82 assertions.
- `bash tests/spec-review/review-brief.sh`: ok 334 assertions.
- `bash tests/poteto-mode/overlap.sh`: ok 57 assertions.
- `bash tests/spec-review/no-stale-wording.sh`: ok, no stale wording.
- `diff docs/agents/issue-tracker.md template/docs/agents/issue-tracker.md`: prints nothing.
- `/opt/homebrew/bin/shellcheck template/.agents/skills/poteto-mode/scripts/overlap.sh tests/poteto-mode/overlap.sh`: clean.

## Bite proof

Before the commit, with the edited fixture in place, the awk regex on the skip line was changed with sed from `(Diff|Testing decisions|Design)` to `(Diff)`. `bash tests/poteto-mode/overlap.sh` then exited 1 at:

    FAIL 17 tokens under ## Testing decisions (with ### parts) and ## Design ignored
      got:    exit 1: go: none
    #1 feat-a: docs/a.md
    #2 feat-b: src/x/y.txt src/z.txt
    #4 feat-b2: src/z.txt
      wanted: exit 0: go: none
    paths: none
    base: origin/main

`src/x/y.txt` in the #2 line is the `### Contract` path leaking. The saved copy of the script was restored with cp; `grep -n 'skip=('` showed the original regex at line 49 and `git diff` on the script showed only the header comment change. The test then passed with 57 assertions.

## Not done as written

Nothing skipped. Two small departures:

- The brief asked for "one sentence" in "The #42 example". The `technical-writing` skill bans semicolons, so the sentence is two: "#42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section."
- The brief's example path for the fixture, `.claude/state/program`, is not a path any fake PR in the fixture touches, and the brief said to pick one that is. I used `src/x/y.txt` (feat-b, PR #2), which is distinct from the `docs/a.md` already in the table row, so the leak shows as its own PR line.

## Choices the brief did not settle

- The header comment paragraphs in overlap.sh and the test were rewrapped after the inserted words pushed lines past the block's width. The rewrap moved line breaks in five lines of each comment block; no words changed beyond the inserted ones. This is why the script's diff stat shows 11 lines rather than 2.
- The `### Contract` body line in the fixture reads "Reads `src/x/y.txt` once.", a prose line rather than a bare token, to look like a real contract sentence.
