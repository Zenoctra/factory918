# Say it back: before, after

Readers per variant: 5. Reader model: claude-opus-5-5 at medium; tools: none. Judge: claude-opus-5-5 at high, blind to variants. Repository at `c83f166`.

Reader cost in API-rate terms: $0.68 (usage on the subscription, not a bill). Safety check: no problems.

## Agreement

For each field, how many different readings the judge found per variant, and the share of readers in the largest group. One reading at 100% means every reader understood that field the same way.

| Field | before | after |
|---|---|---|
| task | 1 reading(s), largest 100% | 1 reading(s), largest 100% |
| done | 1 reading(s), largest 100% | 1 reading(s), largest 100% |
| may_change | 1 reading(s), largest 100% | 2 reading(s), largest 80% |
| must_not | 1 reading(s), largest 100% | 1 reading(s), largest 100% |

## Against what the writer meant

Share of readers whose reading the judge marked match / partial / miss.

| Field | before | after |
|---|---|---|
| task | 100% / 0% / 0% | 100% / 0% / 0% |
| done | 0% / 100% / 0% | 100% / 0% / 0% |
| may_change | 0% / 100% / 0% | 80% / 20% / 0% |
| must_not | 0% / 100% / 0% | 100% / 0% / 0% |

Notes per reader:

- after-1: none
- after-2: none
- after-3: none
- after-4: Allows running build_knowledge.py, which writes to the tree and so goes beyond the read-only commands the writer allowed.
- after-5: none
- before-1: Adds a 400-word cap and a zero-findings expectation, and bans commands and whole-file reads.
- before-2: Adds a 400-word cap and a zero-findings expectation, and restricts reading to the diff with no commands.
- before-3: Expects zero findings under a 400-word cap and forbids commands and repository reads.
- before-4: Adds a 400-word cap and forbids running commands or reading beyond the diff, though the writer allowed full repository reads and read-only commands.
- before-5: Adds a 400-word cap, accepts zero findings, and bans commands and repository browsing.

## The readings, grouped

### task

- Review the diff of the six listed commits, which add a scenario-table core document and wire it in, against CODING_STANDARDS.md and the smell baseline, and report the breaches under four fixed headings. (before: 5, after: 5)

### done

- The report at .scratch/review/ab47eb9/standards-report.md has the four headings in order, continuous numbering, quoted hunks, and Documented step/Result lines on hard items. It ends with `hard findings: N`, has no length cap, and the reply is only the path. (before: 0, after: 5)
- The same report shape, but it must stay under 400 words, and zero findings is treated as an acceptable or expected result. The reply is only the path. (before: 5, after: 0)

### may_change

- Write only the report file. Any repository file may be opened, and read-only commands (grep, git log/show, tests) may be run to check findings. (before: 0, after: 4)
- Write only the report file and read any repository file. Read-only commands may be run, and this explicitly includes build_knowledge.py when it is used only to check that output is current. (before: 0, after: 1)
- Write only the report file. Reading is limited to the diff plus the single function or section around a hunk when a finding needs it. (before: 5, after: 0)

### must_not

- Don't edit repository files (source, generated, vendored, patches), commit, push, post, or run anything that changes state. Skip what CI enforces, and don't count edge cases that are refused with a corrective message. (before: 0, after: 5)
- Run no commands at all (no tests, no build, no git), read no whole files and nothing beyond the brief and the diff, and edit nothing. Skip what CI enforces and don't flag correctable edge cases. (before: 5, after: 0)

## Choices the readers said the brief leaves open

- Whether ab47eb9 is the base or the head of the range, and so which base the diff is against (before: 0, after: 2)
- What to cite as the `Documented step:` when no ticket or spec is given (before: 3, after: 4)
- Which checks the CI gate already enforces, and so what to skip (before: 2, after: 5)
- Whether running build_knowledge.py or sync to verify generated and vendored files is allowed, given that both write to the tree (before: 0, after: 5)
- Whether the edits to generated template/docs/factory918 files are legitimate rebuild output or hand edits that break the 'never edited' rule (before: 5, after: 3)
- Whether prose counts like 'six core documents' are stale or breach the rule that a count is true at the commit, and how severe that would be (before: 4, after: 4)
- Whether docs/agents/issue-tracker.md was properly copied from the template, and which review axis that check belongs to (before: 2, after: 2)
- Whether each vendored-skill edit has a matching patch, a series entry and a SOURCES.md description (before: 3, after: 2)
- How strictly to apply the record rules (M0-findings, ledger, DECISIONS) to the record commit (before: 0, after: 1)
- How to classify doc-only or playbook changes into the behavior-framed Would break and Fails open categories (before: 2, after: 1)
- Whether reading the separate diff file is allowed under 'read nothing beyond this brief' (before: 3, after: 0)
- Whether the 400-word limit counts the quoted hunks (before: 2, after: 0)
- Whether the report needs the model and harness footer (before: 1, after: 0)
- Whether the .scratch/review/ab47eb9/ directory already exists (before: 1, after: 0)
- How to judge subjective prose rules (one Diátaxis mode per file, writing-for-agents style) (before: 0, after: 2)
- How to apply code smells (Shotgun Surgery, Duplicated Code) to a change that is mostly Markdown and patches (before: 1, after: 2)
- Whether the 'documented standards' include the AGENTS.md rules or only CODING_STANDARDS.md (before: 0, after: 1)

## Questions the readers would ask

- after-1: Is there a ticket or spec for this change whose lines I should quote as the Documented step? If not, which file:line should a would-break finding cite?
- after-1: May I run build_knowledge.py and `./factory918.sh sync` in a scratch copy of the repo to check that generated and vendored files are consistent? Or is any command that writes, even outside the tree, off limits?
- after-1: What base commit should I diff against: the parent of 3b48036, or something else such as main?
- after-1: Should the deliberate duplication between patches/ and template/.agents/skills be left out of the smell findings?
- after-2: Can I run the test scripts, build_knowledge.py and `./factory918.sh sync` even though they may write to the working tree, as long as I check `git status` afterwards? Or should I stick to grep and git?
- after-2: If the ticket or spec this change implements is the source of 'Documented step:' lines, where is it? Is there a ticket number?
- after-2: Should I check the edits to the vendored copies under template/.agents/skills against their patches in patches/ (that applying the series reproduces them), or is that out of scope for this axis?
- after-3: Is ab47eb9 the head of the change or its base? Which ticket or issue number did this work come from, so I can cite it as the documented step?
- after-3: Can I run build_knowledge.py and `./factory918.sh sync` to check for drift in generated and patched files, then restore the tree afterwards? Or is any command that writes files off limits?
- after-3: The repo's rule for agent-written comments says they end with the model and harness, but this brief says the report's last line must be `hard findings: N`. Should I leave the signature out of the report?
- after-4: Should the standards I review against include the rules in AGENTS.md (patches listed in series and SOURCES.md, generated files, where records go), or only CODING_STANDARDS.md?
- after-4: Can I run build_knowledge.py and factory918.sh sync to check that the generated and vendored copies match their sources, given that they may modify the working tree?
- after-4: Is ab47eb9 the head or the base of this range, and which commit should I diff against if I need more context than the saved diff?
- after-5: Is it acceptable to run build_knowledge.py and factory918.sh sync to confirm the generated and vendored files are in sync, given that they can write to the working tree?
- after-5: Is there a ticket or spec for this change whose lines I should quote as the Documented step, or should every citation point at repository docs?
- after-5: Is the base for this review v0.2.0..HEAD, or only the six listed commits? That decides which existing text I can treat as already accepted.
- before-1: Is reading .scratch/review/ab47eb9/diff explicitly allowed, given the 'read nothing beyond this brief' line?
- before-1: Does the 400-word limit include the quoted hunks?
- before-1: If a generated file in the diff looks like it doesn't match what the build would produce, but I'm not allowed to run the build, should I report it as a breach or leave it alone?
- before-2: Is reading .scratch/review/ab47eb9/diff allowed, even though the brief says to read nothing beyond itself?
- before-2: Does the 400-word limit include the quoted hunks?
- before-2: Should I check that the template/docs/factory918/ hunks match what build_knowledge would produce from the core sources, or just trust that they're regenerated?
- before-2: Is there a ticket I should take Documented step lines from, or should they always cite repository documentation by file:line?
- before-3: Does the 'read nothing beyond this brief' rule cover the diff file at .scratch/review/ab47eb9/diff? I'm assuming it does not, since the review can't happen without it.
- before-3: Should I skip the getting-started reading order in CLAUDE.md for this review? I'm assuming yes.
- before-3: For generated files that appear in the diff, should I assume they were rebuilt by build_knowledge.py unless the diff clearly shows otherwise, or flag them for verification?
- before-4: Is template/docs/factory918/ meant to be regenerated in this diff by build_knowledge.py, so its changes are expected and not a breach of the never-edit rule?
- before-4: Is SCENARIO-TABLE.md meant to be the sixth core document, replacing one, or a seventh? The AGENTS.md diff and the commit title may disagree.
- before-4: Is there a ticket or spec I should cite for 'Documented step:' lines, or should I cite only file:line from the repository docs?
- before-4: Should the .scratch/review/ab47eb9/ directory be assumed to exist, or may I create it if it is missing?
- before-5: Should I confirm that the template/docs/factory918/ changes match what build_knowledge.py produces, or assume they do since I can't run anything?
- before-5: Does the 400-word limit cover the quoted hunks inside the fenced blocks?
- before-5: Does the .scratch/review/ab47eb9/ directory already exist, or may I create it?

## Files

- `brief.<variant>.md`: each brief as the readers got it (paths remapped into the box).
- `readers/<variant>-<n>/`: each reader's prompt, settings, full event stream and structured reading.
- `readings.json`, `judge.json`, `blind-key.json`: the readings, the judge's raw verdict, and which blind id was which reader.
- `judged-items.jsonl`: the judge's calls, one per line, for `judge-agreement.py`.
