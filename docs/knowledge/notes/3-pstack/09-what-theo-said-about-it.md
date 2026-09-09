<!-- lines: 28 | source: notes/3-pstack.md | part 9/11 | title: Research note: pstack — What Theo said about it -->

## Contents (line numbers are for the Read tool's offset)
- L6: What Theo said about it

## What Theo said about it

**Primary source located.** YouTube video "So I tried Matt's skills..." by "Theo - t3․gg" (https://www.youtube.com/@t3dotgg), video ID `0oXOOlqVu5M`, https://www.youtube.com/watch?v=0oXOOlqVu5M, published 2026-08-19, about 38 minutes (title/channel confirmed via YouTube oEmbed through noembed.com; date and length from the daily.dev mirror https://daily.dev/posts/so-i-tried-matt-s-skills--0f5yy5jlx). The video compares Matt Pocock's skills repo with pstack; per a daily.dev commenter, Lauren's skills occupy "All the rest of the video" after the Pocock section. I could not play the video from this environment; the verbatim lines below come from an auto-transcript served by youtubetotranscript.com (https://youtubetotranscript.com/transcript?v=0oXOOlqVu5M) and should be treated as near-verbatim (auto-captions).

What he said (transcript-derived):

- Introduction: "PA stack created by Lauren, otherwise known as Potato, one of my old favorite React core team members, who is now at Cursor" ("PA stack" is the caption's rendering of "pstack").
- On unslop: "This skill has fundamentally changed my willingness to read the things that my agents say to me." and "I think everyone should have unslop at this point."
- On blast-radius: "This one is great and has cpped [sic; likely 'capped' or 'caught'] a couple things that would have been miserable if I didn't have it. It also calls out that you can't trust your own writeup."
- On arena: "This has been a very fun skill for those of us who are uh token burners because we have a bunch of usage to get through."
- On technical-writing/"writing for agents": "I've mostly been using this for prompting sub aents and it's been very helpful there." On teach: "Teach is one I've heard really good things about."
- On how he tried them (no plugin install): "you copy the text, go to your agent...and then you paste it." and "I did all of this in a thread in T3 code in a repo that I already made called fleet where I manage all of my like skill files and things."
- His main criticism: the skills are "tied to cursor specifically, which is the biggest issue", and he would "be pumped if somebody like cloned all the Pstack skills in a generic not cursor specific way." (The ports in the Tools section are exactly that; pstack-claude predates the video, open-pstack's current release is from 2026-09-03.)
- Verdict: "I find Pstack writing to be a lot more readable and also the behaviors from these skills to be a lot more applicable for my day-to-day...I am much more philosophically aligned with what Potato is cooking." The daily.dev summary's phrasing: pstack's skills are "more philosophically aligned and readable, though some tie specifically to the Cursor platform."
- Contrast with Pocock's set: "He also has disable model invocation on for a lot of his skills, which means the model won't enable it itself." (pstack does the same, though he does not say so in the quoted passage.)

Other summaries agree: youtubesummary.com calls pstack "fun but surprisingly powerful" and says the skills highlighted were Teach, Arena, Blast radius, Show your work, unslop, and that the recommended approach is "auditing actual usage patterns and selectively testing skills through copy-paste evaluation before full adoption."

**Adoption evidence.** Unslop is the skill he says he uses. Circumstantial: T3 Code's own test fixtures use `unslop` as the example skill name (`https://github.com/pingdotgg/t3code/blob/f559fe0b/apps/web/src/components/chat/composerSlashCommandSearch.test.ts`, lines 161–220, and `apps/web/src/providerSkillSearch.test.ts`, line 75), which suggests it was installed on a maintainer's machine when those tests were written (unverified which maintainer). T3 Code's `AGENTS.md` does not import pstack or its principles; it has its own "note from Theo" ("fight for the smallest model that makes the correct behavior unsurprising") and a babysitting rule that reads like a compressed Babysit playbook ("verify each bot finding against the source, fix real ones, dismiss false positives with a written reason"), but there is no citation, so treat any influence as unproven.

**Context that matters for Manuel.** Theo's praise is selective and sits inside a longer skepticism about skill packs. In "How I code with AI changed a lot" (~May 2026, https://finance.biggo.com/podcast/c7c3cb2193d150d2): "You don't need all of that bullshit. I have almost zero skills installed. Just talk to the fucking model. They're smart enough now." In "My AGENTS.md & SKILLS.md Breakdown (Don't copy them)" (2026-08-11, https://finance.biggo.com/news/63e17fcb23548c16): "Less context is best as long as it has the context it needs." So his pstack take is: take the good individual skills (unslop, blast-radius, teach, arena when you have tokens to burn), be wary of the Cursor coupling, and copy-paste rather than install wholesale. I found no evidence he adopted `/poteto-mode` as a router, the 21 principles as a system, or the overnight playbooks. His post "It does have one problem though: It is slop ..." (2026-08-14, https://x.com/theo/status/2088127851929423990) surfaced in searches but could not be read; unverified whether it concerns pstack.

---
