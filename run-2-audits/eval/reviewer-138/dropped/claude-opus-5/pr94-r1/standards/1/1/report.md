The change is prose and patches; the patches all apply (`./factory918.sh sync` reproduces `template/` byte for byte) and `python3 tools/build_knowledge.py` reproduces the knowledge tree and the slim copies with no diff. Two statements the repository already documents are made false by it, both a one-line fix in a file the diff is already editing.

## Would break

1. **`architect`'s own skill still orders the usage sketch first, and the rationale template has no slot for the table.** The patched runner prompt makes the scenario table the first deliverable for a design with state and reserves the usage-and-signature sketch for the stateless case, but the same paragraph tells every runner to read the skill in full, and the skill states the opposite with no condition, in two places. The synthesized package is shaped by `rationale-template.md`, whose first instruction is the usage written first and which has no section for a table, a contract or a test list. Only the runner prompt was patched.
Documented step: `template/.agents/skills/architect/SKILL.md:32`, quoted below with `:84` and `references/rationale-template.md:9-11`. The standard is `CODING_STANDARDS.md`, Markdown: agent-read prose is written with `/writing-for-agents`, whose rule is one authoritative place per meaning (`template/.agents/skills/writing-for-agents/SKILL.md:78`).
Result: for a stateful design a runner, and arena's synthesis which fills that template, can follow the usage-first shape and produce no table; Ticket step 6 then has nothing to append and the ticket keeps no artifact, which is the failure the ticket was filed about.
spec: criterion 1

```
SKILL.md:32  Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it.
SKILL.md:84  The caller's usage is written first and the type sketch derived from it.
rationale-template.md:9,11  ## Usage (caller's view) / *Write this first, before the type sketch. ...*
```

2. **`MANUAL.md` still says a project carries four of the core documents.** `AGENTS.md` went from five to six in this diff; the manual's map of the same set did not move. Its list names `MANUAL.md`, `PHILOSOPHY.md`, `DECISIONS.md` and `GLOSSARY.md` and never `SCENARIO-TABLE.md`, while `factory918.sh apply` copies every file under `template/` (`factory918.sh:131`), so five land in `docs/factory918/` — a directory with no `INDEX.md`, which leaves this list as the only map a project's reader has.
Documented step: `docs/knowledge/core/MANUAL.md:165`, quoted below; its generated copy is `template/docs/factory918/MANUAL.md:146`. The standard is `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby."
Result: a project carries five slim documents while its manual says four and never names the fifth, so a reader following the map is told the page does not exist. Fix in `docs/knowledge/core/MANUAL.md`, then `python3 tools/build_knowledge.py`.
spec: criterion 6

```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```

## Fails open

None.

## Standards breaches

3. **`PHILOSOPHY.md`'s "Where to go next" enumerates the core documents and omits the new one.** It names every core document but itself; after this diff that list is short one. `AGENTS.md:9` in this same diff calls them the six core documents. Fix in `docs/knowledge/core/PHILOSOPHY.md:64`, then rebuild; the generated copy is `template/docs/factory918/PHILOSOPHY.md:54`.

```
`MANUAL.md` for how to use the system day to day. `DECISIONS.md` for the choices and their reasons. `GLOSSARY.md` for terms. `CONVERSATION-DIGEST.md` for how the system was arrived at ...
```

4. **`SOURCES.md` is left saying what this diff records as false, three lines above the diff's own edit.** The new `docs/M0-findings.md` line reads "factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth", and the diff edits `SOURCES.md` without correcting line 3. `AGENTS.md` gives the findings precedence over `docs/FACTORY-SPEC-v2.md` only, so nothing resolves this one for a person reading `SOURCES.md`; `cmd_sync`'s own header in `factory918.sh` already states the truth.

```
SOURCES.md:3   ... `factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.
factory918.sh  # Vendoring never touches the network: update the pins in research/ first.
               # Our own skills and playbooks stay; VERSION is bumped by hand in the commit that lands this.
```

## Fix alongside

5. **The two new ticket sections widen `overlap.sh`'s token scan, and no rule says so.** Ticket step 6 now appends a table full of backticked path tokens to the ticket body; `overlap.sh` reads that body at step 1 and skips only a `## Diff` section, as P24 documents. On any later step-1 run of the same ticket the table's own tokens are matched as pathspecs, so a PR that touches a file the table merely cites can print as an overlap and stop the run at exit 1. Mostly benign, because a table cites the work's own paths, and the fix is one regex in `overlap.sh:48` (outside this diff) or one clause in step 6, so this is ticket material rather than a change here.

```
overlap.sh:48  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
```

6. **Nothing detects a missing artifact.** The step-5 cross-cutting rule beside it is enforced — `review-brief.sh` refuses to brief the diff without a Blast Radius section — while step 6's artifact rule is prose only, so a stateful design that never posts a table reaches review with no trace of the omission. No criterion asks for a gate; noted because the ticket's own problem statement is that nothing sent the work back when the design added state.

hard findings: 2
