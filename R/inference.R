#' Confidence intervals on a scalar function of interest by the r* statistic
#'
#' Interval inference via [likelihoodAsy::rstar.ci()]. It returns a
#' `rstarci` object storing the `r` and `r*` curves.
#'
#' @param FIT A `metaLik2` fit from [metaLik2()].
#' @param PARAM Scalar of interest: a coefficient index or name.
#' @param ORDER `"second"` (default) profiles both `r` and `r*`; `"first"`
#'   profiles the first-order `r` only.
#' @param R Number of simulated datasets for Skovgaard's covariances.
#' @param SEED Optional seed for simulation rng.
#' @param VERBOSE Print [likelihoodAsy::rstar.ci()]'s progress? Defaults to `FALSE`.
#' @param ... Passed to methods.
#'
#' @return An object of class `rstarci`. Use with [print()], [summary()] and [plot()].
#'
#' @export
rstarci <- function(FIT, ...) UseMethod("rstarci")

#' @rdname rstarci
#' @export
rstarci.metaLik2 <- function(
  FIT,
  PARAM = 1,
  ORDER = c("second", "first"),
  R = 1000,
  SEED = NULL,
  VERBOSE = FALSE,
  ...
) {
  ORDER <- match.arg(ORDER)
  model <- FIT$model
  run <- function() {
    likelihoodAsy::rstar.ci(
      data = FIT$data,
      thetainit = FIT$theta.hat,
      floglik = model$loglik,
      fscore = model$score,
      fpsi = model$fpsi_builder(PARAM, FIT$data),
      datagen = model$datagen,
      R = R,
      seed = SEED,
      ronly = ORDER == "first"
    )
  }
  if (VERBOSE) {
    pr <- run()
  } else {
    utils::capture.output(pr <- run())
  }
  pr$param <- PARAM
  pr
}
