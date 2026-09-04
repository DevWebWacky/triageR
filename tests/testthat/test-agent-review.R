test_that("tr_agent_review flags low EPV correctly", {
  df <- test_helper_data(60)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  result <- tr_agent_review(df, model, use_agent = FALSE)

  expect_s3_class(result, "triageR_review")
  expect_true(is.null(result$ai_summary))
  expect_true(nrow(result$flags) > 0)
})

test_that("tr_agent_review flags zero variance predictors", {
  df <- test_helper_data(100)
  df$constant_col <- 5
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  result <- tr_agent_review(df, model, use_agent = FALSE)

  expect_true("zero_variance" %in% result$flags$check)
})

test_that("tr_agent_review flags small sample size", {
  df <- test_helper_data(50)
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  result <- tr_agent_review(df, model, use_agent = FALSE)

  expect_true("small_sample" %in% result$flags$check)
})

test_that("tr_agent_review errors on invalid model input", {
  df <- test_helper_data(50)
  expect_error(tr_agent_review(df, list(a = 1)), "triageR_model")
})

test_that("tr_agent_review flags low event rate for survival models", {
  skip_if_not_installed("censored")
  skip_if_not_installed("survival")
  library(survival)

  set.seed(1)
  small_surv <- data.frame(
    time = rexp(30, rate = 0.1),
    status = sample(c(0, 1), 30, replace = TRUE, prob = c(0.9, 0.1)),
    age = stats::rnorm(30, 60, 10)
  )
  model <- tr_fit_survival(small_surv, time_col = "time", event_col = "status", engine = "cox_ph")

  result <- tr_agent_review(small_surv, model, use_agent = FALSE)

  expect_s3_class(result, "triageR_review")
  expect_true("low_event_rate" %in% result$flags$check)
})

test_that("tr_agent_review works for survival models with no issues", {
  skip_if_not_installed("censored")
  skip_if_not_installed("survival")

  df <- test_survival_helper_data()
  model <- tr_fit_survival(df, time_col = "time", event_col = "status", engine = "cox_ph")

  result <- tr_agent_review(df, model, use_agent = FALSE)

  expect_s3_class(result, "triageR_review")
})
