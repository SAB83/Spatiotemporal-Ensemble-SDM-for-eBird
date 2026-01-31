#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(data.table)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species

raw_dir <- file.path(cfg$paths$raw_ebird_dir, sp, "Origin")
out_dir <- file.path(cfg$paths$processed_dir, sp, "Origin")
ensure_dir(out_dir)

# TODO: set your file lists here (or build from directory listing)
sampling_files <- character(0)
non_sampling_files <- character(0)

read_fixed_data <- function(filepath) {
  if (!file.exists(filepath)) {
    warning(paste("File not found:", filepath))
    return(NULL)
  }
  fread(filepath, quote = "", sep = "\t", fill = TRUE, na.strings = c("", "NA"))
}

sampling_list <- Filter(Negate(is.null), lapply(sampling_files, read_fixed_data))
nonsamp_list  <- Filter(Negate(is.null), lapply(non_sampling_files, read_fixed_data))
stopifnot(length(sampling_list) > 0, length(nonsamp_list) > 0)

std_samp <- Reduce(intersect, lapply(sampling_list, names))
std_non  <- Reduce(intersect, lapply(nonsamp_list,  names))
sampling_list <- lapply(sampling_list, function(df) df[, ..std_samp])
nonsamp_list  <- lapply(nonsamp_list,  function(df) df[, ..std_non])

sampling_data <- rbindlist(sampling_list, use.names = TRUE, fill = TRUE)
nonsamp_data  <- rbindlist(nonsamp_list,  use.names = TRUE, fill = TRUE)

out_sampling <- file.path(out_dir, "combined_sampling_data.txt")
out_ebd      <- file.path(out_dir, "combined_non_sampling_data.txt")

fwrite(sampling_data, out_sampling, sep="\t", quote=FALSE)
fwrite(nonsamp_data,  out_ebd,      sep="\t", quote=FALSE)

message("Wrote: ", out_sampling)
message("Wrote: ", out_ebd)
