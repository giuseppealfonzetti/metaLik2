#' @exportS3Method
print.metaLik_data <- function(x, ...) {
  K <- if (x$type == "continuous") length(x$y) else length(x$y1)
  cat(sprintf("metaLik_data: %s, %d studies\n", x$type, K))
  invisible(x)
}

#' @exportS3Method
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

#' @exportS3Method
coef.metaLik2 <- function(object, ...) object$coefficients

#' @exportS3Method
vcov.metaLik2 <- function(object, ...) object$vcov

#' @exportS3Method
logLik.metaLik2 <- function(object, ...) object$logLik
