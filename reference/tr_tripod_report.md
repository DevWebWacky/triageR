# Generate a TRIPOD+AI-aligned clinical model report

Renders a reproducible report summarizing model fit, validation,
sensitivity analysis, and pipeline review, aligned with TRIPOD+AI
reporting guidance. Supports both binary classification and survival
models. This is a drafting aid, not a certified compliance tool.

## Usage

``` r
tr_tripod_report(
  model,
  model_type = c("classification", "survival"),
  validation = NULL,
  review = NULL,
  sensitivity = NULL,
  recommendation = NULL,
  output_file = file.path(tempdir(), "triageR_report"),
  format = c("html", "docx")
)
```

## Arguments

- model:

  A fitted `triageR_model` or `triageR_survival_model` object.

- model_type:

  Character. Either `"classification"` (default) or `"survival"`. Must
  match the type of `model` supplied.

- validation:

  Optional validation object: a `triageR_validation` (from
  [`tr_validate()`](https://devwebwacky.github.io/triageR/reference/tr_validate.md))
  for classification models, or a `triageR_survival_validation` (from
  [`tr_validate_survival()`](https://devwebwacky.github.io/triageR/reference/tr_validate_survival.md))
  for survival models.

- review:

  Optional `triageR_review` object from
  [`tr_agent_review()`](https://devwebwacky.github.io/triageR/reference/tr_agent_review.md).

- sensitivity:

  Optional `triageR_sensitivity` object from
  [`tr_sensitivity()`](https://devwebwacky.github.io/triageR/reference/tr_sensitivity.md).
  Not currently supported for survival models.

- recommendation:

  Optional character string from
  [`tr_recommend_method()`](https://devwebwacky.github.io/triageR/reference/tr_recommend_method.md).

- output_file:

  Character. File path (without extension) to save the report to.
  Defaults to a file in
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html). Set explicitly
  (e.g. `file.path("my_folder", "report")`) to save elsewhere.

- format:

  Character. Either `"html"` (default) or `"docx"`.

## Value

Invisibly returns the path to the rendered report file.

## Examples

``` r
if (FALSE) { # \dontrun{
tr_tripod_report(model, validation = val, review = rev,
  output_file = file.path(tempdir(), "report"))
} # }
```
