# Paired replays: results

## Per moment

| Moment | Label | Arm | Runs | Fired | Delivered | Reached transcript | Taken | Declined | No trace | anecdote_rule | answers | derailed | meaning_right | repeats_failure | restates |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m01 | correction | deliver | 5 | 5 | 5 | 5 | 3 | 0 | 2 | 1/5 |  |  | 5/5 | 5/5 | 3/5 |
| m01 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 | 3/5 |  |  | 5/5 | 5/5 | 0/5 |
| m02 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 5/5 | 5/5 |
| m02 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 5/5 | 5/5 |
| m03 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 0/5 | 5/5 |
| m03 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 0/5 | 2/5 |
| m04 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 1/5 | 4/5 |
| m04 | correction | shadow | 5 | 4 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 1/5 | 1/5 |
| m05 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 3/5 | 5/5 |
| m05 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 5/5 | 5/5 |
| m06 | correction | deliver | 5 | 5 | 5 | 5 | 2 | 3 | 0 |  |  |  | 5/5 | 3/3 +2? | 2/5 |
| m06 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 5/5 | 0/5 |
| m07 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 4/4 +1? | 5/5 | 3/3 +2? |
| m07 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 4/4 +1? | 5/5 | 0/5 |
| m08 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 0/5 | 5/5 |
| m08 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 5/5 | 0/5 | 5/5 |
| m09 | correction | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  |  |  | 5/5 | 5/5 | 5/5 |
| m09 | correction | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  |  |  | 4/5 | 4/5 | 0/5 |
| m10 | false_alarm | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  | 5/5 | 1/5 |  |  | 0/5 |
| m10 | false_alarm | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  | 5/5 | 0/5 |  |  | 0/5 |
| m11 | false_alarm | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  | 5/5 | 2/5 |  |  | 3/5 |
| m11 | false_alarm | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  | 5/5 | 1/5 |  |  | 1/5 |
| m12 | false_alarm | deliver | 5 | 5 | 5 | 5 | 5 | 0 | 0 |  | 0/5 | 5/5 |  |  | 3/5 |
| m12 | false_alarm | shadow | 5 | 5 | 0 | 0 | 0 | 0 | 0 |  | 0/5 | 5/5 |  |  | 0/5 |

Judge columns are yes out of yes-or-no answers, with unclear answers counted after a plus. Fired counts the detector's verdict in both arms; the shadow arm logs it and delivers nothing.

## Pooled by arm (Mantel-Haenszel difference, deliver minus shadow, stratified by moment)

| Label | Question | Deliver yes | Shadow yes | Difference | 95% interval (moments resampled) | Permutation p | Detectable at 80% power |
|---|---|---|---|---|---|---|---|
| correction | restates | 37/43 | 18/45 | +45 pts | [+20 pts, +72 pts] | 0.000 | +29 pts |
| correction | meaning_right | 44/44 | 43/44 | +2 pts | [+0 pts, +9 pts] | 1.000 | +18 pts |
| correction | repeats_failure | 27/43 | 30/45 | -2 pts | [-16 pts, +9 pts] | 1.000 | +29 pts |
| correction | anecdote_rule | 1/5 | 3/5 | -40 pts | [-100 pts, +20 pts] | 0.527 | +87 pts |
| false_alarm | restates | 6/15 | 1/15 | +33 pts | [+0 pts, +73 pts] | 0.062 | +43 pts |
| false_alarm | answers | 10/15 | 10/15 | +0 pts | [+0 pts, +0 pts] | 1.000 | +48 pts |
| false_alarm | derailed | 8/15 | 6/15 | +13 pts | [-7 pts, +40 pts] | 0.584 | +51 pts |

Good handling is `meaning_right` yes, `repeats_failure` and `anecdote_rule` no on corrections; `answers` yes and `derailed` no on false alarms. `restates` is the behaviour the suggestion asks for.

## Uptake where the suggestion was delivered

| Label | Delivered | Taken | Declined | No trace | Attachment missing |
|---|---|---|---|---|---|
| correction | 45 | 40 | 3 | 2 | 0 |
| false_alarm | 15 | 15 | 0 | 0 | 0 |

Judge's `restates` by uptake, delivered runs: declined with restates=no: 3, no_trace with restates=no: 2, taken with restates=no: 10, taken with restates=unclear: 2, taken with restates=yes: 43

## Cost and time

- deliver: 60 runs, main sessions $103.88, detector $0.758, hook median 2205 ms (max 6738), 84 run-minutes.
- shadow: 60 runs, main sessions $104.62, detector $0.753, hook median 2256 ms (max 10020), 78 run-minutes.

## Did the blind judge's grouping follow the arms?

For each moment the judge was asked whether the runs fall into distinct groups by how they respond. Purity is the share of grouped runs whose group's majority arm is their own arm (0.5 is chance for two even arms).

| Moment | Groups | Grouped runs | Purity |
|---|---|---|---|
| m01 | 2 | 10 | 0.7 |
| m02 | 2 | 10 | 0.7 |
| m03 | 0 | 0 | n/a |
| m04 | 2 | 10 | 0.5 |
| m05 | 2 | 10 | 0.7 |
| m06 | 3 | 10 | 0.7 |
| m07 | 0 | 0 | n/a |
| m08 | 2 | 10 | 1.0 |
| m09 | 3 | 10 | 0.8 |
| m10 | 3 | 10 | 0.6 |
| m11 | 2 | 10 | 0.7 |
| m12 | 2 | 10 | 0.7 |

## Agreement with a second judge (claude-opus-5, same packets)

| Question | Both answered yes/no | Agree | Cohen's kappa |
|---|---|---|---|
| anecdote_rule | 10 | 100% | 1.00 |
| answers | 30 | 100% | 1.00 |
| derailed | 30 | 70% | 0.37 |
| meaning_right | 88 | 99% | 0.00 |
| repeats_failure | 88 | 100% | 1.00 |
| restates | 112 | 96% | 0.93 |
