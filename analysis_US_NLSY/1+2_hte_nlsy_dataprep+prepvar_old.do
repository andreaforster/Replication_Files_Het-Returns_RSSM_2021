********************************************************************************
* 0. CONFIGURATION OF PATHS
********************************************************************************

clear all
capture log close
set more off

* global dataDir 	"C:\Users\andrea\Dropbox\andrea\research\02_data\NLSY79\"
global workingDir "C:\Users\andrea\Dropbox\andrea\research\03_papers\2016_het_returns_paper\2018-09 comparative paper"
global codeDir "C:\Users\andrea\Dropbox\andrea\research\08_methods_coding"

*------------------------------------------------------------------------------*
global data			"${workingDir}\00_data"				// original files
global dofiles 		"${workingDir}\01_code"				// do-files
global posted		"${workingDir}\02_posted"			// prepared data
global logs			"${workingDir}\03_logs"				// log files
global graphs		"${workingDir}\04_text\01_graphs"	// graphs
global tables		"${workingDir}\04_text\02_tables"	// tables for latex
global code			"${codeDir}" 						// others' code for occupations etc.
*------------------------------------------------------------------------------*

********************************************************************************
* 1. Open Data and Log file
********************************************************************************

* Open a log file
*log using "$logs/1+2_nlsy_dataprep+prepvar.txt", replace

* Open data set
use "$data\merged_NLSY_2019.dta", clear

* id variable
clonevar id = CASEID_1979

********************************************************************************
* Variables later used for sample splits and restrictions
********************************************************************************

*-------------------------------------------------------------------------------
* Sex
*-------------------------------------------------------------------------------

/* 
Sex indicated by the student in 1979
*/

recode SAMPLE_SEX_1979 (1=0 "male")(2=1 "female"), gen(female)
lab var female "Female (ref = male)"

*-------------------------------------------------------------------------------
* Age
*-------------------------------------------------------------------------------

/* Age of student in 1979 */

recode AGEATINT_1979 (. = .), gen(age)
lab var age "Age in 1979"

*-------------------------------------------------------------------------------
* Years of Education in 1979 and 1990
*-------------------------------------------------------------------------------

/* 
Years of education completed indicated by the student in the various years.
We take the maximum until 1990
*/

recode HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 HGCREV82_1982 ///
	HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 HGCREV86_1986 ///
	HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 HGCREV90_1990 ///
	(-5/-1 =.)(95=.)

egen eduyears90 = rowmax(HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 ///
	HGCREV82_1982 HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 ///
	HGCREV86_1986 HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 ///
	HGCREV90_1990)

gen eduyears79 = HGCREV79_1979

********************************************************************************
* Socio-economic origin 
********************************************************************************

*-------------------------------------------------------------------------------
* Parental income
*-------------------------------------------------------------------------------

recode TNFI_TRUNC_1979 (-3/-1 =.), gen(parinc_doll)
lab var parinc_doll "Parents' income"

egen parinc = std(parinc_doll)
lab var parinc "Parents' income (std)"

*-------------------------------------------------------------------------------
* Parental education
*-------------------------------------------------------------------------------

* father
recode HGC_FATHER_1979 (-4/-1 =.), gen(edufa)
lab var edufa "Father's education"

* mother
recode HGC_MOTHER_1979 (-4/-1 =.), gen(edumo)
lab var edumo "Mother's education"

* parents highest education 
gen edupar = edufa
	replace edupar = edumo if edufa ==.
	replace edupar = edumo if edumo > edufa & edumo!=.
lab var edupar "Parental Education"

*-------------------------------------------------------------------------------	
* Parental occupational status
*-------------------------------------------------------------------------------

/* 
* CODING following Torche 2011
TORCHE 2011, p. 778: "Occupational status scores are obtained using three 
	formulations the original Socioeconomic Index (Duncan 1961), a revised 
	version by Stevens 
	and Featherman (1981), and Hauser and Warrenӳ (1997) occupational
	education formulation. Upon ascertaining that results are similar across
	formulations, only those based on status scores by Stevens and Featherman
	(1981) are presented (alternative results available from the author
	upon request)." [...] "In the NLSY79, parental status is retrospectively 
	reported for the year when the respondent was 14 years old"

	"measures of socioeconomic standing, correspond to the male 
	(or female if no male was present) 
	head of the household when the respondent was growing up." (p.777)

MY CODING: 
	I remove the missings from father's and mother's census occupation code. Then I attach 
	a status score to each occupation code (see sub do-file) for fathers and mothers separately. 
	The list with status scores, I took directly from the appendix of Stevens and Featherman (1981). 
	Finally, I generate a joint status measure for both parents by taking the score for the 
	father and replacing it with the score for the mother if the score is missing for the father
	For now I use the MSEI2 as Stevens and Featherman recommend that one. 


///// MOTHER'S OCCUPATIONAL STATUS /////

	* Remove missings from mother's occupation in 1979 (occup. is coded in 1970 census codes)
	recode FAM_9A_1979 (-4/-1 =.), gen(mother_occ1970)

	* Match Steven and Featherman's (1981) occupational status scores to mother's occupation code
	rename mother_occ1970 occ1970		//rename to match with sub-dofile
	do "$dofiles/occupation codes/SEI_scores_stevens_featherman.do"
	rename occ1970 mother_occ1970		//rename to obtain distinguishable names for the main data set
	rename msei2 msei2_mother			//rename to obtain distinguishable names for the main data set
	rename tsei2 tsei2_mother			//rename to obtain distinguishable names for the main data set

///// FATHER'S OCCUPATIONAL STATUS /////

	* Remove missings from father's occupation in 1979 (occup. is coded in 1970 census codes)
	recode FAM_11A_1979 (-4/-1 =.), gen(father_occ1970)

	* match Steven and Featherman's (1981) occupational status scores to father's occupation code
	rename father_occ1970 occ1970		// rename to match with sub-dofile
	do "$dofiles/occupation codes/SEI_scores_stevens_featherman.do"
	rename occ1970 father_occ1970		//rename to obtain distinguishable names for the main data set
	rename msei2 msei2_father			//rename to obtain distinguishable names for the main data set
	rename tsei2 tsei2_father			//rename to obtain distinguishable names for the main data set

///// PARENTAL OCCUPATIONAL STATUS /////

	* calculate one status measure for parents
	gen parocc = msei2_father	//use father's occupation if present
	replace parocc = msei2_mother if msei2_father ==. //use mother if father missing
	lab var parocc "Parents' occupational status"
*/

********************************************************************************
* Race and Ethnicity/Religion
********************************************************************************

recode SAMPLE_RACE_78SCRN (1 3 = 0 "no")(2 = 1 "yes"), gen(black)
lab var black "Black"

recode SAMPLE_RACE_78SCRN (2 3 = 0 "no")(1 = 1 "yes"), gen(hispanic)
lab var hispanic "Hispanic"

recode R_REL_1_COL_1979 (-3/-1=.)(8 = 1 "Jewish")(else=0), gen(jewish)
lab var jewish "Jewish"

********************************************************************************
* Family structure
********************************************************************************

*-------------------------------------------------------------------------------
* intact family
*-------------------------------------------------------------------------------

recode FAM_7_1979 (-3 =.)(11 = 1)(else=0), gen(bothpar)
lab var bothpar "Lived with both parents"

*-------------------------------------------------------------------------------
* number of siblings
*-------------------------------------------------------------------------------

recode FAM_28A_1979 (-3/-1 =.), gen(siblings)
lab var siblings "Number of siblings"

gen numkid = siblings + 1
lab var numkid "Number of Children"

********************************************************************************
* Urbanization
********************************************************************************

*-------------------------------------------------------------------------------
* urban/rural (current residence 1979)
*-------------------------------------------------------------------------------

recode URBAN_RURAL_1979 (-4=.), gen(urban)
lab var urban "Urban/Rural"

*-------------------------------------------------------------------------------
* urban/proximity to college
*-------------------------------------------------------------------------------

recode SMSARES_1979 (-4 =.)(0 = 0 "rural")(1 2 3 = 1 "urban"), gen(proxim)
lab var proxim "Proximity to College"

********************************************************************************
* Significant others: Friends' college plans
********************************************************************************

recode SCHOOL_32_1979 (-3/-1 =.), gen(friends_years)

gen friends = .
	replace friends = 0 if friends_years < 13 & friends_years !=.
	replace friends = 1 if friends_years > 12 & friends_years !=.

lab var friends "Friends' college plans"

********************************************************************************
* Ability, Motivation, College preparation
********************************************************************************

*-------------------------------------------------------------------------------
* Mental ability 
*-------------------------------------------------------------------------------

gen age80 = age + 1

recode ASVAB_3_1981 ASVAB_4_1981 ASVAB_5_1981 ASVAB_6_1981 ///
	ASVAB_7_1981 ASVAB_8_1981 ASVAB_9_1981 ASVAB_10_1981 ///
	ASVAB_11_1981 ASVAB_12_1981 (-4/-1 =.)

foreach var of varlist ASVAB_* {

	forvalues x = 1/3 {
		
		forvalues y = 0/1 {
		
		preserve
			keep if SAMPLE_RACE_78SCRN ==`x'
			keep if female ==`y'
			regress `var' age80
			predict res_ab`var'_`x'_`y', res
			egen res_ab`var'_`x'_`y'_std = std(res_ab`var'_`x'_`y')
			keep CASEID_1979 female SAMPLE_RACE_78SCRN res_ab`var'_`x'_`y'_std
			save "$posted/res_ab_`var'_`x'_`y'.dta", replace
		restore
		
		}
	}
}

*

forvalues z = 3/12{

	forvalues x = 1/3 {
		
		forvalues y = 0/1 {

		merge 1:1 CASEID_1979 using "$posted/res_ab_ASVAB_`z'_1981_`x'_`y'.dta"
		drop _merge
		}
	}
}
*

forvalues z = 3/12 {

egen ASVAB_`z' = rowmax( ///
	res_abASVAB_`z'_1981_1_0_std res_abASVAB_`z'_1981_1_1_std ///
	res_abASVAB_`z'_1981_2_0_std res_abASVAB_`z'_1981_2_1_std ///
	res_abASVAB_`z'_1981_3_0_std res_abASVAB_`z'_1981_3_1_std)
}
*

forvalues z = 3/12 {

drop res_abASVAB_`z'_1981_1_0_std res_abASVAB_`z'_1981_1_1_std ///
	res_abASVAB_`z'_1981_2_0_std res_abASVAB_`z'_1981_2_1_std ///
	res_abASVAB_`z'_1981_3_0_std res_abASVAB_`z'_1981_3_1_std
}
*
	
alpha ASVAB_3 ASVAB_4 ASVAB_5 ASVAB_6 ASVAB_7 ASVAB_8 ASVAB_9 ///
	ASVAB_10 ASVAB_11 ASVAB_12, gen(ability)
lab var ability "ASVAB score"
	
*-------------------------------------------------------------------------------
* College prep courses
*-------------------------------------------------------------------------------

/*	" College-prep indicates whether a student was enrolled in a 
	college-preparatory curriculum in the NLSY" */ 

recode SCHOOL_17_1979 SCHOOL_17_1980 SCHOOL_17_1981 SCHOOL_17_1982 ///
	SCHOOL_17_1983 SCHOOL_17_1984 SCHOOL_17_1985 (-4/0 =.)

gen collprep = 0
	replace collprep = 1 if SCHOOL_17_1979==3 | SCHOOL_17_1980==3 | ///
		SCHOOL_17_1981==3 | SCHOOL_17_1982==3 | SCHOOL_17_1983==3 | ///
		SCHOOL_17_1984==3 | SCHOOL_17_1985==3


	lab var collprep "College prep. course"


********************************************************************************
* Treatment variable: College degree
********************************************************************************

* Remove missings from the highest grade completed variable
	recode HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 HGCREV82_1982 ///
		HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 HGCREV86_1986 ///
		HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 HGCREV90_1990 ///
		(-5/-1 =.)(95=.)
	
	egen college = rowmax(HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 ///
		HGCREV82_1982 HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 ///
		HGCREV86_1986 HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 ///
		HGCREV90_1990)
		
	recode college (1/11 =.)(12/15 = 0)(16/20 =1)
	lab var college "College degree"
/*	
	// Remove missings from the highest degree variable
	recode Q3_10B_1988 Q3_10B_1989 Q3_10B_1990 Q3_10B_1991 Q3_10B_1992 ///
		Q3_10B_1993 Q3_10B_1994 Q3_10B_1996 Q3_10B_1998 Q3_10B_2000 ///
		Q3_10B_2002 Q3_10B_2004 Q3_10B_2006 (-5/-1 =.) (95=.) (8=.)
		
	// Generate the highest degree received over the years
	egen degree = rowmax(Q3_10B_1988 Q3_10B_1989 Q3_10B_1990 Q3_10B_1991 ///
		Q3_10B_1992 Q3_10B_1993 Q3_10B_1994 Q3_10B_1996 Q3_10B_1998 ///
		Q3_10B_2000 Q3_10B_2002 Q3_10B_2004 Q3_10B_2006)
		
	recode degree (1 2 =0 "High school")(3 4 5 6 7 =1 "College")(else =.) ///
		, gen(college)
*/
	
********************************************************************************
* Destination Variables
********************************************************************************

*-------------------------------------------------------------------------------
* Earnings 
*-------------------------------------------------------------------------------

	// 1994
	recode HRP1_1994 HRP2_1994 HRP3_1994 HRP4_1994 HRP5_1994 (-5/-1 =.) (0=1)
	egen h_wage_94 = rowtotal(HRP1_1994 HRP2_1994 HRP3_1994 HRP4_1994 HRP5_1994)
	replace h_wage_94 = h_wage_94/100
	recode h_wage_94 (0=.)(0.01/1=1)
	gen lnwg94 = ln(h_wage_94)
	lab var lnwg94 "Log hourly wage 1994"
	
	// 1996
	recode HRP1_1996 HRP2_1996 HRP3_1996 HRP4_1996 HRP5_1996 (-5/-1 =.)(0=1)
	egen h_wage_96 = rowtotal(HRP1_1996 HRP2_1996 HRP3_1996 HRP4_1996 HRP5_1996)
	replace h_wage_96 = h_wage_96/100
	recode h_wage_96 (0=.)(0.01/1=1)
	gen lnwg96 = ln(h_wage_96)
	lab var lnwg96 "Log hourly wage 1996"

	// 1998
	recode HRP1_1998 HRP2_1998 HRP3_1998 HRP4_1998 HRP5_1998 (-5/-1 =.)(0=1)
	egen h_wage_98 = rowtotal(HRP1_1998 HRP2_1998 HRP3_1998 HRP4_1998 HRP5_1998)
	replace h_wage_98 = h_wage_98/100
	recode h_wage_98 (0=.)(0.01/1=1)
	gen lnwg98 = ln(h_wage_98)
	lab var lnwg98 "Log hourly wage 1998"

	// 2000
	recode HRP1_2000 HRP2_2000 HRP3_2000 HRP4_2000 HRP5_2000 (-5/-1 =.)(0=1)
	egen h_wage_00 = rowtotal(HRP1_2000 HRP2_2000 HRP3_2000 HRP4_2000 HRP5_2000)
	replace h_wage_00 = h_wage_00/100
	recode h_wage_00 (0=.)(0.01/1=1)
	gen lnwg00 = ln(h_wage_00)
	lab var lnwg00 "Log hourly wage 2000"
	
	// 2002
	recode HRP1_2002 HRP2_2002 HRP3_2002 HRP4_2002 HRP5_2002 (-5/-1 =.)(0=1)
	egen h_wage_02 = rowtotal(HRP1_2002 HRP2_2002 HRP3_2002 HRP4_2002 HRP5_2002)
	replace h_wage_02 = h_wage_02/100
	recode h_wage_02 (0=.)(0.01/1=1)
	gen lnwg02 = ln(h_wage_02)
	lab var lnwg02 "Log hourly wage 2002"

	// 2004
	recode HRP1_2004 HRP2_2004 HRP3_2004 HRP4_2004 HRP5_2004 (-5/-1 =.)(0=1)
	egen h_wage_04 = rowtotal(HRP1_2004 HRP2_2004 HRP3_2004 HRP4_2004 HRP5_2004)
	replace h_wage_04 = h_wage_04/100
	recode h_wage_04 (0=.)(0.01/1=1)
	gen lnwg04 = log(h_wage_04)
	lab var lnwg04 "Log hourly wage 2004"

	//2006
	recode HRP1_2006 HRP2_2006 HRP3_2006 HRP4_2006 HRP5_2006 (-5/-1 =.)(0=1)
	egen h_wage_06 = rowtotal(HRP1_2006 HRP2_2006 HRP3_2006 HRP4_2006 HRP5_2006)
	replace h_wage_06 = h_wage_06/100
	recode h_wage_06 (0=.)(0.01/1=1)
	gen lnwg06 = ln(h_wage_06)
	lab var lnwg06 "Log hourly wage 2006"

	//2008
	recode HRP1_2008 HRP2_2008 HRP3_2008 HRP4_2008 HRP5_2008 (-5/-1 =.)(0=1)
	egen h_wage_08 = rowtotal(HRP1_2008 HRP2_2008 HRP3_2008 HRP4_2008 HRP5_2008)
	replace h_wage_08 = h_wage_08/100
	recode h_wage_08 (0=.)(0.01/1=1)
	gen lnwg08 = ln(h_wage_08)
	lab var lnwg08 "Log hourly wage 2008"

	//2010
	recode HRP1_2010 HRP2_2010 HRP3_2010 HRP4_2010 HRP5_2010 (-5/-1 =.)(0=1)
	egen h_wage_10 = rowtotal(HRP1_2010 HRP2_2010 HRP3_2010 HRP4_2010 HRP5_2010)
	replace h_wage_10 = h_wage_10/100
	recode h_wage_10 (0=.)(0.01/1=1)
	gen lnwg10 = ln(h_wage_10)
	lab var lnwg10 "Log hourly wage 2010"

	//2012
	recode HRP1_2012 HRP2_2012 HRP3_2012 HRP4_2012 HRP5_2012 (-5/-1 =.)(0=1)
	egen h_wage_12 = rowtotal(HRP1_2012 HRP2_2012 HRP3_2012 HRP4_2012 HRP5_2012)
	replace h_wage_12 = h_wage_12/100
	recode h_wage_12 (0=.)(0.01/1=1)
	gen lnwg12 = ln(h_wage_12)
	lab var lnwg12 "Log hourly wage 2012"
	

********************************************************************************
* Weight
********************************************************************************

rename C_SAMPWEIGHT_1980 weight
lab var weight "Sample weight 1980"

********************************************************************************
* Keep relevant variables and save
********************************************************************************

keep id age female weight eduyears90 eduyears79 /// identifiers, sample grouping
	parinc edupar edufa edumo /// SES parents
	black hispanic jewish ///
	bothpar numkid ///
	urban proxim  ///
	friends /// 
	ability collprep /// merit. co-variates
	college /// treatment
	lnwg94 lnwg96 lnwg98 lnwg00 lnwg02 lnwg04 lnwg06 lnwg08 lnwg10 lnwg12
	

save "$posted/nlsy_final_data.dta", replace
log close
