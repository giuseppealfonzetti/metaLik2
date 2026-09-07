test_that("set_data_cols returns defaults per type", {
  expect_equal(
    set_data_cols("continuous"),
    c(effect = "y", variance = "sigma2")
  )
  expect_equal(
    set_data_cols("binary"),
    c(event1 = "event1", n1 = "n1", event2 = "event2", n2 = "n2")
  )
})

test_that("set_data_cols overrides named roles only", {
  expect_equal(
    set_data_cols("continuous", c(effect = "logOR")),
    c(effect = "logOR", variance = "sigma2")
  )
  expect_error(set_data_cols("continuous", c(bogus = "x")))
})

test_that("set_data builds continuous object", {
  df <- data.frame(y = c(0.1, -0.2), sigma2 = c(0.04, 0.09), age = c(50, 60))
  obj <- set_data(df, "continuous")
  expect_s3_class(obj, "metaLik_data")
  expect_equal(obj$type, "continuous")
  expect_equal(obj$y, df$y)
  expect_equal(obj$s2, df$sigma2)
  expect_equal(obj$frame$age, df$age)
})

test_that("set_data builds binary object with custom cols", {
  df <- data.frame(
    a = c(2, 3),
    n1 = c(10, 12),
    event2 = c(1, 4),
    n2 = c(11, 13)
  )
  obj <- set_data(df, "binary", COLS = c(event1 = "a"))
  expect_equal(obj$type, "binary")
  expect_equal(obj$y1, df$a)
})

test_that("set_data rejects invalid input", {
  df <- data.frame(y = 0.1, sigma2 = 0.04)
  expect_error(set_data(list(), "continuous"), "data.frame")
  expect_error(
    set_data(df[, "y", drop = FALSE], "continuous"),
    "columns not found"
  )
  expect_error(set_data(data.frame(y = 0.1, sigma2 = -1), "continuous"))
})
