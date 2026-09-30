# Standards report, ab47eb9

Verified in a copy of the tree: `python3 tools/build_knowledge.py` reproduces `docs/knowledge/` and `template/docs/factory918/` byte for byte; `python3 tools/check_knowledge.py` passes (119 files); `./factory918.sh sync` applies all 19 patches and leaves `template/` and `patches/` unchanged; `tests/spec-review/no-stale-wording.sh` passes. `review-brief.sh` line 222 pastes the ticket body whole, so the "Spec brief carries the table" claim holds. Both copies of `issue-tracker.md` are identical.

## Would break

## Fails open

## Standards breaches

1. **P25 records a count that is false at this commit.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." `grep -rl "Ticket step 5" patches` returns five patches (`opening-a-pr.md.patch` too), and `review-brief.sh` never quotes "Ticket step 5" (its line 183 says "the Ticket playbook says it"). Same text in the generated `template/docs/factory918/DECISIONS.md`.
   ```
   +| P25 | ... the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
   ```

2. **The manual's reading list still says a project carries four documents.** Same rule. `docs/knowledge/core/MANUAL.md:165` reads "a project carries only the first four, under `docs/factory918/`" and the list below it has no `SCENARIO-TABLE.md`; `PHILOSOPHY.md:64` lists the documents and omits it too. The template `knowledge` skill was updated to say five; the manual was not. The M0 line in this diff is what makes the count wrong:
   ```
   +2026-09-22. A sixth core document costs one CORE_DOCS tuple in tools/build_knowledge.py and no other code: build_core copies every core document except CONVERSATION-DIGEST.md into template/docs/factory918/ ...
   ```

## Fix alongside

3. **Step order: the posting rule lives after the step that runs implementation.** Ticket step 5 says "run that playbook's steps verbatim from step 1", and Feature step 4 delegates with a brief that "carries the ticket's design artifact (Ticket step 6)"; a reader in step order reaches step 6 after step 5 has already delegated, and nothing checks that the brief carried an artifact. The runner prompt and P25 say "before implementation", so the intent is recoverable by cross-reference, not by reading down. A sentence in step 5 ("before the playbook's delegation step, do step 6") or moving the posting into the four playbooks' architect steps would close it. Judgement call; not filed hard because the Standards brief carries no ticket criteria to cite.
   ```
   +6. The spec's **Testing decisions** are the pre-agreed seams. ... The selected playbook's architect step adds the ticket's own: ... before implementation the synthesized table is appended to the ticket's body ...
   ```

4. **Duplicated Code.** The same 60-word sentence ("The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test ...") is pasted verbatim into four playbooks and four patches. One sentence pointing at Ticket step 6, which already holds the rule, would do; the existing "(Ticket step 5) never skips it" clause shows the short form.
   ```
   +... review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

5. **A posted table feeds `overlap.sh` on the next run.** `overlap.sh` line 48 skips only `## Diff`; every backticked token under `## Testing decisions` becomes a pathspec on a re-run of step 1 (a second run of the ticket, a stacked ticket). Non-paths match nothing (row 13) and an absolute path exits 2 (row 14), so it is loud, not silent; the #42 table already unbackticks one token to dodge it. Either skip that section in the awk or say in step 6 that cells name paths without backticks.
   ```
   +The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
   ```

6. **Factory-only path in a document every project receives.** `template/docs/factory918/SCENARIO-TABLE.md` says "Read the table beside `tests/poteto-mode/overlap.sh`"; a project has no such file. `DECISIONS.md` already cites factory tickets, so this is consistent, but the sentence is an instruction, not a citation.
   ```
   +Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
   ```

7. **Diátaxis mix, borderline.** `CODING_STANDARDS.md`, Markdown: one mode per file. `SCENARIO-TABLE.md` is explanation ("What it is", "Why") with a reference section ("The shape") and a how-to ("Where it goes") inside. `MANUAL.md` mixes the same way, so this is the house pattern; noted, not counted.

8. **The M0 line found a stale sentence and left it standing.** `SOURCES.md:3` still says sync "will re-fetch these pins ... and bump VERSION"; the finding records that the code is the truth without a ticket to fix the sentence (ledger 2026-09-17: grep for the old wording). Outside this PR's concern; a quick ticket.

hard findings: 0
