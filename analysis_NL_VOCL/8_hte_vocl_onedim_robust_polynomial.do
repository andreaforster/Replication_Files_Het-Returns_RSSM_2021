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
	* Random Effects Models Polynomials
	*-------------------------------------------------------------------------------

	* Model linear
	xtmixed lnwg c.ps_men##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_linear
	estat ic

	margins, dydx(tertiary) at (ps_men = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("linear") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/linear_onedim_men.gph", replace

	* Model squared
	xtmixed lnwg c.ps_men##c.ps_men##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_squared
	estat ic

	margins, dydx(tertiary) at (ps_men = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("squared") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/squared_onedim_men.gph", replace

	* Model cubic
	xtmixed lnwg c.ps_men##c.ps_men##c.ps_men##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_cubic
	estat ic

	margins, dydx(tertiary) at (ps_men = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("cubic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/cubic_onedim_men.gph", replace

	* Model quartic
	xtmixed lnwg c.ps_men##c.ps_men##c.ps_men##c.ps_men##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_quartic
	estat ic

	margins, dydx(tertiary) at (ps_men = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("quartic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/quartic_onedim_men.gph", replace

		


	*-------------------------------------------------------------------------------
	* Random-effects Models with Bins
	*-------------------------------------------------------------------------------
		
	* Model quintiles

	sum ps_men, detail
		
	xtile ps_men_quint = ps_men , nquantiles(5)

	xtmixed lnwg c.ps_men_quint##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_quintiles
	estat ic

	margins, dydx(tertiary) at (ps_men_quint = (1(1)5)) atmeans

	marginsplot, ///
		title("quintiles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Quintiles Propensity Score") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/quintiles_onedim_men.gph", replace
		
		
	* Model deciles

	sum ps_men, detail
		
	xtile ps_men_dec = ps_men , nquantiles(10)

	xtmixed lnwg c.ps_men_dec##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store men_deciles
	estat ic

	margins, dydx(tertiary) at (ps_men_dec = (1(1)10)) atmeans

	marginsplot, ///
		title("deciles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Deciles Propensity Score") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/deciles_onedim_men.gph", replace
	
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
	* Random Effects Models Polynomials
	*-------------------------------------------------------------------------------

	* Model linear
	xtmixed lnwg c.ps_women##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_linear
	estat ic

	margins, dydx(tertiary) at (ps_women = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("linear") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/linear_onedim_women.gph", replace

	* Model squared
	xtmixed lnwg c.ps_women##c.ps_women##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_squared
	estat ic

	margins, dydx(tertiary) at (ps_women = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("squared") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/squared_onedim_women.gph", replace

	* Model cubic
	xtmixed lnwg c.ps_women##c.ps_women##c.ps_women##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_cubic
	estat ic

	margins, dydx(tertiary) at (ps_women = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("cubic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/cubic_onedim_women.gph", replace

	* Model quartic
	xtmixed lnwg c.ps_women##c.ps_women##c.ps_women##c.ps_women##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_quartic
	estat ic

	margins, dydx(tertiary) at (ps_women = (0(0.1)0.8)) atmeans

	marginsplot, ///
		title("quartic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Propensity of College") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/quartic_onedim_women.gph", replace

	*-------------------------------------------------------------------------------
	* Random-effects Models with Bins
	*-------------------------------------------------------------------------------
		
	* Model quintiles

	sum ps_women, detail
		
	xtile ps_women_quint = ps_women , nquantiles(5)

	xtmixed lnwg c.ps_women_quint##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_quintiles
	estat ic

	margins, dydx(tertiary) at (ps_women_quint = (1(1)5)) atmeans

	marginsplot, ///
		title("quintiles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Quintiles Propensity Score") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/quintiles_onedim_women.gph", replace
		
		
	* Model deciles

	sum ps_women, detail
		
	xtile ps_women_dec = ps_women , nquantiles(10)

	xtmixed lnwg c.ps_women_dec##tertiary c.age_c || rin: , mle variance pweight(ipw)
	est store women_deciles
	estat ic


	margins, dydx(tertiary) at (ps_women_dec = (1(1)10)) atmeans

	marginsplot, ///
		title("deciles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
		ytitle("Return to College") ///
		xtitle("Deciles Propensity Score") ///
		aspectratio(1) ///
		plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
		ci1opts(lcolor(turquoise))
			
		graph save "$graphs/deciles_onedim_women.gph", replace
	 
		
restore

********************************************************************************
* Combined graphs one dimension
********************************************************************************

	graph combine "$graphs/linear_onedim_men.gph" ///
		"$graphs/squared_onedim_men.gph" ///
		"$graphs/cubic_onedim_men.gph" /// 
		"$graphs/quartic_onedim_men.gph" ///
		"$graphs/quintiles_onedim_men.gph" ///
		"$graphs/deciles_onedim_men.gph"

		graph export "$graphs/vocl_polynomial_onedim_men.pdf", replace


	graph combine "$graphs/linear_onedim_women.gph" ///
		"$graphs/squared_onedim_women.gph" ///
		"$graphs/cubic_onedim_women.gph" /// 
		"$graphs/quartic_onedim_women.gph" ///
		"$graphs/quintiles_onedim_women.gph" ///
		"$graphs/deciles_onedim_women.gph"

		graph export "$graphs/vocl_polynomial_onedim_women.pdf", replace

