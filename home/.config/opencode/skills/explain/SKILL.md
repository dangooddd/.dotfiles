---
name: Explain
description: Use this skill for any question about how to explain a difficult concept to a reader who is meeting it for the first time, including the order in which motivation, historical context, failed approaches and the precise statement should be given, and how much of each is warranted. Also use it when drafting or reviewing an explanation of a mathematical, scientific or technical idea, when a definition must be introduced without losing the intuition behind it, or when an explanation is correct but leaves the reader unable to use the concept.
---

# Explaining a Difficult Concept: Motivation, Failed Attempts, and Precise Statement

## Abstract

An explanation is not a definition followed by its properties; it is the record of a problem being solved, and it should be presented in that order. A reader who receives only the finished definition receives a compression without the key to decompress it: such a reader can repeat the definition and manipulate its symbols, but cannot recognise the concept in a new situation, and cannot say why it has the shape it has.

The opening therefore has three movements: the problem and the period in which it arose; the attempts that failed to solve it, and why they failed; and the statement of the concept, given once and given precisely. What follows develops what the statement does, why each hypothesis is necessary, and where its limits lie. The guidance derives from Terence Tao's advice on learning and relearning a field [1-3].

## 1. The Default Form and Its Defect

A definition-first explanation introduces a term, gives its formal characterisation, proves several properties, and follows with worked examples. The form is correct and nearly useless to a beginner.

**The reader has nowhere to put the definition.** New material is retained by its relations to material already understood. A definition that arrives without the problem it answers has no relation to establish, and is remembered, if at all, as a string of words. The reader may assent to it and still be unable to use it.

**The polished surface hides the problem.** A learner generally sees only the end product — a very polished, clever and elegant presentation, from which every false start has been removed [1]. The expert reconstructs the missing steps from experience; the beginner has no such resource and concludes that the concept was simply given, not found.

**Correctness is mistaken for explanation.** A definition is a compression, legible only to a reader who already holds the decompression key. The explainer holds it and is therefore the worst possible judge of whether it has been supplied: what is redundant for the explainer is what is missing for the reader.

The remedy is to restore the order in which the concept was actually needed.

## 2. The Opening: Three Movements

### 2.1. The Problem and Its Period

State what could not be done before the concept existed, who needed it, and what the available tools could and could not handle. A date is useful only insofar as it locates the state of the art: "Euler introduced the notation in 1737" informs, but "the notation removed an ambiguity that had caused sign errors in series manipulations" explains.

Stating the problem supplies the criterion of relevance, makes the concept contingent rather than a convention to be memorised, and fixes the level of the explanation, since the problem itself determines which prerequisites may be assumed.

Where the history is disputed, incomplete, or considerably more complicated than a paragraph allows, say so in one clause and continue. A false clean story is worse than a short honest one, because the reader will later encounter the discrepancy and will have to unlearn the version supplied here.

### 2.2. The Attempts That Failed

Describe the approaches that were tried and did not work, together with the reason for their failure. It is the part most often omitted, and the part that carries much of the weight: a hypothesis appears unmotivated until one sees which counterexample forced it [1]; the reader's own intuition is usually the wrong approach, and if it is not named and refuted the reader will reinvent it while reading and hold two incompatible accounts at once; and negative knowledge — when a tool does not work — is what prevents wasted effort [3].

Two constraints apply. Select failures that are instructive rather than merely historical; a dead end teaches only if the reader can see why it leads nowhere. And keep the failures proportionate to the statement that follows: the reader should arrive at the definition expecting it, not exhausted by the preamble.

### 2.3. The Statement

State the concept once, and state it precisely: its objects, quantifiers, hypotheses and conclusion given explicitly, every symbol introduced. The temptation is to add a second, looser version beside it, on the grounds that the formal statement is unreadable at a first encounter. The two then compete: the looser version is easier to hold, the reader keeps it, and the precise one becomes a formality that is quoted rather than used.

Where unfamiliar terminology is the obstacle, it is usually better to explain the notation in place than to supply a paraphrase. A gloss can still help — "a derivative is the rate at which one quantity changes with respect to another" — but it is most useful when it hangs off the statement rather than standing beside it as a definition of equal authority.

The test of a clear statement is that the reader can say what falls inside it and what falls outside, and can point to the words that decide each case. For a concept that is not mathematical, the same requirement takes the form of an operational criterion, a contract or a decision rule, stated once with its inputs and the cases it excludes.

## 3. The Body of the Explanation

Once the concept has been stated, the explanation should answer, in some order, the questions Tao recommends putting to any result one intends to understand [1]:

- What are the model examples that show the concept in action, and what are the minimal ones?
- Why is each hypothesis or restriction necessary? Which counterexample fails without it?
- When is it a good idea to use the concept, and when is it not?
- What can it do that the preceding tools could not, and what is beyond its reach?
- Are there weaker or simpler versions sufficient for some purposes?
- What are the analogues elsewhere, and what does the concept belong to more broadly?

Not every explanation needs every item. The list is a source of content, not a checklist to be completed. Each question, when answered, yields a sentence that the definition alone cannot, and those are the sentences that make the concept usable.

Answer at least the question of the boundary. A reader who does not know where a concept stops applying will apply it where it does not hold, and the error will then be blamed on the concept.

## 4. An Illustration

The complex numbers fit this structure into a few lines.

*The problem.* Cubic equations were solved algebraically in the sixteenth century, but the general solution required extracting square roots of quantities that the procedure itself produced as negative, even when all three roots were real and known to exist. The obstacle was not philosophical but operational: the formula stopped in the middle of a correct computation.

*The failures.* To declare such quantities impossible and restrict the method to cases where they did not arise excluded exactly the cases in which the cubic has three real roots — correct where it applied and silent where it did not. To accept the intermediate quantities as formal devices with no interpretation, to be cancelled before the answer was reported, worked; it left the status of the objects unresolved for two centuries, which is why the terminology of the period survives as an insult ("imaginary").

*The statement.* A complex number is a pair of real numbers with an addition and a multiplication that make the pairs a field in which the polynomial $x^2 + 1$ has a root. Read as an instruction to move in the plane, the pair makes multiplication a rotation and a scaling, and the square root of a negative quantity the instruction that turns by a quarter turn.

*The boundary.* The construction gives a field, hence division is available and the usual algebra applies; it does not give an ordering compatible with the arithmetic, which is why inequalities between complex numbers are not defined. A reader who is not told this will eventually write one.

## 5. Limits and Common Failures

**Fabricated history.** The most serious failure is a plausible narrative that did not happen. Dates, attributions and motives must be either known or explicitly marked as uncertain. If the history is not available, the problem can be reconstructed without it: the obstacle, the failed attempts and the reason for failure do not require names.

**The narrative swallowing the statement.** History is a means. If the explanation ends without a precise statement, or with a statement the reader cannot connect to the narrative, the structure has been reproduced and its purpose lost. The test is whether the reader can state the concept, not whether they can retell its origins.

**Proportionality.** The three movements should occupy the opening, not the whole. A long preamble is its own kind of difficulty, and an unmotivated definition is not repaired by an essay about its origins.

**False accessibility.** Simplifying the language is not the same as simplifying the claim. Analogies must be labelled as analogies, and their failure points stated, or the reader will carry the analogy where it does not hold.

**Condescension.** The reader may be an expert in an adjacent field. The movements should be skippable, so that a reader who already holds the motivation can begin at the statement.

## Sources

1. Tao, T. [Learn and relearn your field](https://terrytao.wordpress.com/career-advice/learn-and-relearn-your-field/). *What's new*, 2007. The list of questions to put to a lemma; the polished end product and the removed false starts; lecturing and writing as instruments of understanding.
2. Tao, T. [Ask yourself dumb questions, and answer them](https://terrytao.wordpress.com/career-advice/ask-yourself-dumb-questions-and-answer-them/). *What's new*, 2007. The naive question as a route to the reason a definition has its shape.
3. Tao, T. [Learn the limitations of your tools](https://terrytao.wordpress.com/career-advice/learn-the-limitations-of-your-tools/). *What's new*, 2007. Negative knowledge and the library of counterexamples.
4. Tao, T. [Solving mathematical problems](https://terrytao.wordpress.com/career-advice/solving-mathematical-problems/). *What's new*, 2007. The rule that a solution one cannot explain to a classmate has not been understood.
