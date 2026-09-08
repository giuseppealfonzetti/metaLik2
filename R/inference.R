#' Confidence intervals on a scalar function of interest by the r* statistic
#'
#' Interval inference via [likelihoodAsy::rstar.ci()]. It returns a
#' `rstarci` object storing the `r` and Skovgaard's `r*` curves.
#'
#' @param FIT A `metaLik2` fit from [metaLik2()].
#' @param PARAM Scalar parameter of interest, given as a coefficient index or name.
#' @param RONLY Skip the Skovgaard `r*` simulation and return the first-order `r`
#'   only? Defaults to `FALSE`.
#' @param R The number of Monte Carlo replicates used for computing the r* statistic. A positive integer, default is 1000.
#' @param SEED Optional seed for simulation rng.
#' @param VERBOSE Print [likelihoodAsy::rstar.ci()]'s progress? Defaults to `FALSE`.
#' @param ... Passed to [likelihoodAsy::rstar.ci()].
#'
#' @return An object of class `rstarci`. Use with `print()`, `summary()` and `plot()`.
#'
#' @export
rstar_ci <- function(FIT, ...) UseMethod("rstar_ci")

#' @rdname rstar_ci
#' @export
rstar_ci.metaLik2 <- function(
  FIT,
  PARAM = 1,
  RONLY = FALSE,
  R = 1000,
  SEED = 123,
  VERBOSE = FALSE,
  ...
) {
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
      ronly = RONLY,
      ...
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


#' Hypothesis testing on a scalar fixed-effect component in meta-analysis amodels
#'
#' Tests a hypothesis on one scalar parameter of interest using the `r` or Skovgaard's `r*`, via
#' [likelihoodAsy::rstar()].
#'
#' @param FIT A `metaLik2` fit from [metaLik2()].
#' @param PARAM Scalar parameter of interest, given as a coefficient index or name.
#' @param VALUE  A single number indicating the value of the fixed-effect parameter under the null hypothesis. Default is 0.
#' @param ALTERNATIVE Test direction: `"two.sided"`, `"less"` or `"greater"`.
#' @param RONLY Skip the Skovgaard `r*` simulation and return the first-order
#'   signed profile LR `r` only? Defaults to `FALSE`.
#' @param R The number of Monte Carlo replicates used for computing the r* statistic. A positive integer, default is 1000.
#' @param SEED Optional seed for simulation rng.
#' @param VERBOSE Print [likelihoodAsy::rstar()]'s trace? Defaults to `FALSE`.
#'
#' @param ... Passed to [likelihoodAsy::rstar()].
#'
#' @return An object of class `metaLik2.test`.
#'
#' @examples
#' data(vaccine, package = "metaLik")
#' d <- metaLik2_set_data(vaccine, "continuous")
#' rstar_test(metaLik2("normal_normal", d, FORMULA = ~ latitude), PARAM = "latitude")
#' @importFrom stats pnorm
#' @export
rstar_test <- function(FIT, ...) UseMethod("rstar_test")

#' @rdname rstar_test
#' @export
rstar_test.metaLik2 <- function(
  FIT,
  PARAM = 1,
  VALUE = 0,
  ALTERNATIVE = c("two.sided", "less", "greater"),
  RONLY = FALSE,
  R = 1000,
  SEED = 123,
  VERBOSE = FALSE,
  ...
) {
  ALTERNATIVE <- match.arg(ALTERNATIVE)
  pval <- function(stat) {
    switch(
      ALTERNATIVE,
      two.sided = 2 * pnorm(-abs(stat)),
      less = pnorm(stat),
      greater = pnorm(stat, lower.tail = FALSE)
    )
  }
  model <- FIT$model
  out <- likelihoodAsy::rstar(
    data = FIT$data,
    thetainit = FIT$theta.hat,
    floglik = model$loglik,
    fscore = model$score,
    fpsi = model$fpsi_builder(PARAM, FIT$data),
    psival = VALUE,
    datagen = model$datagen,
    R = R,
    seed = SEED,
    ronly = RONLY,
    trace = VERBOSE,
    ...
  )
  res <- list(
    param = if (is.numeric(PARAM)) names(FIT$coefficients)[PARAM] else PARAM,
    value = VALUE,
    alternative = ALTERNATIVE,
    estimate = out$psi.hat,
    se = out$se.psi.hat,
    r = out$r,
    p.r = pval(out$r),
    rstar = if (RONLY) NA else out$rs,
    p.rstar = if (RONLY) NA else pval(out$rs),
    NP = if (RONLY) NA else out$NP,
    INF = if (RONLY) NA else out$INF,
    theta.hat = out$theta.hat
  )
  structure(res, class = "metaLik2.test")
}

#' @param x A `metaLik2.test` object.
#' @param ... Ignored.
#' @rdname rstar_test
#' @export
print.metaLik2.test <- function(x, ...) {
  digits <- max(3, getOption("digits") - 3)
  cat(
    "\nSigned profile log-likelihood ratio test for parameter ",
    x$param,
    "\n",
    sep = ""
  )
  cat("\nFirst-order statistic")
  cat(
    "\nr:",
    formatC(x$r, digits),
    ", p-value:",
    formatC(x$p.r, digits),
    sep = ""
  )
  if (!is.na(x$rstar)) {
    cat("\nSkovgaard's statistic")
    cat(
      "\nrSkov:",
      formatC(x$rstar, digits),
      ", p-value:",
      formatC(x$p.rstar, digits),
      sep = ""
    )
  }
  if (x$alternative == "two.sided") {
    cat(
      "\nalternative hypothesis: parameter is different from ",
      round(x$value, digits),
      "\n",
      sep = ""
    )
  } else {
    cat(
      "\nalternative hypothesis: parameter is ",
      x$alternative,
      " than ",
      round(x$value, digits),
      "\n",
      sep = ""
    )
  }
  invisible(x)
}
