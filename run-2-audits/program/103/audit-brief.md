# Matching review findings to known defects

You are matching code-review findings against a list of known defects. Read-only: read exactly one file, write exactly one file, run nothing else, launch no agents.

Input: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/103/audit/packet.md

It has one section per brief. Each section lists the known defects of that review round ("Labels of this round", ids like S1 or P3, each with the text of the finding that first reported it), then a set of reports, each under an opaque id (R followed by hex). Each report item is tagged `hard` (filed as a defect that breaks or fails open) or `other` (a standards note or a tidy-up), with its number.

For every report and every label of its section, decide:
- `hard <n>` when a hard item n of that report describes the same defect as the label: the same mechanism failing in the same place with the same consequence. Wording, file line numbers and depth do not matter; a finding that names the same broken behavior counts even if it proposes a different fix. A finding about a neighbouring but different failure does not count.
- `other <n>` when only a non-hard item n describes it.
- `no` otherwise.

Also, for every hard item that matches no label, write one line `extra <n> <yes|no>`, yes when you judge it a real defect a careful reviewer would want fixed, no when it is wrong, speculative or not a defect.

Write the result to exactly /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/103/audit/verdicts.tsv as tab-separated lines: `<report id>\t<label id or ->\t<verdict>` (for extra lines the label column is `-` and the verdict is `extra <n> <yes|no>`). One line per report and label, plus the extra lines. No header, no prose. Reply with only the output path.
