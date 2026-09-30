| model | axis | runs | context failures | recall | min_k | max_k | sd | within noise | demoted | unlabeled/brief | out tokens | in tokens | cache read | cache write | wall s | contaminated | usage limit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| claude:sonnet | standards | 35 | 0 | 3/18 (0.17) | 0.17 | 0.17 | 0.00 | no | 0 | 0.09 | 12192 | 16 | 668182 | 80567 | 150.6 | 10 | 0 |
| claude:sonnet | spec | 36 | 1 | 5/21 (0.24) | 0.33 | 0.33 | 0.00 | yes | 0 | 0.17 | 13553 | 19 | 893220 | 90520 | 168.2 | 5 | 0 |
| claude:opus-5 | standards | 36 | 0 | 5/18 (0.28) | 0.17 | 0.33 | 0.08 | no | 5 | 0.14 | 11310 | 21 | 880257 | 80765 | 145.1 | 3 | 0 |
| claude:opus-5 | spec | 36 | 0 | 8/21 (0.38) | 0.14 | 0.57 | 0.18 | yes | 0 | 0.36 | 15276 | 28 | 1387525 | 92837 | 198.9 | 0 | 0 |
| claude:opus-5.5 | standards | 36 | 0 | 4/18 (0.22) | 0.17 | 0.33 | 0.08 | no | 6 | 0.00 | 3673 | 13 | 430613 | 60283 | 38.2 | 0 | 0 |
| claude:opus-5.5 | spec | 36 | 0 | 4/21 (0.19) | 0.14 | 0.29 | 0.07 | yes | 0 | 0.08 | 5081 | 14 | 538776 | 72382 | 53.1 | 0 | 0 |
| codex:gpt-6-astra | standards | 22 | 0 | 7/16 (0.44) | 0.50 | 0.50 | 0.00 | no | 0 | 0.14 | 544 | 41094 | 130996 | 0 | 34.5 | 0 | 14 |
| codex:gpt-6-astra | spec | 13 | 1 | 2/16 (0.12) | 0.00 | 0.00 | 0.00 | no | 0 | 0.83 | 1275 | 37248 | 136384 | 0 | 52.1 | 0 | 23 |

| model | result | receipt |
| --- | --- | --- |
| claude:fable-5.1 | dropout withheld | /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer/runs/claude-fable-5.1/pr94-r1/spec/1/receipt.json |
| codex:gpt-6-terra | dropout unavailable-model | /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer/runs/codex-gpt-6-terra/pr94-r1/spec/1/runner-receipt.json |
| codex:gpt-6-sol | dropout unavailable-model | /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer/runs/codex-gpt-6-sol/pr94-r1/spec/1/runner-receipt.json |
