# triageR 0.2.0

# triageR 0.2.0

* Added calibration plots (binned or smoothed) and Brier score to 
  `tr_validate()`, closing a TRIPOD+AI reporting gap. New `calibration_method` 
  argument (`"binned"` or `"smooth"`).
* Calibration plot now included in `tr_tripod_report()` output.
* Added robustness handling for models with limited probability variation 
  (e.g. tree-based models with many identical predictions).
* Added survival analysis support: `tr_fit_survival()` (Cox Proportional 
  Hazards and Random Survival Forest via the `censored`/`aorsf` engines) and 
  `tr_validate_survival()` (concordance index / C-index).

# triageR 0.1.1

*`PimaIndianDataset` in the `mlbench` package was removed in the latest update, thus the vignette now uses the inbuilt MASS which still has the Pima Indian Diabetes Dataset.

# triageR 0.1.0

* Initial development version.
* Added data layer: `tr_load_clinical()`, `tr_check_missing()`, `tr_impute()`.
* Added model layer: `tr_fit()`, `tr_validate()`, `tr_explain()`.
* Added agent layer: `tr_recommend_method()`, `tr_sensitivity()`, `tr_agent_review()`.
* Added reporting layer: `tr_tripod_report()`.
