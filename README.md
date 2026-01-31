# ebird-aukrf-range-shift-sdm

End-to-end pipeline to build **checklist-level detection/non-detection datasets** from eBird (EBD + SED),
engineer **environmental predictors** (climate, elevation, landcover metrics), and train **ensemble Random
Forest SDMs** to map **current** and **future** binary ranges.

This repo is a clean scaffold for the pipeline you shared (AUK → zerofill → effort cleaning → features →
ensemble RF → mapping/export).

---

## What this produces

- `data/processed/<species>/checklists-<species>_<year>.csv`  
  Model-ready checklists (detections + non-detections), filtered to US/CA/MX and your season window.
- `data/processed/<species>/env_train_locality_mp{mp}_p{p}_delta_<species>.csv`  
  Training predictors on checklist localities (mp + p + deltas).
- `data/processed/<species>/env_grid_mp{mp}_p{p}_delta_NA3km.csv`  
  Prediction-grid predictors on a 3km LAEA grid.
- `outputs/rasters/<species>_current_<year>.tif` and `<species>_future_p{p}_h{horizon}.tif`  
  Binary range maps.
- `outputs/maps/<species>_current_<year>.pdf` and `outputs/maps/<species>_future_p{p}_h{horizon}.pdf`  
  Quick visualization.

---

## Quick start

1) Install packages (suggested: `renv`)
```r
install.packages("renv")
renv::init()
renv::install(c("auk","dplyr","tidyr","readr","sf","terra","ranger","rsample",
                "rnaturalearth","rnaturalearthdata","units","exactextractr",
                "landscapemetrics","data.table","ggplot2","scales","hms","purrr","yaml"))
renv::snapshot()
```

2) Edit configuration:
- `config/config.yml`

3) Run the pipeline (example):
```bash
Rscript scripts/01_combine_ebd_sed_raw_txt.R
Rscript scripts/02_split_ebd_sed_by_year.R
Rscript scripts/03_auk_zero_fill_and_clean_checklists.R
Rscript scripts/04_build_env_training_localities_mp_p_deltas.R
Rscript scripts/05_build_env_prediction_grid_mp_p_deltas.R
Rscript scripts/06_train_ensemble_rf_current_range.R
Rscript scripts/07_predict_future_range_ensemble_rf.R
```

---

## Notes

- **Paths**: this scaffold uses relative paths under the repo. Update `config/config.yml` if you want Box paths.
- **Projections**: LAEA definition is centralized in `R/utils_crs.R`.
- **BCR region groups**: place your BCR zip under `data-raw/shapes/` and point scripts to it (or adapt to download).
