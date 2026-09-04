# Run an automated sensitivity analysis battery

Re-fits a clinical prediction model under several robustness checks,
complete-case vs imputed data, outlier exclusion, and subgroup
consistency, and compares performance metrics across them.

## Usage

``` r
tr_sensitivity(data, model, subgroup_col = NULL, outlier_sd = 3)
```

## Arguments

- data:

  The original (pre-imputation) data frame, containing the same
  predictors and outcome used in `model`.

- model:

  A fitted `triageR_model` object from
  [`tr_fit()`](https://devwebwacky.github.io/triageR/reference/tr_fit.md).

- subgroup_col:

  Optional character. Name of a categorical column (e.g. "sex") to check
  subgroup consistency across.

- outlier_sd:

  Numeric. Number of standard deviations beyond which a numeric
  predictor value is considered an outlier and excluded in the
  outlier-robustness check. Defaults to 3.

## Value

A `triageR_sensitivity` object (list) with a comparison tibble of
metrics across all sensitivity scenarios.

## Examples

``` r
if (FALSE) { # \dontrun{
tr_sensitivity(data, model, subgroup_col = "sex")
} # }
```
