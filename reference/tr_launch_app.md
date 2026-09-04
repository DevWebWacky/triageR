# Launch the triageR Shiny app

Opens an interactive Shiny application for building, validating, and
reporting clinical prediction models without writing R code directly.
Supports data upload, model fitting across multiple engines, validation,
explainability, automated pipeline review, and TRIPOD+AI report
generation. The AI method-recommendation feature requires a configured
Gemini API key (see
[`?tr_recommend_method`](https://devwebwacky.github.io/triageR/reference/tr_recommend_method.md))
and is optional.

## Usage

``` r
tr_launch_app()
```

## Value

Does not return; launches a Shiny application.

## Examples

``` r
if (interactive()) {
  tr_launch_app()
}
```
