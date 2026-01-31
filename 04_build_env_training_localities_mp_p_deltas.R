#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(sf); library(terra); library(units)
  library(exactextractr); library(tidyr); library(purrr)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species
mp  <- cfg$mp_year
p   <- cfg$p_year

proc_dir <- cfg$paths$processed_dir
sp_dir   <- file.path(proc_dir, sp)
ensure_dir(sp_dir)

message("Scaffold: paste your full env-locality builder here (climate mp/p + elevation + landcover metrics + deltas).")
