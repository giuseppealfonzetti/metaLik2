test_that("metaLik2 fits binomial_normal model", {
  set.seed(1)
  K <- 6
  n1 <- rep(50, K)
  n2 <- rep(50, K)
  mu <- rnorm(K, 0, 0.3)
  delta <- 0.5
  tau <- 0.2
  di <- rnorm(K, delta, tau)
  df <- data.frame(
    event1 = rbinom(K, n1, plogis(mu + di / 2)),
    n1 = n1,
    event2 = rbinom(K, n2, plogis(mu - di / 2)),
    n2 = n2
  )
  fit <- metaLik2("binomial_normal", metaLik2_set_data(df, "binary"), nodes = 15)
  expect_s3_class(fit, "metaLik2")
  expect_true(all(c("delta", "log_tau2") %in% names(coef(fit))))
  expect_true(is.finite(fit$logLik))
  expect_equal(unname(coef(fit)["delta"]), delta, tolerance = 0.3)
})

test_that("binomial_normal rejects FORMULA and continuous data", {
  df <- data.frame(event1 = 2, n1 = 10, event2 = 1, n2 = 10)
  d <- metaLik2_set_data(df, "binary")
  expect_error(metaLik2("binomial_normal", d, FORMULA = ~1), "FORMULA applies")
  cont <- metaLik2_set_data(data.frame(y = 0.1, sigma2 = 0.04), "continuous")
  expect_error(metaLik2("binomial_normal", cont), "needs binary data")
})
