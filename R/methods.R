#' @exportS3Method
print.metaLik_data <- function(x, ...) {
  K <- if (x$type == "continuous") length(x$y) else length(x$y1)
  cat(sprintf("metaLik_data: %s, %d studies\n", x$type, K))
  invisible(x)
}
