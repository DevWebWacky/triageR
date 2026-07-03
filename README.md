
# triageR

<!-- badges: start -->

<!-- badges: end -->

**triageR** provides a streamlined, reproducible workflow for building,
validating, and reporting clinical prediction models in R. It combines
standard machine learning and survival analysis tools with an optional
AI agent that recommends appropriate statistical methods, runs automated
sensitivity analyses, and flags common clinical modelling pitfalls.
Reports are generated in a format aligned with TRIPOD+AI reporting
guidance, to support reproducible, guideline-conscious research.

## Why triageR?

Most R machine learning tooling (`tidymodels`, `mlr3`, `caret`) is
general-purpose. Clinical researchers are left to manually stitch
together model fitting, validation, sensitivity analysis,
explainability, and TRIPOD-compliant reporting across many separate
packages. triageR brings these into one coherent workflow, with
clinically-aware safeguards built in — such as warning when validation
is performed only on training data, and flagging low events-per-variable
ratios before you finalize a model.

The AI agent layer is entirely **optional** — every core function works
without any LLM/API key. The agent adds method recommendations, plain
language pipeline review summaries, and assists with sensitivity
analysis interpretation, but is never required to fit, validate, or
explain a model.

## Installation

You can install the development version of triageR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("DevWebWacky/triageR")
```

## Example workflow

This is a basic example showing the full pipeline, from raw data to a
TRIPOD+AI-aligned report.

``` r
library(triageR)

# 1. Load and standardize clinical data
# data <- tr_load_clinical("patients.csv", id_col = "patient_id")

# 2. Check and handle missing data
# tr_check_missing(data)
# data <- tr_impute(data, method = "mice")

# 3. Fit a model
# model <- tr_fit(data, outcome = "disease", engine = "logistic_reg")

# 4. Validate on a holdout set
# validation <- tr_validate(model, newdata = test_data)

# 5. Explain the model
# tr_explain(model, method = "permutation")

# 6. Run automated sensitivity analyses
# sensitivity <- tr_sensitivity(data, model, subgroup_col = "sex")

# 7. Review the pipeline for common pitfalls
# review <- tr_agent_review(data, model)

# 8. (optional) Get an AI method recommendation
# recommendation <- tr_recommend_method(data, outcome = "disease")

# 9. Generate a TRIPOD+AI-aligned report
# tr_tripod_report(
#   model = model,
#   validation = validation,
#   review = review,
#   sensitivity = sensitivity,
#   recommendation = recommendation,
#   format = "html"
# )
```

## Core functions

| Layer | Function | Purpose |
|----|----|----|
| Data | `tr_load_clinical()` | Load and standardize clinical data |
| Data | `tr_check_missing()` | Missingness summary and visualization |
| Data | `tr_impute()` | Multiple imputation (mice / missForest) |
| Model | `tr_fit()` | Fit a binary clinical prediction model |
| Model | `tr_validate()` | Discrimination and calibration metrics |
| Model | `tr_explain()` | Variable importance / SHAP explanations |
| Agent | `tr_recommend_method()` | AI-suggested statistical/ML approach |
| Agent | `tr_sensitivity()` | Automated sensitivity analysis battery |
| Agent | `tr_agent_review()` | Pipeline pitfall checks (imbalance, EPV, leakage) |
| Report | `tr_tripod_report()` | TRIPOD+AI-aligned HTML/docx report |

\`\`\`

## Disclaimer

triageR’s AI-generated recommendations and summaries are drafting aids
intended to support, not replace, expert clinical and statistical
judgment. The TRIPOD+AI report generator is a drafting tool and does not
guarantee full compliance with the TRIPOD+AI checklist — always review
against the official checklist at the [EQUATOR
Network](https://www.equator-network.org/).

## License

MIT © Uwakmfon Usen Paul
