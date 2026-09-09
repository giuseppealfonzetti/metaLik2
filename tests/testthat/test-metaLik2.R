test_that("metaLik2 fits normal_normal model", {
  set.seed(1)
  df <- data.frame(y = rnorm(30, 0.5, 0.3), sigma2 = rep(0.05, 30))
  fit <- metaLik2("normal_normal", set_data(df, "continuous"))
  expect_s3_class(fit, "metaLik2")
  expect_equal(names(coef(fit)), c("(Intercept)", "log_tau2"))
  expect_equal(dim(fit$vcov), c(2, 2))
  expect_true(is.finite(fit$logLik))
  expect_equal(unname(coef(fit)[1]), mean(df$y), tolerance = 0.05)
})

test_that("metaLik2 fits meta-regression via FORMULA", {
  set.seed(2)
  x <- runif(30)
  df <- data.frame(
    y = 0.2 + 0.5 * x + rnorm(30, 0, 0.2),
    sigma2 = rep(0.04, 30),
    x = x
  )
  fit <- metaLik2("normal_normal", set_data(df, "continuous"), FORMULA = ~x)
  expect_equal(names(coef(fit)), c("(Intercept)", "x", "log_tau2"))
  expect_equal(ncol(fit$data$X), 2)
})

test_that("metaLik2 rejects bad data or mismatched type", {
  df <- data.frame(y = rnorm(10), sigma2 = rep(0.1, 10))
  expect_error(metaLik2("normal_normal", df), "metaLik2_data")
  bin <- set_data(
    data.frame(event1 = 2, n1 = 10, event2 = 1, n2 = 10),
    "binary"
  )
  expect_error(metaLik2("normal_normal", bin), "needs continuous data")
})

test_that("metaLik2 fits binomial_normal model", {
  set.seed(1)
  K <- 5
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
  fit <- metaLik2("binomial_normal", set_data(df, "binary"), nodes = 15)
  expect_s3_class(fit, "metaLik2")
  expect_true(all(c("delta", "log_tau2") %in% names(coef(fit))))
  expect_true(is.finite(fit$logLik))
})
