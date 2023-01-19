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


log using "$logs/4_hte_nlsy_propensity.txt", replace

use "$posted/nlsy_final_sample_residualized.dta", clear


*-------------------------------------------------------------------------------
* Descriptives background characteristics
*-------------------------------------------------------------------------------

estpost sum age parinc edupar black hispanic jewish bothpar numkid urban proxim ///
	friends ability collprep if college==0 & female ==0
est store men_nocoll

estpost sum age parinc edupar black hispanic jewish bothpar numkid urban proxim ///
	friends ability collprep if college==0 & female ==1
est store women_nocoll

estpost sum age parinc edupar black hispanic jewish bothpar numkid urban proxim ///
	friends ability collprep if college==1 & female ==0
est store men_coll

estpost sum age parinc edupar black hispanic jewish bothpar numkid urban proxim ///
	friends ability collprep if college==1 & female ==1
est store women_coll

esttab men_nocoll men_coll women_nocoll women_coll , replace nostar par cells("mean(fmt(2)) sd(fmt(2))") 








*-------------------------------------------------------------------------------
* Men
*-------------------------------------------------------------------------------

* Propensity model with squared terms for all continuous variables

logit college ///
	c.ability##c.ability collprep ///
	c.parinc##c.parinc c.edupar##c.edupar ///
	black hispanic jewish ///
	bothpar c.numkid##c.numkid ///
	urban proxim ///
	friends ///
	if female==0 

* Propensity model with squared terms only if significant (=none)

logit college ///
	c.ability collprep ///
	c.parinc c.edupar ///
	black hispanic jewish ///
	bothpar c.numkid ///
	urban proxim ///
	friends ///
	if female==0 
estimates store prop_men

* Predict propensity scores for individuals based on logit model

predict ps_men, pr
replace ps_men=. if female==1

lab var ps_men "Overall Propensity Men"

*-------------------------------------------------------------------------------
* Women
*-------------------------------------------------------------------------------

* Propensity model with squared terms for all continuous variables
logit college ///
	c.ability##c.ability collprep ///
	c.parinc##c.parinc c.edupar##c.edupar ///
	black hispanic jewish ///
	bothpar c.numkid##c.numkid ///
	urban proxim ///
	friends ///
	if female==1 

* Propensity model with squared terms only if significant (=only edumo)

logit college ///
	c.ability collprep ///
	c.parinc c.edupar##c.edupar ///
	black hispanic jewish ///
	bothpar c.numkid ///
	urban proxim ///
	friends ///
	if female==1
estimates store prop_women

* Predict propensity scores for individuals based on logit model

predict ps_women, pr
replace ps_women=. if female==0

lab var ps_women "Overall Propensity Women"

********************************************************************************
* Two Dimensions of Propensity
********************************************************************************

*-------------------------------------------------------------------------------
* Men
*-------------------------------------------------------------------------------

// SCHOOL RELEVANT

	* All squared terms
	logit college ///
		c.abil_r##c.abil_r collprep_r ///
		if female==0 

	* Only significant square terms (=none)
	logit college ///
		c.abil_r collprep_r ///
		if female==0 
	estimates store prop_men_rel

	predict ps_men_rel, pr
	replace ps_men_rel=. if female==1

lab var ps_men_rel "School-relevant Propensity Men"

// SCHOOL IRRELEVANT

	* All square terms
	logit college ///
		c.parinc##c.parinc c.edupar##c.edupar ///
		black hispanic jewish ///
		bothpar c.numkid##c.numkid ///
		urban proxim ///
		friends ///
		if female==0 

	* Only significant square terms (=none)
	logit college ///
		c.parinc c.edupar ///
		black hispanic jewish ///
		bothpar c.numkid ///
		urban proxim ///
		friends ///
		if female==0 
	estimates store prop_men_irr

	predict ps_men_irr, pr
	replace ps_men_irr=. if female==1

lab var ps_men_irr "School-irrelevant Propensity Men"

*-------------------------------------------------------------------------------
* Women
*-------------------------------------------------------------------------------

// SCHOOL RELEVANT

	* All squared terms
	logit college ///
		c.abil_r##c.abil_r collprep_r ///
		if female==1

	* Only significant square terms (=none)
	logit college ///
		c.abil_r collprep_r ///
		if female==1 
	estimates store prop_women_rel

	predict ps_women_rel, pr
	replace ps_women_rel=. if female==0

lab var ps_women_rel "School-relevant Propensity Women"

// SCHOOL IRRELEVANT

	* All square terms
	logit college ///
		c.parinc##c.parinc c.edupar##c.edupar ///
		black hispanic jewish ///
		bothpar c.numkid##c.numkid ///
		urban proxim ///
		friends ///
		if female==1

	* Only significant square terms (=edufa, edumo)
	logit college ///
		c.parinc c.edupar##c.edupar ///
		black hispanic jewish ///
		bothpar c.numkid ///
		urban proxim ///
		friends ///
		if female==1
	estimates store prop_women_irr

	predict ps_women_irr, pr
	replace ps_women_irr=. if female==0

lab var ps_women_irr "School-irrelevant Propensity Women"

********************************************************************************
* Table propensity models
********************************************************************************

esttab prop_men prop_men_rel prop_men_irr prop_women prop_women_rel prop_women_irr ///
	using "$tables/propmodels_all_resid.rtf" ///
	, nobaselevels label nodepvars se pr2 replace b(%9.2f)

*-------------------------------------------------------------------------------
* Density Plots
*-------------------------------------------------------------------------------

// Men - One dimension
twoway kdensity ps_men if college==0 || kdensity ps_men if college==1 ///
	, xscale(range(0(0.2)1)) xlabel(0(0.2)1) ///
	xtitle("Propensity of College (one dimension)") ///
	ytitle("Density") ///
	legend(order(1 "No college degree" 2 "College degree") pos(6) col(2))
graph export "$figures/density_ps_men_onedimension.pdf", replace

// Women - One dimension
twoway kdensity ps_women if college==0 || kdensity ps_women if college==1 ///
	, xscale(range(0(0.2)1)) xlabel(0(0.2)1) ///
	xtitle("Propensity of College (one dimension)") ///
	ytitle("Density") ///
	legend(order(1 "No college degree" 2 "College degree") pos(6) col(2))
graph export "$figures/density_ps_women_onedimension.pdf", replace

// Men - School-relevant
twoway kdensity ps_men_rel if college==0 || kdensity ps_men_rel if college==1 ///
	, xscale(range(0(0.2)1)) xlabel(0(0.2)1) ///
	xtitle("Propensity of College (school-relevant)") ///
	ytitle("Density") ///
	legend(order(1 "No college degree" 2 "College degree") pos(6) col(2))
graph export "$figures/density_ps_men_relevant_res.pdf", replace

// Women - School-relevant
twoway kdensity ps_women_rel if college==0 || kdensity ps_women_rel if college==1 ///
	, xscale(range(0(0.2)1)) xlabel(0(0.2)1) ///
	xtitle("Propensity of College (school-relevant)") ///
	ytitle("Density") ///
	legend(order(1 "No college degree" 2 "College degree") pos(6) col(2))
graph export "$figures/density_ps_women_relevant_res.pdf", replace

// Men - School-irrelevant
twoway kdensity ps_men_irr if college==0 || kdensity ps_men_irr if college==1 ///
	, xscale(range(0(0.2)1)) xlabel(0(0.2)1) ///
	xtitle("Propensity of College (school-irrelevant)") ///
	ytitle("Density") ///
	legend(order(1 "No college degree" 2 "College degree") pos(6) col(2))
graph export "$figures/density_ps_men_irrelevant.pdf", replace

// Women - School-irrelevant
twoway kdensity ps_women_irr if college==0 || kdensity ps_women_irr if college==1 ///
	, xscale(range(0(0.2)1)) xlabel(0(0.2)1) ///
	xtitle("Propensity of College (school-irrelevant)") ///
	ytitle("Density") ///
	legend(order(1 "No college degree" 2 "College degree") pos(6) col(2))
graph export "$figures/density_ps_women_irrelevant.pdf", replace

*-------------------------------------------------------------------------------
* Propensity Score Descriptives
*-------------------------------------------------------------------------------

estpost sum ps_men ps_men_rel ps_men_irr ///
	ps_women ps_women_rel ps_women_irr ///
	if college==0
est store notert

estpost sum ps_men ps_men_rel ps_men_irr ///
	ps_women ps_women_rel ps_women_irr ///
	if college==1
est store tert

esttab notert tert ///
	using "$tables/propensity_descriptives_res.rtf" ///
	, replace nostar wide par  ///
	cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
	mtitles("no College" "College")

********************************************************************************
* IPT Weights
********************************************************************************

sum college, detail
local pt = r(mean)
local pnt = (1-r(mean))

gen ipw=1 
replace ipw = `pt'/ps_men if college==1 & female==0			// Men with College
replace ipw = `pnt'/(1-ps_men) if college==0 & female==0	// Men without College

replace ipw = `pt'/ps_women if college==1 & female==1		// Women with College
replace ipw = `pnt'/(1-ps_women) if college==0 & female==1	// Women without College


********************************************************************************
* Comparison of descriptives
********************************************************************************


estpost sum parinc edupar black hispanic jewish bothpar numkid ///
	urban proxim friends ability collprep ///
	if college==0 
est store raw0

estpost sum parinc edupar black hispanic jewish bothpar numkid ///
	urban proxim friends ability collprep ///
	if college==1 
est store raw1

estpost sum parinc edupar black hispanic jewish bothpar numkid ///
	urban proxim friends ability collprep [aweight = ipw] ///
	if college==0 
est store weight0

estpost sum parinc edupar black hispanic jewish bothpar numkid ///
	urban proxim friends ability collprep [aweight = ipw] ///
	if college==1 
est store weight1

esttab raw0 raw1 weight0 weight1 , replace nostar par cells("mean(fmt(2)) sd(fmt(2))") 

********************************************************************************
* Save
********************************************************************************

save "$posted/nsly_data_hte-analysis_resid.dta", replace
log close
