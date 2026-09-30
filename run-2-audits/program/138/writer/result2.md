# #138 writer result 2: the content check

The reviewer runner now counts a run as contaminated when a tool result in its transcript holds a line that only later commits hold and that the run was not given. It no longer judges the paths a reviewer named. On the 39 labelled #103 runs, the check agrees with every label, and all the verify commands pass.

Branch: `wt/138-writer`. Head: `9887a0ddaffc2363d1a39f76c55a64e3de7dbabc`. The branch was fast-forwarded to 58b0458 first, then got new commits only. Nothing was pushed, no reviewer run was launched, docs/ is untouched, and the pilot runs under W were not touched.

## Commits

- **603aea6, the labels and the test, before the check.** "Label 39 #103 runs by what they read, and test a content check against them."
  - `tests/eval/reviewer/contamination-cases` has 19 cases and 20 clean runs, each with a label and one line of evidence.
  - `tests/eval/reviewer/corpus.sh` failed at this commit (`AttributeError: module 'reviewer' has no attribute 'tree_lines'`).
- **9887a0d, the check.** "Judge contamination by what a run's tools returned, not by the paths it named."
  - The content check, the `given/` copies and `collect --recheck`.
  - The tokenizer is gone: `bash_reaches`, `path_tokens`, `PATTERN`, `SEGMENT_SPLIT`, `COMMAND_WORDS`, `CHECKED_TOOLS` and their tests.
  - The refusals.sh cases now cover the new mechanics.
  - AGENTS.md now counts 28 shell files and lists corpus.sh. CI runs corpus.sh, which skips there.
  - One phrase in this commit message is wrong. It says the old tokenizer "missed nothing it could not parse". It did miss one: it scored claude-sonnet/pr96-r3/spec/1 complete. I left the message as it is, because the brief says new commits only.

## Rule 1: what the reviewers are told

Nothing tells a reviewer what it may not read or run.
- The runner prompt says only: "Read `<brief>` whole and follow it. You are working in `<checkout>`; every relative path in the brief is relative to it."
- The three `agents/*.md` bodies say only: "You are a lane launched by a parent session. Do exactly the task in your prompt."
- The settled section's paragraph says "Do not raise them again". That limits what the reviewer reports, not what it reads or runs.
- The brief's first line, from e710e99's script, says: "You may open any file in the repository and run read-only commands, such as grep or the test suite."
  - It names what the reviewer can use.
  - "read-only" can be read as a limit on what it runs. The script's wording is outside this brief's scope, so I report it and leave it.
- Each run's copy of the code at its reviewed commit is unchanged.

## The check

- **Lines of the future.** Lines added by every commit that the keep refs (`refs/keep/103/*`) and `origin/main` reach, that the head does not reach, and that was committed after the head. Each line records the first commit that added it.
  - **Deviation.** The brief said: tips that descend from the head, via `git diff <head> <tip>`.
    - PRs #96, #99 and #101 were rebased onto main after review. Their later code sits on main and does not descend from the reviewed heads.
    - With descent only, pr96-r2, pr96-r3, pr99-r2 and pr101-r1 have no future at all. Five of the ten future cases would be missed: all four pr101-r1 runs and the pr96-r3 Sonnet run the audit names.
    - I use every commit's added lines, not only the lines that survive to the tip. That also covers intermediate states that a worktree held when it was read.
- **What the run was given.** Subtracted from the future lines:
  - every line of its tree (the head, or the folded masked commit, taken from the export itself);
  - its brief, with any settled lines;
  - its diff.
  Each run now keeps its brief and diff under `<run dir>/given/`, so a recheck judges it against exactly what it got. A run prepared before this change is rebuilt from the fixtures, and a masked one through rebuild.sh.
- **The scan.**
  - Every `tool_result` block is read line by line, text and nested text alike.
  - Each line is compared as returned and with the tool prefixes stripped: Read's `12→` and `12<tab>`, `cat -n`, grep's `12:` and `12-`, and grep's `path:12:` and `path-12-`.
  - A line that any of its forms shows was given is not a hit.
- **Tools judged by name.** Agent (and its earlier name, Task), WebFetch and WebSearch still count as contamination by name. Every other tool, Bash and Skill included, goes through the content check alone.
- **The receipt detail.** It names up to three hits, each with the tool call (name and input), the commit that first added the line, and the line.
- **Caching.** Under `<out>/cache/`, as `future-<head>-<hash of the commits read>.json` and `tree-<commit>.json`. Deleting the directory rebuilds it.

## Floor and threshold, from the corpus

Over all 233 Claude runs of #103 with a transcript:

| Floor (characters) | Future runs caught | Other runs flagged |
|---|---|---|
| 1 to 56 | 10 of 10 | 0 of 223 |
| 60, 64, 80 | 9 of 10 | 0 of 223 |

The one lost at 60 is claude-sonnet/pr102-r1/spec/2. Its single future line is 57 characters.

- **FLOOR = 12.** It keeps a wide margin under that 57-character line. It also leaves out short tool output that no corpus run happened to hit: an exit code, a count, a shell keyword.
- **Threshold: one hit.** The same run has exactly one hit, so no count threshold is possible.
- **Generic lines are dropped**: lines with no letter or digit, fence markers, and one-word Markdown headings.

The reason is in the FLOOR comment in reviewer.py.

## The gh decision

There is no separate gh rule.
- In the corpus, one run called gh: claude-opus-5/pr99-r1b/standards/3, with `gh issue view 90 -R Zenoctra/factory918`.
- The content check catches it with 66 hits. The ticket's amended criteria and tables are held by later commits (the #103 ticket inputs), and its Standards brief carried none of them.
- The exports have no `.git`, so a bare `gh pr view` fails there.
- The risk is on the act-on list: a gh call returning text no commit ever holds, such as PR comments, would not be caught.

## Per-case corpus table

`bash tests/eval/reviewer/corpus.sh` reports 39 of 39 cases match their label. The first hit is the line, then the commit that added it and the tool.

| Case | Label | Verdict | First hit |
|---|---|---|---|
| claude-opus-5/pr99-r1b/standards/3 | future | future | "Observed (agent): on PR #87 the core of the new script was r…" [35de22e Bash, gh issue view 90] |
| claude-sonnet/pr101-r1/standards/2 | future | future | "# in place of the one it rebuilt. From it: the `would-break…" [27c43af Bash] |
| claude-sonnet/pr101-r1/standards/4 | future | future | "# same round does not advance it, and a fourth round is refu…" [27c43af Bash] |
| claude-sonnet/pr101-r1/standards/5 | future | future | "# review-comment.sh wrote (the last such line outside fenced…" [27c43af Bash] |
| claude-sonnet/pr101-r1/standards/6 | future | future | "# The round is one more than the highest `round: N of 3`…" [27c43af Read] |
| claude-sonnet/pr102-r1/spec/2 | future | future | "j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]+$/" [fc75ac6 Bash] |
| claude-sonnet/pr96-r1/standards/1 | future | future | "echo "shellcheck.sh: no file matched $g; the gate checked no…" [01e5386 Bash] |
| claude-sonnet/pr96-r2/standards/2 | future | future | "# version over the files the globs name. When this machine d…" [a64c7e6 Bash] |
| claude-sonnet/pr96-r3/spec/1 | future | future | "# the release tarball once, verifies its sha256 on every run…" [070c1fa Bash] |
| claude-sonnet/pr99-r1/standards/1 | future | future | "if [ -n "$deciding" ] && ! printf '%s\n' "$deciding" \| awk…" [27c43af Bash] |
| claude-opus-5/pr102-r1/standards/2 | clean | clean | - |
| claude-opus-5/pr102-r1/standards/4 | clean | clean | - |
| claude-sonnet/pr102-r2/standards/1 | clean | clean | - |
| claude-sonnet/pr102-r2/standards/4 | clean | clean | - |
| claude-sonnet/pr94-r1/spec/2 | clean | clean | - |
| claude-sonnet/pr94-r1/standards/2 | clean | clean | - |
| claude-sonnet/pr96-r2/spec/3 | clean | clean | - |
| claude-sonnet/pr96-r2/spec/4 | clean | clean | - |
| claude-sonnet/pr99-r1/spec/1 | clean | clean | - |
| claude-opus-5/pr102-r1/standards/5 | clean | clean | - |
| claude-opus-5/pr102-r2/standards/2 | clean | clean | - |
| claude-opus-5/pr99-r2/standards/1 | clean | clean | - |
| claude-opus-5/pr99-r1b/standards/4 | clean | clean | - |
| claude-opus-5/pr94-r1/spec/1 | clean | clean | - |
| claude-opus-5/pr96-r3/spec/1 | clean | clean | - |
| claude-opus-5/pr101-r1/standards/1 | clean | clean | - |
| claude-opus-5/pr96-r1/spec/2 | clean | clean | - |
| claude-opus-5.5/pr94-r1/standards/2 | clean | clean | - |
| claude-opus-5.5/pr101-r1/standards/2 | clean | clean | - |
| claude-opus-5.5/pr99-r2/spec/3 | clean | clean | - |
| claude-opus-5.5/pr96-r3/spec/2 | clean | clean | - |
| claude-opus-5.5/pr102-r1/spec/1 | clean | clean | - |
| claude-opus-5.5/pr96-r2/standards/2 | clean | clean | - |
| claude-sonnet/pr99-r2/standards/2 | clean | clean | - |
| claude-sonnet/pr99-r1/standards/3 | clean | clean | - |
| claude-sonnet/pr94-r1/spec/3 | clean | clean | - |
| claude-sonnet/pr101-r1/spec/1 | clean | clean | - |
| claude-sonnet/pr96-r1/spec/2 | clean | clean | - |
| claude-sonnet/pr99-r1b/spec/2 | clean | clean | - |

### How the labels were made

- For each run, a reading aid listed every tool call that reached outside the export. For each such call it showed the result lines the run was not given, and which of those lines later commits hold.
- It compares at a floor of 1 and ignores length, so it is not the check itself.
- I read those results and wrote the verdict and evidence by hand.
- Of the 18 runs the old rule flagged, 9 read later code and 9 are clean:
  - two read only their own overflow files;
  - three ran probes in /tmp or on echoed strings;
  - four read worktree files whose returned lines are identical at their head.
- The 19th case, claude-sonnet/pr96-r3/spec/1, was scored complete in #103. It read the later shellcheck.sh.

## Verify

- `python3 tests/eval/reviewer/reviewer.py check`: exit 0. 33 masked subsets apply and brief.
- `bash tests/eval/reviewer/refusals.sh`: all 214 checks passed. New cases cover:
  - a future line caught through each tool prefix;
  - a later line under the floor, one the head already holds, one the brief carries, and part of a future line, none of them a hit;
  - the masked tree: a fix line given to M2 is clean, and the same line in I2 is contaminated;
  - Agent, WebFetch and WebSearch contaminated by name, while Skill, ToolSearch, TodoWrite, Read and Grep are judged by content;
  - give-up by content;
  - recheck: complete turning contaminated, an old-rule contamination coming back complete, a second pass changing nothing, a set-aside run restored to its free place, and one without its report staying aside.
- `bash tests/eval/reviewer/corpus.sh`: 39 of 39 cases match. It takes about 30 seconds without a warm cache.
- `REVIEWER_CORPUS=/nonexistent bash tests/eval/reviewer/corpus.sh`: prints `skip: no #103 corpus at /nonexistent` and exits 0.
- `bash tests/eval/reviewer/rebuild.sh` for pr94-r1, pr96-r1 and pr99-r1: identical, all three.
- `bash tests/eval/reviewer/fixes.sh`: 10 identical.
- `next claude:opus-5 --limit 8` with a temporary REVIEWER_OUT: 6 lines and 6 exports, each run dir holding `given/` with its brief and diff. I removed them afterwards.
- ShellCheck with the AGENTS.md line: exit 0 over 28 files (corpus.sh is the new one).
- deslop: I read the diff by hand. No narrating comments. The comments that remain say why: the floor and its corpus numbers, the tool prefixes, why some tools are judged by name, and why the future is not limited to descent.

## Act on

1. **gh output no commit holds.** Text a reviewer fetches with gh that no commit ever holds (PR comments, review judgments) is not caught. In the corpus, the one gh call returned a ticket whose text later commits hold, so it was caught. If you want gh caught by name, it needs a command-word parse again, which this brief removed.
2. **The committed-after-the-head filter.** It relies on commit timestamps. A commit made earlier than the head, on a branch that merged after it, counts as not future. The fixture needed its commits spaced an hour apart for the same reason.
3. **Masked tree cache.** For a masked run, the tree cache is built from the whole export, so it also holds the review files. When a pre-given/ masked run is rebuilt through rebuild.sh, both axes' briefs count as given. The effect is at most a few brief lines treated as given.
4. **The pilot runs under W.** They have no `given/`. A recheck rebuilds their brief from the fixtures. That is exact for pass 1 and the I and S arms, and goes through rebuild.sh for a masked one.
5. **Docs.** P138 and the M0 lines still describe the path rule. They are yours to update.
6. **`read-only`.** The brief's first line says the reviewer may "run read-only commands". If that counts as a limit under rule 1, the fix is in review-brief.sh's wording, outside this brief.

## Addendum: live GitHub text, records, and the first #138 case (2026-09-24)

Live GitHub text now counts as future text, and receipts record where a run first saw what it should not have. The addendum's test case comes out contaminated, but at tool call 14, not 32: the root's numbers do not match the 1-based count of tool calls it specified.

Head: `70ba03d40656c011c860039f2ee0aede7acec760`, one new commit on 9887a0d: "Count live GitHub text as future text and record where a run first saw it". It closes act-on item 1 above.

- **Live GitHub text.** For the round's ticket and PR (the `ticket` and `pr` keys of `round` and `inputs/recipe`), the check runs `gh issue view <ticket> --repo Zenoctra/factory918 --json body,comments` and the same for `gh pr view <pr>`.
  - It runs each once and caches the result at `<out>/cache/github-<ticket>-<pr>.json`.
  - Every dated line of those bodies and comments that the frozen `inputs/` (ticket.md, previous.txt, blast-radius.md) do not hold joins the future set, labelled `live #N` or `live PR #N`. The given set is subtracted afterwards, as for code.
  - With no cache and no network, the check refuses and names the failed command. With the cache, it runs offline.
  - I added `--repo` to both commands, so the fetch does not depend on the working directory.
- **The records.** None of them changes a verdict.
  - **`first_contaminated`**: `{call, timestamp}` of the first contaminated tool result. `call` is the 1-based ordinal among the transcript's tool_use blocks, and the timestamp is the time of the line that carries the result. An Agent, WebFetch or WebSearch call counts at its own ordinal.
  - **`sightings`**: for each report item, `{n, hard, call}`, where `call` is the earliest tool call whose single result already held every dated line the item quotes in a fence, or null.
  - **`outside`**: `"<call> <tool> <path>"` for a Read, Edit or Write path, a Grep or Glob path, or a Bash `cd` target or absolute argument outside the export.
- **The table.** Each model's table says "Contaminated runs excluded from recall: N.", counting its current and set-aside contaminated receipts.
- **The test case: agent-a7282a4eeee51f4d4.jsonl, first contaminated at call 14.**
  - By the definition given (1-based count of tool_use blocks), `gh issue view 88` from its export is call 13. It failed with "not a git repository".
  - The same command after `cd` into the owner's worktree is call 14. It returned live #88.
  - Those are JSONL lines 66 and 69. The run has 29 tool calls in all, so the "32 and 33" in the addendum cannot be tool-call ordinals.
  - The check's first hit is at call 14. The line matched ("Observed (agent): three of the ten hard findings…") is the #88 body. It is also in later commits (the #103 ticket inputs, 35de22e), so it is dated to that commit.
  - The run's gate runs at calls 8 to 11 come before call 14. It ran the gate again at calls 15, 23 and 24, after it had seen the ticket, so "calls 8 to 22 come before it" does not hold. The test pins call 14. If a different ordinal was meant, tell me the rule and I will re-pin.
- **The corpus.**
  - contamination-cases gains a `call` column: the expected first contaminated call, or `-` where it is not pinned. It also gains the #138 case as `138 pr96-r1/standards <transcript under ~/.claude/projects>`, briefed from this tree's rounds.
  - corpus.sh: 40 of 40 cases match. Its cache defaults to `<main>/.scratch/eval/reviewer-corpus-cache`, which now holds the five rounds' live GitHub text.
  - With that text added, no #103 label changed.

Verify, at 70ba03d:
- `bash tests/eval/reviewer/refusals.sh`: all 231 checks passed. New cases cover live ticket, comment and PR lines, a frozen ticket line (clean), offline with a cache, offline without one (refusal), the first-call ordinal and time, sightings with and without a quote, cd and Read outside records, and the excluded count.
- `bash tests/eval/reviewer/corpus.sh`: 40 of 40.
- `python3 tests/eval/reviewer/reviewer.py check`: exit 0.
- `rebuild.sh` for all three rounds: identical.
- `fixes.sh`: 10 identical.
- `next` dry run: 6 lines.
- ShellCheck: exit 0 over 28 files.

Act on:
1. **Confirm the ordinal.** The pin is call 14, as explained above.
2. **Seven more transcripts.** When the root names them, each gets a label and a pinned call in contamination-cases.
3. **The GitHub cache is a snapshot.** A comment posted on the ticket or PR after the first fetch is not seen until the cache file is deleted and fetched again.
