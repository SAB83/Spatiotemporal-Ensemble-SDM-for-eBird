# R/utils_crs.R
# Centralize LAEA CRS text.

laea_from_config <- function(cfg) {
  cfg$laea_crs %||% "+proj=laea +lat_0=45 +lon_0=-100 +datum=WGS84 +units=m +no_defs"
}
