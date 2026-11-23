---
name: Explain
description: Use this skill for any question about how to explain a difficult concept to a reader who meets it for the first time: what such a text should provide, how much context and history are warranted, and which mistakes recur. Also use it when drafting or reviewing an explanation of a mathematical, scientific or technical idea, when a definition must be introduced without losing the intuition behind it, or when an explanation is correct but the reader still cannot use the concept.
---

# How to Explain a Difficult Concept

## Abstract

An explanation of a difficult concept has to give the reader more than a correct definition. The reader needs to know what problem the concept answers, what was tried before it and why those attempts failed, and what exactly the concept asserts. This skill describes that information and the reasons it matters. It does not prescribe a template: the order, the length and the form are left to the author, since a reader who already knows the field needs far less than one who does not. The recommendations follow Tao's advice on learning a field [1-3].

## 1. Why a Definition Alone Is Not Enough

The standard explanation introduces a term, gives its formal definition, proves a few properties and supplies examples. It is mathematically complete, and a reader who meets the concept for the first time still cannot use it. There are three reasons.

A definition that arrives before the problem has nothing to attach to. Readers retain new material by connecting it to what they already know. If the definition comes first, there is no connection to make, and the wording is stored without the idea behind it: the reader can repeat the definition and still fail to recognise the concept in a new problem.

The reader also sees only the final result. Tao notes that a learner usually encounters a polished and elegant presentation from which every false start has been removed [1]. An expert fills in the missing steps from experience; a beginner has no such experience and concludes that the concept was simply given.

Finally, a correct definition is not yet an explanation. It compresses a long argument into a few lines, and only a reader who already knows the argument can unpack it. The author knows it, so the author is the last person able to judge whether the text supplies it. What is redundant for the author is often exactly what the reader is missing.

## 2. What the Reader Usually Lacks

The three items below are not a sequence to be followed. They are the information a reader is usually missing when a concept arrives as a finished definition. A text can supply them in any order, in any proportion, or not at all where the audience already has them. An expert in a neighbouring field may need only a precise statement and its limits; a newcomer may need the problem and the failed attempts before the statement means anything.

### 2.1. Why the Concept Exists

Without the problem, a concept looks like a convention that someone chose and the reader must memorise. With it, the concept looks like an answer, and the reader can tell which of its features are essential.

The useful content is what could not be done before: which question was open, who needed an answer, and which existing tools were adequate and which were not. This also fixes the level of the exposition, because the problem determines which prerequisites can be assumed.

A date adds little by itself. The information that Euler introduced a notation in 1737 locates the work in time; the information that the notation removed an ambiguity which had caused sign errors in manipulations with series says why the notation was needed.

Where the history is disputed, incomplete, or much more complicated than the text allows, one clause of qualification is usually enough. A short and honest account serves the reader better than a tidy one that will have to be unlearned later.

### 2.2. What Did Not Work

The approaches that failed, and the reason for each failure, carry much of the explanatory work and are often left out.

They matter for three reasons. A result looks arbitrary until the counterexample that forced it is known [1]. The reader's own first guess is usually one of the approaches that failed, and will be reinvented during reading unless it is named and refuted. Knowing which tools do not work prevents wasted effort [3].

The failures worth including are the instructive ones: a dead end teaches something when the reader can see why it leads nowhere. Their length should stay modest relative to the statement that follows; a reader exhausted by the preamble will read the definition as an afterthought.

### 2.3. What the Concept Is

Sooner or later the text has to say what the concept is, precisely enough for it to be used: the objects it concerns, the conditions it assumes, the conclusion it reaches, and the meaning of every symbol. For a concept that is not mathematical, the same requirement takes the form of an operational criterion, a contract, or a decision rule, with its inputs and its excluded cases.

Precision matters most where the reader will have to decide whether a given case falls under the concept. A statement is clear when the reader can say what falls inside it and what falls outside, and can point to the words that decide the case.

Two things tend to weaken a statement. The first is a looser version offered beside it as an alternative, on the ground that the formal one is hard on a first reading. The loose version is easier to remember, so it tends to be the one retained, and the precise version becomes a quotation. The second is a paraphrase of notation that the reader could have understood in place; explaining the symbol where it appears usually works better. A gloss can still help, for example that a derivative is the rate at which one quantity changes with respect to another, as long as it supports the statement rather than competes with it.

## 3. What Else the Text May Need

Tao's questions for a result one intends to understand are a useful source of content after the statement [1]. Few texts need all of them, and the answers may appear before the statement as well as after it.

- Which examples show the concept in action, and which of them are minimal?
- Which condition is necessary, and which counterexample fails without it?
- When should the concept be used, and when not?
- What does it do that the earlier tools could not, and what lies outside its reach?
- Is a weaker or simpler version sufficient for some purposes?
- What are the analogues, and to what larger family does the concept belong?

Each answer gives a sentence that the definition alone cannot give, and those sentences are what make the concept usable. One question is worth answering in almost every case: where does the concept stop applying? A reader who does not know the boundary will apply the concept where it does not hold, and will blame the concept for the resulting error.

## 4. One Arrangement of These Ingredients

The complex numbers can be explained with all of the above in four paragraphs.

*The problem.* Cubic equations were solved algebraically in the sixteenth century, but the general solution required square roots of quantities that the procedure itself produced as negative, including cases where all three roots were real and known to exist. The obstacle was practical: the formula stopped in the middle of a correct computation.

*The failed attempts.* Declaring such quantities impossible, and restricting the method to cases where they did not arise, excluded exactly those cases in which the cubic has three real roots; the method was then correct where it applied and silent where it did not. Treating the intermediate quantities as formal devices with no interpretation, to be cancelled before the result was reported, worked, but left their status unresolved for two centuries. The name "imaginary number" is a remnant of that period.

*The statement.* A complex number is a pair of real numbers with an addition and a multiplication under which the pairs form a field containing a root of the polynomial $x^2 + 1$. Read as an instruction to move in the plane, the pair makes multiplication a rotation combined with a scaling, and the square root of a negative quantity becomes the instruction to turn by a quarter turn.

*The boundary.* The construction yields a field, so division is available and the usual algebra applies. It does not yield an ordering compatible with the arithmetic, so inequalities between complex numbers are undefined. A reader who is not told this will eventually write one.

The arrangement is arbitrary. The same material could begin with the boundary, since many readers already know that complex numbers cannot be ordered, and work backwards to the problem that made such numbers necessary.

## 5. Mistakes Worth Checking For

**Invented history.** The most serious failure is a narrative that sounds plausible and did not happen. Dates, attributions and motives must be either known or explicitly marked as uncertain. If the history is unavailable, the problem can be reconstructed without it: the obstacle, the failed attempts and their reasons do not require names.

**History that replaces the statement.** If the text ends without a precise statement, or with a statement the reader cannot connect to the narrative, the material has been covered and its purpose lost. What matters is whether the reader can state the concept, not whether the reader can retell its origins.

**An opening that becomes the whole text.** A long preamble is its own kind of difficulty, and an essay on origins does not repair a definition that lacks motivation.

**Structure for its own sake.** A text that contains the problem, the failures and the statement but reads as a filled-in form has not explained anything. Each part should be present because this reader needs it, and omitted when this reader does not.

**An analogy presented as a definition.** Simplifying the language is not the same as simplifying the claim. Analogies should be labelled as analogies, with their limits stated, so that the reader does not carry them into a domain where they fail.

**Talking down to the reader.** The reader may be an expert in an adjacent field. Each part should be skippable, so that a reader who already has the motivation can begin at the statement.

## Sources

1. Tao, T. [Learn and relearn your field](https://terrytao.wordpress.com/career-advice/learn-and-relearn-your-field/). *What's new*, 2007.
   Contents: the list of questions to put to a lemma; the polished end product and the removed false starts; lecturing and writing as instruments of understanding.
2. Tao, T. [Ask yourself dumb questions, and answer them](https://terrytao.wordpress.com/career-advice/ask-yourself-dumb-questions-and-answer-them/). *What's new*, 2007.
   Contents: the naive question as a route to the reason a definition has its present form.
3. Tao, T. [Learn the limitations of your tools](https://terrytao.wordpress.com/career-advice/learn-the-limitations-of-your-tools/). *What's new*, 2007.
   Contents: negative knowledge and the library of counterexamples.
4. Tao, T. [Solving mathematical problems](https://terrytao.wordpress.com/career-advice/solving-mathematical-problems/). *What's new*, 2007.
   Contents: the rule that a solution one cannot explain to a classmate has not been understood.
