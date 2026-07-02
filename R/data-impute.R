#' Impute missing values in a clinical dataset
#'
#' Fills in missing values using either multiple imputation (`mice`) or
#' a random-forest based approach (`missForest`). The method must be
#' chosen explicitly — this function does not guess for you.
#'
#' @param data A data frame with missing values, typically the output of
#'   `tr_load_clinical()`.
#' @param method Character. Either `"mice"` (default) or `"missForest"`.
#' @param m Integer. Number of multiple imputations to run if `method = "mice"`.
#'   Defaults to 5. Ignored for `"missForest"`.
#' @param seed Integer. Random seed for reproducibility. Defaults to 123.
#'
#' @return A completed data frame with missing values filled in. If
#'   `method = "mice"`, the first completed dataset is returned, and the
#'   full `mids` object is attached as an attribute (`"mice_object"`) in
#'   case the user wants to inspect all imputations.
#' @export
#'
#' @examples
#' \dontrun{
#' completed <- tr_impute(data, method = "mice")
#' }
tr_impute <- function(data, method = c("mice", "missForest"), m = 5, seed = 123) {

  method <- match.arg(method)

  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  if (sum(is.na(data)) == 0) {
    message("No missing values detected — returning data unchanged.")
    return(data)
  }

  set.seed(seed)

  if (method == "mice") {

    # Step 1: run multiple imputation
    mice_obj <- mice::mice(data, m = m, printFlag = FALSE, seed = seed)

    # Step 2: take the first completed dataset as the "working" version
    completed <- mice::complete(mice_obj, 1)
    completed <- tibble::as_tibble(completed)

    # Step 3: attach the full mice object for anyone who wants all m datasets
    attr(completed, "mice_object") <- mice_obj
    attr(completed, "imputation_method") <- "mice"

  } else if (method == "missForest") {

    # missForest needs to be installed separately - check first
    if (!requireNamespace("missForest", quietly = TRUE)) {
      stop("Package 'missForest' is required for method = 'missForest'. ",
           "Install it with install.packages('missForest').", call. = FALSE)
    }

    result <- missForest::missForest(as.data.frame(data))
    completed <- tibble::as_tibble(result$ximp)

    attr(completed, "imputation_method") <- "missForest"
    attr(completed, "missForest_OOB_error") <- result$OOBerror
  }

  message("Imputation complete using method: ", method)
  completed
}
