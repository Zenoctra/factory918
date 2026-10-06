The map already exists, so this session charts it: settle the destination first, then the questions under it. A background search is still checking what already exists (the writing skills, current brief text, the earlier audits in `.scratch/`). Questions that depend on that search, such as where the standard should live, wait for the next round. The ones below don't depend on it.

❓ **Q1** - **Reword the destination around your correction**: The destination currently ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." That's the old framing you just replaced. Your note gives the test as whether a constraint was written with the agent's own, possibly better, strategy in mind. A proposed rewrite:

> A theory-of-mind writing standard for everything an agent writes to another agent or to a person (briefs, review briefs, handoff files, PR text, factory files); an audit and rework of the existing factory-authored files and briefs against it; and brief templates for the recurring subagent jobs, whose fixed parts leave the receiving agent free to choose how it pursues and completes the goal.

➡️ Use that wording, and add one line to Notes saying your 2026-09-30 comment replaces the "protect the world / shape the search" test. That way every later session reads the correction before it reads the old response.

---

❓ **Q2** - **Does this map plan the work, or also do it?** Wayfinder only plans by default. It ends with a spec handed to `/to-spec`, and execution tickets do the work. But the destination says "an audit and rework," which is doing. There are two ways to handle it:
- (a) The map ends when the standard is written and the audit's method is decided. The audit and rework become execution tickets afterwards.
- (b) The map also carries out the audit, because what the audit finds may change the standard. For example, an audit may turn up a failure the standard doesn't cover yet.

➡️ (a), with one exception: a small sample audit of a handful of real briefs, run inside the map as a check on the draft standard. That keeps the loop between standard and evidence without turning the map into the full rework.

---

❓ **Q3** - **What counts as "writing to a person"?** The destination names PR text. Your message also described the agent talking to you in chat, using words defined in context you never saw. Those are different surfaces:
- Chat replies to you in a session.
- Text that persists: PRs, tickets, comments, docs.
- Final reports a subagent hands back to the orchestrator, which the orchestrator then often relays to you.

➡️ All three are in scope for the standard, since they share the same root failure: the writer never pictures what the reader has in mind. The audit, though, covers only what persists in files: briefs, skills, playbooks and templates. Chat can't be audited after the fact except through transcripts, and that belongs to the optimization map's telemetry.

---

❓ **Q4** - **How do we know the standard made things better?** The optimization map plans an A/B benchmark for single-sentence changes, and its order says to take a baseline now and judge every other map against it. If this map lands first with nothing measured, its effect can never be shown afterwards.

➡️ Make one ticket on this map a task: record a baseline for one or two of the most-run brief types (likely the review briefs) before any rework lands. This map decides what "better" means for those briefs. Building the general benchmark stays with the optimization map.

---

❓ **Q5** - **Vendored skills**: You said the problem is "a deeply entrenched part of everything not vendored." Some briefs live in vendored skills (from Matt, pstack and others). Changing those takes a patch that `factory918 sync` re-applies. One question for you now: is vendored text in scope for the audit at all? The background search is looking up exactly which brief text is vendored.

➡️ In scope where a vendored skill writes briefs our subagents receive, because the reader suffers the same way whoever wrote the brief. Changes there go through `patches/`, and the audit flags them rather than rewriting upstream prose wholesale.