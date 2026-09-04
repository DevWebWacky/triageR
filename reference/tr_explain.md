# Explain a clinical prediction model

Generates variable importance or prediction explanations for a fitted
`triageR_model`, using the `DALEX` framework under the hood.

## Usage

``` r
tr_explain(
  model,
  method = c("permutation", "shap"),
  newdata = NULL,
  observation = 1
)
```

## Arguments

- model:

  A fitted `triageR_model` object from
  [`tr_fit()`](https://devwebwacky.github.io/triageR/reference/tr_fit.md).

- method:

  Character. One of `"permutation"` (global variable importance) or
  `"shap"` (SHAP values for a single prediction).

- newdata:

  Optional data frame to explain predictions on. If `NULL`, uses the
  training data.

- observation:

  Integer. Row index of the observation to explain, only used when
  `method = "shap"`. Defaults to 1.

## Value

A `triageR_explanation` object (list) containing the explanation result
and a plot.

## Examples

``` r
if (FALSE) { # \dontrun{
tr_explain(model, method = "permutation")
tr_explain(model, method = "shap", observation = 3)
} # }
```
