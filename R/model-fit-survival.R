#' Fit a clinical survival (time-to-event) model
#'
#' triageR: Survival Analysis Utilities
#'
#' @importFrom survival Surv
#' @keywords internal
"_PACKAGE"
#' Fits a survival model using the `censored`/`parsnip` framework. The
#' outcome must be specified as separate time and event columns (following
#' `survival::Surv()` convention), and the user must explicitly choose an
#' engine.
#'
#' @param data A data frame containing predictors, a time column, and an
#'   event column.
#' @param time_col Character. Name of the column giving time to event or
#'   censoring.
#' @param event_col Character. Name of the column indicating event status
#'   (1 = event occurred, 0 = censored), following standard survival
#'   analysis convention.
#' @param engine Character. One of `"cox_ph"` (Cox Proportional Hazards) or
#'   `"survival_rf"` (Random Survival Forest via the `aorsf` engine).
#' @param predictors Character vector of predictor column names. If `NULL`
#'   (default), all columns except `time_col` and `event_col` are used.
#'
#' @return A fitted `triageR_survival_model` object (list) containing the
#'   fitted workflow, engine, and time/event/predictor column names.
#' @importFrom survival Surv
#' @export
#'
#' @examples
#' if (requireNamespace("survival", quietly = TRUE)) {
#'   library(survival)
#'   lung_clean <- lung
#'   lung_clean$status <- lung_clean$status - 1  # convert 1/2 to 0/1
#'   lung_clean <- lung_clean[stats::complete.cases(lung_clean), ]
#'   model <- tr_fit_survival(lung_clean, time_col = "time",
#'                             event_col = "status", engine = "cox_ph")
#' }
tr_fit_survival <- function(data, time_col, event_col,
                            engine = c("cox_ph", "survival_rf"),
                            predictors = NULL) {

  engine <- match.arg(engine)

  if (!requireNamespace("censored", quietly = TRUE)) {
    stop("Package 'censored' is required for tr_fit_survival(). ",
         "Install it with install.packages('censored').", call. = FALSE)
  }

  # Step 1: basic checks
  if (!time_col %in% names(data)) {
    stop("Time column '", time_col, "' not found in data.", call. = FALSE)
  }
  if (!event_col %in% names(data)) {
    stop("Event column '", event_col, "' not found in data.", call. = FALSE)
  }

  event_vals <- unique(stats::na.omit(data[[event_col]]))
  if (!all(event_vals %in% c(0, 1))) {
    stop("Event column '", event_col, "' must be coded as 0 (censored) and ",
         "1 (event occurred).", call. = FALSE)
  }

  if (is.null(predictors)) {
    predictors <- setdiff(names(data), c(time_col, event_col))
  }

  # Step 2: build the survival formula (Surv() must be unqualified for recipes to parse the formula correctly)
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Package 'survival' is required for tr_fit_survival(). ",
         "Install it with install.packages('survival').", call. = FALSE)
  }
  formula <- stats::as.formula(
    paste0("Surv(", time_col, ", ", event_col, ") ~ ",
           paste(predictors, collapse = " + "))
  )

  # Step 3: define the model spec based on chosen engine
  # (note: recipes does not support Surv() in formulas, so we use add_formula
  model_spec <- switch(engine,
                       cox_ph = parsnip::proportional_hazards() |>
                         parsnip::set_engine("survival") |>
                         parsnip::set_mode("censored regression"),

                       survival_rf = {
                         if (!requireNamespace("aorsf", quietly = TRUE)) {
                           stop("Package 'aorsf' is required for engine = 'survival_rf'. ",
                                "Install it with install.packages('aorsf').", call. = FALSE)
                         }
                         parsnip::rand_forest() |>
                           parsnip::set_engine("aorsf") |>
                           parsnip::set_mode("censored regression")
                       }
  )

  # Step 4: bundle into a workflow and fit (using add_formula, not add_recipe)
  wf <- workflows::workflow() |>
    workflows::add_formula(formula) |>
    workflows::add_model(model_spec)

  fitted_wf <- parsnip::fit(wf, data = data)

  # Step 6: package everything into our own object
  result <- list(
    workflow = fitted_wf,
    engine = engine,
    time_col = time_col,
    event_col = event_col,
    predictors = predictors,
    training_data = data
  )
  class(result) <- "triageR_survival_model"

  message("Survival model fitted successfully using engine: ", engine)
  result
}
