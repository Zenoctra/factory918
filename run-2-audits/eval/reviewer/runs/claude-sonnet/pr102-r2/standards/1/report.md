## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated round-cap literal.** The `cap=3; [ "$round" -le 3 ] || cap=5` line is copied verbatim between `review-brief.sh` and `review-comment.sh`, joining the existing `fenced='...'` and `ref=` fragments already held together only by a test (`tests/spec-review/review-brief.sh`'s `fragment()` check) rather than a shared source. This is the same pattern the file already accepts elsewhere, so it is a judgment call, not a new smell, and is fixed only if a Would-break fix already touches this code.

```
+cap=3; [ "$round" -le 3 ] || cap=5
```

Nothing else in the diff breaches `CODING_STANDARDS.md`: `set -euo pipefail` and quoting are intact in both scripts, no `sed -i`/`date -d`/`readlink -f` portability traps were introduced, the one `# shellcheck disable=SC2016` carries its reason on the same line, and the round-gate logic in `review-brief.sh` (the `would-break fixed after <sha>` validation, the round-4/5 fixed-point checks, and the `--ticket` requirement) matches the prose added to `SKILL.md`, `DECISIONS.md` (P20), `docs/agents/ledger.md` and the Ticket/babysit playbooks word for word, including the round-one/round-two exception documented in `playbooks/ticket.md`'s "Would-break fix" section. `tests/spec-review/no-stale-wording.sh` was updated to catch the retired "at most three rounds" phrasing.

hard findings: 0
