test_that("tr_validate_survival computes a C-index for Cox PH", {
  skip_if_not_installed("censored")
  skip_if_not_installed("survival")

  df <- test_survival_helper_data()
  model <- tr_fit_survival(df, time_col = "time", event_col = "status", engine = "cox_ph")

  result <- suppressWarnings(tr_validate_survival(model, newdata = df))

  expect_s3_class(result, "triageR_survival_validation")
  expect_true(result$c_index > 0 && result$c_index < 1)
})

test_that("tr_validate_survival warns when no newdata supplied", {
  skip_if_not_installed("censored")
  skip_if_not_installed("survival")

  df <- test_survival_helper_data()
  model <- tr_fit_survival(df, time_col = "time", event_col = "status", engine = "cox_ph")

  expect_warning(tr_validate_survival(model), "training data")
})

test_that("tr_validate_survival errors on invalid model input", {
  expect_error(tr_validate_survival(list(a = 1)), "triageR_survival_model")
})
