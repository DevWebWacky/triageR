# Load and standardize a clinical dataset

Reads a flat clinical dataset (CSV or data frame) and returns it as a
standardized `triageR` object with basic structure checks. This is the
entry point for most triageR workflows.

## Usage

``` r
tr_load_clinical(data, id_col = "id")
```

## Arguments

- data:

  A file path to a CSV, or an existing data frame.

- id_col:

  Character. Name of the column identifying unique patients. Defaults to
  `"id"`.

## Value

A tibble of class `triageR_data`, with basic metadata attached.

## Examples

``` r
df <- data.frame(
  id = 1:5,
  age = c(45, 62, 38, 71, 55),
  sex = c("F", "M", "F", "M", "F")
)
tr_load_clinical(df, id_col = "id")
#> # A tibble: 5 × 3
#>      id   age sex  
#>   <int> <dbl> <chr>
#> 1     1    45 F    
#> 2     2    62 M    
#> 3     3    38 F    
#> 4     4    71 M    
#> 5     5    55 F    
```
