#' Fit a clinical prediction model
#'
#' Fits a binary classification model using the `parsnip`/`workflows`
#' framework. The user must specify the model engine explicitly.
#'
#' @param data A data frame containing predictors and the outcome column.
#' @param outcome Character. Name of the binary outcome column (must be a
#'   factor or coercible to one, with the event of interest as the second level).
#' @param engine Character. Model engine to use. One of `"logistic_reg"`,
#'   `"random_forest"`, or `"boost_tree"`.
#' @param predictors Character vector of predictor column names. If `NULL`
#'   (default), all columns except `outcome` are used.
#'
#' @return A fitted `triageR_model` object — a list containing the fitted
#'   workflow, the engine used, and the outcome/predictor names.
#' @export
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   age = round(rnorm(50, 55, 12)),
#'   sex = sample(c("M", "F"), 50, replace = TRUE),
#'   disease = sample(c(0, 1), 50, replace = TRUE)
#' )
#' model <- tr_fit(df, outcome = "disease", engine = "logistic_reg")
tr_fit <- function(data, outcome, engine = c("logistic_reg", "random_forest", "boost_tree"),
                   predictors = NULL) {

  engine <- match.arg(engine)

  # basic checks
  if (!outcome %in% names(data)) {
    stop("Outcome column '", outcome, "' not found in data.", call. = FALSE)
  }

  if (is.null(predictors)) {
    predictors <- setdiff(names(data), outcome)
  }

  # outcome must be a factor (classification requires this)
  data[[outcome]] <- as.factor(data[[outcome]])

  if (nlevels(data[[outcome]]) != 2) {
    stop("Outcome '", outcome, "' must be binary (exactly 2 levels). ",
         "Found ", nlevels(data[[outcome]]), " levels.", call. = FALSE)
  }

  #the formula
  formula <- stats::as.formula(
    paste(outcome, "~", paste(predictors, collapse = " + "))
  )

  #preprocessing recipe
  recipe_obj <- recipes::recipe(formula, data = data) |>
    recipes::step_dummy(recipes::all_nominal_predictors()) |>
    recipes::step_zv(recipes::all_predictors())

  # model spec based on chosen engine
  model_spec <- switch(engine,
                       logistic_reg = parsnip::logistic_reg() |>
                         parsnip::set_engine("glm") |>
                         parsnip::set_mode("classification"),

                       random_forest = parsnip::rand_forest() |>
                         parsnip::set_engine("ranger") |>
                         parsnip::set_mode("classification"),

                       boost_tree = parsnip::boost_tree() |>
                         parsnip::set_engine("xgboost") |>
                         parsnip::set_mode("classification")
  )

  # workflow and fit
  wf <- workflows::workflow() |>
    workflows::add_recipe(recipe_obj) |>
    workflows::add_model(model_spec)

  fitted_wf <- parsnip::fit(wf, data = data)

  # package everything
  result <- list(
    workflow = fitted_wf,
    engine = engine,
    outcome = outcome,
    predictors = predictors,
    training_data = data
  )
  class(result) <- "triageR_model"

  message("Model fitted successfully using engine: ", engine)
  result
}
