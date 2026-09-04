test_helper_data <- function(n = 100, seed = 1) {
  set.seed(seed)
  data.frame(
    age = round(rnorm(n, 55, 12)),
    bmi = round(rnorm(n, 27, 4), 1),
    sex = sample(c("M", "F"), n, replace = TRUE),
    disease = sample(c(0, 1), n, replace = TRUE, prob = c(0.6, 0.4))
  )
}

test_survival_helper_data <- function() {
  library(survival)
  lung_clean <- lung
  lung_clean$status <- lung_clean$status - 1
  lung_clean[stats::complete.cases(lung_clean), ]
}
