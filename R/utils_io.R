# R/utils_io.R
# Small helpers for config + directories.

`%||%` <- function(a, b) if (!is.null(a)) a else b

read_config <- function(path = "config/config.yml") {
  if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")
  yaml::read_yaml(path)
}

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}
