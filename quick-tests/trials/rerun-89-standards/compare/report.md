# Re-run of 'Standards review of PR #94'

Original: `/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/subagents/agent-a6625c5aa72f90533.jsonl`, started 2026-09-22T15:09:41.590Z, models claude-opus-5. Repository at `c83f166` (c83f16657).

## Runs

| Run | ok | minutes | turns | tool calls | cost (API terms) | files changed |
|---|---|---|---|---|---|---|
| original | - | 7.6 | - | 28 | - | see output |
| original-1 | True | 3.6 | 20 | 19 | $1.92 | 7 |
| original-2 | True | 4.7 | 24 | 23 | $2.26 | 1 |
| original-3 | True | 2.7 | 16 | 15 | $1.50 | 1 |
| pr137-1 | True | 14.9 | 41 | 40 | $3.41 | 1080 |
| pr137-2 | True | 7.1 | 35 | 34 | $3.02 | 1080 |
| pr137-3 | True | 6.3 | 42 | 41 | $3.62 | 1 |

## Key items found

Each cell: yes / partly / no, from one blind judge pass over the original and every run.

| Item | original | original-1 | original-2 | original-3 | pr137-1 | pr137-2 | pr137-3 |
|---|---|---|---|---|---|---|---|
| 1. --body-file replaces the body, wiping What to build and acceptance criteria | yes | no | yes | yes | yes | yes | no |
| 2. Backticked paths in the posted table become phantom overlaps in overlap.sh | yes | no | no | no | no | yes | yes |
| 3. Stated count of four core/project documents is false after the scenario table was added | no | yes | no | yes | no | yes | yes |
| 4. No stop clause when gh issue edit fails | no | no | no | no | no | no | no |

How often each item came back, per label (yes or partly):

- original: item 1: 2/3, item 2: 0/3, item 3: 2/3, item 4: 0/3
- pr137: item 1: 2/3, item 2: 2/3, item 3: 2/3, item 4: 0/3

## Findings outside the key, per output

- original:
  - to-spec's exemption covers only the 'code snippet' half of 'no file paths or code snippets', but the tables name paths
  - SOURCES.md line 3 still says sync bumps VERSION, which this commit records as false
  - Writer sentence copied verbatim into four playbooks and four patches, and the rule restated across ~8 files (Duplicated Code / Shotgun Surgery)
- original-1:
  - Step 6 comes after step 5 has run the whole playbook (a sequencing issue; P25 records it)
  - Writer paragraph duplicated across four playbooks and patches, described as house style
  - PHILOSOPHY.md:64's read-more list omits SCENARIO-TABLE.md
  - Verified that the patches reverse-apply byte-identically, cmd_update reaches the new file, P25 is under Provisional, and the M0 line is dated
- original-2:
  - Writer paragraph copied verbatim into four playbooks and four patches (Duplicated Code)
  - The 'before implementation' rule sits in step 6, after step 5 runs the playbook; it is reached only through forward pointers (P25 records the trade)
- original-3:
  - PHILOSOPHY.md:64 omits SCENARIO-TABLE.md from its list
  - Writer paragraph duplicated in four playbooks and their patches, following the precedent of the architect skip clause
  - Divergent Change: step 6 sits after step 5 and is reached on time only through forward pointers
  - Trigger drift: the to-spec patch drops 'rounds'
- pr137-1:
  - Nothing triggers the table for a stateful change that does not cross a function boundary (the playbooks gate architect on a function boundary)
  - An architect package with no table is accepted silently: SKILL.md and rationale-template are still usage-first and have no table heading
  - The trigger list has drifted: 'rounds' is missing in the to-spec patch and the CORE_DOCS description
  - The runner prompt carries an orchestrator-facing sentence; N runners editing the body is a destructive race
  - The core document ships a 45-line factory-internal #42 example to every project and mixes Diátaxis modes
  - Shotgun Surgery: one rule lives in ten prose homes
  - feature.md step 4 sprawls to about 190 words with four unrelated rules
  - Two '## Testing decisions' tables (spec and architect) have no tie-break
  - Verification run: build_knowledge leaves the tree clean, check_knowledge passes, sync applies all 20 patches
- pr137-2:
  - SOURCES.md keeps a sync/VERSION claim that this PR's own finding proves false
  - The SCENARIO-TABLE page shipped to projects points at the factory-only path tests/poteto-mode/overlap.sh and at factory ticket numbers
  - architect SKILL.md Phase B is still usage-first, and the orchestrator's posting job sits in the runner's prompt; /architect outside Ticket has no table instruction
  - Writer paragraph duplicated across eight files (Shotgun Surgery)
  - 'the rule above' is a distant referent, and the waiver answers only the snippet half and not the paths half
  - Step 6 is numbered after step 5, which runs the whole playbook, so a reader following the numbers posts after implementation
  - Core page copies the #42 table verbatim while naming ticket #42 as the durable copy, so the two will drift
- pr137-3:
  - P25 miscounts where 'Ticket step 5' is quoted: five patches, and review-brief.sh does not contain it
  - SOURCES.md:3 still claims sync re-fetches pins and bumps VERSION
  - Writer instruction duplicated in eight copies
  - architect SKILL.md and rationale-template have no table home, so /architect outside Ticket can produce no table unnoticed
  - 'the rule above' is an unresolved referent, and the waiver does not answer the file-path ban

## What happened after the original returned

From `run-2-audits/program/postmortem/delegates.md` (branch `research/run-2-audits`), ticket #89, PR #94, delegate 7a: the round-1 Standards reviewer "changed the outcome. The new rule told an agent to post the table with a command that replaces the whole ticket body. An agent following the rule as written would have wiped What to build and the acceptance criteria from every ticket it touched, and the next Spec review would have read an empty spec and said nothing." The round-1 lane put five Act-on items to the owner (S1, P1, S5, P3, P4) and a fix lane fixed them; the round-2 reviewers found nothing hard.

The launching agent's next steps, from its transcript: `original/after.md`.

## Outputs

Each output in full: `original/output.md` and `runs/<label>-<n>/output.md`. Each run's event stream: `runs/<label>-<n>/stream.jsonl`; files it wrote: `runs/<label>-<n>/written/`.
