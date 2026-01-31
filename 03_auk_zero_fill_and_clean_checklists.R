#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(auk); library(dplyr); library(readr); library(sf); library(lubridate)
  library(rnaturalearth); library(rnaturalearthdata); library(hms)
  source("R/utils_io.R")
})

cfg <- read_config()
sp  <- cfg$species
yr  <- cfg$p_year

proc_dir <- cfg$paths$processed_dir
sp_dir   <- file.path(proc_dir, sp)
ebd_path <- file.path(sp_dir, paste0("ebd", yr, ".txt"))
sed_path <- file.path(sp_dir, paste0("sed", yr, ".txt"))

observations1 <- read_ebd(ebd_path)
checklists    <- read_sampling(sed_path, unique = FALSE)

checklists_unique <- auk_unique(checklists, checklists_only = TRUE)
observations <- auk_rollup(observations1)

ne_countries <- ne_download(scale = 50, category = "cultural",
  type = "admin_0_countries_lakes", returnclass = "sf") %>%
  dplyr::filter(ISO_A2 %in% cfg$countries_iso2)

checklists_sf <- st_as_sf(checklists_unique, coords = c("longitude", "latitude"), crs = 4326)
checklists_sf <- st_join(checklists_sf, ne_countries, left = FALSE)

coords <- st_coordinates(checklists_sf)
checklists_sf$longitude <- coords[, "X"]
checklists_sf$latitude  <- coords[, "Y"]

checklists_filtered <- checklists_sf %>%
  st_drop_geometry() %>%
  dplyr::filter(all_species_reported)

# ID normalization
if (!"checklist_id" %in% names(observations) && "sampling_event_identifier" %in% names(observations)) {
  observations <- observations %>% mutate(checklist_id = sampling_event_identifier)
}
if (!"sampling_event_identifier" %in% names(observations) && "checklist_id" %in% names(observations)) {
  observations <- observations %>% mutate(sampling_event_identifier = checklist_id)
}
if (!"sampling_event_identifier" %in% names(checklists_filtered) && "checklist_id" %in% names(checklists_filtered)) {
  checklists_filtered <- checklists_filtered %>% mutate(sampling_event_identifier = checklist_id)
}
if (!"checklist_id" %in% names(checklists_filtered) && "sampling_event_identifier" %in% names(checklists_filtered)) {
  checklists_filtered <- checklists_filtered %>% mutate(checklist_id = sampling_event_identifier)
}

observations_filtered <- semi_join(
  observations,
  checklists_filtered %>% select(checklist_id),
  by = "checklist_id"
)

zf <- auk_zerofill(observations_filtered, checklists_filtered, collapse = TRUE)

proto_col <- if ("protocol_type" %in% names(zf)) "protocol_type" else
  if ("protocol_name" %in% names(zf)) "protocol_name" else stop("No protocol column found.")

if (!inherits(zf$observation_date, "Date")) zf$observation_date <- as.Date(zf$observation_date)

bstart <- as.Date(paste0(cfg$p_year, "-", cfg$breeding_start_mmdd))
bend   <- as.Date(paste0(cfg$p_year, "-", cfg$breeding_end_mmdd))

time_to_decimal <- function(x) as.numeric(hms::as_hms(x))/3600

zf <- zf %>%
  mutate(
    protocol_std = .data[[proto_col]],
    observation_count = na_if(observation_count, "X"),
    observation_count = na_if(observation_count, ""),
    observation_count = na_if(observation_count, "unknown"),
    observation_count = na_if(observation_count, "-"),
    observation_count = suppressWarnings(as.integer(observation_count)),
    effort_distance_km = suppressWarnings(as.numeric(if_else(
      grepl("^[0-9.]+$", as.character(effort_distance_km)),
      as.character(effort_distance_km), NA_character_
    ))),
    duration_minutes = suppressWarnings(as.numeric(if_else(
      grepl("^[0-9.]+$", as.character(duration_minutes)),
      as.character(duration_minutes), NA_character_
    ))),
    effort_hours = if_else(!is.na(duration_minutes) & duration_minutes > 0, duration_minutes / 60, NA_real_),
    effort_speed_kmph = if_else(!is.na(effort_hours) & effort_hours > 0, effort_distance_km / effort_hours, NA_real_),
    year = lubridate::year(observation_date),
    day_of_year = lubridate::yday(observation_date)
  ) %>%
  filter(observation_date >= bstart, observation_date <= bend)

zf$time_observations_started <- as.character(zf$time_observations_started)
ok_time <- !is.na(zf$time_observations_started) & grepl("^\d{2}:\d{2}:\d{2}$", zf$time_observations_started)
zf$hours_of_day <- NA_real_
zf$hours_of_day[ok_time] <- time_to_decimal(zf$time_observations_started[ok_time])

set.seed(42)
zf$type <- if_else(runif(nrow(zf)) <= 0.8, "train", "test")

checklists_out <- zf %>%
  select(checklist_id, observer_id, type,
         observation_count, species_observed,
         state_code, locality_id, latitude, longitude,
         protocol_std, all_species_reported,
         observation_date, year, day_of_year,
         hours_of_day,
         effort_hours, effort_distance_km, effort_speed_kmph,
         number_observers)

out_path <- file.path(sp_dir, sprintf("checklists-%s_%d.csv", sp, yr))
write_csv(checklists_out, out_path, na = "")
message("Wrote: ", out_path)
