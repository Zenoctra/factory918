# Standards report

Nothing in this diff breaks a documented rule. Two small test-quality notes are below; neither
changes behavior and neither needs fixing unless something else touches that code.

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The new overlap case is weaker than the `## Diff` case it mirrors.** The `## Diff` fixture puts a counted token in a following `## Notes` section, so it proves the skip both starts and *ends* at the next `## ` heading. The new fixture has nothing after `## Design`, so the run short-circuits at `paths: none` and never reaches the PR matcher; an alternation that over-matched (`## Design notes`, a stray heading) would still pass. One counted token in a trailing section would make the two symmetrical.

   ```
   +## Design
   +
   +`src/z.txt`'
   +check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
   ```

2. **Two different scenarios both numbered 17.** Elsewhere a repeated number marks facets of one scenario (the three `22` gos, the two `19` go writes). Here `17` covers the `## Diff` skip and then a separate scenario, so a failure naming "17" is ambiguous.

   ```
   check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
   ...
   check "17 tokens under ## Testing decisions and ## Design ignored" 0 ...
   ```

Checked and clean: the awk alternation is POSIX-portable and quoted, and the `shellcheck disable` comment still sits on the line that needs it; `build_knowledge.py`'s new docstring line matches the code it describes (`if p.name != "CONVERSATION-DIGEST.md"`, line 136); the MANUAL "first five" count matches the five bullets under it and the six core documents minus the digest; `MANUAL.md`'s mini-TOC needs no shift because the added bullet is in the last section; the core and `template/docs/factory918/` copies of MANUAL, DECISIONS and SCENARIO-TABLE moved together with no drift; the new `patches/pstack/architect/SKILL.md.patch` is listed in `series`, described in `SOURCES.md` entry 14, and its `@@ -29,7 +29,7 @@` context matches the pinned upstream (`research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md` lines 29-35) line for line.

hard findings: 0
