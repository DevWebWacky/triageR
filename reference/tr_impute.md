# Impute missing values in a clinical dataset

Fills in missing values using either multiple imputation (`mice`) or a
random-forest based approach (`missForest`). The method must be chosen
explicitly, this function does not guess for you.

## Usage

``` r
tr_impute(data, method = c("mice", "missForest"), m = 5, seed = 123)
```

## Arguments

- data:

  A data frame with missing values, typically the output of
  [`tr_load_clinical()`](https://devwebwacky.github.io/triageR/reference/tr_load_clinical.md).

- method:

  Character. Either `"mice"` (default) or `"missForest"`.

- m:

  Integer. Number of multiple imputations to run if `method = "mice"`.
  Defaults to 5. Ignored for `"missForest"`.

- seed:

  Integer. Random seed for reproducibility. Defaults to 123.

## Value

A completed data frame with missing values filled in. If
`method = "mice"`, the first completed dataset is returned, and the full
`mids` object is attached as an attribute (`"mice_object"`) in case the
user wants to inspect all imputations.

## Examples

``` r
df <- data.frame(
  a = c(5, 7, 3, 9, 2, 8, 6, 4, 5, 7),
  b = c(1, 3, 2, 4, 5, 3, 2, NA, 1, 3)
)
completed <- tr_impute(df, method = "mice", m = 2)
#> Imputation complete using method: mice
```
