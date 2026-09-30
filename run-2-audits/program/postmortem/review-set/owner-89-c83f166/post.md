Round 2 reviewed the four fix commits since c83f166 and found nothing that breaks or fails open on either axis; the one note, that `to-spec` spells the section `Testing Decisions` while the ticket body and the overlap check use `Testing decisions`, is off the documented path and is recorded, not acted on. Nothing is left to fix and this round fixed no Would-break item, so no further round is owed and the PR is ready for Manuel to merge.

Claude Fable 5.1 on Claude Code

## Standards

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

## Spec

# Spec report

## Walk

1. Ticket step 1 runs `overlap.sh N`. The awk pass now sets `skip` on `^## (Diff|Testing decisions|Design)[[:space:]]*$` and clears it at the next `## ` heading, so backticked tokens inside the two artifact sections never become pathspecs; `### ` subheadings inside a table do not clear it, and a trailing `\r` from `gh` still matches.
2. With every token inside those sections, `paths` is empty and the script prints `go: ...`, `paths: none`, `base: origin/main` and exits 0 before `gh pr list`, so step 1 branches from main.
3. `--diff` (step 8) never reads the ticket body, so the record run is unchanged.
4. Architect Phase B now tells runners that a stateful design's package opens with the table, its contract and its test list, and points at `references/runner-prompt.md`, which already carries the shape and the refusal-cell rule. The new patch's context matches the pin at lines 29-35, and the vendored copy differs from the pin only at the patched line, so `sync` reproduces it; `series` lists it.
5. Ticket step 6 posts the artifact: read the body with `gh issue view N --json body -q .body`, add the section with its `Posted by the agent <date>` first line, write the whole file with `gh issue edit N --body-file`; a failed write stops before implementation. `SCENARIO-TABLE.md` says the same, with the reason (`--body-file` replaces, never merges).
6. The `to-spec` bullet and its patch agree, and "the rule above about paths and snippets" names a rule that is really above it.
7. Docs stay consistent: `MANUAL.md` counts five project documents and lists `SCENARIO-TABLE.md`; `template/docs/factory918/` holds exactly those five, each byte-identical to the stripped core body; `INDEX.md` records 175 lines, which `wc -l` confirms, and the mini-TOC offsets are unshifted because the new bullet is in the last section; the `build_knowledge.py` docstring now matches the code's `!= "CONVERSATION-DIGEST.md"` test.
8. The new test case puts one token in each skipped section and asserts exit 0 with `paths: none`; miss either heading and the tokens match PRs 1, 2 and 4 and the case fails at exit 1.
9. `SCENARIO-TABLE.md` states the amended rule in "Where it goes"; the #42 quote below it is kept at the old `## Diff`-only wording, as the criterion's verbatim example, and P24 carries the dated amendment.

## Would break

## Fails open

## Not asked for

hard findings: 0

## Judgment

## Act on

## Ask

## Consider

## Noted

1. [S1] **The skipped headings are matched case-sensitively, and the repo spells the section two ways.** A Fix alongside with no Act on fix touching `overlap.sh`; the documented path (Ticket step 6 and the awk) agrees on `## Testing decisions`, and `to-spec`'s `## Testing Decisions` names a spec-file section, not the ticket body the check reads, so nothing on the path is wrong or silent.

## Dismissed

Standards: 0 would break, 0 fail open, of 1; Spec: 0 would break, 0 fail open, of 0; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point c83f166.
round: 2 of 3
act-on items: 0
