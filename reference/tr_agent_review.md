# Review a clinical modelling pipeline for common pitfalls

Runs a series of rule-based checks for common clinical-ML pitfalls
(class imbalance or low event rate, low events-per-variable, possible
leakage, near-zero variance predictors), then optionally asks an LLM to
summarize the findings in plain language. Works with both binary
classification models (`triageR_model`) and survival models
(`triageR_survival_model`).

## Usage

``` r
tr_agent_review(data, model, use_agent = TRUE)
```

## Arguments

- data:

  The data frame used to fit the model.

- model:

  A fitted `triageR_model` or `triageR_survival_model` object.

- use_agent:

  Logical. If `TRUE` (default), also generates an AI-written
  plain-language summary of the findings via `ellmer`.

## Value

A `triageR_review` object (list) containing a tibble of flags and, if
`use_agent = TRUE`, an AI-generated summary.

## Examples

``` r
if (FALSE) { # \dontrun{
tr_agent_review(data, model)
} # }
```
