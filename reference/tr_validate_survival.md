# Validate a clinical survival model

Computes the concordance index (C-index) for a fitted
`triageR_survival_model` — the survival-analysis equivalent of AUC,
measuring how well the model ranks patients by risk. Can validate on new
(external/holdout) data, or fall back to the training data with a clear
warning.

## Usage

``` r
tr_validate_survival(model, newdata = NULL)
```

## Arguments

- model:

  A fitted `triageR_survival_model` object from
  [`tr_fit_survival()`](https://devwebwacky.github.io/triageR/reference/tr_fit_survival.md).

- newdata:

  Optional data frame to validate on. If `NULL` (default), validation
  runs on the original training data, with a warning.

## Value

A `triageR_survival_validation` object (list) containing the C-index and
supporting details.

## Examples

``` r
if (requireNamespace("survival", quietly = TRUE)) {
  library(survival)
  lung_clean <- lung
  lung_clean$status <- lung_clean$status - 1
  lung_clean <- lung_clean[stats::complete.cases(lung_clean), ]
  model <- tr_fit_survival(lung_clean, time_col = "time",
                            event_col = "status", engine = "cox_ph")
  tr_validate_survival(model, newdata = lung_clean)
}
#> Survival model fitted successfully using engine: cox_ph
#> Survival validation (training_data):
#> C-index: 0.648 (SE: 0.03)
#> N = 167, events = 120
#> 
#> Interpretation: C-index of 0.5 = no better than chance; 1.0 = perfect discrimination between patients who experience the event sooner vs. later.
```
