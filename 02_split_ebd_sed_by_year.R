#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(auk); library(dplyr); library(lubridate); library(readr)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species

origin_dir <- file.path(cfg$paths$processed_dir, sp, "Origin")
combined_ebd <- file.path(origin_dir, "combined_non_sampling_data.txt")
combined_sed <- file.path(origin_dir, "combined_sampling_data.txt")

obs <- read_ebd(combined_ebd) %>% mutate(observation_date = ymd(observation_date))
sed <- read_sampling(combined_sed) %>% mutate(observation_date = ymd(observation_date))

years <- sort(unique(year(obs$observation_date)))
sp_dir <- file.path(cfg$paths$processed_dir, sp)
ensure_dir(sp_dir)

for (yr in years) {
  write_delim(filter(obs, year(observation_date) == yr),
              file.path(sp_dir, paste0("ebd", yr, ".txt")), delim="\t")
  write_delim(filter(sed, year(observation_date) == yr),
              file.path(sp_dir, paste0("sed", yr, ".txt")), delim="\t")
}
message("Wrote year-sliced files for: ", paste(years, collapse=", "))
