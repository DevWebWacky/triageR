# triageR 0.1.1

* Fixed vignette build failures on CRAN caused by `mlbench` datasets not 
  being reliably available in `data()` calls without explicit `package =` 
  argument. Vignettes now also degrade gracefully (skip execution) if 
  `mlbench` is unavailable in the build environment.

# triageR 0.1.0

* Initial development version.
* Added data layer: `tr_load_clinical()`, `tr_check_missing()`, `tr_impute()`.
* Added model layer: `tr_fit()`, `tr_validate()`, `tr_explain()`.
* Added agent layer: `tr_recommend_method()`, `tr_sensitivity()`, `tr_agent_review()`.
* Added reporting layer: `tr_tripod_report()`.
