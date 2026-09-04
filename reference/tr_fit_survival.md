# Fits a survival model using the `censored`/`parsnip` framework. The outcome must be specified as separate time and event columns (following `survival::Surv()` convention), and the user must explicitly choose an engine.

Fits a survival model using the `censored`/`parsnip` framework. The
outcome must be specified as separate time and event columns (following
[`survival::Surv()`](https://rdrr.io/pkg/survival/man/Surv.html)
convention), and the user must explicitly choose an engine.

## Usage

``` r
tr_fit_survival(
  data,
  time_col,
  event_col,
  engine = c("cox_ph", "survival_rf"),
  predictors = NULL
)
```

## Arguments

- data:

  A data frame containing predictors, a time column, and an event
  column.

- time_col:

  Character. Name of the column giving time to event or censoring.

- event_col:

  Character. Name of the column indicating event status (1 = event
  occurred, 0 = censored), following standard survival analysis
  convention.

- engine:

  Character. One of `"cox_ph"` (Cox Proportional Hazards) or
  `"survival_rf"` (Random Survival Forest via the `aorsf` engine).

- predictors:

  Character vector of predictor column names. If `NULL` (default), all
  columns except `time_col` and `event_col` are used.

## Value

A fitted `triageR_survival_model` object (list) containing the fitted
workflow, engine, and time/event/predictor column names.

## Examples

``` r
if (requireNamespace("survival", quietly = TRUE)) {
  library(survival)
  lung_clean <- lung
  lung_clean$status <- lung_clean$status - 1  # convert 1/2 to 0/1
  lung_clean <- lung_clean[stats::complete.cases(lung_clean), ]
  model <- tr_fit_survival(lung_clean, time_col = "time",
                            event_col = "status", engine = "cox_ph")
}
#> Survival model fitted successfully using engine: cox_ph
```
