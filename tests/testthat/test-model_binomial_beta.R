test_that("metaLik2 fits binomial_beta model", {
  set.seed(1)
  K <- 15
  n1 <- n2 <- rep(80, K)
  df <- data.frame(
    event1 = rbinom(K, n1, rbeta(K, 6, 4)),
    n1 = n1,
    event2 = rbinom(K, n2, rbeta(K, 4, 6)),
    n2 = n2
  )
  fit <- metaLik2("binomial_beta", set_data(df, "binary"))
  expect_s3_class(fit, "metaLik2")
  expect_equal(names(coef(fit)), c("log_a1", "log_b1", "log_a2", "log_b2", "eta"))
  expect_true(is.finite(fit$logLik))
  expect_equal(dim(fit$vcov), c(5, 5))
})

test_that("binomial_beta rejects continuous data", {
  cont <- set_data(data.frame(y = 0.1, sigma2 = 0.04), "continuous")
  expect_error(metaLik2("binomial_beta", cont), "needs binary data")
})
