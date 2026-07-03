test_that("tr_impute returns data unchanged when no missing values", {
  df <- data.frame(a = 1:5, b = 6:10)
  expect_message(result <- tr_impute(df), "No missing values")
  expect_equal(sum(is.na(result)), 0)
})

test_that("tr_impute fills missing values using mice", {
  set.seed(1)
  df <- data.frame(
    a = c(5, 7, NA, 3, 9, 2, 8, NA, 6, 4, 5, 7, 3, 9, 2),
    b = c(1, 3, 2, NA, 4, 5, 3, 2, 4, NA, 1, 3, 2, 4, 5),
    c = c(20, 22, 19, 25, NA, 18, 21, 23, 20, 19, 22, NA, 20, 21, 19)
  )

  result <- suppressMessages(tr_impute(df, method = "mice", m = 2))

  expect_equal(sum(is.na(result)), 0)
  expect_equal(attr(result, "imputation_method"), "mice")
  expect_true(!is.null(attr(result, "mice_object")))
})

test_that("tr_impute errors on non-data-frame input", {
  expect_error(tr_impute(list(a = 1)), "must be a data frame")
})

test_that("tr_impute requires explicit method (no silent default guessing)", {
  df <- data.frame(a = c(1, NA, 3))
  expect_error(tr_impute(df, method = "invalid_method"))
})
