#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(sf); library(terra); library(ranger)
  library(rsample); library(parallel); library(units); library(rnaturalearth)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species

message("Scaffold: paste your current-range ensemble RF SDM script here (the version that makes *_binary_range_YYYY.tif).")
