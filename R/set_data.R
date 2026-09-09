#' Set data column names
#'
#' Automatic dispatch used in [set_data()] to fill the `COLS` header names vector.
#'
#' @param TYPE Outcome type: `"continuous"` or `"binary"`.
#' @param COLS Optional named character vector overriding default column names
#'   by role, e.g. `c(effect = "logOR")`. Valid roles are `effect`, `variance`
#'   for `TYPE = "continuous"` and `event1`, `n1`, `event2`, `n2` for
#'   `TYPE = "binary"`.
#' @return A named character vector mapping roles to column names.
#' @examples
#' set_data_cols("continuous")
#' set_data_cols("binary", c(event1 = "tpos", n1 = "trials"))
#' @export
set_data_cols <- function(TYPE = c("continuous", "binary"), COLS = NULL) {
  TYPE <- match.arg(TYPE)
  cols <- switch(
    TYPE,
    continuous = c(effect = "y", variance = "sigma2"),
    binary = c(event1 = "event1", n1 = "n1", event2 = "event2", n2 = "n2")
  )
  stopifnot(is.null(COLS) || all(names(COLS) %in% names(cols)))
  cols[names(COLS)] <- COLS
  cols
}

#' Set data for meta-analysis
#'
#' @param DATA A data frame of study-level columns.
#' @param TYPE Outcome type: `"continuous"` for study-level effect estimate; `"binary"` for a study-specific 2x2 table of event counts.
#' @param COLS Optional named character vector overriding the default column
#'   names from [set_data_cols()], e.g. `c(effect = "logOR")`. Valid roles are
#'   `effect`, `variance` for `TYPE = "continuous"` and `event1`, `n1`,
#'   `event2`, `n2` for `TYPE = "binary"`.
#'
#' @return An object of class `metaLik2_data` to pass as the
#'   `data` argument of [metaLik2()].
#'
#' @export
set_data <- function(
  DATA,
  TYPE = c("continuous", "binary"),
  COLS = NULL
) {
  TYPE <- match.arg(TYPE)
  stopifnot(is.data.frame(DATA))
  cols <- set_data_cols(TYPE, COLS)
  miss <- setdiff(cols, names(DATA))
  if (length(miss)) {
    stop("columns not found in DATA: ", paste(miss, collapse = ", "))
  }
  if (TYPE == "continuous") {
    y <- as.numeric(DATA[[cols[["effect"]]]])
    s2 <- as.numeric(DATA[[cols[["variance"]]]])
    stopifnot(length(s2) == length(y), all(s2 > 0))
    structure(
      list(type = "continuous", y = y, s2 = s2, frame = DATA),
      class = "metaLik2_data"
    )
  } else {
    e1 <- DATA[[cols[["event1"]]]]
    m1 <- DATA[[cols[["n1"]]]]
    e2 <- DATA[[cols[["event2"]]]]
    m2 <- DATA[[cols[["n2"]]]]
    stopifnot(
      length(e1) == length(m1),
      length(e2) == length(m2),
      length(e1) == length(e2),
      all(m1 > 0),
      all(m2 > 0),
      all(e1 >= 0 & e1 <= m1),
      all(e2 >= 0 & e2 <= m2)
    )
    structure(
      list(type = "binary", y1 = e1, n1 = m1, y2 = e2, n2 = m2),
      class = "metaLik2_data"
    )
  }
}


#' @export
print.metaLik2_data <- function(x, ...) {
  K <- if (x$type == "continuous") length(x$y) else length(x$y1)
  cat(sprintf("<metaLik2_data>: %s, %d studies\n", x$type, K))
  invisible(x)
}
