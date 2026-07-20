#' Run an automated sensitivity analysis battery
#'
#' Re-fits a clinical prediction model under several robustness checks,
#' complete-case vs imputed data, outlier exclusion, and subgroup
#' consistency, and compares performance metrics across them.
#'
#' @param data The original (pre-imputation) data frame, containing the
#'   same predictors and outcome used in `model`.
#' @param model A fitted `triageR_model` object from `tr_fit()`.
#' @param subgroup_col Optional character. Name of a categorical column
#'   (e.g. "sex") to check subgroup consistency across.
#' @param outlier_sd Numeric. Number of standard deviations beyond which a
#'   numeric predictor value is considered an outlier and excluded in the
#'   outlier-robustness check. Defaults to 3.
#'
#' @return A `triageR_sensitivity` object (list) with a comparison tibble
#'   of metrics across all sensitivity scenarios.
#' @export
#'
#' @examples
#' \dontrun{
#' tr_sensitivity(data, model, subgroup_col = "sex")
#' }
tr_sensitivity <- function(data, model, subgroup_col = NULL, outlier_sd = 3) {

  if (!inherits(model, "triageR_model")) {
    stop("`model` must be a triageR_model object from tr_fit().", call. = FALSE)
  }

  outcome <- model$outcome
  engine <- model$engine
  predictors <- model$predictors

  scenarios <- list()

  # complete-case analysis
  complete_data <- data[stats::complete.cases(data[, c(outcome, predictors)]), ]
  if (nrow(complete_data) >= 10) {
    m_cc <- tryCatch(
      tr_fit(complete_data, outcome = outcome, engine = engine, predictors = predictors),
      error = function(e) NULL
    )
    if (!is.null(m_cc)) {
      v_cc <- suppressWarnings(tr_validate(m_cc))
      scenarios[["complete_case"]] <- v_cc$metrics
    }
  }

  # outlier exclusion
  numeric_preds <- predictors[sapply(data[predictors], is.numeric)]
  outlier_flag <- rep(FALSE, nrow(data))
  for (col in numeric_preds) {
    z <- scale(data[[col]])
    outlier_flag <- outlier_flag | (abs(z) > outlier_sd & !is.na(z))
  }
  no_outliers <- data[!outlier_flag, ]
  if (nrow(no_outliers) >= 10 && sum(outlier_flag, na.rm = TRUE) > 0) {
    m_out <- tryCatch(
      tr_fit(no_outliers, outcome = outcome, engine = engine, predictors = predictors),
      error = function(e) NULL
    )
    if (!is.null(m_out)) {
      v_out <- suppressWarnings(tr_validate(m_out))
      scenarios[["outliers_excluded"]] <- v_out$metrics
    }
  } else {
    message("No outliers detected beyond ", outlier_sd, " SD, skipping outlier scenario.")
  }

  # subgroup consistency
  if (!is.null(subgroup_col)) {
    if (!subgroup_col %in% names(data)) {
      warning("subgroup_col '", subgroup_col, "' not found, skipping subgroup check.",
              call. = FALSE)
    } else {
      groups <- unique(stats::na.omit(data[[subgroup_col]]))
      sub_predictors <- setdiff(predictors, subgroup_col)
      for (g in groups) {
        sub_data <- data[data[[subgroup_col]] == g & !is.na(data[[subgroup_col]]), ]
        if (nrow(sub_data) >= 10) {
          m_sub <- tryCatch(
            tr_fit(sub_data, outcome = outcome, engine = engine, predictors = sub_predictors),
            error = function(e) {
              message("Subgroup '", g, "' failed to fit: ", conditionMessage(e))
              NULL
            }
          )
          if (!is.null(m_sub)) {
            v_sub <- suppressWarnings(tr_validate(m_sub))
            scenarios[[paste0("subgroup_", subgroup_col, "_", g)]] <- v_sub$metrics
          }
        } else {
          message("Subgroup '", g, "' has fewer than 10 rows, skipping.")
        }
      }
    }
  }

  # combine all scenarios into one comparison tibble
  if (length(scenarios) == 0) {
    message("No sensitivity scenarios could be run (data too small or no variation).")
    return(invisible(NULL))
  }

  comparison <- dplyr::bind_rows(scenarios, .id = "scenario")

  out <- list(
    comparison = comparison,
    n_scenarios = length(scenarios)
  )
  class(out) <- "triageR_sensitivity"

  message("\n--- Sensitivity Analysis Comparison ---\n")
  message(paste(utils::capture.output(
    print(tidyr::pivot_wider(comparison, names_from = .metric, values_from = .estimate))
  ), collapse = "\n"))
  message("\nNote: Compare AUC/sensitivity/specificity across scenarios. Large swings ",
          "suggest the model is not robust to that assumption.")

  invisible(out)
}
