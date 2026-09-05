# Survival Analysis with triageR

``` r

library(triageR)
library(survival)
```

## Overview

Not every clinical outcome is binary. Many research questions are about
**time to an event**, time to death, relapse, readmission, or disease
progression — where some patients are followed for the full study and
others are “censored” (the event hasn’t happened by the time we stop
observing them, or they leave the study early).

This vignette walks through triageR’s survival analysis workflow using
the classic **`lung`** dataset (from the `survival` package): time to
death for patients with advanced lung cancer.

## 1. Prepare the data

The `lung` dataset codes its event status as 1 (censored) / 2 (death), a
common convention in older survival datasets, but triageR expects
standard 0/1 coding (0 = censored, 1 = event occurred).

``` r

lung_clean <- lung
lung_clean$status <- lung_clean$status - 1
lung_clean <- lung_clean[stats::complete.cases(lung_clean), ]

head(lung_clean[, c("time", "status", "age", "sex", "ph.karno")])
#>   time status age sex ph.karno
#> 2  455      1  68   1       90
#> 4  210      1  57   1       90
#> 6 1022      0  74   1       50
#> 7  310      1  68   2       70
#> 8  361      1  71   2       60
#> 9  218      1  53   1       70
```

## 2. Fit a survival model

triageR supports two survival engines through the same interface used
for classification models: **Cox Proportional Hazards** (the clinical
standard, via the `survival` engine) and **Random Survival Forest** (via
the `aorsf` engine).

Unlike
[`tr_fit()`](https://devwebwacky.github.io/triageR/reference/tr_fit.md),
survival models are fit with
[`tr_fit_survival()`](https://devwebwacky.github.io/triageR/reference/tr_fit_survival.md),
which expects a `time_col` and `event_col` instead of a single outcome
column — reflecting the different shape of time-to-event data.

``` r

model_cox <- tr_fit_survival(
  lung_clean,
  time_col = "time",
  event_col = "status",
  engine = "cox_ph"
)
#> Survival model fitted successfully using engine: cox_ph
```

``` r

model_rf <- tr_fit_survival(
  lung_clean,
  time_col = "time",
  event_col = "status",
  engine = "survival_rf"
)
#> Survival model fitted successfully using engine: survival_rf
```

## 3. Validate the model

Survival models are validated with
[`tr_validate_survival()`](https://devwebwacky.github.io/triageR/reference/tr_validate_survival.md),
which computes the **concordance index (C-index)** — survival analysis’s
equivalent of AUC. A C-index of 0.5 means the model is no better than
chance at ranking which patient will experience the event sooner; 1.0
means perfect discrimination.

``` r

val_cox <- tr_validate_survival(model_cox, newdata = lung_clean)
#> Survival validation (training_data):
#> C-index: 0.648 (SE: 0.03)
#> N = 167, events = 120
#> 
#> Interpretation: C-index of 0.5 = no better than chance; 1.0 = perfect discrimination between patients who experience the event sooner vs. later.
```

``` r

val_rf <- tr_validate_survival(model_rf, newdata = lung_clean)
#> Survival validation (training_data):
#> C-index: 0.836 (SE: 0.018)
#> N = 167, events = 120
#> 
#> Interpretation: C-index of 0.5 = no better than chance; 1.0 = perfect discrimination between patients who experience the event sooner vs. later.
```

In this example, the Random Survival Forest achieves a notably higher
C-index than Cox Proportional Hazards, suggesting the relationship
between predictors and survival time may not be fully linear on the log
hazard scale, exactly the kind of finding that motivates comparing more
than one modelling approach.

## 4. Automated pipeline review

[`tr_agent_review()`](https://devwebwacky.github.io/triageR/reference/tr_agent_review.md)
works with survival models too, adapting its checks to the time-to-event
context: instead of class imbalance, it checks the **event rate** (the
proportion of patients who experienced the event rather than being
censored), and events-per-variable is calculated using the number of
observed events rather than total sample size.

``` r

review_cox <- tr_agent_review(lung_clean, model_cox, use_agent = FALSE)
#> 
#> --- triageR Pipeline Review ---
#> 
#> No major issues flagged.
```

## 5. Generate a TRIPOD+AI-aligned report

[`tr_tripod_report()`](https://devwebwacky.github.io/triageR/reference/tr_tripod_report.md)
supports survival models via the `model_type` argument. The report
adapts automatically: instead of a confusion matrix and calibration
plot, it reports the C-index and its standard error.

``` r

tr_tripod_report(
  model = model_cox,
  model_type = "survival",
  validation = val_cox,
  review = review_cox,
  output_file = file.path(tempdir(), "lung_survival_report"),
  format = "html"
)
```

Note: automated sensitivity analysis
([`tr_sensitivity()`](https://devwebwacky.github.io/triageR/reference/tr_sensitivity.md))
is currently only supported for classification models, not survival
models.

## Summary

This vignette covered triageR’s survival analysis workflow: preparing
time-to-event data, fitting Cox Proportional Hazards and Random Survival
Forest models through a consistent interface, validating with the
concordance index, running an automated pipeline review adapted for
censored data, and generating a TRIPOD+AI-aligned report, all using a
real, widely-used clinical dataset.
