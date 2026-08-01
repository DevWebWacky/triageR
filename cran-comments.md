## Resubmission

This is a resubmission (0.1.1) fixing a vignette build failure discovered 
on CRAN after 0.1.0's acceptance. The failure was caused by `mlbench` 
removing the `PimaIndiansDiabetes` dataset in a recent release (following 
its removal from the UCI Machine Learning Repository). The 
'triageR-intro' vignette now uses `MASS::Pima.tr2` instead, which ships 
as part of R's own recommended packages and is not subject to the same 
risk. The 'triageR-breast-cancer' vignette (using `mlbench::BreastCancer`, 
unaffected) is unchanged.
