set.seed(1)
df <- data.frame(
  age = round(rnorm(200, 55, 12)),
  sex = sample(c("M", "F"), 200, replace = TRUE),
  disease = sample(c(0, 1), 200, replace = TRUE, prob = c(0.6, 0.4))
)
train <- df[1:140, ]
test <- df[141:200, ]

model <- tr_fit(train, outcome = "disease", engine = "logistic_reg")
val <- tr_validate(model, newdata = test, calibration_method = "binned")

val_smooth <- tr_validate(model, newdata = test, calibration_method = "smooth")
