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

use "$posted/nlsy_pooled_data_hte_resid.dta", clear


********************************************************************************
* Men
********************************************************************************

preserve
keep if ps_men!=.

*-------------------------------------------------------------------------------
* Restrict to Area of Common Support
*-------------------------------------------------------------------------------

sum ps_men if college==0, detail
local min0_men = r(min)
local max0_men = r(max)

sum ps_men if college==1, detail
local min1_men = r(min)
local max1_men = r(max)

gen low_men = `min1_men'
replace low_men =`min0_men' if `min0_men' > `min1_men'

gen hi_men = `max0_men'
replace hi_men = `max1_men' if `max0_men' > `max1_men'

drop if ps_men < low_men & ps_men!=.
drop if ps_men > hi_men & ps_men!=. 

*-------------------------------------------------------------------------------
* Random-effects Models
*-------------------------------------------------------------------------------

* Empty Model
xtmixed lnwg || id:, mle variance pweight(ipw)
xtmrho

* Model I
xtmixed lnwg c.ps_men college c.age_c || id: , mle variance pweight(ipw)
est store men_I

* Model II
xtmixed lnwg c.ps_men##college c.age_c || id: , mle variance pweight(ipw)
est store men_II

	* Marginal Effects Plot of Model II
	margins, dydx(college) at (ps_men = (0.0(0.1)0.8)) atmeans 

	marginsplot, ///
		title("") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))

		graph save onedim_men_robustness3.gph, replace

		graph export "$robust/nlsy_hte_margins_men_robustness3.pdf", replace


restore 

********************************************************************************
* Women
********************************************************************************

*-------------------------------------------------------------------------------
* Restrict to Area of Common Support
*-------------------------------------------------------------------------------

preserve

keep if ps_women!=.

sum ps_women if college==0, detail
local min0_women = r(min)
local max0_women = r(max)

sum ps_women if college==1, detail
local min1_women = r(min)
local max1_women = r(max)

gen low_women = `min1_women'
replace low_women =`min0_women' if `min0_women' > `min1_women'

gen hi_women = `max0_women'
replace hi_women = `max1_women' if `max0_women' > `max1_women'

drop if ps_women < low_women & ps_women!=. 
drop if ps_women > hi_women & ps_women!=. 

*-------------------------------------------------------------------------------
* Random-effects Models 
*-------------------------------------------------------------------------------

* Empty Model
xtmixed lnwg || id:, mle variance
xtmrho

* Model I
xtmixed lnwg c.ps_women college age_c || id: , mle variance pweight(ipw)
est store women_I

* Model II
xtmixed lnwg c.ps_women##college age_c || id: , mle variance pweight(ipw)
est store women_II

	* Marginal Effects Plot for Model II

	margins, dydx(college) at (ps_women = (0(0.1)0.8)) atmeans 
	
	marginsplot, ///
		title("") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))

		graph save onedim_women_robustness3.gph, replace

		graph export "$robust/nlsy_hte_margins_women_robustness3.pdf", replace


restore 

*------------------------------------------------------------------------------*
* Tables
*------------------------------------------------------------------------------*

* Main Table 
esttab men_I men_II women_I women_II ///
	using "$robust/nlsy_hte_onedimension=_robustness3.tex" ///
	, nobaselevels label nodepvars se r2 replace ///
	transform(ln*: exp(2*@) 2*exp(2*@)) ///
   eqlabels("" "var(_cons)" "var(Residual)", none) 
   */


