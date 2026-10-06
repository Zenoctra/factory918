Split dev; precision at 39.5% corrections among all messages (34.3% among the clean ones).

| Variant | Thr | AUROC | Recall | Quiet recall | False alarms | On near misses | Precision | Invalid | Wall, median (p90) | Cost per check |
|---|---|---|---|---|---|---|---|---|---|---|
| slow-b | 6 | 0.973 [0.937, 0.993] | 91% [84%, 95%] | 74% [58%, 86%] | 3% [2%, 7%] | 6% [3%, 13%] | 95% [92%, 99%] | 0/598 | 1.75 s (2.58 s) | $0.0063 |
