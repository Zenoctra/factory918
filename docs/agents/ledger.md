# Ledger

One line per time an agent surprised you: `YYYY-MM-DD | model | what it did | what you wanted`. Append only. Rules are promoted from here (`/reflect`), never invented ahead of it.

2026-09-16 | fable | committed the ADR-pin doctor check before reading its test result | run the test, then commit
2026-09-17 | fable | ran apply through the ~/.local/bin symlink and copied nothing, because BASH_SOURCE was the link | resolve the link; a check that template/ is reachable
2026-09-17 | fable | passed the user's absolute path straight to vp create --directory, which refuses it; every local test had used a relative name | test the command the way a user types it
2026-09-17 | fable | hid vp install failures behind || true, which cost three CI runs to find | report every failure a gate depends on
2026-09-17 | fable | put seven concerns in PR #2 | one concern per PR; a bootstrap is still one PR per concern
2026-09-17 | fable | recorded surprises in the findings file instead of the ledger it had just created | the ledger is the ledger
