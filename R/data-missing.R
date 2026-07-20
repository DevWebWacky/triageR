#' Check missing data in a clinical dataset
#'
#' Produces a summary table of missingness per column, plus a visual plot
#' showing the pattern of missing data across the dataset.
#'
#' @param data A data frame, typically the output of `tr_load_clinical()`.
#'
#' @return Invisibly returns a summary tibble (columns, n_missing, pct_missing).
#'   Also prints a summary to console and displays a missingness plot as a
#'   side effect.
#' @export
#'
#' @examples
#' df <- data.frame(a = c(1, NA, 3), b = c(4, 5, NA))
#' tr_check_missing(df)
tr_check_missing <- function(data) {

  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  # summary table
  n_total <- nrow(data)

  summary_tbl <- data.frame(
    column = names(data),
    n_missing = sapply(data, function(x) sum(is.na(x))),
    pct_missing = round(sapply(data, function(x) sum(is.na(x))) / n_total * 100, 1),
    row.names = NULL
  )

  # show worst offenders show first
  summary_tbl <- summary_tbl[order(-summary_tbl$pct_missing), ]
  summary_tbl <- tibble::as_tibble(summary_tbl)

  # message a friendly console summary (can be suppressed with suppressMessages())
  total_missing_cols <- sum(summary_tbl$n_missing > 0)
  message("Missing data summary:")
  message("- ", total_missing_cols, " of ", ncol(data), " columns have missing values")
  message("- ", n_total, " total rows")
  message(paste(utils::capture.output(print(summary_tbl)), collapse = "\n"))

  #visual plot (wraps naniar)
  plot <- naniar::vis_miss(data)
  print(plot)

  invisible(summary_tbl)
}
