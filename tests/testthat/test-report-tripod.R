test_that("tr_tripod_report generates an html file", {
  skip_on_cran()

  df <- test_helper_data(150)
  train <- df[1:100, ]
  test <- df[101:150, ]

  model <- tr_fit(train, outcome = "disease", engine = "logistic_reg")
  validation <- suppressWarnings(tr_validate(model, newdata = test))
  review <- tr_agent_review(train, model, use_agent = FALSE)

  output_path <- file.path(tempdir(), "test_report")

  result <- tr_tripod_report(
    model = model,
    validation = validation,
    review = review,
    output_file = output_path,
    format = "html"
  )

  expect_true(file.exists(paste0(output_path, ".html")))

  # cleanup
  unlink(paste0(output_path, ".html"))
})

test_that("tr_tripod_report errors on invalid model input", {
  expect_error(
    tr_tripod_report(model = list(a = 1)),
    "triageR_model"
  )
})
