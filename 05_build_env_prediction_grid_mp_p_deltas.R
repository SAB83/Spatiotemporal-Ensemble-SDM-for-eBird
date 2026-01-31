#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(sf); library(terra); library(units)
  library(exactextractr); library(tidyr); library(rnaturalearth); library(rnaturalearthdata)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species

proc_dir <- cfg$paths$processed_dir
sp_dir   <- file.path(proc_dir, sp)
ensure_dir(sp_dir)

message("Scaffold: paste your full env-grid builder here (3km LAEA grid + mp/p climate + elevation + landcover + deltas).")
