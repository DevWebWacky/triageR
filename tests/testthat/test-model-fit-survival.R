test_that("tr_fit_survival fits a Cox PH model", {
  skip_if_not_installed("censored")
  skip_if_not_installed("survival")

  df <- test_survival_helper_data()
  model <- tr_fit_survival(df, time_col = "time", event_col = "status", engine = "cox_ph")

  expect_s3_class(model, "triageR_survival_model")
  expect_equal(model$engine, "cox_ph")
  expect_equal(model$time_col, "time")
  expect_equal(model$event_col, "status")
})

test_that("tr_fit_survival fits a random survival forest model", {
  skip_if_not_installed("censored")
  skip_if_not_installed("aorsf")
  skip_if_not_installed("survival")

  df <- test_survival_helper_data()
  model <- tr_fit_survival(df, time_col = "time", event_col = "status", engine = "survival_rf")

  expect_s3_class(model, "triageR_survival_model")
  expect_equal(model$engine, "survival_rf")
})

test_that("tr_fit_survival errors when time_col is missing", {
  df <- test_survival_helper_data()
  expect_error(
    tr_fit_survival(df, time_col = "not_a_column", event_col = "status", engine = "cox_ph"),
    "not found"
  )
})

test_that("tr_fit_survival errors when event_col is not coded 0/1", {
  df <- test_survival_helper_data()
  df$status <- df$status + 1  # back to 1/2 coding
  expect_error(
    tr_fit_survival(df, time_col = "time", event_col = "status", engine = "cox_ph"),
    "0 \\(censored\\) and"
  )
})
