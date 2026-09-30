# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Two checks numbered 17.** The new check is inserted between `17 a token under ## Diff ignored` and `18 two PRs in ascending number` and reuses the label `17`. The file's header says the calls run "in the order of the scenario table in the ticket's design", so the numbers are positional; two 17s make a miss ambiguous when the runner prints only the label, and the numbering no longer maps onto the table. Renumber the tail, or give the new check a distinct suffix (`17b`). Smell: Mysterious Name.

```
check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
export FAKE_BODY='## Testing decisions
...
check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

Checked and clean: the counts in prose are true at this commit (`docs/knowledge/core/MANUAL.md` is 175 lines, its header and `INDEX.md` both say 175, and "Where to read more" is the last section, so no mini-TOC offset moves); `tools/build_knowledge.py` line 136 already excludes only `CONVERSATION-DIGEST.md`, so the amended docstring and the manual's "first five" both match the code; the new `patches/pstack/architect/SKILL.md.patch` context matches the pinned upstream at `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md` lines 29-35 exactly, it is listed in `patches/series` and described in `SOURCES.md` entry 14, as `AGENTS.md` requires for a vendored skill; the awk skip list in `overlap.sh` matches its own header comment, Ticket step 6, and P24 in both `DECISIONS.md` copies; the two `template/docs/factory918/` files carry the same text as their `docs/knowledge/core/` sources with headers stripped, as the build script produces.

hard findings: 0
