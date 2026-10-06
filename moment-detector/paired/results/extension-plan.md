# Extension plan

Written on 2026-10-06 after batch one (`batch1.md`), before any extension run started. Batch one is the primary result. The extension adds runs where batch one left a question that more runs of the same moment could settle. The moments were chosen after seeing batch one, so each test below uses only the new runs.

| Moment | Runs added per arm | Hypothesis | Batch one, deliver against shadow |
|---|---|---|---|
| m01 | 15 | H1. With the suggestion delivered, fewer runs turn Manuel's anecdote into a universal rule (`anecdote_rule` yes). | 1/5 against 3/5; the replay trial's base rate for this failure was 9/20 |
| m05, m06 | 10 each | H2. With the suggestion delivered, fewer runs repeat the follow-on failure (`repeats_failure` yes). | 3/5 against 5/5 on m05; 3/3 (2 unclear) against 5/5 on m06 |
| m10 | 10 | H3. On this false alarm, more runs derail with the suggestion delivered (`derailed` yes). | 1/5 against 0/5 |

Tests: a one-sided Fisher exact test for H1 and H3, and a one-sided permutation test stratified by moment for H2, on the new runs only, each at 0.05. Three tests are run and none is corrected for the others. Each moment's runs, old and new, are judged again in one blind pass, as the judging rule asks, and the tests read the verdicts on the new runs. The primary judge is Opus 5.5 at high effort, and Opus 5 answers the same packets.
