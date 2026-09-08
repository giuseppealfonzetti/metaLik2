model_normal_normal <- function() {
  set_model(
    NAME = "normal_normal",
    DATA_TYPE = "continuous",
    LOGLIK = function(theta, data) {
      p <- ncol(data$X)
      v <- data$s2 + exp(theta[p + 1])
      r <- as.numeric(data$y - data$X %*% theta[1:p])
      -0.5 * sum(log(2 * pi * v) + r^2 / v)
    },
    SCORE = function(theta, data) {
      p <- ncol(data$X)
      t2 <- exp(theta[p + 1])
      v <- data$s2 + t2
      r <- as.numeric(data$y - data$X %*% theta[1:p])
      c(as.numeric(t(data$X) %*% (r / v)), 0.5 * sum(r^2 / v^2 - 1 / v) * t2)
    },
    DATAGEN = function(theta, data) {
      p <- ncol(data$X)
      v <- data$s2 + exp(theta[p + 1])
      data$y <- as.numeric(data$X %*% theta[1:p]) +
        rnorm(length(data$y), 0, sqrt(v))
      data
    },
    THETAINIT = function(data) {
      w <- 1 / data$s2
      beta <- solve(
        crossprod(data$X, data$X * w),
        crossprod(data$X, data$y * w)
      )
      c(as.numeric(beta), log(max(1e-3, var(data$y) - mean(data$s2))))
    },
    PAR_NAMES = function(data) c(colnames(data$X), "log_tau2"),
    HET = function(coef) c(`tau^2` = exp(coef[["log_tau2"]])),
    FPSI_BUILDER = function(param, data) {
      p <- ncol(data$X)
      if (identical(param, "tau2")) {
        return(function(theta) exp(theta[p + 1]))
      }
      j <- if (is.character(param)) match(param, colnames(data$X)) else param
      force(j)
      function(theta) theta[j]
    }
  )
}
