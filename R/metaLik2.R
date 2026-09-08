#' Fit a meta-analysis model
#'
#' @param MODEL Model name: `"normal_normal"` (continuous outcomes),
#'   `"binomial_normal"` or `"binomial_beta"` (binary outcomes). The data
#'   `type` must match the chosen model.
#' @param DATA A `metaLik_data` object from [metaLik2_set_data()].
#' @param FORMULA One-sided formula of study-level covariates for meta-regression
#'   (continuous outcomes only). Defaults to `~ 1`.
#' @param ... Passed to the model constructor.
#' @param object,x A `metaLik2` fit, for the accessor and print methods.
#'
#' @return An object of class `metaLik2`.
#'
#' @importFrom stats nlminb optimHess setNames rnorm var model.matrix dbinom dnorm plogis qlogis rbinom rbeta runif
#' @export
metaLik2 <- function(
  MODEL = c("normal_normal", "binomial_normal", "binomial_beta"),
  DATA,
  FORMULA = ~1,
  ...
) {
  MODEL <- match.arg(MODEL)
  if (!inherits(DATA, "metaLik_data")) {
    stop("data must be a metaLik_data object")
  }
  mod <- switch(
    MODEL,
    normal_normal = model_normal_normal(...),
    binomial_normal = model_binomial_normal(...),
    binomial_beta = model_binomial_beta(...)
  )
  if (DATA$type != mod$data_type) {
    stop(sprintf(
      "model '%s' needs %s data, got '%s'",
      MODEL,
      mod$data_type,
      DATA$type
    ))
  }
  if (DATA$type == "continuous") {
    DATA$X <- model.matrix(FORMULA, DATA$frame)
    stopifnot(nrow(DATA$X) == length(DATA$y))
  } else if (!missing(FORMULA)) {
    stop("FORMULA applies to continuous outcomes only")
  }
  nll <- function(th) -mod$loglik(th, DATA)
  gr <- if (!is.null(mod$score)) function(th) -mod$score(th, DATA) else NULL
  opt <- nlminb(mod$thetainit(DATA), nll, gradient = gr)
  nm <- mod$par_names(DATA)
  v <- solve(optimHess(opt$par, nll, gr))
  dimnames(v) <- list(nm, nm)
  structure(
    list(
      model = mod,
      data = DATA,
      coefficients = setNames(opt$par, nm),
      vcov = v,
      logLik = -opt$objective,
      theta.hat = opt$par
    ),
    class = "metaLik2"
  )
}

#' @rdname metaLik2
#' @export
coef.metaLik2 <- function(object, ...) object$coefficients

#' @rdname metaLik2
#' @export
vcov.metaLik2 <- function(object, ...) object$vcov

#' @rdname metaLik2
#' @export
logLik.metaLik2 <- function(object, ...) {
  df <- length(object$coefficients)
  if (!is.null(object$model$het)) {
    df <- df + (object$model$het(object$coefficients) > 0)
  }
  structure(object$logLik, df = df, class = "logLik")
}
#' @rdname metaLik2
#' @export
print.metaLik2 <- function(x, ...) {
  cat("metaLik2 fit:", x$model$name, "\n\n")
  print.default(format(x$coefficients), print.gap = 2, quote = FALSE)
  if (!is.null(x$model$het)) {
    h <- x$model$het(x$coefficients)
    cat(
      "\nHeterogeneity: ",
      paste(names(h), "=", format(h, digits = 4), collapse = "  "),
      "\n"
    )
  }
  cat("\nLog-likelihood:", format(x$logLik, digits = 4), "\n")
  invisible(x)
}
