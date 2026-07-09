#' Load and standardize a clinical dataset
#'
#' Reads a flat clinical dataset (CSV or data frame) and returns it as a
#' standardized `triageR` object with basic structure checks. This is the
#' entry point for most triageR workflows.
#'
#' @param data A file path to a CSV, or an existing data frame.
#' @param id_col Character. Name of the column identifying unique patients.
#'   Defaults to `"id"`.
#'
#' @return A tibble of class `triageR_data`, with basic metadata attached.
#' @export
#'
#' @examples
#' df <- data.frame(
#'   id = 1:5,
#'   age = c(45, 62, 38, 71, 55),
#'   sex = c("F", "M", "F", "M", "F")
#' )
#' tr_load_clinical(df, id_col = "id")
tr_load_clinical <- function(data, id_col = "id") {

  # check out if input is a file path or already a data frame
  if (is.character(data)) {
    if (!file.exists(data)) {
      stop("File not found: ", data, call. = FALSE)
    }
    df <- utils::read.csv(data, stringsAsFactors = FALSE)
  } else if (is.data.frame(data)) {
    df <- data
  } else {
    stop("`data` must be a file path (character) or a data frame.", call. = FALSE)
  }

  # check the id column exists
  if (!id_col %in% names(df)) {
    stop("Column '", id_col, "' not found in the data. ",
         "Set `id_col` to the correct patient identifier column.", call. = FALSE)
  }

  # check for duplicate patient IDs to minimise error
  n_dupes <- sum(duplicated(df[[id_col]]))
  if (n_dupes > 0) {
    warning(n_dupes, " duplicated value(s) found in id column '", id_col, "'.",
            call. = FALSE)
  }

  # convert to tibble and tag with our custom class
  df <- tibble::as_tibble(df)
  class(df) <- c("triageR_data", class(df))

  # Step 5: attach some useful metadata as attributes
  attr(df, "id_col") <- id_col
  attr(df, "n_patients") <- length(unique(df[[id_col]]))
  attr(df, "loaded_at") <- Sys.time()

  df
}
