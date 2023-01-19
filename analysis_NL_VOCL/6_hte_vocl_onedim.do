********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Heterogeneous return analysis using the one-dimensional propensity score
********************************************************************************

* Description

/* This do-file carries out the heterogeneous return analysis for one dimension
of propensity. First, the data is restricted to the are of common support.
Then random effects models are carried out and marginal effects plots are
produced for Figure 1 in the paper. The analysis is carried out separately for men and 
women. Finally, a combined table is created that is the basis for table 5 in
the paper. In addition, a table is created for the analysis with age trends
in the appendix. */


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
use "$posted\5_vocl_reshaped.dta", clear

********************************************************************************
* Men
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------

preserve
keep if ps_men!=.

sum ps_men if tertiary==0, detail
local min0_men = r(min)
local max0_men = r(max)

sum ps_men if tertiary==1, detail
local min1_men = r(min)
local max1_men = r(max)

gen low_men = `min1_men' 
replace low_men = `min0_men' if `min0_men' > `min1_men' 

gen hi_men = `max0_men' 
replace hi_men = `max1_men' if `max0_men' > `max1_men' 


drop if ps_men < low_men & ps_men!=. // 300 obs missing
drop if ps_men > hi_men & ps_men!=. // 48 obs missing

*-------------------------------------------------------------------------------
* Random Effects Models
*-------------------------------------------------------------------------------

* Model I
xtmixed lnwg c.ps_men tertiary c.age_c || rin: , mle variance pweight(ipw)
est store men_I

* Model II
xtmixed lnwg c.ps_men##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store men_II

	* Marginal Effects Plot for Model II
	margins, dydx(tertiary) at (ps_men = (0(0.1)0.8)) atmeans 

	marginsplot, ///
		title("") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
		
		graph export "$graphs/fig1_vocl_onedim_men.pdf", replace

/*yscale(range(-1(0.2)1.4)) ylabel(-1(0.2)1.4)*/

* Model III (Appendix)
xtmixed lnwg c.ps_men##tertiary##c.age_c || rin: , mle variance pweight(ipw)
est store men_III

* Model IV (Appendix)
xtmixed lnwg c.ps_men##tertiary ///
	c.ps_men##c.ps_men##tertiary ///
	c.age_c || rin: , mle variance pweight(ipw) 
est store men_IV

* Model V (Appendix)
xtmixed lnwg c.ps_men##tertiary ///
	c.ps_men##c.ps_men##tertiary ///
	c.ps_men##c.ps_men##c.ps_men##tertiary ///
	c.age_c || rin: , mle variance pweight(ipw) 
est store men_V

* Model VI (Appendix)
xtmixed lnwg c.ps_men##tertiary ///
	c.ps_men##c.ps_men##tertiary ///
	c.ps_men##c.ps_men##c.ps_men##tertiary ///
	c.ps_men##c.ps_men##c.ps_men##c.ps_men##tertiary ///
	c.age_c || rin: , mle variance pweight(ipw) 
est store men_VI

restore 

********************************************************************************
* Women
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------

preserve 

keep if ps_women!=. 

sum ps_women if tertiary==0, detail
local min0_women = r(min)
local max0_women = r(max)

sum ps_women if tertiary==1, detail
local min1_women = r(min)
local max1_women = r(max)

gen low_women = `min1_women' 
replace low_women = `min0_women' if `min0_women' > `min1_women' 

gen hi_women = `max0_women' 
replace hi_women = `max1_women' if `max0_women' > `max1_women' 


drop if ps_women < low_women & ps_women!=. // 46 missing
drop if ps_women > hi_women & ps_women!=. // 4 missing

*-------------------------------------------------------------------------------
* Random Effects Models
*-------------------------------------------------------------------------------

* Empty Model
xtmixed lnwg || rin: , mle variance pweight(ipw)
xtmrho

* Model I
xtmixed lnwg c.ps_women tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_I

* Model II
xtmixed lnwg c.ps_women##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_II

	* Marginal Effects Plot for Model II
	margins, dydx(tertiary) at (ps_women = (0(0.1)0.8)) atmeans 

	marginsplot, ///
		title("") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))		
		
		graph export "$graphs/fig1_vocl_onedim_women.pdf", replace

* Model III (Appendix)
xtmixed lnwg c.ps_women##tertiary##c.age_c || rin: , mle variance pweight(ipw)
est store women_III

restore
*-------------------------------------------------------------------------------
* Combined table - Men, Women
*-------------------------------------------------------------------------------	

* Main table
esttab men_I men_II women_I women_II ///
	using "$tables\tab5_vocl_hte_onedim.txt" ///
	, nobaselevels nodepvars se r2 b(%8.2f) replace
	

* Appendix table
esttab men_III women_III ///
	using "$tables\tabA2_vocl_hte_onedim_agetrends.txt" ///
	, nobaselevels nodepvars se r2 b(%8.2f) replace	
