#' Define a metaLik model
#'
#' @details A metaLik model object supplies the functions consumed by [metaLik2()]:
#'   `loglik(theta, data)` and optional `score(theta, data)`; a
#'   `datagen(theta, data)` that simulates a dataset under the model;
#'   `thetainit(data)` giving starting values; `par_names(data)` naming the
#'   parameter vector; `fpsi_builder(param, data)` returning the scalar interest
#'   function; and optional `het(coef)` for natural-scale heterogeneity. See
#'   `model_normal_normal` for a complete example.
#'
#' @param NAME Short model name.
#' @param DATA_TYPE Data type consumed: `"continuous"` or `"binary"`.
#' @param LOGLIK,DATAGEN,THETAINIT,PAR_NAMES,FPSI_BUILDER Required model
#'   functions.
#' @param SCORE Optional analytic score, or `NULL` for a numeric gradient.
#' @param HET Optional coefficients-to-heterogeneity function (e.g. `tau^2`),
#'   or `NULL`.
#'
#' @return An object of class `metaLik2_model`.
#' @export
set_model <- function(
  NAME,
  DATA_TYPE,
  LOGLIK,
  DATAGEN,
  THETAINIT,
  PAR_NAMES,
  FPSI_BUILDER,
  SCORE = NULL,
  HET = NULL
) {
  stopifnot(
    is.character(NAME),
    length(NAME) == 1L,
    DATA_TYPE %in% c("continuous", "binary"),
    is.function(LOGLIK),
    is.function(DATAGEN),
    is.function(THETAINIT),
    is.function(PAR_NAMES),
    is.function(FPSI_BUILDER),
    is.null(SCORE) || is.function(SCORE),
    is.null(HET) || is.function(HET)
  )
  structure(
    list(
      name = NAME,
      data_type = DATA_TYPE,
      loglik = LOGLIK,
      score = SCORE,
      datagen = DATAGEN,
      thetainit = THETAINIT,
      par_names = PAR_NAMES,
      het = HET,
      fpsi_builder = FPSI_BUILDER
    ),
    class = "metaLik2_model"
  )
}

#' @param x A `metaLik2_model` object.
#' @param ... Ignored.
#' @rdname set_model
#' @export
print.metaLik2_model <- function(x, ...) {
  cat(sprintf("metaLik model: %s (%s)\n", x$name, x$data_type))
  invisible(x)
}
