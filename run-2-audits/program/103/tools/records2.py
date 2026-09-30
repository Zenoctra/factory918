"""Round-one fix [S3]: the astra run counts in the M0 section and the ledger line."""
from pathlib import Path

wt = Path("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2")
edits = {
    "docs/M0-findings.md": (
        "the other 51 are `usage-limit` dropouts, left out of every metric",
        "of the other 55 planned runs (24 briefs times 3), 51 are `usage-limit` dropouts, 2 were refused as "
        "`unauthenticated` during the same outage and 2 were not attempted after those, all left out of every metric",
    ),
    "docs/agents/ledger.md": (
        "started 72 Codex runs without checking the ChatGPT account's quota; 51 hit the usage limit",
        "planned 72 Codex runs without checking the ChatGPT account's quota; 17 completed, 51 hit the usage limit, "
        "2 were refused as unauthenticated in the same outage and 2 were never attempted",
    ),
}
for rel, (old, new) in edits.items():
    p = wt / rel
    t = p.read_text()
    assert t.count(old) == 1, rel
    p.write_text(t.replace(old, new))
print("ok")
