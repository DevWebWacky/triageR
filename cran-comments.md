## Resubmission

This is a resubmission (0.1.1) fixing a vignette build failure discovered 
on CRAN after 0.1.0's acceptance. `data(PimaIndiansDiabetes)` and 
`data(BreastCancer)` calls now explicitly specify `package = "mlbench"`, 
and vignettes skip execution if `mlbench` is unavailable in the 
build environment.
