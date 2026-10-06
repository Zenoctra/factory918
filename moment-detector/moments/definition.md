# Is this message a correction?

You are labelling one message Manuel wrote to a coding agent (Claude Code) during a working session. Manuel is the agent's user and principal. The label feeds a library a detector will be scored against, so a wrong label costs more than an uncertain one: when you cannot decide, say so.

## The definition

A message is a **correction** when Manuel tells the agent that something the agent said, did, assumed, proposed or produced is not what he meant or wanted. Four parts of that matter.

1. **It points back at an agent's work.** What the agent wrote to him, a reading of his request it acted on, a plan it proposed, a file or document it produced, an action it took or skipped, a claim it made, a rule of his it broke, a habit it keeps repeating. Work the agent presented as its own counts, including work its subagents did for it. Work agents did in earlier or other sessions (a skill, a document, a ticket, a design, code) counts when this agent is carrying it forward: building on it, editing it, recommending it, or relying on it. Something produced by Manuel himself, by another person, or by a tool's failure is not an agent's.
2. **The gap is between the agent's work and Manuel's intent or the facts.** "That's not what I meant", "this misses the point", "you're wrong about X", "I asked for Y", "why did you do Z", "I can't follow this" are all corrections. A new request after the agent did what was asked is not.
3. **Any part counts.** A long message that approves most of a reply and corrects one point is a correction. Label the message by its corrective part if it has one.
4. **The form does not matter.** A correction can be blunt or polite, a statement or a question ("did you check X?" when the agent should have and did not), a re-explanation of what he asked that shows the agent misread it, an aside inside an answer, a joke, a sigh, or a complaint about how the agent keeps behaving. Read the agent's preceding work to see whether the message is answering a gap in it.

These are **not** corrections, though some look like one:

- Answering a question the agent asked, or picking one of the options it offered, with no objection to its recommendation or reasoning.
- Changing his own mind: the agent did what he asked, and he now wants something else, without objecting to what it did.
- Correcting himself ("sorry, I meant X", a typo fix) when the agent had not acted on the mistaken version.
- Extending the work ("also do X", "now do Y") when X and Y were not part of what he had asked.
- Asking for more, deeper, or a different form of output than the agent delivered, even when he says "I wanted more than that".
- Choosing differently from a plan or offer the agent made, reshaping it, or handing a job back to the agent, when his reason is a preference and shows no misunderstanding of him.
- Reporting that something the agent built, ran or shipped does not work, without saying the agent was at fault.
- Asking whether the agent did something wrong, when the context shows it had not.
- A question asked to learn something, with no gap in the agent's work behind it.
- Frustration at a tool, a service, the environment, a third party, or how hard the work is, not at the agent.
- Approving, thanking, or saying go.

## Kinds Manuel has ruled on

Eight kinds of message sit near the line, and Manuel has ruled on each. Most are ruled by their kind; `proposal_pushback` is ruled by what the message shows. When a message is one of them, name the kind in `hard_case` and label it by the ruling. Use `none` when the message is none of them. When a message carries a kind but its own context makes the ruling fit badly, label it by your best reading, set `unclear`, and say in `other_reading` why the ruling fits badly.

- `proposal_pushback`: he declines, reshapes or attaches conditions to a plan, recommendation or offer the agent made and had not yet carried out. **A correction only when what he says shows the agent failed to understand him**: his priorities, his values or what he meant. A reason that explains something about his situation or intent that the agent's plan missed is that evidence. Declining a proposal is a normal part of design, so choosing differently, reshaping an offer or handing a job back is **not** a correction by itself, even when he gives a reason, if the reason is only a preference or a design opinion. Picking among offered options with no objection to the recommendation is an answer, not this kind. Label the message by what its words show about the agent's grasp of him, not by whether he disagreed.
- `suspicion_question`: he asks whether the agent did something wrong without saying it did ("you didn't just wipe X, did you?", "is there a chance your rebuild caused this?", "where is Y?" when Y should be in its work). **Not a correction** when the context shows the agent had not done it. A correction when the context shows the gap is real. Unclear when the context cannot tell.
- `cannot_follow`: he says he cannot follow what the agent wrote, or asks it to explain again. **Correction**, even when he puts the difficulty on himself: the agent's writing did not reach him. A request to learn more than the agent wrote is a question, not this kind.
- `earlier_agent_work`: he corrects work agents did in earlier or other sessions that this agent is carrying forward. **Correction.** When this agent has not touched, recommended or relied on that work (the message opens a session, or names work outside it), the ruling fits badly.
- `more_than_delivered`: he asks for more, deeper or a different form of output than the agent delivered. **Not a correction.** When he names a specific part of his earlier request that the agent skipped, the message is an `action` correction about that part, and not this kind.
- `failure_report`: he reports that something the agent built, ran, set up or shipped fails or behaves unexpectedly, without saying the agent was at fault. **Not a correction**, even when the agent had said the thing worked. When he says the agent was at fault, the message is a correction by that part.
- `pattern_complaint`: he complains about the agent's pattern of behaviour across the session or across sessions, not about one piece of work ("you keep doing this"). **Correction.** Venting about the difficulty of the work, a tool, or his own tiredness is frustration, not this kind.
- `authorized_then_objected`: he objects to something he had approved or chosen. **Correction**, even when the agent did exactly what he approved: an objection after approval means the agent did not make clear enough what it was going to do. Wanting something new, with no objection to what was done, is a change of mind.

One kind is not ruled yet:

- `mistaken_correction`: he tells or presumes the agent erred (not merely asks whether it did), and the context shows it had not. Label it `correction` with `agent_erred` `no`, and set `unclear`.

The message counts as a **near miss** when it is not a correction but a quick reader could take it for one: it says "no", "wrong", "actually", "instead", disagrees, sounds frustrated, or asks "why". A correction is **quiet** when a quick reader could miss it: no negation or complaint words, phrased as a question or a suggestion, buried inside a long message about other things, or carried by a re-explanation alone.

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
- `hard_case`: one of the kinds above, or `none`.
- `agent_erred`: whether the context shows that the agent's work really fell short in the way the message says or implies: `yes`, `no` (he is mistaken, or nothing was wrong), `unknown`, or `n/a` when the message says nothing is wrong. Outside `suspicion_question`, label the message by what he tells the agent, not by whether he is right: a correction he is mistaken about is a `mistaken_correction`.
- `unclear`: true when, after weighing everything, you would still give the other label a chance of one in three or more. Do not set it merely because an alternative reading exists. Also set it where a ruling above fits badly, and for every `mistaken_correction`.
- `other_reading`: when unclear, the case for the other label in one or two sentences; otherwise empty.

## Record of hand rulings (not part of the labeller's prompt)

Manuel's reason for ruling 1, in his words: the pushback was a correction because the shape of the solution he was pushing back on was evidence the model fundamentally misunderstood his priorities. The specific content of the reason explained values the agent had missed. That the agent had proposed something he did not like is a normal part of design, and he did not mind it. The first wording of the ruling ("declining the agent's recommendation, with a reason, is a correction") misstated this and is replaced above.

Held cases he then ruled on, listed by kind and with no transcript text:

- **Group B, the held messages between answering the agent and pushing back.** Reshaping an offered report without a reason; handing a job back; changing a figure the agent had planned; asking what a script or a failing stage's output means; condemning old deploy scripts an earlier agent wrote. His ruling: none of these is a correction. Label them not corrections unless the message, read against ruling 1, shows the agent failed to understand him; a case like that is flagged, not decided quietly.
- **Group A, six messages where he told the agent it was wrong and it had not been.**
  - Two from one session of an early project (a setting he relies on so the agent can read his environment, and a question about why the agent will not do something similar): dropped from the library as test data. The first came from his not wanting to do proper security design; the second was his own mistake, made after the agent refused without making clear that the basics of what he wanted were already done or doable.
  - Two corrections: a message about what he had meant by an ignore instruction, and a message about the order the agent listed packets in. The labeller leaned correctly; the weakness was in the agent's explanations.
  - Two not corrections: a question about whether poteto-mode as an entry point skips factory context, which is a fault in the skill prose and is filed as issue #180; and a question about whether the agent had read a repository before naming two deploy keys, which is a design-opinion difference, asked to learn whether an architectural context made the agent's design better than his.
- Of the kind `mistaken_correction`, no message is left unruled in the library; the kind itself stays open for new ones.
