# Standards report

The change is documentation plus one awk filter and its test. I checked the filter against the script, the new patch against its pinned upstream, and the build script's docstring against its code; the documented path holds in each.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The skipped headings are matched case-sensitively, and the repo spells the section two ways.** `to-spec/SKILL.md:59` writes the spec heading as `## Testing Decisions`; Ticket step 6 and the awk both use `## Testing decisions`. The documented path is consistent, so nothing breaks, but a body that carries the spec's spelling is not skipped, and the mismatch is invisible at the call site.

```
-  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
+  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
```

Checked and clean, so not reported: the awk alternation is POSIX ERE and drops the heading line itself, so the new fixture body yields no tokens and the expected `paths: none\nbase: origin/main` (`template/.agents/skills/poteto-mode/scripts/overlap.sh`, the empty-`paths` branch); `patches/pstack/architect/SKILL.md.patch` matches the pinned upstream exactly at line 32 (`research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md`), is listed in `patches/series` and is described in `SOURCES.md` item 14, as AGENTS.md "Vendored skills" requires; `tools/build_knowledge.py`'s new docstring line matches its code, which copies every core document except `CONVERSATION-DIGEST.md` (`build_core`, the `p.name != "CONVERSATION-DIGEST.md"` guard), so "the first five" in both manuals is the true count; `docs/knowledge/core/MANUAL.md` is 175 lines, the number the header and `INDEX.md` now carry; the generated copies under `template/docs/factory918/` and `docs/knowledge/INDEX.md` were rebuilt rather than hand-edited, and reusing the number 17 for the new case follows the file's existing convention (19, 22, 23 are each reused).

hard findings: 0
