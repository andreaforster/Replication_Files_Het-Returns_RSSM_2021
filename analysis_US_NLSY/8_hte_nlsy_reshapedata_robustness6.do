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


egen lnwg_av = rowmean(lnwg1994 lnwg1996 lnwg1998 lnwg2000 lnwg2002 lnwg2004 lnwg2006)




save "$posted/nlsy_pooled_data_hte_resid.dta", replace
