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
	log using "$logs/6_hte_nlsy_onedim_re.txt", replace

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
	* Random-effects Models Polynomials
	*-------------------------------------------------------------------------------

		* Model linear
		xtmixed lnwg c.ps_men##college c.age_c || id: , mle variance pweight(ipw)
		est store men_linear
		estat ic
		margins, dydx(college) at (ps_men = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("linear") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save linear_men.gph, replace

		* Model squared
		xtmixed lnwg c.ps_men##c.ps_men##college c.age_c || id: , mle variance pweight(ipw)
		est store men_squared
		estat ic
		margins, dydx(college) at (ps_men = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("squared") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save squared_men.gph, replace

		* Model cubic
		xtmixed lnwg c.ps_men##c.ps_men##c.ps_men##college c.age_c || id: , mle variance pweight(ipw)
		est store men_cubic
		estat ic
		margins, dydx(college) at (ps_men = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("cubic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save cubic_men.gph, replace

		* Model quartic
		xtmixed lnwg c.ps_men##c.ps_men##c.ps_men##c.ps_men##college c.age_c || id: , mle variance pweight(ipw)
		est store men_quartic
		estat ic
		margins, dydx(college) at (ps_men = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("quartic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save quartic_men.gph, replace


	*-------------------------------------------------------------------------------
	* Random-effects Models with Bins
	*-------------------------------------------------------------------------------
		
		* Model quintiles 

		sum ps_men, detail
		
		xtile ps_men_quint = ps_men , nquantiles(5)

		xtmixed lnwg ps_men_quint##college c.age_c || id: , mle variance pweight(ipw)
		est store men_quintiles
		estat ic
		margins, dydx(college) at (ps_men_quint = (1(1)5)) atmeans 

		marginsplot, ///
			title("quintiles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Quintiles Propensity Score") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save quintiles_men.gph, replace

		* Model deciles 

		sum ps_men, detail
		
		xtile ps_men_dec = ps_men , nquantiles(10)

		xtmixed lnwg ps_men_dec##college c.age_c || id: , mle variance pweight(ipw)
		est store men_deciles
		estat ic
		margins, dydx(college) at (ps_men_dec = (1(1)10)) atmeans 

		marginsplot, ///
			title("deciles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Deciles Propensity Score") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise))

			graph save deciles_men.gph, replace

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
	* Random-effects Models Polynomials
	*-------------------------------------------------------------------------------

		* Model linear
		xtmixed lnwg c.ps_women##college c.age_c || id: , mle variance pweight(ipw)
		est store women_linear
		estat ic
		margins, dydx(college) at (ps_women = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("linear") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save linear_women.gph, replace

		* Model squared
		xtmixed lnwg c.ps_women##c.ps_women##college c.age_c || id: , mle variance pweight(ipw)
		est store women_squared
		estat ic
		margins, dydx(college) at (ps_women = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("squared") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save squared_women.gph, replace

		* Model cubic
		xtmixed lnwg c.ps_women##c.ps_women##c.ps_women##college c.age_c || id: , mle variance pweight(ipw)
		est store women_cubic
		estat ic
		margins, dydx(college) at (ps_women = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("cubic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save cubic_women.gph, replace

		* Model quartic
		xtmixed lnwg c.ps_women##c.ps_women##c.ps_women##c.ps_women##college c.age_c || id: , mle variance pweight(ipw)
		est store women_quartic
		estat ic
		margins, dydx(college) at (ps_women = (0.0(0.1)0.8)) atmeans 

		marginsplot, ///
			title("quartic") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Propensity of College") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save quartic_women.gph, replace


	*-------------------------------------------------------------------------------
	* Random-effects Models with Bins
	*-------------------------------------------------------------------------------
		
		* Model quintiles 

		sum ps_women, detail
		
		xtile ps_women_quint = ps_women , nquantiles(5)

		xtmixed lnwg ps_women_quint##college c.age_c || id: , mle variance pweight(ipw)
		est store women_quintiles
		estat ic
		margins, dydx(college) at (ps_women_quint = (1(1)5)) atmeans 

		marginsplot, ///
			title("quintiles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Quintiles Propensity Score") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise)) 

			graph save quintiles_women.gph, replace

		* Model deciles 

		sum ps_women, detail
		
		xtile ps_women_dec = ps_women , nquantiles(10)

		xtmixed lnwg ps_women_dec##college c.age_c || id: , mle variance pweight(ipw)
		est store women_deciles
		estat ic
		margins, dydx(college) at (ps_women_dec = (1(1)10)) atmeans 

		marginsplot, ///
			title("deciles") yscale(range(-0.4(0.2)0.8)) ylabel(-0.4(0.2)0.8) ///
			ytitle("Return to College") xtitle("Deciles Propensity Score") ///
			aspectratio(1) ///
			plot1opts(lcolor(turquoise) lpattern(1) mcolor(turquoise) msymbol(O)) ///
			ci1opts(lcolor(turquoise))

			graph save deciles_women.gph, replace

		


	restore 

*------------------------------------------------------------------------------*
* Tables
*------------------------------------------------------------------------------*

* Table men
esttab men_linear men_squared men_cubic men_quartic men_quintiles men_deciles ///
	, nobaselevels label nodepvars se r2 replace ///
	transform(ln*: exp(2*@) 2*exp(2*@)) ///
   eqlabels("" "var(_cons)" "var(Residual)", none) 
   */

* Table women
esttab women_linear women_squared women_cubic women_quartic women_quintiles women_deciles ///
	, nobaselevels label nodepvars se r2 replace ///
	transform(ln*: exp(2*@) 2*exp(2*@)) ///
   eqlabels("" "var(_cons)" "var(Residual)", none) 
   */





