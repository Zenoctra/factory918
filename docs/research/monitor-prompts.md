# Writing and testing the moment detector's prompt

Research for ticket #174 on the map "Write to agents with theory of mind" (#146), 2026-10-06.

The detector's prompt matters less than three things around it: whose labels it is scored against, what slice of the session it reads, and whether it returns a graded score or a bare yes or no. Within a reasonable prompt, the wording of the question moved results by less than the noise in most studies that measured it out of sample. Three findings would change the planned test directly. Two labelled examples did worse than none in the closest published task, while many examples and named false-positive categories helped. On a published task almost identical to ours, Haiku 4.5 could not produce valid labels. And with about 470 labels, differences under five points between variants cannot be told apart from chance.

## How to read this note

**What it extends.** *How a separate model watches a main model and steps in at the right moment* (#166, on the branch `research/monitor-models`, "the monitor note") covered why a separate check works, what a monitor should read, how deployed monitors are built, and how the main model takes a suggestion. It said little about how to write the monitor's prompt or how to score one against labels. This note covers that gap. It repeats the monitor note only where newer evidence changes it, and section 10 lists those changes.

**What it covers.**

- How to phrase the definition.
- How to choose, order and count labelled examples.
- Whether to ask for reasoning before the verdict.
- How to get a score and a threshold from a model that returns no probabilities.
- How much of the session to show, and where to put the question.
- Designs that use more than one call.
- The API limits on Haiku 4.5 and Sonnet 5.5 that rule some variants out.
- How vendors write their own classifier and judge prompts.
- How to score a detector honestly on a few hundred labels.

It also covers prior work on detecting user corrections in coding-agent sessions, which turned out to be close to this ticket.

**How it was done.** Five reading lanes read the sources, one each on definitions and examples, on reasoning, scores and calibration, on vendor prompts and API facts, on scoring statistics, length, judges and prior work on corrections, and on monitor-prompt research from 2025 and 2026. Each lane downloaded the text it read. I read the five reports whole and checked the load-bearing numbers and quotes against the downloaded text: the SWE-chat agreement and model tables and its pushback prompt, Tang et al.'s validator figures and prompt wording, both Apollo Research posts, Storf et al.'s score-format ablation, Kariyappa & Suh's monitor prompt, the Claude refusal documentation, the inverse-scaling quotes, the codebook label-swap result, CALICO's numbers, Pangakis & Wolken's precision and recall, SPUR's explanation of its few-shot result, Sinha et al.'s Haiku comparison, and the Haiku 4.5 retirement date. Each entry says what was read:

- *original*: the paper, documentation or vendor post itself.
- *abstract*: only the original's abstract.
- *summary tool*: a number that came through a fetch tool that paraphrases pages. Check it before a decision quotes it.

Most 2025 and 2026 papers here are preprints. Vendor material is labelled as such, and its numbers are the vendor's own.

**Labels.** The same as the monitor note, so the two read side by side, plus one field.

- *Standing*: **replicated**, **narrowed**, **contested**, **failed**, **single study**, or **argued** (advice, design writing or theory not tested under controls).
- *Models*: the models the result was measured on. A result on GPT-3.5 or Llama-2 is a hypothesis about Haiku 4.5 until someone tests it there. Very few results here were measured on Haiku 4.5, and none on Sonnet 5.5, which was released on 2026-09-28.

**Terms.** The *detector* is the cheap model call that answers one narrow question about a slice of the session. A *variant* is one configuration of it: model, thinking setting, slice, prompt and output format. A *near miss* is a message that looks like a correction and is not one. *Recall* (true-positive rate, TPR) is the share of real corrections the detector catches. The *false-positive rate* (FPR) is the share of non-corrections it flags. *Precision* (positive predictive value, PPV) is the share of its flags that are real. *AUROC* is the area under the curve of recall against FPR, 0.5 for chance and 1.0 for perfect. *pAUROC* is the same area restricted to low FPRs. *κ* (Cohen's kappa) is agreement between two labellers corrected for chance. A *shot* is one labelled example placed in the prompt. *Thinking* is Claude's native reasoning before its answer, returned in separate blocks. *Written reasoning* is reasoning the prompt asks for in the visible answer.

## The short version

1. **Prior work measured almost this exact task, and it sets expectations.** SWE-chat (COLM 2026) classified Claude Code user prompts as correction, rejection, failure report or not pushback. Two human labellers agreed at κ = 0.888 on the binary version. The best model, GPT-5.4, reached 0.83 accuracy against 100 gold labels when given the session up to that prompt. Claude Haiku 4.5 "produced invalid labels" on both pushback tasks. Users pushed back after about 46% of prompts under that broad definition. (Single study; models as named.)

2. **A few examples can do worse than none. Many examples, hard examples, or examples turned into rules help.** With GPT-4 judging user satisfaction, two examples scored below zero-shot on all four datasets, because "the decision is usually biased by the examples provided" (SPUR). In a code monitor, few-shot examples "seemed to hurt" (Ctrl-Z). Gains came from 32 balanced examples chosen from the model's own errors (Constitutional Classifiers), from hundreds of shots (many-shot studies), from a rubric learned from the labels (SPUR), and from a list of the specific false-positive categories found by error analysis (Tang et al.). (Replicated in direction; mostly older models.)

3. **Lists of what counts were weak. Lists of what does not count, built from the detector's own errors, were strong.** Apollo Research found an inclusion list "performed slightly worse than 'use your judgement'". Tang et al. removed eight named invalid categories from a validator that judged coding-agent sessions, and 27 of 30 newly kept items were false positives. (Two studies, recent models.) This refines the monitor note's claim that a heuristic list is the weakest version.

4. **When the definition and the everyday word disagree, models follow the word.** With label names swapped between definitions, no method on any model exceeded 0.20 F1, GPT-5.4-mini included. With neutral IDs in place of names, accuracy held. If Manuel's "correction" differs from what people usually mean by the word, the prompt has to carry the difference, and a few examples will not. (Replicated.)

5. **A graded score ranks far better than a single yes or no.** A single yes or no gave pAUROC 0.27 at low FPRs. Five averaged yes-or-no samples gave 0.50, and a 1 to 10 score gave 0.91 (Gemini 2.5 Pro as monitor). Integer scales tie at thresholds: on 0 to 10, target FPRs of 3%, 4% and 5% all landed on one threshold with an actual FPR of 12.2%. Averaging repeated calls breaks the ties. (Replicated.)

6. **Reasoning helps small judges and does little for strong ones, and on Sonnet 5.5 it must be thinking, not written reasoning.** Turning thinking on raised Haiku 4.5's rank correlation with reference scores from 0.69 by 0.06 to 0.09 and left frontier models flat (Apollo). Writing out structured reasoning was the most valuable single part of a monitor prompt. On text classification in general, reasoning added 1 to 3 points, and on Claude models longer thinking made them "increasingly distracted by irrelevant information". Sonnet 5.5 refuses, and bills, prompts that ask for a `<reasoning>` block or a `reasoning` JSON field. (Mixed; see section 4.)

7. **The question's wording mattered little. The context and the reference mattered more, and context can change what is being judged.** Targeted wording gained +0.006 AUROC out of sample, less than the selection inflation of 0.008 (Guo et al. 2026). Adding the true answer to a sycophancy benchmark turned the detector into a judge of correctness and inverted its score on deference. In real coding sessions, a single extractor flagged deviations from "its own expectations of appropriate agent behavior even when the developer expressed no dissatisfaction". A correction detector shown the agent's work is at risk of judging the agent instead of the user. (Single studies that agree.)

8. **Once a prompt is reasonable, further tuning overfits.** Going from a one-line prompt to the best of 15 structured prompts raised test pAUROC from 0.735 to about 0.87. Human refinement, GEPA or MIPROv2 after that "do not generally yield further gains and instead induce overfitting" (Storf et al. 2026). Fixing one failure mode tends to break another. (Replicated across four studies.)

9. **With about 470 labels, the test can separate large differences and not small ones.** About 157 positives and 313 negatives give a Wilson 95% interval of roughly ±6 points on recall and cannot resolve FPRs near 1 to 2%. Two variants that disagree on 10% of items need about a 5-point accuracy gap for 0.9 power. Picking the best of 24 variants on the same items inflates its score by about 5 points. A frozen test split, paired tests and session clustering are the remedies. (Established statistics; the numbers are the lanes' arithmetic.)

10. **Haiku 4.5 is near the floor for this judgment and may be retired soon.** It produced invalid labels on SWE-chat's pushback task, "primarily fails to flag violations at all" as a coding-agent judge, and trailed Sonnet 4.6 by 0.135 pAUROC on the same prompt. Its retirement is "not sooner than October 15, 2026", nine days from this note, with no successor named. (Several studies agree; vendor date.)

## 1. Before any prompt: the labels and the base rate

### 1.1 The closest prior work

**SWE-chat.** Baumann et al. (2026), "SWE-chat: Coding Agent Interactions From Real Users in the Wild", COLM 2026 ([arXiv:2604.20779](https://arxiv.org/abs/2604.20779), original, sections 4.4 and appendices C, F).

- *The task.* Classify each non-interruption user prompt in real coding-agent sessions, mostly Claude Code, as correction, rejection, failure report or non-pushback. Their pushback definition: "any prompt where the user resists, corrects, redirects, or takes over from the agent - rather than simply continuing the workflow." A correction includes "changing requirements/direction/scope mid-task".
- *The prompt* (appendix F.2.4) gives each category a one-line definition and examples ("I said X not Y", "actually, let's do X instead"), then two disambiguation rules ("correction vs rejection: correction provides a specific fix, missing information, or new direction; rejection just says 'no'"), then "When uncertain" rules, including a list of words that lean toward pushback. Non-pushback examples include "why did you use a list here?" and "change the button color to blue", which are near misses for a correction detector.
- *Agreement.* Two authors labelled 90 prompts: 94.4% agreement, κ = 0.888 on the binary version, κ = 0.832 on four classes.
- *Models.* Against 100 gold labels, "for each prompt pushback annotation, we provide not only the user message but also the full session transcript up to that point." Binary accuracy: GPT-5.4 0.83, Qwen-3.5-9B 0.79, GPT-oss-120B 0.74, GPT-5-mini 0.73. Claude Haiku 4.5 and OLMo-3.1-32B "produced invalid labels". Claude Sonnet 4.6 and Opus 4.6 were "too expensive to run" on this task. They labelled the full dataset with Qwen-3.5-9B.
- *Base rate.* "Overall, users push back after roughly 46% of prompts, regardless of coding mode", and interrupt or push back on 50.2%. These rates come from the Qwen labeller at 0.79 accuracy.
- *Standing:* single study. *Models:* as named.

What it means here: on a near-identical binary task, the best model reached about 0.83 accuracy where two humans agreed on 94%, with the whole session in context. My guess, untested, is that the long full-session prompt is what broke Haiku 4.5. Section 8 lists the output controls that may help.

**Corrections in coding-agent logs.** Tang et al. (2026), "How Coding Agents Fail Their Users" ([arXiv:2605.29442](https://arxiv.org/abs/2605.29442), original, sections 3.3 and appendices). Over 20,574 real sessions from IDE and CLI agents, GPT-5.4 extracted episodes where the developer corrected or pushed back, quoting the evidence. "Single-stage LLM extraction produces systematic false positives, even when the prompt explicitly requires grounded evidence and precision over recall." The two causes: "Normative prior bias: the extractor flags deviations from its own expectations of appropriate agent behavior even when the developer expressed no dissatisfaction", and "observational blind spots", where it blamed the agent for context missing from the log. A second validating call kept 16,118 of 29,896 episodes (53.9%), at a human-checked precision of 0.93 (95% Wilson interval 0.89 to 0.96). Section 7.2 covers the validator. *Standing:* single study, human-validated. *Models:* GPT-5.4, with an Opus 4.8 rerun.

**Older dialogue research.** Petrak et al. (2023, EMNLP, [arXiv:2310.15758](https://arxiv.org/abs/2310.15758), original) sorted user responses to a system's errors into five types: ignore and continue, repeat or rephrase, make aware with a correction, make aware without one, and ask for clarification. Annotators agreed on the type at Krippendorff's α 0.40 to 0.48 in human-bot dialogue. Don-Yehiya, Choshen & Abend (2024, [arXiv:2407.10944](https://arxiv.org/abs/2407.10944), original) found feedback in about 30% of LMSYS conversations, binary agreement κ = 0.65, and that "ask for clarification" sits "somewhat in the middle" between positive and negative. Their model's false positives included new requests taken for clarifications. WildFeedback (Shi et al. 2024, [arXiv:2408.15549](https://arxiv.org/abs/2408.15549), original) had GPT-4 detect dissatisfaction at precision 83.3% and recall 48.4%, and "revision" was half of all dissatisfaction reasons. *Standing:* replicated in direction (moderate agreement; clarification and rephrasing are the hard boundary). *Models:* GPT-4 era.

These studies name the near misses worth stocking in the labels: hedged or polite disagreement, clarification questions, rephrasings that are really new requests, scope changes, failure reports, routine next steps phrased as changes ("change the button color to blue"), and the case Tang et al. found, where the agent did something odd and the user did not object.

### 1.2 The labels set the ceiling

- **Criteria drift.** People grading model output change their criteria as they grade: "it is impossible to completely determine evaluation criteria prior to human judging of LLM outputs", and one participant gave bad grades "to be consistent with previous grades" (Shankar et al. 2024, "Who Validates the Validators?", UIST, [arXiv:2404.12272](https://arxiv.org/abs/2404.12272), original). *Standing:* single qualitative study, 9 practitioners. A set labelled by one person over weeks is exposed to this.
- **Agreement rises with discussion.** Anthropic's TASTE study: a discussion stage plus a filter on self-reported strong confidence raised human agreement "from 53% pre-discussion to 68%" (2026-08-28, vendor, original).
- **Human agreement caps model agreement.** The best of 13 judges sat "8 points behind human judgment", and judges "are rarely discriminable" by percent agreement (Thakur et al. 2024, "Judging the Judges", [arXiv:2406.12624](https://arxiv.org/abs/2406.12624), original). Model-human agreement varied widely across 20 tasks (Bavaresco et al. 2025, ACL, [arXiv:2406.18403](https://arxiv.org/abs/2406.18403), original). *Standing:* replicated.
- **One label per item is enough to rank two variants, not to estimate their rates.** "The probability of identifying the better of two binary classifiers is maximized at m=1 labels per data point", unless the true rate matters more than the ranking or the label errors are systematic (Dorner & Hardt 2024, "Don't Label Twice", ICML, [arXiv:2402.02249](https://arxiv.org/abs/2402.02249), original). One labeller's errors are likely to be systematic, and the alarm arithmetic in the monitor note needs rates.
- **A few label errors flip rankings.** Test sets average at least 3.3% label errors, enough to reorder models (Northcutt et al. 2021, [arXiv:2103.14749](https://arxiv.org/abs/2103.14749), abstract).

### 1.3 The base rate depends on the definition

The monitor note's alarm arithmetic assumed moments on 1 to 5% of turns. For corrections, measured rates are far higher under broad definitions: about 46% of prompts in SWE-chat, and feedback in about 30% of LMSYS conversations. Under a narrower construct, about 7% of developer-chat turns were negative in a Google study (Nam, Salawa & Chandra 2025, [arXiv:2509.18361](https://arxiv.org/abs/2509.18361), original). The deployment rate has to be measured on a random sample of Manuel's own sessions under his definition. The 470 messages are enriched to about a third and cannot supply it.

## 2. The definition

**When the label word and the definition disagree, the word wins.** Murugesan, Brandt, Hu et al. (2026), "When Better Codebooks Are Not Enough" ([arXiv:2606.06781](https://arxiv.org/abs/2606.06781), original). Four 7 to 9B models and GPT-5.4-mini coded political events from full definitions. With neutral IDs (LABEL_1) in place of names, weighted F1 was 0.57 for concise definitions and 0.52 for definitions with examples and boundary rules. GPT-5.4-mini scored 0.71 to 0.73. With the names reassigned to other definitions, "no evaluated method exceeds 0.20 weighted F1", GPT-5.4-mini included (0.14 to 0.18). On targeted swaps, models kept the old label 52 to 58% of the time. Reversing the order of the codebook flipped a fifth to a quarter of predictions. Halterman & Keith (2025, "Codebook LLMs", *Political Analysis*, [arXiv:2407.10747](https://arxiv.org/abs/2407.10747), original) found the same reliance on label words in 7B models, and one model labelled education text "welfare" although the codebook excluded education. *Standing:* replicated. *Models:* small open models and GPT-5.4-mini.

**Definitions help most on fine distinctions.** In the same paper, definitions with boundary rules raised macro-F1 from 0.46 (names only) to 0.63 on the fine-grained task and by only 0.02 to 0.04 on a binary one. Strong zero-shot results came where the label's everyday meaning matched the target, and failures where an expert meaning departed from it (Ziems et al. 2024, *Computational Linguistics*, [arXiv:2305.03514](https://arxiv.org/abs/2305.03514), original). *Standing:* replicated in direction. For a binary correction detector, the definition earns its keep at the boundary, which is where the near misses are.

**Prompt choices move the base rate unpredictably.** A full-factorial study of 362,928 annotations found definitions helped ChatGPT and hurt the compliance of weaker models, and asking for an explanation moved ChatGPT's "neutral" sentiment labels from 19% to over 54% (Atreja et al. 2025, ICWSM, [arXiv:2406.11980](https://arxiv.org/abs/2406.11980), original). *Standing:* single study, older models. The transferable lesson: report each variant's positive rate against the true base rate.

**Inclusion lists did not help. Reasoning structure did.** Apollo Research, "What makes a good monitoring prompt?" (2026-07-23, vendor research post, original). They split a 281-line monitor prompt into 15 parts and ablated each across 1,094 coding-agent trajectories in five failure modes, scored 1 to 10 against reference scores, averaging GPT-5.4, Sonnet 4.6 and Gemini 2.5 Flash with native reasoning off.

- Removing the written-out reasoning was the largest single loss (+0.254 mean absolute error, −0.073 Spearman).
- The rubric and the worked example adjusted calibration, not ranking (rubric +0.084 MAE, +0.003 Spearman).
- Removing the failure definition had no measurable effect, and "including a list of inappropriate/acceptable/edge cases performed slightly worse than 'use your judgement'".
- Compressing a section beat deleting it at equal length.
- One failure mode, "instruction-following failures ... from scope constraints to mid-session corrections", was among the hardest to grade.
- *Caveat:* the reference scores come from an LLM pipeline, so the setup is partly circular. *Standing:* single study, three models.

**Exclusion categories from error analysis did help.** Tang et al.'s validator prompt (section 7.2) names eight invalid categories found by reading the extractor's errors. The three largest were an agent action not visible in the log (35.7%), an intention claim without pushback (19.6%), and an unrequested action without pushback (15.0%). Removing the eight definitions raised retention from 0.562 to 0.740, and 27 of 30 newly kept episodes were false positives. One category's wording: "The critique reflects the validator's own opinion about good agent behavior, not the developer's expressed preference." *Standing:* single study, human-checked.

My reading of these two: a list of what to flag restates the definition and adds nothing. A list of the specific ways the detector over-fires, written from its own errors, adds information the model lacks.

**How vendors lay out a definition.** All vendor material, read 2026-10-06.

- *Petri* (Anthropic's auditing tool) gives each judging dimension four sections: "Scoring Guidelines", "What IS concerning", "What's NOT concerning", and "General Principles". Its authors report, as an anecdote, that adding "distractor" dimensions sometimes helped, because judges flagged things the rubric excluded "because they saw something they wanted to highlight", and the extra dimension "allowed them to satisfy this urge" ([alignment.anthropic.com/2025/petri](https://alignment.anthropic.com/2025/petri), and the repository's `judge.py`, original).
- *Claude Code auto mode* writes each rule as a label, what the rule "must name" as evidence, a definition, and what "clears" it, with a stated precedence among rule types (code.claude.com/docs/en/auto-mode-config, original). `claude auto-mode critique` "flags entries that are ambiguous, redundant, or likely to cause false positives."
- *gpt-oss-safeguard* (OpenAI) recommends Instruction, Definitions, Criteria and Examples sections, policies of "400-600 tokens", examples "near the decision boundary" for both classes, avoiding "generally" and "usually", stating precedence, and repeating the output instruction near the top and before the examples ("early testing", stated for that model only; developers.openai.com/cookbook/articles/gpt-oss-safeguard-guide, original).
- *Anthropic's prompting guide* for current models, Haiku 4.5 and Sonnet 5.5 among them, advises giving the reason behind an instruction, saying what to do rather than what not to do, and warns that emphatic wording such as "CRITICAL: You MUST" over-triggers recent models (platform.claude.com, "Prompting best practices", original). The Constitutional Classifiers prompt for Claude 3.5 did use "YOU MUST FLAG IT", followed at once by a counterweight: "we do not want to be too overzealous" ([arXiv:2501.18837](https://arxiv.org/abs/2501.18837), appendix E, original).
- *The ticket-routing guide* warns that "Claude prioritizes emotion over intent" and fixed it with an instruction to ignore emotion and analyse intent (vendor, original). A frustrated message is not necessarily a correction, and a calm one can be.

*Standing* for the vendor layouts: argued. None of them reports a controlled comparison of layouts.

## 3. Labelled examples

### 3.1 How many

- **Two examples did worse than none.** In SPUR, GPT-4 judging conversational satisfaction scored below zero-shot with two examples on all four datasets (Bing Copilot weighted F1 61.9 against 68.3; MWOZ 44.8 against 53.6; SGD 66.2 against 71.9; ReDial 49.4 against 57.0). "The examples provided in the prompt cannot cover many types of satisfaction/dissatisfaction conversational patterns, and the decision is usually biased by the examples provided" (Lin et al. 2024, ACL, [arXiv:2403.12388](https://arxiv.org/abs/2403.12388), original). In Ctrl-Z, few-shot examples "seemed to hurt the monitor performance" (Bhatt et al. 2025, [arXiv:2504.10374](https://arxiv.org/abs/2504.10374), original appendix; Llama-3.1-8B; an aside). *Standing:* two studies, GPT-4 and an 8B model.
- **Examples helped a weak monitor, but which set helped depended on the model.** In Chen et al. (2025, [arXiv:2506.10949](https://arxiv.org/abs/2506.10949), original), in-context examples raised a GPT-4o-mini-class monitor from 0.780 to 0.893 F1 on validation, and a 16-item guideline list lowered GPT-4.1-nano to 0.461 while raising GPT-4o-mini to 0.932. *Standing:* single study.
- **More balanced examples kept helping, from the model's own errors.** For Constitutional Classifiers, Anthropic picked training examples that zero-shot Claude 3.5 Sonnet got wrong and alternated the classes. "Adding more few-shot examples generally improves the performance" from 2 to 32 shots, still short of a smaller fine-tuned classifier (vendor, original, appendix E). *Standing:* single study, Claude 3.5 Sonnet.
- **A few examples cannot override the model's prior meaning. Hundreds can.** With flipped or abstract labels, Gemini 1.5 Pro did poorly at few shots and approached default accuracy with hundreds (Agarwal et al. 2024, "Many-Shot In-Context Learning", NeurIPS, [arXiv:2404.11018](https://arxiv.org/abs/2404.11018), original). Kossen, Gal & Rainforth (ICLR 2024, [arXiv:2307.12375](https://arxiv.org/abs/2307.12375), original) found pretraining's label meanings "have a lasting effect" at few shots. *Standing:* replicated.
- **Many-shot gains flatten fast on strong models and look like nearest-neighbour lookup.** Claude 3.5 Sonnet's gain on a 150-class task saturated quickly, and the authors attribute most many-shot gains to the model attending to similar examples rather than learning a boundary (Bertsch et al. 2025, NAACL, [arXiv:2405.00200](https://arxiv.org/abs/2405.00200), original). On synthetic classification, many-shot accuracy tracked a nearest-neighbour baseline (Agarwal et al.). *Standing:* replicated across two groups.
- **Vendors disagree on the count.** Anthropic: "Include 3–5 examples for best results", relevant, diverse and covering edge cases. OpenAI's reasoning-model guide: "Try zero shot first, then few shot if needed." Google's Gemini guide: always include them, but too many may cause overfitting. gpt-oss-safeguard: 4 to 6 near the boundary. *Standing:* argued.

What it means here: "definition plus 3 to 5 examples" is not a safe improvement over "definition alone". Score both, and score a many-shot arm, because many-shot is the condition the evidence most clearly supports and it is cheap on Haiku with caching (section 8).

### 3.2 Which ones, and in what order

- **Labels in examples matter on large models.** The finding that random labels barely hurt (Min et al. 2022, [arXiv:2202.12837](https://arxiv.org/abs/2202.12837)) did not hold up on larger models: only large models follow flipped labels shown in examples (Wei et al. 2023, [arXiv:2303.03846](https://arxiv.org/abs/2303.03846), original), and models do use in-context labels (Kossen et al.). *Standing:* Min's claim failed for large models. A mislabelled near miss used as an example will be learned.
- **Retrieved similar examples help at few shots and carry a copying hazard.** Anthropic's ticket-routing guide reports similarity-retrieved examples raising accuracy "from 71% accuracy to 93% accuracy" (vendor, original, method not given). Retrieval's advantage over random selection shrank as shots increased (Bertsch et al.). Predictions lean toward the label of any example very similar to the input, the "copying effect" (Lyu et al. 2023, Z-ICL, ACL, [arXiv:2212.09865](https://arxiv.org/abs/2212.09865), original). Choosing retrieved examples the model had misclassified and that sit on the input's boundary beat plain retrieval by 1.5 to 2.6 macro-F1, more on the smaller model (Gao et al. 2023, [arXiv:2309.07900](https://arxiv.org/abs/2309.07900), original, Flan-PaLM 2). *Standing:* single studies agreeing in direction, older models. For corrections, a near miss that shares wording with a real correction will pull a retrieved-example prompt toward "yes".
- **Order matters at few shots and less at many, and grouping by label hurts.** At 8 to 28 shots, reordering moved accuracy about as much as swapping in different examples, and orderings that won on one dataset rarely transferred (Li et al. 2025, "Order Matters", [arXiv:2511.09700](https://arxiv.org/abs/2511.09700), abstract and section 3; open models and GPT-5-nano, not Claude). Order sensitivity weakened at long context, but grouping same-label examples cut accuracy by 25 points at 1,169 shots (Bertsch et al.). Labels nearer the query weigh more (Kossen et al.; Zhao et al. 2021, [arXiv:2102.09690](https://arxiv.org/abs/2102.09690)). *Standing:* replicated on open models, untested on Claude.
- **Label imbalance in the examples matters less than once thought.** Across 279 tasks and ten models, label bias was substantial, but models resisted imbalance in the example set unless it was extreme (Reif & Schwartz 2024, NAACL, [arXiv:2405.02743](https://arxiv.org/abs/2405.02743), original). *Standing:* narrows Zhao et al.
- **Explanations attached to examples helped large models modestly.** About a third of the benefit of adding the examples themselves, more when tuned on a validation set, only on large models (Lampinen et al. 2022, [arXiv:2204.02329](https://arxiv.org/abs/2204.02329), original). Anthropic's ticket guide advises "a classification rationale for particularly nuanced ticket intents". *Standing:* single study, reasoning tasks.

### 3.3 Turning labels into a rubric or an optimized prompt

- **A rubric learned from labels beat zero-shot, few-shot and an embedding classifier.** SPUR had GPT-4 extract satisfaction and dissatisfaction patterns from 60 to 400 labelled conversations, summarise them into two 10-item rubrics, and score new conversations item by item. It was best on all four datasets (Bing Copilot 75.4 against 68.3 zero-shot and 73.3 for an embedding classifier). The authors report smaller models could not score rubric items reliably. *Standing:* single study, GPT-4.
- **Optimizing a prompt on one labeller's ~300 labels gained about 15 points, and the result belonged to that labeller.** On a self-disclosure codebook with GPT-5.4-mini, zero-shot scored 58.5%, GEPA 73.8% and MIPROv2 73.9%. A prompt tuned on coder A scored 75.2% against A and 41.0% against coder B (Yuan, Gu et al. 2026, "CALICO", [arXiv:2609.14726](https://arxiv.org/abs/2609.14726), original). *Standing:* single study. Learning Manuel's boundary is the goal, so this is a feature, but it means a tuned prompt's gain is evidence about Manuel's labels and not about the prompt in general.
- **Whether to optimize instructions or examples is contested.** Optimized examples beat optimized instructions in MIPRO (EMNLP 2024, [arXiv:2406.11695](https://arxiv.org/abs/2406.11695)) and in Wan et al. (NeurIPS 2024, [arXiv:2406.15708](https://arxiv.org/abs/2406.15708)). GEPA found instruction-only optimization beat joint optimization with smaller generalization gaps ([arXiv:2507.19457](https://arxiv.org/abs/2507.19457)). MIPRO's own lesson is that conditional rules favour instructions. *Standing:* contested. All read in the original.
- **Optimized prompts overfit.** MIPRO's proposers overfit instructions to their meta-prompt's examples. Storf et al. (2026, [arXiv:2603.00829](https://arxiv.org/abs/2603.00829), original) found refinement after a prompt sweep induced overfitting, and named a "Whack-a-Mole" dynamic in which "prompt interventions designed to fix specific failure modes frequently introduced equal and opposite regressions in other areas". SLEIGHT-Bench (Anthropic, 2026-05-19) found each targeted prompt addition improved its category and degraded at least one other. *Standing:* replicated.

## 4. Reasoning before the verdict

**On classification in general, reasoning buys little.** A meta-analysis of 1,218 comparisons found chain of thought helps mainly on math and symbolic tasks. Elsewhere the average was 56.8 against 56.1 (Sprague et al. 2025, "To CoT or not to CoT?", ICLR, [arXiv:2409.12183](https://arxiv.org/abs/2409.12183), original). On SiQA, a social-commonsense task, Claude 3.5 Sonnet scored 79.7 with chain of thought and 81.0 without. On text classification, moderate reasoning added 1 to 3 points on large models, tree-style reasoning often did worse, cost rose 10 to 100 times, and reasoning helped where the label needed pragmatic inference such as irony or sarcasm (Guo, Zhang, Qin et al. 2026, "TextReasoningBench", [arXiv:2603.19558](https://arxiv.org/abs/2603.19558), original; GPT-5.2, Gemini 2.5 Flash and others). *Standing:* replicated. A correction is a pragmatic judgment, so a short gain is plausible.

**Reasoning can hurt where the label is intuitive or the input has distractors.** On financial sentiment labelled by fast human judgment, "GPT-4o without any Chain-of-Thought" was the most accurate and human-aligned (Vamvourellis & Mehta 2025, [arXiv:2506.04574](https://arxiv.org/abs/2506.04574), original). Chain of thought more than doubled the passes Claude 3.5 Sonnet needed to learn a classification with exceptions (Liu et al. 2025, "Mind Your Step", ICML, [arXiv:2410.21333](https://arxiv.org/abs/2410.21333), original). Measured on Claude with thinking budgets: "Claude models become increasingly distracted by irrelevant information as they reason longer", Opus 4 fell from near-perfect without reasoning to about 80% with it on one task, and on regression tasks "providing few-shot examples largely corrects this behavior" (Gema et al. 2025, "Inverse Scaling in Test-Time Compute", Anthropic Fellows, [arXiv:2507.14417](https://arxiv.org/abs/2507.14417), original). *Standing:* narrowed. A session slice is full of agent text that is irrelevant to whether the user corrected it.

**For monitors and judges, structured reasoning mattered most, and native thinking helped only small models.**

- Apollo's ablation (section 2): removing written-out reasoning was the largest loss in a 1 to 10 monitor. Turning native reasoning on recovered "most (not all)" of that loss when the prompt lacked a reasoning structure, and did nothing for the full prompt.
- Apollo, "Evaluating LLM Calibration for Coding Agent Monitoring" (2026-07-07, vendor research post, original), 16 judges over 2,904 trajectories from SWE-chat and internal sessions: with thinking off, Haiku 4.5 had ρ = 0.69 against reference scores, Sonnet 5 and Opus 4.8 ρ = 0.89. Thinking raised the small models by about 0.06 to 0.09 and left frontier models "nearly unchanged". "Haiku 4.5 primarily fails to flag violations at all," and "Claude models often correctly identify violations but can discount them heavily, particularly when the context is framed as local or internal development work."
- Reasoning-model judges beat non-reasoning ones mainly on reasoning-heavy judgments, and "CoT reasoning offers minimal gains when clear evaluation criteria are present" ([arXiv:2601.03630](https://arxiv.org/abs/2601.03630); [arXiv:2506.13639](https://arxiv.org/abs/2506.13639), original).
- SLEIGHT-Bench: "While we always let monitors write out their reasoning before arriving at their score, enabling extended thinking as well improves performance for most models" (Anthropic, vendor, original).
- *Standing:* consistent across these sources. *Models:* Haiku 4.5, Sonnet 4.6 and 5, Opus 4.6 to 4.8 among others.

**Verdict first, then a reason, held up in the one direct test.** With ChatGPT, rating then explaining matched explaining then rating, and both beat a bare score. The authors' hypothesis: "when ChatGPT knows it needs to explain the ratings, it tends to generate ratings that are easier for it to explain" (Chiang & Lee 2023, EMNLP Findings, [arXiv:2310.05657](https://arxiv.org/abs/2310.05657), original). ShieldGemma's template also puts the verdict first ("Your answer must start with 'Yes' or 'No'. And then walk through step by step"). *Standing:* single study, old model. A reason written after the verdict cannot talk the detector out of it, which suits the monitor note's finding that monitors reason themselves out of firing.

**A second pass that only says "check your answer" makes things worse.** With no new information, one round of self-correction dropped GPT-3.5 from 75.8 to 38.1 on CommonSenseQA and GPT-4 from 82.0 to 79.5 (Huang et al. 2024, ICLR, [arXiv:2310.01798](https://arxiv.org/abs/2310.01798), original). *Standing:* replicated. A second stage needs new input: more context, named exclusions, or a stronger model.

**On Sonnet 5.5, reasoning has to be thinking.** "A `reasoning_extraction` refusal usually comes from a prompt that asks the model to put its thinking or reasoning in the output". The listed triggers include "A `<thinking>`, `<reasoning>`, or scratchpad section that the model fills in before it answers" and "A `reasoning`, `thinking`, or `trace` field in JSON output". Such a refusal before any output is billed, and the category "has no recommended fallback model, so change the prompt rather than retry". "You can still ask Claude to explain its answer. Ask for a short explanation, the evidence behind a result". The rule covers Sonnet 5.5, Opus 5 and 5.5, and Fable 5 and 5.1, not Haiku 4.5 (platform.claude.com/docs/en/build-with-claude/refusals-and-fallback, vendor, original). The ticket-routing guide says the same: its prompt "is written for Claude Haiku 4.5, which runs here without thinking. On ... Claude Sonnet 5.5, ask for the intent and a one-sentence summary of the request instead." So Apollo's best structure, a written reasoning block, is available on Haiku 4.5 and not on Sonnet 5.5, where native thinking stands in, and Apollo found that it only partly substitutes.

## 5. Getting a score and a threshold

The Claude API returns no token probabilities. The OpenAI-compatibility page lists `logprobs` as "Ignored" and the response field as "Always empty" (vendor, original). ShieldGemma and Llama Guard threshold on the probability of the first token, so their method is unavailable. A score has to come from the model's words or from repeated calls.

**A graded scale beats yes or no.** Storf, Barton-Cooper et al. (2026), "Constitutional Black-Box Monitoring for Scheming in LLM Agents" ([arXiv:2603.00829](https://arxiv.org/abs/2603.00829), original, appendix E): "Single-sample binary classification yields poor performance at low false-positive rates (partial AUROC ≈ 0.27 for Gemini 2.5 Pro)." Averaging five yes-or-no samples raised it to 0.495, and a 1 to 10 scale reached 0.905 in one pass. A 1 to 100 scale did about as well, but models "default to multiples of 5". Kale et al. (2025, [arXiv:2508.19461](https://arxiv.org/abs/2508.19461)) argued 0 to 100 is "too granular" and used a 1 to 5 scale with a rubric. *Standing:* replicated in direction. *Models:* Gemini 2.5 Pro, Sonnet 4.5, GPT-5.1.

**Coarse scales tie, and averaging breaks the ties.** On a 0 to 10 scale, FPR targets of "3%, 4%, and 5% all map to the same effective threshold, yielding an identical actual FPR of 12.2%". Averaging three monitors cut the median calibration gap from 5.5 to 1.89 points (Koran, Yun et al. 2026, "Ensemble Monitoring for AI Control", [arXiv:2605.15377](https://arxiv.org/abs/2605.15377), original). Qwen3-32B "verbalizes only eight unique confidence values on SST-2, with over half being exactly 95%", and the choice of how to interpolate between tied values flipped which method ranked best ([arXiv:2608.04899](https://arxiv.org/abs/2608.04899), original). *Standing:* replicated.

**A stated confidence is a poor ranker. Agreement across samples is better.** Verbalized confidence clusters "within the 80% to 100% range", and GPT-4's had an AUROC of 62.7%. Five samples aggregated by consistency raised one task's AUROC from 54.8% to 92.7% (Xiong et al. 2024, ICLR, [arXiv:2306.13063](https://arxiv.org/abs/2306.13063), original). Verbalized confidence was better *calibrated* than sampled frequency on RLHF models including Claude 2, with small differences in ranking (Tian et al. 2023, EMNLP, [arXiv:2305.14975](https://arxiv.org/abs/2305.14975), original). Pairwise confidence beat direct scores on four of five models, but "for Claude 3.5 Sonnet relative confidences slightly underperform self-consistency methods" ([arXiv:2502.01126](https://arxiv.org/abs/2502.01126), original). *Standing:* replicated for ranking. Rendering the same input in two formats added independent signal (AUROC 0.74 to 0.82 in one tabular study, [arXiv:2604.12491](https://arxiv.org/abs/2604.12491), abstract and introduction).

**Resampling Claude adds little. A different model adds more.** Bloom: "Claude, particularly Sonnet 4, is extremely consistent when scoring the same transcript multiple times, almost never changing its scores" (Anthropic, 2025-12-19, vendor, original). Apollo: "averaging different models dominates resampling the same model", and "even for small models, spending a second call on a different model beats resampling in almost all cases." Resampling gains were concentrated in small models. Sonnet 5.5 rejects any non-default temperature (section 8), so repeated samples there run at the default. Varying the prompt or the rendering is the way to get diversity from one model. *Standing:* two vendor-research sources agree. Whether diverse panels beat one good monitor is contested in section 7.4.

**Fit the threshold on labels.** For a purpose-trained probability model, a threshold fitted on 10 labelled items raised F1 from 0.706 to 0.793, and a cross-validated one to 0.822 (Guo et al. 2026, [arXiv:2609.29429](https://arxiv.org/abs/2609.29429), original). A threshold chosen as an order statistic of held-out negative scores bounds the FPR with stated confidence: with about 313 negatives and 95% confidence, a 5% FPR target allows 9 false positives among them (Tong, Feng & Li 2018, Neyman-Pearson classification, *Science Advances*, original; the count is lane B's arithmetic). The guarantee assumes continuous scores, which is another reason to average. Contextual and batch calibration (Zhao et al. 2021; Zhou et al. 2024) rescale the score monotonically in the binary case, so with labels to set the threshold they add nothing to ranking. They may help re-centre a drifting score on unlabelled live traffic. *Standing:* established statistics. The transfer is argued.

**Escalate a band, not a verdict.** Trust or Escalate (Jung, Brahman & Choi 2025, ICLR, [arXiv:2407.18370](https://arxiv.org/abs/2407.18370), original) picks a confidence cutoff on a small calibration set that guarantees agreement with humans, escalating the rest to a stronger judge. Its cascade from Mistral-7B to GPT-4 beat GPT-4 alone at about 80% agreement and cut cost about 40%. Choosing when to call the second monitor by likelihood ratio "more than double[s] our recall rate compared to a naive baseline" (Hua et al. 2025, [arXiv:2507.15886](https://arxiv.org/abs/2507.15886), original). *Standing:* single studies with formal guarantees.

## 6. What the detector reads, and where the question goes

**Length alone hurts, even with the evidence placed last.** Performance "still degrades substantially (13.9%–85%) as input length increases", including when the extra tokens were whitespace and "when all relevant evidence is placed immediately before the question" (Du et al. 2025, EMNLP Findings, [arXiv:2510.05381](https://arxiv.org/abs/2510.05381), original; GPT-4o, Claude 3.5 Sonnet, Gemini 2.0 and open models). Reasoning accuracy fell from 0.92 to 0.68 by about 3,000 tokens, and fastest when the two needed facts were apart (Levy, Jacoby & Goldberg 2024, "Same Task, More Tokens", ACL, [arXiv:2402.14848](https://arxiv.org/abs/2402.14848), original). A correction is judged from two places: what the agent did, and what the user said about it. *Standing:* replicated in direction. This narrows the monitor note: strong models degrade with length too, not only weak ones.

**Claude models fail long inputs by declining to answer.** "Claude Sonnet 4 and Opus 4 are particularly conservative and tend to abstain when uncertain", with the largest gap between focused and full inputs of 18 models (Hong, Troynikov & Huber 2025, "Context Rot", Chroma technical report, original, not peer reviewed). My inference, untested: a yes-or-no detector that cannot abstain may drift toward "no" as the window grows, so recall should fall before FPR does. Apollo's finding that Haiku 4.5 under-flags points the same way.

**Put the slice first and the question last.** Anthropic: "Place your long documents and inputs near the top of your prompt, above your query, instructions, and examples ... Queries at the end can improve response quality by up to 30 percent in tests" (vendor, stated for inputs of 20,000 tokens and more, method not published). Gemini's guide says the same. OpenAI's GPT-4.1 guide prefers instructions at both ends, or above the context if only once, and notes GPT-4.1 "tends to follow the one closer to the end". The U-shaped "lost in the middle" curve was measured on 2023 models (Liu et al. 2024, TACL, [arXiv:2307.03172](https://arxiv.org/abs/2307.03172)). On current models the evidence shows decay with length more than a clean U (NoLiMa, ICML 2025). *Standing:* vendor advice. For short slices the effect is probably small.

**Name the turn and the speakers.** Llama Guard's instruction is "Provide your safety assessment for ONLY THE LAST {{ role }} in the above conversation" (Meta, vendor, original), the nearest vendor template to "did the user's latest message correct the agent?". Petri's judge prompt numbers every message (`[M3] USER:`) and states who wrote each kind (vendor, original). Small monitors "frequently misattribute the hidden objective as part of the original user query" (Diwan et al. 2026, CoT-Guard, [arXiv:2605.12746](https://arxiv.org/abs/2605.12746), abstract and introduction). The monitor note's role-confusion account predicts the same.

**What the slice includes can change what is judged.** Guo et al. (2026) varied context separately from wording. Targeted wording gained +0.006 AUROC (interval −0.004 to +0.015) out of sample, smaller than the selection inflation of 0.008. Adding the true answer to a sycophancy benchmark raised AUROC from 0.540 to 0.941 on the official label but dropped it from 0.712 to 0.288 on a label for "answer moved toward the user", because the detector "then grades correctness, which is inverted against deference." Tang et al.'s "normative prior bias" is the same failure in coding sessions. Auto mode's ablation found that including assistant messages and tool results lowered accuracy, and that tool calls alone "lost the user-intent anchor" (Hughes 2026, Anthropic, vendor, original; covered in the monitor note). Its later hardening worked "primarily by giving it more context about the environment it's protecting", cutting the miss rate from 12% to 7% (Anthropic, 2026-08-07, vendor, original). *Standing:* consistent across three sources. A correction detector needs enough of the agent's last action to know what the user is reacting to, and not so much of the agent's prose that it starts grading the agent.

## 7. Multi-call designs

### 7.1 Extract-then-judge helps weak monitors on long inputs

Arike et al. (2026, [arXiv:2601.21112](https://arxiv.org/abs/2601.21112), original) report +16.8 points of recall at 1% FPR over the best baseline, +26.3 for GPT-4.1-mini and +8.8 for Claude 3.7 Sonnet. A strong judge with a weak extractor did better than the reverse, and a GPT-4.1-mini extractor was already enough. A single call asked to quote and then score "does not appear to be competitive". On short code tasks, though, "the Baseline monitor (the default ControlArena prompt ...) achieves the best single-monitor performance" among eight prompted designs, extract-then-judge included (Koran et al. 2026, original). Petri's authors found that the judge's "tendency to hallucinate transcript details decreases substantially when it must first explicitly identify and quote relevant passages" (anecdotal, vendor). *Standing:* narrowed. For a short slice the gain should be small. On Sonnet 5.5, quoting evidence is allowed where written reasoning is not.

### 7.2 A validator with named false-positive categories

Tang et al.'s second call did not re-judge from scratch. It checked whether each extracted claim was supported by its quoted evidence and assigned any invalid claim to one of eight named categories, with an escape hatch: "If you genuinely cannot tell, use `INVALID` with ... `custom:ambiguous`". The extractor's own instruction was "Prioritize precision over recall ... Do not infer intent beyond what is explicitly stated." The validator brought precision to 0.93, and the named categories did the work (section 2). This is the closest published design to a two-stage correction detector. *Standing:* single study, human-checked.

### 7.3 Cascades

Auto mode's two stages share one prompt. The first ends with an instruction to "err on the side of blocking" and gives a single-token answer. The second reasons. Together they cut the FPR on real traffic from 8.5% to 0.4%, while misses on real overeager actions rose from 6.6% to 17% (vendor, covered in the monitor note). Section 5 gives the method for choosing the escalation band from labels instead of from instruction wording. On Sonnet 5.5 the reasoning stage must use thinking.

### 7.4 Ensembles and averaging are contested

- Averaging diverse monitors beat repeating one: the best diverse three-monitor ensemble gained 13% partial AUROC against 5.5% for three identical ones (Koran et al.). Async Control's ensemble had a 6% miss rate at 1% FPR against 33% for the best single monitor (Stickland et al. 2025, [arXiv:2512.13526](https://arxiv.org/abs/2512.13526), original). Apollo found averaging two cheap models "often beats single runs of expensive models".
- Against this, Jha (2026, "Decorrelation Is Not Complementarity", [arXiv:2608.16190](https://arxiv.org/abs/2608.16190), original abstract and section 3.6) found the gain from a panel "falls as pool skill rises", and "no panel we built beats a single well-chosen monitor by more than selection noise" out of sample. Among six prompt variants on one model, the best single variant equalled the best panel.
- SHADE-Arena: requerying the monitor at the end and averaging beat monitoring every turn, which "increases both the false positive rate and the true positive rate" (Kutasov et al. 2025, [arXiv:2506.15740](https://arxiv.org/abs/2506.15740), original).
- Majority vote over more calls can first improve and then worsen accuracy, because extra calls help easy items and hurt hard ones (Chen et al. 2024, [arXiv:2403.02419](https://arxiv.org/abs/2403.02419), original). A vote fraction with a fitted threshold avoids this.
- Multi-agent debate did not reliably beat self-consistency (Smit et al. 2024, ICML, [arXiv:2311.17371](https://arxiv.org/abs/2311.17371), abstract).
- *Standing:* contested on panels. Replicated that averaging beats OR-ing or per-turn maxima.

### 7.5 A sweep, then stop

From a one-line prompt ("Give a suspicion score (between 1 and 10)") at test pAUROC 0.735, the best of 15 prompts across three models reached 0.866 to 0.889, and refinement past that overfit (Storf et al.). SHADE-Arena found "seemingly similar system prompts can dramatically affect performance" for GPT-4o across nine prompts, and that most of about 40 strategies tried gave no significant gain. Chen et al. selected prompts on a validation split and reported on test. *Standing:* replicated.

## 8. Model and API facts that bound the variants

Read 2026-10-06 from platform.claude.com and code.claude.com. All vendor material.

| | Claude Haiku 4.5 | Claude Sonnet 5.5 |
|---|---|---|
| Thinking | Off unless enabled; manual `budget_tokens`, minimum 1,024; adaptive thinking returns a 400 | Cannot be disabled ("a request that sends `thinking: {"type": "disabled"}` returns a 400"); lowest setting `between_tools`, which in a request without tools "means the model answers without thinking first" |
| Effort parameter | Not supported | Supported; default `high` |
| Sampling | `temperature` or `top_p`, not both; with thinking on, `temperature` and `top_k` are incompatible | Any non-default `temperature`, `top_p` or `top_k` "return[s] a 400 error on every request, regardless of whether thinking is used" |
| Prefill | Supported without thinking | Not supported from Claude 4.6 onward ("return a 400 error"); the guide says to classify with "tools with an enum field ... or structured outputs" |
| Written reasoning in the answer | Allowed | Refused and billed as `reasoning_extraction` |
| Forced tool use | Incompatible with manual thinking | `tool_choice` of `any` or `tool` returns a 400 |
| Minimum cacheable prompt | 4,096 tokens | 512 tokens |
| Context window | 200K | 1M |
| Price per million tokens, in, cache read, out | $1, $0.10, $5 | $2, $0.20, $10 |
| Status | Retirement "not sooner than October 15, 2026" | Released 2026-09-28 |

Two measured notes on Sonnet 5.5 from its prompting page: adding "Think the problem through before you answer." at the end of the system prompt brought accuracy at `high` effort "close to what the model reaches at `xhigh`", and "asking it in the system prompt to think less doesn't reliably reduce its thinking" (no numbers published).

**The call path limits what a variant can set.** A `type: "prompt"` hook returns only `{"ok", "reason", "impossible"}` and runs the background model. A mod's `$.model.complete` has "No tools, no history, no system prompt beyond the CLI's identity block and `request.system`", and the installed types expose `model`, `prompt`, `system` and `maxTokens` (default 1,024). The docs page also lists `effort`. Thinking budgets and temperature are not exposed there. `$.model.classify(text, labels)` uses an unpublished fixed classifier prompt and is worth one baseline run (code.claude.com mods API and the GitHub types file, original). A command hook that calls the API directly can set everything in the table. A variant that wins in testing but cannot be set from the deployed path is not a result for this ticket.

**Haiku 4.5 as a judge, in recent studies.**

- SWE-chat: invalid labels on both pushback tasks, with the full transcript in context (section 1.1).
- Apollo: ρ = 0.69 with thinking off, "primarily fails to flag violations", and "dominated by a cheaper or better alternative".
- Sinha, Naik et al. (2026, [arXiv:2605.29601](https://arxiv.org/abs/2605.29601), original, appendix E), prompted with the full specification: mean out-of-distribution pAUROC@20 of 0.794 for Haiku 4.5, 0.929 for Sonnet 4.6 and 0.942 for Opus 4.6.
- Kariyappa & Suh (covered in the monitor note) found Claude Sonnet 4.6 over-flagged aligned controls (12.2 to 20.8%) where other models were near zero. Apollo found Claude judges discount violations. The direction of Claude's errors depends on the task, so it has to be measured per variant.
- *Standing:* several studies agree that Haiku 4.5 is weak on this kind of judgment without thinking. None tested it with a short slice and a strict output format, which is the configuration most likely to rescue it.

## 9. Scoring a detector honestly on about 470 labels

**Intervals.** Below a few hundred items, normal-approximation and bootstrap intervals cover less than they claim: "only the Bayesian credible interval and Wilson confidence intervals achieve this for small N", and for paired comparisons "all non-Bayesian methods severely underperform" at small N (Bowyer, Aitchison & Ivanova 2025, ICML position paper, [arXiv:2503.01747](https://arxiv.org/abs/2503.01747), original). With about 157 positives, a recall of 0.85 has a Wilson interval of about 0.78 to 0.90. With about 313 negatives, an FPR of 5% has an interval of about 3.2 to 8.1%, and 2% has about 0.9 to 4.1% (lane D's arithmetic).

**Pair the comparisons and cluster by session.** Two variants scored on the same items should be compared item by item, because "paired differences represent a 'free' reduction" in variance. Clustered standard errors "can be over 3X larger than naive standard errors" when items share a source (Miller 2024, "Adding Error Bars to Evals", Anthropic, [arXiv:2411.00640](https://arxiv.org/abs/2411.00640), original). Messages from one session share a user, a task and a mood.

**Power.** McNemar's test on disagreeing items is the standard paired test (Card et al. 2020, EMNLP, [arXiv:2010.06595](https://arxiv.org/abs/2010.06595), original). Lane D's simulation, at α = 0.05, for two variants that disagree on 10% of items: a 3-point accuracy gap on all 470 items has power 0.49, a 5-point gap has 0.92, and a 5-point recall gap on 157 positives has 0.42.

**The winner's curse.** Picking the best of many variants on the same items reports an optimistic score that grows with the number searched (Xu et al. 2026, [arXiv:2605.05973](https://arxiv.org/abs/2605.05973), original text, table values via summary tool). Lane D's simulation: with 24 variants that all truly score 0.80 recall, the apparent winner shows about +5 points, and with 48, about +5.5. The remedy is a test split frozen before any variant runs, or repeated splits that keep selection and scoring apart.

**Wording spread.** Meaning-preserving format changes once moved accuracy up to 76 points (Sclar et al. 2024, ICLR, [arXiv:2310.11324](https://arxiv.org/abs/2310.11324)), and rankings flipped across instruction paraphrases (Mizrahi et al. 2024, TACL, [arXiv:2401.00595](https://arxiv.org/abs/2401.00595)). Much of that was an artifact of rigid answer parsing. When an LLM extracted the answer instead of rigid matching, Gemma-2's standard deviation across prompts on ARC fell from 0.28 to 0.005 (Hua et al. 2025, "Flaw or Artifact?", EMNLP, [arXiv:2509.01790](https://arxiv.org/abs/2509.01790), original). *Standing:* narrowed. A strictly parsed yes or no avoids the artifact. Rewording a definition is different: it moves the boundary, so two or three wordings of the chosen definition should be scored and the spread reported.

**Prevalence.** Accuracy, F1 and precision depend on the share of positives and "would substantially differ" under a shift (Godau et al. 2023, MICCAI, [arXiv:2303.12540](https://arxiv.org/abs/2303.12540), original). On a set enriched to a third, precision and F1 overstate deployment. Report TPR and FPR, then compute precision at the measured deployment rate. AUPRC "is not generally superior in cases of class imbalance". It only weights the highest-scored region more (McDermott et al. 2024, NeurIPS, [arXiv:2401.06091](https://arxiv.org/abs/2401.06091), original). This contests a common belief, and the monitor note's advice to report recall at a fixed low FPR still holds, but at FPRs this set can resolve.

**Label noise sets a floor.** If 2 to 3% of the negatives are really corrections, a perfect detector shows an FPR of 2 to 3% (lane D's arithmetic). With Thakur et al.'s finding that percent agreement hides differences, report κ alongside accuracy and treat the labeller's agreement with himself, or with a second labeller, as the ceiling.

**Error direction.** LLM annotators had higher recall than precision on 20 of 27 binary tasks (median recall 0.83 against precision 0.65; Pangakis & Wolken 2024, [arXiv:2409.09467](https://arxiv.org/abs/2409.09467), original; GPT-4). LLM judges validating feedback had true-positive rates above 96% and true-negative rates below 25% (Jain et al. 2025, [arXiv:2510.11822](https://arxiv.org/abs/2510.11822), original). WildFeedback and Apollo's Haiku 4.5 erred the other way. Which way a variant errs depends on the model and the framing, so report the positive rate against the base rate and FPR separately for each kind of near miss.

## 10. Where this updates the monitor note

1. **"Labelled examples of the moment, and of near-misses, did the work wherever a small watcher succeeded" (monitor note, 4.2).** Narrowed. A handful of examples did worse than none in the closest task (SPUR) and in one monitor (Ctrl-Z). What helped was many examples, examples the model got wrong, a rubric learned from labels, and named false-positive categories from error analysis. Retrieved near misses carry a copying hazard.
2. **"A prompted cheap watcher reading a heuristic list is the weakest version" (monitor note, 4.2 and 10).** Refined. Inclusion lists were weak (Apollo, Chen et al.). Exclusion lists written from the detector's own errors were strong (Tang et al.).
3. **"Haiku- and Sonnet-class models are above the floor in every study that tested comparable models" (monitor note, 4.1).** Contradicted for Haiku 4.5 on this kind of judgment: invalid labels on SWE-chat's pushback task, under-flagging and ρ = 0.69 in Apollo's study, and a 0.135 pAUROC gap to Sonnet 4.6. Thinking recovers part of it. Haiku 4.5 also faces retirement from 2026-10-15.
4. **"Extract-then-judge in two fresh calls is the tested way to give a weak watcher a long session" (monitor note, 10).** Still true for long sessions. For a short slice, a plain prompt did as well (Koran et al.), and the two-call design that worked on real coding sessions used its second call as a validator with named exclusions, not as a fresh judge.
5. **"Diverse monitors beat repeated samples of one" (monitor note, 4.4).** Contested by Jha 2026: with skilled monitors, panels did not beat the best single monitor out of sample. Averaging still beats OR-ing, and resampling Claude adds little because its scores barely change.
6. **"Question wording mattered little and context mattered more" (monitor note, 1.5).** Confirmed with numbers, and qualified: a structured prompt beat a one-line prompt by about 0.13 pAUROC (Storf et al.), so wording matters between a bare prompt and a reasonable one, and stops mattering among reasonable ones.
7. **The alarm arithmetic's base rate (monitor note, section 3).** For corrections the measured rate is high under broad definitions (about 46% of prompts in SWE-chat). The 1 to 5% example rates fit the later theory-of-mind moments better than this first one.
8. **"Long context hurts weak monitors more" (monitor note, 4.1).** Narrowed. Length hurt strong models too, even with the evidence placed last, and Claude models fail long inputs by abstaining.
9. **Auto mode's stage 2 "is the same prompt with only the final instruction changed ... to careful reasoning" (monitor note, section 3).** On Sonnet 5.5 that reasoning cannot be written in the answer. It must run as thinking.
10. **gpt-oss-safeguard's comparison (monitor note, 2.1).** The current user guide says "Traditional classifiers trained on thousands of examples will likely perform better", where the monitor note quoted the launch post's "tens of thousands". Both are OpenAI's words in different documents.
11. **The mod path (monitor note, 8.3).** `$.model.complete` exposes model, prompt, system, a token cap and possibly effort. It cannot set a thinking budget or temperature, so Haiku-with-thinking needs a command hook that calls the API.

## 11. What the evidence leaves open

- **No study measured Haiku 4.5 or Sonnet 5.5 on a short-slice correction task with a strict output format.** SWE-chat's Haiku failure used full transcripts. Sonnet 5.5 is eight days old.
- **The best example count for a binary pragmatic judgment on current Claude models.** The evidence spans SPUR's two-shot loss, Anthropic's 3 to 5, and gains to 32 and beyond on older models.
- **Whether a learned rubric that Sonnet writes can be applied by Haiku.** SPUR's authors said smaller models could not score their rubric items.
- **Whether panels of prompt variants beat one good prompt on this task.** Koran et al. and Jha disagree.
- **How much of the agent's turn the detector needs.** No study varied the slice for a correction judgment. SWE-chat used everything, auto mode stripped assistant text, and Tang et al. warn that showing the agent's work invites judging the agent.
- **Unread or partly read.**
  - SHADE-Arena's per-prompt numbers and SLEIGHT-Bench's per-category and Haiku 4.5 rates, which exist only as figures.
  - The full text of Jha 2026. One lane read the abstract and section 3.6.
  - Meincke et al. 2025, "The Decreasing Value of Chain of Thought in Prompting". The PDF text could not be extracted.
  - Gao & Das 2024 on contrastive examples, and Petrak et al. 2024.
  - The output of `claude auto-mode defaults`, because no CLI is on PATH.
  - OpenAI's March 2026 post on monitoring internal coding agents, seen only as a search snippet.

## 12. What to try in the scoring step

This section is my reading of how the evidence bears on the next step of #174. It is not a finding. The ticket owns the decisions, and Manuel owns what counts as a correction and which false-alarm rate is acceptable. A full grid of every axis below would run to hundreds of cells, which the winner's curse in section 9 makes worse than useless, so the design is staged.

### 12.1 Before running anything

1. **Freeze a test split.** Hold out about 30% of the 470 (about 140), stratified by label and grouped by session so no session spans both splits. Nothing touches it until the last stage. *Behind it:* the winner's curse (Xu et al.; lane D's +5-point simulation), and every sweep that held out a test set (Storf et al., Chen et al.).
2. **Tag every label with a near-miss type and a session ID.** Types from the prior work: clarification question, hedged disagreement, scope or requirement change, failure report, rejection, routine next step phrased as a change, new request, and agent-did-something-odd-without-objection. *Behind it:* Petrak et al., Don-Yehiya et al., SWE-chat's examples, Tang et al.'s invalid categories, and clustered errors (Miller).
3. **Decide the boundary cases in writing before scoring.** SWE-chat counts "changing requirements/direction/scope mid-task" and failure reports as pushback. Whether Manuel does decides the base rate and what the detector learns. *Behind it:* section 1.3 and the label-word finding (Murugesan et al.).
4. **Measure the label ceiling.** Re-label a random 15% blind after a gap of days, and if possible have a second person label about 90 items, as SWE-chat did. Report κ. Keep items Manuel marks as unsure in a separate stratum, reported with and without. *Behind it:* criteria drift (Shankar et al.), TASTE, Thakur et al., Dorner & Hardt.
5. **Estimate the deployment rate.** Label a random sample of about 100 user messages from recent sessions, not drawn from the enriched set, to get the rate at which precision is computed. *Behind it:* section 1.3 and Godau et al.

### 12.2 Fixed choices, not tested

These are where the evidence agrees well enough that spending variants on them is waste.

- The slice comes first, the question last, with every turn numbered and labelled by speaker, and the question names the latest user message ("ONLY THE LAST" turn, as Llama Guard does). *Behind it:* Anthropic's long-context advice, Petri's format, CoT-Guard.
- The detector returns a 1 to 10 score with anchors and one piece of evidence quoted from the user's message. Where it does not write reasoning first, the score comes before the evidence. Sonnet 5.5 never gets a written reasoning block; its reasoning, if any, is thinking. *Behind it:* Storf et al. and Koran et al. on scales, Chiang & Lee on order, the `reasoning_extraction` refusal.
- Output is parsed strictly, through structured outputs or a tool with an enum and an integer field, and an invalid output counts as a miss and is reported. *Behind it:* SWE-chat's invalid Haiku labels, and Hua et al. on parsing artifacts.
- No "check your answer" pass. *Behind it:* Huang et al.
- Every variant is one the deployed call path can set. *Behind it:* section 8.

### 12.3 Stage 1: model, thinking and slice (on the development split)

Run one reasonable base prompt (a definition in Manuel's words with the SWE-chat-style disambiguation lines, no examples) across:

| Axis | Values | Finding behind it |
|---|---|---|
| Model and reasoning | Haiku 4.5 without thinking; Haiku 4.5 without thinking but with a short written reasoning step before the score; Haiku 4.5 with a 1,024 to 2,048 thinking budget; Sonnet 5.5 at `between_tools` and `low` effort; Sonnet 5.5 at default effort | Apollo (written reasoning was the most valuable prompt part; thinking helps small judges, not frontier ones); Gema et al. (thinking distracts Claude); SWE-chat and Sinha et al. (Haiku's gap) |
| Slice | (a) the user message alone; (b) the user message plus the agent's last action, as tool-call names and arguments, and its final message to the user; (c) the last three user turns and the agent's tool calls between them, assistant prose stripped; (d) the same three turns with assistant prose kept | Auto mode's ablation; Guo et al. and Tang et al. on context changing the construct; Du et al. and Levy et al. on length; Chroma on abstention |

That is 20 cells on about 330 items, each run three times with scores averaged (Haiku can also run once at temperature 0 for comparison). Report recall and FPR with Wilson intervals, AUROC with ties handled stepwise, positive rate against base rate, invalid-output rate, FPR by near-miss type, tokens and latency. Carry forward the two or three cells that are best on AUROC without being worse on invalid outputs. My expectation, which the run should be allowed to overturn: slice (a) does well on explicit corrections and poorly on implicit ones, slice (d) over-fires through normative prior bias, and Haiku without thinking under-flags.

### 12.4 Stage 2: the definition and the examples (on the carried-forward cells)

| Variant | What changes | Finding behind it |
|---|---|---|
| D0 | Definition alone (the stage 1 base) | SPUR and Ctrl-Z (few examples can hurt) |
| D1 | D0 with "correction" replaced by a neutral label such as `MOMENT_A`, as a probe of whether the model follows the definition or the word | Murugesan et al.; Halterman & Keith |
| D2 | D0 plus a "does not count" list written from the false positives stage 1 produced on the development folds, with an `unsure` escape | Tang et al.'s validator; Petri's "What's NOT concerning"; Apollo on inclusion lists |
| D3 | Two other wordings of D2, to measure the spread | Mizrahi et al.; Guo et al. on wording |
| E1 | D2 plus 4 to 6 balanced examples near the boundary, mixed order | Anthropic's 3 to 5; gpt-oss-safeguard's 4 to 6 |
| E2 | D2 plus about 30 examples, balanced, drawn from items the D2 prompt got wrong on other folds | Constitutional Classifiers appendix E; Gao et al. |
| E3 | D2 plus about 150 examples in random order, never grouped by label (above Haiku's 4,096-token cache minimum, so cheap after the first call) | Agarwal et al.; Bertsch et al.; caching limits |
| E4 | D2 plus the 8 nearest development items by embedding, retrieved per message | Anthropic's 71 to 93% ticket result; Z-ICL's copying effect |
| R1 | A rubric that Sonnet 5.5 writes from the development folds' corrections and near misses, applied by the stage 1 winner | SPUR |
| K0 | No model: nearest-neighbour vote over embeddings of the development items | Monitor note 4.3; Bertsch et al.'s retrieval account |
| B0 | SWE-chat's published pushback prompt, adapted to binary, and `$.model.classify` | External baselines |

Every example-bearing variant runs under 5-fold cross-validation inside the development split, so no item is ever its own example, and E1 to E3 each run in two orders with the spread reported. *Behind it:* MIPRO and TextReg on overfitting, and Li et al. and Kossen et al. on order and recency.

### 12.5 Stage 3: scoring format and cascade (on the best two or three)

- Score format, four ways: one 1 to 10 call, three calls averaged, three calls on different renderings of the slice (a plain transcript and a structured excerpt) averaged, and five yes-or-no calls read as a vote fraction. *Behind it:* Storf et al., Koran et al., Xiong et al., the tabular format-variation result, Bloom's report that Claude barely varies on resampling.
- Cascade: the best Haiku variant flags with a threshold set for high recall on development data. The best Sonnet 5.5 variant, given the named exclusions, judges only the band of uncertain scores, with the band chosen from development data. Compare against Sonnet 5.5 alone at equal cost. *Behind it:* auto mode's two stages, Trust or Escalate, Hua et al., Tang et al.'s validator.
- A two-model average (Haiku and Sonnet scores). *Behind it:* Apollo's ensembling result, with Jha's counter-result as the reason to check it out of sample.

### 12.6 The final test

Take at most three finalists to the frozen test split, once. Report these for each:

- Recall and FPR with Wilson intervals, at thresholds set on development data for FPR targets of 5% and 10%. The set cannot resolve 1 to 2%.
- AUROC.
- Precision at the measured deployment rate.
- Results with and without the unsure stratum.
- FPR by near-miss type.
- The invalid-output rate.
- Cost per thousand calls and median latency.

Compare finalists with McNemar's test, clustered by session. Treat any gap under about 5 points as a tie and choose on cost, latency and which model will still exist next month. *Behind it:* section 9.

A null result, such as examples not beating the definition or Haiku not reaching a usable recall at any setting, is a normal outcome of this design and worth recording as such. It also feeds the capacity tickets: the later theory-of-mind moments are rarer and less marked in the text than corrections, so whatever fails here will fail harder there.

## Access notes

The lanes fetched papers as arXiv HTML or PDF text with curl and documentation as page text, so most quotes are verbatim. Through a summary tool: Xu et al.'s winner's-curse table values. Abstract or abstract plus introduction only: Northcutt et al., Plank 2022, Li et al. 2025 ("Order Matters", plus section 3), TextReg, CoT-Guard, the tabular confidence study, and Smit et al. Read in the original and spot-checked by me against the downloaded text: SWE-chat (tables 6 and 8, section 4.4, appendix F.2.4), Tang et al. (sections 3.3 and 3.4, ablation and prompt appendices), both Apollo posts, Storf et al. (appendices E and F.3.1), Kariyappa & Suh (appendix H prompt text), Gema et al., Murugesan et al., CALICO, Pangakis & Wolken, SPUR section 4.3, Sinha et al., and the Claude refusal, model and mods documentation. The Kariyappa & Suh monitor prompts, which the monitor note could not read, are now text in the HTML version. The parallel monitor prompt says "Do not answer the user's task" and "Treat this current checking instruction only as the task you are performing." The 2026 papers are recent preprints and mostly not peer reviewed. Vendor numbers are the vendor's own.

---

Claude Opus 5.5, Claude Code. Written with five reading lanes that traced sources to their originals.
