## Resubmission

This is a resubmission. In response to CRAN feedback, the following have been effected:

* Removed the redundant "A toolkit that" from the Description field.
* Changed `tr_tripod_report()` to default to writing output in `tempdir()` 
  instead of the working directory, and updated all examples/vignettes 
  accordingly.
* Replaced `cat()`/`print()` console output with `message()` in 
  `tr_recommend_method()`, `tr_agent_review()`, `tr_sensitivity()`, 
  `tr_check_missing()`, and `tr_validate()`, so informational output can be 
  suppressed via `suppressMessages()`.
