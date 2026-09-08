test_that("set_model builds object with defaults", {
  f <- function(...) NULL
  m <- set_model("nn", "continuous", f, f, f, f, f)
  expect_s3_class(m, "metaLik2_model")
  expect_equal(m$name, "nn")
  expect_equal(m$data_type, "continuous")
  expect_null(m$score)
  expect_null(m$het)
})

test_that("set_model rejects invalid input", {
  f <- function(...) NULL
  expect_error(set_model(1, "continuous", f, f, f, f, f))
  expect_error(set_model(c("a", "b"), "continuous", f, f, f, f, f))
  expect_error(set_model("nn", "count", f, f, f, f, f))
  expect_error(set_model("nn", "continuous", "notfun", f, f, f, f))
  expect_error(set_model("nn", "continuous", f, f, f, f, f, SCORE = 1))
})

test_that("print.metaLik2_model shows name and type", {
  f <- function(...) NULL
  m <- set_model("nn", "binary", f, f, f, f, f)
  expect_output(print(m), "nn.*binary")
  expect_invisible(print(m))
})
