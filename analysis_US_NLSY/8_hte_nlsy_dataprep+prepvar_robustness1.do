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


* Open a log file
log using "$logs/1+2_hte_nlsy_dataprep+prepvar.txt", replace

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


********************************************************************************
* Robustness check: College degree at age 28 (individual by student age instead
* of one single year for the entire NLSY cohort)
********************************************************************************

/*
1979 
 14 --> 1993
 15 --> 1992
 16 --> 1991
 17 --> 1990
*/

recode HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 HGCREV82_1982 ///
		HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 HGCREV86_1986 ///
		HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 HGCREV90_1990 ///
		HGCREV91_1991 HGCREV92_1992 HGCREV93_1993 ///
		(-5/-1 =.)(95=.)

egen college14 = rowmax(HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 ///
		HGCREV82_1982 HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 ///
		HGCREV86_1986 HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 ///
		HGCREV90_1990 HGCREV91_1991 HGCREV92_1992 HGCREV93_1993) if age==14

egen college15 = rowmax(HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 ///
		HGCREV82_1982 HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 ///
		HGCREV86_1986 HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 ///
		HGCREV90_1990 HGCREV91_1991 HGCREV92_1992) if age==15

egen college16 = rowmax(HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 ///
		HGCREV82_1982 HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 ///
		HGCREV86_1986 HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 ///
		HGCREV90_1990 HGCREV91_1991) if age==16

egen college17 = rowmax(HGCREV79_1979 HGCREV80_1980 HGCREV81_1981 ///
		HGCREV82_1982 HGCREV83_1983 HGCREV84_1984 HGCREV85_1985 ///
		HGCREV86_1986 HGCREV87_1987 HGCREV88_1988 HGCREV89_1989 ///
		HGCREV90_1990) if age==17


forval x = 14/17 {
	recode college`x' (1/11 =.)(12/15 = 0)(16/20 =1)
}


forval x = 14/17 {
	replace college = college`x' if age==`x'
}


********************************************************************************
* Destination Variables
********************************************************************************

*-------------------------------------------------------------------------------
* Earnings 
*-------------------------------------------------------------------------------

********************************************************************************
* Earnings
********************************************************************************

*-------------------------------------------------------------------------------
* Generate average of hourly wages from different reported jobs in each year
*-------------------------------------------------------------------------------

	forvalues x = 1994(2)2006 {
		recode HRP1_`x' HRP2_`x' HRP3_`x' HRP4_`x' HRP5_`x' (-5/0 =.)
		egen h_wage_`x' = rowmean(HRP1_`x' HRP2_`x' HRP3_`x' HRP4_`x' HRP5_`x')
		replace h_wage_`x' = h_wage_`x'/100	
	}


*-------------------------------------------------------------------------------
* Log wage variable
*-------------------------------------------------------------------------------

	forvalues x = 1994(2)2006 {
		gen lnwg`x' = ln(h_wage_`x')
		lab var lnwg`x' "Log hourly wage `x'"
	}

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
	lnwg*
	

save "$posted/nlsy_final_data.dta", replace
log close
