## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The `ref=` grammar is copied into both scripts.** The same eleven-token ERE now lives in `review-brief.sh` (for `cites:`) and `review-comment.sh` (for `spec:` and `hole:`). Duplicated Code: one edit has to land twice. The change already guards it — `tests/spec-review/review-brief.sh` compares the two lines and fails on drift — so this is a note, not a fix to make now; the shared-file extraction only pays off if a third caller appears.

```sh
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

2. **Rung 1 of the review ladder is one ~400-word paragraph.** `template/docs/agents/review-ladder.md:6` now carries CI ordering, the finding definition, blast radius, the three-round rule, Ask items, the whole design-hole definition and the stack rules in a single sentence run. `CODING_STANDARDS.md`, Markdown: "One Diátaxis mode per file" is still met, but the bullet has become reference material a reader has to scan linearly. If a later change touches this line, split the design-hole half into its own bullet.

```md
- **Rung 1 — spec-review.** After CI is green, the agent runs `spec-review` in a fresh context: ... A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a cell of the ticket's scenario table ... and the redesign is reviewed from round one. Fixes land on the PR that was reviewed, never on a PR above it.
```

Notes on what was checked and found clean: the `hole:` detection order (no-spec, then heading, then form, then word-for-word against the item's `spec:`) matches `SKILL.md` step 6 sentence for sentence; `holed()` excludes lines ending in `fixed:`/`ticket:` so no judgment item is subtracted twice from `act-on items:`; the restart slicer normalizes `\r` and trailing blanks before matching `$0 == "restart"` and re-derives comment boundaries from `raw[]`, so a CRLF comment from the web UI still restarts; every new pipeline that may legitimately match nothing (`grep -v`, `grep -c`) carries `|| true` under `set -euo pipefail`; the one new `# shellcheck disable=SC2016` carries its reason on the same line.

hard findings: 0
