test_that("tr_check_missing returns correct summary", {
  df <- data.frame(
    a = c(1, NA, 3, NA),
    b = c(1, 2, 3, 4),
    c = c(NA, NA, NA, 4)
  )

  result <- suppressWarnings(tr_check_missing(df))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_true(all(c("column", "n_missing", "pct_missing") %in% names(result)))

  # column 'c' has most missing (3 of 4), should be sorted first
  expect_equal(result$column[1], "c")
  expect_equal(result$n_missing[1], 3)
})

test_that("tr_check_missing errors on non-data-frame input", {
  expect_error(tr_check_missing(list(a = 1)), "must be a data frame")
})

test_that("tr_check_missing handles data with no missing values", {
  df <- data.frame(a = 1:3, b = 4:6)
  result <- suppressWarnings(tr_check_missing(df))

  expect_true(all(result$n_missing == 0))
})
