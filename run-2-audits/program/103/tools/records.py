"""Append the #103 records: the M0 section before "## Still open", the P103 Provisional row, two ledger lines."""
from pathlib import Path

wt = Path("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2")
section = Path("/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad/m0-section.md").read_text()

m0 = wt / "docs/M0-findings.md"
text = m0.read_text()
anchor = "\n## Still open\n"
assert text.count(anchor) == 1
m0.write_text(text.replace(anchor, "\n" + section + anchor))

row = (
    "| P103 | Which model runs each review axis | Both the Standards and the Spec reviewer run on Claude Opus 5.5 "
    "(the upper tier). Measured on 24 frozen briefs, N of at least 3 per brief (#103): its recall is inside the "
    "run-to-run noise of the best model on both axes (Standards 0.22 against Opus 5's 0.28, band 0.17 to 0.33; Spec "
    "0.19 against 0.38, band 0.14 to 0.57), and it is the cheapest in both measures the ticket names, 3.7K to 5.1K "
    "output tokens and 38 to 53 seconds a run against Opus 5's 11K to 15K and 145 to 199 seconds, with half the "
    "cache reads. Sonnet is neither cheaper nor better (12K to 14K output tokens, 150 to 168 seconds, recall 0.17 and "
    "0.24) and left its checkout in 15 of 86 runs. The models sheet is not edited here; the PR body proposes the change "
    "| The ticket's rule: the cheapest model whose recall is within the run-to-run noise of the best. The noise is wide "
    "(6 or 7 labels per axis), so the rule cannot separate the models; the point estimates favour Opus 5 on Spec, and "
    "two pooled Opus 5 runs reach 0.50 and 0.52 where two Opus 5.5 runs reach 0.28 and 0.24, so a second reviewer run "
    "buys more recall than a model change. Fable 5.1 was not measured (the operator's rule of 2026-09-22), and GPT-6 "
    "Terra and Sol are refused to this account. 2026-09-23. |"
)
dec = wt / "docs/knowledge/core/DECISIONS.md"
lines = dec.read_text().split("\n")
start = next(i for i, l in enumerate(lines) if l.startswith("## Provisional"))
end = start + 1
while end < len(lines) and not lines[end].startswith("## "):
    end += 1
last = max(i for i in range(start, end) if lines[i].startswith("| P"))
lines.insert(last + 1, row)
dec.write_text("\n".join(lines))

ledger = wt / "docs/agents/ledger.md"
ltext = ledger.read_text().rstrip("\n") + "\n"
ltext += ("2026-09-23 | Claude Opus 5.5 | as the #103 owner, launched 23 reviewer lanes in one message and hit the harness's "
          "20-subagent cap, which the sibling owners share, so their launches could fail meanwhile | batches of 8, and a "
          "cap the brief names\n")
ltext += ("2026-09-23 | Claude Opus 5.5 | as the #103 owner, started 72 Codex runs without checking the ChatGPT account's "
          "quota; 51 hit the usage limit and waited hours for the reset | a quota check before a sweep, and the runner "
          "reading a usage-limit error as retryable from the start\n")
ledger.write_text(ltext)
print("ok")
