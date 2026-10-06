# Paired replays: results

## Per moment

| Moment | Label | Arm | Runs | Fired | Delivered | Reached transcript | Taken | Declined | No trace | anecdote_rule | answers | derailed | meaning_right | repeats_failure | restates |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m01 | correction | deliver | 20 | 20 | 20 | 20 | 17 | 0 | 3 | 6/20 |  |  | 20/20 | 20/20 | 17/20 |
| m01 | correction | shadow | 20 | 20 | 0 | 0 | 0 | 0 | 0 | 9/20 |  |  | 20/20 | 20/20 | 0/20 |
| m02 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 5/5 | 5/5 |
| m02 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 3/3 +2? | 5/5 | 3/3 +2? |
| m03 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 0/5 | 5/5 |
| m03 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 0/5 | 0/5 |
| m04 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 1/5 | 4/5 |
| m04 | correction | shadow | 5 | 4 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 1/5 | 0/5 |
| m05 | correction | deliver | 15 | 15 | 15 | 15 | 15 | 0 | 0 |  |  |  | 14/15 | 10/15 | 14/15 |
| m05 | correction | shadow | 15 | 15 | 0 | 0 | 0 | 0 | 0 |  |  |  | 15/15 | 13/15 | 15/15 |
| m06 | correction | deliver | 15 | 14 | 14 | 14 | 5 | 9 | 0 |  |  |  | 15/15 | 13/13 +2? | 4/15 |
| m06 | correction | shadow | 15 | 14 | 0 | 0 | 0 | 0 | 0 |  |  |  | 15/15 | 14/14 +1? | 0/15 |
| m07 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 4/4 +1? | 5/5 | 4/4 +1? |
| m07 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 4/4 +1? | 5/5 | 0/5 |
| m08 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 0/5 | 5/5 |
| m08 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 0/5 | 5/5 |
| m09 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 4/5 | 5/5 |
| m09 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 4/5 | 4/5 | 0/5 |
| m10 | false_alarm | deliver | 15 | 15 | 15 | 15 | 15 | 0 | 0 |  | 15/15 | 1/15 |  |  | 0/15 |
| m10 | false_alarm | shadow | 15 | 15 | 0 | 0 | 0 | 0 | 0 |  | 15/15 | 0/15 |  |  | 0/15 |
| m11 | false_alarm | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  | 5/5 | 2/5 |  |  | 3/5 |
| m11 | false_alarm | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  | 5/5 | 1/5 |  |  | 1/5 |
| m12 | false_alarm | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  | 0/5 | 5/5 |  |  | 3/5 |
| m12 | false_alarm | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  | 0/5 | 5/5 |  |  | 0/5 |

Judge columns are yes out of yes-or-no answers, with unclear answers counted after a plus. Fired counts the detector's verdict in both arms; the shadow arm logs it and delivers nothing.

## Pooled by arm (Mantel-Haenszel difference, deliver minus shadow, stratified by moment)

| Label | Question | Deliver yes | Shadow yes | Difference | 95% interval (moments, then runs, resampled) | Permutation p | Detectable at 80% power |
|---|---|---|---|---|---|---|---|
| correction | restates | 63/79 | 23/78 | +49 pts | [+17 pts, +80 pts] | 0.000 | +22 pts |
| correction | meaning_right | 78/79 | 76/77 | +0 pts | [-5 pts, +6 pts] | 1.000 | +14 pts |
| correction | repeats_failure | 58/78 | 62/79 | -4 pts | [-15 pts, +4 pts] | 0.501 | +19 pts |
| correction | anecdote_rule | 6/20 | 9/20 | -15 pts | [-45 pts, +15 pts] | 0.512 | +43 pts |
| false_alarm | restates | 6/25 | 1/25 | +20 pts | [+0 pts, +73 pts] | 0.066 | +28 pts |
| false_alarm | answers | 20/25 | 20/25 | +0 pts | [+0 pts, +0 pts] | 1.000 | +32 pts |
| false_alarm | derailed | 8/25 | 6/25 | +8 pts | [-7 pts, +32 pts] | 0.586 | +36 pts |

The interval resamples moments and then runs within each arm, which counts within-moment variation twice: it is conservative, and with three false-alarm moments it has few distinct resamples. The permutation p shuffles arm labels within each moment.

Good handling is `meaning_right` yes, `repeats_failure` and `anecdote_rule` no on corrections; `answers` yes and `derailed` no on false alarms. `restates` is the behaviour the suggestion asks for.

## Uptake where the suggestion was delivered

| Label | Delivered | Taken | Declined | No trace | Attachment missing |
|---|---|---|---|---|---|
| correction | 79 | 67 | 9 | 3 | 0 |
| false_alarm | 25 | 25 | 0 | 0 | 0 |

Judge's `restates` by uptake, delivered runs: declined with restates=no: 9, no_trace with restates=no: 3, taken with restates=no: 22, taken with restates=unclear: 1, taken with restates=yes: 69

## Cost and time

- deliver: 105 runs, main sessions $190.97, detector $1.309, hook median 2240 ms (max 6738), 154 run-minutes.
- shadow: 105 runs, main sessions $189.11, detector $1.304, hook median 2256 ms (max 10020), 141 run-minutes.

## Extension tests (new runs only; extension-plan.md)

| Test | Moments | Question | Deliver yes | Shadow yes | Difference | One-sided p |
|---|---|---|---|---|---|---|
| H1 | m01 | anecdote_rule (less with delivery) | 5/15 | 6/15 | -7 pts | 0.500 |
| H2 | m05, m06 | repeats_failure (less with delivery) | 17/20 | 17/19 | -5 pts | 0.497 |
| H3 | m10 | derailed (more with delivery) | 0/10 | 0/10 | +0 pts | 1.000 |

## Did the blind judge's grouping follow the arms?

For each moment the judge was asked whether the runs fall into distinct groups by how they respond. Purity is the share of grouped runs whose group's majority arm is their own arm. Chance is the mean purity when the arms are shuffled over the judge's groups, and p the share of shuffles at least as pure.

| Moment | Groups | Grouped runs | Purity | Chance | p |
|---|---|---|---|---|---|
| m01 | 2 | 40 | 0.57 | 0.56 | 0.510 |
| m02 | 2 | 10 | 0.70 | 0.59 | 0.444 |
| m03 | 0 | 0 | n/a | n/a | n/a |
| m04 | 2 | 10 | 0.50 | 0.59 | 1.000 |
| m05 | 4 | 30 | 0.67 | 0.60 | 0.134 |
| m06 | 2 | 30 | 0.53 | 0.55 | 1.000 |
| m07 | 0 | 0 | n/a | n/a | n/a |
| m08 | 2 | 10 | 1.00 | 0.64 | 0.008 |
| m09 | 3 | 10 | 0.80 | 0.68 | 0.284 |
| m10 | 4 | 30 | 0.70 | 0.62 | 0.093 |
| m11 | 2 | 10 | 0.70 | 0.61 | 0.525 |
| m12 | 0 | 0 | n/a | n/a | n/a |

## Agreement with a second judge (claude-opus-5, same packets)

| Question | Both answered yes/no | Agree | Cohen's kappa |
|---|---|---|---|
| anecdote_rule | 40 | 98% | 0.95 |
| answers | 50 | 100% | 1.00 |
| derailed | 50 | 84% | 0.62 |
| meaning_right | 155 | 99% | 0.00 |
| repeats_failure | 157 | 99% | 0.96 |
| restates | 193 | 98% | 0.97 |
