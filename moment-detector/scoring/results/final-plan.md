# The final test, fixed before it runs

Written 2026-10-06, after every dev run and before any check touched the test split (140 clean messages in 17 session groups; ids hash to `714e488f27c7`).

## What runs, once

| Variant | Why it is here | Threshold at a 5% dev false-alarm target | At a 10% target |
|---|---|---|---|
| `slow-b` | Sonnet 5.5 at low effort, the agent's last reply and actions, the definition, a 1 to 10 score. Best on dev at the lowest usage among the Sonnet cells. | 5 | 4 |
| `olow-b` | Opus 5.5 at low effort, the same prompt. Caught 4.5 points more corrections on dev (interval 0 to +9), at twice the cost. | 6 | 5 |
| `snotes-b` | `slow-b` plus notes on where a checker goes wrong, written from `slow-b`'s dev errors. Its dev score is in-sample, so only the test can say whether the notes carry over. | 5 | 4 |
| `ship0` | The hook as it shipped (Haiku 4.5, the short working question, yes or no). Not a candidate; it shows on held-out messages what the change is worth. | 6 (its yes) | 6 |

Thresholds come from the dev curves in `stage1-dev.json` and `stage2-dev.json` (the lowest score whose dev false-alarm rate is at or under the target).

## How the choice is made

- Between `slow-b` and `olow-b`: Opus only if its recall at the 5% operating point is higher with an interval that excludes 0, and its false-alarm rate is not worse with an interval that excludes 0. Otherwise Sonnet, which uses half as much of the subscription per check and is the model more likely to stay current.
- `snotes-b` replaces `slow-b` only if its false-alarm rate is lower with an interval that excludes 0 and its recall is not lower with an interval that excludes 0.
- The hook ships the chosen variant at its 5% threshold.
- Any difference whose interval includes 0 is a tie. Two runs of the same variant on dev gave the same verdict on 293 of 299 messages, so gaps of about 2 points can come from the model alone.
