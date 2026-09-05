# Changelog

## triageR 0.2.0

- Added calibration plots (binned or smoothed) and Brier score to
  [`tr_validate()`](https://devwebwacky.github.io/triageR/reference/tr_validate.md),
  closing a TRIPOD+AI reporting gap. New `calibration_method` argument
  (`"binned"` or `"smooth"`).
- Calibration plot now included in
  [`tr_tripod_report()`](https://devwebwacky.github.io/triageR/reference/tr_tripod_report.md)
  output.
- Added robustness handling for models with limited probability
  variation (e.g. tree-based models with many identical predictions).
- Added survival analysis support:
  [`tr_fit_survival()`](https://devwebwacky.github.io/triageR/reference/tr_fit_survival.md)
  (Cox Proportional Hazards and Random Survival Forest via the
  `censored`/`aorsf` engines) and
  [`tr_validate_survival()`](https://devwebwacky.github.io/triageR/reference/tr_validate_survival.md)
  (concordance index / C-index).
- Added
  [`tr_launch_app()`](https://devwebwacky.github.io/triageR/reference/tr_launch_app.md):
  an interactive Shiny application for the full triageR workflow (upload
  data, fit and compare models, validate, explain, review, and download
  a TRIPOD+AI report) without writing R code.
- Fixed test suite reliability issues related to lazy-loaded survival
  datasets.

## triageR 0.1.1

CRAN release: 2026-08-02

\*`PimaIndianDataset` in the `mlbench` package was removed in the latest
update, thus the vignette now uses the inbuilt MASS which still has the
Pima Indian Diabetes Dataset.

## triageR 0.1.0

CRAN release: 2026-07-29

- Initial development version.
- Added data layer:
  [`tr_load_clinical()`](https://devwebwacky.github.io/triageR/reference/tr_load_clinical.md),
  [`tr_check_missing()`](https://devwebwacky.github.io/triageR/reference/tr_check_missing.md),
  [`tr_impute()`](https://devwebwacky.github.io/triageR/reference/tr_impute.md).
- Added model layer:
  [`tr_fit()`](https://devwebwacky.github.io/triageR/reference/tr_fit.md),
  [`tr_validate()`](https://devwebwacky.github.io/triageR/reference/tr_validate.md),
  [`tr_explain()`](https://devwebwacky.github.io/triageR/reference/tr_explain.md).
- Added agent layer:
  [`tr_recommend_method()`](https://devwebwacky.github.io/triageR/reference/tr_recommend_method.md),
  [`tr_sensitivity()`](https://devwebwacky.github.io/triageR/reference/tr_sensitivity.md),
  [`tr_agent_review()`](https://devwebwacky.github.io/triageR/reference/tr_agent_review.md).
- Added reporting layer:
  [`tr_tripod_report()`](https://devwebwacky.github.io/triageR/reference/tr_tripod_report.md).
