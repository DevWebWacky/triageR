test_that("tr_load_clinical works with a data frame", {
  df <- data.frame(id = 1:3, age = c(45, 62, 38), sex = c("F", "M", "F"))
  result <- tr_load_clinical(df, id_col = "id")

  expect_s3_class(result, "triageR_data")
  expect_equal(nrow(result), 3)
  expect_equal(attr(result, "n_patients"), 3)
})

test_that("tr_load_clinical errors when id_col is missing", {
  df <- data.frame(age = c(45, 62), sex = c("F", "M"))
  expect_error(tr_load_clinical(df, id_col = "id"), "not found")
})

test_that("tr_load_clinical warns on duplicate ids", {
  df <- data.frame(id = c(1, 1, 2), age = c(45, 46, 38))
  expect_warning(tr_load_clinical(df, id_col = "id"), "duplicated")
})

test_that("tr_load_clinical errors on invalid input type", {
  expect_error(tr_load_clinical(list(a = 1)), "must be a file path")
})
