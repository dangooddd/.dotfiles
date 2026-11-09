---
name: Experiments
description: Use this skill for any question about the methodology of machine learning experiments, including data leakage, evaluation and comparison of models, statistical validity, and reproducibility. Also use it when explaining or reviewing an ML experiment, assessing leakage risk, interpreting results, planning a methodology, or preparing a paper or review.
---

# Methodology of Machine Learning Experiments: Leakage, Evaluation, and Reproducibility

This skill presents a detailed exposition of two complementary bodies of work. The first is Kapoor and Narayanan's "Leakage and the reproducibility crisis in machine-learning-based science" (arXiv:2207.07048), which systematises data leakage and proposes a reporting instrument for detecting it. The second is Lones's "How to avoid machine learning pitfalls: a guide for academic researchers" (arXiv:2108.02497), which surveys errors across the entire research pipeline, from planning to publication.

The skill is explanatory rather than prescriptive. It does not impose a fixed procedure; instead, it sets out a conceptual map of failure modes and of the measures that mitigate them. It is intended for discussions of experimental design, for auditing results that have already been obtained, for preparing a paper or a review, and for training researchers.

Where the skill is used to analyse experiments that have already been conducted, it should identify the errors found in accordance with the two papers, provided that such errors are present and materially affect the results.

## Part I. Data Leakage as a Systemic Cause of Irreproducibility

### 1. Scope and framing

The first body of work concerns the class of studies that Kapoor and Narayanan call ML-based science: research in which a scientific claim is supported by the measured performance of a predictive model. This distinguishes it from four other domains of ML practice - methods research, research on ethical implications, engineering applications, and prediction competitions. The criteria of validity differ across these domains, and consequently the remedies for leakage cannot be transferred mechanically from one to another.

The authors adopt a broad definition of reproducibility: a finding is reproducible if the code and data used to obtain it are available and the data have been analysed correctly. This is wider than computational reproducibility, which requires only that the published numbers can be reproduced with the authors' code and dataset. The broader definition matters because it treats as an error not only the inability to run someone else's code, but also correctly executing code that leads to a false conclusion.

### 2. Scale of the problem

The survey covers 20 review papers documenting methodological errors in 17 scientific fields; together they concern 329 papers. Leakage is found in every one of these fields. The authors stress that this figure is a lower bound rather than a precise estimate of prevalence: most reviews examine only the text of papers, without consulting the accompanying code and data, and errors in code are often invisible on reading. In addition, different disciplines use different terminology for the same defects, which impedes systematic search.

Other defects are recorded alongside leakage: insufficient computational reproducibility, problems of data quality (small samples, missing values, a weak proxy for the phenomenon under study), inappropriate metric choice, and errors that arise even when standard datasets are used, owing to the absence of standard protocols for splitting and evaluation.

### 3. Definition of leakage

Data leakage is defined as a spurious relationship between the independent variables and the target variable that arises as an artefact of data collection, sampling, or preprocessing. Because that relationship is absent from the distribution about which the scientific claim is made, leakage generally produces an inflated estimate of model performance.

This definition is more useful than a mere catalogue of technical errors, because it supplies a general criterion: any information that is available when the model is built but unavailable when the model is applied to data from the target distribution constitutes leakage. It follows that the same practice may be valid in one study and invalid in another, depending on the claim being made and the distribution over which it is asserted.

### 4. Why recipes do not transfer

The authors explain separately why practices accepted in competitions and engineering applications do not solve the problem in science.

In a competition, dataset construction and model evaluation are delegated to an impartial third party, and participants have no access to the held-out set until the competition ends. In scientific research, by contrast, the researcher usually has access to the entire dataset and makes all decisions about splitting, preprocessing, and evaluation. The mere availability of the full dataset makes leakage likely.

In engineering applications, a common recommendation is to deploy the model at a limited scale and observe its behaviour in production. This route is unavailable for scientific inference: the aim is not to produce a working system but to establish a claim about a phenomenon. Moreover, engineering applications often tolerate approximate performance estimates, whereas scientific claims are sensitive to small differences between models.

It follows that transferring anti-leakage practice from competitions or engineering to science requires an explicit reformulation: the task is not merely to obtain high performance on held-out data, but to justify that the measured performance pertains to the distribution and the task about which the substantive claim is made.

### 5. A taxonomy of eight types of leakage

The authors propose a taxonomy that spans data collection, preprocessing, modelling, and evaluation. The eight types fall into three families: L1, failure to separate training and test data; L2, use of illegitimate features; and L3, a test set that does not correspond to the distribution of scientific interest. Each type is described below in terms of mechanism, illustration, consequence, and remedy.

#### L1. Failure to separate training and test data

The general mechanism is that the model receives information from the test set before its performance is measured. As a result, it learns relationships that will not be present in new data from the target distribution, and the estimate ceases to reflect generalisation.

**L1.1. No test set.** Training and evaluation are conducted on the same data. This is the textbook case of overfitting: a sufficiently complex model can memorise the data and achieve high performance without learning any generalisable regularity. The remedy is to set aside a test set before modelling begins and to exclude it from every stage of model selection.

**L1.2. Preprocessing on combined data.** Imputation, scaling, normalisation, variance-based feature selection, and over- or undersampling are performed before splitting. The parameters of the transformation are therefore estimated with the test observations, and synthetic examples generated from training objects may enter the test set. Oversampling before splitting is especially dangerous: copies or synthetic variants of training examples appear in the test set, and the estimate becomes optimistic by construction. The remedy is to estimate every transformation statistic on the training portion only and to apply it to the test portion without re-estimation; under cross-validation, preprocessing must be performed inside each fold.

**L1.3. Feature selection on combined data.** If features are selected on the full dataset, the decision to include a feature depends on how well it performs on the test set. This already uses the test labels, even if the model is formally trained only on the training portion. The remedy is to treat feature selection as part of model training and to conduct it exclusively on training data, separately for each cross-validation fold.

**L1.4. Duplicates in the dataset.** When records are duplicated, the same object may appear in both training and test data. A model that has memorised the object will perform well on its copy. The remedy is to identify and remove duplicates before splitting, including near-duplicates and overlaps between data sources.

#### L2. Use of illegitimate features

The model is given features that should not be available for the task. A typical case is a feature that acts as a proxy for the target variable. In a study predicting hypertension, for example, the use of antihypertensive medication was included as a feature. Such a feature is unavailable when predicting for a new patient, and if it is known, the prediction becomes trivial. Other variants include information that arises after the target event and administrative fields that encode the outcome.

The judgement of whether a feature is legitimate requires domain expertise and cannot be reduced to a statistical criterion. The remedy is to state explicitly, for each feature or homogeneous group of features, why it will be available at prediction time and why its association with the target is substantive rather than artefactual.

#### L3. The test set does not correspond to the distribution of scientific interest

The general mechanism is that the distribution on which performance is measured differs from the distribution about which the claim is made. Even a split that is perfectly clean with respect to L1 will not help if measurement is performed on the wrong population.

**L3.1. Temporal leakage.** When a model predicts a future event, the test set must not contain data earlier than the training data. Otherwise the model is built on information "from the future" that it will not have in real use. A classical source is a random split of a time series or ordinary k-fold cross-validation, in which most iterations place later observations in the training folds than in the test fold. The remedy is to split by time and to use cross-validation schemes that respect the ordering of observations, such as blocked cross-validation.

**L3.2. Dependence between training and test observations.** If observations in training and test come from the same units - patients, participants, protein families, devices - they are not independent. In the extreme but common case, different records of the same patient appear in both training and test. The claim is then about new patients, but it is tested on data from old ones. The remedy is group splitting: all observations belonging to one unit remain in the same fold; for spatially or structurally dependent data, block schemes are used.

**L3.3. Sampling bias in the test distribution.** A test set may be unrepresentative in spatial, temporal, or selective terms. Examples include training and testing on images from a single hospital while making claims about hospitals in general; excluding borderline cases of a disease, which are precisely the most difficult and most important; and collecting test data in one geographical region while generalising to others. The bias may be subtle: differences in imaging protocols between hospitals are sufficient to prevent transfer. The remedy is to define the target distribution explicitly and to verify that the test set is drawn from it; where this is impossible, the claim must be restricted to the distribution actually measured.

### 6. Other defects identified in the survey

Beyond leakage, the authors identify four classes of problem.

**Computational reproducibility.** The absence of code, data, or a computational environment prevents independent verification. This is not equivalent to the absence of errors in the code, but it substantially impedes their discovery.

**Data quality.** Small sample size, extensive missingness, a weak proxy for the phenomenon under study, and unrecorded limitations of data collection. These defects can persist even when the evaluation procedure is formally correct.

**Metric choice.** A metric may fail to correspond to the scientific question. Accuracy under severe class imbalance, for instance, yields an optimistic estimate because a model can always predict the majority class.

**Use of standard datasets.** The existence of a widely used dataset does not guarantee correctness: in the absence of a standard split, metric, and evaluation protocol, the same errors are reproduced in new work.

### 7. Model info sheets as an instrument for detecting leakage

The authors propose a supplementary document - a model info sheet - in which the researcher must set out precise arguments for the absence of leakage. The template contains 21 questions organised around three central arguments.

**Argument L1: clean separation of training and test data.** The researcher must justify that the test set does not interact with the training data at any stage - during preprocessing, modelling, or evaluation.

**Argument L2: legitimacy of each feature.** The researcher must justify that each feature, or each homogeneous group of features, is available at prediction time and is substantively related to the task. It is not necessary to enumerate every feature if the argument covers them all - for a vector of location history, for example, the use of the entire vector can be justified at once. A single illegitimate feature, however, can invalidate the conclusion, so the argument must be exhaustive.

**Argument L3: the test set is drawn from the distribution of scientific interest.** The researcher must justify that the distribution on which performance is measured coincides with the distribution about which the claim is made, and that the choice of test data involves no spatial, temporal, or selective bias.

Model info sheets differ from model cards and ordinary checklists in that they are directed specifically at leakage and require argument rather than description. They can serve two purposes: as a means of self-examination during the preparation of a study, and as a basis for discussion between authors and reviewers. The authors also acknowledge limitations: without accessible code and data, the correctness of a completed sheet cannot be verified; incorrect statements in the sheet may create false assurance; completing and assessing it requires expertise that may be absent on both sides; and, finally, understanding of leakage evolves, so the template is versioned.

### 8. Case study: predicting civil war

To test these ideas empirically, the authors conduct a reproducibility study in the prediction of civil war, a subfield of political science in which complex ML models were believed to outperform logistic regression substantially. A systematic search identified 124 papers; of these, 12 were selected because they predicted the onset of civil war, used a training/test split, and provided complete code and data.

Errors were found in 4 of the 12 papers - precisely those four that claimed superiority of complex models over logistic regression. All four were published in leading journals of political science. After correction, the complex models show no substantively better performance, except in the work of Wang, where the AUC gap falls from 0.14 to 0.01. Notably, none of the errors was visible on reading the paper; each was discovered only through work with the code and data. A model info sheet would have exposed the leakage in all four cases.

It was further found that 9 of the 12 papers reported neither significance tests nor any quantification of uncertainty when comparing classifiers. In the study by Blair and Sambanis, the test set contained only 11 onsets of civil war, and the reported smoothed AUC of 0.85 had a bootstrapped 95% confidence interval of [0.66, 0.95]. The point estimate thus concealed enough uncertainty to make the claim of superiority doubtful.

### 9. Five diagnoses and five recommendations

The authors move beyond leakage to formulate five causes of reproducibility failure, each paired with a recommendation.

**D1. Misunderstanding the limits of prediction.** Successes of ML in perception tasks create the impression that the same methods are equally effective in predicting social outcomes. In fact, there are strong limits on attainable accuracy. Recommendation R1: investigate and communicate the limits of prediction, and treat results that violate known bounds with heightened scepticism.

**D2. Hype, overoptimism, and publication bias.** Non-reproducible results are cited more often than reproducible ones, which closes a feedback loop of overoptimism. Recommendation R2: treat results in ML-based science as provisional until reproducibility problems are resolved, and do not rely on headline performance figures when assessing work.

**D3. Inadequate expertise.** The rapid adoption of ML in a discipline in which neither authors nor reviewers possess the relevant expertise produces errors. Recommendation R3: interdisciplinary teams and explicit transmission of best practice.

**D4. Lack of standardisation.** The standard splits, metrics, and protocols accepted in engineering and competitions have not been widely adopted in science. Recommendation R4: where possible, use the common task framework - an agreed training set, a secret hold-out set, and a public leaderboard. At the same time, account must be taken of a side effect: exclusive concentration on a single metric displaces other scientifically significant properties of models.

**D5. Absence of computational reproducibility.** Without code, data, and environment, independent verification is impossible. Recommendation R5: ensure computational reproducibility, including through containerised platforms that recreate the original environment.

## Part II. A Stage-by-Stage Guide to Sound Practice

The second body of work complements the taxonomy by following the research process from planning to publication. Lones organises the guidance into five stages: preparation, model building, evaluation, comparison, and reporting. The recommendations below preserve the substance of that guide while presenting it in continuous prose.

### 1. Before model building

**Planning the use of data.** Data serve two distinct purposes - training and verification - but this does not necessarily imply a single split into two parts. Model development involves experimentation, which requires a separate validation set. The more comparisons are made on validation data, the more the validation set is overfitted through the multiplicity effect; in complex projects it may therefore be advisable to reserve several validation sets. A test set drawn from the same source as the training data inherits its biases and may not permit a measurement of generalisation; more than one test set may be required. Under cross-validation, an additional hold-out set is often needed to evaluate the final model instance.

**Understanding the data.** The reliability of the source, the collection methodology, and the quality of the data directly affect the publishability and the substance of the result. Widespread use of a dataset is not evidence of its quality: some popular datasets have known limitations. The principle "garbage in, garbage out" is here quite literal. It is advisable to establish direct relationships with those who generate the data and to begin with exploratory analysis: missing values, inconsistencies, anomalies.

**Not looking at the test data.** Exploratory analysis of training data is useful, but the test set should not be examined at an early stage. Regularities observed in the test set may, consciously or unconsciously, become assumptions that cannot be tested and that limit the generality of the model. This is one manifestation of leakage.

**Cleaning the data.** Even high-quality datasets contain defects: duplicates, missing values, outliers, meaningless or contradictory values. Duplicates must be removed before splitting. Missing values require imputation, but its parameters must be estimated on training data only. Outliers should be removed only when they are the result of error rather than a natural extreme of the distribution: an age of 150 is probably an error, whereas 110 may be a natural outlier.

**Sufficiency of data.** The possibility of generalisation depends on the signal-to-noise ratio: a strong signal permits a smaller sample. When data are scarce, augmentation, treatment of class imbalance, and transfer learning are available. A small sample increases the risk of biased splits, so frequent repartitioning is useful, and cross-validation provides it efficiently. Model complexity must also be constrained: deep networks readily overfit small samples.

**Research context.** Domain experts help to identify a useful problem, meaningful features, an appropriate model, and a suitable venue for publication. A review of the literature prevents repetition of work already done and allows the study to build on prior results. Finally, it is useful to consider deployment in advance: constraints on memory, latency, energy consumption, and operating cost influence the choice of model.

### 2. Reliable model building

**Preventing leakage.** This is the central recommendation. Information from the test set must not enter the configuration, training, or selection of models. In addition to the cases already described - scaling and imputation over the full dataset, feature selection before splitting, augmentation before splitting, repeated use of the test set - there are specific forms: temporal dependencies, duplicates, and dependent observations. The most reliable measure is to set aside an independent test set at the outset and to use it once, at the end, to evaluate a single final model.

**Diversity of models.** There is no single best model: the no-free-lunch theorem shows that, over all possible problems, no method is superior to any other. The researcher's task is to find a model suited to the particular problem, taking inductive bias into account: linear models are appropriate in the absence of substantial nonlinearity but poor otherwise. Modern libraries make it possible to examine a wide range of models with minimal changes to code.

**Appropriateness of models.** Lowering the barrier to implementation also facilitates the application of inappropriate models: categorical features are supplied to a model that expects numerical ones, regression is replaced by classification, a model that assumes independent observations is applied to time series, or model complexity is mismatched to sample size or to requirements of interpretability.

**Caution with deep learning.** Deep networks are not universally superior to classical methods. On tabular data, tree-based models often perform better; transformers are not always suitable for time-series forecasting. Deep learning is a poor choice when data are scarce, when the underlying regularity is simple, or when interpretation is required. Moreover, contemporary large models require substantial data and computational resources and create risks associated with memorisation of training examples and the opacity of training sets.

**Feature selection and dimensionality reduction.** Feature selection is part of training, not a preliminary operation over the whole dataset. When PCA is used, component weights are estimated on training data only and then applied to the test set. Under cross-validation, selection and reduction are performed independently in each iteration, on the training folds alone.

**Hyperparameter optimisation.** Hyperparameters materially affect performance, and there are no universal values. Manual tuning until an acceptable result is obtained is poorly reproducible and poorly justified. Systematic strategies are preferable: random and grid search, Bayesian optimisation, and AutoML. The strategy and the search budget should be reported.

**Spurious correlations.** A model may rely on features that correlate with the target but carry no substantive meaning. The classic illustration is the tank problem: images of tanks and non-tanks differed in weather and background, and the model learned to recognise the background rather than the object. Complex data contain more such correlations, and complex models have a greater capacity to learn them. Regularisation and augmentation reduce the risk, but the principal measure is to inspect the trained model and determine which features it responds to.

### 3. Robust evaluation

**An appropriate test set.** Performance on the training set is almost meaningless: a sufficiently complex model can memorise it without learning a generalisable regularity. The test set must not overlap with training and must be representative of the wider population. If training and test data are collected under identical conditions - in the same weather, on the same equipment - independence is violated, and the model may learn characteristics of the equipment that do not transfer to other conditions; such a defect will not be detected on that test set. "Frankenstein datasets", assembled from other public datasets, warrant caution because of possible overlap with training data. When several observations belong to one subject, they must not be distributed across different parts of the split. The COVID-19 pandemic is instructive: a substantial proportion of diagnostic models failed to transfer beyond their own test sets precisely because of such defects.

**Augmentation only after splitting.** Augmentation is useful, but it should be applied to training data only. If the whole dataset is augmented before splitting, variants of training examples enter the test set. This is a particularly dangerous form of leakage, capable of inflating results across an entire field.

**Sequential overfitting.** One of the most insidious forms of leakage: models are trained in succession, with information about the performance of earlier models guiding the configuration of later ones, and each is evaluated on the same test set. Formally the test set is not used in training, but in practice it participates in model selection, and information from it enters the configuration. The more often the test set is used, the greater the overfitting. The remedy is a validation set for all decisions of selection and tuning, and a separate hold-out test set for the final evaluation. The phenomenon is sometimes called "over-hyping" - overfitting to hyperparameters.

**Repeated evaluation.** Many models are stochastic or unstable: retraining or small changes to the data materially alter performance. A single measurement is unreliable. The simplest remedy is several runs with different random seeds. A more reliable remedy is cross-validation, which also varies the split. With dependent observations, they must be grouped within a fold; for time series, ordinary cross-validation is unsuitable. When hyperparameters are optimised, nested cross-validation is used to avoid overfitting the test folds. Under class imbalance, stratification is useful. In addition to mean performance, the spread or a confidence interval should be reported.

**Reserving data for the final model instance.** It is important to distinguish the potential of a general approach from the performance of a particular trained instance. Cross-validation assesses the former well but the latter less well: ten folds produce ten instances, and selecting the best of them may select the instance that received the easiest test fold. A reliable estimate for the final instance requires a separate hold-out set. An alternative is to ensemble the instances produced by cross-validation: the ensemble will perform in line with the average, but inference cost rises and interpretability falls.

**Choice of metric.** Accuracy is applicable only when classes are balanced. With 90% of one class, a model that always predicts that class obtains 90% accuracy while being useless. F1, Cohen's kappa, and MCC are more robust to imbalance. In regression and time-series forecasting, an analogous problem arises with RMSE: a model that always predicts no change can obtain a good value. The metric must correspond to the scientific question and to the type of error that matters in the domain.

**Fairness.** Beyond aggregate performance, fairness towards groups of people is significant. Sources of unfairness include an unrepresentative dataset, bias in data preparation, and the inductive biases of the model. Definitions of fairness differ, so metrics relevant to the context must be selected.

**Temporal dependencies.** The order of observations in a time series is significant. The most characteristic error is look-ahead bias: the model is trained on data that are later than the test data and thus acquires knowledge of the future. Ordinary cross-validation on time series systematically creates this situation. The remedy is splitting by time and blocked cross-validation; whether special schemes are necessary depends in part on whether the series is stationary. Look-ahead bias also arises from preprocessing before splitting: scaling the entire series to [0, 1] before separating the test set, for example, allows the model to infer the future range of values. Data must be split before any operation that depends on their distribution.

### 4. Fair comparison

**A larger number does not imply a better model.** Claims of the form "previous work reported 94% accuracy; our model achieves 95% and is therefore better" are invalid for several reasons: the models may have been trained and evaluated on different splits; the datasets may have differed in class imbalance; entirely different datasets may have been used; and the models may have been optimised to different degrees. Comparisons based on published figures therefore require caution. A fair comparison requires independent implementation of all models, equal optimisation of hyperparameters, repeated evaluation, and statistical testing of differences. A further complication arises with foundation models: their training data are often unknown, so independence of the test set from training cannot be guaranteed.

**Meaningful baselines.** A new model must be compared with established approaches. Baselines are chosen to demonstrate that any complexity is necessary: if the work extends model X, a comparison with X is appropriate; if deep learning is proposed for tabular data, comparisons with trees and SVMs should be included. The simplest "naive" baselines show that the model is not doing something trivial: a classifier that always predicts the majority class; a forecast that repeats the previous value of a series. There are known cases in which a complex transformer for time series performed worse than such a naive forecast. In addition to simple baselines, comparisons with state-of-the-art models are necessary.

**Statistical tests.** To compare two particular trained instances, McNemar's test is applicable, for example, comparing labels on the same test set; this requires predictions to be retained. To compare approaches in general, repeated evaluations are needed - cross-validation, resampling, or repeated runs under stochastic training - after which the resulting distributions are compared. Student's t-test is reliable only when the distributions are normal, which is often not the case; the Mann-Whitney U test is more robust. The choice of test must correspond to the evaluation scheme and the type of data.

**Multiple comparisons.** When more than two models are compared, a series of pairwise tests increases the probability of a false positive. At a 95% confidence level, roughly one in twenty comparisons may yield false significance; with twenty comparisons such an outcome is already likely. This is the multiplicity effect, and when used intentionally it constitutes p-hacking. The remedy is a correction for multiplicity, such as the Bonferroni correction, which lowers the significance threshold according to the number of tests; less conservative procedures also exist. When and where to apply such corrections remains a matter of debate.

**Community benchmarks.** The use of a shared dataset is intended to make comparisons transparent, but it creates two problems. First, when access to the test set is unrestricted, it cannot be excluded that the test set was used in training - "training to the test set". Second, even if each researcher uses the test set once, the community as a whole uses it many times; the more models are compared on one test set, the more likely it is that the best model has simply overfitted it. The situation is aggravated for foundation models, whose training data may have included the test sets of popular benchmarks. A small advantage on a benchmark is not in itself significant.

**Model composition.** ML does not always reduce to the choice of a single model; compositions can compensate for the weaknesses of components. When stacking and embeddings are used, however, care must be taken that test data do not participate in the training of any component. Components trained on overlapping data create leakage. An independent test set is desirable for evaluating a composite model.

### 5. Reporting

**Transparency.** Code, experiment scripts, and descriptions of the computational environment should be published. This permits replication, facilitates fair comparison, and disciplines the authors. Requirements for reproducibility are becoming more stringent in the community; experiment-tracking systems and checklists are useful.

**Multiple forms of reporting.** Several datasets and several metrics should be used. Different datasets compensate for the defects of individual datasets, and different metrics provide different projections of the result. Beyond aggregate metrics, metrics for particular types of error are important: precision and recall, sensitivity and specificity, since they show what kind of errors the model makes. The metric used must be stated explicitly: F1 or another F-measure, AUC on the ROC or the PR curve.

**Limits to generalisation.** A conclusion must not be extended beyond the data studied. Success on one dataset does not imply success on others. Even several datasets may not be independent and may share similar biases. Data quality, especially in deep learning, where volume limits verification, also imposes constraints. Claims must correspond to what has actually been measured.

**Caution with statistical significance.** Statistical tests are imperfect: conservative tests underestimate significance, liberal tests overestimate it. A threshold of 0.05 means that roughly one in twenty differences flagged as significant may be random. It is increasingly recommended not to reduce the conclusion to a threshold but to report the p-value and leave interpretation to the reader. Beyond significance, the practical magnitude of the effect matters: with a large sample, even a negligible difference may be significant. Effect size can be assessed with Cohen's d or more robust measures; a Bayesian alternative, free of some problems of classical tests, is also available.

**Examining trained models.** Reporting only metrics impoverishes the study: the aim of science is not a small gain in accuracy but knowledge. For simple models, visualisation is useful; for complex models, explainable AI methods are available: LIME, SHAP, saliency maps and Grad-CAM for images, and attention visualisation for transformers. It should be remembered that these methods do not reveal the exact mechanism of a decision and may smooth over genuine complexity. Ablation studies - the successive removal of parts of the model - are a further means of identifying significant components.

**Checklists.** A checklist helps to traverse the whole pipeline and to document how decisions support a substantive conclusion. It is especially useful at the planning stage. Lones recommends REFORMS, a consensus checklist for ML-based science developed in part by Kapoor.

### 6. Concluding remarks

The practice of ML is young, and the errors that allow a model to appear sound are numerous. Publishing such results misleads, and deploying them may cause harm. The guidance describes common errors and the measures that prevent them, and it also touches on broader questions of good practice: fairness, transparency, and bias. Because new approaches generate new risks, the theory of sound practice lags behind practice, and what is considered correct today may change tomorrow; vigilance is therefore necessary.

## Part III. A Synthesis: From Symptom to Remedy

| Symptom | Probable mechanism | Remedy |
| --- | --- | --- |
| Suspiciously high performance; sharp drop on new data | Leakage L1-L3 | Audit the split, preprocessing, feature selection, and definition of the target distribution |
| Performance rises from experiment to experiment | Sequential overfitting | Use validation for decisions; use the test set once, at the end |
| The winner changes from run to run | Stochasticity; small test set | Several seeds, cross-validation, confidence intervals |
| The model is better, but the difference is small | No analysis of uncertainty | Statistical test, effect size, intervals |
| A new model surpasses the baseline | The baseline is untuned or too simple | Comparable tuning; naive and state-of-the-art baselines |
| The model attends to the background or an administrative field | Spurious correlation; illegitimate feature | Inspect the model, justify features, augment |
| The result does not reproduce | No code, data, or environment | Publish artefacts, containerise, use a checklist |
| The claim extends beyond the population studied | Test set does not match the target distribution | Define the population explicitly; restrict the claim |

### A minimal protocol for sound experimental design

1. State the scientific claim and the target distribution to which it applies.
2. Set aside a test set before any data-dependent operation, and fix it.
3. Perform preprocessing, imputation, scaling, feature selection, and augmentation only within the training portion, separately for each fold.
4. Justify the legitimacy of each feature or group of features by its availability at prediction time and its substantive meaning.
5. Tune hyperparameters on validation data or in nested cross-validation; do not use the test set for selection.
6. Evaluate repeatedly and report the mean together with the spread or a confidence interval.
7. Compare with equally optimised baselines, including naive ones, and apply statistical tests with a correction for multiplicity.
8. Report several metrics and datasets, including metrics for particular types of error.
9. State limitations explicitly and do not extend the claim beyond what has been measured.
10. Publish code, data, and environment; complete a model info sheet or REFORMS.

## Sources

- [Kapoor S., Narayanan A. Leakage and the reproducibility crisis in machine-learning-based science](https://arxiv.org/abs/2207.07048). arXiv:2207.07048.
- [Lones M. A. How to avoid machine learning pitfalls: a guide for academic researchers](https://arxiv.org/abs/2108.02497). arXiv:2108.02497.
