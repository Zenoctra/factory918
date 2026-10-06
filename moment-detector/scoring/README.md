# Scoring the moment detector

How well the hook in `../hook/` catches Manuel's corrections, and what each check costs, measured against the labelled library in `../moments/`. The hook now ships Manuel's choice, Sonnet 5.5 at low effort, reading the agent's last reply and actions, asked the definition in `question-definition.md`, firing at a score of 6 or more. On the 148 clean test messages under the labels after his third ruling it caught 35 of 36 corrections and flagged 3 of 112 other messages, at about 1.5 s and $0.007 a check. The labels it is scored against are mostly Opus 5.5's, applied under Manuel's rulings, plus his own verdicts where he gave them; the sections after "After the third ruling" were written under the labels before it and are kept as they were measured, with the choice of Opus that they led to. "After the third ruling" has what changed.

Workshop-only, like the hook. Everything that holds Manuel's words (cases, per-message runs, examples, error lists) is under the main checkout's `.scratch/moment-detector/scoring/`; this directory holds code and aggregate results only.

## Steps

```
python3 moment-detector/scoring/prepare.py                 # items, split, sessions (.scratch)
python3 moment-detector/scoring/run.py --list              # the variants in variants.json
python3 moment-detector/scoring/run.py slow-b olow-b --split dev [--reps 2] [--jobs 4]
python3 moment-detector/scoring/report.py slow-b olow-b --split dev [--compare slow-b:olow-b] [--write NAME]
python3 moment-detector/scoring/errors.py olow-b --split dev   # misses and false alarms, with the words (.scratch)
python3 moment-detector/scoring/report.py slow-b --split dev --items .scratch/.../items-r2.jsonl   # against another set of labels
python3 moment-detector/scoring/rescore.py --old items-r2.jsonl [--write NAME]   # saved runs against new labels, no model calls
python3 moment-detector/scoring/run.py snew-b --split dev --ids FILE   # only the listed items
```

- `prepare.py` builds one item per message in the library (a re-sent message counts once), marks whether the hook would call a model on it (`md.py`'s own gates), and stores the session as the hook would have read it there (`md.session_at`).
- `run.py` runs a variant through `md.make_case` and `md.check`, the functions the hook calls. A variant is a named list of `--set` overrides in `variants.json`. A rerun does only what is missing or failed. The test split refuses to run without `--final`.
- `report.py` puts every variant on one 0 to 10 scale (a yes or no answer maps through its stated confidence; a skipped or failed check scores 0), and reports each figure with an interval that treats the session group as the sampled unit.
- `stats.py` is the arithmetic: Wilson intervals at the effective sample size, AUROC, and resampling of whole session groups for everything else.

## After the third ruling

Manuel's reason for ruling 1 was not "declining a recommendation with a reason". A pushback is a correction when what he says shows the agent failed to understand him: his priorities, values or meaning. A reason that is only a preference is not. He also ruled on the held cases (`../moments/definition.md` records the rulings with no transcript text). The labels were rebuilt: 125 messages relabelled by Sonnet 5.5 under the rewritten rule, his verdicts on the held cases written as his own, two messages dropped as test data.

### The library now

The library holds 610 messages; folding re-sent copies leaves 598 and 500 of the 598 are clean (before: 466 of 600). Clean: 125 corrections (36 quiet) and 375 others (178 near misses), against 160 (49) and 306 (134) before. 98 are still unclear and wait for him. The split rule, salt and frozen test ids (`714e488f27c7`) are unchanged; both dropped messages were in dev, and no message changed split.

| Split | Clean messages | Session groups | Corrections (quiet) | Others (near misses) | Skipped by the hook | Unclear, held |
|---|---|---|---|---|---|---|
| dev | 352 | 29 | 89 (25) | 263 (128) | 30 | 66 |
| test | 148 | 16 | 36 (11) | 112 (49) | 17 | 32 |

Most of the 35 fewer corrections are pushbacks: of the 95 messages ruling 1 had reached, 50 stay corrections (29 of them now unclear), 44 were relabelled not corrections (one, an example Manuel had ruled on himself, stays a correction by his verdict) and one was already not. The 38 messages that the third-ruling labeller left unclear between answering and pushing back, and that no reading showed the agent failing to understand him on, were given his group verdict: not corrections. Four messages are flagged for him instead, because his own words state a priority or value the agent's plan missed; they are in `.scratch/moment-detector/moments/for-manuel-r3.md`.

### The saved predictions against the new labels, no new model calls

`rescore.py` scores the saved runs again, first run of each cell as in the stage 1 table, at threshold 6 (`results/r3-rescore.md` has every variant, the test finalists and the slice tables). Only messages with a saved prediction and a clean label under both sets can be compared; 41 dev and 18 test messages became clean and have no prediction from the old runs.

| Detector | Split | Recall before | Recall after | False alarms before | False alarms after |
|---|---|---|---|---|---|
| Opus 5.5 low (`olow-b`) | dev | 96% [91, 99] | 98% [92, 99] | 4% [2, 7] | 7% [4, 11] |
| Opus 5.5 low | test | 98% [89, 100] | 100% [90, 100] | 2% [1, 8] | 5% [2, 12] |
| Sonnet 5.5 low (`slow-b`) | dev | 92% [85, 96] | 92% [84, 96] | 5% [2, 9] | 8% [4, 14] |
| Sonnet 5.5 low | test | 90% [76, 96] | 94% [80, 99] | 1% [0, 6] | 3% [1, 9] |
| Haiku, original (`ship0`) | dev | 82% [71, 89] | 82% [67, 91] | 16% [12, 22] | 18% [14, 24] |
| Haiku, original | test | 88% [75, 95] | 92% [78, 97] | 11% [6, 19] | 13% [7, 21] |

Why it moved: on dev, 8 messages that were corrections are now not, and Sonnet and Opus fired on 7 of them, Haiku on 6; they became false alarms. On test, 4 flipped, and Opus fired on 3 of them, Sonnet and Haiku on 2. Fifteen dev and 10 test corrections became unclear and left the set; the detectors had caught nearly all of them (14 of 15 on dev for Opus and Sonnet, 10 and 9 of 10 on test), so leaving them out moves recall little. Nothing moved the other way. On the 311 dev messages clean under both sets, the new labels raise every cell's false-alarm rate by 1 to 3 points (the interval is above 0 for every cell but Haiku's slice a) and leave recall and AUROC within noise. The detectors score a pushback with a stated preference as a correction, as the definition they were given said to; the labels now say it is not.

### Did Haiku's changes track Sonnet's across the slices?

Mostly not. The table has each model's change from slice b (the agent's reply and actions) to the other three, on the 311 dev messages scored by all eight cells, threshold 6. Nine contrasts per label set; "same direction" counts those where both moved the same way, whether or not the interval excluded 0.

- Old labels: 5 of 9 in the same direction. Dropping the agent's prose (d) cut Haiku's false alarms by 6.0 points [-9.3, -2.1] and left Sonnet's up 0.9 [-1.1, +4.3]; the models differ by 6.9 points [-11.3, -3.4]. Adding the user's previous message (c) lifted Haiku's AUROC by 0.016 [-0.008, +0.035] and lowered Sonnet's by 0.009 [-0.019, -0.001]; they differ by 0.024 [+0.002, +0.041].
- New labels: 2 of 9 in the same direction, 2 where one was flat. Slice d cut Haiku's false alarms by 6.7 points [-10.0, -2.6] against Sonnet's +0.4 [-1.6, +3.8]; slice c lifted Haiku's AUROC by 0.018 [-0.006, +0.039] against Sonnet's -0.008 [-0.019, +0.002], a difference of 0.026 [+0.004, +0.042].
- Where they agree is small: slice a is slightly worse than b for both on AUROC (-0.004 to -0.014), inside the intervals except Sonnet's old -0.014 [-0.026, -0.001].

What the new labels do to each cell, though, is the same for both models: on the shared dev messages every Haiku and Sonnet cell gains 1 to 3 false-alarm points, moves by -0.4 to +2.8 points of recall and under 0.01 of AUROC. So the labels shift the two models together; what a slice choice does to them differs. A slice found best on Haiku says little about Sonnet.

### The shipped default, measured under the new definition

`moment.json` now names `claude-sonnet-5-5`, low effort, threshold 6, and `question-definition.md` carries the rewritten ruling 1 (the old text is `question-definition-r2.md`, which the older variants still point to). The variant `snew-b` measured it with 175 Sonnet checks: the 44 dev messages whose label changed that the hook would check (5 more were skipped by its gates), and the 131 test messages the hook would check. Nothing else ran again.

| On | Messages | Recall | False alarms | AUROC |
|---|---|---|---|---|
| Test, all clean (`snew-b`) | 148 (36 corrections, 112 others) | 35/36, 97% [83, 100] | 3/112, 3% [1, 8] | 0.991 [0.981, 1.000] |
| Dev, the messages whose label changed | 49 (2 corrections, 47 others) | 2/2 | 7/47 | not meaningful |

The test comparison with the old definition on the 130 messages both ran on (`results/r3-test-newdef.md`): `snew-b` over `slow-b` is AUROC +0.035 [+0.004, +0.097], recall +2.8 points [0, +10.0], false alarms -2.1 points [-4.9, 0]; one more correction caught, two fewer false alarms. Opus's number on the same 130 is recall 100% and false alarms 5%. The new definition did not cost recall and removed two false alarms on messages that were not corrections under the new labels. The test set has been scored twice now, and the rulings that changed its labels came after its errors had been read, so it no longer tests an untouched choice. On the dev messages that changed, the old definition fired on 7 of the 8 that flipped to not-corrections and the new fires on 3.

The three false alarms and the one miss on test: all three are messages Manuel ruled not corrections: a question about whether the agent had read a repository, a message giving the agent background on a developer's access, and a message that weighs the agent's proposal to drop a review lane. The miss, an overt correction of the agent's output, scored 4. At about 1.5 s median and $0.0068 a check, the default costs half of Opus's.


## What was frozen, and how

The library holds 612 messages. Folding re-sent copies leaves 600: 466 clean (160 corrections, 49 of them quiet; 306 others, 134 of them near misses) and 134 unclear ones that wait for Manuel's rulings.

Messages from one session share a task and a mood, and a forked or rewound session repeats the context of the one it came from. So the unit of the split is the session group: the sessions joined by re-sent messages, 53 sessions in 45 groups. A group goes to `test` when a salted hash of its key falls under 0.30. The salt (310) is the first, counting from 0, whose test split held 27 to 33% of the clean messages, the corrections, the quiet corrections, the near misses and the unclear messages. No prediction was looked at to choose it. Because the split is a rule over groups, a message Manuel rules on later joins the split its session is already in; `prepare.py` stops if the test ids ever hash to anything but `714e488f27c7`.

| Split | Clean messages | Session groups | Corrections (quiet) | Others (near misses) | Skipped by the hook | Unclear, held |
|---|---|---|---|---|---|---|
| dev | 326 | 28 | 110 (35) | 216 (96) | 27 | 94 |
| test | 140 | 17 | 50 (14) | 90 (38) | 16 | 40 |

The hook skips a session's first message, slash-command text as transcripts record it, and never sees an answer given through `AskUserQuestion`. Those messages count as not flagged, so every recall here is what the deployed hook would catch. Two dev corrections and one test correction are out of its reach this way.

The finalists, their thresholds and the rule for choosing among them were committed in `results/final-plan.md` before any check ran on the test split.

## What ran

Every dev cell ran once over the 299 dev messages the hook would check (two Sonnet checks that timed out at 60 s during a slow minute were rerun); 6,478 model calls in all, about $62 at API list price as the CLI reports it (the subscription bears it as usage). The thresholds and comparisons below are at 6 unless named.

1. **Model, reasoning and slice** (`results/stage1-dev.md`). Haiku 4.5 without thinking and Sonnet 5.5 at low effort, each on four slices: the message alone (a), the agent's last reply and actions (b), b plus the user's previous message (c), and the previous message and actions without the agent's prose (d). Then on slice b: Haiku with a 2,048-token thinking budget, Haiku writing a one-sentence reason before its score, Sonnet at medium and default (high) effort, and Opus 5.5 at low effort. And `ship0`, the hook as it first shipped.
2. **Definition and examples** (`results/stage2-dev.md`), on Sonnet low with slice b: the definition reworded; the word "correction" replaced by `MOMENT_A`; notes on where a checker goes wrong, written from Sonnet's dev errors; 24 balanced labelled examples drawn from other session groups (4-fold by group); and a yes or no answer in place of the score.
3. **Repeat** (`results/stage3-dev-slow-b-two-runs.md`): Sonnet low on slice b a second time.
4. **Test, once** (`results/final-test-5pct.md`, `results/final-test-10pct.md`): Sonnet low, Opus low, Sonnet low with the notes, and `ship0` for reference.

## Results

### On dev

| Variant | AUROC | Recall | Quiet recall | False alarms | On near misses | Median wall time |
|---|---|---|---|---|---|---|
| `ship0`: Haiku, first question, yes or no | 0.830 [0.784, 0.882] | 82% [71, 89] | 69% [52, 81] | 16% [12, 22] | 29% [21, 39] | 1.05 s |
| Haiku, slice b | 0.887 [0.845, 0.923] | 83% [73, 89] | 66% [48, 80] | 17% [12, 22] | 33% [25, 43] | 0.96 s |
| Haiku, slice b, thinking 2,048 | 0.933 [0.890, 0.966] | 94% [87, 97] | 83% [67, 92] | 20% [15, 27] | 36% [28, 46] | 6.20 s |
| Sonnet low, slice b | 0.971 [0.938, 0.991] | 92% [85, 96] | 77% [59, 89] | 5% [2, 9] | 9% [4, 20] | 1.80 s |
| Opus low, slice b | 0.977 [0.944, 0.997] | 96% [91, 99] | 91% [77, 97] | 4% [2, 7] | 8% [4, 16] | 1.96 s |

The model is the only axis that moved the result by more than the noise.

- Sonnet over Haiku on slice b: AUROC +0.084 [+0.055, +0.116], false alarms −12 points [−17, −7]. Real.
- Thinking raised Haiku's AUROC by 0.046 [+0.028, +0.060] (real) and its recall by 11 points, but left it flagging a fifth of other messages at 6 s a check.
- Haiku's written reason did not change its ranking (AUROC −0.006) and only made it fire more: recall +9, false alarms +11.
- Sonnet at low, medium and high effort tied (AUROC within 0.005; at low effort it writes about 16 output tokens, so it hardly thinks).
- Opus over Sonnet: recall +4.5 points [0, +9], false alarms −1 [−3, +3]; AUROC +0.006 [0, +0.012]. Borderline.
- Slices: for Sonnet, b beat a by 0.014, c by 0.009 and d by 0.023 in AUROC. The bootstrap calls these real, but none moved recall or false alarms beyond their intervals. Leaving out the agent's prose (d) was the worst, not the best.
- Every stage 2 change tied with plain Sonnet low: AUROC within 0.006, recall and false alarms within 2.5 points, every interval across 0. The examples cost four times as much per check. The neutral label lost nothing, so the model follows the definition, not the word. The notes cut false alarms from 5% to 2% on the very errors they were written from.
- Two runs of Sonnet low gave the same verdict on 293 of 299 messages and the same score on 249. Averaging them changed AUROC by 0.002.

### On test, once

At the thresholds fixed on dev for a 5% false-alarm target. Precision is at 39.5%, the share of corrections among all of Manuel's messages.

| Variant | Thr | AUROC | Recall | Quiet recall | False alarms | On near misses | Precision | Wall, median (p90) | Cost per check |
|---|---|---|---|---|---|---|---|---|---|
| Opus low, slice b | 6 | 0.981 [0.936, 1.000] | 49/50, 98% [89, 100] | 13/14 | 2/90, 2% [1, 8] | 2/38 | 97% [95, 100] | 1.98 s (2.87 s) | $0.0133 |
| Sonnet low, slice b | 5 | 0.959 [0.869, 0.999] | 45/50, 90% [76, 96] | 12/14 | 1/90, 1% [0, 6] | 1/38 | 98% [96, 100] | 1.60 s (2.25 s) | $0.0066 |
| Sonnet low with notes | 5 | 0.974 [0.930, 0.998] | 46/50, 92% [81, 97] | 12/14 | 0/90 | 0/38 | 100% | 1.62 s (2.39 s) | $0.0074 |
| `ship0` | 6 | 0.890 [0.827, 0.937] | 44/50, 88% [75, 95] | 11/14 | 10/90, 11% [6, 19] | 7/38 | 84% [75, 90] | 1.00 s (1.36 s) | $0.0022 |

- Opus caught 4 corrections Sonnet missed and none the other way: recall +8 points [+2, +21], real. Its false alarms were 1 point higher [0, +3], a tie. One of the four was Sonnet answering 96 on the 1 to 10 scale, which counts as invalid. The other three were kinds Manuel ruled to be corrections against the everyday reading: pushing back on a plan the agent proposed, and correcting earlier agents' work the agent was carrying forward. Sonnet scored them 3 or 4.
- The notes gave Sonnet 0 false alarms against 1, a tie [−2.5, 0]. Under the rule fixed beforehand they are not adopted.
- Sonnet low against `ship0`: false alarms −10 points [−18, −6], real; recall +2, a tie.
- With 17 session groups in the test split, these intervals are wide. The dev and test results point the same way for every finalist.

## The choice

Opus 5.5 at low effort, slice b, `question-definition.md`, a 1 to 10 score, threshold 6, prompt caching off, a 10 s timeout. It met the rule in `results/final-plan.md`: its recall advantage over Sonnet held with an interval above 0, and its false-alarm rate was not worse beyond the interval. The model is pinned as `claude-opus-5-5`, so the scores above stay attached to the model that earned them; the log records the model id of every check.

What it costs on every message the hook checks: a median of 1.98 s before the main model starts (90th percentile 2.9 s, 99th 5.7 s; two of 423 calls passed 10 s, one reaching 32 s during a slow minute, and the 10 s timeout now cuts such a call off with no suggestion), about 2,800 input tokens, and $0.013 at API list price. About one message in eleven is skipped without a call. Sonnet low would halve the cost and save 0.4 s at the price of the recall gap above; it is the fallback if Opus's usage or latency is too much.

Haiku 4.5 is out on accuracy at every setting. The monitor-prompts note also reports its retirement as "not sooner than October 15, 2026"; that date was not checked here.

## What it still misses and fires on

Across dev and test, Opus missed 5 of 160 corrections and flagged 10 of 306 other messages.

- Three of the misses are messages the hook never sees: two answers given through `AskUserQuestion` and one slash command's arguments. Of the corrections it could see, it missed 2 of 157.
- The other two misses were quiet: one where Manuel said he could not follow the agent's summary, and one pointed question about whether his words had been carried into the agent's tickets, where only what came after showed the gap was real.
- Six of the ten false alarms were worried questions ("did you...?", "did it get lost?") where the agent had not in fact erred. Under Manuel's ruling such a question is a correction only when the gap is real, and the labeller knew from what came after. The detector reads only what came before, so this is a floor set by the definition, not by the prompt. The other four were a question about how to proceed, a fact given to the agent, a colleague's claim passed on for checking, and a new request that opened with "don't make any changes".
- Six of the ten scored exactly 6, the threshold. On dev, a threshold of 7 cuts false alarms from 3.7% to 1.4% and recall from 96% to 92%. Which side of that trade the hook should sit on is Manuel's call; the default stays where the plan fixed it.

The examples are in `.scratch/moment-detector/scoring/errors/olow-b-dev.md` and `olow-b-test.md`.

## Where the monitor-prompts research held

- Held: the model mattered more than the prompt; Haiku 4.5 was weak and thinking recovered part of the gap; among reasonable prompts, wording, the label word, a few examples and the answer format made no difference; resampling Claude added nothing; about 470 labels could separate Haiku from Sonnet and not much below that.
- Did not hold: the library is not enriched. It is every message Manuel wrote in the period, so the deployment rate is measured, 34% among clean messages and 39.5% counting unclear ones by the labeller. A graded score did not beat yes or no for Sonnet (AUROC 0.971 against 0.965). Written reasoning did not help Haiku rank; it moved its threshold. Leaving out the agent's prose hurt rather than helped. Haiku gave no invalid answers with a short slice.
- Path facts: the hook's CLI path can set Haiku's thinking (through `MAX_THINKING_TOKENS`), Sonnet's and Opus's effort, the system prompt, and prompt caching. It cannot set temperature. Sonnet 5.5 always returns a thinking block, and effort did not matter here.

## What the next capacities should take from this

- Spend runs on the model and the slice; once the prompt carries the definition, more prompt work stays inside the noise.
- Write the moment so it can be judged from what came before. A ruling that turns on what happened next sets a false-alarm floor no detector can go under.
- Corrections are 34 to 40% of Manuel's messages. Later moments will be far rarer, and precision falls with the base rate: Opus's test rates at a 5% base rate would give a precision of about 70%.
- Three paths are out of the hook's reach: `AskUserQuestion` answers, slash-command arguments, and queued messages judged before the transcript catches up. A capacity whose moments arrive that way needs another hook.
- A library for each capacity should span more sessions; 17 test groups made every test interval wide.
- `prepare.py`, `run.py` and `report.py` assume the `correction` moment and its library; the next capacity should make the moment a parameter rather than copy them.
