# Candidate A: the reviewer-model eval runner (#103)

## Problem

We re-run 24 frozen reviewer briefs (12 rounds × 2 axes) against several models, N ≥ 3 times each, then score each report against labels. The shape is not obvious for four reasons. First, the runner has two halves that cannot share one code path. The Claude half is launched by the owner session's `Agent` tool, and its completion and tokens are visible only in a subagent transcript. The Codex half is a shell call to `pstack-runner`, which writes a receipt. Second, each brief tells the reviewer to write to a fixed relative path (`.scratch/review/<id>/<axis>-report.md`) and to read `.scratch/review/<id>/diff`. So N parallel runs of one brief need N separate trees, or they write over each other. Third, blinding. A reviewer that can reach the owner repository can read `tests/eval/reviewer/labels`, and a git checkout at the reviewed head can read the later fix commits through `git log --all`. Fourth, the result table must be rebuilt from the raw reports by rerunning the scorer, which rules out a model judge as the source of truth.

Constraints carried in from grounding. Reviewed heads are pinned by local refs `refs/keep/103/*` and exist only in this machine's object store. Briefs are frozen, and no `gh` call happens at run time. `pstack-runner` refuses an existing output or receipt path, has no implicit timeout, and in `--mode read-only` cannot write the report the brief asks for. Codex `usage.inputTokens` is normalized from `input_tokens`. For OpenAI that count includes cached tokens, while Claude's `input_tokens` excludes them. A Claude transcript's `assistant` lines carry `.message.usage`, `.requestId`, `.message.stop_reason` and a top-level `.timestamp`. In the transcript read on 2026-09-22, the final `assistant` line has `stop_reason: end_turn` and is followed by `attachment` lines. The models sheet gives the standards reviewer `opus@medium`, so external runs use effort `medium`.

## Scenario table: the runner's refusals and results

Situations go down the side. The input shape runs across the top: the verb and the kind of model it names. External runs are collected inside `run`, so the `collect` column concerns native runs.

| # | Situation | `run` native model (`claude:sonnet`, `claude:opus-5`, `claude:opus-5.5`) | `run` external model (`codex:*`) | `run` withheld model (`claude:fable-5.1`) | `collect` | `table` |
|---|---|---|---|---|---|---|
| 1 | Fresh: fixture set valid, no run directory for this model and brief | PREP. One launch line per run k=1..N. Exit 0. Launch each line with `Agent` in the background, then poll `collect`. | PREP, then DISPATCH and COLLECT each k in turn. One score line per run. Exit 0. Go to the next brief or `table`. | DROP for k=1 with status `withheld` and the rule as reason. Prints `dropout <run> withheld: <reason>`. Exit 0. Nothing further. | Summary `collected 0 · in flight 0 · unlaunched 0 · stuck 0`. Exit 0. | row 21 |
| 2 | Unknown model descriptor | ARGP (invalid choice, lists the known descriptors). Exit 2. Pick a listed descriptor. | same as native | same as native | — | — |
| 3 | Unknown brief id | ARGP (invalid choice, lists the 24 ids). Exit 2. Fix the id. | same | same | — | — |
| 4 | N is not an integer, or N < 1 | ARGP for a non-integer. For N < 1, `argument N: must be at least 1`. Exit 2. Pass N ≥ 1. | same | same | — | — |
| 5 | Reviewed head absent from the object store | REFUSE `round <r> head <sha> is not in this repository's objects; the fixture pins it as refs/keep/103/<short>`. Exit 1. Restore the ref or run on the machine that holds it. | same as native | Not checked, because nothing launches. Same as row 1. | — | — |
| 6 | Run k already collected (the output exists) | SKIP. Prints `collected <run>`, no launch line. Runs up to N are still prepared. Exit 0. | SKIP, same line. Exit 0. | SKIP. Prints `dropout <run>`. Exit 0. | Not re-read. Counted in `collected`. Exit 0. | Included. |
| 7 | External run prepared but has no receipt (crashed, or another `run` holds it) | — | REFUSE before any work: `<dir> was prepared and has no receipt: a runner holds it or crashed; if none is running, remove <dir> and rerun`. Exit 1. Check `ps`, then remove the directory. | — | Listed as `stuck <run>`. Exit 0. | Excluded. Counted in `stuck`. |
| 8 | Native run prepared, never launched (no transcript carries its nonce) | Prints the launch line again. Exit 0. Launch it. | — | — | Prints the launch line again under `unlaunched`. Exit 0. Launch it. | Excluded. |
| 9 | Native run launched, not finished (a transcript is found, and its last `assistant` line has no `end_turn`) | No line, because the run is in flight. Exit 0. | — | — | Counted in `in flight`. Exit 0. Poll again. | Excluded. |
| 10 | Two transcripts carry one run's nonce | REFUSE `<run> has two transcripts <a> <b>: one prompt was launched twice; remove <dir> and rerun`. Exit 1. | — | — | Same REFUSE. Nothing collected. Exit 1. | — |
| 11 | Transcripts directory missing | REFUSE only when a native run is already prepared: `no transcripts at <path>; set REVIEWER_TRANSCRIPTS`. Exit 1. | — | — | Same REFUSE. Exit 1. | — |
| 12 | Provider cannot serve the model (`unavailable-model`, `unauthenticated`, `unavailable-cli`) | — | DROP for k with the pstack status and error. Prints `dropout <run> <status>: <error>`. Later k are not attempted. Exit 0. Next brief. | — | — | Model row reads `dropout <status>` with the receipt path. |
| 13 | Runner `timed-out`, `child-failed` or `malformed-output` | — | FAIL(`<status>`). Prints the score line. The next k still runs. Exit 0. | — | — | Counted in `context failures`. |
| 14 | Finished, but no report file at the brief's report path | — | FAIL(`no-report`) | — | FAIL(`no-report`) | Counted in `context failures`. |
| 15 | Report has no line matching `^hard findings: [0-9]+$` (truncated or omitted) | — | FAIL(`no-count-line`) | — | FAIL(`no-count-line`) | Counted in `context failures`. |
| 16 | `hard findings: N` exceeds the number of Would break plus Fails open items | — | FAIL(`count-exceeds-items`) | — | FAIL(`count-exceeds-items`) | Counted in `context failures`. |
| 17 | Report has neither a `## Would break` nor a `## Fails open` heading | — | FAIL(`no-hard-headings`) | — | FAIL(`no-hard-headings`) | Counted in `context failures`. |
| 18 | The served model does not match the descriptor's pin | — | Not detectable. Codex reports no model, so the receipt records `model_verified: false` (`pinned-argv`). | — | REFUSE `<run> was served <model>; <descriptor> pins <pattern>; the agent definition drifted: fix it, remove <dir>, rerun`. Nothing collected. Exit 1. | — |
| 19 | The transcript shows a tool call reaching outside the checkout | — | Not detectable, because the runner keeps no tool log (see Open questions). | — | TAINT. Collected with status `contaminated` and the offending calls listed. Exit 0. Run one more k to keep N valid. | Excluded from every metric. Counted in `contaminated`. |
| 20 | Fixture set malformed: bad `labels` line, a label naming an unknown brief, an anchor that fails to compile, a brief referencing a review file its round lacks, or a `round` file missing `head` | REFUSE `fixtures: <file>:<line>: <what>`. Exit 1. Fix the fixture. | same | same | same | same |
| 21 | Nothing collected yet | — | — | — | — | REFUSE `no collected runs under <out>`. Exit 1. Run something. Otherwise it writes `scores.tsv` and `table.md`, prints the table and exits 0. |

### Legend

- **PREP.** For each k, `os.mkdir` the run directory. It is atomic, so a second concurrent `run` on the same brief sees the directory and lands in row 7. Export the reviewed head's tree with `git archive <head> | tar -x` into a fresh checkout under `REVIEWER_WORK`. Copy the round's `review/` files into `<checkout>/<review dir>/`, leaving out the other axis's brief. Write `run.json` and `prompt.txt`. Nothing is written for any k until every refusal check has passed.
- **Launch line.** One JSON object per line on stdout: `{"run": <run dir>, "agent": {"subagent_type": ..., "model": ...}, "description": "Review <short-head> <axis>", "prompt": <prompt.txt text>}`.
- **DISPATCH.** `pstack-runner --parent claude --provider codex --model <slug> --effort medium --mode isolated-write --prompt <run>/prompt.txt --cwd <checkout> --output <run>/runner-output.md --receipt <run>/runner-receipt.json --timeout 1800`.
- **COLLECT.** Build `receipt.json` from the transcript (native) or `runner-receipt.json` (external). Copy the report from `<checkout>/<report relpath>` to `<run>/report.md` if it exists. Print the score line. Remove the checkout.
- **Score line.** `<run> recall <hits>/<labels> unlabeled <u> demoted <d> tokens in/out <i>/<o> wall <s>s`, or `<run> context-failure <reason>`.
- **DROP.** Write `receipt.json` with `status: dropout` and the evidence. Write no report.
- **FAIL(reason).** Collected, with `receipt.json` `status: complete` and a score whose `failure` is `reason`. It is a result, not an error, so the exit code is 0.
- **TAINT.** Collected with `receipt.json` `status: contaminated`. The report is kept for reading and never scored.
- **REFUSE.** Prints `reviewer: <msg>` on stderr. Exit 1. Writes nothing, because every state check runs before the first write.
- **ARGP.** argparse's own message and exit code 2. No code beyond `choices=` and one `type=` function.
- **—.** This input cannot reach this situation.

## Contract

- **Descriptor.** A key of `MODELS`: `claude:sonnet`, `claude:opus-5`, `claude:opus-5.5`, `claude:fable-5.1`, `codex:gpt-6-astra`, `codex:gpt-6-terra`, `codex:gpt-6-sol`. Each maps to one route. `Native(agent, expect)` holds the `Agent` arguments and a regex the transcript's `.message.model` must match. `External(slug, effort)` is the `pstack-runner` arguments. `Withheld(reason)` means never launched. Terra and Sol are `External`: their refusal is recorded from a real call (row 12), never assumed.
- **Brief id.** `<round>/<axis>`, for example `pr94-r1/standards`, where axis is `standards` or `spec`. Round ids are `pr94-r1 pr94-r2 pr94-r3 pr96-r1 pr96-r2 pr96-r3 pr99-r1 pr99-r1b pr99-r2 pr101-r1 pr102-r1 pr102-r2`.
- **Review dir, report relpath.** Parsed from the brief's own `Write your report to \`<path>\`` line, and never stored twice. The review dir is that path's parent.
- **Run.** `(descriptor, brief id, k)`, with k ≥ 1. Its directory is `<out>/runs/<model slug>/<round>/<axis>/<k>/`, where `<out>` is `REVIEWER_OUT` (default `.scratch/eval/reviewer`).
- **Run state.** Derived from the files present, never stored. No directory means absent. `run.json` without `receipt.json` means prepared: for a native run, unlaunched, in flight or finished per its transcript; for an external run, stuck. `receipt.json` present means collected, and the receipt's `status` is one of `complete`, `dropout` or `contaminated`.
- **Nonce.** 12 random hex characters per run. They name the checkout `REVIEWER_WORK/<nonce>/factory918` and appear in the prompt. The run's transcript is the one subagent transcript whose first `user` line's `.message.content` contains `<nonce>/factory918`.
- **Checkout.** A plain exported tree of the reviewed head with no `.git`, outside the owner repository (`REVIEWER_WORK` defaults to `${TMPDIR:-/tmp}/review-work`). The round's review files are copied into it. No path component contains a banned word (`eval test judge experiment rubric score compare benchmark candidate arena`). `prepare` asserts this for the checkout path and `prompt.txt`.
- **Prompt.** Identical for both routes, in the organic shape of `spec-review` step 4: ``Read `<checkout>/<review dir>/<axis>-brief.md` whole and follow it. You are working in `<checkout>`; every relative path in the brief is relative to it.``
- **Finished (native).** The transcript's last line of type `assistant` has `.message.stop_reason == "end_turn"`.
- **Transcripts directory.** `REVIEWER_TRANSCRIPTS`. It defaults to `~/.claude/projects/<encoded>/`, where `<encoded>` is the main checkout's absolute path with every character outside `A-Za-z0-9` replaced by `-`. Only `*/subagents/agent-*.jsonl` inside it is searched, never another project's directory.
- **Receipt** (`receipt.json`, our schema, version 1). The fields are `run`, `descriptor`, `route`, `status`, `detail` (the pstack status, the withheld reason, or the contamination evidence), `reported_model` (string or null), `model_verified`, `effort`, `tokens` {`input`, `cache_read`, `cache_write`, `output`} or null, `wall_ms` or null, and `source` (transcript or runner receipt path).
  - `tokens.input` is uncached input only. Native runs sum `input_tokens`. External runs use `inputTokens − cachedInputTokens`.
  - `cache_read` comes from `cache_read_input_tokens` or `cachedInputTokens`. `cache_write` comes from `cache_creation_input_tokens` or `cacheCreationInputTokens`, with 0 when absent.
  - Native usage is summed once per distinct `.requestId`, because several lines of one response can repeat the usage.
  - Native `wall_ms` is the last `.timestamp` minus the first. External `wall_ms` is `elapsedMs`.
- **Contaminated.** A native transcript is contaminated when any `tool_use` input to Read, Grep, Glob, Write or Edit names a path outside the checkout, when Grep or Glob has no path (which means the owner's cwd), or when a Bash command does not contain the checkout path.
- **Report item.** A line matching `^\d+\. ` and the lines after it, up to the next item or `## ` heading. The item is **hard** when its heading is `## Would break` or `## Fails open`. Its **normalized text** is lowercased, with backticks and asterisks removed and whitespace runs collapsed to one space.
- **Context failure.** One of `no-report`, `no-count-line`, `count-exceeds-items`, `no-hard-headings`, `timed-out`, `child-failed` or `malformed-output`. It is never a zero-finding report. `N` below the hard-item count is tolerated, as in `review-comment.sh:117`.
- **Label.** A `labels` line, tab-separated: `brief`, `id`, `kind`, `anchors`, `title`. `#` starts a comment line.
  - `id` is the historical report's item reference (`S3` or `P1`).
  - `kind` is `fixed` or `hole`.
  - `anchors` is one or more Python regexes separated by ` && `. A report item **matches** a label when every regex searches true in the item's normalized text. Each label carries at least two anchors, and at least one names the mechanism, not a path.
  - `title` is for people and is never matched.
  - A brief with no line in `labels` is an unlabeled brief and is still in the set.
- **Score** of one collected, uncontaminated run.
  - A **hit** is a label matched by at least one hard item.
  - A **demoted** label is matched only by non-hard items. It is reported and never counted as a hit.
  - An **unlabeled** item is a hard item that matches no label. A second hard item matching an already-hit label is a duplicate and is not unlabeled.
  - A context failure scores 0 hits and is excluded from the unlabeled mean, since there are no findings to count.
- **Recall** of a descriptor on an axis is total hits over total labels across its complete runs on that axis's briefs. **Replicate recall** is the same, restricted to runs with one k.
- **Noise band.** The best descriptor on an axis is the one with the highest recall. Its band is `[min_k, max_k]` of its replicate recalls. A descriptor is **within noise** when its recall is at least the best's `min_k`. `table` marks those rows. The cheapest one is written in prose and never computed, because the tool encodes no price.
- **Calibration.** A round may carry `review/<axis>-report.historical.md`. `check` scores it and requires every label of that brief to be hit by exactly the item whose number is the label's id, and by no other item.

## Test list

The file is `tests/eval/reviewer/refusals.sh`, in bash like `tests/spec-review/*.sh`. It builds a temp git repository with one commit and a temp fixture set with one round `r1`, whose briefs reference `.scratch/review/x/diff` and have one label line on `r1/standards`. A fake `pstack-runner` (`REVIEWER_RUNNER`) writes a report into `--cwd` and a receipt whose `status` comes from `FAKE_STATUS`. Hand-written transcripts live under a temp `REVIEWER_TRANSCRIPTS`. The test also sets `REVIEWER_OUT` and `REVIEWER_WORK`. Assertions follow cell order, and the script exits 1 on the first miss.

1. `run` native, fresh: exit 0, N launch lines that parse as JSON, and each prompt names its own checkout, which exists and holds the brief and `diff` but not the other axis's brief or `.git`.
2. `run` external, fresh: exit 0, N score lines, N `receipt.json` with `status: complete`, and the checkouts removed.
3. `run` withheld: exit 0, one `dropout … withheld:` line, one dropout receipt, no report.
4. `collect` with nothing prepared: exit 0 and the zero summary.
5. Unknown descriptor, for each `run` shape: exit 2, and stderr names `invalid choice`.
6. Unknown brief: exit 2, `invalid choice`.
7. `N=0` gives exit 2 and `must be at least 1`. `N=x` gives exit 2 and `invalid`.
8. Head absent, native: exit 1, the message names `refs/keep/103/`, and no run directory was created.
9. Head absent, external: the same as 8.
10. Head absent, withheld: exit 0 and a dropout receipt.
11. Collected k=1 then `run … 2`, native: `collected` for k=1, one launch line for k=2.
12. The same for external: k=1 skipped, k=2 dispatched once. The fake runner's call count is 1.
13. The same for withheld: `dropout` printed, and no second receipt.
14. `collect` after 11: k=1 counted in `collected` and its `receipt.json` unchanged (mtime).
15. Prepared external without receipt, then `run`: exit 1, the message names the directory, and the fake runner was never called.
16. `collect` with a stuck external run: exit 0, and `stuck <run>` is listed.
17. Native prepared, no transcript, `run` again: the same launch line reprinted, byte-identical.
18. The same state, `collect`: the launch line printed under `unlaunched`.
19. A transcript whose last `assistant` line is `tool_use`: `run` prints nothing for it.
20. The same state, `collect`: counted in `in flight`, and no receipt written.
21. Two transcripts carrying one nonce, `run`: exit 1, and the message names both.
22. The same state, `collect`: exit 1, and no receipt written for any run, including a finished sibling.
23. `REVIEWER_TRANSCRIPTS` missing with a prepared native run, `run`: exit 1.
24. The same state, `collect`: exit 1.
25. `FAKE_STATUS=unavailable-model`, N=3: exit 0, one dropout receipt carrying the error, fake runner call count 1.
26. `FAKE_STATUS=timed-out`: `context-failure timed-out`, and k=2 still dispatched.
27. External, the fake writes no report: `context-failure no-report`.
28. Native finished transcript, no report file: `context-failure no-report`.
29. External, report with no count line: `no-count-line`.
30. Native, the same: `no-count-line`.
31. External, `hard findings: 2` with one hard item: `count-exceeds-items`.
32. Native, the same.
33. External, report without both hard headings: `no-hard-headings`.
34. Native, the same.
35. External receipt: `model_verified: false`.
36. Native transcript `.message.model: claude-opus-5-5` under `claude:opus-5`: exit 1, and no receipt.
37. Native transcript with a Read of a path outside the checkout: `receipt.json` `status: contaminated`, and the offending path appears in `detail`.
38. Malformed fixture, one case per kind (bad column count, unknown brief, bad regex, a missing referenced review file, no `head`), for each of `run` native, `run` external, `run` withheld, `collect` and `table`: exit 1, and stderr begins `reviewer: fixtures:`.
39. `table` with nothing collected: exit 1.
40. `table` after 2, 11, 25, 26 and 37: exit 0, and `scores.tsv` has one row per complete run. A contaminated run is absent. The dropout model's row reads `dropout unavailable-model`. The failure is counted in `context failures`.

Scoring and receipt cells use the same fixtures with `table`, one assertion each.

41. A hard item matching the label gives recall 1/1 and unlabeled 0.
42. A matching item under `## Standards breaches` only gives recall 0/1 and demoted 1.
43. Two hard items matching one label give recall 1/1 and unlabeled 0.
44. A hard item matching nothing on the unlabeled `r1/spec` gives unlabeled 1.
45. A context failure on a labeled brief gives recall 0/1 and is left out of the unlabeled mean.
46. An external receipt with `inputTokens 1000, cachedInputTokens 600` gives `tokens.input 400, cache_read 600`.
47. A native transcript with two lines sharing one `requestId` has its usage counted once.
48. Native `wall_ms` equals the last timestamp minus the first.
49. Noise band: best replicate recalls 1.0, 0.5 and 1.0 give a band minimum of 0.5. A descriptor at 0.6 is marked within noise, and one at 0.4 is not.
50. `check` with a historical report whose item 2 matches label `S1`: exit 1, and the message names the mismatch.

## Usage (caller's view)

Written first. The README block goes at the top of `reviewer.py`:

```
python3 tests/eval/reviewer/reviewer.py check
    Validate the fixture set and calibrate labels against historical reports.
python3 tests/eval/reviewer/reviewer.py run <descriptor> <round>/<axis> <N>
    Ensure runs 1..N exist. External models are dispatched and scored here.
    Native models print one JSON launch line per run the session must launch.
    A withheld model gets a dropout receipt.
python3 tests/eval/reviewer/reviewer.py collect
    Collect every finished native run and print what is in flight or unlaunched.
    Safe to repeat.
python3 tests/eval/reviewer/reviewer.py table
    Rescore every collected report and write scores.tsv and table.md.
```

Call site 1 is the owner session, Claude half. It is polled and never blocks.

```
$ python3 tests/eval/reviewer/reviewer.py run claude:opus-5 pr96-r1/standards 3
{"run": ".scratch/eval/reviewer/runs/claude-opus-5/pr96-r1/standards/1", "agent": {"subagent_type": "tier-lower"}, "description": "Review 69bd412 standards", "prompt": "Read `/var/…/review-work/3f9c…/factory918/.scratch/review/ab47eb9/standards-brief.md` whole and follow it. You are working in `/var/…/factory918`; every relative path in the brief is relative to it."}
…two more lines…
```

The session passes each line's `agent`, `description` and `prompt` to `Agent` with `run_in_background: true`. Later:

```
$ python3 tests/eval/reviewer/reviewer.py collect
…/claude-opus-5/pr96-r1/standards/1 recall 1/1 unlabeled 0 demoted 0 tokens in/out 41/2210 wall 212s
…/claude-opus-5/pr96-r1/standards/2 context-failure no-count-line
collected 2 · in flight 1 · unlaunched 0 · stuck 0
```

Call site 2 is the Codex half. It is one blocking shell call, backgrounded by the owner per brief.

```
$ for b in $(python3 tests/eval/reviewer/reviewer.py check --list); do
    python3 tests/eval/reviewer/reviewer.py run codex:gpt-6-astra "$b" 3
  done
```

Call site 3 covers the dropouts and the result.

```
$ python3 tests/eval/reviewer/reviewer.py run codex:gpt-6-sol pr94-r1/standards 3
dropout …/codex-gpt-6-sol/pr94-r1/standards/1 unavailable-model: HTTP 400 not supported when using Codex with a ChatGPT account
$ python3 tests/eval/reviewer/reviewer.py run claude:fable-5.1 pr94-r1/standards 3
dropout …/claude-fable-5.1/pr94-r1/standards/1 withheld: operator rule 2026-09-22, Fable is not launched
$ python3 tests/eval/reviewer/reviewer.py table     # the markdown that goes into docs/M0-findings.md
```

`check --list` prints the 24 brief ids, one per line. It is the only listing verb.

## Shape

### Fixture set (committed)

```
tests/eval/reviewer/
  reviewer.py                 CLI and all logic, python3 stdlib only
  refusals.sh                 one assertion per cell above
  labels                      TSV, the only label source
  rounds/<round>/
    round                     key=value: pr, ticket, label (as posted), head (40-hex), head_source (recorded|inferred|recovered)
    review/                   copied verbatim into <checkout>/<review dir>/
      standards-brief.md      byte-for-byte as review-brief.sh produced or reproduces it
      spec-brief.md
      diff                    what `.scratch/review/<id>/diff` held
      <axis>-report.historical.md   optional; only for the six surviving rounds; used by `check`
```

An example `labels` line:

```
pr96-r1/standards	S1	fixed	for f in \$g|unmatched|matches nothing && exit(s)? 0|files checked|silent	One unmatched glob among several is dropped and the gate still exits 0
```

### Types and signatures (`reviewer.py`)

```python
Axis = Literal["standards", "spec"]
BANNED = ("eval", "test", "judge", "experiment", "rubric", "score", "compare",
          "benchmark", "candidate", "arena")

@dataclass(frozen=True)
class BriefId:
    round: str
    axis: Axis
    @staticmethod
    def parse(s: str) -> "BriefId": raise NotImplementedError   # argparse type=; own message on a bad form

@dataclass(frozen=True)
class Brief:
    id: BriefId
    head: str                 # 40-hex, from rounds/<round>/round
    files: Path               # rounds/<round>/review
    report_relpath: PurePosixPath   # parsed from the brief's "Write your report to" line; review dir = parent

@dataclass(frozen=True)
class Label:
    brief: BriefId
    id: str                   # "S1" | "P3": the historical item number, which calibration checks
    kind: Literal["fixed", "hole"]
    anchors: tuple[re.Pattern[str], ...]   # len >= 2, all must search true

@dataclass(frozen=True)
class Fixtures:
    briefs: Mapping[BriefId, Brief]
    labels: Mapping[BriefId, tuple[Label, ...]]   # every brief is a key; unlabeled briefs map to ()

@dataclass(frozen=True)
class Native:   agent: Mapping[str, str]; expect: re.Pattern[str]
@dataclass(frozen=True)
class External: slug: str; effort: str
@dataclass(frozen=True)
class Withheld: reason: str
Route = Native | External | Withheld

MODELS: Mapping[str, Route] = {
    "claude:sonnet":     Native({"subagent_type": "general-purpose", "model": "sonnet"}, re.compile(r"^claude-sonnet-")),
    "claude:opus-5":     Native({"subagent_type": "tier-lower"}, re.compile(r"^claude-opus-5$")),
    "claude:opus-5.5":   Native({"subagent_type": "tier-upper"}, re.compile(r"^claude-opus-5-5$")),
    "claude:fable-5.1":  Withheld("operator rule 2026-09-22, Fable is not launched"),
    "codex:gpt-6-astra": External("gpt-6-astra", "medium"),
    "codex:gpt-6-terra": External("gpt-6-terra", "medium"),
    "codex:gpt-6-sol":   External("gpt-6-sol", "medium"),
}

@dataclass(frozen=True)
class RunId:
    descriptor: str; brief: BriefId; k: int
    def dir(self, out: Path) -> Path: raise NotImplementedError   # runs/<slug>/<round>/<axis>/<k>

@dataclass(frozen=True)
class Prepared:              # run.json
    run: RunId; nonce: str; checkout: Path; prompt: str

Status = Literal["complete", "dropout", "contaminated"]
@dataclass(frozen=True)
class Tokens: input: int; cache_read: int; cache_write: int; output: int
@dataclass(frozen=True)
class Receipt:               # receipt.json
    run: RunId; status: Status; detail: str
    reported_model: str | None; model_verified: bool; effort: str | None
    tokens: Tokens | None; wall_ms: int | None; source: Path

Failure = Literal["no-report", "no-count-line", "count-exceeds-items", "no-hard-headings",
                  "timed-out", "child-failed", "malformed-output"]
@dataclass(frozen=True)
class Item: n: int; hard: bool; text: str   # text normalized
@dataclass(frozen=True)
class Report: items: tuple[Item, ...]; count: int

@dataclass(frozen=True)
class Score:
    run: RunId; failure: Failure | None
    hits: frozenset[str]; demoted: frozenset[str]; unlabeled: int; labels: int

class Refusal(Exception): """stderr 'reviewer: <msg>', exit 1; raised before any write."""

# boundary: parse the committed files once; everything after trusts these types
def load_fixtures(root: Path, repo: Path) -> Fixtures: raise NotImplementedError
    # TODO: refuse on bad TSV, unknown brief, bad regex, < 2 anchors, missing head,
    #       a `.scratch/review/<id>/<f>` reference in a brief with no review/<f>

# pure core
def parse_report(text: str | None) -> Report | Failure: raise NotImplementedError
def score(run: RunId, parsed: Report | Failure, labels: tuple[Label, ...]) -> Score: raise NotImplementedError
def receipt_from_transcript(run: RunId, lines: list[dict], expect: re.Pattern[str], checkout: Path) -> Receipt: raise NotImplementedError
    # TODO: dedupe usage by requestId; wall = last - first timestamp; model mismatch -> Refusal;
    #       contamination -> status "contaminated", detail lists the calls
def receipt_from_runner(run: RunId, pstack: dict) -> Receipt | Failure: raise NotImplementedError
    # dropout statuses -> Receipt(status="dropout"); timed-out/child-failed/malformed-output -> Failure
def noise(scores: Iterable[Score], axis: Axis) -> Mapping[str, tuple[float, float, float]]: raise NotImplementedError
    # descriptor -> (recall, min_k, max_k)
def render_table(scores: list[Score], receipts: list[Receipt]) -> str: raise NotImplementedError

# shell: the only functions that touch git, the filesystem layout, or subprocesses
def progress(p: Prepared, transcripts: Path) -> Literal["unlaunched", "in-flight", "finished"]: raise NotImplementedError
def prepare(run: RunId, brief: Brief, work: Path, out: Path) -> Prepared: raise NotImplementedError
def dispatch(p: Prepared, route: External, runner: Path) -> dict: raise NotImplementedError
def collect_one(p: Prepared, receipt: Receipt | Failure, brief: Brief, fx: Fixtures) -> Score: raise NotImplementedError
def cmd_check(fx: Fixtures, list_only: bool) -> int: raise NotImplementedError
def cmd_run(fx: Fixtures, descriptor: str, brief: BriefId, n: int) -> int: raise NotImplementedError
def cmd_collect(fx: Fixtures) -> int: raise NotImplementedError
def cmd_table(fx: Fixtures) -> int: raise NotImplementedError
```

### Module map

There is one Python file, and a reader traces any question inside it. `load_fixtures` is the only parser of committed input, per boundary-discipline. `parse_report`, `score`, `receipt_from_*`, `noise` and `render_table` are pure and take text or dicts. The `cmd_*` functions and four shell helpers do the I/O. `refusals.sh` is the one test file. Environment knobs (`REVIEWER_FIXTURES`, `REVIEWER_OUT`, `REVIEWER_WORK`, `REVIEWER_TRANSCRIPTS`, `REVIEWER_RUNNER`, `REVIEWER_REPO`) exist so the test can point everything at temp state. Each has a default, so the owner types no flags.

### Load-bearing decisions

- **Python for everything, bash only for the test.** The work is JSON (receipts, transcripts), regex matching and aggregation. In bash that is jq plus awk, and it gets harder to test. The repository already has `tools/*.py` on stdlib. The test is bash so it runs beside the other `tests/*/*.sh` and goes through the same ShellCheck gate.
- **The run directory is the state machine, and its state is derived.** No status file exists. State is whichever of `run.json`, `receipt.json` and a transcript are present. Rerunning `run` or `collect` converges, per make-operations-idempotent. `os.mkdir` is the only cross-actor guard. Two `run` calls on one brief never both dispatch a k, per separate-before-serializing-shared-state.
- **One checkout per run, exported without `.git`, outside the repository.** This separates the fixed report path per run. It also removes the two leaks at once: the labels in the owner repository, and the later fix commits in the object store. The tree at the reviewed head is still there for "read the code around a hunk".
- **The transcript is found by the nonce in the prompt, not bound by hand.** The owner never has to paste an agent id back. The same lookup answers unlaunched, in flight and finished, so `collect` doubles as the poll. That is single source of truth.
- **Deterministic anchor labels, calibrated against history.** A label is reproducible, diffable and cheap to rerun. Its false-match risk is bounded by `check`: on every round with a surviving report, label `S<n>` must match item n and nothing else. `demoted` exposes the case where a cheaper model finds the bug but files it as a breach, which is the question the ticket is really asking.
- **The noise band is the best model's own replicate spread.** With roughly a dozen labels per axis, a bootstrap would produce confidence it does not have. "Within the run-to-run noise of the best" is read literally.
- **External effort is `medium`**, from the models sheet's reviewer row. Native effort is whatever the agent definition sets, recorded from the transcript's `.effort`.

## Synthesis decision

Filled in by arena.

## Tradeoffs accepted

- We accept hand-authored regex anchors, which can miss an oddly worded re-finding, in exchange for a table any reader can rebuild with one command. `demoted` and the unlabeled count keep the misses visible. The owner can read the unlabeled items of any model whose recall looks low.
- We accept that a contaminated Claude run is detected after the fact rather than prevented, in exchange for launching through the session's native `Agent` tool unchanged. The detector is conservative: a Bash call without the checkout path taints the run even when it was harmless.
- We accept an exported tree without git, which is less faithful than the historical reviewers' checkout, in exchange for no path to later commits. The brief says "Run nothing", so a faithful reviewer loses nothing.
- We accept that `run` for an external model blocks until its N runs finish, in exchange for no background process owned by the script. The owner backgrounds the shell call.
- We accept one Python file of perhaps 400 lines rather than a scorer module and a runner module. Every question is answered in one file.
- We accept that fixtures are reproducible only on a machine holding `refs/keep/103/*`. The CI-facing test builds its own repository, so CI is unaffected.

## Alternatives considered

- **A blinded judge model decides the matches, with verdicts cached per run.** It hides wording variance better. The cost is that the table depends on a second model's run-to-run noise, the verdict cache becomes a second source of truth beside the reports, and rerunning the scorer no longer reproduces the table from reports alone. It lost on the ticket's reproducibility requirement. It remains the right tool for a one-off audit of the unlabeled items.
- **`git worktree add --detach` per run, keyed by the reviewer's own relative paths.** It is simpler to build and faithful to history. The cost is that each reviewer can run `git log --all` into the fix commits, and 288 registered worktrees pile up in `.git/worktrees`. It lost on blinding.
- **Split verbs: `prepare`, `dispatch`, `bind <run> <agent-id>`, `status`, `collect`, `score`, `table`.** Each verb is trivial, so the interface is wide and shallow. The owner has to learn the protocol, and the hand-bound agent id duplicates what the transcript already says. It lost on interface depth. `run` and `collect` hide the route split and the state machine behind two idempotent verbs.

## Open questions and risks

1. For the six rounds with no surviving report, where does an Act on item's heading come from? The hard-only rule needs to know whether `[S2]` sat under `## Would break`. If the posted comment does not say, is that label dropped or kept with `head_source`-style provenance?
2. Codex runs cannot be audited for contamination, because `pstack-runner` keeps only the final message. Is the Codex sandbox, whose cwd is the exported checkout outside the repository, enough? Or should the runner persist its JSONL stream? That would be a change to vendored code and its own ticket.
3. `tier-lower` and `tier-upper` may carry a system prompt that `general-purpose` with `model: sonnet` does not. Should Sonnet run under a matching agent definition so the three Claude rows differ only by model?
4. Does Codex's `inputTokens` include `cachedInputTokens` on 0.154.0, as OpenAI's API does? Cell 46 pins the subtraction. One probe receipt with nonzero cache settles it before the runs start.
5. Does the rule "the final `assistant` line has `end_turn`" hold for every subagent that ends? It held on the one transcript read. If a lane dies mid-turn, it stays `in flight` forever. Should `collect` report runs in flight longer than an hour?
6. `tests/eval/reviewer/refusals.sh` sits three levels deep, and the ShellCheck glob in AGENTS.md is `tests/*/*.sh`. Should the glob gain `tests/*/*/*.sh`, or should the directory be `tests/eval-reviewer/`? The ticket names the path.
7. The Spec axis has few labels (about four). Its noise band will be wide enough to admit almost any model. Is a per-axis recommendation from four labels acceptable, or should the recommendation pool the axes and say so?

## Next implementation step

Write `refusals.sh` cells 1 to 4 and 41 to 45 against a `reviewer.py` whose `load_fixtures`, `parse_report` and `score` are filled in and whose other bodies still raise `NotImplementedError`. The scorer then exists and is proven before any run is launched.
