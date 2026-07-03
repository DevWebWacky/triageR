test_that("tr_recommend_method errors when outcome column is missing", {
  df <- test_helper_data(50)
  expect_error(tr_recommend_method(df, outcome = "not_a_column"), "not found")
})

test_that("tr_recommend_method returns a recommendation when API key is available", {
  skip_if(Sys.getenv("GEMINI_API_KEY") == "", "No GEMINI_API_KEY set - skipping live API test")

  df <- test_helper_data(50)
  result <- tr_recommend_method(df, outcome = "disease")

  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})
