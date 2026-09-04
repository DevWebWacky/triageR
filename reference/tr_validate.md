# Validate a clinical prediction model

Computes discrimination (AUC, sensitivity, specificity) and calibration
metrics for a fitted `triageR_model`. Can validate on new
(external/holdout) data, or fall back to the training data with a clear
warning.

## Usage

``` r
tr_validate(
  model,
  newdata = NULL,
  threshold = 0.5,
  calibration_method = c("binned", "smooth")
)
```

## Arguments

- model:

  A fitted `triageR_model` object from
  [`tr_fit()`](https://devwebwacky.github.io/triageR/reference/tr_fit.md).

- newdata:

  Optional data frame to validate on. If `NULL` (default), validation
  runs on the original training data, with a warning.

- threshold:

  Numeric. Probability threshold for classifying the positive class.
  Defaults to 0.5.

- calibration_method:

  Character. One of `"binned"` (groups patients into risk deciles, the
  standard clinical approach) or `"smooth"` (loess-smoothed calibration
  curve, more granular). Defaults to `"binned"`.

## Value

A `triageR_validation` object (list) containing a metrics tibble and the
underlying predictions, invisibly printed as a summary.

## Examples

``` r
set.seed(1)
df <- data.frame(
  age = round(rnorm(50, 55, 12)),
  sex = sample(c("M", "F"), 50, replace = TRUE),
  disease = sample(c(0, 1), 50, replace = TRUE)
)
model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")
#> Model fitted successfully using engine: logistic_reg
tr_validate(model, newdata = df)
#> Validation metrics (training_data):
#> # A tibble: 5 × 3
#>   .metric     .estimator .estimate
#>   <chr>       <chr>          <dbl>
#> 1 roc_auc     binary         0.623
#> 2 sens        binary         0.364
#> 3 spec        binary         0.857
#> 4 accuracy    binary         0.64 
#> 5 brier_score binary         0.236
#> 
#> Confusion Matrix:
#>           Truth
#> Prediction  0  1
#>          0 24 14
#>          1  4  8

```
