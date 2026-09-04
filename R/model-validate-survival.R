#' Validate a clinical survival model
#'
#' Computes the concordance index (C-index) for a fitted
#' `triageR_survival_model` — the survival-analysis equivalent of AUC,
#' measuring how well the model ranks patients by risk. Can validate on
#' new (external/holdout) data, or fall back to the training data with a
#' clear warning.
#'
#' @param model A fitted `triageR_survival_model` object from
#'   `tr_fit_survival()`.
#' @param newdata Optional data frame to validate on. If `NULL` (default),
#'   validation runs on the original training data, with a warning.
#'
#' @return A `triageR_survival_validation` object (list) containing the
#'   C-index and supporting details.
#' @export
#'
#' @examples
#' if (requireNamespace("survival", quietly = TRUE)) {
#'   library(survival)
#'   lung_clean <- lung
#'   lung_clean$status <- lung_clean$status - 1
#'   lung_clean <- lung_clean[stats::complete.cases(lung_clean), ]
#'   model <- tr_fit_survival(lung_clean, time_col = "time",
#'                             event_col = "status", engine = "cox_ph")
#'   tr_validate_survival(model, newdata = lung_clean)
#' }
tr_validate_survival <- function(model, newdata = NULL) {

  if (!inherits(model, "triageR_survival_model")) {
    stop("`model` must be a triageR_survival_model object from ",
         "tr_fit_survival().", call. = FALSE)
  }

  if (is.null(newdata)) {
    warning(
      "No `newdata` supplied, validating on the training data. ",
      "These metrics will be optimistic and should NOT be used for formal ",
      "reporting or TRIPOD+AI compliance. Supply a separate test/holdout set ",
      "for proper validation.",
      call. = FALSE
    )
    newdata <- model$training_data
  }

  time_col <- model$time_col
  event_col <- model$event_col

  if (!time_col %in% names(newdata) || !event_col %in% names(newdata)) {
    stop("Time column '", time_col, "' and/or event column '", event_col,
         "' not found in newdata.", call. = FALSE)
  }

  # Step 1: get predicted event times (works across all censored-regression
  # engines, unlike "linear_pred" which tree-based models don't support)
  pred <- stats::predict(model$workflow, new_data = newdata, type = "time")

  # Step 2: compute concordance index using survival::concordance()
  # note: predicted TIME is used with reverse = TRUE, since a shorter
  # predicted survival time corresponds to higher risk
  surv_obj <- survival::Surv(newdata[[time_col]], newdata[[event_col]])
  conc <- survival::concordance(surv_obj ~ pred$.pred_time)

  c_index <- conc$concordance
  c_index_se <- sqrt(conc$var)

  out <- list(
    c_index = c_index,
    c_index_se = c_index_se,
    n = nrow(newdata),
    n_events = sum(newdata[[event_col]] == 1),
    validated_on = if (identical(newdata, model$training_data)) "training_data" else "newdata"
  )
  class(out) <- "triageR_survival_validation"

  message("Survival validation (", out$validated_on, "):\n")
  message("C-index: ", round(c_index, 3), " (SE: ", round(c_index_se, 3), ")")
  message("N = ", out$n, ", events = ", out$n_events)
  message("\nInterpretation: C-index of 0.5 = no better than chance; ",
          "1.0 = perfect discrimination between patients who experience ",
          "the event sooner vs. later.")

  invisible(out)
}
