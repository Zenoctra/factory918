# Original moment 832548a0-fb5a-4cbe-9d39-5c976ff24eb9 (2026-09-30T18:08:54.034Z)

## Text

The map for "Write to agents with theory of mind" exists, but nobody has charted it yet. It has a destination and your notes, but no tickets. So this session charts it: first we settle the destination, then we map out the open questions, then I create the tickets. A background agent is taking stock of what already exists (the writing skills, every place one agent briefs another, the old audits in `.scratch/`). Questions that depend on its findings will wait for a later round.

The destination as it stands: *"A theory-of-mind writing standard for everything an agent writes to another agent or to a person … an audit and rework of the existing factory-authored files and briefs against it; and brief templates for the recurring lane jobs whose fixed parts never shape the search."*

❓ **Q1 – Does the map end in a plan or in finished work?** By default, a wayfinder map ends when every decision is made, and then `/to-spec` and `/to-tickets` turn those decisions into build tickets. The current destination names the audit and the rework as deliverables, which means doing the work inside the map itself. The alternative is that the map ends with a spec, and the standard, the audit and the templates get built afterward through ordinary tickets.

➡️ It ends in a spec. The standard is the thing every later piece gets checked against, so it should be settled before anything is rewritten against it. The one exception I'd allow is a small trial inside the map: rewrite a single real brief under the draft standard and compare it with the original. A decision ticket might need that evidence.

---

❓ **Q2 – What replaces "whose fixed parts never shape the search"?** Your note from today throws out that test. There are a few ways to handle the wording:
- (a) Replace it with your sentence as written: "don't constrain the design architecture of how the task is pursued or completed."
- (b) Replace it with the test in the sentence after that one: a template's fixed part holds only constraints written with the reader's own better strategy in mind, and each one states its reason.
- (c) Take the criterion out of the destination entirely. The destination just says "brief templates for the recurring lane jobs", and working out what makes a template safe becomes a decision ticket.

➡️ (c). The destination should name what gets delivered, not settle the hardest open question ahead of time. Writing any criterion into the destination repeats the same mistake: it hands every later session an answer before they've looked at the question.

---

❓ **Q3 – Who counts as the reader?** The destination covers writing to agents and to people. Your message separates two jobs: auditing the files that already exist, and writing new communication from scratch. There's also a third surface: text an agent writes to a person (PR bodies, replies, reports), where the failure is jargon that was defined in a context the person never saw. Options:
- (a) All three are in scope.
- (b) Agent-to-agent only. Person-facing text already has `unslop` and `technical-writing`.
- (c) All three for the standard, but agent-to-agent first in the audit and templates.

➡️ (a), treated as one standard. Your point was that it's one failure, "the writer never pictures the reader", no matter who the reader is. Splitting the standard by audience would make it two standards. Whether `unslop` and `technical-writing` fold into it is a later question, and it will depend on what the background agent finds.

---

❓ **Q4 – Factory-only, or part of the product?** Agents inside every project write briefs too. Anything placed under `template/` ships to every project. Anything outside it improves only the factory.

➡️ It's part of the product. The standard, and any templates for lane jobs that exist in projects, go under `template/`. The audit also covers the factory's own files, since they're read by the same kind of reader.

---

❓ **Q5 – How will we know it worked?** You said these failures happen silently and pile up. Map #145 (token use and wall-clock time) plans an A/B benchmark for single-sentence changes. Options:
- (a) This map defines its own test of success, such as the same review task briefed the old way and the new way, with the results compared.
- (b) This map adopts #145's benchmark and waits for it.
- (c) No measurement here: judge the standard by reading it.

➡️ (a), kept small, and designed so it can later run inside #145's benchmark. If this map waits for #145, it stalls. If it has no measurement, a writing standard can sound right and still change nothing. A second agent reading the draft standard or a rewritten brief is also a reader, so how we test it needs the same care as how we write it.

## Tool calls in the same response
