********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Reshape of data from wide format (one row per individual) 
* to long format (one row per wage observations)
********************************************************************************

* Description

/* This do file reshapes the data in a way that each row pertains to one
wage observation (year). This is done as the further analyses will be carried
out as multilevel analysis with wage-years on level 2 and 
individuals on level 2. It also creates a variable for age at each wage-year */


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
use "$posted\4_vocl_propensity.dta", clear

* Keep variables that will be used in the analysis
keep rin srtnum female tertiary lnwg07 lnwg08 lnwg09 lnwg10 lnwg11 lnwg12 ///
	lnwg13 lnwg14 lnwg15 lnwg16 lnwg17 lnwg18 ps_men ps_women ps_men_rel ///
	ps_men_irr ps_women_rel ps_women_irr ipw

* rename wave observations to consecutive numbers
rename lnwg07 lnwg1 
rename lnwg08 lnwg2
rename lnwg09 lnwg3
rename lnwg10 lnwg4
rename lnwg11 lnwg5
rename lnwg12 lnwg6
rename lnwg13 lnwg7
rename lnwg14 lnwg8
rename lnwg15 lnwg9
rename lnwg16 lnwg10
rename lnwg17 lnwg11
rename lnwg18 lnwg12

* reshape from wide to long
reshape long lnwg, i(rin) j(year) 

* recode back from consecutive numbers to years
recode year (1=2007)(2=2008)(3=2009)(4=2010)(5=2011)(6=2012)(7=2013) ///
	(8=2014)(9=2015)(10=2016)(11=2017)(12=2018)

* generate a variable for the average age of the respondents at each wage-year
gen age =.
replace age = 30 if year==2007
replace age = 31 if year==2008	
replace age = 32 if year==2009
replace age = 33 if year==2010
replace age = 34 if year==2011
replace age = 35 if year==2012
replace age = 36 if year==2013
replace age = 37 if year==2014
replace age = 38 if year==2015
replace age = 39 if year==2016
replace age = 40 if year==2017
replace age = 41 if year==2018

lab var age "Age at Wage"

* center the age variable at the youngest age in the data (= 30)
gen age_c = age-30
lab var age_c "Age at Wage"

save "$posted/5_vocl_reshaped.dta", replace
