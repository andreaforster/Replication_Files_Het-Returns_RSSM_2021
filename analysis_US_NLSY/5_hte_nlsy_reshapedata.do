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


log using "$logs/5_hte_nlsy_reshapedata.txt", replace

use "$posted/nsly_data_hte-analysis_resid.dta", clear

keep ps_men ps_women ps_men_rel ps_men_irr ps_women_rel ps_women_irr ipw ///
	id college lnwg*

rename lnwg1994 lnwg1
rename lnwg1996 lnwg2 
rename lnwg1998 lnwg3 
rename lnwg2000 lnwg4 
rename lnwg2002 lnwg5 
rename lnwg2004 lnwg6
rename lnwg2006 lnwg7 

reshape long lnwg, i(id) j(year)

recode year (1=1994)(2=1996)(3=1998)(4=2000)(5=2002)(6=2004)(7=2006) ///
	(8=2008)(9=2010)(10=2012)

gen age = .
replace age=31 if year==1994
replace age=33 if year==1996
replace age=35 if year==1998
replace age=37 if year==2000
replace age=39 if year==2002
replace age=41 if year==2004
replace age=43 if year==2006

lab var age "Age at Wage"

gen age_c = age-31
lab var age_c "Age centered"




save "$posted/nlsy_pooled_data_hte_resid.dta", replace
