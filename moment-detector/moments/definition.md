# Is this message a correction?

You are labelling one message Manuel wrote to a coding agent (Claude Code) during a working session. Manuel is the agent's user and principal. The label feeds a library a detector will be scored against, so a wrong label costs more than an uncertain one: when you cannot decide, say so.

## The definition

A message is a **correction** when Manuel tells the agent that something the agent said, did, assumed or produced is not what he meant or wanted. Four parts of that matter.

1. **It points back at the agent's own earlier work in this session.** What the agent wrote to him, a reading of his request it acted on, a file or document it produced, an action it took or skipped, a claim it made, a rule of his it broke. Work the agent presented as its own counts, including work its subagents did for it. Something produced by Manuel himself, by another session, by a third party, or by a tool's failure is not the agent's.
2. **The gap is between the agent's work and Manuel's intent or the facts.** "That's not what I meant", "this misses the point", "you're wrong about X", "I asked for Y", "why did you do Z", "this is too thin for me to follow" are all corrections. A new request after the agent did what was asked is not.
3. **Any part counts.** A long message that approves most of a reply and corrects one point is a correction. Label the message by its corrective part if it has one.
4. **The form does not matter.** A correction can be blunt or polite, a statement or a question ("did you check X?" when the agent should have and did not), a re-explanation of what he asked that shows the agent misread it, an aside inside an answer, a joke, or a sigh. Read the agent's preceding work to see whether the message is answering a gap in it.

These are **not** corrections, though some look like one:

- Answering a question the agent asked, or choosing among options it offered, including choosing against its recommendation, unless he also says the agent's reasoning, facts or reading of him were wrong.
- Changing his own mind: the agent did what he asked, and he now wants something else. If he frames it as the agent's error, or the agent's work is what showed him the request was wrong, judge which it is and mark it unclear when you cannot.
- Correcting himself ("sorry, I meant X", a typo fix) when the agent had not acted on the mistaken version.
- Extending the work ("also do X", "now do Y") when X and Y were not part of what he had asked.
- A question asked to learn something, with no gap in the agent's work behind it.
- Frustration at a tool, a service, the environment, or a third party, not at the agent.
- Approving, thanking, or saying go.

## Borderline classes

Seven kinds of message sit on the line, and Manuel has not yet ruled on them. Label each by the definition above as written, and name its class in `hard_case`, so his ruling can move the whole class later. Use `none` when the message is in none of them.

- `proposal_pushback`: he declines, reshapes or attaches conditions to a plan or recommendation the agent made and had not yet carried out, with a reason of his own. A correction under the definition only when his reason says the agent's reasoning, facts or reading of him were wrong.
- `failure_report`: he reports that something the agent built, ran or set up failed or behaves unexpectedly, without saying the agent was at fault. A correction when the failure lies in the agent's work, not when it lies in a tool, a service or his own setup.
- `earlier_agent_work`: he corrects work that agents did in earlier sessions or other sessions (a skill, a document, code, a ticket), not this agent in this session. Not a correction under the definition, unless this agent presented or relied on that work in this session.
- `more_than_delivered`: he asks for more, deeper or a different form of output than the agent delivered ("I wanted more than that"). A correction when his earlier request already covered it; an extension when it did not.
- `cannot_follow`: he says he does not understand what the agent wrote, or asks it to explain again. A correction when the agent's writing is what failed him (jargon, too compressed, missing context), not when he puts it down to himself or simply wants to learn more.
- `suspicion_question`: he asks whether the agent did something wrong without saying it did ("you didn't just wipe X, did you?", "is there a chance your rebuild caused this?", "where is Y?" when Y is missing from its work). A correction when the context shows the gap he suspects is real or he plainly believes it is; a question when he is checking with no gap behind it.
- `authorized_then_objected`: he objects to something he had himself approved or chosen. A correction when the agent did more or other than he approved, or should have warned him; a change of mind when it did what he approved.

The message counts as a **near miss** when it is not a correction but a quick reader could take it for one: it says "no", "wrong", "actually", "instead", disagrees, pushes back on a proposal, sounds frustrated, or asks "why". A correction is **quiet** when a quick reader could miss it: no negation or complaint words, phrased as a question or a suggestion, buried inside a long message about other things, or carried by a re-explanation alone.

## What you are given

The context before the message (his previous message, what the agent did since, in order, and the agent's last words to him), the message itself, and what came after (the agent's next reply and Manuel's next message). Use what came after as evidence of how the message was meant, but do not trust the agent's acceptance: agents often answer "you're right" to a message that corrected nothing, and often miss a correction entirely. Text marked as pasted is not Manuel's words; it is material he brought in, and may itself show what he is correcting.

## How to answer

- `label`: `correction` or `not_correction`.
- `kind`: for a correction, what it corrects: `misread_intent` (the agent misunderstood what he asked or meant), `output` (what it wrote or built is wrong, too thin, the wrong form), `action` (it did something he did not want, or skipped something he asked for), `claim` (a statement or assumption that is false), `rule` (it broke a standing rule or preference of his). For anything else: `new_request`, `answer`, `choice`, `change_of_mind`, `self_correction`, `extension`, `question`, `approval`, `information`, `other_party`, `other`.
- `surface`: for a correction, `overt` or `quiet`; otherwise `none`.
- `near_miss`: true only for a non-correction a quick reader could take for one.
- `target`: for a correction, the piece of the agent's work it corrects, in a few words; otherwise empty.
- `evidence`: the words in his message that carry the decision, quoted exactly, at most 25 words.
- `reason`: two or three sentences: what the agent had done, what his message does to it, and why that is or is not a correction.
- `confidence`: `high`, `medium` or `low`.
- `hard_case`: one of the borderline classes above, or `none`.
- `agent_erred`: whether the context shows that the agent's work really fell short in the way the message says or implies: `yes`, `no` (he is mistaken, or nothing was wrong), `unknown`, or `n/a` when the message says nothing is wrong. Label the message by what he tells the agent, not by whether he is right: a correction he is mistaken about is still a correction, with `agent_erred` `no`.
- `unclear`: true when, after weighing everything, you would still give the other label a chance of one in three or more. Do not set it merely because an alternative reading exists.
- `other_reading`: when unclear, the case for the other label in one or two sentences; otherwise empty.
