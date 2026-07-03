test_that("tr_explain runs permutation importance without error", {
  df <- test_helper_data(100)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  result <- suppressWarnings(tr_explain(model, method = "permutation"))

  expect_s3_class(result, "triageR_explanation")
  expect_equal(result$method, "permutation")
  expect_true(!is.null(result$result))
})

test_that("tr_explain runs shap for a single observation", {
  df <- test_helper_data(100)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  result <- suppressWarnings(tr_explain(model, method = "shap", observation = 1))

  expect_s3_class(result, "triageR_explanation")
  expect_equal(result$method, "shap")
  expect_equal(result$observation, 1)
})

test_that("tr_explain errors on invalid model input", {
  expect_error(tr_explain(list(a = 1)), "triageR_model")
})

test_that("tr_explain errors when observation index exceeds data rows", {
  df <- test_helper_data(10)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  expect_error(
    suppressWarnings(tr_explain(model, method = "shap", observation = 999)),
    "exceeds"
  )
})
