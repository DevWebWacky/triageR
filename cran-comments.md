## Submission

This is a feature release (0.2.0) adding:

* Calibration plots (binned or smoothed) and Brier score in `tr_validate()`.
* Survival analysis support: `tr_fit_survival()` (Cox Proportional Hazards 
  and Random Survival Forest via the `censored`/`aorsf` engines) and 
  `tr_validate_survival()` (concordance index).
* Survival models are now supported throughout `tr_agent_review()` and 
  `tr_tripod_report()` (via a new `model_type` argument).
* A new vignette covering the survival analysis workflow.
* `tr_launch_app()`: an interactive Shiny application bundled in 
  `inst/shiny-app/` providing a no-code interface to the full workflow.
* A live pkgdown documentation site.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local (Windows), win-builder (devel and release)
