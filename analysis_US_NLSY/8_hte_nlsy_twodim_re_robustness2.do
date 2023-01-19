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


log using "$logs/8_hte_nlsy_twodim_re_robustness2.txt", replace

use "$posted/nlsy_pooled_data_hte_resid.dta", clear

********************************************************************************
* Men - School-relevant
********************************************************************************

*-------------------------------------------------------------------------------
* Restrict to Area of Common Support
*-------------------------------------------------------------------------------

preserve

sum ps_men_rel if college==0, detail
local min0_men = r(min)
local max0_men = r(max)

sum ps_men_rel if college==1, detail
local min1_men = r(min)
local max1_men = r(max)

gen low_men = `min1_men'
replace low_men =`min0_men' if `min0_men' > `min1_men'

gen hi_men = `max0_men'
replace hi_men = `max1_men' if `max0_men' > `max1_men'

drop if ps_men_rel < low_men & ps_men_rel!=. // 89 missing
drop if ps_men_rel > hi_men & ps_men_rel!=. // 10 missing

drop hi_men low_men

*------------------------------------------------------------------------------*
* Random Effects Models
*------------------------------------------------------------------------------*

keep if ps_men_rel!=.

* Empty Model
xtmixed lnwg || id:, mle variance
xtmrho

* Model I
xtmixed lnwg c.ps_men_rel college c.age_c || id: , mle variance pweight(ipw)
est store men_rel_I

* Model II
xtmixed lnwg c.ps_men_rel##college c.age_c || id: , mle variance pweight(ipw)
est store men_rel_II

	* Marginal Effects Plot for Model II

	gen xvar = ps_men_rel

	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)

	sleep 8000

	margins, dydx(college) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_resid", replace)
	
	sleep 8000

restore 

********************************************************************************
* Women - School-relevant
********************************************************************************

*-------------------------------------------------------------------------------
* Restrict to Area of Common Support
*-------------------------------------------------------------------------------
preserve 

sum ps_women_rel if college==0, detail
local min0_women = r(min)
local max0_women = r(max)

sum ps_women_rel if college==1, detail
local min1_women = r(min)
local max1_women = r(max)

gen low_women = `min1_women'
replace low_women =`min0_women' if `min0_women' > `min1_women'

gen hi_women = `max0_women'
replace hi_women = `max1_women' if `max0_women' > `max1_women'

drop if ps_women_rel < low_women & ps_women_rel!=. // 40 missing
drop if ps_women_rel > hi_women & ps_women_rel!=. // 3 missing

*------------------------------------------------------------------------------*
* Random Effects Models
*------------------------------------------------------------------------------*

keep if ps_women_rel!=.

* Empty Model
xtmixed lnwg || id:, mle variance
xtmrho

* Model I
xtmixed lnwg c.ps_women_rel college c.age_c || id: , mle variance pweight(ipw)
est store women_rel_I

* Model II
xtmixed lnwg c.ps_women_rel##college c.age_c || id: , mle variance pweight(ipw)
est store women_rel_II

	* Marginal Effects Plot for Model II
	gen xvar = ps_women_rel

	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)

	sleep 8000

	margins, dydx(college) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_resid", replace)

	sleep 8000

restore 

********************************************************************************
* Men - School-irrelevant
********************************************************************************

*-------------------------------------------------------------------------------
* Restrict to Area of Common support
*-------------------------------------------------------------------------------

preserve

sum ps_men_irr if college==0, detail
local min0_men = r(min)
local max0_men = r(max)

sum ps_men_irr if college==1, detail
local min1_men = r(min)
local max1_men = r(max)

gen low_men = `min1_men'
replace low_men =`min0_men' if `min0_men' > `min1_men'

gen hi_men = `max0_men'
replace hi_men = `max1_men' if `max0_men' > `max1_men'

drop if ps_men_irr < low_men & ps_men_irr!=. // 29 missing
drop if ps_men_irr > hi_men & ps_men_irr!=. // 2 missing

*------------------------------------------------------------------------------*
* Random Effects Models
*------------------------------------------------------------------------------*

keep if ps_men_irr!=.

* Empty Model
xtmixed lnwg || id:, mle variance
xtmrho

* Model I
xtmixed lnwg c.ps_men_irr college c.age_c || id: , mle variance pweight(ipw)
est store men_irr_I

* Model II
xtmixed lnwg c.ps_men_irr##college c.age_c || id: , mle variance pweight(ipw)
est store men_irr_II

	* Marginal Effects Plot for Model II 

	gen xvar = ps_men_irr

	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)

	sleep 8000

	margins, dydx(college) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men", replace)

	sleep 8000

	marginsplot, ///
		title("") yscale(range(-0.4(0.2)0.9)) ylabel(-0.4(0.2)0.9) ///
		ytitle("Return to College") xtitle("Propensity of College (School-irrelevant)") 

		graph export "$robust/nlsy_hte_margins_irr_men_robustness2.pdf", replace

* Model III (Appendix)
xtmixed lnwg c.ps_men_irr##college##c.age_c || id: , mle variance pweight(ipw)
est store men_irr_III

restore 

********************************************************************************
* Women School-irrelevant
********************************************************************************

*-------------------------------------------------------------------------------
* Restrict to Area of Common Support
*-------------------------------------------------------------------------------
preserve 
sum ps_women_irr if college==0, detail
local min0_women = r(min)
local max0_women = r(max)

sum ps_women_irr if college==1, detail
local min1_women = r(min)
local max1_women = r(max)

gen low_women = `min1_women'
replace low_women =`min0_women' if `min0_women' > `min1_women'

gen hi_women = `max0_women'
replace hi_women = `max1_women' if `max0_women' > `max1_women'

drop if ps_women_irr < low_women & ps_women_irr!=. // 18 missing
drop if ps_women_irr > hi_women & ps_women_irr!=. // 5 missing

*-------------------------------------------------------------------------------
* Random Effects Models
*-------------------------------------------------------------------------------

keep if ps_women_irr!=.

* Empty Model 
xtmixed lnwg || id:, mle variance
xtmrho

* Model I
xtmixed lnwg c.ps_women_irr college c.age_c || id: , mle variance pweight(ipw)
est store women_irr_I

* Model II 
xtmixed lnwg c.ps_women_irr##college c.age_c || id: , mle variance pweight(ipw)
est store women_irr_II
	
	* Marginal Effects Plot for Model II

	gen xvar = ps_women_irr

	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)

	sleep 8000

	margins, dydx(college) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women", replace)

	sleep 8000

	marginsplot, ///
		title("") yscale(range(-0.4(0.2)0.9)) ylabel(-0.4(0.2)0.9) ///
		ytitle("Return to College") xtitle("Propensity of College (School-irrelevant)") 

		graph export "$robust/nlsy_hte_margins_irr_women_robustness2.pdf", replace

* Model III (Appendix)
xtmixed lnwg c.ps_women_irr##college##c.age_c || id: , mle variance pweight(ipw)
est store women_irr_III  

restore


********************************************************************************
* Tables & Graphs 
********************************************************************************

* Main Text
esttab men_rel_I men_rel_II women_rel_I women_rel_II ///
	using "$robust/nlsy_hte_rel_re_resid_robustness2.rtf" ///
	, nobaselevels label nodepvars se r2 replace 

esttab men_irr_I men_irr_II women_irr_I women_irr_II ///
	using "$robust/nlsy_hte_irr_re_robustness2.rtf" ///
	, nobaselevels label nodepvars se r2 replace  


combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_resid"	///
	"$posted/nlsy_hte_margins_irr_men", 	///
	label("School-relevant" "School-irrelevant") title("") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College (School-relevant/School-irrelevant)") ///
	yscale(range(-0.4(0.2)0.9)) ylabel(-0.4(0.2)0.9) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save twodim_men_robustness2.gph, replace

graph export "$robust/nlsy_hte_margins_twodim_men_robustness2.pdf", replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_resid"	///
	"$posted/nlsy_hte_margins_irr_women", 	///
	label("School-relevant" "School-irrelevant") title("") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College (School-relevant/School-irrelevant)") ///
	yscale(range(-0.4(0.2)0.9)) ylabel(-0.4(0.2)0.9) legend(pos(1) col(2)) ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save twodim_women_robustness2.gph, replace

graph export "$robust/nlsy_hte_margins_twodim_women_resid_robustness2.pdf", replace

		
