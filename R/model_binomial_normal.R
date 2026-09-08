model_binomial_normal <- function(nodes = 30, maxit = 25, tol = 1e-5) {
  gh <- statmod::gauss.quad(nodes, "hermite")
  metaLik2_set_model(
    NAME = "binomial_normal",
    DATA_TYPE = "binary",
    LOGLIK = function(theta, data) {
      K <- length(data$y1)
      mu <- theta[1:K]
      delta <- theta[K + 1]
      tau2 <- exp(theta[K + 2])
      y1 <- data$y1
      n1 <- data$n1
      y2 <- data$y2
      n2 <- data$n2
      d <- qlogis((y1 + 0.5) / (n1 + 1)) - qlogis((y2 + 0.5) / (n2 + 1))
      for (it in seq_len(maxit)) {
        p1 <- plogis(mu + d / 2)
        p2 <- plogis(mu - d / 2)
        g <- 0.5 * (y1 - n1 * p1) - 0.5 * (y2 - n2 * p2) - (d - delta) / tau2
        h <- -0.25 * (n1 * p1 * (1 - p1) + n2 * p2 * (1 - p2)) - 1 / tau2
        step <- g / h
        d <- d - step
        if (max(abs(step)) < tol) break
      }
      p1 <- plogis(mu + d / 2)
      p2 <- plogis(mu - d / 2)
      sig <- 1 /
        sqrt(0.25 * (n1 * p1 * (1 - p1) + n2 * p2 * (1 - p2)) + 1 / tau2)
      z <- gh$nodes
      w <- gh$weights
      dk <- d + sqrt(2) * outer(sig, z)
      ll <- dbinom(y1, n1, plogis(mu + dk / 2), log = TRUE) +
        dbinom(y2, n2, plogis(mu - dk / 2), log = TRUE) +
        dnorm(dk, delta, sqrt(tau2), log = TRUE)
      term <- sweep(ll, 2, log(w) + z^2, "+")
      logL <- log(sqrt(2) * sig) +
        apply(term, 1, function(a) {
          m <- max(a)
          m + log(sum(exp(a - m)))
        })
      sum(logL)
    },
    SCORE = NULL,
    DATAGEN = function(theta, data) {
      K <- length(data$y1)
      mu <- theta[1:K]
      delta <- theta[K + 1]
      tau <- sqrt(exp(theta[K + 2]))
      di <- rnorm(K, delta, tau)
      data$y1 <- rbinom(K, data$n1, plogis(mu + di / 2))
      data$y2 <- rbinom(K, data$n2, plogis(mu - di / 2))
      data
    },
    THETAINIT = function(data) {
      l1 <- qlogis((data$y1 + 0.5) / (data$n1 + 1))
      l2 <- qlogis((data$y2 + 0.5) / (data$n2 + 1))
      dor <- l1 - l2
      c((l1 + l2) / 2, mean(dor), log(max(1e-3, var(dor))))
    },
    PAR_NAMES = function(data) {
      K <- length(data$y1)
      c(paste0("mu", 1:K), "delta", "log_tau2")
    },
    HET = function(coef) c(`tau^2` = exp(coef[["log_tau2"]])),
    FPSI_BUILDER = function(param, data) {
      K <- length(data$y1)
      if (identical(param, "delta")) {
        return(function(theta) theta[K + 1])
      }
      if (identical(param, "tau2")) {
        return(function(theta) exp(theta[K + 2]))
      }
      force(param)
      function(theta) theta[param]
    }
  )
}
