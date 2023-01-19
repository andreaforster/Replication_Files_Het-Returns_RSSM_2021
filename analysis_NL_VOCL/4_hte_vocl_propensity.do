********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Propensity score analysis, creation of ipw weights and propensity dimensions
********************************************************************************

* Description

/* 
1. This do file produces summary statistics for the background characteristics
of students.
2. Logistic regression analyses are carried out with the dichotomous indicator for 
tertiary degree as dependent variables. This is done for one dimension of 
propensity, including all background characteristics and subsequently separately
for school-relevant and school-irrelevant characteristcs. In a next step,
the predicted probabilities from these regressions are taken and saved into a 
variable. These are the propensity values for each individual in the data.
3. The do file produces summary statistics for the propensity scores
4. IPT weights are created based on the one-dimensional propensity values that
are used in the further analysis
 */


********************************************************************************
* General settings
version 16
clear all
set more off

********************************************************************************

* Configure paths
global workingDir "H:\Andrea\heterog. effects edu\2021-04_replication_files"

global dataDir "${workingDir}\00_data"				// original data sets
global dofiles "${workingDir}\01_dofiles"			// Stata do-files
global posted "${workingDir}\02_posted"				// prepared data sets
global graphs "${workingDir}\03_graphs"				// output graphs
global tables "${workingDir}\04_tables"				// output tables 

********************************************************************************
		
* Load prepared data
use "$posted\3_vocl_restricted.dta", clear

********************************************************************************
* Descriptives Background characteristics
********************************************************************************

estpost sum age parinc edupar moroccan suriantill turkish other_nonNL ///
	bothpar numkid urban zencourage zcito intellig7 havovwo if tertiary==0 & female==0
est store men_nocoll
	
estpost sum age parinc edupar moroccan suriantill turkish other_nonNL ///
	bothpar numkid urban zencourage zcito intellig7 havovwo if tertiary==0 & female==1
est store women_nocoll

estpost sum age parinc edupar moroccan suriantill turkish other_nonNL ///
	bothpar numkid urban zencourage zcito intellig7 havovwo if tertiary==1 & female==0
est store men_coll

estpost sum age parinc edupar moroccan suriantill turkish other_nonNL ///
	bothpar numkid urban zencourage zcito intellig7 havovwo if tertiary==1 & female==1
est store women_coll


esttab men_nocoll men_coll women_nocoll women_coll ///
	using "$tables\tab2_vocl_background_descriptives.txt", replace nostar wide nopar ///
	cells("mean(fmt(2)) sd(fmt(2))")

********************************************************************************
* One Dimension of Propensity
********************************************************************************

*-------------------------------------------------------------------------------
* Men
*-------------------------------------------------------------------------------

/* Predict propensity of college degree (including squared terms for all 
continuous variables */

logit tertiary ///
	c.intellig7##c.intellig7 havovwo c.zcito##c.zcito ///
	c.edupar##c.edupar c.parinc##c.parinc ///
	moroccan suriantill turkish other_nonNL ///
	bothpar i.numkid ///
	i.urban ///
	c.zencourage##c.zencourage ///
	if female==0

/* Predict propensity of college degree (squared terms only if significant
= only for zcito) */

logit tertiary ///
	intellig7 havovwo c.zcito##c.zcito ///
	edupar c.parinc ///
	moroccan suriantill turkish other_nonNL ///
	bothpar i.numkid ///
	i.urban ///
	c.zencourage ///
	if female==0
estimates store prop_men
	
	
/* Predict propensity scores for individuals based on logit model */

predict ps_men, pr
replace ps_men=. if female==1

lab var ps_men "Propensity of College (one dimension)"
	
*-------------------------------------------------------------------------------
* Women
*-------------------------------------------------------------------------------

/* Predict propensity of college degree (including squared terms for all 
continuous variables */

logit tertiary ///
	c.intellig7##c.intellig7 havovwo c.zcito##c.zcito ///
	c.edupar##c.edupar c.parinc##c.parinc ///
	moroccan suriantill turkish other_nonNL ///
	bothpar i.numkid ///
	i.urban ///
	c.zencourage##c.zencourage ///
	if female==1

/* Predict propensity of college degree (squared terms only if significant
= only for zcito) */

logit tertiary ///
	c.intellig7 havovwo c.zcito##c.zcito ///
	edupar c.parinc ///
	moroccan suriantill turkish other_nonNL ///
	bothpar i.numkid ///
	i.urban ///
	c.zencourage ///
	if female==1
estimates store prop_women
	
/* Predict propensity scores for individuals based on logit model */

predict ps_women, pr
replace ps_women=. if female==0
	
lab var ps_women "Propensity of College (one dimension)"

********************************************************************************
* Table propensity models
********************************************************************************

esttab prop_men prop_women ///
	using "$tables\tab4_vocl_propmodels_all.txt" ///
	, nobaselevels nodepvars se pr2 b(%8.2f) replace

********************************************************************************
* Two Dimensions of propensity
********************************************************************************

*-------------------------------------------------------------------------------
* Men
*-------------------------------------------------------------------------------

// SCHOOL RELEVANT //

	* All squared terms
	logit tertiary ///
		c.intellig7_r##c.intellig7_r havovwo_r c.zcito_r##c.zcito_r ///
		if female==0

	* Only significant squared terms
	logit tertiary ///
		c.intellig7_r havovwo_r c.zcito_r##c.zcito_r ///
		if female==0
	est store prop_men_rel
	
	predict ps_men_rel, pr
	replace ps_men_rel=. if female==1
	
	lab var ps_men_rel "Propensity of College (school-relevant)"
	
// SCHOOL IRRELEVANT //

	* All squared terms
	logit tertiary ///
		c.edupar##c.edupar c.parinc##c.parinc ///
		moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid ///
		i.urban ///
		c.zencourage##c.zencourage ///
		if female==0
		
	* Only significant squared terms
	logit tertiary ///
		edupar c.parinc ///
		moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid ///
		i.urban ///
		c.zencourage##c.zencourage ///
		if female==0
	est store prop_men_irr
	
	predict ps_men_irr, pr
	replace ps_men_irr=. if female==1

lab var ps_men_irr "Propensity of College (school-irrelevant)"

*-------------------------------------------------------------------------------
* Women
*-------------------------------------------------------------------------------

// SCHOOL RELEVANT //

	* All squared terms
	logit tertiary ///
		c.intellig7_r##c.intellig7_r havovwo_r c.zcito_r##c.zcito_r ///
		if female==1

	* Only significant squared terms
	logit tertiary ///
		c.intellig7_r havovwo_r c.zcito_r##c.zcito_r ///
		if female==1
	est store prop_women_rel
	
	predict ps_women_rel, pr
	replace ps_women_rel=. if female==0

	lab var ps_women_rel "Propensity of College (school-relevant)"

// SCHOOL IRRELEVANT //

	* All squared terms
	logit tertiary ///
		c.edupar##c.edupar c.parinc##c.parinc ///
		moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid ///
		i.urban ///
		c.zencourage##c.zencourage ///
		if female==1
		
	* Only significant squared terms
	logit tertiary ///
		edupar c.parinc##c.parinc ///
		moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid ///
		i.urban ///
		c.zencourage##c.zencourage ///
		if female==1
	est store prop_women_irr
	
	predict ps_women_irr, pr
	replace ps_women_irr=. if female==0

	lab var ps_women_irr "Propensity of College (school-irrelevant)"
	
********************************************************************************
* Table propensity models
********************************************************************************

esttab prop_men_rel prop_women_rel ///
	using "$tables\tab4_vocl_propmodels_rel.txt" ///
	, nobaselevels nodepvars se pr2 b(%8.2f) replace

esttab prop_men_irr prop_women_irr ///
	using "$tables\tab4_vocl_propmodels_irr.txt" ///
	, nobaselevels nodepvars se pr2 b(%8.2f) replace
	

*-------------------------------------------------------------------------------
* Propensity Score Descriptives
*-------------------------------------------------------------------------------

estpost sum ps_men ps_men_rel ps_men_irr ///
	ps_women ps_women_rel ps_women_irr ///
	if tertiary==0
est store notert

estpost sum ps_men ps_men_rel ps_men_irr ///
	ps_women ps_women_rel ps_women_irr ///
	if tertiary==1
est store tert 

esttab notert tert ///
	using "$tables/tabA4_vocl_propensity_descriptives.txt" ///
	, replace nostar wide nopar ///
	cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
	mtitles("no College" "College")

********************************************************************************
* IPT Weights
********************************************************************************

/* 
Generate inverse probability weights using the propensity score. To balance
the weights better we use the average probability of being allocated to the group
that an individual is allocated to as a denominator instead of 1 
*/

gen ipw = 1

sum tertiary, detail
local pt = r(mean)
local pnt = (1-r(mean))

replace ipw = `pt'/ps_men if tertiary==1 & female==0			//Men with College
replace ipw = `pnt'/(1-ps_men) if tertiary==0 & female==0		//Men without College
replace ipw = `pt'/ps_women if tertiary==1 & female==1			//Women with College
replace ipw = `pnt'/(1-ps_women) if tertiary==0 & female==1		//Women without College

********************************************************************************
* Save
********************************************************************************

save "$posted/4_vocl_propensity.dta", replace

