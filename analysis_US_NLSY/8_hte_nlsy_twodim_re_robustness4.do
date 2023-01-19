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


log using "$logs/7_hte_nlsy_twodim_re.txt", replace

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

gen xvar = ps_men_rel

* Model linear
	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_rel_linear
	
	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_linear", replace) 


	* Model squared
	xtmixed lnwg c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_rel_squared

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_squared", replace) 
 

	* Model cubic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_rel_cubic

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_cubic", replace)  


	* Model quartic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_rel_quartic

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_quartic", replace)  


	* Model quintiles
	xtile ps_men_quint = ps_men_rel , nquantiles(5)

	xtmixed lnwg ps_men_quint##college c.age_c || id: , mle variance pweight(ipw)
	est store men_rel_quintiles
	
	margins, dydx(college) at (ps_men_quint = (1(1)5)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_quintiles", replace)  


	* Model deciles 
	xtile ps_men_dec = xvar , nquantiles(10)

	xtmixed lnwg ps_men_dec##college c.age_c || id: , mle variance pweight(ipw)
	est store men_rel_deciles
	
	margins, dydx(college) at (ps_men_dec = (1(1)10)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_men_deciles", replace)  

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

gen xvar = ps_women_rel

* Model linear
	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_rel_linear
	
	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_linear", replace) 


	* Model squared
	xtmixed lnwg c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_rel_squared

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_squared", replace) 
 

	* Model cubic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_rel_cubic

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_cubic", replace)  


	* Model quartic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_rel_quartic

	sleep 8000
 
	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_quartic", replace)  


	* Model quintiles
	xtile ps_women_quint = ps_women_rel , nquantiles(5)

	xtmixed lnwg ps_women_quint##college c.age_c || id: , mle variance pweight(ipw)
	est store women_rel_quintiles
	
	sleep 8000

	margins, dydx(college) at (ps_women_quint = (1(1)5)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_quintiles", replace)  


	* Model deciles 
	xtile ps_women_dec = ps_women_rel , nquantiles(10)

	xtmixed lnwg ps_women_dec##college c.age_c || id: , mle variance pweight(ipw)
	est store women_rel_deciles
	
	sleep 8000

	margins, dydx(college) at (ps_women_dec = (1(1)10)) atmeans ///
		saving("$posted/nlsy_hte_margins_rel_women_deciles", replace)  

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

gen xvar = ps_men_irr

* Model linear
	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_irr_linear
	
	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men_linear", replace) 


	* Model squared
	xtmixed lnwg c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_irr_squared

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men_squared", replace) 
 

	* Model cubic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_irr_cubic

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men_cubic", replace)  


	* Model quartic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store men_irr_quartic

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men_quartic", replace)  


	* Model quintiles
	xtile ps_men_quint = ps_men_irr , nquantiles(5)

	xtmixed lnwg ps_men_quint##college c.age_c || id: , mle variance pweight(ipw)
	est store men_irr_quintiles
	
	sleep 8000

	margins, dydx(college) at (ps_men_quint = (1(1)5)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men_quintiles", replace)  


	* Model deciles 
	xtile ps_men_dec = ps_men_irr , nquantiles(10)

	xtmixed lnwg ps_men_dec##college c.age_c || id: , mle variance pweight(ipw)
	est store men_irr_deciles
	
	sleep 8000

	margins, dydx(college) at (ps_men_dec = (1(1)10)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_men_deciles", replace)  

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

*------------------------------------------------------------------------------*
* Random Effects Models
*------------------------------------------------------------------------------*

keep if ps_women_irr!=.

gen xvar = ps_women_irr

* Model linear
	xtmixed lnwg c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_irr_linear
	
	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women_linear", replace) 


	* Model squared
	xtmixed lnwg c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_irr_squared

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women_squared", replace) 
 

	* Model cubic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_irr_cubic

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women_cubic", replace)  


	* Model quartic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##c.xvar##college c.age_c || id: , mle variance pweight(ipw)
	est store women_irr_quartic

	sleep 8000

	margins, dydx(college) at (xvar = (0.0(0.1)0.8)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women_quartic", replace)  


	* Model quintiles
	xtile ps_women_quint = ps_women_irr , nquantiles(5)

	xtmixed lnwg ps_women_quint##college c.age_c || id: , mle variance pweight(ipw)
	est store women_irr_quintiles
	
	sleep 8000

	margins, dydx(college) at (ps_women_quint = (1(1)5)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women_quintiles", replace)  


	* Model deciles 
	xtile ps_women_dec = ps_women_irr , nquantiles(10)

	xtmixed lnwg ps_women_dec##college c.age_c || id: , mle variance pweight(ipw)
	est store women_irr_deciles
	
	sleep 8000

	margins, dydx(college) at (ps_women_dec = (1(1)10)) atmeans ///
		saving("$posted/nlsy_hte_margins_irr_women_deciles", replace)  

restore 


********************************************************************************
* Tables & Graphs 
********************************************************************************

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_linear"	///
	"$posted/nlsy_hte_margins_irr_men_linear", 	///
	label("School-relevant" "School-irrelevant") title("linear") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save men_twodim_linear.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_squared"	///
	"$posted/nlsy_hte_margins_irr_men_squared", 	///
	label("School-relevant" "School-irrelevant") title("squared") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save men_twodim_squared.gph, replace
		
combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_cubic"	///
	"$posted/nlsy_hte_margins_irr_men_cubic", 	///
	label("School-relevant" "School-irrelevant") title("cubic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save men_twodim_cubic.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_quartic"	///
	"$posted/nlsy_hte_margins_irr_men_quartic", 	///
	label("School-relevant" "School-irrelevant") title("quartic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save men_twodim_quartic.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_quintiles"	///
	"$posted/nlsy_hte_margins_irr_men_quintiles", 	///
	label("School-relevant" "School-irrelevant") title("quintiles") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save men_twodim_quintiles.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_men_deciles"	///
	"$posted/nlsy_hte_margins_irr_men_deciles", 	///
	label("School-relevant" "School-irrelevant") title("deciles") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save men_twodim_deciles.gph, replace




combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_linear"	///
	"$posted/nlsy_hte_margins_irr_women_linear", 	///
	label("School-relevant" "School-irrelevant") title("linear") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save women_twodim_linear.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_squared"	///
	"$posted/nlsy_hte_margins_irr_women_squared", 	///
	label("School-relevant" "School-irrelevant") title("squared") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save women_twodim_squared.gph, replace
		
combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_cubic"	///
	"$posted/nlsy_hte_margins_irr_women_cubic", 	///
	label("School-relevant" "School-irrelevant") title("cubic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save women_twodim_cubic.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_quartic"	///
	"$posted/nlsy_hte_margins_irr_women_quartic", 	///
	label("School-relevant" "School-irrelevant") title("quartic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save women_twodim_quartic.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_quintiles"	///
	"$posted/nlsy_hte_margins_irr_women_quintiles", 	///
	label("School-relevant" "School-irrelevant") title("quintiles") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save women_twodim_quintiles.gph, replace

combomarginsplot ///
	"$posted/nlsy_hte_margins_rel_women_deciles"	///
	"$posted/nlsy_hte_margins_irr_women_deciles", 	///
	label("School-relevant" "School-irrelevant") title("deciles") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save women_twodim_deciles.gph, replace


