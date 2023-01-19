********************************************************************************
* 0. CONFIGURATION OF PATHS
********************************************************************************

clear all
capture log close
set more off

global workingDir "C:\Users\andrea\Dropbox\andrea\research\03_papers\2016_het_returns_paper\2020-11 revision RSSM\01_analysis_nlsy"
global codeDir "C:\Users\andrea\Dropbox\andrea\research\08_methods_coding"

*------------------------------------------------------------------------------*
global data			"${workingDir}\00_data"				// original files
global dofiles 		"${workingDir}\01_code"				// do-files
global posted		"${workingDir}\02_posted"			// prepared data
global logs			"${workingDir}\03_logs"				// log files
global tables 		"${workingDir}\04_tables"			// figures
global figures		"${workingDir}\05_figures"			// tables for latex
global code			"${codeDir}" 						// others' code for occupations etc.
global robust		"${workingDir}\06_output_robustness_checks" //output robustness checks 
*------------------------------------------------------------------------------*

********************************************************************************
* 1. Open Data and Log file
********************************************************************************

log using "$logs/3_hte_nlsy_sample.txt", replace


use "$posted/nlsy_final_data.dta", clear

********************************************************************************
* Residualize the school-relevant characteristics
********************************************************************************

*-------------------------------------------------------------------------------
* Men
*-------------------------------------------------------------------------------

// Each meritocratic variable is residualized by regressing it on all 
// non-meritocratic variables

	regress ability ///
		parinc edupar black hispanic jewish bothpar i.numkid urban proxim friends ///
		 if female==0
	predict abil_r_m if female==0, res
	
	regress collprep ///
		parinc edupar black hispanic jewish bothpar i.numkid urban proxim friends ///
		 if female==0
	predict collprep_r_m if female==0, res

*-------------------------------------------------------------------------------
* Women
*-------------------------------------------------------------------------------

// Each meritocratic variable is residualized by regressing it on all 
// non-meritocratic variables

	regress ability ///
		parinc edupar black hispanic jewish bothpar i.numkid urban proxim friends ///
		 if female==1
	predict abil_r_f if female==1, res
	
	regress collprep ///
		parinc edupar black hispanic jewish bothpar i.numkid urban proxim friends ///
		 if female==1
	predict collprep_r_f if female==1, res

*-------------------------------------------------------------------------------
* Put into one variable
*-------------------------------------------------------------------------------	

gen abil_r = abil_r_m
	replace abil_r = abil_r_f if female==1
	
lab var abil_r "Ability (res)"

gen collprep_r = collprep_r_m
	replace collprep_r = collprep_r_f if female==1
	
lab var collprep_r "College prep. (res)"

drop abil_r_m collprep_r_m abil_r_f collprep_r_f


********************************************************************************
* Sample
********************************************************************************

count // 12,686

********************************************************************************
* No missings on pre-college covariates
********************************************************************************

keep if !missing(female, age, parinc, edupar, black, hispanic, jewish, ///
	bothpar, numkid, urban, proxim, friends, abil_r, collprep_r) // 4,494 missing

count // 8,192

********************************************************************************
* Students under 18 in 1979
********************************************************************************

keep if age < 18 // 3,991 to missing

count // 4,201

********************************************************************************
// completed 12th grade by 1990 (HS degree)
********************************************************************************
keep if eduyears90 >= 12 // missing 718

count // 3,483

save "$posted\nlsy_final_sample_residualized.dta", replace
