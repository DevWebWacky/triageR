#' Recommend an appropriate statistical or ML method (AI agent)
#'
#' Uses an LLM to inspect the structure of a clinical dataset and suggest
#' an appropriate statistical or machine learning approach, with reasoning.
#' This is an assistive tool, not a replacement for expert judgment.
#'
#' @param data A data frame, typically the output of `tr_load_clinical()`.
#' @param outcome Character. Name of the outcome column of interest.
#' @param context Optional character string giving extra clinical context
#'   (e.g. "predicting 30-day readmission in heart failure patients").
#'
#' @return Invisibly returns the raw text recommendation (character string).
#'   Also prints the recommendation to console.
#' @export
#'
#' @examples
#' \dontrun{
#' tr_recommend_method(data, outcome = "disease",
#'   context = "predicting diabetes onset in adults")
#' }
tr_recommend_method <- function(data, outcome, context = NULL) {

  if (!requireNamespace("ellmer", quietly = TRUE)) {
    stop("Package 'ellmer' is required for tr_recommend_method(). ",
         "Install it with install.packages('ellmer').", call. = FALSE)
  }

  if (!outcome %in% names(data)) {
    stop("Outcome column '", outcome, "' not found in data.", call. = FALSE)
  }

  #data structure summary (NOT the raw data - patient
  # privacy matters, so only structure/summary stats is sent, never
  # raw rows)
  outcome_vec <- data[[outcome]]
  outcome_type <- if (length(unique(stats::na.omit(outcome_vec))) == 2) {
    "binary"
  } else if (is.numeric(outcome_vec)) {
    "continuous"
  } else {
    "categorical (>2 levels)"
  }

  predictor_summary <- data.frame(
    column = setdiff(names(data), outcome),
    type = sapply(data[setdiff(names(data), outcome)], function(x) class(x)[1]),
    pct_missing = round(sapply(data[setdiff(names(data), outcome)],
                               function(x) mean(is.na(x))) * 100, 1),
    row.names = NULL
  )

  n_rows <- nrow(data)

  #prompt, structure/summary only, no raw patient data
  prompt <- paste0(
    "You are assisting a researcher in choosing an appropriate statistical ",
    "or machine learning method for a clinical prediction modelling task.\n\n",
    "Dataset summary:\n",
    "- Number of patients: ", n_rows, "\n",
    "- Outcome variable: '", outcome, "' (type: ", outcome_type, ")\n",
    "- Predictors:\n",
    paste(capture.output(print(predictor_summary)), collapse = "\n"), "\n\n",
    if (!is.null(context)) paste0("Clinical context: ", context, "\n\n") else "",
    "Based on this, recommend an appropriate statistical or machine learning ",
    "approach. Briefly justify your reasoning (e.g. sample size, outcome type, ",
    "missingness), and flag any concerns (e.g. small sample size, high ",
    "missingness, class imbalance). Keep the response concise and practical, ",
    "aimed at a researcher who will implement this in R."
  )

  #ellmer call
  chat <- ellmer::chat_google_gemini(
    system_prompt = "You are a careful, concise clinical biostatistics advisor.",
    model = "gemini-flash-latest"
  )
  response <- chat$chat(prompt)

  cat("\n--- triageR Method Recommendation ---\n\n")
  cat(response, "\n")
  cat("\n--- This is an AI-generated suggestion. Always apply expert clinical",
      "and statistical judgment. ---\n")

  invisible(response)
}
