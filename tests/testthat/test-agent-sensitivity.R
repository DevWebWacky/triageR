test_that("tr_sensitivity runs complete-case and subgroup scenarios", {
  df <- test_helper_data(150)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  result <- suppressWarnings(suppressMessages(
    tr_sensitivity(df, model, subgroup_col = "sex")
  ))

  expect_s3_class(result, "triageR_sensitivity")
  expect_true(result$n_scenarios >= 1)
  expect_true("complete_case" %in% result$comparison$scenario)
})

test_that("tr_sensitivity warns/skips gracefully with invalid subgroup_col", {
  df <- test_helper_data(100)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  expect_warning(
    suppressMessages(tr_sensitivity(df, model, subgroup_col = "not_a_column")),
    "not found"
  )
})

test_that("tr_sensitivity errors on invalid model input", {
  df <- test_helper_data(50)
  expect_error(tr_sensitivity(df, list(a = 1)), "triageR_model")
})
