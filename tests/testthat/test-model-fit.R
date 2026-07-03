test_that("tr_fit fits a logistic regression model", {
  df <- test_helper_data()
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  expect_s3_class(model, "triageR_model")
  expect_equal(model$engine, "logistic_reg")
  expect_equal(model$outcome, "disease")
  expect_true(!is.null(model$workflow))
})

test_that("tr_fit fits a random forest model", {
  df <- test_helper_data()
  model <- tr_fit(df, outcome = "disease", engine = "random_forest")

  expect_s3_class(model, "triageR_model")
  expect_equal(model$engine, "random_forest")
})

test_that("tr_fit errors when outcome column is missing", {
  df <- test_helper_data()
  expect_error(tr_fit(df, outcome = "not_a_column", engine = "logistic_reg"), "not found")
})

test_that("tr_fit errors when outcome is not binary", {
  df <- test_helper_data()
  df$disease <- sample(c("a", "b", "c"), nrow(df), replace = TRUE)
  expect_error(tr_fit(df, outcome = "disease", engine = "logistic_reg"), "binary")
})

test_that("tr_fit requires explicit engine choice", {
  df <- test_helper_data()
  expect_error(tr_fit(df, outcome = "disease", engine = "not_a_real_engine"))
})
