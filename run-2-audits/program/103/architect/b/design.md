# Candidate B: the reviewer-model runner under `tests/eval/reviewer/`

This design has state: it writes sandboxes, reports, receipts and scores, it has exit codes, and two
actors write during a run (the shell runner and the launched lane). So the package opens with the
scenario table, then the contract that defines every term the cells use, then the test list, then the
caller's usage, the shape, and the rationale.

One idea carries the whole design. **A run is a directory of bytes, and every number in the final
table is derived from those bytes by a pure function that can be rerun.** The shell never computes a
metric; it only places files and calls a provider. Nothing about a model, a replicate or this
measurement ever enters the sandbox the reviewer can see.

---

## 1. Scenario table

Situations down the side. Input shape across the top. Every cell names what is printed, the exit
code, and what the caller does next.

**Legend.** `refused` = one line on stderr naming the offending value and the correction, nothing
written anywhere, exit 2. `ran: k` = k run directories complete with `report.md`, `receipt.json` and
`score.json`, exit 0. `prepared: k` = k sandboxes and k `launch.json` files written, one line per run
on stdout, exit 20. `not ready` = one line on stderr, the run directory left as it was, exit 21.
`scored: <status>` = a complete run directory whose `score.json` carries that status, exit 0; a
scored failure is a result, not an error. `n/a` = the situation cannot arise for that input shape and
costs no code and no assertion. `refused by the tool` = the underlying tool's own message is printed
unchanged and becomes the receipt; we neither reword it nor pre-check for it.

| Situation \ input | **one brief** `run.sh <round> <axis> <model> <N>` | **a round** `run.sh <round> both <model> <N>` | **the whole set** `run.sh all <model> <N>` | **a stored run** `collect.sh <runid>…` |
|---|---|---|---|---|
| **1. Everything present, Codex descriptor** | `ran: N`, exit 0. Caller reads `score.json` or runs `table.py`. | `ran: 2N`, exit 0. | `ran: 24N`, exit 0. | `n/a`: a Codex run is already collected by `run.sh`; re-collecting rescores in place, `ran: 1`, exit 0. |
| **2. Everything present, Claude descriptor** | `prepared: N` and N launch lines, exit 20. Caller launches N lanes with the printed prompt paths, then polls `collect.sh`. | `prepared: 2N`, exit 20. | `prepared: 24N`, exit 20. Caller launches in bounded batches. | `ran: k` for the lanes whose report has landed, exit 0. |
| **3. Unknown model descriptor** | `refused`: the descriptor is not in the descriptor table, with the table's keys listed. Caller fixes the argument. | as one brief, `refused` before any sandbox. | as one brief. | `n/a`: the model is read from `launch.json`, not from argv. |
| **4. Unknown round id, or an axis the round has no brief for** | `refused`: names the id (or `<round>/<axis>`) and lists the round ids in `rounds/`. | `refused` on an unknown round id. An axis is not given. | `n/a`: the set is the directory listing. | `refused`: unknown runid, with the runids under `runs/` that share its round. |
| **5. `N` not an integer ≥ 1** | `refused`: `N must be an integer of at least 1; got "<value>"`. | as one brief. | as one brief. | `n/a`. |
| **6. Reviewed head missing (`refs/keep/103/<sha>` does not resolve)** | `refused`: names the round, the sha and the ref, and says to re-pin it before running. Nothing written. | `refused` on the first round whose head is missing, before any sandbox for any round. | as a round: the whole set's heads are resolved first, and one missing head refuses the set. | `n/a`: the sandbox already exists. |
| **7. Fixture incomplete (a brief, `meta.json`, `diff` or `labels` absent from the round dir)** | `refused`: names the missing file under `rounds/<round>/`. An absent `labels` is a fixture error; an *empty* `labels` is a valid round with no label. | as one brief, on the first round that is incomplete, before any sandbox. | as a round. | `refused`: the round the run names is incomplete, so the run cannot be scored. |
| **8. The requested replicate index already has a run directory** | Default: `ran: N` into the next free indices, exit 0, nothing overwritten. With an explicit `--replicate k` that exists: `refused`, naming `runs/<runid>/`. | as one brief. | as one brief. | Re-collect of a complete run rewrites the same bytes, `ran: 1`, exit 0. |
| **9. Codex refuses the model (HTTP 400, `unavailable-model`)** | `refused by the tool`: the runner's own message, the receipt is kept with `status: unavailable-model`, `scored: dropout` for that run, exit 0. Caller records the model as a dropout and stops launching it. | first refusal stops the round; the receipt is kept, exit 0. | first refusal stops the set for that model, exit 0. | `n/a`. |
| **10. Codex CLI absent or not logged in** | `refused by the tool`: preflight's own message, receipt kept with `status: unavailable-cli` or `unauthenticated`, exit 0 with `scored: dropout`. Caller logs in, or records the dropout. | as one brief. | as one brief. | `n/a`. |
| **11. A Claude lane has written no report yet** | `n/a`: `run.sh` does not wait. | `n/a`. | `n/a`. | `not ready`: names the runid and the report path it is waiting for, exit 21. Caller polls again. |
| **12. No transcript for a Claude lane (no `.meta.json` whose description is the sandbox id)** | `n/a`. | `n/a`. | `n/a`. | `not ready` while the report is also absent; with a report present and no transcript, `scored: no-receipt`, exit 0, the run counted and excluded from the token and wall-clock means. Caller sees it in the table's `no-receipt` column. |
| **13. Two transcripts carry the same sandbox id** | `n/a`. | `n/a`. | `n/a`. | `refused`: names both transcript paths; the sandbox id must be unique, so this is a harness bug, not data. |
| **14. Report has no `hard findings: N` line, is empty, or is truncated mid-item** | `scored: context-failure`, exit 0. Recall contributes nothing; the run counts in the failure column. | as one brief. | as one brief. | as one brief. |
| **15. Report has `hard findings: N` with N greater than the Would-break plus Fails-open item count, or headings out of contract order** | `scored: context-failure`, exit 0, with the refusal reason recorded. N below the item count is tolerated and scored normally, as `review-comment.sh` tolerates it. | as one brief. | as one brief. | as one brief. |
| **16. A hard finding matches no label; or two items match the same label** | `scored: complete` with that item counted as an unlabeled hard finding; a label is claimed by at most one item, and the loser counts as unlabeled. | as one brief. | as one brief. | as one brief. |
| **17. `TMPDIR` is unwritable, or `git archive` fails** | `refused`: the tool's own message with the sandbox root named. Nothing is left behind. | as one brief, before any dispatch. | as one brief. | `n/a`. |
| **18. A run exceeds `--timeout`** | Codex: `refused by the tool`, receipt `status: timed-out`, `scored: context-failure`, exit 0. | as one brief. | as one brief. | Claude: a lane with no report past the caller's own deadline is closed with `collect.sh --abandon <runid>`, which writes `scored: context-failure`, exit 0. |
| **19. A model is withheld or unreachable and no run is attempted** | `n/a`. | `n/a`. | `n/a`. | `run.sh --dropout <model> <reason> [--receipt FILE]` writes `dropouts/<model>.json` and exits 0; without a receipt file it records `status: withheld` and the reason verbatim. |

Row 9, row 10 and row 18's Codex half are written as "refused by the tool" deliberately: the probes on
2026-09-22 already ran the `gpt-6-terra` refusal and saw an `unavailable-model` receipt, so these
cells are grounded, not assumed. Row 17 and row 13 have not been run; they stay in the table as cells
with assertions rather than being cut.

---

## 2. Contract

Every term the cells use, defined once.

**round.** One of the twelve historical review rounds in `how.md`'s table. Its **round id** is
`pr<PR>-r<N>`, with `pr99-r1-restart` for the pre-restart round one. Ids are stable and appear in
runids, never in a sandbox.

**axis.** `standards` or `spec`. A round has both.

**brief.** The file `rounds/<round>/<axis>-brief.md`, the bytes `review-brief.sh` produced at that
round. The runner never regenerates a brief and never calls `gh`.

**round directory.** `tests/eval/reviewer/rounds/<round>/`, holding `meta.json`, `standards-brief.md`,
`spec-brief.md`, `diff` and `labels`. All five must exist; `labels` may be empty.

**reviewed head.** The commit the round reviewed, pinned as `refs/keep/103/<short-sha>` and named in
`meta.json`. The sandbox tree is this commit.

**review dir id.** The string the brief itself spells in its diff and report paths, `ab47eb9` or the
full forty hex for #101 and #102. It comes from `meta.json`, never from the sha.

**hard finding.** A numbered item under `## Would break` or `## Fails open` in a report. Nothing else
is a hard finding.

**label.** One line of `labels`, one historical hard finding that mattered: an Act-on item that was
fixed, or a `hole:` item that restarted the rounds. Fields, tab separated:
`round  axis  id  kind  min  anchors  title`. `kind` is `fix` or `hole`. `min` is how many anchors an
item must carry. `anchors` is a `;`-separated list of literal substrings. `title` is for people and
the scorer ignores it.

**anchor.** A literal substring matched case-insensitively against an item's **normalized text**:
the item's title and body lowercased, backticks and Markdown emphasis stripped, runs of whitespace
collapsed to one space.

**labeled hit.** A label some item carries at least `min` of the anchors of, under the one-to-one
matching below.

**matching.** Deterministic and one-to-one. Score every (item, label) pair by how many of the label's
anchors the item carries; drop pairs below the label's `min`; take pairs in descending score, ties
broken by item number then by label id, and consume both sides. One item cannot claim two labels and
one label cannot be claimed twice.

**unlabeled hard finding.** A hard finding that claims no label. Counted and reported, never judged.
A re-finding of a historical Noted item lands here by construction.

**context failure.** A report the real pipeline would send back: no line matching
`^hard findings: [0-9]+$`, a count above the hard-item count, headings that are not the axis's
contract headings in order, items not numbered 1..N in document order, or an empty report. The
predicate is `review-comment.sh`'s report-side refusal set and nothing more. A context failure is
never a zero.

**run.** One dispatch of one brief to one model. Its **runid** is
`<round>.<axis>.<model-slug>.<k>`, readable because only the harness sees it. `k` is the
**replicate**, from 1.

**sandbox.** `$TMPDIR/review-runs/<sandbox-id>/`, with `<sandbox-id>` the first eight hex of a hash of
the runid. It holds the tree at the reviewed head, `.scratch/review/<review-dir-id>/diff`, and
`prompt.md`. It is the only thing the reviewer sees. No path, file name or byte inside it names a
model, a replicate, a round, or this measurement.

**prompt.** `prompt.md` inside the sandbox: a three-sentence preamble naming the sandbox root as the
working directory and saying every relative path below resolves inside it, then the brief's bytes
unchanged. The brief is never edited.

**run directory.** `.scratch/eval/reviewer/runs/<runid>/`, holding `launch.json`, `report.md`,
`receipt.json`, `score.json` and, for Codex, `pstack-receipt.json` verbatim. Never committed.

**receipt.** One normalized JSON object per run, every field derived from the provider's own
artifact: the pstack receipt for Codex, the subagent JSONL for Claude. Fields: `status`,
`reportedModel`, `modelVerified`, `inputTokens`, `cachedInputTokens`, `cacheCreationInputTokens`,
`outputTokens`, `reasoningTokens`, `startedAt`, `completedAt`, `elapsedMs`, `source`.

**dropout.** A model with no runs: `dropouts/<model>.json`, carrying the provider's refusal receipt
when one exists and `status: withheld` with the reason when the model was never launched.

**recall.** Pooled over a model's runs: labeled hits divided by labels offered. A brief with an empty
`labels` offers none and contributes only to the unlabeled count.

**run-to-run noise.** For replicate `k`, the model's recall computed over the whole set using only
each brief's `k`-th run. Noise is the spread of those N values, reported as max minus min and as the
sample standard deviation. Secondary: a paired bootstrap over briefs at a fixed seed, deterministic
and rerunnable.

---

## 3. Test list

`tests/eval/reviewer/checks.sh`, one assertion per cell, in the order the cells are written. Each
names the fixture state it needs. Fixture states are tiny synthetic round directories under a temp
tree, plus two real ones copied from `rounds/`; a fake `pstack-runner` on `PATH` plays Codex.

1. **1/one brief.** A synthetic round, a Codex descriptor, fake runner returning a good report, `N=2`: two run dirs, `score.json` present, exit 0.
2. **1/a round.** Same fixture with `both`: four run dirs, exit 0.
3. **1/the whole set.** Two synthetic rounds, `all`, `N=1`: four run dirs, exit 0.
4. **1/a stored run.** Re-collect a complete Codex run: same `score.json` bytes, exit 0.
5. **2/one brief.** A Claude descriptor: no report written, `prompt.md` and `launch.json` present, one launch line per run, exit 20.
6. **2/a round.** `both`: 2N launch lines, exit 20.
7. **2/the whole set.** `all`: 24N launch lines against the real `rounds/`, exit 20, and no provider called.
8. **2/a stored run.** Two prepared Claude runs, a report planted for one, a stub transcript for it: `ran: 1`, the other left alone, exit 0.
9. **3/one brief.** Model `claude:nope`: exit 2, stderr names the descriptor table, no sandbox created.
10. **3/a round.** Same, exit 2, nothing written.
11. **3/the whole set.** Same, exit 2, nothing written.
12. **4/one brief.** Round `pr77-r9`: exit 2, stderr lists the real round ids.
13. **4/a round.** Same id with `both`: exit 2.
14. **4/a stored run.** `collect.sh pr94-r1.standards.claude-opus.9` with no such dir: exit 2.
15. **5/one brief.** `N=0` and `N=two`: exit 2 each, message quotes the value.
16. **5/a round.** `N=-1`: exit 2.
17. **5/the whole set.** `N=0`: exit 2.
18. **6/one brief.** A round whose `refs/keep/103/<sha>` is deleted: exit 2, message names the ref, no sandbox.
19. **6/a round.** Same, exit 2.
20. **6/the whole set.** Two rounds, the second's ref deleted: exit 2 and *no* sandbox for the first, proving heads are resolved before any dispatch.
21. **7/one brief.** `labels` removed: exit 2. Then `labels` truncated to zero bytes: exit 0 and the round runs, proving empty is legal.
22. **7/a round.** `meta.json` removed: exit 2.
23. **7/the whole set.** One round missing `diff`: exit 2 before any dispatch.
24. **7/a stored run.** A run dir whose round lost its `labels`: `collect.sh` exits 2.
25. **8/one brief.** Run `N=1` twice: two run dirs, replicates 1 and 2, the first unchanged. Then `--replicate 1`: exit 2.
26. **8/a round.** Same shape with `both`.
27. **8/the whole set.** A crashed set half-written, rerun: no run dir is overwritten.
28. **8/a stored run.** Collect twice: identical bytes both times.
29. **9/one brief.** Fake runner exits with an `unavailable-model` receipt: the receipt is kept, `score.json` says `dropout`, exit 0, and the tool's message is on stderr verbatim.
30. **9/a round.** The second brief is not attempted after the first refusal, exit 0.
31. **9/the whole set.** The set stops at the first refusal, exit 0.
32. **10/one brief.** Fake runner returns `unauthenticated`: receipt kept, `scored: dropout`, exit 0.
33. **10/a round.** Same, exit 0.
34. **10/the whole set.** Same, exit 0.
35. **11/a stored run.** A prepared Claude run with no report: exit 21, stderr names the report path, the run dir unchanged.
36. **12/a stored run.** Report present, no transcript matching the sandbox id: `scored: no-receipt`, exit 0, and `table.py` excludes it from the means while counting it.
37. **13/a stored run.** Two stub `.meta.json` files with the same description: exit 2, both paths printed.
38. **14/one brief.** Fake runner returns a report with no count line; then an empty file; then a report cut mid-item: `scored: context-failure` all three, exit 0.
39. **14/a round, 14/the whole set, 14/a stored run.** The same malformed report through each input shape gives the same `score.json` status, proving the predicate lives in one place.
40. **15/one brief.** `hard findings: 5` over two hard items: `context-failure`. `hard findings: 1` over two hard items: `complete`. Headings reordered: `context-failure`.
41. **15/drift.** Every malformed report in the fixture is fed to `review-comment.sh` in a temp review dir and to `score.py`; the accept/reject verdicts agree item for item. This is the lint that keeps the two from drifting.
42. **16/one brief.** A report whose single item carries the anchors of two labels: one hit, one miss, and no double count. A report with two items over one label: one hit, one unlabeled.
43. **16/anchors are real.** For every label in `rounds/*/labels`, the historical report for that round and axis matches it, and matches no other label in that round. A label whose anchors do not find their own item is a fixture bug and fails here.
44. **16/blinding.** Every byte under the sandbox and every path in it is grepped for `eval`, `test`, `judge`, `score`, `benchmark`, `candidate`, `experiment`, `rubric`, `compare`, `arena`, and for each model slug; a hit fails. The rule is an assertion, not a paragraph.
45. **17/one brief.** `TMPDIR` pointed at a read-only directory: exit 2, message names the root, nothing under `.scratch/eval/`.
46. **17/a round, 17/the whole set.** Same, and no dispatch happened.
47. **18/one brief.** Fake runner returns `timed-out`: receipt kept, `scored: context-failure`, exit 0.
48. **18/a stored run.** `collect.sh --abandon` on a prepared run: `scored: context-failure`, exit 0, idempotent on a second call.
49. **19.** `run.sh --dropout claude:fable "withheld by the operator's rule"`: `dropouts/claude-fable.json` with `status: withheld` and the reason verbatim, exit 0. With `--receipt FILE`, the file's JSON is carried into the dropout unchanged.
50. **Table.** `table.py` over a planted results tree reproduces a known table byte for byte, and rerunning `score.py` over the same `report.md` files reproduces every `score.json`. This is the reproducibility claim the ticket asks for, asserted.

---

## 4. Usage, the caller's view

### README

```
tests/eval/reviewer/ — the labeled reviewer set and its runner.

  rounds/<round>/          the fixture: two briefs, the diff, meta.json, labels
  run.sh                   dispatch one brief, one round, or the set, N times, at one model
  collect.sh               turn a launched lane's report into a receipt and a score
  score.py                 report + labels -> score.json          (pure, rerunnable)
  table.py                 scores + receipts -> the per-model table (pure, rerunnable)
  checks.sh                one assertion per cell of the scenario table

Results land under .scratch/eval/reviewer/ and are not committed.
A Codex model runs itself. A Claude model cannot: run.sh prepares the lanes and prints them,
the session launches them, collect.sh harvests them.
```

### Call site 1, a Codex model over everything

```bash
$ tests/eval/reviewer/run.sh all codex:gpt-6-astra 3 --effort high --timeout 900
ran: 72
$ tests/eval/reviewer/table.py > .scratch/eval/reviewer/table.md
```

### Call site 2, a Claude model, launched by the session

```bash
$ tests/eval/reviewer/run.sh all claude:opus 3
launch pr94-r1.standards.claude-opus.1 tier-lower /tmp/review-runs/3f2a91cc/prompt.md /tmp/review-runs/3f2a91cc/.scratch/review/ab47eb9/standards-report.md
launch pr94-r1.spec.claude-opus.1      tier-lower /tmp/review-runs/9b1e0d47/prompt.md /tmp/review-runs/9b1e0d47/.scratch/review/ab47eb9/spec-report.md
...
prepared: 72
```

The session launches a bounded batch, each lane with `subagent_type` from the line and the prompt
`Read /tmp/review-runs/<id>/prompt.md and do exactly what it says.` Nothing about the measurement
reaches the lane. It then polls:

```bash
$ tests/eval/reviewer/collect.sh $(cat .scratch/eval/reviewer/pending)
ran: 18
not ready: 6
```

### Call site 3, rebuilding the table from the raw reports alone

```bash
$ tests/eval/reviewer/score.py --all          # rewrites every score.json from report.md + labels
$ tests/eval/reviewer/table.py --noise
| model | runs | recall | unlabeled/brief | out tok | in tok | cache read | wall | fail |
...
noise (recall spread across replicates): claude:opus 0.04, codex:gpt-6-astra 0.07
```

### Call site 4, recording a model that never ran

```bash
$ tests/eval/reviewer/run.sh --dropout claude:fable "withheld by the operator's 2026-09-22 rule"
$ tests/eval/reviewer/run.sh --dropout codex:gpt-6-terra --receipt .scratch/probe/terra-receipt.json
```

---

## 5. Signatures

### `run.sh`

```bash
# run.sh <round-id|all> <standards|spec|both> <model> <N> [--replicate K] [--effort E] [--timeout S]
# run.sh --dropout <model> <reason> [--receipt FILE]
#
# Resolves the fixture and every reviewed head before touching a provider, builds one sandbox per
# run, then either dispatches (Codex) or prints a launch line (Claude). Exit 0 ran, 2 refused before
# any state, 20 prepared.

descriptor_row()  { :; }  # <model> -> "provider slug agent_type expected_revision"; refuses unknown
resolve_round()   { :; }  # <round-id> -> the round dir; refuses unknown or incomplete
resolve_head()    { :; }  # <round-id> -> sha; refuses when refs/keep/103/<sha> does not resolve
next_replicate()  { :; }  # <round> <axis> <model> -> the lowest free k
make_sandbox()    { :; }  # <runid> -> sandbox path: git archive | tar -x, place diff, write prompt.md
write_prompt()    { :; }  # <sandbox> <brief> -> prompt.md: preamble + brief bytes, unedited
dispatch_codex()  { :; }  # <runid> -> pstack-runner ...; keeps the receipt whatever the status
prepare_claude()  { :; }  # <runid> -> launch.json + one stdout line; never launches
record_dropout()  { :; }  # <model> <reason> [receipt] -> dropouts/<model>.json
```

### `collect.sh`

```bash
# collect.sh <runid>... [--abandon]
# Idempotent. For each runid: find the report in the sandbox, copy it to the run dir, build the
# receipt from the provider's artifact, call score.py. Exit 0 collected, 2 refused, 21 not ready.

find_transcript() { :; }  # <sandbox-id> -> the agent-*.jsonl whose .meta.json description matches;
                          # zero -> not ready, two -> refused
```

### `score.py`

```python
HARD = ("## Would break", "## Fails open")

class Item(NamedTuple):
    number: int; heading: str; title: str; body: str; norm: str

class Label(NamedTuple):
    round: str; axis: str; id: str; kind: str; min_anchors: int
    anchors: tuple[str, ...]; title: str

def parse_report(text: str, axis: str) -> Report | Failure:
    """Headings in contract order, items numbered 1..N, the count line. Any breach of
    review-comment.sh's report-side refusal set returns Failure(reason); nothing raises."""
    raise NotImplementedError

def load_labels(path: Path, round_id: str, axis: str) -> list[Label]:
    """Tab-separated; a malformed line is a fixture error and exits 2."""
    raise NotImplementedError

def match(items: list[Item], labels: list[Label]) -> tuple[dict[str, int], list[Item]]:
    """One-to-one, deterministic: (label id -> item number, unclaimed hard items).
    # TODO: score pairs by anchors carried, drop below min, consume in descending score,
    # ties by item number then label id."""
    raise NotImplementedError

def score(report_text: str, axis: str, labels: list[Label]) -> dict:
    """The score.json object: status, hits, misses, unlabeled, per-label verdicts, reason."""
    raise NotImplementedError
```

### `table.py`

```python
def load_runs(root: Path) -> list[Run]:
    """Every runs/*/ with a score.json; the receipt may be missing (status no-receipt)."""
    raise NotImplementedError

def per_model(runs: list[Run]) -> list[ModelRow]:
    """recall, unlabeled per brief, mean output, mean input with cache reads separate,
    mean wall clock, context failures, no-receipt count, run count."""
    raise NotImplementedError

def noise(runs: list[Run], model: str) -> Noise:
    """Recall computed per replicate over the whole set; spread and stdev of those N values."""
    raise NotImplementedError

def recommend(rows: list[ModelRow], noise: dict[str, Noise], axis: str) -> str:
    """The cheapest model whose recall is within the best model's noise of the best recall.
    Cheapest is mean output tokens, with mean wall clock as the tie-break."""
    raise NotImplementedError
```

---

## 6. Module map

```
tests/eval/reviewer/
  rounds/<round-id>/
    meta.json            pr, ticket, round, axis briefs present, fixed_point_as_typed,
                         review_dir_id, reviewed_head, head_ref, diff_inline, provenance
    standards-brief.md   byte-for-byte
    spec-brief.md        byte-for-byte
    diff                 the bytes the brief points at
    labels               tab-separated, may be empty, never absent
  run.sh                 bash. Placing files and calling tools.
  collect.sh             bash. Same.
  score.py               python3. Pure: (report bytes, labels) -> score.json.
  table.py               python3. Pure: (score.json + receipt.json)* -> markdown + noise.
  checks.sh              bash. One assertion per cell.
  build/                 one-time fixture building, not the runner. Never runs at run time.
    regenerate.sh        checks out a head, runs that head's review-brief.sh with a stubbed gh
    ticket-bodies/       the historical bodies recovered through userContentEdits
```

Bash where the work is placing files and calling tools, because that is what `tests/*/*.sh` already
does here and the ShellCheck gate already covers `tests/*/*.sh`. Python where the work is parsing
Markdown, matching strings and computing means, because that is what `tools/*.py` already does here
and the alternative is awk. Standard library only: `json`, `re`, `pathlib`, `statistics`, `hashlib`.

Three files from input to output: `run.sh` places the sandbox, `collect.sh` harvests it, `score.py`
turns bytes into numbers. `table.py` is a fourth only because rebuilding the table without rerunning
anything is the ticket's reproducibility claim.

---

## 7. Rationale

### Problem

The ticket wants one number per model: does a cheaper reviewer still find the hard bugs? Three
constraints make the shape non-obvious. The Claude half of the matrix cannot be a shell call, because
the standalone CLI is not logged in, so the only Claude route is the parent session's `Agent` tool
and a launched lane's completion never comes back to its launcher. The reviewer must not know it is
being measured, and it reads a brief that names relative paths into a checkout, so the thing it sees
has to be a faithful-looking review directory with nothing of ours in it. And the reviewed heads are
pre-rebase commits that only survive because `refs/keep/103/*` pins them, so a run is only valid at a
head that still resolves. Everything else follows from those three.

### Usage

Written in section 4 before the types. The four call sites are the whole public surface: run a model
over the set, launch and poll the Claude half, rebuild the table from the reports alone, record a
model that never ran.

### Shape

The load-bearing decision is that **a run is a directory of bytes and every metric is a pure function
of it**. `report.md` and `receipt.json` are the raw record; `score.json` and the table are derived and
can be thrown away and rebuilt. That is single-source-of-truth applied to a measurement: the scorer is
rerunnable by construction, which is exactly what the ticket asks for, and no number in the final
table was ever computed by the shell.

The second decision is **the sandbox is a `git archive` extract, not a worktree**. Two hundred and
eighty-eight runs sharing one repository's `.git` is shared mutable state between concurrent actors,
and the brief tells every one of them to write to the same relative path. Per
separate-before-serializing-shared-state, the sharing is eliminated rather than serialized: each run
gets its own tree with no `.git` at all, so two lanes cannot collide however they are scheduled, and
`--skip-git-repo-check` means Codex does not care. The cost is a tar extract per run, which is noise
beside a multi-minute review and is outside the clocked interval anyway.

The third decision is **the brief is never edited; a preamble carries the working directory**. The
ticket wants the briefs byte-for-byte, and the brief's relative paths would otherwise resolve against
a Claude lane's own cwd. A three-sentence preamble in front of unchanged bytes fixes that without
touching the fixture, and it is the same preamble for both providers, so nothing about the dispatch
differs in what the model reads.

The fourth is **the blinding rule is an assertion, not a paragraph**. The results tree is named
`.scratch/eval/reviewer/`, which a reviewer must never see, so the sandbox lives under `$TMPDIR` with
an opaque id, the transcript is found by that same opaque id rather than by a description naming the
model, and `checks.sh` greps the whole sandbox for the banned vocabulary and for every model slug.
Per encode-lessons-in-structure, the eval playbook's rule is enforced by a check rather than restated.

The fifth is **matching by anchors, not by a judge model**. `how.md` already wrote the anchor set for
every label as its `terms:` list, so the determinism is free, and a judge would add a second
non-deterministic model to a measurement whose whole point is reproducibility, plus 288 more runs to
pay for. The risk, a paraphrase the anchors miss, is bounded two ways: `min` of at least two anchors
keeps false matches down, and assertion 43 requires every label to match its own historical report
item and no other, so an anchor set that does not work is a failing test rather than a quiet
understatement of recall.

The sixth is **the context-failure predicate is `review-comment.sh`'s report-side refusal set and
nothing more**. That makes the metric mean something operationally: a context failure is exactly a
report the real pipeline would have sent back. The re-implementation could drift, so assertion 41
feeds the same malformed reports to both and requires the verdicts to agree.

Interface depth. The public surface is four verbs, and three of them are pure. `run.sh` hides
descriptor resolution, ref pinning, sandbox construction, prompt assembly, provider dispatch and
replicate allocation behind four positional arguments. The one asymmetry it does not hide is the
Claude launch, and it cannot: only the session can call `Agent`. Rather than pretend, exit 20 names
it, prints exactly what to launch, and hands the caller a poll loop. Validation is all at the front
of `run.sh`, which resolves every round and every head before a single sandbox exists, so a refusal
never leaves half a set behind; per boundary-discipline the two Python modules trust their inputs and
contain no guards.

What the system deliberately does not do: it does not call `gh`, it does not regenerate a brief, it
does not wait for a lane, it does not judge whether an unlabeled hard finding is real, and it does not
decide the recommendation on its own. It prints the noise number and the cheapest model inside it; a
person writes the DECISIONS row.

### Synthesis decision

Left for arena.

### Tradeoffs accepted

- We accept anchors that can miss a paraphrase in exchange for a scorer with no model in it, so the table rebuilds from the raw reports at any time.
- We accept a tar extract per run in exchange for zero shared state between 288 concurrent writers.
- We accept a visible two-step for the Claude half (exit 20, then poll) in exchange for not pretending the shell can launch a subagent.
- We accept that recall is pooled across briefs, not per brief, in exchange for a denominator large enough to mean anything at nineteen or so labels.
- We accept `min` anchors as a per-label constant tuned once against the historical reports, rather than a similarity score, because a constant is inspectable in the fixture and a threshold is not.
- We accept four small files instead of one, because the two pure ones are the rerunnable half and mixing them into the shell would lose that.

### Alternatives considered

**A blinded judge model decides re-finding.** Hides more from the caller and reads paraphrases the
anchors miss. It loses because the ticket's own requirement is that the table be reproducible from the
raw reports, and a judge makes the table a function of a model's mood; it also needs its own blinding,
its own dropout handling, and roughly 288 more runs. If anchors prove too brittle during fixture
building, the judge comes back as a second opinion over the unmatched items only, never as the primary
rule.

**One worktree per reviewed head, shared by the runs at that head, with each run writing to its own
report file name.** Twelve extracts instead of 288, so faster. It loses on the brief: the brief names
the report path, so either the brief is edited, which breaks byte fidelity, or the runs collide. It
also puts 288 concurrent readers on one repository's `.git`.

**One Python program for everything, with bash nowhere.** Fewer moving parts and one language. It
loses on interface depth in the wrong direction: the orchestration is `git archive`, `tar`,
`pstack-runner` and `mktemp`, which is a shell's job here and is already covered by this repository's
ShellCheck gate, and it would drag subprocess plumbing into the one part of the system that is
currently pure.

**A single `run.sh` that also launches Claude lanes by writing a queue file some session drains.**
Tempting, because the public surface shrinks to one verb. It loses on shared state: a queue file is
one object two actors write, which is exactly the shape the design spent effort eliminating.

### Open questions and risks

1. The fixture cannot reach byte fidelity for the ticket body without a stubbed `gh` (how.md
   section 3). Is committing the historical bodies under `build/ticket-bodies/` and stubbing `gh`
   during fixture building acceptable, or should `review-brief.sh` gain a `--ticket-body FILE` flag
   on its own ticket first?
2. Four reviewed heads are inferred rather than read off an artifact. Should a round whose head is
   inferred carry `provenance: inferred` in `meta.json` and be reported as a separate line of the
   table, so a reader can see whether the conclusion survives without them?
3. Nineteen or so labels over twenty-four briefs is a small denominator. Is a recall difference of
   one label worth acting on, or should the recommendation require the cheaper model to be inside the
   noise on both axes separately as well as pooled?
4. N of 3 gives three recall values per model, from which the spread is a weak noise estimate. Is N
   of 5 on the two finalists, after a first pass at N of 3 across all four, the better spend?
5. Does a Claude lane's `.meta.json` description reach the lane's own context? The design assumes it
   does not, and uses the opaque sandbox id there anyway so the assumption costs nothing, but the
   blinding claim in assertion 44 is only as strong as that.

### Next implementation step

Write `score.py` and assertion 43 against the six surviving review directories, so the anchor sets in
`labels` are proven to find their own historical findings before any model is launched.
