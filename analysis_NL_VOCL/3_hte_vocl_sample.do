********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Residualization procedure for school-relevant characteristics and
* restriction of the sample for analysis
********************************************************************************

* Description

/* We residualize each of the school-relevant variables on all school-irrelevant 
factors to disentangle the two dimensions of propensity. Furthermore, we
make restriction to the sample for  the final analysis */


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


********************************************************************************
* Load prepared data set
********************************************************************************
use "$posted/2_vocl_prepared.dta", clear

sum intellig7 female age havovwo zcito moroccan suriantill turkish ///
	other_nonNL bothpar numkid urban edupar zencourage parinc

********************************************************************************
* Residualize the school-relevant characteristics
********************************************************************************
/* Residualization is done separately for men and women as our analyses are 
also separate for the two genders. 
Finally the two residualizations are combined into one variable  */

*-------------------------------------------------------------------------------
* Men
*-------------------------------------------------------------------------------

// each school-relevant vaiable is residualized by regressing it on all 
// school-irrelevant variables

regress zcito edupar parinc	moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid i.urban zencourage ///
		if female==0
predict zcito_r_m if female==0, res

regress intellig7 edupar parinc	moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid i.urban zencourage ///
		if female==0
predict intellig7_r_m if female==0, res

regress havovwo edupar parinc moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid i.urban zencourage ///
		if female==0
predict havovwo_r_m if female==0, res

*-------------------------------------------------------------------------------
* Women
*-------------------------------------------------------------------------------

// each school-relevant vaiable is residualized by regressing it on all 
// school-irrelevant variables

regress zcito edupar parinc	moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid i.urban zencourage ///
		if female==1
predict zcito_r_f if female==1, res

regress intellig7 edupar parinc	moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid i.urban zencourage ///
		if female==1
predict intellig7_r_f if female==1, res

regress havovwo edupar parinc moroccan suriantill turkish other_nonNL ///
		bothpar i.numkid i.urban zencourage ///
		if female==1
predict havovwo_r_f if female==1, res

*-------------------------------------------------------------------------------
* Put into one variable
*-------------------------------------------------------------------------------

gen zcito_r = zcito_r_m
	replace zcito_r = zcito_r_f if female==1
	
lab var zcito_r "Cito score (res)"

gen intellig7_r = intellig7_r_m
	replace intellig7_r = intellig7_r_f if female==1
	
lab var intellig7_r "Intelligence score (res)"

gen havovwo_r = havovwo_r_m
	replace havovwo_r = havovwo_r_f if female==1
	
lab var havovwo_r "College track (res)"

drop zcito_r_m intellig7_r_m havovwo_r_m zcito_r_f intellig7_r_f havovwo_r_f

********************************************************************************
*  Sample Restrictions
********************************************************************************

// Original VOCL data: 19,524 respondents

count
// Only those with register data identifier: 19,111 (= 413 missing)

*-------------------------------------------------------------------------------
* Only students who answered 7th grade questionnaire and test
*-------------------------------------------------------------------------------

* Questionnaire
keep if dusb1_it ==1 // 940 missing
count // 18,171

* Cito test
keep if dumen_it ==1 // 384 missing
count // 17,787

*-------------------------------------------------------------------------------
// Only students with VOCL parent information: (=850 missing)
*-------------------------------------------------------------------------------

keep if dumou_vr ==1 // 737 missing
count // 17050


*-------------------------------------------------------------------------------
// Only students with SSD parent information:
*-------------------------------------------------------------------------------

keep if parinc!=. // 2,410 missing
count // 14,640

*-------------------------------------------------------------------------------
* Only students with no missing data on VOCL pre-college covariates
*-------------------------------------------------------------------------------

keep if !missing(intellig7, female, age, havovwo, zcito, ///
	moroccan, suriantill, turkish, other_nonNL, ///
	bothpar, numkid, urban, edupar, zencourage) 
	// 1,909 missing

count // 12,731

sum intellig7 female age havovwo zcito moroccan suriantill turkish other_nonNL bothpar numkid urban edupar zencourage parinc

*-------------------------------------------------------------------------------
* Only students under 18 in 1989
*-------------------------------------------------------------------------------

keep if age!=15 // 59 missing
count  // 12,672

*-------------------------------------------------------------------------------
* Only those who are eligible for HE by 2003 (havo/vwo degree)
*-------------------------------------------------------------------------------

keep if secondary ==1 // 4,230 missing
count // 8,442


*-------------------------------------------------------------------------------
* Saving
*-------------------------------------------------------------------------------

save "$posted/3_vocl_restricted.dta", replace





