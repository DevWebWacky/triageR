#' Explain a clinical prediction model
#'
#' Generates variable importance or prediction explanations for a fitted
#' `triageR_model`, using the `DALEX` framework under the hood.
#'
#' @param model A fitted `triageR_model` object from `tr_fit()`.
#' @param method Character. One of `"permutation"` (global variable
#'   importance) or `"shap"` (SHAP values for a single prediction).
#' @param newdata Optional data frame to explain predictions on. If `NULL`,
#'   uses the training data.
#' @param observation Integer. Row index of the observation to explain,
#'   only used when `method = "shap"`. Defaults to 1.
#'
#' @return A `triageR_explanation` object (list) containing the explanation
#'   result and a plot.
#' @export
#'
#' @examples
#' \dontrun{
#' tr_explain(model, method = "permutation")
#' tr_explain(model, method = "shap", observation = 3)
#' }
tr_explain <- function(model, method = c("permutation", "shap"),
                       newdata = NULL, observation = 1) {

  method <- match.arg(method)

  if (!inherits(model, "triageR_model")) {
    stop("`model` must be a triageR_model object from tr_fit().", call. = FALSE)
  }

  if (is.null(newdata)) {
    newdata <- model$training_data
  }

  outcome <- model$outcome

  #DALEX explainer that wraps any parsnip/workflow model
  # into a common format DALEX knows how to interrogate
  predict_fn <- function(model_obj, newdata) {
    stats::predict(model_obj, new_data = newdata, type = "prob")[[2]]
  }

  explainer <- DALEX::explain(
    model = model$workflow,
    data = newdata[, model$predictors, drop = FALSE],
    y = as.numeric(as.factor(newdata[[outcome]])) - 1,
    predict_function = predict_fn,
    label = model$engine,
    verbose = FALSE
  )

  if (method == "permutation") {

    #global variable importance via permutation
    result <- DALEX::model_parts(explainer)
    plot_obj <- plot(result)

    out <- list(
      method = "permutation",
      result = result,
      plot = plot_obj
    )

  } else if (method == "shap") {

    #SHAP explanation for a single observation
    if (observation > nrow(newdata)) {
      stop("`observation` (", observation, ") exceeds number of rows in data (",
           nrow(newdata), ").", call. = FALSE)
    }

    single_obs <- newdata[observation, model$predictors, drop = FALSE]
    result <- DALEX::predict_parts(explainer, new_observation = single_obs, type = "shap")
    plot_obj <- plot(result)

    out <- list(
      method = "shap",
      observation = observation,
      result = result,
      plot = plot_obj
    )
  }

  class(out) <- "triageR_explanation"
  print(out$plot)
  invisible(out)
}
