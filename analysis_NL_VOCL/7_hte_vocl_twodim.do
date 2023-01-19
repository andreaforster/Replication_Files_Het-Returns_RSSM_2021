********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Heterogeneous return analysis using two dimensions of propensity
********************************************************************************

* Description

/* This do-file carries out the heterogeneous return analysis for two dimensions
of propensity. First, the data is restricted to the are of common support.
Then random effects models are carried out and marginal effects plots are
produced for Figure 1 in the paper. The analysis is carried out separately for men and 
women and for school-relevant and -irrelevant propensity. 
Finally, combined tables are created that are the basis for table 6 and table 7 in
the paper.  */


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
* Men - School-relevant
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------
preserve 

	keep if ps_men_rel!=.

	sum ps_men_rel if tertiary==0, detail
	local min0_men = r(min)
	local max0_men = r(max)

	sum ps_men_rel if tertiary==1, detail
	local min1_men = r(min)
	local max1_men = r(max)

	gen low_men = `min1_men' 
	replace low_men = `min0_men' if `min0_men' > `min1_men' 

	gen hi_men = `max0_men' 
	replace hi_men = `max1_men' if `max0_men' > `max1_men' 

	drop if ps_men_rel < low_men & ps_men_rel !=. // 25 missing
	drop if ps_men_rel > hi_men & ps_men_rel !=. // 3 missing

	*-------------------------------------------------------------------------------
	* Random Effects Models
	*-------------------------------------------------------------------------------

	* Model I
	xtmixed lnwg c.ps_men_rel tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_I

	* Model II
	xtmixed lnwg c.ps_men_rel##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_II

	/* Generate margins from Model II (we rename the propensity score 
	variable as we later want to plot the school-irrelevant and -relevant 
	characteristics on the same x-axis) */
	gen xvar = ps_men_rel 
	xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
			saving("$posted/vocl_margins_men_rel", replace)

restore 

********************************************************************************
* Women - School-relevant
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------
preserve 

	keep if ps_women_rel!=.

	sum ps_women_rel if tertiary==0, detail
	local min0_women = r(min)
	local max0_women = r(max)

	sum ps_women_rel if tertiary==1, detail
	local min1_women = r(min)
	local max1_women = r(max)

	gen low_women = `min1_women' 
	replace low_women = `min0_women' if `min0_women' > `min1_women' 

	gen hi_women = `max0_women' 
	replace hi_women = `max1_women' if `max0_women' > `max1_women' 

	drop if ps_women_rel < low_women & ps_women_rel !=. // 480 missing
	drop if ps_women_rel > hi_women & ps_women_rel !=. // 72 missing

	*-------------------------------------------------------------------------------
	* Random Effects Models
	*-------------------------------------------------------------------------------

	* Model I
	xtmixed lnwg c.ps_women_rel tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_rel_I

	* Model II
	xtmixed lnwg c.ps_women_rel##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_rel_II

	/* Generate margins from Model II (we rename the propensity score 
	variable as we later want to plot the school-irrelevant and -relevant 
	characteristics on the same x-axis) */
	gen xvar = ps_women_rel

	xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
			saving("$posted/vocl_margins_women_rel", replace)

restore 

********************************************************************************
* Men - School-irrelevant
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------
preserve 

	keep if ps_men_irr!=.

	sum ps_men_irr if tertiary==0, detail
	local min0_men = r(min)
	local max0_men = r(max)

	sum ps_men_irr if tertiary==1, detail
	local min1_men = r(min)
	local max1_men = r(max)

	gen low_men = `min1_men' 
	replace low_men = `min0_men' if `min0_men' > `min1_men' 

	gen hi_men = `max0_men' 
	replace hi_men = `max1_men' if `max0_men' > `max1_men' 

	drop if ps_men_irr < low_men & ps_men_irr !=. // 120 missing
	drop if ps_men_irr > hi_men & ps_men_irr !=. // 60 missing

	*-------------------------------------------------------------------------------
	* Random Effects Models
	*-------------------------------------------------------------------------------

	* Model I
	xtmixed lnwg c.ps_men_irr tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_I

	* Model II
	xtmixed lnwg c.ps_men_irr##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_II
		
	/* Generate margins from Model II (we rename the propensity score 
	variable as we later want to plot the school-irrelevant and -relevant 
	characteristics on the same x-axis) */

	gen xvar = ps_men_irr

	xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
			saving("$posted/vocl_margins_men_irr", replace)

restore 

********************************************************************************
* Women - School-irrelevant
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------
preserve 

	keep if ps_women_irr!=.

	sum ps_women_irr if tertiary==0, detail
	local min0_women = r(min)
	local max0_women = r(max)

	sum ps_women_irr if tertiary==1, detail
	local min1_women = r(min)
	local max1_women = r(max)

	gen low_women = `min1_women' 
	replace low_women = `min0_women' if `min0_women' > `min1_women' 

	gen hi_women = `max0_women' 
	replace hi_women = `max1_women' if `max0_women' > `max1_women' 

	drop if ps_women_irr < low_women & ps_women_irr !=. // 132 missing
	drop if ps_women_irr > hi_women & ps_women_irr !=. // 12 missing

	*-------------------------------------------------------------------------------
	* Random Effects Models
	*-------------------------------------------------------------------------------

	* Model I
	xtmixed lnwg c.ps_women_irr tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_irr_I

	* Model II
	xtmixed lnwg c.ps_women_irr##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_irr_II

	/* Generate margins from Model II (we rename the propensity score 
	variable as we later want to plot the school-irrelevant and -relevant 
	characteristics on the same x-axis) */

	gen xvar = ps_women_irr

	xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
			saving("$posted/vocl_margins_women_irr", replace)

restore 

*-------------------------------------------------------------------------------
* Combined tables and Graphs
*-------------------------------------------------------------------------------	
	
esttab men_rel_I men_rel_II women_rel_I women_rel_II ///
	using "$tables\tab6_vocl_hte_rel.txt" ///
	, nobaselevels nodepvars se r2 b(%8.2f) replace 

esttab men_irr_I men_irr_II women_irr_I women_irr_II ///
	using "$tables\tab7_vocl_hte_irr.txt" ///
		, nobaselevels nodepvars se r2 b(%8.2f) replace 
	
	
combomarginsplot ///
	"$posted/vocl_margins_men_rel" ///
	"$posted/vocl_margins_men_irr", ///
	label("School-relevant" "School-irrelevant") title("") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College (School-relevant/School-irrelevant)") ///
	yscale(range(-0.4(0.2)1.1)) ylabel(-0.4(0.2)1.1) ///
	legend(pos(1) col(2)) 		///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph export "$graphs/fig2_vocl_men_twodim.pdf", replace
	
combomarginsplot ///
	"$posted/vocl_margins_women_rel" ///
	"$posted/vocl_margins_women_irr", ///
	label("School-relevant" "School-irrelevant") title("") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College (School-relevant/School-irrelevant)") ///
	yscale(range(-0.4(0.2)1.1)) ylabel(-0.4(0.2)1.1) ///
	legend(pos(1) col(2)) ///
	aspectratio(1) ///
	plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
	ci1opts(lcolor(turquoise)) ///
	plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
	ci2opts(lcolor(orangebrown))
	
	graph export "$graphs/fig2_vocl_women_twodim.pdf", replace
