test_that("tr_validate computes metrics on newdata without warning", {
  set.seed(1)
  df <- test_helper_data(150)
  train <- df[1:100, ]
  test <- df[101:150, ]

  model <- tr_fit(train, outcome = "disease", engine = "logistic_reg")

  expect_no_warning(result <- tr_validate(model, newdata = test))
  expect_s3_class(result, "triageR_validation")
  expect_equal(result$validated_on, "newdata")
  expect_true(all(c("roc_auc", "sens", "spec", "accuracy") %in% result$metrics$.metric))
})

test_that("tr_validate warns when no newdata is supplied", {
  df <- test_helper_data()
  model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")

  expect_warning(result <- tr_validate(model), "training data")
  expect_equal(result$validated_on, "training_data")
})

test_that("tr_validate errors on invalid model input", {
  expect_error(tr_validate(list(a = 1)), "triageR_model")
})
