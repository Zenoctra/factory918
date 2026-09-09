<!-- lines: 19 | source: notes/2-theo.md | part 6/12 | title: Research note: Theo — 5. Why "don't copy them" -->

## Contents (line numbers are for the Read tool's offset)
- L6: 5. Why "don't copy them"

## 5. Why "don't copy them"

His argument, assembled from the Aug 11 2026 video [SECONDARY] and consistent with the repo [PRIMARY]:

1. **The value is the process, not the text.** "The real reason is the value of this isn't the exact things I instructed. It is the way I thought of it." His recommendation: "audit your own agent failure logs, identify recurring mistakes, and codify fixes into durable rules specific to your workflow." The enabling prompt he shared: **"Can you look through my history with models like Fable, Opus, and GPT-56 Soul to see what the most common mistakes are? Want to make sure we optimize to steer away from those."**
2. **Rules are derived from *his* failure ledger, per model.** His audit table: process killing (Opus 5), draft PRs (GPT-5.6 "Soul", ~40% of the time), overbuilding (Opus 5/4.8), request misreading (Opus 4.8), environment breakage (Opus 5 "worst by far"), unasked edits (only Soul), process neglect (Fable on process-heavy tasks), stopping early without verification (all). He also flagged the confound: "Fable looks worst because he assigns it hardest tasks with least context." Your models, tasks and machines produce a different ledger.
3. **Rules encode *his* environment.** `pkill` bans exist because *his* agent runs inside the dev server it might kill; `VACUUM INTO` exists because *his* real data lives at `~/.t3/userdata`; the fleet skills assume Tailscale, PostPlan, files.tslop.org, a Framework desktop. Copying them imports his infrastructure assumptions.
4. **Context is physics.** Every unnecessary line steers the model: "Less context is best as long as it has the context it needs." Copied rules that don't apply to you are pure noise.
5. **Tone is personal.** He writes as himself so the model answers like him: "If you talk a certain way to the model, the model's more likely to talk that way back, which is something I very much wanted." A copied voice is nobody's voice.
6. **He changes his mind quickly.** In May 2026 he said "You don't need all of that bullshit. I have almost zero skills installed. Just talk to the fucking model." By August he had spent "12–16 hours" on markdown and six skills. The artifacts are snapshots of an evolving practice, not a standard.

**[INFERRED]** The title is also a hedge against the cargo-cult pattern he criticizes elsewhere ("cognitive debt", "slot machine"): a beginner who pastes his AGENTS.md skips exactly the learning step — observing your own agent's mistakes — that made it work for him.

---
