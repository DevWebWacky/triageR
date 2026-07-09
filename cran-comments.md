## R CMD check results

0 errors | 0 warnings | 0 notes

## Additional notes

* triageR includes an optional AI agent layer (functions `tr_recommend_method()`
  and parts of `tr_agent_review()`) that calls an external LLM API (Google
  Gemini via the `ellmer` package). These functions are not used in examples,
  vignettes, or tests without a live API key, and all core functionality
  (data preparation, model fitting, validation, explainability, sensitivity
  analysis, and reporting) works fully offline without any API access.
* Vignettes were built and tested locally; two use real, publicly available
  datasets (`mlbench::PimaIndiansDiabetes`, `mlbench::BreastCancer`).
