model_binomial_beta <- function() {
  extract_par <- function(theta) {
    a1 <- exp(theta[1])
    b1 <- exp(theta[2])
    a2 <- exp(theta[3])
    b2 <- exp(theta[4])
    L <- plogis(-theta[5])
    w <- (a1 + b1) *
      (a2 + b2) *
      ((1 - L) / max(a1 * b2, a2 * b1) - L / max(a1 * a2, b1 * b2))
    list(
      a1 = a1,
      b1 = b1,
      a2 = a2,
      b2 = b2,
      w = w,
      mu1 = a1 / (a1 + b1),
      mu2 = a2 / (a2 + b2)
    )
  }
  set_model(
    NAME = "binomial_beta",
    DATA_TYPE = "binary",
    LOGLIK = function(theta, data) {
      pp <- extract_par(theta)
      e1 <- data$y1
      n1 <- data$n1
      e2 <- data$y2
      n2 <- data$n2
      lm1 <- lchoose(n1, e1) +
        lbeta(pp$a1 + e1, pp$b1 + n1 - e1) -
        lbeta(pp$a1, pp$b1)
      lm2 <- lchoose(n2, e2) +
        lbeta(pp$a2 + e2, pp$b2 + n2 - e2) -
        lbeta(pp$a2, pp$b2)
      c1 <- (e1 - n1 * pp$mu1) / (pp$a1 + pp$b1 + n1)
      c2 <- (e2 - n2 * pp$mu2) / (pp$a2 + pp$b2 + n2)
      dep <- pp$w * c1 * c2
      if (any(!is.finite(dep)) || any(dep <= -1)) {
        return(-Inf)
      }
      ll <- sum(lm1 + lm2 + log1p(dep))
      if (is.finite(ll)) ll else -Inf
    },
    SCORE = NULL,
    DATAGEN = function(theta, data) {
      pp <- extract_par(theta)
      K <- length(data$n1)
      bound <- 1 + abs(pp$w) * max(pp$mu1, 1 - pp$mu1) * max(pp$mu2, 1 - pp$mu2)
      p1 <- numeric(K)
      p2 <- numeric(K)
      for (k in 1:K) {
        repeat {
          u1 <- rbeta(1, pp$a1, pp$b1)
          u2 <- rbeta(1, pp$a2, pp$b2)
          if (runif(1) < (1 + pp$w * (u1 - pp$mu1) * (u2 - pp$mu2)) / bound) {
            p1[k] <- u1
            p2[k] <- u2
            break
          }
        }
      }
      data$y1 <- rbinom(K, data$n1, p1)
      data$y2 <- rbinom(K, data$n2, p2)
      data
    },
    THETAINIT = function(data) {
      mom <- function(p) {
        m <- mean(p)
        v <- max(1e-4, var(p))
        s <- max(0.5, m * (1 - m) / v - 1)
        c(log(max(1e-3, m * s)), log(max(1e-3, (1 - m) * s)))
      }
      c(mom(data$y1 / data$n1), mom(data$y2 / data$n2), 0)
    },
    PAR_NAMES = function(data) c("log_a1", "log_b1", "log_a2", "log_b2", "eta"),
    FPSI_BUILDER = function(param, data) {
      if (identical(param, "delta")) {
        return(function(theta) theta[1] - theta[2] - theta[3] + theta[4])
      }
      force(param)
      function(theta) theta[param]
    }
  )
}
