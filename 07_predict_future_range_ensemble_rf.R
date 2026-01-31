#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(sf); library(terra); library(ranger)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species

message("Scaffold: paste your future/6-years ensemble RF projection script here (the version that makes *_future_YYYY_6years.tif).")
