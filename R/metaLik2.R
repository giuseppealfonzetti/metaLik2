#' Fit a meta-analysis model
#'
#' @param MODEL Model name: `"normal_normal"` (continuous outcomes),
#'   `"binomial_normal"` or `"binomial_beta"` (binary outcomes). The data
#'   `type` must match the chosen model.
#' @param DATA A `metaLik_data` object from [set_data()].
#' @param FORMULA One-sided formula of study-level covariates for meta-regression
#'   (continuous outcomes only). Defaults to `~ 1`.
#' @param ... Passed to the model constructor.
#'
#' @return An object of class `metaLik2`.
#'
#' @importFrom stats nlminb optimHess setNames rnorm var model.matrix
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
    normal_normal = model_normal_normal()
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
