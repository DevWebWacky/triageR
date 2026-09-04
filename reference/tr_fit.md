# Fit a clinical prediction model

Fits a binary classification model using the `parsnip`/`workflows`
framework. The user must specify the model engine explicitly.

## Usage

``` r
tr_fit(
  data,
  outcome,
  engine = c("logistic_reg", "random_forest", "boost_tree"),
  predictors = NULL
)
```

## Arguments

- data:

  A data frame containing predictors and the outcome column.

- outcome:

  Character. Name of the binary outcome column (must be a factor or
  coercible to one, with the event of interest as the second level).

- engine:

  Character. Model engine to use. One of `"logistic_reg"`,
  `"random_forest"`, or `"boost_tree"`.

- predictors:

  Character vector of predictor column names. If `NULL` (default), all
  columns except `outcome` are used.

## Value

A fitted `triageR_model` object — a list containing the fitted workflow,
the engine used, and the outcome/predictor names.

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
```
