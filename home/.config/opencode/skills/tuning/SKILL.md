---
name: Tuning
description: Use this skill for any question about tuning the prompts and tool descriptions of an agent harness, including regularized iterative improvement, overfitting to a development sample, pruning instructions that do not earn their place, and controlling the token cost of a change. Also use it when assessing whether a measured improvement is real, when reviewing a proposed prompt or tool-description edit, or when planning a tuning loop over several rounds.
---

# Regularized Tuning of Prompts and Tool Descriptions

## Abstract

This skill specifies a method for the iterative improvement of the prompts and tool descriptions of an agent harness. The method is derived from RRSI, Regularized Recursive Self-Improvement of Agent Harnesses [1], and its objective is to retain changes that improve the generalizable behavior of the agent rather than its performance on the requests already examined. Three forms of complexity control form its basis: sparsity of updates, structural pruning, and a bound on the growth of computational cost.

The $L_0$-, $L_1$- and $L_2$-analogies set out below follow the article, but they apply to any improvement of a harness and not only to the recursive case.

## 1. Problem Setting

Let $H$ denote the current configuration of the agent, comprising its instructions and the available tool descriptions. A candidate $H'$ differs from it by a bounded set of semantic edits. $S(H)$ denotes task performance and $C(H)$ the mean number of tokens consumed by all model calls per task. The model, the generation parameters, the environment and the evaluation procedure are held fixed for the duration of the comparison.

The repeated use of a finite sample both to analyze errors and to select edits produces adaptive overfitting. It manifests as memorization of particular cases, retention of stochastic improvements, and accumulation of instructions that raise cost without a sustained gain in quality. The search trajectory is therefore regularized: how many mechanisms may change, which evidence is admitted, and which candidates are retained.

Distinguish the development sample (`evolve`), a held-out sample drawn from the same distribution (`held-out`), and tasks with different scenarios or conditions (`OOD`). Data on which an edit has already been formulated belong to development. If the results of a held-out evaluation are used to formulate the next edit, that sample ceases to be an independent test of transfer.

## 2. Three Forms of Regularization

### 2.1. The $L_0$ Analogy: Bounding the Number of Independent Edits

**Mechanism.** RRSI bounds the number of independently interpretable changes in a single candidate. The budget decreases over the course of the search:

$$
b_t = \left\lceil b_{\min} + (b_{\max} - b_{\min}) \frac{1 + \cos(\pi t/T)}{2} \right\rceil.
$$

Here $T$ is the search horizon, and $b_{\min}$ and $b_{\max}$ are the final and initial budgets. Early iterations admit several coordinated changes; later ones approach a single edit. The unit of the budget is a behavioral hypothesis, not a line, a file, or a count of replaced words.

**Rationale.** A large bundle of changes is more readily fitted to the idiosyncrasies of the tasks already analyzed. In addition, its result cannot be attributed with confidence to a particular mechanism. A sparse update reduces the adaptive capacity of the step and renders conclusions about its effect more interpretable.

**Application.** For manual tuning, investigate one hypothesis per iteration by default. For example, a refinement of the scope of a tool and a change in the policy of repeated calls are two hypotheses, even when they are written in a single paragraph. Coordinated changes in several places are admissible if they implement one mechanism; state that relation explicitly. Under a bundled edit, the aggregate result is not evidence for the benefit of each of its elements.

Record the history of hypotheses, diffs, results and decisions. A rejected hypothesis remains negative evidence; its reconsideration requires new data or changed conditions. When progress stalls, investigate an aspect of the task that has not yet been examined: the conditions of tool selection, the semantics of arguments, the interpretation of results, or the termination condition. Perpetual paraphrase of a single rule does not constitute a new mechanism.

### 2.2. The $L_1$ Analogy: Removing Mechanisms without Confirmed Utility

**Mechanism.** In RRSI, components that have been exercised but have produced no strictly positive measured gain within a fixed window become targets for removal in subsequent proposals. Pruning concerns the retained structure $H$, whereas the $L_0$ budget concerns an individual update only.

**Rationale.** Under selection by quality alone, instructions tend to accumulate. Obsolete exceptions and duplicated rules enlarge the context, create competing directives, and preserve traces of fitting to individual cases. Removal returns the configuration to a smaller set of justified mechanisms.

**Application.** Treat the removal of a duplicated warning, a particular example, a redundant verification step or an obsolete exception as a candidate in its own right. Test it by ablation: compare the current configuration with the configuration lacking the selected fragment. The absence of recent gain is a reason to investigate removal, not a proof that the rule is unnecessary. Do not remove a correct tool contract merely because the sample contained no instance of its use.

The criterion is the preservation of quality under a simplification of behavior. A reduction in text does not by itself demonstrate the utility of a change; a brief but ambiguous instruction may degrade tool selection and increase the number of calls.

### 2.3. The $L_2$ Analogy: Cost Growth Must Be Justified by Quality

**Mechanism.** For a candidate relative to the current $H$, define

$$
\begin{aligned}
\Delta S &= S(H') - S(H), \\
\Delta C &= \frac{C(H') - C(H)}{C(H)}.
\end{aligned}
$$

If the gain in quality exceeds the empirical noise band $\delta$, RRSI requires

$$
\Delta C \leq \beta_0 + \beta_1 \Delta S, \qquad \Delta S > \delta.
$$

$\beta_0$ sets the cost increase tolerated for a negligible gain, and $\beta_1$ the additional allowance per unit of gain in quality. $S$ is expressed as a fraction and $\Delta C$ as a relative change. The parameters are fixed before candidates are selected; the values reported in the experiments of the article are not ready-made settings for a service.

**Rationale.** Directives such as "always verify again", "perform one further search" or "reason in detail" may improve the result predominantly through additional computation. A bound on aggregate cost limits such growth without requiring the removal of any particular component. This is the analogy with the non-sparsifying action of ridge regression; the stated rule contains no quadratic penalty.

**Application.** Measure the cost of the full trajectory, including repeated LLM calls and the repeated transmission of instructions and tool results. The length of the modified prompt is a diagnostic indicator only. Record latency, the number of tool calls and errors as well, but do not combine them with tokens in the absence of an explicitly stated criterion. A longer description may reduce total cost if it eliminates incorrect calls.

## 3. Reliability of Selection

The three forms of complexity control are supplemented by the following conditions from RRSI.

**Leakage screening before evaluation.** Examine the diff for answers, identifiers, entities, values and branches carried over from particular development tasks. An edit must express a general rule of behavior. Genuine tool names and documented API constraints are part of the contract and are not automatically leakage. Reject also instructions concerning capabilities that do not exist, and mechanisms that do not in fact participate in execution.

**Robustness to noise.** Estimate $\delta$ by repeated runs of the unchanged base configuration under comparable conditions. The empirical noise band is not automatically a confidence interval or a demonstration of statistical significance. Every candidate must satisfy the threshold

$$
S(H') \geq S^\star - \delta,
$$

where $S^\star$ is the best result on the accepted search trajectory. Comparison with the preceding version alone permits the accumulation of small regressions. A gain within $\delta$ is not to be described as a confirmed improvement in quality.

**Changes within the noise band.** For $\Delta S \leq \delta$, Appendix C.3 of the article applies a separate rule rather than the cost bound above:

$$
w_s \Delta S - w_c \Delta C + w_n \nu > 0.
$$

Here $\nu$ counts previously unaccepted types of structural components; an ordinary paraphrase of a prompt receives no novelty bonus. For the tuning of text, apply a simpler conservative variant: retain such a candidate when the reduction in cost is reproducible and the quality threshold is met, or leave it unconfirmed. This is an adaptation, not an exact reproduction of the selector in the article.

**Test of transfer.** After a version has been chosen, evaluate it unchanged on held-out scenarios. A gain on the development sample does not demonstrate transfer. Where no independent sample or repeated runs are available, state the limitation of the conclusion explicitly and do not substitute subjective confidence for measurement.

## 4. Practical Protocol for Tuning

The following protocol adapts RRSI to the modification of prompts and tool descriptions. Hypotheses are formulated by separate subagents, and the main agent acts as a critic in the selection of candidates.

1. **Fix the conditions of comparison.**
   Define the current configuration, the development sample, and the metrics of quality and cost.
   Estimate the noise band $\delta$ by repeated runs of the original configuration.
   Fix the selection parameters and set aside the data for the test of transfer.
2. **Formulate a hypothesis.**
   Relate the observed error to the mechanism by which it is to be eliminated.
   Take account of the results of earlier changes, including rejected candidates.
3. **Construct candidate or candidates.**
   Bound the number of independent edits by the current budget.
   Consider the removal of unproductive instructions together with additions and modifications.
   Use subagents to construct candidate edits for one of the hypotheses, so that several hypotheses are formed in parallel.
   When progress stalls, investigate mechanisms within the task that have not yet been examined.
4. **Screen and evaluate each candidate.**
   Before evaluation, exclude fitting to particular tasks and changes that do not affect behavior.
   Measure quality and total token cost under conditions comparable with the current configuration.
5. **Perform selection.**
   Apply the threshold relative to $S^\star$ and the corresponding cost rule from Sections 2.3 and 3.
   If no candidate satisfies the conditions, retain the current configuration.
   Record the hypothesis, the diff, the measurements and the decision.
6. **Test transfer.**
   Evaluate the chosen configuration unchanged on held-out tasks.
   Distinguish an improvement on the development sample from confirmed transfer.

## Sources

1. Xia, P. et al. *RRSI: Regularized Recursive Self-Improvement of Agent Harnesses*. arXiv:2609.24972v1, 2026. [Full text](https://arxiv.org/html/2609.24972v1).
   Principal sections: §3.1-3.3; algorithm and selection rules: Appendix C; experimental settings: Appendix D.1.
2. Google Research. [RRSI: official repository](https://github.com/google-research/rrsi).
