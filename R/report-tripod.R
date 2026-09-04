#' Generate a TRIPOD+AI-aligned clinical model report
#'
#' Renders a reproducible report summarizing model fit, validation,
#' sensitivity analysis, and pipeline review, aligned with TRIPOD+AI
#' reporting guidance. Supports both binary classification and survival
#' models. This is a drafting aid, not a certified compliance tool.
#'
#' @param model A fitted `triageR_model` or `triageR_survival_model` object.
#' @param model_type Character. Either `"classification"` (default) or
#'   `"survival"`. Must match the type of `model` supplied.
#' @param validation Optional validation object: a `triageR_validation`
#'   (from `tr_validate()`) for classification models, or a
#'   `triageR_survival_validation` (from `tr_validate_survival()`) for
#'   survival models.
#' @param review Optional `triageR_review` object from `tr_agent_review()`.
#' @param sensitivity Optional `triageR_sensitivity` object from `tr_sensitivity()`.
#'   Not currently supported for survival models.
#' @param recommendation Optional character string from `tr_recommend_method()`.
#' @param output_file Character. File path (without extension) to save the
#'   report to. Defaults to a file in `tempdir()`. Set explicitly (e.g.
#'   `file.path("my_folder", "report")`) to save elsewhere.
#' @param format Character. Either `"html"` (default) or `"docx"`.
#'
#' @return Invisibly returns the path to the rendered report file.
#' @export
#'
#' @examples
#' \dontrun{
#' tr_tripod_report(model, validation = val, review = rev,
#'   output_file = file.path(tempdir(), "report"))
#' }
tr_tripod_report <- function(model, model_type = c("classification", "survival"),
                             validation = NULL, review = NULL,
                             sensitivity = NULL, recommendation = NULL,
                             output_file = file.path(tempdir(), "triageR_report"),
                             format = c("html", "docx")) {
  model_type <- match.arg(model_type)
  format <- match.arg(format)

  if (model_type == "classification" && !inherits(model, "triageR_model")) {
    stop("`model_type = \"classification\"` requires a triageR_model object ",
         "from tr_fit().", call. = FALSE)
  }
  if (model_type == "survival" && !inherits(model, "triageR_survival_model")) {
    stop("`model_type = \"survival\"` requires a triageR_survival_model ",
         "object from tr_fit_survival().", call. = FALSE)
  }
  if (model_type == "survival" && !is.null(sensitivity)) {
    warning("Sensitivity analysis output is not currently supported in ",
            "survival reports and will be omitted.", call. = FALSE)
    sensitivity <- NULL
  }

  if (!requireNamespace("quarto", quietly = TRUE)) {
    stop("Package 'quarto' is required for tr_tripod_report(). ",
         "Install it with install.packages('quarto'), and ensure Quarto CLI ",
         "is installed on your system (https://quarto.org).", call. = FALSE)
  }
  template_path <- system.file("templates", "tripod_report.qmd", package = "triageR")
  if (template_path == "") {
    stop("Report template not found. Is triageR installed correctly?", call. = FALSE)
  }
  work_file <- file.path(tempdir(), "tripod_report.qmd")
  file.copy(template_path, work_file, overwrite = TRUE)
  output_path <- paste0(output_file, ".", format)

  data_bundle <- list(
    model = model,
    model_type = model_type,
    validation = validation,
    review = review,
    sensitivity = sensitivity,
    recommendation = recommendation
  )
  bundle_path <- file.path(tempdir(), "triageR_report_data.rds")
  saveRDS(data_bundle, bundle_path)

  quarto::quarto_render(
    input = work_file,
    output_format = format,
    output_file = basename(output_path),
    execute_params = list(bundle_path = bundle_path)
  )

  rendered_file <- file.path(tempdir(), basename(output_path))
  if (file.exists(rendered_file) &&
      normalizePath(rendered_file) != normalizePath(output_path, mustWork = FALSE)) {
    file.copy(rendered_file, output_path, overwrite = TRUE)
  }
  message("Report saved to: ", output_path)
  invisible(output_path)
}
