#' Launch the triageR Shiny app
#'
#' Opens an interactive Shiny application for building, validating, and
#' reporting clinical prediction models without writing R code directly.
#' Supports data upload, model fitting across multiple engines, validation,
#' explainability, automated pipeline review, and TRIPOD+AI report
#' generation. The AI method-recommendation feature requires a configured
#' Gemini API key (see `?tr_recommend_method`) and is optional.
#'
#' @return Does not return; launches a Shiny application.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   tr_launch_app()
#' }
tr_launch_app <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to launch the triageR app. ",
         "Install it with install.packages('shiny').", call. = FALSE)
  }
  if (!requireNamespace("bslib", quietly = TRUE)) {
    stop("Package 'bslib' is required to launch the triageR app. ",
         "Install it with install.packages('bslib').", call. = FALSE)
  }

  app_dir <- system.file("shiny-app", package = "triageR")
  if (app_dir == "") {
    stop("Could not find the triageR Shiny app. Try re-installing triageR.",
         call. = FALSE)
  }

  shiny::runApp(app_dir, display.mode = "normal")
}
