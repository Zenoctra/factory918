# Paired replays of the moment detector

This is the last part of #174's question. The detector catches corrections (`../scoring/`). This folder asks whether the suggestion it delivers reaches the main model on real moments and changes its work, and what a false alarm costs. Real moments from Manuel's sessions are replayed through Claude Code with the hook live. In one arm the hook delivers its suggestion. In the other it runs in shadow mode: the same check, logged, with nothing delivered. A blind judge reads every run of both arms.

On 210 runs over 12 moments, the hook fired and delivered under replay every time it could. The suggestion changed one thing reliably. The main model said in its own words what was being corrected and what Manuel now meant: in 63 of 79 runs with delivery, against 23 of 78 without. It did not measurably change whether the work then went right. The main model took the suggestion on all 25 false alarms and declined only on one real correction. The placeholder suggestion is a restating step, so this measures the pipeline, not advice a capacity would give.

Workshop-only, like `../hook/`. Code and aggregate results are here. Everything that holds Manuel's words is in the main checkout's `.scratch/moment-detector/paired/`, which git ignores. That folder holds the moment list, the judge's criteria, the replays, the verdicts and the declines.

## Method

### Moments

Twelve messages from the labelled library (`../moments/`), all in this repository's sessions except m12, where the detector at its shipped setting fired. The aim was moments where delivery could change something, so most are corrections where Manuel then had to correct the original agent's answer again.

| Moment | Library id | Kind | Why it is here |
|---|---|---|---|
| m01 | `c0c3530f-fedfffbd` | correction | The replay trial's F1 moment: Manuel's anecdote turned into a rule 9 times in 20. He also had to correct the reply again. |
| m02 | `a7278fa9-c200222c` | correction | The next reply repeated the narrow fix he objected to. |
| m03 | `a7278fa9-db6e1191` | correction | The same session, one turn later. |
| m04 | `33656705-66ea4439` | correction | The next reply kept the design he had just disowned. |
| m05 | `48857ffb-7d0cb80b` | correction | The next proposal had the same flaw he pointed out. |
| m06 | `48857ffb-cbbc94e8` | correction | A quiet correction asked as a question, at the detector's threshold (score 6). |
| m07 | `862ce07d-0e90d8dd` | correction | The next plan overlooked the rule he raised. |
| m08 | `60fce290-6613540b` | correction | The original agent got this one right, so there is no room to improve. |
| m09 | `3f0f412b-abeda6ad` | correction | His premise was mistaken. The edits he objected to had not happened. |
| m10 | `48857ffb-764ace91` | false alarm | A worried question, detector score 9. |
| m11 | `c4adc431-542ac6e2` | false alarm | A question about how two reviews fit, score 6 to 7. |
| m12 | `15fd7ed0-c9c87851` | false alarm | A developer's claim passed on for checking, score 7 (the CRM repository). |

### Arms

Both arms run the real hook (`../hook/md.py`, the shipped `correction` moment) through `replay.py run --hooks`, so the detector reads the session and calls Opus 5.5 in both. They differ in one key in `moment.json`: `deliver` is `true` in one and `false` (shadow mode) in the other. The hook's suggestion arrives as `additionalContext`, as it would live. The main model is Opus 5.5 in both arms, at the effort the session had at the cut. Four moments came from Fable 5.1 sessions and continue on Opus 5.5.

Two things the hook needed under replay:

- A forked session writes its transcript only when its first message is recorded, after `UserPromptSubmit` has fired. The first probe's checks all skipped as "first message of the session". The hook now reads `$MD_TRANSCRIPT` when set, and the kit sets it to the copy the replay resumed from. That copy holds what the live hook read at that message. On m01 the slice matched the scoring step's `md.py case`, apart from where a rewritten path moved the 300-character cut of one tool call.
- The hook runs outside the replay's API proxy (`env -u ANTHROPIC_BASE_URL`) and logs to the run's folder.

Run folders are named `m01-p` and `m01-q`. The replayed model sees its working directory, so the names say nothing about the arms.

### Runs

Batch one ran 5 runs per arm per moment, 120 runs (`results/batch1.md`). The extension was written down before it ran (`results/extension-plan.md`). It added 15 runs per arm on m01 and 10 per arm on m05, m06 and m10, 90 runs, to test three hypotheses that batch one hinted at. Its tests use only the new runs. In all, 210 runs.

### Judge

For each moment, one blind pass reads every run of both arms, shuffled under random ids (`paired.py judge`), as `quick-tests/README.md` asks. The judge is Opus 5.5 at high effort, with no tools, in an empty box. The markers `(md-xxxxxx)` and `(md-xxxxxx declined: ...)` are stripped first, since only the delivering arm can write them. So is the arm's letter in the run folder's name, which appears in the paths a run's tool calls carry.

Each moment's criteria file was written from the record before any run was read. It holds what had happened, Manuel's message whole, and what he meant as the rest of the session shows it. The questions, answered yes, no or unclear per run:

- Corrections. `restates`: does the run say what is being corrected and what he now wants? `meaning_right`: does it act on what he meant? `repeats_failure`: does it make the mistake the original agent made next? On m01, also `anecdote_rule`, the F1 criterion.
- False alarms. `restates`: does it treat the message as a correction? `answers`: does it answer correctly? `derailed`: does it concede an error it did not make, or undo or redo work that was right?

The judge was also asked whether the runs fall into groups, without knowing that arms exist. Opus 5 answered the same packets as a second judge. A review of this code found that the first judging round left the folder letter in the tool-call paths, so a judge could have told the arms apart, though not which was which. Every moment was judged again after the fix, and all figures here come from that round. `results/batch1.md`, the report the extension was planned from, comes from the first round.

## Results

All counts are in `results/paired.md` and `results/paired.json`. Differences are Mantel-Haenszel risk differences, delivery minus shadow, stratified by moment. Intervals resample moments, then runs within each arm. P-values shuffle the arm labels within each moment.

### Did the hook fire and deliver under replay?

Yes. The hook ran on all 210 runs. The detector fired on 206. One check hit the 10 s timeout under 12 concurrent sessions, and two m06 checks scored 5. In the delivering arm, 104 of 105 runs got the suggestion. All 104 show it in the session's transcript as a `hook_additional_context` attachment, before the main model's first response. The hook took a median 2.24 s (90th percentile 2.92 s, maximum 10.0 s, the timeout) at $0.0125 a check.

### Uptake

| | Delivered | Taken (marker) | Declined | No marker |
|---|---|---|---|---|
| Corrections | 79 | 67 | 9 | 3 |
| False alarms | 25 | 25 | 0 | 0 |

The declines did not track whether the suggestion was right.

- All 9 were on m06, a real correction, with one reason in 9 wordings ("this is a question about what the two documents contain, not a correction of my last reply"). The gap Manuel suspected was real, and every run found it, so the premise of each decline was wrong. By outcome, 8 of the 9 runs then made the follow-on mistake, and the judge could not tell for the ninth. So did 4 of the 5 that took the suggestion (the fifth unclear), so declining did not change the outcome.
- On the false alarms, the main model wrote the marker every time, including on a message that was plainly a question.

The marker tracks the restatement it asks for, not the work. On corrections, the judge found a restatement in 63 of the 67 runs that wrote the marker. Those runs made the follow-on mistake about as often as shadow runs did (next section).

### What changed between the arms

| Question | With delivery | Shadow | Difference [95% interval] | p | Smallest difference these runs detect at 80% power |
|---|---|---|---|---|---|
| Corrections: restates | 63/79 | 23/78 | +49 points [+17, +80] | < 0.001 | 22 points |
| Corrections: meaning_right | 78/79 | 76/77 | 0 [-5, +6] | 1.0 | 14 |
| Corrections: repeats_failure | 58/78 | 62/79 | -4 [-15, +4] | 0.50 | 19 |
| m01: anecdote_rule | 6/20 | 9/20 | -15 [-45, +15] | 0.51 | 43 |
| False alarms: restates | 6/25 | 1/25 | +20 [0, +73] | 0.07 | 28 |
| False alarms: answers | 20/25 | 20/25 | 0 | 1.0 | 32 |
| False alarms: derailed | 8/25 | 6/25 | +8 [-7, +32] | 0.59 | 36 |

- **The restatement moved, and nothing downstream did.** Both arms understood the correction (`meaning_right` is at the ceiling). The mistake the original agent made next came back about as often with the suggestion as without. The second judge gives the same picture, +39 points on the restatement and -5 [-17, +5] on the follow-on mistake (p = 0.38).
- **The planned extension found nothing.** Each test counts new runs only. H1, m01's anecdote rule, 5/15 against 6/15 (one-sided p = 0.50). H2, m05 and m06's follow-on mistake, 17/20 against 17/19 (p = 0.50). H3, a derail on m10, 0/10 against 0/10. Batch one's hints were noise.
- **The blind judge did not sort runs by arm, except on m08.** Asked for groups without knowing the arms existed, it grouped the runs of 9 moments. On 8 of them the groups were no purer by arm than the same group sizes filled at random (p from 0.09 to 1.0). Those groups followed the substance of the work, such as which mechanisms a run listed and whether it added a rule. On m08 it split the runs exactly by arm (p = 0.008), for a reason outside the question. m08's topic is the monitor-model idea itself, and all five delivered runs wrote about the detector that had just fired, as a live instance of Manuel's idea. No run on any other moment mentioned it once the markers were stripped.
- **How sure.** These runs could detect a change of about 20 points in the follow-on mistake. They cannot see a change of 10 points or less, which would need about four times as many runs. On 6 of the 9 corrections, the follow-on mistake happened in every shadow run or in none (always on m01, m02, m06 and m07, never on m03 and m08). A restatement could only show an effect by turning a certainty around.

### What the false alarms cost

The answers did not change. On m10 and m11, every run in both arms answered correctly. m12's right answer needed a live API call, which replay blocks, so no run in either arm could check it, and its `answers` and `derailed` figures are the replay's, not the suggestion's.

The framing changed. With the suggestion, 6 of 25 runs took Manuel's question as a correction ("You're correcting my framing..."), against 1 of 25 without. The second judge gave +23 points, p = 0.01. On m10 the marker sentence often conceded that the previous summary "made it sound like more than that", while the answer stayed right.

Derailing was rare where it could be judged. The two judges agreed on 84% of `derailed` answers (kappa 0.62). On m10, one run with the suggestion committed to stopping and relaunching an investigation lane that its own answer said was intact (1 of 15, against 0 of 15). On m11, the primary judge counted 2 of 5 runs with the suggestion against 1 of 5 without, all for conceding a framing error that was not one. The second judge counted the same total in both arms. At the shipped false-alarm rate, 2 of 90 other messages, the detector seldom fires where it should not. For a capacity whose moments are rarer, more of what fires will be false alarms, and the main model will not filter them by declining.

### Cost and time

The main sessions cost $380 at API list price for 210 runs, about $1.81 a run, as subscription usage, not a bill. The judge passes cost about $35 over three rounds, and the detector checks $2.61. One Opus 5 judge pass was refused by a safeguard as a false positive and ran again. The runs took 296 run-minutes, at up to 12 concurrent sessions.

A resumed session's `total_cost_usd` can include what the original session had spent. On one session it carried $1,556 into every run. `replay.py` now records `run_cost_usd`, and `paired.py` subtracts the figure the stream reports before any turn.

## What the machinery should change before the capacities plug in

- **Do not rely on declines to filter false alarms.** The main model took every false-alarm suggestion, and it declined only a real correction, with a templated reason. A wrong suggestion has to be filtered by the detector's threshold, or cost little when it lands.
- **Drop the marker, or keep it for the log only.** It sits in the reply Manuel reads, it asks for a change in form, and taking it did not predict what the work did. Measure uptake with paired runs on outcomes, as here.
- **A capacity's suggestion should name the move that prevents the follow-on mistake, not a restatement.** A generic restating step changed the restatement and nothing measurable after it. It should then be tested on moments where that mistake happens in some runs and not others. Most of these moments were all-or-nothing.
- **A suggestion that describes itself can enter the work.** On m08, whose topic was the detector, every delivered run discussed the suggestion's own text. The capacities are about how agents write and read, so their suggestions will often touch the topic of the work. Keep what the suggestion says about itself to what the main model needs to act on it.
- **Shadow mode is useful beyond the control arm.** `deliver: false` logs what a capacity would have said, live, at no cost to the main model. A capacity can be calibrated in shadow before it delivers anything.
- **The first message after a fork or rewind reads no transcript.** The hook now logs it as "no transcript to read" rather than as a session's first message. Whether the desktop app's rewinds hit this is untested.
- **Watch the timeout under load.** 1 check in 210 hit 10 s with 12 sessions running, and nothing was delivered for it.

## What a replay is not

`../../quick-tests/replay/README.md` lists the general differences. These ones touched this run:

- No network. m12 could not be answered. Runs that tried to read or post on GitHub were refused, equally in both arms.
- Today's refs. On m09, both arms found that later commits had merged the branch.
- Background lanes from the original session are not running. On m10, several runs in both arms concluded the lane had died.
- The replay is prefill. The model is handed the whole history at once, and the monitor-models research note (section 1.2) reports that models treat prefilled dialogue as their own and resist changing its direction. Both arms share this, but it may lower how far any suggestion can move a run.

## Running it

```
python3 moment-detector/paired/paired.py kits                     # the two arms' hook kits, under $PAIRED_ROOT/kits
python3 moment-detector/paired/paired.py run m01 deliver -n 5     # one moment, one arm (and m01 shadow)
python3 moment-detector/paired/paired.py collect                  # runs.jsonl: check, delivery, uptake, cost per run
python3 moment-detector/paired/paired.py judge m01 [--model M]    # one blind pass over both arms of a moment
python3 moment-detector/paired/paired.py report                   # results/paired.md and .json
```

`$PAIRED_DATA` (default: the main checkout's `.scratch/moment-detector/paired/`) holds `moments.json`, the list of moments, and `criteria/<name>.md`, one file per moment with `# Context` and `# Questions`, each question a `- **key**:` line. Runs are made under `$PAIRED_ROOT` (default `/private/tmp/wsr`), a short neutral path outside the main checkout. Copy them into `.scratch/moment-detector/paired/replays/` afterwards, without the `repo/` clones, and set `PAIRED_ROOT` to that folder to collect or judge them again. Run one batch per folder at a time; `run` holds a lock. `replay.py selftest` printed PASS after the changes to `replay.py`. Every batch's seal check named only the CLI's bookkeeping and other batches' transcripts, which those batches moved.
