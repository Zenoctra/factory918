# Lane E: where Manuel established the template rule

## The answer in one paragraph

He said it once, on 2026-09-17, in the conversation that produced ticket #7. The words are
"a somewhat universal template for these reviews that pulls the human quotes as the primary drivers
for the context of the review agent", and their point was that an orchestrator writing a subordinate's
prompt freehand leads the witness. It was never written into PHILOSOPHY, MANUAL, DECISIONS or any skill
as a general rule. #7 turned it into two narrow acceptance criteria about whose text counts as the spec,
and that is all that landed. The machinery he is remembering, `review-brief.sh`, came later and from a
different ticket (#33, cost), so the templates exist but the rule behind them does not.

## The rule itself

**Candidate 1 (this is the one he means).**
Source: transcript `/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/c4adc431-82a9-4202-b70c-b99878ab10b6.jsonl`, 2026-09-17T20:37:24.398Z.

> "Does spec review or whatever agent based context fresh review system we have have a way that it
> invokes itself such that I could tell you to run spec review on these two PR's you just submitted and
> the agent could run the review without YOU writing its prompts right now? Cause I know that AI written
> prompts usually guide the reviewer on accident very often and accidentally force a pass instead of
> having a somewhat universal template for these reviews that pulls the human quotes as the primary
> drivers for the context of the review agent. I kind of assume this is already properly callibrated,
> but its worth checking to make sure our system is built to handle it."

He also gave, in the same message, the mechanism for the no-grilling case: "skipping it takes the first
explanations and impromptu informal plans and explorations and writes a quick ticket behind the scenes by
utilizing quotes and not summaries so that we have the information necessary and it stays clean".

Three claims are bundled there, and he has since repeated all three separately: the orchestrator must not
hand-write the subordinate's prompt; a fixed template does it instead; the template is filled with the
human's own quotes rather than the model's paraphrase.

**Where it was recorded.** Issue #7, "Reviews read the human's words, not the author's" (Zenoctra/factory918,
opened 2026-09-17T21:14:54Z, closed COMPLETED 2026-09-17T23:13:25Z). The sentence above is the entire
`## What to build` section, quoted verbatim as a blockquote.

**What #7 actually shipped.** Its three acceptance criteria are narrow, and none of them is the template rule:

- "`spec-review` never takes the PR description, a commit message or the author's account as the spec;
  without a ticket it reports Standards-only, in those words."
- "`interrogate` uses the ticket's What to build and Acceptance criteria verbatim as the intent when a ticket exists."
- "Both are patches under `patches/`, listed in `series` and `SOURCES.md`; `sync` reproduces the template."

PR #12 (merged 2026-09-17T23:13:24Z) closed it with exactly that: two vendored-skill patches so neither
review skill reads author-written text as the spec. The general rule, "the authority model always talks to
the subordinate through a template", was not carried into a core document, a DECISIONS row or a skill.

## The second, sharper statement of the same rule

Source: transcript `a652bd71-daf0-425b-be80-7044d0035777.jsonl`, 2026-09-21T18:12:14.295Z.

> "I also want to make sure my exact philosophical reasonings are quoted in the skills/system
> instructions/prompts as well because even if the things you said covers it all, using the exact verbiage
> of the user is going to help semantic philosophical alignment."

And six minutes later, 2026-09-21T18:18:52.713Z, same file:

> "'An edge case outside the intended path being unsupported is not a flag.'
> 'Primary focus must be the happy path, then unhappy paths that error in a way the user can correct.'
> add these two quotes as well to the list of my words that we keep quoted."

"The list of my words that we keep quoted" is the closest thing in the record to a standing instruction
about template contents. This half did land: it became ticket #81, whose body has the heading "The five
sentences of Manuel's that the brief and the skill quote verbatim, attributed", and PR #85 put those five
sentences into `review-brief.sh` and into `template/.agents/skills/spec-review/SKILL.md` step 4, pinned by
`tests/spec-review/review-brief.sh:195,200`. The quoting rule is enforced by a test. The rule that the
prompt must come from a template at all is not stated anywhere.

## Other candidates, and why they are not it

**A. 2026-09-17T22:52:38.340Z, `c4adc431-...jsonl`.** The opposite worry, quoted because it bounds the rule:

> "did we accidentally neuter a certain orchestrator models ability to properly plan by telling it it had
> to pass my words only as opposed to my words PLUS? [...] we didnt accidentally take that ability away and
> force it into a single dimensional flattened communication style with its delegates where it can only pass
> what I said directly. [...] if the user says something and then the orchestrator gives thoughjts and the
> the user approves, then the users quotes PLUS (not 'or', but 'PLUS') the models suggestions that got
> approved can also be quoted".

So the template is a floor for the human's words, not a ceiling on the orchestrator's. Not recorded anywhere.

**B. 2026-09-23T19:43:20.670Z, `48857ffb-f0e5-4af1-9b36-ecddce7fb416.jsonl`.** Presupposes the templates exist
and asks the inventory question he is asking again now:

> "How many of our brief templates are doing this to us right now in the factory, and how many of them came
> from us as opposed to coming from a vendored skill?"

That question was answered on 2026-09-23 by the lane whose report is
`.scratch/program/leading-prompts-audit/report.md`: 31 prompt and brief templates for agents that judge work,
9 of them leading. It became ticket #137 and PR #140. It is a count, not the rule.

**C. Ticket #33 (2026-09-18), "Cheaper reviews: file pointers in the briefs, a junior lane for the Standards
axis".** This is where script-assembled briefs actually came from, and the reason given is cost, not leading
the witness. The quoted user line is "Ive seen a single important file passed to a subagent cut discovery and
context establishment tokens in half. [...] That last full turn you did including all the review and sub
agents cost close to a million tokens." The acceptance criterion is "hands each reviewer the changed-file
list, the standards sections that apply, and the ticket body pasted in, not commands to run". So the template
mechanism he remembers exists for a reason he did not give, which is why no rule sentence accompanies it.

**D. Ticket #74 / PR #75 (2026-09-18), the delegation hook.** Establishes that the orchestrator briefs and does
not do the work (P11, `docs/knowledge/core/DECISIONS.md:80`), and P19 at `:88`. It says who writes, never what
shape the briefing takes.

**E. Ledger, `docs/agents/ledger.md`.** Two lines touch brief construction and neither states the rule:
2026-09-18, "the ticket author's comments are spec; paste them into the brief"; 2026-09-21, "the brief is
checked against the design note before it is sent; a path an agent will type is tested the way it is typed".

**Searched and empty.** `docs/knowledge/core/PHILOSOPHY.md` (belief 9 is about context cost, not briefs),
`MANUAL.md`, `GLOSSARY.md`, `SCENARIO-TABLE.md`, `CONVERSATION-DIGEST.md`, `DECISIONS.md` (all 19 settled rows
and all 37 Provisional rows; P11, P16, P18, P20, P21, P27, P107, P109 touch brief *contents*, none the form),
`docs/M0-findings.md`, both `AGENTS.md`, `template/docs/agents/`, the memory directory, all 261 of Manuel's own
messages across the 21 factory918 transcripts, his messages in the four other project directories, and all
99 issues and 44 pull requests on the tracker.

## Where the templates are kept, for the review he wants

Three kinds, which is why no single list exists.

1. **Script-generated, ours.** `template/.agents/skills/spec-review/scripts/review-brief.sh` writes the
   Standards brief and the Spec brief. Its wording is mirrored in `template/.agents/skills/spec-review/SKILL.md`
   steps 4 and 5 (through `patches/mattpocock/spec-review.SKILL.md.patch`) and pinned byte-for-byte by
   `tests/spec-review/review-brief.sh`. `scripts/reading-pack.sh` supplies the `## Reading pack` section.
   One more of ours: the eval runner prompt at `tests/eval/reviewer/reviewer.py:642`.
2. **Prose reference templates, vendored.** `template/.agents/skills/*/references/*prompt*.md`, seven files
   (`architect/runner-prompt.md`, `how/critic-prompt.md`, `how/explainer-prompt.md`, `how/explorer-prompt.md`,
   `interrogate/reviewer-prompt.md`, `why/investigator-prompt.md`, `why/synthesizer-prompt.md`), plus the
   rubric and judgment references beside them, plus the brief text written inline in playbook steps
   (`poteto-mode/playbooks/*.md`).
3. **Lane wrappers.** `template/.claude/agents/pstack-*.md`, eleven identical bodies, and `poteto-agent.md`.

Everything else is freehand: an owner brief such as `.scratch/program/owner-brief.md`, and every ad-hoc lane
prompt an orchestrator types, including the five briefs of this run.

## Manuel's statements about constraining subagents' reading, cost or output

Chronological. All are his own words.

1. **2026-09-18T01:51:13.819Z**, `c4adc431-...jsonl`, on the 65K review-cost criterion in #33:
   "I dont like the shape of the proposed solution. It treats the under 65k as the non negitiable deliverable
   when the only actual desire was to optimize within highest accuracy. [...] But I prioritize accuracy over
   savings. So things like cutting the affective reliability of a test or the pass types is to me, outside the
   scope of the Issue."

2. **2026-09-18T04:28:32.347Z**, same file: "Im still gonna run in isolated contexts and eat the cost."
   Also: "the job was to make predetermined changes, NOT to reach a certain token count goal." The criterion was
   struck; see PR #39's body and the strikethrough in #33.

3. **2026-09-18T06:03:37.841Z**, `9ad61cb7-52b7-4140-a239-8363851f6d8a.jsonl`, on the #74 read cap:
   "im giving you a chance to defend against the philosophy of ticket 74. Are we neutering the orchestrator
   beyond what it can reasonably be expected to do, or simply increasng the cost of a task in order to force it
   to be done more safely and reliably?" (He let it through; the cap is execute-phase only, DECISIONS row 19,
   `docs/knowledge/core/DECISIONS.md:35`.)

4. **2026-09-21T19:23:46.412Z**, `0ea57ae6-3e89-47e8-9791-681c03e90497.jsonl`:
   "can you give me a link to read the brief you gave to the spec reviewer. I find it a little surprising it
   found nothing. Id just like to confirm we werent to harsh in limiting what it was allowed to review".

5. **2026-09-21T19:48:14.029Z**, same file, the strongest early one, quoted in ticket #86:
   "I saw that part of your brief saying not to read outside of the brief and it threw immediate red flags for
   me. A models intelligence often comes from the fact that it knows what to be curious about and look into it
   (as long as its a good model I mean) and so limiting what it can read to do its job sounds dangerous. How many
   of our skills/lanes/roles where we are relying on the model to fact check or have a wide understanding of the
   feature/codebase are we limiting what it can read, and how many of those limitations did WE add as opposed to
   what limitations came with the vendored skills as they came to us?"

6. **2026-09-21T18:12:14.295Z**, `a652bd71-...jsonl`, on an output quota: "'report what breaks. Then at most
   three hardening items.' This is going to consistently return a result with exactly 1 thing that breaks and
   exactly 3 things that can be hardened. I dont want that". Same message, the principle-over-proxy sentence:
   "The rigor of the test was the non negotiable from the start so the proposed solution to do less testing to
   meet the verification test was unacceptable."

7. **2026-09-22T22:16:33.848Z**, `8ade969a-ef50-40a4-9bc3-b470ce121a41.jsonl` (also in `b4a8ae9c` and
   `f5384b27`), the eco/safe message: "The guys whose thing is to find surprises should stay in fresh context,
   but maybe the other lanes dont need to." This is the one cost constraint he did ask for, and it constrains
   lane *count*, never a lane's reading.

8. **2026-09-23T19:43:20.670Z**, `48857ffb-...jsonl`: "400 word cap sounds like trying to save money on output
   tokens when thinking tokens make up the vast majority of token costs, not output. What a stupid level to
   manipulate. Zero items is expected is absolutely HORRENDOUS. [...] You are guiding the witness."

9. **2026-09-23T20:01:49.692Z**, same file: "we arent doing you r review info increase suggestion. We are keeping
   them equally blind. I HATE leading witness prompts." Ticket #137, PR #140.

10. **2026-09-23T20:39:08.408Z**, same file: "This sounds EXACTLY like prioritizing the verification step pass
    over the philosophy of the feature/factory itself. [...] Thats stupid and happens way too often even when we
    put it into our factory rules." Led to the P109 amendment in PR #135.

11. **2026-09-24T22:52:34.171Z**, same file, the broadest and most recent, and the message this lane was
    launched from: "I dont want you telling a reviewer what they CANT look at. You ONLY highlight things they
    CAN look at. [...] I would literally have you pass a subagent no brief at all than sit there and constrain
    them to only the files you THOUGHT were important before it started exploring. That drives me crazy. This is
    the case with pretty much every subagent."

Item 11 is recorded, as of 2026-09-24T22:54, in his memory file
`/Users/manuel/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/memory/principle-over-proxy.md`,
which is machine-level and ships to no project. Items 5, 8 and 9 are recorded in tickets #86 and #137 and shipped
in PRs #101 and #140. Items 1, 2, 3, 6 and 11's general half are in no repository file.

## What follows for him

The rule he remembers is real and he stated it clearly, but it lives only as a blockquote at the top of a
closed ticket from the factory's second week. Everything downstream of it (the brief script, the five quoted
sentences, the leading-prompt audit) was built for other reasons and happens to satisfy parts of it. If he wants
the rule to bind, it needs a DECISIONS row of its own saying that a subordinate's prompt comes from a named
template, that the human's words go into it verbatim, and that the orchestrator's own additions sit beside those
words rather than replacing them. There is no such row today.
