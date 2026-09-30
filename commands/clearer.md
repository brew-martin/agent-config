---
description: Rewrite the last assistant answer when it was hard to understand
argument-hint: "[focus]"
disable-model-invocation: true
---

# Clearer

Rewrite the previous answer for comprehension using the model handling this conversation. Return only the clearer answer after checking that its meaning stayed intact.

## Input

Raw focus: `$ARGUMENTS`

Use the most recent substantive assistant answer before this command as the source answer. Exclude tool calls, progress updates and the command invocation itself. If there is no earlier answer, say that `/clearer` has nothing to rewrite and stop.

Treat the arguments as optional focus: they identify what was confusing or what needs more explanation. They guide the rewrite but do not replace or narrow the source answer.

## Rewrite

Rewrite the source answer with these rules:

- Preserve every factual claim, conclusion, uncertainty, caveat, warning, command, path, number, citation and code block.
- Add no fact, recommendation or interpretation that the source answer does not support.
- Lead with the answer. State premises or causal links that the source left implicit.
- Use plain, concrete English. Define necessary jargon and keep one name for each concept.
- Put one idea in each sentence. Split dense clauses and remove filler or empty hedging without deleting real uncertainty.
- Keep useful structure, but do not add a preamble, diagnosis, attribution or summary of the rewrite.

## Fidelity check

Before replying, compare the rewrite with the source answer. Revise it internally until all of these are true:

- It adds no factual claim, decision or advice.
- It omits no decision-relevant fact, condition, warning, caveat or uncertainty.
- It preserves commands, paths, numbers, citations and code exactly unless only surrounding prose changed.
- It addresses the focus without narrowing away the rest of the answer.

Return only the rewritten answer in Markdown. Do not mention this command, the fidelity check or the fact that a rewrite occurred.
