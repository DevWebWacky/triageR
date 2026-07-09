#' Validate a clinical prediction model
#'
#' Computes discrimination (AUC, sensitivity, specificity) and calibration
#' metrics for a fitted `triageR_model`. Can validate on new (external/holdout)
#' data, or fall back to the training data with a clear warning.
#'
#' @param model A fitted `triageR_model` object from `tr_fit()`.
#' @param newdata Optional data frame to validate on. If `NULL` (default),
#'   validation runs on the original training data, with a warning.
#' @param threshold Numeric. Probability threshold for classifying the
#'   positive class. Defaults to 0.5.
#'
#' @return A `triageR_validation` object (list) containing a metrics tibble
#'   and the underlying predictions, invisibly printed as a summary.
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
#' tr_validate(model, newdata = df)
tr_validate <- function(model, newdata = NULL, threshold = 0.5) {

  if (!inherits(model, "triageR_model")) {
    stop("`model` must be a triageR_model object from tr_fit().", call. = FALSE)
  }

  # Decide which data to validate on
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

  outcome <- model$outcome

  if (!outcome %in% names(newdata)) {
    stop("Outcome column '", outcome, "' not found in newdata.", call. = FALSE)
  }

  newdata[[outcome]] <- as.factor(newdata[[outcome]])

  #predictions for both class and probability
  pred_class <- stats::predict(model$workflow, new_data = newdata)
  pred_prob  <- stats::predict(model$workflow, new_data = newdata, type = "prob")

  #Assemble results into one tibble for yardstick
  results <- dplyr::bind_cols(
    truth = newdata[[outcome]],
    pred_class,
    pred_prob
  )

  # yardstick expects the probability column of the event level (2nd level)
  event_level <- levels(newdata[[outcome]])[2]
  prob_col <- paste0(".pred_", event_level)

  #Compute metrics
  auc <- yardstick::roc_auc(results, truth = truth, !!prob_col, event_level = "second")
  sens <- yardstick::sens(results, truth = truth, estimate = .pred_class, event_level = "second")
  spec <- yardstick::spec(results, truth = truth, estimate = .pred_class, event_level = "second")
  acc  <- yardstick::accuracy(results, truth = truth, estimate = .pred_class)

  metrics_tbl <- dplyr::bind_rows(auc, sens, spec, acc)

  #build confusion matrix
  conf_mat <- yardstick::conf_mat(results, truth = truth, estimate = .pred_class)
  conf_tbl <- as.data.frame(conf_mat$table)
  names(conf_tbl) <- c("predicted", "actual", "n")

  #build ROC curve data and plot
  roc_data <- yardstick::roc_curve(results, truth = truth, !!prob_col, event_level = "second")
  roc_plot <- ggplot2::ggplot(roc_data, ggplot2::aes(x = 1 - specificity, y = sensitivity)) +
    ggplot2::geom_abline(lty = 3, color = "gray50", linewidth = 0.8) +
    ggplot2::geom_path(color = "#2C5F8A", linewidth = 1.2) +
    ggplot2::labs(
      title = "ROC Curve",
      subtitle = paste0("AUC = ", round(auc$.estimate, 3)),
      x = "1 - Specificity",
      y = "Sensitivity"
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank()
    )

  #package into our own object
  out <- list(
    metrics = metrics_tbl,
    confusion_matrix = conf_mat,
    roc_curve = roc_data,
    roc_plot = roc_plot,
    predictions = results,
    validated_on = if (identical(newdata, model$training_data)) "training_data" else "newdata"
  )
  class(out) <- "triageR_validation"

  cat("Validation metrics (", out$validated_on, "):\n\n", sep = "")
  print(metrics_tbl)
  cat("\nConfusion Matrix:\n\n")
  print(conf_mat)
  print(roc_plot)

  invisible(out)
}
