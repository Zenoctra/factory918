## Would break

## Fails open

## Standards breaches

1. **P25 gets its own count wrong.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it." At this commit the string "Ticket step 5" (or "the Ticket playbook, step 5") appears in six patches, not four: bug-fix, feature, perf-issue, refactoring, opening-a-pr and `mattpocock/spec-review.SKILL.md.patch`. `review-brief.sh` does not quote a step number at all. Its line 183 says only "the Ticket playbook says it in words". The same text is in `template/docs/factory918/DECISIONS.md`, which is generated, so the fix goes in the core file.
```
Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`)
```

2. **The project copy of the page points at things only the factory has.** AGENTS.md, the nesting rule: "Files under `template/` and `profiles/` are content addressed to agents in a future project." `template/docs/factory918/SCENARIO-TABLE.md` tells a project agent to read the table beside `tests/poteto-mode/overlap.sh`. The template has no `tests/` directory, so a project has no such file. The page also names "ticket #42" and "PR #92" as the durable copy. In a project, `gh issue view 42` opens that project's own issue 42. The page already carries the table verbatim, so the fix is in `docs/knowledge/core/SCENARIO-TABLE.md` (the generated copy follows): drop the pointers or name the factory repository.
```
+The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
...
+Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
```

## Fix alongside

3. **Stale docstring in `tools/build_knowledge.py` (a stale comment).** The diff adds a CORE_DOCS tuple, and `build_core` now copies SCENARIO-TABLE.md into `template/docs/factory918/`. The module docstring (lines 7-9) still lists four copied documents. The new M0-findings line also says the change needed "no other code", but this docstring is the one other place that had to change.
```
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

4. **The posting rule is written out in six places (Duplicated Code / Shotgun Surgery).** Six places each state the heading, the first-line wording and the `/architect with checkpoint` opt-in: Ticket step 6, the runner prompt, P25, `SCENARIO-TABLE.md`, `docs/agents/issue-tracker.md` (and its template twin) and the glossary. The writer sentence is also word for word in four playbooks and in the page. The playbook copies are there because the vendored files have to be patched. The page and `issue-tracker.md` could point to Ticket step 6 instead of restating it. As it stands, the next change to the rule is a six-file edit.
```
+... first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first ... a stop before implementation is asked for only with `/architect with checkpoint`.
```

5. **A known-false line is left in place.** The M0-findings line records that `SOURCES.md` line 3 is wrong ("`factory918 sync` will re-fetch these pins ... and bump VERSION"; sync does neither). It leaves line 3 unchanged. AGENTS.md, "Pull requests": "a finding outside its scope becomes a ticket". The diff does not show that a ticket was filed. Name the ticket in the finding, or file one.
```
+... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

6. **One page, three Diátaxis modes (a judgement call).** CODING_STANDARDS.md: "One Diátaxis mode per file". `SCENARIO-TABLE.md` combines explanation ("What it is", "Why"), reference ("The shape", the verbatim #42 legend, table and contract) and how-to ("Where it goes", with the `gh issue edit` step). Most of the page is explanation, so this is a light breach. The how-to already lives in Ticket step 6.
```
+## Where it goes
+
+On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`.
```

These ran on a copy of this commit, put under git: `python3 tools/build_knowledge.py` left the tree clean, `python3 tools/check_knowledge.py` passed (119 files), and `./factory918.sh sync` left the tree clean with all 19 patches applied. Five test scripts passed: `tests/hooks/delegation.sh` (55 assertions), `tests/spec-review/review-comment.sh` (82), `tests/spec-review/review-brief.sh` (334), `tests/poteto-mode/overlap.sh` (56) and `tests/spec-review/no-stale-wording.sh`. The other four scripts that AGENTS.md lists (`tests/shellcheck/gate.sh`, `tests/show-me-your-work/check-trail.sh`, `tests/knowledge/provisional-ids.sh`, `tests/eval/reviewer/refusals.sh`) do not exist at this commit. `tests/knowledge/provisional-ids.sh` would have checked the new P25 ID. No shell file changed.

hard findings: 0
