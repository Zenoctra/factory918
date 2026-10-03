# Ground truth for pr94-r1, pr96-r1 and pr99-r1 (#138)

`truth` has 14 bugs: 6 at pr94-r1, 4 at pr96-r1 and 4 at pr99-r1. Nine are hard and five are non-hard; "Classes" says why. Each bug below was read in the code at the head (`git show <head>:<file>`, extracted with `git archive` to a scratch copy). Each fix was applied with `patch -p1` to a copy of the head's files (`apply.log`, at the end). The anchors match every item credited to their bug and no item credited to another bug of the same head (`validate.out`, 0 failures). The only items that match two bugs are ones that describe both.

The fix column of `truth` names patches under `rounds/<round>/fixes/`. The `fixes` file and `fixes.sh` build each one from the commits this page names, limited to the files that hold the bug. The masked arm applies them with `git apply --3way`.

Conventions:
- "hist" is `tests/eval/reviewer/rounds/<round>/review/<axis>-report.historical.md` as it stands at e710e99 (`git show e710e99:<path>`).
- "label <brief> <id>" is a row of `tests/eval/reviewer/labels` at e710e99.
- "run" is `.scratch/eval/reviewer/runs/<model>/<brief>/<axis>/<k>/report.md`, the #103 runs in the main checkout. They are not committed.
- U-numbers are the #103 audit's unlabeled hard items.
- `#n` is the report's item number as `reviewer.parse_report` reads it.

## Fix column rule

The fix column names only commits whose change removes the bug. It lists them in the order they must be applied. A commit that is only a textual prerequisite for a later hunk is not listed. Those prerequisites are named here:

- **pr94-r1 G2.** 3f5033f's `ticket.md` hunk rewrites the line b368116 wrote, so a whole-commit apply needs b368116 first. Its `overlap.sh` hunk applies to c83f166 alone. 715100c needs b368116 and 3f5033f under it.
- **pr96-r1 G2 and G3.** The `template/.github/shellcheck.sh` hunks of 72953c0 and a64c7e6 apply to 69bd412 alone. Their `tests/shellcheck/gate.sh` hunks do not. A whole-commit apply needs 01e5386, then 72953c0, then a64c7e6.
- **pr96-r1 G4.** ae1b4b5 is a 30-file commit. Only its `opening-a-pr.md` hunk and that file's patch hunk apply to 69bd412; the rest depends on main after the rebase. 69bd412 is not an ancestor of ae1b4b5, because #96 was rebased onto main as d4331d8 and others. Apply that file's hunk only.
- **pr99-r1 G1 and G2.** 0ff73f0 on main is the rebased 384bb43. This file uses the chain shas.

## Classes

2026-09-24: Manuel approved re-classing the key after the answer-key audit (`.scratch/program/answer-key-audit/report.md` in the main checkout, written by Opus 5.5 for the #138 owner). His words: "go ahead and fix the answer key".

The class column follows the definition `review-brief.sh` gives the reviewer. A bug is hard when the documented path gives a wrong or silent result, or when an input outside the path proceeds silently. A refusal that says how to correct itself is not a finding. An unsupported edge case is not a flag.

Non-hard:
- **pr94-r1 G3.** Conflicting prose. `architect/SKILL.md` says usage first, but the runner prompt a runner works from asks for the table first, and Ticket step 6 posts it. No documented path gives a wrong result.
- **pr94-r1 G4.** A stale count in a reading list. `/knowledge` still reaches the page, so criterion 6 holds. The repository's own rule on counts in prose makes it a Standards breach.
- **pr94-r1 G5.** Designed behaviour: the loud refusal. A failed `gh issue edit` prints gh's own error and exits nonzero, which is what #89 asks of an input outside the path ("refused with the tool's own message"). It never earns hard credit; a hard filing of it counts as over-rating. The other reading is that the playbook goes on without its artifact, which fails open at the level of the process. I do not take it, because nothing in it is silent to the agent. No #138 report names this bug. Its one credit was an anchor mis-match ("Anchor edits").
- **pr94-r1 G6.** A gap between #89's intent and the playbooks' trigger. Step 6's own trigger is a design that adds state, and a fix inside one function rarely adds any. No commit ever fixed it.
- **pr96-r1 G3.** An unsupported edge case. The cache file exists only after a tarball whose checksum passed. The gate already trusts any `shellcheck` on PATH that reports the pin, so trusting the cache matches the design's trust. An interrupted `tar` fails loudly.

Hard, with both readings of the three close calls:
- **pr94-r1 G2.** Hard reading: a re-run of step 1 after the table is posted matches unrelated PRs, exits 1, and tells the reply to merge or stack them. That is a wrong result with a wrong remedy, and the definition says "wrong or silent". Non-hard reading, taken by Opus 5.5 and Fable 5.1 in #138: it is loud, it costs one human turn, and it happens only on a relaunch or a pickup, so by Manuel's "fail fast and loud" it is the mildest kind of failure. It stays hard by the letter of the definition.
- **pr96-r1 G4.** Hard reading: taken literally, the playbook's command is the bare gate. In the factory that form lints only the hooks and the gate, so a changed `factory918.sh` or test script passes the lane check unread and silently, which defeats #88 criterion 3. Non-hard reading: "on every shell file" implies passing the files, the design's usage line shows the file form, CI is a loud backstop, and in a project the bare set equals CI's. It stays hard because the lane check is the step the criterion names, and it is silent there.
- **pr99-r1 G1.** Hard reading: a Noted or Dismissed reason that says "hole:" is valid under the documented contract. It is refused with a message that names the wrong cause, so the refusal does not say how to correct itself. Non-hard reading, taken by Opus 5.5 and Fable 5.1 in #138: it is loud and costs one retry. It stays hard because the message misleads; 53ca502 fixed exactly that message.

The masked arm follows the filing, not the class. A pass-2 or pass-3 tree gets a bug's fix when an earlier pass filed that bug hard, whatever its class. The arm stands for an author who fixes what the review said to act on: a non-hard bug filed hard is fixed, and a hard bug filed non-hard is not. The M2 and M3 runs collected before this change were prepared on the same rule, so they stay valid.

## Anchor edits

2026-09-24. The audit found four report items credited to the wrong bug. `refusals.sh` now scores each one from its text, copied word for word from the #138 report:
- **opus-5 pr94-r1/spec/1#4** is a skipped architect step (G6). It matched G5 through "the failure this ticket opens with". G5's first anchor was `fail|error`. It now needs a failure of the post itself: "a failed post", "gh issue edit failing", a nonzero exit, auth or network.
- **opus-5 pr96-r1/standards/1#1** is the bare gate at the factory root (G4), and it also describes G1's mechanism. G1 and G4 tied at three anchors, and the tie went to G1 by label order. G4 now has a fourth anchor, the files the bare gate leaves unread, so the narrower bug claims it. G4's second anchor no longer accepts a bare "default", which had matched "the default IFS" in Opus 5.5's word-split items (G2).
- **opus-5 pr99-r1/standards/1#1** is a Standards brief that carries no ticket (G4). It matched G2 through "carries no ticket". G2's first anchor now needs a review or run with no ticket ("a review with no ticket", "without a ticket", "ticketless"), not a brief that carries none.
- **fable-5.1 pr94-r1/standards/1#3** is about step order and names no bug of the key. It matched G1 because "close" contains "lose". G1's second anchor now takes `lost`, `lose`, `loses` and `losing` only as whole words.

Over every report on the three rounds, meaning the six historical reports, the #103 runs and the #138 runs as they stood on 2026-09-24, these edits changed the matches of eight items and the claim of one more, opus-5 pr96-r1/standards/1#1. Every change agrees with the audit, and no labelled source lost its match. Three of the eight are named above; the other five:
- opus-5 pr94-r1/spec/1#2 (overlap, G2) no longer also matches G1.
- opus-5 pr94-r1/standards/1#3 (step order) no longer matches G1.
- opus-5.5 pr94-r1/spec/I3#1 (a skipped architect step) no longer matches G1.
- opus-5.5 pr96-r1/standards/1#1 and its set-aside second attempt (the word split, G2) no longer match G4.

The claim rule changed with them. Every item, hard or not, claims at most one bug. The bug with more anchors claims first, and a hard item claims before a non-hard one. A bug is filed hard when a hard item claims it, and found when any item does. Before, a non-hard item counted toward every bug it matched ("demoted").

## pr94-r1 (head c83f166, ticket #89)

**G1: `--body-file` replaces the body.**
- Present: `ticket.md:10 @ c83f166` says "the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`". It has no read of the current body. `SCENARIO-TABLE.md:43 @ c83f166` says the same thing.
- Fix: b368116. Step 6 now reads the body with `gh issue view N --json body -q .body`, adds the section, and writes the whole file back "since that command replaces the body and never merges". It applies to c83f166 alone.
- Not this bug: U07, the unguarded read. b368116 creates it, so it was born after the head.

**G2: posted table tokens become pathspecs.**
- Present: `overlap.sh:48 @ c83f166` is `awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip'`. Only `## Diff` is skipped, and step 6 appends a table of backticked paths to the body.
- Fix, part 1: 3f5033f skips `## (Diff|Testing decisions|Design)`. That removes the bug for a table posted inside one section.
- Fix, part 2: 715100c. The verifier (`verify/94-78be65e/worker-audit.md`, Issues 2) showed a residual: the skip ends at the next `## `, so a table posted with its parts under sibling `## ` headings, as #42's was, still leaks paths. 715100c requires the whole artifact to stay in one section with `###` parts, and the test proves a `###` part stays skipped.
- The audit calls the residual fix-born at 0c63fa6. At c83f166 the same leak already existed, so it is one bug that was fixed in two steps.

**G3: the architect skill still says usage first.**
- Present: `architect/SKILL.md:32 @ c83f166` says the package is "the caller's usage written first, then the type sketch, function signatures, module map", and `:84` Outputs says the same. The runner prompt tells each runner to "Read the architect skill in full first".
- Fix: 0c63fa6 adds to Phase B: "For a design with state the package opens with the scenario table, its contract and its test list". It applies alone.
- Outputs (`:84`) is unchanged at 0c63fa6. Rounds 2 and 3 accepted the Phase B sentence, and so do I.

**G4: four project documents.**
- Present: `docs/knowledge/core/MANUAL.md:165 @ c83f166` says "a project carries only the first four" and lists four. `tools/build_knowledge.py:8 @ c83f166` says the script "copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY". `build_core` now copies SCENARIO-TABLE.md as well.
- Fix: ca2c106 says five, adds the manual bullet and rewrites the docstring. It applies alone.
- A stale count in a map a person reads. It was the weakest hard bug until 2026-09-24 and is non-hard now ("Classes"). Some runs filed it under Standards breaches.

**G5: a failed post does not stop the work.**
- Present: `ticket.md:10 @ c83f166` has no clause for `gh issue edit` failing, while step 8 has "Exit 2: stop and report stderr".
- Fix: b368116 adds "If the write fails, stop and report the error; implementation does not start without the artifact on the ticket."

**G6: stateful work inside one function skips architect and the table.**
- Present: the three playbooks run architect only on these terms:
  - `bug-fix.md:9 @ c83f166`: "If it crosses a function boundary, `architect` first".
  - `perf-issue.md:16 @ c83f166`: the same words.
  - `feature.md:6 @ c83f166`: "Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff".
- Ticket step 6 makes the table "`architect`'s first deliverable" only through the playbook's architect step. Ticket #89 says "For anything with state, the scenario table". A state-file fix inside one function therefore reaches implementation with no table.
- Fix: none. At HEAD (e710e99), `bug-fix.md:9` and `perf-issue.md:16` still read "If it crosses a function boundary, `architect` first". `git log c83f166..HEAD -- bug-fix.md` shows no change to that trigger.

## pr96-r1 (head 69bd412, ticket #88)

**G1: one unmatched glob is dropped.**
- Present: `shellcheck.sh:37-43 @ 69bd412` builds one `files` array from every argument, and `:40` refuses only when `${#files[@]}` is 0.
- Fix: 01e5386 sets `matched=0` per argument and exits 1 on the first argument that matches nothing. It applies alone.

**G2: an argument with a space is word-split.**
- Present: `shellcheck.sh:38 @ 69bd412` is `for f in $g; do if [ -f "$f" ]`. `$g` is unquoted, so it is split on IFS before globbing, each fragment fails `-f`, and it is dropped. At 69bd412 the drop is silent when another file matches. After 01e5386 it becomes a false refusal, which is how pr96-r2 found it.
- Fix: 72953c0 adds `IFS=` above the loop.
- Round 1 named this only in passing, inside the glob item (hist pr96-r1/standards#1: "a path with a space, which splits on the unquoted `$g`").

**G3: a cached binary runs unchecked.**
- Present: `shellcheck.sh:26 @ 69bd412` is `if [ ! -x "$bin" ]; then`. Everything in that block, including the download, the sha256 check and the extraction, is skipped once the cache path is executable, and PATH's binary is the only one version-tested (`:18`).
- Fix: a64c7e6 removes the `-x` guard, checks the tarball sha on every run and re-extracts. It is the shellcheck.sh hunk that applies alone.
- Not this bug: U14 (a failed check wedges the tarball) is born in a64c7e6's `[ -f "$tarball" ] || curl`.

**G4: the playbook's bare gate is not scoped to the diff.**
- Present: `opening-a-pr.md:9 @ 69bd412` says "Run `bash .github/shellcheck.sh` on every shell file the diff changes". With no arguments, `shellcheck.sh:35` lints only `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`. A lane that changes `factory918.sh` or `tests/*/*.sh` passes the lane check, and only CI catches the file later.
- Fix: ae1b4b5 rewrites the line to "Run `bash .github/shellcheck.sh <file> ...` ... the bare form lints only its default globs".
- This is the least severe of the four: CI still lints the factory's five globs. It fails open at the lane step the playbook documents.

## pr99-r1 (head 52ccd8e, ticket #90)

**G1: "hole:" in a reason is read as a field.**
- Present: `review-comment.sh:158 @ 52ccd8e` is `holed() { items ... | grep -vE "$ending" | grep 'hole:' || true; }`. The refusals at `:161` and `:164` name a field the item does not carry.
- Fix: 53ca502 and 32978fa. The round-1 judgment marked this a design hole (`hole: table 1/A`), and architect amended the ticket's table (096954b, tests only). The fix redefines the field rather than the detection:
  - 53ca502 keeps `holed()`, prints the value, and says "reword a reason that says 'hole:'".
  - 32978fa's SKILL.md step 5 says "The text from the last `hole:` on an Act on line is the field, so a reason does not write `hole:`".
- After both, the behavior is the documented contract with a corrective message. Detection is still a substring match (`review-comment.sh:176` at HEAD). Pass 2 of a masked chain at 52ccd8e+53ca502+32978fa can still name the detection as a design choice; opus-5 pr99-r1b/standards/3#3 did, as a note.
- Side effect: 53ca502 adds `value()`, which carries the pr99-r1b S4 missing-space bug.

**G2: a review with no ticket cannot finish.**
- Present: `review-brief.sh:360 @ 52ccd8e` echoes `$spec_rule` into `standards-brief.md` with no `[ -n "$spec" ]` guard. `review-comment.sh:114 @ 52ccd8e` refuses any counted Standards item without `spec: $ref`, where every form of `$ref` names a ticket artifact.
- Fix: 53ca502 wraps the Standards echo in `if [ -n "$spec" ]` (patched copy, `review-brief.sh:362-365`) and returns early in `report()` without `has_spec`. 32978fa aligns SKILL.md steps 4 and 6. Both apply to 52ccd8e in that order.

**G3: the MANUAL merge read takes the count alone.**
- Present: `docs/knowledge/core/MANUAL.md:103 @ 52ccd8e`: "It is ready when: ... `spec-review`'s last line on the latest commit reads `act-on items: 0`". It has no restart clause, and `review-comment.sh:206-208` prints `restart` above `act-on items: 0`.
- Fix: 384bb43 adds "and that comment carries no `restart` line". It applies alone.

**G4: the Standards brief demands `spec:` but carries no ticket.**
- Present: `review-brief.sh:327-364 @ 52ccd8e` builds `standards-brief.md` with `$spec_rule` (`:360`). `## The ticket` is written only into `spec-brief.md` (`:370`), and the Standards brief says "Read nothing beyond this brief". With a ticket, the Standards reviewer must name a cell, signature or criterion it was never shown. `review-comment.sh` checks only the form, so a guessed reference passes and later feeds the `hole:` equality check.
- Fix: none. 53ca502 removes only the no-ticket case, which is G2. At HEAD, `review-brief.sh:606` still echoes `$spec_rule` into the Standards brief, and `## The ticket` (`:617`) is still Spec-only.
- The audit dates it `review-brief.sh:363 @ 32978fa`. The same code is at 52ccd8e, without the guard.

## Candidates excluded

Born after the head:
- **U07** (unguarded body read): born b368116.
- **U09 and U22:** born 715100c.
- **The skip that ends at the next `## `** (verifier 94 Issues 2): an old leak, counted under pr94-r1 G2.
- **Case-sensitive `## Testing Decisions`** (verifier 94 Notes 1; pr94-r2 Fix alongside 1): born 3f5033f.
- **U13 and U28** (the zero-argument gate refuses in the factory): born 01e5386. At 69bd412 the empty-set test passes because `.claude/hooks/*.sh` matches.
- **U14** (a checksum failure wedges the tarball): born a64c7e6.
- **Concurrent gate runs on one TMPDIR** (verifier 96 Notes 2): born 2360707.
- **pr99-r1b S4** (`hole:table` prints a value that looks valid) and **U18:** `value()` is born in 53ca502.
- **U03, U19, U20 and U21:** #102 code. `would-break fixed` does not occur in either script at 52ccd8e.

Real but minor:
- **pr94-r1 Standards 2** (the to-spec exemption covers half the rule): two instructions disagree, and no path breaks. 0c63fa6 fixes it.
- **pr94-r1 Standards 3** (SOURCES.md line 3 stale), **P25 counts four patches, not five** (opus-5.5 standards/2#1), **a dangling "the rule above"**, and **the perf step's orphaned trace line:** prose accuracy only.
- **The writer sentence pasted into eight places** (many runs) and **the table shape restated in six places:** smells.
- **The "with state" definition drifts** (to-spec omits "rounds", opus-5.5 pr94-r1/standards/2#3): a narrower trigger in one prose copy. The runner prompt and Ticket step 6, which drive the path, include rounds.
- **The runner prompt addresses the orchestrator, and a non-Ticket architect run has no posting rule** (opus-5 pr94-r1/standards/3#2; verifier 94 criterion 3 and Notes 4): off the documented Ticket path, and the verifier's own wording is "a note, not a block".
- **The doctor's slim-knowledge check reads only PHILOSOPHY and MANUAL** (verifier 94 Notes 2): an older gap in a file outside the diff.
- **gate.sh lands mode 100644** (pr96-r1 Fix alongside 3): CI runs it through bash.
- **The doctor prints PASS for any ShellCheck version:** cosmetic, because the gate ignores that binary.
- **U35, test 6 assumes no ShellCheck 0.11.0 in `/usr/bin`:** a red test, never a silent gate.
- **`${#files[@]}` under `set -u` on bash 3.2** (opus-5 pr96-r1/standards/2#2): no failure. `${#arr[@]}` of an empty array is defined under `set -u`; only `"${arr[@]}"` errors before bash 4.4, and the empty case exits before that expansion. I did not run this: the lane's guard refuses `bash -c` here.
- **The M0 line's file arithmetic is one short** (pr96-r2 S3), **the SC2016 file-wide disable**, **the delegation.sh "line 7" comments**, **data clumps** and **globs duplicated in two files:** prose or smells.
- **An empty skills directory counts as 1** (pr96-r2 Fix alongside 5): a cosmetic count line.
- **log.sh and worktree-audit.sh are linted but not in keep_files** (verifier 96 Notes 6): a future upstream change turns CI red, which is loud.
- **fake-gh.sh:15 drops a fallback when `cat` fails** (verifier 96 Notes 3): unreachable.
- **gate.sh:78 pins 4 files** (verifier 96 gates): not a defect.
- **U25, U26, U29 and U30:** noise per the judge (a stale repro, a loud `conflicts` line, and a cache already fixed at that head). I did not re-read them.
- **U02, a bare `restart` line in a pasted report resets the history** (`review-brief.sh:143 @ 52ccd8e`, `$0 == "restart"`): real. It needs a report line that is exactly `restart` outside a fence, which is off the documented path. It is minor per the judge, and I agree.
- **The summary line hides the holes it subtracts** (opus-5 and opus-5.5 pr99-r1/standards/3#2): cosmetic, because the count is right.
- **P19, P20 and P21 not amended** (opus-5 pr99-r1/standards/1#2; pr99-r1b S2 and S3): prose, and 384bb43 fixes it.
- **Step 6 says "carries hole:"** (opus-5 pr99-r1/standards/2#1) and **"word for word" names the line, not the value** (opus-5 pr99-r1/standards/3#3): two prose copies read against each other, with no behavior change.
- **`holed()` reads only an item's opening line** (verifier 99 Notes): it matches the contract.
- **The ordering test assumes one match per rule**, the **`ref_id` parse written twice** and **globals reused in the hole loop:** test robustness and smells.
- **PR-body receipts and counts** (verifier 94 Issues 1 and 3; verifier 99 Issues 1 to 3): not code at a head.

## Anchors that cannot fully separate

- **pr99-r1 G2 and G4.** run claude-opus-5.5/pr99-r1/spec/1#1 describes both bugs in one item: "The Standards brief does not include the ticket" is G4, and "A review with no ticket at all ... can never finish" is G2. Both anchor sets match it. The 103 judge credited it to P1 (G2). G2 and G4 each have 3 anchors, and `reviewer.claims` resolves the tie by label order, so the scorer gives it to G2 (`claims.out`). G4 had no other item at pr99-r1 before #138; opus-5 pr99-r1/standards/1#1 of #138 now matches G4 alone ("Anchor edits"). Its separating evidence is the pr99-r1b item (opus-5 pr99-r1b/standards/4#1), which matches G4 only.
- **pr96-r1 G1 and G2.** Eight glob items also name the space split. Both anchor sets match each one, and the validator lists them as `both`:
  - hist pr96-r1/standards#1
  - run opus-5 spec/1#1 and standards/3#1
  - run opus-5.5 spec/2#1, spec/3#1, standards/1#1 and standards/3#1
  - run astra spec/1#1 (U34)
- **How `claims` resolves the pr96-r1 overlap.** G1 and G2 each have 3 anchors, so the scorer gives a combined item to G1 by label order. That agrees with the 103 audit's credits.
- **The one crediting disagreement.** The 103 audit credited astra pr96-r1/standards/2#1 to the glob label; judge-pr96 (U42) says space split. The item's text is the space split ("a quoted path containing spaces is split"), so I credit it to G2. It matches G2 only.
- Every other credited item matches its bug alone.

## Validation

The scripts ran in a scratch directory: `corpus.py` loads every historical report and every run report through `reviewer.parse_report`. `validate.py` checks credits. `claims.py` runs `reviewer.claims` with the truth rows as labels. `dry.py` and `applyall.py` apply the fixes. They are reproduced below, then their output.

### `corpus.py`

```python
import sys, glob, os
W = "<a checkout at e710e99, which still holds the labels and historical reports>"
M = "<the main checkout, which holds the #103 runs under .scratch/eval/reviewer>"
sys.path.insert(0, W + "/tests/eval/reviewer")
import reviewer

def items_of(path):
    text = open(path).read() if os.path.exists(path) else None
    parsed = reviewer.parse_report(text)
    if isinstance(parsed, str):
        # parse anyway, so an item in a report the scorer rejects is not lost to the check
        parsed2 = reviewer.parse_report((text or "") + "\n## Would break\n\nhard findings: 0\n")
        return parsed, ([] if isinstance(parsed2, str) else parsed2)
    return "ok", parsed

def corpus():
    """Yield (source_id, round_or_brief, item_no, hard, text, parse_status)."""
    for rd in sorted(os.listdir(W + "/tests/eval/reviewer/rounds")):
        for ax in ("standards", "spec"):
            p = f"{W}/tests/eval/reviewer/rounds/{rd}/review/{ax}-report.historical.md"
            st, its = items_of(p)
            for it in its:
                yield (f"hist/{rd}/{ax}", rd, it.n, it.hard, it.text, st)
    for p in sorted(glob.glob(M + "/.scratch/eval/reviewer/runs/*/*/*/*/report.md")):
        model, brief, ax, k = p.split("/")[-5:-1]
        st, its = items_of(p)
        for it in its:
            yield (f"run/{model}/{brief}/{ax}/{k}", brief, it.n, it.hard, it.text, st)

if __name__ == "__main__":
    from collections import Counter
    c = Counter(); bad = Counter()
    for s, rd, n, h, t, st in corpus():
        c[rd] += 1
        if st != "ok": bad[(s, st)] += 1
    print(c); print(bad)
```

### `validate.py`

```python
"""Validate the truth anchors against every parsed report item.

For each head: every item credited to a bug must match that bug's anchors; no item credited to
another bug of the same head may match them (items that describe two bugs are listed as `both`
and reported separately); every other item that matches is printed for inspection.
"""
import re, sys
import corpus

TRUTH = {}  # (round, id) -> list[str]
for line in open(sys.argv[1]):
    if line.startswith("#") or not line.strip():
        continue
    rd, gid, anchors = line.rstrip("\n").split("\t")[:3]
    TRUTH[(rd, gid)] = [re.compile(p) for p in anchors.split(" && ")]

def matches(key, text):
    return all(a.search(text) for a in TRUTH[key])

R = "run/"
CREDIT = {
    # pr94-r1
    ("hist/pr94-r1/standards", 1): "G1",
    (R + "claude-opus-5/pr94-r1/spec/1", 1): "G1",          # U04
    (R + "claude-opus-5/pr94-r1/standards/3", 1): "G1",     # label hit
    ("hist/pr94-r1/spec", 1): "G2",
    ("hist/pr94-r1/standards", 5): "G2",                     # Fix alongside, same bug
    (R + "claude-opus-5/pr94-r1/spec/2", 2): "G2",          # label hit
    (R + "claude-opus-5/pr94-r1/standards/2", 1): "G2",     # U06
    ("hist/pr94-r1/spec", 2): "G3",
    ("hist/pr94-r1/spec", 3): "G4",
    (R + "claude-opus-5/pr94-r1/spec/1", 2): "G4",          # U05
    (R + "claude-opus-5/pr94-r1/spec/2", 1): "G4",
    (R + "claude-opus-5/pr94-r1/spec/3", 1): "G4",
    (R + "claude-opus-5/pr94-r1/spec/3", 2): "G4",
    (R + "claude-opus-5/pr94-r1/standards/1", 1): "G4",     # 103 audit, other
    (R + "claude-opus-5/pr94-r1/standards/2", 2): "G4",
    (R + "claude-opus-5/pr94-r1/standards/2", 3): "G4",     # 103 audit, other
    (R + "claude-sonnet/pr94-r1/standards/4", 2): "G4",     # 103 audit, other
    ("hist/pr94-r1/spec", 4): "G5",
    (R + "codex-gpt-6-astra/pr94-r1/spec/1", 1): "G6",      # U31
    (R + "codex-gpt-6-astra/pr94-r1/spec/2", 1): "G6",      # U32
    (R + "codex-gpt-6-astra/pr94-r1/spec/3", 1): "G6",      # U33
    # pr96-r1
    ("hist/pr96-r1/standards", 1): "G1",
    ("hist/pr96-r1/spec", 1): "G1",
    (R + "claude-opus-5.5/pr96-r1/spec/1", 1): "G1",
    (R + "claude-opus-5.5/pr96-r1/standards/2", 1): "G1",
    (R + "claude-opus-5/pr96-r1/spec/1", 1): "G1",
    (R + "claude-opus-5/pr96-r1/spec/2", 1): "G1",
    (R + "claude-opus-5/pr96-r1/spec/3", 1): "G1",
    (R + "claude-opus-5/pr96-r1/standards/1", 2): "G1",
    (R + "claude-sonnet/pr96-r1/spec/1", 1): "G1",
    (R + "claude-sonnet/pr96-r1/spec/2", 2): "G1",
    (R + "claude-sonnet/pr96-r1/spec/3", 1): "G1",
    (R + "claude-sonnet/pr96-r1/standards/1", 1): "G1",
    (R + "claude-sonnet/pr96-r1/standards/2", 1): "G1",
    (R + "claude-sonnet/pr96-r1/standards/3", 1): "G1",
    (R + "claude-sonnet/pr96-r1/standards/4", 2): "G1",
    (R + "codex-gpt-6-astra/pr96-r1/spec/2", 2): "G1",
    (R + "codex-gpt-6-astra/pr96-r1/spec/3", 3): "G1",
    (R + "codex-gpt-6-astra/pr96-r1/standards/1", 2): "G1",
    (R + "claude-opus-5/pr96-r1/standards/1", 1): "G2",     # U11
    (R + "codex-gpt-6-astra/pr96-r1/spec/2", 1): "G2",      # U37
    (R + "codex-gpt-6-astra/pr96-r1/spec/3", 1): "G2",      # U39
    (R + "codex-gpt-6-astra/pr96-r1/standards/1", 1): "G2", # U41
    (R + "codex-gpt-6-astra/pr96-r1/standards/2", 1): "G2", # U42
    (R + "codex-gpt-6-astra/pr96-r1/standards/3", 1): "G2", # U43
    ("hist/pr96-r2/standards", 1): "G2",                     # label pr96-r2 S1, later round
    (R + "claude-opus-5.5/pr96-r1/spec/1", 2): "G3",        # U01
    (R + "claude-opus-5/pr96-r1/spec/1", 2): "G3",          # U10
    (R + "claude-opus-5/pr96-r1/standards/2", 1): "G3",     # U12
    (R + "codex-gpt-6-astra/pr96-r1/spec/1", 3): "G3",      # U36
    (R + "codex-gpt-6-astra/pr96-r1/spec/2", 3): "G3",      # U38
    (R + "codex-gpt-6-astra/pr96-r1/spec/3", 2): "G3",      # U40
    (R + "claude-opus-5.5/pr96-r1/standards/1", 3): "G3",   # non-hard
    (R + "claude-opus-5.5/pr96-r1/standards/2", 2): "G3",   # non-hard
    (R + "claude-opus-5/pr96-r1/standards/3", 2): "G3",     # non-hard
    ("hist/pr96-r2/standards", 2): "G3",                     # label pr96-r2 S2, later round
    ("hist/pr96-r2/spec", 1): "G3",                          # label pr96-r2 P1, later round
    (R + "claude-sonnet/pr96-r1/spec/2", 1): "G4",          # U23
    (R + "claude-sonnet/pr96-r1/standards/4", 1): "G4",     # U24
    # pr99-r1
    ("hist/pr99-r1/standards", 1): "G1",
    (R + "claude-opus-5/pr99-r1/spec/3", 1): "G1",          # U15
    (R + "claude-sonnet/pr99-r1/spec/1", 1): "G1",
    (R + "claude-opus-5.5/pr99-r1/spec/2", 1): "G1",        # 103 audit, other
    (R + "claude-opus-5.5/pr99-r1/standards/1", 3): "G1",   # 103 audit, other
    (R + "claude-opus-5/pr99-r1/standards/3", 1): "G1",     # 103 audit, other
    ("hist/pr99-r1/spec", 1): "G2",
    (R + "claude-sonnet/pr99-r1/spec/3", 1): "G2",          # label hit
    (R + "claude-sonnet/pr99-r1/standards/1", 1): "G2",
    (R + "claude-opus-5.5/pr99-r1/standards/1", 2): "G2",   # 103 audit, other
    ("hist/pr99-r1/standards", 3): "G3",                     # Fix alongside, same bug
    (R + "claude-opus-5/pr99-r1/standards/1", 1): "G3",     # U16
    ("hist/pr99-r1b/standards", 1): "G3",                    # label pr99-r1b S1, later round
    (R + "claude-opus-5/pr99-r1b/standards/4", 1): "G4",    # U17, later brief
}
# Items that describe two bugs of the head; either anchor set may match them.
BOTH = {
    ("hist/pr96-r1/standards", 1): {"G1", "G2"},                    # glob item, space named in passing
    (R + "claude-opus-5/pr96-r1/spec/1", 1): {"G1", "G2"},
    (R + "claude-opus-5/pr96-r1/standards/3", 1): {"G1", "G2"},
    (R + "claude-opus-5.5/pr96-r1/spec/2", 1): {"G1", "G2"},
    (R + "claude-opus-5.5/pr96-r1/standards/3", 1): {"G1", "G2"},
    (R + "codex-gpt-6-astra/pr96-r1/spec/1", 1): {"G1", "G2"},      # U34
    (R + "claude-opus-5.5/pr99-r1/spec/1", 1): {"G2", "G4"},
    (R + "claude-opus-5.5/pr96-r1/spec/3", 1): {"G1", "G2"},       # glob item, "a path that contains a space ... splits it"
    (R + "claude-opus-5.5/pr96-r1/standards/1", 1): {"G1", "G2"},  # glob item, "a quoted path that $g splits at a space"
}
HEAD_OF = {"pr94-r1": "pr94-r1", "pr96-r1": "pr96-r1", "pr99-r1": "pr99-r1",
           "pr96-r2": "pr96-r1", "pr99-r1b": "pr99-r1"}

fail = 0
seen = set()
for src, rd, n, hard, text, st in corpus.corpus():
    key = (src, n)
    head = HEAD_OF.get(rd)
    if head is None:
        continue
    hit = {g for (r, g) in TRUTH if r == head and matches((r, g), text)}
    want = CREDIT.get(key)
    both = BOTH.get(key)
    later = rd != head
    if both:
        seen.add(key)
        ok = bool(hit & both) and not (hit - both)
        print(f"{'ok  ' if ok else 'FAIL'} both {sorted(both)} {src}#{n}: matched {sorted(hit)}")
        fail += not ok
    elif want:
        seen.add(key)
        ok = hit == {want}
        print(f"{'ok  ' if ok else 'FAIL'} {head} {want} {src}#{n} {'H' if hard else 'o'}: matched {sorted(hit)}")
        fail += not ok
    elif hit and not later:
        print(f"INFO uncredited {src}#{n} {'H' if hard else 'o'} matched {sorted(hit)} | {text[:160]}")
    elif hit and later:
        print(f"INFO later-round {src}#{n} {'H' if hard else 'o'} matched {sorted(hit)} | {text[:160]}")
missing = set(CREDIT) - seen
for m in sorted(missing):
    print("FAIL credited item not found", m); fail += 1
print("failures:", fail)
```

### `claims.py`

```python
"""Score every report of the three heads against the truth rows with reviewer.claims (hard items only)."""
import re, sys
from collections import defaultdict
import corpus, reviewer

rows = defaultdict(list)
for line in open(sys.argv[1]):
    if line.startswith("#") or not line.strip():
        continue
    rd, gid, anchors = line.rstrip("\n").split("\t")[:3]
    rows[rd].append(reviewer.Label(None, gid, "fixed", tuple(re.compile(p) for p in anchors.split(" && "))))

reports = defaultdict(list)
for src, rd, n, hard, text, st in corpus.corpus():
    if rd in rows:
        reports[(rd, src)].append(reviewer.Item(n, hard, text))

for (rd, src), items in sorted(reports.items()):
    hard = [i for i in items if i.hard]
    got = reviewer.claims(hard, tuple(rows[rd]))
    hits = {rows[rd][li].id: hard[ii].n for li, ii in got.items()}
    soft = sorted({l.id for l in rows[rd] for i in items if not i.hard and l.matches(i.text)} - set(hits))
    if hits or soft:
        print(f"{src}: hard {dict(sorted(hits.items()))}" + (f"; non-hard {soft}" if soft else ""))
```

### `dry.py`

```python
import subprocess, sys, shutil, tempfile, os, re
base = "<a scratch directory holding p/<sha>.patch and each head's files under t/<head>/>"
head = sys.argv[1]; seq = sys.argv[2].split(",")
tmp = tempfile.mkdtemp(dir=base, prefix=f"ap-{head}-")
files = set()
for p in seq:
    files |= set(re.findall(r"^\+\+\+ b/(.*)$", open(f"{base}/p/{p}.patch").read(), re.M))
for f in files:
    src = os.path.join(base, "t", head, f)
    if os.path.exists(src):
        os.makedirs(os.path.dirname(os.path.join(tmp, f)), exist_ok=True)
        shutil.copy(src, os.path.join(tmp, f))
for p in seq:
    r = subprocess.run(["patch", "-p1", "-f", "-i", os.path.join(base, "p", p + ".patch")], cwd=tmp, capture_output=True, text=True)
    print(p, "rc", r.returncode, " | ".join(l for l in (r.stdout + r.stderr).splitlines() if "FAILED" in l or "failed" in l or "Hunk" in l))
print("OUT", tmp)
```

### `applyall.py`

```python
"""Apply each truth row's fix commits, in order, to a copy of the head's files (patch -p1)."""
import subprocess
base = "<a scratch directory holding p/<sha>.patch and each head's files under t/<head>/>"
cases = [("c83f166", "b368116"), ("c83f166", "3f5033f"), ("c83f166", "b368116,3f5033f"),
         ("c83f166", "b368116,3f5033f,715100c"), ("c83f166", "715100c"), ("c83f166", "0c63fa6"),
         ("c83f166", "ca2c106"), ("69bd412", "01e5386"), ("69bd412", "72953c0"), ("69bd412", "a64c7e6"),
         ("69bd412", "ae1b4b5"), ("52ccd8e", "53ca502"), ("52ccd8e", "53ca502,32978fa"), ("52ccd8e", "384bb43")]
for h, s in cases:
    r = subprocess.run(["python3", f"{base}/dry.py", h, s], capture_output=True, text=True, cwd=base)
    print(f"$ dry.py {h} {s}")
    print("\n".join(l for l in (r.stdout + r.stderr).splitlines() if not l.startswith("OUT")))
```

### Anchor validation: `python3 validate.py truth.tsv`

```
ok   pr94-r1 G1 hist/pr94-r1/standards#1 H: matched ['G1']
ok   pr94-r1 G2 hist/pr94-r1/standards#5 o: matched ['G2']
ok   pr94-r1 G2 hist/pr94-r1/spec#1 H: matched ['G2']
ok   pr94-r1 G3 hist/pr94-r1/spec#2 H: matched ['G3']
ok   pr94-r1 G4 hist/pr94-r1/spec#3 H: matched ['G4']
ok   pr94-r1 G5 hist/pr94-r1/spec#4 H: matched ['G5']
ok   both ['G1', 'G2'] hist/pr96-r1/standards#1: matched ['G1', 'G2']
ok   pr96-r1 G1 hist/pr96-r1/spec#1 H: matched ['G1']
ok   pr96-r1 G2 hist/pr96-r2/standards#1 H: matched ['G2']
ok   pr96-r1 G3 hist/pr96-r2/standards#2 H: matched ['G3']
ok   pr96-r1 G3 hist/pr96-r2/spec#1 H: matched ['G3']
ok   pr99-r1 G1 hist/pr99-r1/standards#1 H: matched ['G1']
ok   pr99-r1 G3 hist/pr99-r1/standards#3 o: matched ['G3']
ok   pr99-r1 G2 hist/pr99-r1/spec#1 H: matched ['G2']
ok   pr99-r1 G3 hist/pr99-r1b/standards#1 H: matched ['G3']
INFO later-round hist/pr99-r1b/standards#4 o matched ['G1'] | the no-form refusal reprints a value that looks well formed. holed() matches the substring hole:, but the form check wants hole: and value() strips at most one 
ok   pr96-r1 G1 run/claude-opus-5.5/pr96-r1/spec/1#1 H: matched ['G1']
ok   pr96-r1 G3 run/claude-opus-5.5/pr96-r1/spec/1#2 H: matched ['G3']
ok   both ['G1', 'G2'] run/claude-opus-5.5/pr96-r1/spec/2#1: matched ['G1', 'G2']
ok   both ['G1', 'G2'] run/claude-opus-5.5/pr96-r1/spec/3#1: matched ['G1', 'G2']
ok   both ['G1', 'G2'] run/claude-opus-5.5/pr96-r1/standards/1#1: matched ['G1', 'G2']
ok   pr96-r1 G3 run/claude-opus-5.5/pr96-r1/standards/1#3 o: matched ['G3']
ok   pr96-r1 G1 run/claude-opus-5.5/pr96-r1/standards/2#1 H: matched ['G1']
ok   pr96-r1 G3 run/claude-opus-5.5/pr96-r1/standards/2#2 o: matched ['G3']
ok   both ['G1', 'G2'] run/claude-opus-5.5/pr96-r1/standards/3#1: matched ['G1', 'G2']
INFO later-round run/claude-opus-5.5/pr96-r2/standards/1#1 o matched ['G2'] | the gate word-splits a path it is given. coding_standards.md, bash: "quote every path. paths here contain spaces." and "test a command the way a user types it: 
INFO later-round run/claude-opus-5.5/pr96-r2/standards/2#1 H matched ['G2'] | an absolute path to a file under a spaced directory is refused as "no file matched". coding_standards.md, bash: "quote every path. paths here contain spaces." a
INFO later-round run/claude-opus-5.5/pr96-r2/standards/2#3 o matched ['G3'] | the cached binary is trusted without its checksum. this is a judgement call and matches the author's risk 1. the sha is checked only on the run that downloads. 
INFO later-round run/claude-opus-5.5/pr96-r2/standards/3#1 o matched ['G2'] | the gate word-splits every path it is given. the standard is coding_standards.md, bash: "quote every path. paths here contain spaces." and "test a command the w
INFO later-round run/claude-opus-5.5/pr96-r2/standards/3#2 o matched ['G3'] | a cached binary is trusted on -x alone (speculative trust; blast-radius risk 1). the checksum and the version are checked only on the download path. a re-run of
ok   both ['G2', 'G4'] run/claude-opus-5.5/pr99-r1/spec/1#1: matched ['G2', 'G4']
ok   pr99-r1 G1 run/claude-opus-5.5/pr99-r1/spec/2#1 o: matched ['G1']
ok   pr99-r1 G2 run/claude-opus-5.5/pr99-r1/standards/1#2 o: matched ['G2']
ok   pr99-r1 G1 run/claude-opus-5.5/pr99-r1/standards/1#3 o: matched ['G1']
ok   pr94-r1 G1 run/claude-opus-5/pr94-r1/spec/1#1 H: matched ['G1']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/spec/1#2 H: matched ['G4']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/spec/2#1 H: matched ['G4']
ok   pr94-r1 G2 run/claude-opus-5/pr94-r1/spec/2#2 H: matched ['G2']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/spec/3#1 H: matched ['G4']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/spec/3#2 H: matched ['G4']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/standards/1#1 o: matched ['G4']
ok   pr94-r1 G2 run/claude-opus-5/pr94-r1/standards/2#1 H: matched ['G2']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/standards/2#2 o: matched ['G4']
ok   pr94-r1 G4 run/claude-opus-5/pr94-r1/standards/2#3 o: matched ['G4']
ok   pr94-r1 G1 run/claude-opus-5/pr94-r1/standards/3#1 H: matched ['G1']
ok   both ['G1', 'G2'] run/claude-opus-5/pr96-r1/spec/1#1: matched ['G1']
ok   pr96-r1 G3 run/claude-opus-5/pr96-r1/spec/1#2 H: matched ['G3']
ok   pr96-r1 G1 run/claude-opus-5/pr96-r1/spec/2#1 H: matched ['G1']
ok   pr96-r1 G1 run/claude-opus-5/pr96-r1/spec/3#1 H: matched ['G1']
ok   pr96-r1 G2 run/claude-opus-5/pr96-r1/standards/1#1 H: matched ['G2']
ok   pr96-r1 G1 run/claude-opus-5/pr96-r1/standards/1#2 H: matched ['G1']
ok   pr96-r1 G3 run/claude-opus-5/pr96-r1/standards/2#1 H: matched ['G3']
ok   both ['G1', 'G2'] run/claude-opus-5/pr96-r1/standards/3#1: matched ['G1', 'G2']
ok   pr96-r1 G3 run/claude-opus-5/pr96-r1/standards/3#2 o: matched ['G3']
INFO later-round run/claude-opus-5/pr96-r2/spec/2#1 H matched ['G3'] | a cached binary is run as the pin without its checksum. shellcheck.sh:26 skips the download, and so the sha, whenever ${tmpdir:-/tmp}/shellcheck-0.11.0/shellche
INFO later-round run/claude-opus-5/pr96-r2/spec/3#1 H matched ['G1', 'G4'] | the zero-argument form refuses inside the factory. the factory root has .claude/hooks and .claude/skills (both symlinks) but no .agents/, so the default glob .a
INFO later-round run/claude-opus-5/pr96-r2/spec/3#2 H matched ['G3'] | a cached binary is run without its checksum. after the first download, [ ! -x "$bin" ] (template/.github/shellcheck.sh:26) skips both the download and the sha25
INFO later-round run/claude-opus-5/pr96-r2/standards/1#1 H matched ['G3'] | the cached binary runs without a version or sha check. the path binary is verified against the pin (grep -qx "version: $version"), but once $dir/shellcheck-v$ve
INFO later-round run/claude-opus-5/pr96-r2/standards/2#1 H matched ['G2'] | a glob argument with a space in it is split, and a half that matches wins silently. $g is expanded unquoted, so the argument is word-split before pathname expan
INFO later-round run/claude-opus-5/pr96-r2/standards/2#3 o matched ['G3'] | the cached binary is trusted on its path alone. [ ! -x "$bin" ] skips both the download and the sha, so anything already at ${tmpdir:-/tmp}/shellcheck-0.11.0/sh
INFO later-round run/claude-opus-5/pr96-r2/standards/3#4 o matched ['G1'] | dirs=("$skills"//) counts one when nothing matches. without nullglob the unmatched pattern survives as a literal, so an empty skills directory would print vendo
ok   pr99-r1 G1 run/claude-opus-5/pr99-r1/spec/3#1 H: matched ['G1']
ok   pr99-r1 G3 run/claude-opus-5/pr99-r1/standards/1#1 H: matched ['G3']
ok   pr99-r1 G1 run/claude-opus-5/pr99-r1/standards/3#1 o: matched ['G1']
INFO later-round run/claude-opus-5/pr99-r1b/standards/1#1 o matched ['G3'] | shotgun surgery: the design-hole rule is restated in five documents and three patches. the definition of a hole, the restart line and the not-merge-ready conseq
INFO later-round run/claude-opus-5/pr99-r1b/standards/3#1 H matched ['G3'] | the human's merge checklist still reads act-on items: 0 as ready. the change teaches babysit/skill.md, playbooks/babysit.md, playbooks/ticket.md and review-ladd
INFO later-round run/claude-opus-5/pr99-r1b/standards/3#3 o matched ['G1'] | hole: is detected by an unanchored substring. grep 'hole:' also matches a word ending in hole: (whole:, loophole:), which then reaches the form check and is ref
ok   pr99-r1 G4 run/claude-opus-5/pr99-r1b/standards/4#1 H: matched ['G4']
ok   pr94-r1 G4 run/claude-sonnet/pr94-r1/standards/4#2 o: matched ['G4']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/spec/1#1 H: matched ['G1']
ok   pr96-r1 G4 run/claude-sonnet/pr96-r1/spec/2#1 H: matched ['G4']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/spec/2#2 H: matched ['G1']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/spec/3#1 H: matched ['G1']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/standards/1#1 H: matched ['G1']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/standards/2#1 H: matched ['G1']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/standards/3#1 H: matched ['G1']
ok   pr96-r1 G4 run/claude-sonnet/pr96-r1/standards/4#1 H: matched ['G4']
ok   pr96-r1 G1 run/claude-sonnet/pr96-r1/standards/4#2 H: matched ['G1']
INFO later-round run/claude-sonnet/pr96-r2/spec/1#1 H matched ['G3'] | a tampered or replaced cache is trusted without a checksum. once ${tmpdir:-/tmp}/shellcheck-$version/shellcheck-v$version/shellcheck exists, the gate skips the 
INFO later-round run/claude-sonnet/pr96-r2/spec/2#1 H matched ['G1'] | the unmatched-glob refusal does not hold beside a glob that matches. the commit named for this exact behavior (01e5386, "refuse a glob that matches nothing even
INFO later-round run/claude-sonnet/pr96-r2/spec/3#1 H matched ['G3'] | cached binary reused with no re-verification. once ${tmpdir:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck exists, [ ! -x "$bin" ] at template/.github/s
INFO later-round run/claude-sonnet/pr96-r2/spec/4#1 H matched ['G3'] | a cached shellcheck binary is reused with no verification. the download branch's own guard, [ ! -x "$bin" ], only downloads and checksums when the cached path i
ok   pr99-r1 G1 run/claude-sonnet/pr99-r1/spec/1#1 H: matched ['G1']
ok   pr99-r1 G2 run/claude-sonnet/pr99-r1/spec/3#1 H: matched ['G2']
ok   pr99-r1 G2 run/claude-sonnet/pr99-r1/standards/1#1 H: matched ['G2']
ok   pr94-r1 G6 run/codex-gpt-6-astra/pr94-r1/spec/1#1 H: matched ['G6']
ok   pr94-r1 G6 run/codex-gpt-6-astra/pr94-r1/spec/2#1 H: matched ['G6']
ok   pr94-r1 G6 run/codex-gpt-6-astra/pr94-r1/spec/3#1 H: matched ['G6']
ok   both ['G1', 'G2'] run/codex-gpt-6-astra/pr96-r1/spec/1#1: matched ['G1', 'G2']
ok   pr96-r1 G3 run/codex-gpt-6-astra/pr96-r1/spec/1#3 H: matched ['G3']
ok   pr96-r1 G2 run/codex-gpt-6-astra/pr96-r1/spec/2#1 H: matched ['G2']
ok   pr96-r1 G1 run/codex-gpt-6-astra/pr96-r1/spec/2#2 H: matched ['G1']
ok   pr96-r1 G3 run/codex-gpt-6-astra/pr96-r1/spec/2#3 H: matched ['G3']
ok   pr96-r1 G2 run/codex-gpt-6-astra/pr96-r1/spec/3#1 H: matched ['G2']
ok   pr96-r1 G3 run/codex-gpt-6-astra/pr96-r1/spec/3#2 H: matched ['G3']
ok   pr96-r1 G1 run/codex-gpt-6-astra/pr96-r1/spec/3#3 H: matched ['G1']
ok   pr96-r1 G2 run/codex-gpt-6-astra/pr96-r1/standards/1#1 H: matched ['G2']
ok   pr96-r1 G1 run/codex-gpt-6-astra/pr96-r1/standards/1#2 H: matched ['G1']
ok   pr96-r1 G2 run/codex-gpt-6-astra/pr96-r1/standards/2#1 H: matched ['G2']
ok   pr96-r1 G2 run/codex-gpt-6-astra/pr96-r1/standards/3#1 H: matched ['G2']
INFO later-round run/codex-gpt-6-astra/pr96-r2/standards/1#1 H matched ['G2'] | a quoted path can check a different file. coding_standards.md, bash: “quote every path. paths here contain spaces.” the unquoted expansion splits the argument b
INFO later-round run/codex-gpt-6-astra/pr96-r2/standards/1#2 H matched ['G3'] | an executable cache entry bypasses the pin. docs/knowledge/core/decisions.md, p2: “pin every tool ci runs to an exact version.” only the path binary receives a 
INFO later-round run/codex-gpt-6-astra/pr96-r2/standards/2#1 H matched ['G2'] | a quoted path can silently select a different file. coding_standards.md, bash: “quote every path. paths here contain spaces.” the unquoted expansion splits each
INFO later-round run/codex-gpt-6-astra/pr96-r2/standards/2#2 H matched ['G3'] | an executable cache entry bypasses the pin. docs/knowledge/core/decisions.md, p2: “pin every tool ci runs to an exact version”. executability alone admits a cac
INFO later-round run/codex-gpt-6-astra/pr96-r2/standards/3#1 H matched ['G1', 'G2'] | quoted paths are split again inside the gate. coding_standards.md, bash: “quote every path. paths here contain spaces.” the unquoted expansion performs word spl
INFO later-round run/codex-gpt-6-astra/pr96-r2/standards/3#2 H matched ['G1', 'G3'] | the cached executable bypasses the pin verification. docs/knowledge/core/decisions.md, p2: “pin every tool ci runs to an exact version.” the path executable is 
failures: 0
```

### Scorer simulation: `python3 claims.py truth.tsv` (hard items claimed per report; non-hard matches listed)

```
hist/pr94-r1/spec: hard {'G2': 1, 'G3': 2, 'G4': 3, 'G5': 4}
hist/pr94-r1/standards: hard {'G1': 1}; non-hard ['G2']
run/claude-opus-5/pr94-r1/spec/1: hard {'G1': 1, 'G4': 2}
run/claude-opus-5/pr94-r1/spec/2: hard {'G2': 2, 'G4': 1}
run/claude-opus-5/pr94-r1/spec/3: hard {'G4': 1}
run/claude-opus-5/pr94-r1/standards/1: hard {}; non-hard ['G4']
run/claude-opus-5/pr94-r1/standards/2: hard {'G2': 1}; non-hard ['G4']
run/claude-opus-5/pr94-r1/standards/3: hard {'G1': 1}
run/claude-sonnet/pr94-r1/standards/4: hard {}; non-hard ['G4']
run/codex-gpt-6-astra/pr94-r1/spec/1: hard {'G6': 1}
run/codex-gpt-6-astra/pr94-r1/spec/2: hard {'G6': 1}
run/codex-gpt-6-astra/pr94-r1/spec/3: hard {'G6': 1}
hist/pr96-r1/spec: hard {'G1': 1}
hist/pr96-r1/standards: hard {'G1': 1}
run/claude-opus-5.5/pr96-r1/spec/1: hard {'G1': 1, 'G3': 2}
run/claude-opus-5.5/pr96-r1/spec/2: hard {'G1': 1}
run/claude-opus-5.5/pr96-r1/spec/3: hard {'G1': 1}
run/claude-opus-5.5/pr96-r1/standards/1: hard {'G1': 1}; non-hard ['G3']
run/claude-opus-5.5/pr96-r1/standards/2: hard {'G1': 1}; non-hard ['G3']
run/claude-opus-5.5/pr96-r1/standards/3: hard {'G1': 1}
run/claude-opus-5/pr96-r1/spec/1: hard {'G1': 1, 'G3': 2}
run/claude-opus-5/pr96-r1/spec/2: hard {'G1': 1}
run/claude-opus-5/pr96-r1/spec/3: hard {'G1': 1}
run/claude-opus-5/pr96-r1/standards/1: hard {'G1': 2, 'G2': 1}
run/claude-opus-5/pr96-r1/standards/2: hard {'G3': 1}
run/claude-opus-5/pr96-r1/standards/3: hard {'G1': 1}; non-hard ['G3']
run/claude-sonnet/pr96-r1/spec/1: hard {'G1': 1}
run/claude-sonnet/pr96-r1/spec/2: hard {'G1': 2, 'G4': 1}
run/claude-sonnet/pr96-r1/spec/3: hard {'G1': 1}
run/claude-sonnet/pr96-r1/standards/1: hard {'G1': 1}
run/claude-sonnet/pr96-r1/standards/2: hard {'G1': 1}
run/claude-sonnet/pr96-r1/standards/3: hard {'G1': 1}
run/claude-sonnet/pr96-r1/standards/4: hard {'G1': 2, 'G4': 1}
run/codex-gpt-6-astra/pr96-r1/spec/1: hard {'G1': 1, 'G3': 3}
run/codex-gpt-6-astra/pr96-r1/spec/2: hard {'G1': 2, 'G2': 1, 'G3': 3}
run/codex-gpt-6-astra/pr96-r1/spec/3: hard {'G1': 3, 'G2': 1, 'G3': 2}
run/codex-gpt-6-astra/pr96-r1/standards/1: hard {'G1': 2, 'G2': 1}
run/codex-gpt-6-astra/pr96-r1/standards/2: hard {'G2': 1}
run/codex-gpt-6-astra/pr96-r1/standards/3: hard {'G2': 1}
hist/pr99-r1/spec: hard {'G2': 1}
hist/pr99-r1/standards: hard {'G1': 1}; non-hard ['G3']
run/claude-opus-5.5/pr99-r1/spec/1: hard {'G2': 1}
run/claude-opus-5.5/pr99-r1/spec/2: hard {}; non-hard ['G1']
run/claude-opus-5.5/pr99-r1/standards/1: hard {}; non-hard ['G1', 'G2']
run/claude-opus-5/pr99-r1/spec/3: hard {'G1': 1}
run/claude-opus-5/pr99-r1/standards/1: hard {'G3': 1}
run/claude-opus-5/pr99-r1/standards/3: hard {}; non-hard ['G1']
run/claude-sonnet/pr99-r1/spec/1: hard {'G1': 1}
run/claude-sonnet/pr99-r1/spec/3: hard {'G2': 1}
run/claude-sonnet/pr99-r1/standards/1: hard {'G2': 1}
```

### Fix application: `python3 applyall.py` (commit diffs from `git show --format= <sha>`; pr96 shellcheck fixes and ae1b4b5 limited to the files named above, see "Fix column rule")

```
$ dry.py c83f166 b368116
b368116 rc 0 
$ dry.py c83f166 3f5033f
3f5033f rc 1 1 out of 1 hunks failed--saving rejects to 'template/.agents/skills/poteto-mode/playbooks/ticket.md.rej'
$ dry.py c83f166 b368116,3f5033f
b368116 rc 0 
3f5033f rc 0 
$ dry.py c83f166 b368116,3f5033f,715100c
b368116 rc 0 
3f5033f rc 0 
715100c rc 0 
$ dry.py c83f166 715100c
715100c rc 1 1 out of 1 hunks failed--saving rejects to 'docs/knowledge/core/SCENARIO-TABLE.md.rej' | 1 out of 1 hunks failed--saving rejects to 'template/.agents/skills/poteto-mode/playbooks/ticket.md.rej' | 1 out of 1 hunks failed--saving rejects to 'template/.agents/skills/poteto-mode/scripts/overlap.sh.rej' | 1 out of 1 hunks failed--saving rejects to 'template/docs/factory918/SCENARIO-TABLE.md.rej' | 2 out of 2 hunks failed--saving rejects to 'tests/poteto-mode/overlap.sh.rej'
$ dry.py c83f166 0c63fa6
0c63fa6 rc 0 
$ dry.py c83f166 ca2c106
ca2c106 rc 0 
$ dry.py 69bd412 01e5386
01e5386 rc 0 
$ dry.py 69bd412 72953c0
72953c0 rc 0 
$ dry.py 69bd412 a64c7e6
a64c7e6 rc 0 
$ dry.py 69bd412 ae1b4b5
ae1b4b5 rc 0 
$ dry.py 52ccd8e 53ca502
53ca502 rc 0 
$ dry.py 52ccd8e 53ca502,32978fa
53ca502 rc 0 
32978fa rc 0 
$ dry.py 52ccd8e 384bb43
384bb43 rc 0
```

Whole-commit check for the pr96 fixes: 01e5386 applies alone; 72953c0 alone rejects 1 of 2 `tests/shellcheck/gate.sh` hunks; a64c7e6 alone rejects 2 of 2 `gate.sh` hunks; 01e5386,72953c0,a64c7e6 in order apply cleanly; ae1b4b5 whole rejects SOURCES.md and five playbook patch hunks.
