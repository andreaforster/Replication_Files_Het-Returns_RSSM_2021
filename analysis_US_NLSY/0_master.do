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
global old			"C:\Users\andrea\Dropbox\andrea\research\03_papers\2016_het_returns_paper\2018-09 submission to RSSM\04_text\01_graphs" //old graphs
*------------------------------------------------------------------------------*

/********************************************************************************
* Update main analysis (since initial submission)
********************************************************************************

do "$dofiles/1+2_hte_nlsy_dataprep+prepvar_old.do"
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/6_hte_nlsy_onedim_re_old.do"
do "$dofiles/7_hte_nlsy_twodim_re_old.do"*/

********************************************************************************
* Main analysis
********************************************************************************

do "$dofiles/1+2_hte_nlsy_dataprep+prepvar.do"
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/6_hte_nlsy_onedim_re.do"
do "$dofiles/7_hte_nlsy_twodim_re.do"


********************************************************************************
* Robustness check 1: Use year when students are 28 to determine college degree instead of 
* year 1990
********************************************************************************

do "$dofiles/8_hte_nlsy_dataprep+prepvar_robustness1.do" 
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/8_hte_nlsy_onedim_re_robustness1.do"
do "$dofiles/8_hte_nlsy_twodim_re_robustness1.do"

* Graphs one dimension

	graph combine onedim_men.gph onedim_men_robustness1.gph

	graph export "$robust/onedim_men_robustness_check1.pdf", replace

	graph combine onedim_women.gph onedim_women_robustness1.gph

	graph export "$robust/onedim_women_robustness_check1.pdf", replace


* Graphs two dimensions

	graph combine twodim_men.gph twodim_men_robustness1.gph

	graph export "$robust/twodim_men_robustness_check1.pdf", replace

	graph combine twodim_women.gph twodim_women_robustness1.gph

	graph export "$robust/twodim_women_robustness_check1.pdf", replace

********************************************************************************
* Robustness check 2: cap wage variable at between 1 and 100 dollars per hour
********************************************************************************

do "$dofiles/8_hte_nlsy_dataprep+prepvar_robustness2.do" 
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/8_hte_nlsy_onedim_re_robustness2.do"
do "$dofiles/8_hte_nlsy_twodim_re_robustness2.do"


* Graphs one dimension

	graph combine onedim_men.gph onedim_men_robustness2.gph

	graph export "$robust/onedim_men_robustness_check2.pdf", replace

	graph combine onedim_women.gph onedim_women_robustness2.gph

	graph export "$robust/onedim_women_robustness_check2.pdf", replace


* Graphs two dimensions

	graph combine twodim_men.gph twodim_men_robustness2.gph

	graph export "$robust/twodim_men_robustness_check2.pdf", replace

	graph combine twodim_women.gph twodim_women_robustness2.gph

	graph export "$robust/twodim_women_robustness_check2.pdf", replace


*******************************************************************************
* Robustness check 3: deflate wage variable
********************************************************************************

do "$dofiles/8_hte_nlsy_dataprep+prepvar_robustness3.do" 
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/8_hte_nlsy_onedim_re_robustness3.do"
do "$dofiles/8_hte_nlsy_twodim_re_robustness3.do"

* Graphs one dimension

	graph combine onedim_men.gph onedim_men_robustness3.gph

	graph export "$robust/onedim_men_robustness_check3.pdf", replace

	graph combine onedim_women.gph onedim_women_robustness3.gph

	graph export "$robust/onedim_women_robustness_check3.pdf", replace


* Graphs two dimensions

	graph combine twodim_men.gph twodim_men_robustness3.gph

	graph export "$robust/twodim_men_robustness_check3.pdf", replace

	graph combine twodim_women.gph twodim_women_robustness3.gph

	graph export "$robust/twodim_women_robustness_check3.pdf", replace



********************************************************************************
* Robustness check 4: interactions with higher order polynominals and bins
********************************************************************************

do "$dofiles/1+2_hte_nlsy_dataprep+prepvar_final-analysis.do" //Incorporate changes from robustness check 2 and 3 into main analysis
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/8_hte_nlsy_onedim_re_robustness4.do"
do "$dofiles/8_hte_nlsy_twodim_re_robustness4.do"

* Graphs one dimension
	graph combine onedim_men.gph squared_men.gph cubic_men.gph quartic_men.gph ///
		quintiles_men.gph deciles_men.gph

		graph export "$robust/non-linear_interactions_onedim_men.pdf", replace


	graph combine onedim_women.gph squared_women.gph cubic_women.gph quartic_women.gph ///
		quintiles_women.gph deciles_women.gph

		graph export "$robust/non-linear_interactions_onedim_women.pdf", replace

* Graphs two dimensions 

	graph combine men_twodim_linear.gph men_twodim_squared.gph men_twodim_cubic.gph ///
		men_twodim_quartic.gph men_twodim_quintiles.gph men_twodim_deciles.gph 

	graph export "$robust/non-linear_interactions_twodim_men.pdf", replace

	graph combine women_twodim_linear.gph women_twodim_squared.gph women_twodim_cubic.gph ///
	women_twodim_quartic.gph women_twodim_quintiles.gph women_twodim_deciles.gph 

	graph export "$robust/non-linear_interactions_twodim_women.pdf",replace


********************************************************************************
* Robustness check 6: unweighted models
********************************************************************************

do "$dofiles/1+2_hte_nlsy_dataprep+prepvar_final-analysis.do"
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/8_hte_nlsy_reshapedata_robustness6.do"
do "$dofiles/8_hte_nlsy_onedim_robustness6.do"


********************************************************************************
* Final analysis
********************************************************************************

do "$dofiles/1+2_hte_nlsy_dataprep+prepvar_final-analysis.do"
do "$dofiles/3_hte_nlsy_sample.do"
do "$dofiles/4_hte_nlsy_propensity.do"
do "$dofiles/5_hte_nlsy_reshapedata.do"
do "$dofiles/6_hte_nlsy_onedim_re.do"
do "$dofiles/7_hte_nlsy_twodim_re.do"


