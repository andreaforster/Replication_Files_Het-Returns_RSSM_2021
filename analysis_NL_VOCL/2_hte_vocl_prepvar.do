********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Definition and coding of variables for the analysis
********************************************************************************

* Description

/* In this do-file we prepare all variables that are used in the analyses */


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

********************************************************************************
* Load prepared data set
********************************************************************************
use "$posted\1_vocl_merged.dta", clear

********************************************************************************
* Variables later used for sample splits and Restrictions
********************************************************************************

*-------------------------------------------------------------------------------
* gender
*-------------------------------------------------------------------------------

recode gesl				///
	(1 = 0 "male")		///
	(2 = 1 "female")	///
	, gen(female)		
	
lab var female "Female"

*-------------------------------------------------------------------------------
* Age
*-------------------------------------------------------------------------------

/* Recode birth year to age at the time point of the first data wave */

recode gebjr 			///
	(1 = 15 "15-18")	///
	(2 = 14 "14")		///
	(3 = 13 "13")		///
	(4 = 12 "12")		///
	(5 = 11 "9-11")		///
	(9=.)				///
	, gen(age)
	
lab var age "Age at First Wave (1989)"

********************************************************************************
* Socio-economic Origin
********************************************************************************

*-------------------------------------------------------------------------------
* Parental Education
*-------------------------------------------------------------------------------

/* Highest education of both parents combined is used. We combine the lowest
two categories into one due to very low case numbers of parents who did not
complete primary education */

recode hooplv ///
	(1 2 = 1 "Primary school or less")			///
	(3   = 2 "Secondary low step")				///
	(4   = 3 "Secondary high step")				///
	(5   = 4 "Tertiary first phase")			///
	(6 	 = 5 "Tertiary second phase")			///
	(8 9 = . )									///
	, gen(edupar_cat)
	
lab var edupar_cat "Parental Education"

/* Assign years of education to the parental education categories 
to make the variable comparable to the analysis with the NLSY */

recode edupar_cat 	///
	(1 = 6)			///
	(2 = 10)		///
	(3 = 12)		///
	(4 = 16)		///
	(5 = 18)		///
	, gen(edupar)
	
lab var edupar "Parental Education"

*-------------------------------------------------------------------------------
* Parental Household income
*-------------------------------------------------------------------------------

/* 
We have household information from the registers separately for mothers and 
fathers as we have the information merged to fathers and mothers identifiers 
(rinpersoon, rinpersoons). We prepare the parental income variable separately
for mothers and fathers and then use fathers information if both parents live
in the same household (same rinpersoonkern). This means that income is 
standardized within father age groups if both parents are present and in
mother age groups if the father is missing.

*/

// Household Income Information for Mothers

	* Generate an age variable for mothers from the birthyear variable
	replace gbageboortejaarmoeder = "1" if gbageboortejaarmoeder=="----"
	destring gbageboortejaarmoeder, gen(age_mo) 
	replace age_mo=. if age_mo==1
	
	/* put negative incomes to zero */
	replace stdnethhincome_mo =0 if stdnethhincome_mo <0
	rename stdnethhincome_mo income_mo

	* standardize the income variable by age groups 
	egen mean_income_mo = mean(income_mo), by(age_mo) 
	egen sd_income_mo = sd(income_mo), by(age_mo)
	gen std_income_mo = (income_mo - mean_income_mo) / sd_income_mo
	
	* generate income as missing for those where standardization is not possible
	replace std_income_mo = . if age_mo==.

	
// Household Income Information for Fathers

	* Generate an age variable for mothers from the birthyear variable	
	replace gbageboortejaarvader = "1" if gbageboortejaarvader=="----"
	destring gbageboortejaarvader, gen(age_fa) 
	replace age_fa=. if age_fa==1

	* replace negative incomes
	replace stdnethhincome_fa  =0 if stdnethhincome_fa  <0
	rename stdnethhincome_fa   income_fa

	* standardize the income variable by age groups 
	egen mean_income_fa = mean(income_fa), by(age_fa) 
	egen sd_income_fa = sd(income_fa), by(age_fa)
	gen std_income_fa = (income_fa - mean_income_fa) / sd_income_fa

	* generate income as missing for those where standardization is not possible
	replace std_income_fa = . if age_fa==.

	
// Calculate Parental income by combining information from mothers and fathers 

	gen parinc= std_income_fa ///
		if rinpersoonkernma == rinpersoonkernpa
		replace parinc=std_income_mo if std_income_fa==.
		replace parinc=std_income_fa if std_income_mo==.
		replace parinc=. if std_income_fa==. & std_income_mo==.
		
	lab var parinc "Parental Income"

********************************************************************************
* Ethnicity and Migration
********************************************************************************

*-------------------------------------------------------------------------------
* Migration background
*-------------------------------------------------------------------------------

/*
Migration background of child according to CBS definition: 
'one parent born abroad'
*/

* father born abroad
recode geblman				///
	(1 = 0 "no")			///
	(2 3 4 5 = 1 "yes")		///
	(6 7 9 = .)				///
	, gen(foreignfa)

* mother born abroad
recode geblvr				///
	(1 = 0 "no")			///
	(2 3 4 5 = 1 "yes")		///
	(6 7 9 = .)				///
	, gen(foreignmo)
	
* CBS definition: 'one parent born abroad'
gen migr = .
	replace migr = 0 if foreignfa==0 & foreignmo==0
	replace migr = 1 if foreignfa==1 | foreignmo==1

lab var migr "Migration Background"	


*-------------------------------------------------------------------------------
* Ethnicity
*-------------------------------------------------------------------------------

/* generate dummy variables for the ethnic groups: Moroccan, Surinamese/Antillan
Turkish and a dummy for 'other non-Dutch' */


gen moroccan = 1 if etnisch ==2 
replace moroccan = 0 if etnisch !=2
lab var moroccan "Moroccan"

gen suriantill = 1 if etnisch ==3
replace suriantill = 0 if etnisch !=3
lab var suriantill "Surinamese/Antillan"

gen turkish = 1 if etnisch ==4
replace turkish = 0 if etnisch !=4
lab var turkish "Turkish"

gen other_nonNL = 1 if etnisch ==5
replace other_nonNL = 0 if etnisch !=5
lab var other_nonNL "Other non-Dutch"

********************************************************************************
* Family structure
********************************************************************************

*-------------------------------------------------------------------------------
* Both parents live in household
*-------------------------------------------------------------------------------

/* Create a dichotomous variable for houshold composition*/

recode huishnw 			///
	(6 = 1 "both parents") ///
	(1 2 3 4 5 7 = 0 "not both parents") ///
	(8 9 =.) ///
	, gen(bothpar)
lab var bothpar "Both Parents at Home"

*-------------------------------------------------------------------------------
* Number of children
*-------------------------------------------------------------------------------

recode aantk_nw			///
	(8 9 =.)			///
	, gen(numkid)
lab var numkid "Number of Children"

********************************************************************************
* level of urbanization
********************************************************************************

/*
Level of urbanization where student lives
*/

recode u71llnw						///
	(2 3 4 = 1 "very rural")		///
	(5 6 7 = 2 "rural")				///
	(8 9 = 3 "small towns")			///
	(10 11 = 4 "medium sized towns") ///
	(12 = 5 "large cities")			///
	(99 = .)						///
	, gen(urban)
lab var urban "Urbanization"
	

********************************************************************************
* Significant others: Parental involvement
********************************************************************************

*-------------------------------------------------------------------------------
* talk about school
*-------------------------------------------------------------------------------

recode schpramn 							///
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(talk_school_fa)

lab var talk_school_fa "Talk about school - Father"
	
recode schpravr								/// 
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(talk_school_mo)
	
lab var talk_school_mo "Talk about school - Mother"

*-------------------------------------------------------------------------------
* Talk about performance
*-------------------------------------------------------------------------------

recode prepramn 							///
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(talk_perform_fa)

lab var talk_perform_fa "Talk about performance - Father"

recode prepravr								///
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(talk_perform_mo)
	
lab var talk_perform_mo "Talk about performance - Mother"

*-------------------------------------------------------------------------------
* Giving compliments 
*-------------------------------------------------------------------------------

recode complimn								///
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(compliments_fa)
	
lab var compliments_fa "Giving compliments - Father"

recode complivr								///	
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(compliments_mo)
	
lab var compliments_mo "Giving compliments - Mother"

*-------------------------------------------------------------------------------
* Motivate to work harder
*-------------------------------------------------------------------------------

recode aanspomn 							///
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(motivate_fa)

lab var motivate_fa "Motivate to work harder - Father"
	
recode aanspovr								///
	(1   = 1 "never")						///
	(2   = 2 "at least once per year")		///
	(3   = 3 "at least once per month")		///
	(4   = 4 "at least once per week")		///
	(8 9 = .)								///
	, gen(motivate_mo)
	
lab var motivate_mo "Motivate to work harder - Mother"

*-------------------------------------------------------------------------------
* INDEX: Parental Encouragement
*-------------------------------------------------------------------------------

/* generate a scale from the variables above */

alpha talk_school_fa talk_school_mo talk_perform_fa talk_perform_mo ///
	compliments_fa compliments_mo motivate_fa motivate_mo ///
	, gen(encourage)
	
lab var encourage "Parental Encouragement"

egen zencourage = std(encourage)
lab var zencourage "Parental Encouragement (std)"
********************************************************************************
* Ability, Performance and Motivation
********************************************************************************

*-------------------------------------------------------------------------------
* CITO score 7th grade
*-------------------------------------------------------------------------------

/*
Score in Cito test (standardized test in 6th grade that determines the secondary 
school track a student will attend). For VOCL a shorter version of the Cito 
was taken by students in 7th grade)
*/

* Total Cito score
recode cstotr (99=.), gen(cito)
lab var cito "CITO score"

* Standardized score
egen zcito = std(cito)
lab var zcito "CITO score (std)"

*-------------------------------------------------------------------------------
* Intelligence test 7th grade and 9th grade
*-------------------------------------------------------------------------------

/*
Intelligence tests taken by VOCL students in 7th grade and 9th grade
*/

rename intel_1 intellig7
lab var intellig7 "IQ score (std) 7th grade"

rename intel_3 intellig9
lab var intellig9 "IQ score (std) 9th grade"



*-------------------------------------------------------------------------------
* Track year 3 (College preparation)
*-------------------------------------------------------------------------------

/*
Whether student is enrolled in a high school track that prepares for higher
education in 9th grade
*/

gen havovwo = 0
	replace havovwo =1 if ondel91==1000 | ondel91==1100 | ondel91==1200 | ///
	ondel91==1300 | ondel91==2000 | ondel91==2100 | ondel91==2200
	replace havovwo =. if ondel91==0 & ((verc9091==2 | verc9091==5 | verc9091==6) ///
	| (verc8990==2 | verc8990==5 | verc8990==6))
	
lab var havovwo "Havo/Vwo Enrolment"

********************************************************************************
* Treatment Variable: HE degree yes/no
********************************************************************************

*-------------------------------------------------------------------------------
* Higher education degree in 2003 yes/no from register data
*-------------------------------------------------------------------------------

/*
Here we use information from the SSD. As higher education degrees are strictly
registered in the Netherlands due to universal study subsidies, we can assume
that all students who are missing in the SSD did not obtain a higher education
degree. 
Missing data is therefore set to: "No degree"
*/ 

destring SOI2006NIVEAU, gen(soi_level)
gen tertiary = 0
	replace tertiary = 1 if inrange(soi_level, 52, 70)	
	
lab var tertiary "Tertiary degree"


*-------------------------------------------------------------------------------
* Eligible for higher education (Vwo/Havo degree or Mbo 4-years)
*-------------------------------------------------------------------------------

/*
Secondary school degrees are not perfectly registered in the SSD. Here we rely
on information from the VOCL to determine who obtained a Havo/Vwo diploma and
is thereby eligible for higher education.
*/

gen secondary = 0
replace secondary =1 if (ondel89 == 4 | ondel89 == 9 | ondel89 == 10) & exres89==1 
replace secondary =1 if (ondel90 == 3 | ondel90 == 4 | ondel89 == 9 | ondel89 == 10 | ondel89 == 27 | ondel89 == 28) & exres90 ==1
replace secondary =1 if (ondel91 == 1000 | ondel91 == 1200 | ondel91 == 1300 | ondel91 == 2000 | ondel91 >= 20000) & exres91 ==1 
replace secondary =1 if (ondel92 == 1000 | ondel92 == 1200 | ondel92 == 1300 | ondel92 == 2000 | ondel92 >= 20000) & exres92 ==1
replace secondary =1 if (ondel93 == 1000 | ondel93 == 1200 | ondel93 == 1300 | ondel93 == 2000 | ondel93 >= 20000) & exres93 ==1
replace secondary =1 if (ondel94 == 1000 | ondel94 == 2000 | ondel94 >= 20000) & exres94 ==1
replace secondary =1 if (ondel95 == 1000 | ondel95 == 2000 | ondel95 >= 20000) & exres95 ==1
replace secondary =1 if (ondel96 == 1000 | ondel96 == 2000 | ondel96 >= 20000) & exres96 ==1
replace secondary =1 if (ondel97 == 1000 | ondel97 == 2000 | ondel97 >= 20000) & exres97 ==1
replace secondary =1 if (ondel98 == 1000 | ondel98 == 2000 | ondel98 >= 20000) & exres98 ==1
replace secondary =1 if (ondel99 == 1000 | ondel99 == 2000 | ondel99 >= 20000) & exres99 ==1
replace secondary =1 if (ondel00 == 1000 | ondel00 == 2000 | ondel00 >= 20000) & exres00 ==1
replace secondary =1 if (ondel01 == 1000 | ondel01 == 2000 | ondel01 >= 20000) & exres01 ==1
replace secondary =1 if (ondel02 == 1000 | ondel02 == 2000 | ondel02 >= 20000) & exres02 ==1
replace secondary =1 if (ondel03 == 1000 | ondel03 == 2000 | ondel03 >= 20000) & exres03 ==1

* Those with MBO 4 or higher taken from register (Mbo not always clear in VOCL)
replace secondary =1 if soi_level > 42 & soi_level!=.

lab var secondary "Secondary Degree"

********************************************************************************
* Destination variable: Hourly wage
********************************************************************************

*-------------------------------------------------------------------------------
* Delete hourly wages outside the range of 1 to 100 dollars per hour
*-------------------------------------------------------------------------------

	forvalues x = 2007(1)2018 {
		recode hourwage`x' (min/0.9=.)(100.01/max=.)
	}

*-------------------------------------------------------------------------------
* Deflate wages using the CPI 2015 (Statline)
*-------------------------------------------------------------------------------

* http://opendata.cbs.nl/statline/#/CBS/nl/dataset/83131NED/table?ts=1614772754480	

gen cpi2007 = 87.2
gen cpi2008 = 89.37
gen cpi2009 = 90.44
gen cpi2010 = 91.59
gen cpi2011 = 93.73
gen cpi2012 = 96.04
gen cpi2013 = 98.44
gen cpi2014 = 99.4
gen cpi2015 = 100
gen cpi2016 = 100.32
gen cpi2017 = 101.7
gen cpi2018 = 103.44

	
	
	forvalues x = 2007(1)2018 {
		replace hourwage`x' = hourwage`x' * 100/cpi`x'
	}

*-------------------------------------------------------------------------------
* Log transformation
*-------------------------------------------------------------------------------

/*
As the hourly wage is strongly skewed, we log transform the variable using
the natural logaritm
*/

gen lnwg07 = ln(hourwage2007) 
gen lnwg08 = ln(hourwage2008)
gen lnwg09 = ln(hourwage2009)
gen lnwg10 = ln(hourwage2010)
gen lnwg11 = ln(hourwage2011)
gen lnwg12 = ln(hourwage2012)
gen lnwg13 = ln(hourwage2013)
gen lnwg14 = ln(hourwage2014) 
gen lnwg15 = ln(hourwage2015)
gen lnwg16 = ln(hourwage2016)
gen lnwg17 = ln(hourwage2017)
gen lnwg18 = ln(hourwage2018)

lab var lnwg07 "Log Hourly Wage 2007"
lab var lnwg08 "Log Hourly Wage 2008"
lab var lnwg09 "Log Hourly Wage 2009"
lab var lnwg10 "Log Hourly Wage 2010"
lab var lnwg11 "Log Hourly Wage 2011"
lab var lnwg12 "Log Hourly Wage 2012"
lab var lnwg13 "Log Hourly Wage 2013"
lab var lnwg14 "Log Hourly Wage 2014"
lab var lnwg15 "Log Hourly Wage 2015"
lab var lnwg16 "Log Hourly Wage 2016"
lab var lnwg17 "Log Hourly Wage 2017"
lab var lnwg18 "Log Hourly Wage 2018"



*-------------------------------------------------------------------------------
* Restrict Dataset
*-------------------------------------------------------------------------------

keep rin srtnum rinpersoon dumou_vr dumen_it dusb1_it dusb3_it female age /// 
	havovwo zcito intellig7 intellig9 ///
	migr moroccan suriantill turkish other_nonNL ///
	bothpar numkid ///
	urban ///
	edupar parinc ///
	zencourage ///
	tertiary secondary ///
	lnwg07 lnwg08 lnwg09 lnwg10 lnwg11 lnwg12 lnwg13 lnwg14 lnwg15 ///
	lnwg16 lnwg17 lnwg18
	
save "$posted/2_vocl_prepared.dta", replace

