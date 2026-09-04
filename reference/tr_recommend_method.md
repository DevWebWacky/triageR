# Recommend an appropriate statistical or ML method (AI agent)

Uses an LLM to inspect the structure of a clinical dataset and suggest
an appropriate statistical or machine learning approach, with reasoning.
This is an assistive tool, not a replacement for expert judgment.

## Usage

``` r
tr_recommend_method(data, outcome, context = NULL)
```

## Arguments

- data:

  A data frame, typically the output of
  [`tr_load_clinical()`](https://devwebwacky.github.io/triageR/reference/tr_load_clinical.md).

- outcome:

  Character. Name of the outcome column of interest.

- context:

  Optional character string giving extra clinical context (e.g.
  "predicting 30-day readmission in heart failure patients").

## Value

Invisibly returns the raw text recommendation (character string). Also
prints the recommendation to console.

## Examples

``` r
if (FALSE) { # \dontrun{
tr_recommend_method(data, outcome = "disease",
  context = "predicting diabetes onset in adults")
} # }
```
