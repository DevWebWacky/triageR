#' Review a clinical modelling pipeline for common pitfalls
#'
#' Runs a series of rule-based checks for common clinical-ML pitfalls
#' (class imbalance, low events-per-variable, possible leakage, near-zero
#' variance predictors), then optionally asks an LLM to summarize the
#' findings in plain language.
#'
#' @param data The data frame used to fit the model.
#' @param model A fitted `triageR_model` object from `tr_fit()`.
#' @param use_agent Logical. If `TRUE` (default), also generates an
#'   AI-written plain-language summary of the findings via `ellmer`.
#'
#' @return A `triageR_review` object (list) containing a tibble of flags
#'   and, if `use_agent = TRUE`, an AI-generated summary.
#' @export
#'
#' @examples
#' \dontrun{
#' tr_agent_review(data, model)
#' }
tr_agent_review <- function(data, model, use_agent = TRUE) {

  if (!inherits(model, "triageR_model")) {
    stop("`model` must be a triageR_model object from tr_fit().", call. = FALSE)
  }

  outcome <- model$outcome
  predictors <- model$predictors
  flags <- list()

  # Check class imbalance
  outcome_tab <- table(data[[outcome]])
  minority_pct <- round(min(outcome_tab) / sum(outcome_tab) * 100, 1)
  if (minority_pct < 20) {
    flags[["class_imbalance"]] <- paste0(
      "Class imbalance detected: minority class is only ", minority_pct,
      "% of the outcome. Consider reporting AUC/sensitivity/specificity ",
      "rather than accuracy alone, and consider resampling methods."
    )
  }

  # Check events per variable (EPV)
  n_events <- min(outcome_tab)
  n_predictors <- length(predictors)
  epv <- round(n_events / n_predictors, 1)
  if (epv < 10) {
    flags[["low_epv"]] <- paste0(
      "Low events-per-variable ratio (EPV = ", epv, "). Clinical prediction ",
      "modelling guidance generally recommends at least 10 events per ",
      "predictor to avoid overfitting. Consider reducing predictors or ",
      "collecting more data."
    )
  }

  # Check possible leakage (near-perfect single predictor)
  for (col in predictors) {
    if (is.numeric(data[[col]])) {
      suppressWarnings({
        test_auc <- tryCatch({
          pred_tbl <- data.frame(truth = as.factor(data[[outcome]]), val = data[[col]])
          pred_tbl <- pred_tbl[stats::complete.cases(pred_tbl), ]
          as.numeric(pROC::auc(pROC::roc(pred_tbl$truth, pred_tbl$val, quiet = TRUE)))
        }, error = function(e) NA)
      })
      if (!is.na(test_auc) && (test_auc > 0.97 || test_auc < 0.03)) {
        flags[["possible_leakage"]] <- paste0(
          "Predictor '", col, "' alone achieves AUC ~", round(max(test_auc, 1 - test_auc), 2),
          " predicting the outcome. This may indicate data leakage ",
          "(e.g. the variable is a proxy for or derived from the outcome)."
        )
      }
    }
  }

  #Check near-zero variance predictors
  for (col in predictors) {
    if (is.numeric(data[[col]]) && stats::sd(data[[col]], na.rm = TRUE) == 0) {
      flags[["zero_variance"]] <- paste0(
        "Predictor '", col, "' has zero variance (same value for all patients) ",
        "and contributes nothing to the model."
      )
    }
  }

  # sample size checking
  if (nrow(data) < 100) {
    flags[["small_sample"]] <- paste0(
      "Sample size is small (n = ", nrow(data), "). Results should be ",
      "interpreted cautiously and external validation is strongly recommended."
    )
  }

  #build flags tibble
  if (length(flags) == 0) {
    flags_tbl <- tibble::tibble(check = character(0), message = character(0))
    cat("\n--- triageR Pipeline Review ---\n\nNo major issues flagged.\n")
  } else {
    flags_tbl <- tibble::tibble(
      check = names(flags),
      message = unlist(flags, use.names = FALSE)
    )
    cat("\n--- triageR Pipeline Review ---\n\n")
    for (i in seq_len(nrow(flags_tbl))) {
      cat("[", flags_tbl$check[i], "]\n", flags_tbl$message[i], "\n\n", sep = "")
    }
  }

  out <- list(flags = flags_tbl, ai_summary = NULL)

  #AI narrative summary
  if (use_agent && nrow(flags_tbl) > 0) {
    if (!requireNamespace("ellmer", quietly = TRUE)) {
      message("ellmer not available, skipping AI summary.")
    } else {
      prompt <- paste0(
        "A clinical prediction model pipeline review flagged the following ",
        "issues:\n\n",
        paste(paste0("- ", flags_tbl$message), collapse = "\n"),
        "\n\nSummarize these concerns in 2-3 sentences for a researcher, ",
        "prioritizing the most serious issue first."
      )
      chat <- ellmer::chat_google_gemini(
        system_prompt = "You are a careful, concise clinical biostatistics advisor."
      )
      summary_text <- chat$chat(prompt)
      cat("--- AI Summary ---\n", summary_text, "\n")
      out$ai_summary <- summary_text
    }
  }

  class(out) <- "triageR_review"
  invisible(out)
}
