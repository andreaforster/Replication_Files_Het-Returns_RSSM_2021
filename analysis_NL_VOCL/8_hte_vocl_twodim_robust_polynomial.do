********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Heterogeneous return analysis using two dimensions of propensity
********************************************************************************

* Description

/* This do-file presents a robustness check where we use non-linear 
interaction terms with the propensity score in addition to the linear interaction.
This analysis is mentioned in footnote 9 in the paper  */


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

	keep if ps_men_rel!=.
	gen xvar = ps_men_rel

	* Model linear 
	xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_linear

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_rel_linear", replace)

	* Model squared
	xtmixed lnwg c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_squared

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_rel_squared", replace)
		
	* Model cubic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_cubic

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_rel_cubic", replace)
		
	* Model quartic
	xtmixed lnwg c.xvar##cc.xvar##cc.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_quartic

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_rel_quartic", replace)
		
	* Model quintiles
	xtile ps_men_quint = ps_men_rel , nquantiles(5)

	xtmixed lnwg ps_men_quint##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_quintiles

	margins, dydx(tertiary) at (ps_men_quint = (1(1)5)) atmeans ///
		saving("$posted/vocl_margins_men_rel_quintiles", replace)

	* Model deciles
	xtile ps_men_dec = ps_men_rel , nquantiles(10)

	xtmixed lnwg ps_men_dec##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_rel_deciles

	margins, dydx(tertiary) at (ps_men_dec = (1(1)5)) atmeans ///
		saving("$posted/vocl_margins_men_rel_deciles", replace)
		
restore 

********************************************************************************
* Men - School-irrelevant
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------
preserve 

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

	keep if ps_men_irr!=.
	gen xvar = ps_men_irr

	* Model linear 
	xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_linear

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_irr_linear", replace)

	* Model squared
	xtmixed lnwg c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_squared

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_irr_squared", replace)
		
	* Model cubic
	xtmixed lnwg c.xvar##c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_cubic

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_irr_cubic", replace)
		
	* Model quartic
	xtmixed lnwg c.xvar##cc.xvar##cc.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_quartic

	margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
		saving("$posted/vocl_margins_men_irr_quartic", replace)
		
	* Model quintiles
	xtile ps_men_quint = ps_men_irr, nquantiles(5)

	xtmixed lnwg ps_men_quint##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_quintiles

	margins, dydx(tertiary) at (ps_men_quint = (1(1)5)) atmeans ///
		saving("$posted/vocl_margins_men_irr_quintiles", replace)

	* Model deciles
	xtile ps_men_dec = ps_men_irr, nquantiles(10)

	xtmixed lnwg ps_men_dec##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_irr_deciles

	margins, dydx(tertiary) at (ps_men_dec = (1(1)5)) atmeans ///
		saving("$posted/vocl_margins_men_irr_deciles", replace)
	
restore 


********************************************************************************
* Women - School-relevant
********************************************************************************

*-------------------------------------------------------------------------------
* Common Support Restriction
*-------------------------------------------------------------------------------
preserve 


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

keep if ps_women_rel!=.
gen xvar = ps_women_rel

* Model linear 
xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_rel_linear

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_rel_linear", replace)

* Model squared
xtmixed lnwg c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_rel_squared

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_rel_squared", replace)
	
* Model cubic
xtmixed lnwg c.xvar##c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_rel_cubic

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_rel_cubic", replace)
	
* Model quartic
xtmixed lnwg c.xvar##cc.xvar##cc.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_rel_quartic

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_rel_quartic", replace)
	
* Model quintiles
xtile ps_women_quint = ps_women_rel , nquantiles(5)

xtmixed lnwg ps_women_quint##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_rel_quintiles

margins, dydx(tertiary) at (ps_women_quint = (1(1)5)) atmeans ///
	saving("$posted/vocl_margins_women_rel_quintiles", replace)

* Model deciles
xtile ps_women_dec = ps_women_rel , nquantiles(10)

xtmixed lnwg ps_women_dec##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_rel_deciles

margins, dydx(tertiary) at (ps_women_dec = (1(1)5)) atmeans ///
	saving("$posted/vocl_margins_women_rel_deciles", replace)
	
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

keep if ps_women_irr!=.
gen xvar = ps_women_irr

* Model linear 
xtmixed lnwg c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_irr_linear

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_irr_linear", replace)

* Model squared
xtmixed lnwg c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_irr_squared

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_irr_squared", replace)
	
* Model cubic
xtmixed lnwg c.xvar##c.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_irr_cubic

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_irr_cubic", replace)
	
* Model quartic
xtmixed lnwg c.xvar##cc.xvar##cc.xvar##c.xvar##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_irr_quartic

margins, dydx(tertiary) at (xvar = (0(0.1)0.8)) atmeans ///
	saving("$posted/vocl_margins_women_irr_quartic", replace)
	
* Model quintiles
xtile ps_women_quint = ps_women_irr , nquantiles(5)

xtmixed lnwg ps_women_quint##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_irr_quintiles

margins, dydx(tertiary) at (ps_women_quint = (1(1)5)) atmeans ///
	saving("$posted/vocl_margins_women_irr_quintiles", replace)

* Model deciles
xtile ps_women_dec = ps_women_irr , nquantiles(10)

xtmixed lnwg ps_women_dec##tertiary c.age_c || rin: , mle variance pweight(ipw)
est store women_irr_deciles

margins, dydx(tertiary) at (ps_women_dec = (1(1)5)) atmeans ///
	saving("$posted/vocl_margins_women_irr_deciles", replace)
	
restore 

*-------------------------------------------------------------------------------
* Combined tables and Graphs
*-------------------------------------------------------------------------------	

* MEN
combomarginsplot ///
	"$posted/vocl_margins_men_rel_linear"	///
	"$posted/vocl_margins_men_irr_linear", 	///
	label("School-relevant" "School-irrelevant") title("linear") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/men_twodim_linear.gph", replace
	
combomarginsplot ///
	"$posted/vocl_margins_men_rel_squared"	///
	"$posted/vocl_margins_men_irr_squared", 	///
	label("School-relevant" "School-irrelevant") title("squared") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/men_twodim_squared.gph", replace

combomarginsplot ///
	"$posted/vocl_margins_men_rel_cubic"	///
	"$posted/vocl_margins_men_irr_cubic", 	///
	label("School-relevant" "School-irrelevant") title("cubic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/men_twodim_cubic.gph", replace
		
combomarginsplot ///
	"$posted/vocl_margins_men_rel_quartic"	///
	"$posted/vocl_margins_men_irr_quartic", 	///
	label("School-relevant" "School-irrelevant") title("quartic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/men_twodim_quartic.gph", replace

combomarginsplot ///
	"$posted/vocl_margins_men_rel_quintiles"	///
	"$posted/vocl_margins_men_irr_quintiles", 	///
	label("School-relevant" "School-irrelevant") title("quintiles") ///
	ytitle("Return to College") ///
	xtitle("Quintiles Propensity Score") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/men_twodim_quintiles.gph", replace

combomarginsplot ///
	"$posted/vocl_margins_men_rel_deciles"	///
	"$posted/vocl_margins_men_irr_deciles", 	///
	label("School-relevant" "School-irrelevant") title("quartic") ///
	ytitle("Return to College") ///
	xtitle("Deciles Propensity Score") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/men_twodim_deciles.gph", replace


* WOMEN
combomarginsplot ///
	"$posted/vocl_margins_women_rel_linear"	///
	"$posted/vocl_margins_women_irr_linear", 	///
	label("School-relevant" "School-irrelevant") title("linear") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/women_twodim_linear.gph", replace
	
combomarginsplot ///
	"$posted/vocl_margins_women_rel_squared"	///
	"$posted/vocl_margins_women_irr_squared", 	///
	label("School-relevant" "School-irrelevant") title("squared") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/women_twodim_squared.gph", replace

combomarginsplot ///
	"$posted/vocl_margins_women_rel_cubic"	///
	"$posted/vocl_margins_women_irr_cubic", 	///
	label("School-relevant" "School-irrelevant") title("cubic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/women_twodim_cubic.gph", replace
		
combomarginsplot ///
	"$posted/vocl_margins_women_rel_quartic"	///
	"$posted/vocl_margins_women_irr_quartic", 	///
	label("School-relevant" "School-irrelevant") title("quartic") ///
	ytitle("Return to College") ///
	xtitle("Propensity of College") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/women_twodim_quartic.gph", replace

combomarginsplot ///
	"$posted/vocl_margins_women_rel_quintiles"	///
	"$posted/vocl_margins_women_irr_quintiles", 	///
	label("School-relevant" "School-irrelevant") title("quintiles") ///
	ytitle("Return to College") ///
	xtitle("Quintiles Propensity Score") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/women_twodim_quintiles.gph", replace

combomarginsplot ///
	"$posted/vocl_margins_women_rel_deciles"	///
	"$posted/vocl_margins_women_irr_deciles", 	///
	label("School-relevant" "School-irrelevant") title("quartic") ///
	ytitle("Return to College") ///
	xtitle("Deciles Propensity Score") ///
	yscale(range(-1(0.5)1)) ylabel(-1(0.5)1) legend(pos(1) col(2)) ///
	aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise)) ///
		plot2opts(lcolor(orangebrown) lpattern(_) mcolor(orangebrown) msymbol(S)) ///
		ci2opts(lcolor(orangebrown))

graph save "$graphs/women_twodim_deciles.gph", replace


********************************************************************************
* Combined graphs two dimensions 
********************************************************************************

	graph combine "$graphs/men_twodim_linear.gph" ///
		"$graphs/men_twodim_squared.gph" /// 
		"$graphs/men_twodim_cubic.gph" ///
		"$graphs/men_twodim_quartic.gph" ///
		"$graphs/men_twodim_quintiles.gph" ///
		"$graphs/men_twodim_deciles.gph"

	graph export "$graphs/vocl_polynomial_twodim_men.pdf", replace

	graph combine "$graphs/women_twodim_linear.gph" ///
		"$graphs/women_twodim_squared.gph" /// 
		"$graphs/women_twodim_cubic.gph" ///
		"$graphs/women_twodim_quartic.gph" ///
		"$graphs/women_twodim_quintiles.gph" ///
		"$graphs/women_twodim_deciles.gph" 

	graph export "$graphs/vocl_polynomial_twodim_women.pdf",replace