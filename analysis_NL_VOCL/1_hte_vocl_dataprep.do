********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Merging of different data sources, preparation of data set
********************************************************************************

* Description

/* We use the VOCL 1989 student dataset as main data set and merge information 
from the vocl parent questionnaire and from the population registers to these 
survey data */


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
* Use VOCL 1989 main questionnaire
********************************************************************************

/*
We start with the main VOCL data that contains information on 19,524 students 
obtained via questionnaires starting in 7th grade
*/

use "$dataDir\VOCL89\vocl89_hoofdbestand.dta", clear

********************************************************************************
* Convert VOCL identifiers to match SSD indentifiers for merging
********************************************************************************

/* 
VOCL uses srtnum and rin as identifiers for individuals.
SSD uses rinpersoon and rinpersoons. The content of those is identical and 
can be translated into each other
*/

* Drop those without identifier in VOCL (these cannot be connected to SSD data)
drop if rin==. 					// 413 cases are dropped 
			
* VOCL identifier rin (integer) --> SSD identifier rinpersoon (string)
gen rinpersoon = string(rin, "%09.0f")

* VOCL identifier srtnum (string) --> SSD identifier rinpersoons (string)
clonevar rinpersoons = srtnum	

*-------------------------------------------------------------------------------
* Save a list of all identifiers for later use in merging
*-------------------------------------------------------------------------------

preserve 

keep rinpersoon rinpersoons

save "$posted/dataprep_rinlist.dta", replace

restore

/*******************************************************************************
GBAPERSOONTAB: merge personal information from SSD 
(also contains birthyears of parents) 
*******************************************************************************/

/*
We merge personal basic data from the SSD for each individual. These are e.g.
birth year and country of birth for the individual and his/her parents
*/


merge 1:1 rinpersoon rinpersoons ///
	using "G:\Bevolking\GBAPERSOONTAB\2016\geconverteerde data\GBAPERSOONTAB 2016V1.dta" ///
	, keep(match master) nogen 

	// 8 individuals cannot be merged (no personal register information)
	
********************************************************************************
* Merge VOCL parental questionnaire to data set
********************************************************************************

/*
We merge data from parent interviews in the VOCL to the data set
*/

merge 1:1 crptmodg srtmodg ///
	using "$dataDir\VOCL89\vocl89_ouderbestand.dta" ///
	, keep(match master) nogen

	// 850 individuals cannot be merged ( --> no VOCL parent information)
	
********************************************************************************
* KINDOUDERTAB: Merge parent register ID's to VOCL data 
********************************************************************************

/*
With the KINDOUDERTAB we identify which children belong to which parents in the
SSD. 
We obtain the SSD identifiers for those parents for further data merging
*/

merge m:1 rinpersoon rinpersoons ///
	using "G:\Bevolking\KINDOUDERTAB\2016\geconverteerde data\KINDOUDER2016TABV1.dta", ///
	keep(match master)

	// 28 individuals cannot be merged ( --> no SSD parent information)

********************************************************************************
* Merge Parental income from Integraal Huishoudens Inkomen (IHI) 2003 to VOCL
********************************************************************************

/*
As we do not have parents' household income when children were young, we proxy
this household income with information from the SSD from 2003, the oldest
data that we have available

As we do not know whether father and mother live in the same household, we
collect information from the SSD for both of them and harmonize the information
afterwards
*/

*-------------------------------------------------------------------------------
* SSD information from mothers
*-------------------------------------------------------------------------------

preserve 

* rename the identifiers for mothers to be used with the income data set
keep rinpersoon rinpersoons RINPERSOONSMa RINPERSOONMa

drop if RINPERSOONMa =="---------" 
drop if RINPERSOONMa ==""

rename rinpersoon rinpersoon_prim
rename rinpersoons rinpersoons_prim

rename RINPERSOONMa rinpersoon
rename RINPERSOONSMa rinpersoons

* merge mother information to the person in the household for which income
* information is recorded
merge m:1 rinpersoon rinpersoons ///
	using "G:\InkomenBestedingen\INTEGRAAL PERSOONLIJK INKOMEN\2003\geconverteerde data\PERSOONINK2003TABV3.dta" ///
	, keep(match master) keepusing(rinpersoons rinpersoon rinpersoonskern rinpersoonkern) nogen

* merge income information of the household to our data set 
merge m:1 rinpersoonkern rinpersoonskern ///
	using "G:\InkomenBestedingen\INTEGRAAL HUISHOUDENS INKOMEN\2003\geconverteerde data\HUISHBVRINK2003TABV3.dta" ///
	, keep(match master) keepusing(bvrbestinkh bvrgestinkh) nogen

* rename identifiers back to the original names
rename rinpersoons RINPERSOONSMa
rename rinpersoon RINPERSOONMa
rename rinpersoonskern rinpersoonskernma
rename rinpersoonkern rinpersoonkernma

* rename income variables
rename bvrbestinkh nethhincome_mo
rename bvrgestinkh stdnethhincome_mo

* drop observations if income information is missing
drop if nethhincome_mo ==.
drop if stdnethhincome_mo ==.
drop if nethhincome_mo ==999999999
drop if stdnethhincome_mo ==999999999

* save income information for mothers
save "$posted/household_income_mother.dta", replace
	
restore

*-------------------------------------------------------------------------------
* SSD information from fathers
*-------------------------------------------------------------------------------

preserve 

* rename the identifiers for fathers to be used with the income data set
keep rinpersoon rinpersoons RINPERSOONSpa RINPERSOONpa

drop if RINPERSOONpa =="---------" 
drop if RINPERSOONpa ==""

rename rinpersoon rinpersoon_prim
rename rinpersoons rinpersoons_prim

rename RINPERSOONpa rinpersoon
rename RINPERSOONSpa rinpersoons

* merge father information to the person in the household for which income
* information is recorded
merge m:1 rinpersoon rinpersoons ///
	using "G:\InkomenBestedingen\INTEGRAAL PERSOONLIJK INKOMEN\2003\geconverteerde data\PERSOONINK2003TABV3.dta" ///
	, keep(match master) keepusing(rinpersoons rinpersoon rinpersoonskern rinpersoonkern) nogen

* merge income information of the household to our data set 
merge m:1 rinpersoonkern rinpersoonskern ///
	using "G:\InkomenBestedingen\INTEGRAAL HUISHOUDENS INKOMEN\2003\geconverteerde data\HUISHBVRINK2003TABV3.dta" ///
	, keep(match master) keepusing(bvrbestinkh bvrgestinkh) nogen

* rename identifiers back to the original names
rename rinpersoons RINPERSOONSpa
rename rinpersoon RINPERSOONpa
rename rinpersoonskern rinpersoonskernpa
rename rinpersoonkern rinpersoonkernpa

* rename income variables
rename bvrbestinkh nethhincome_fa
rename bvrgestinkh stdnethhincome_fa

* drop observations if income information is missing
drop if nethhincome_fa ==.
drop if stdnethhincome_fa ==.
drop if nethhincome_fa ==999999999
drop if stdnethhincome_fa ==999999999

* save income information for fathers
save "$posted/household_income_father.dta", replace
	
restore

*-------------------------------------------------------------------------------
* Merge income information to our data
*-------------------------------------------------------------------------------

* merge income information for fathers to our data
merge m:m RINPERSOONSpa RINPERSOONpa ///
	using "$posted/household_income_father.dta", keep(match master) nogen
	
// 1,887 fathers without SSD income information

* merge income information for mothers to our data
merge m:m RINPERSOONSMa RINPERSOONMa ///
	using "$posted/household_income_mother.dta", keep(match master) nogen

// 916 mothers without SSD Income information 

*-------------------------------------------------------------------------------
* Save our prepared data 
*-------------------------------------------------------------------------------

save "$posted/prepdata_withoutearnings.dta", replace


********************************************************************************
* POLISBUS, SPOLISBUS: Save and merge earnings data for children 2007 to 2015
********************************************************************************

/*
We save earnings data for the VOCL children for each year between 2007 and 2015
and calculate the average hourly wage for each of the years.
The original data sets are very large, that is why for some years we have 
opened the original data (in SPSS) and only kept 
relevant variables before converting them to Stata manually as they could not be
opened in Stata directly due to memory restrictions on the CBS server
*/

*-------------------------------------------------------------------------------
* prepare earnings 2007
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from POLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Polis\POLISBUS\2007\geconverteerde data/POLISBUS 2007V1.dta" ///
, keep(match master) keepusing(lningld basisuren basisloon aanvbus eindbus) nogen
		
* rename variables to identify the correct year
rename lningld earnings2007
rename basisuren hours2007
rename basisloon base_earn2007
rename aanvbus begindate2007
rename eindbus enddate2007

* save the earnings data
save "$posted/earnings2007.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2007
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2007.dta", clear

* generate hourly wage for each job
gen hourwage2007 = base_earn2007/hours2007

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2007==.
collapse (mean) hourwage2007, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2007.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2008
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from POLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Polis\POLISBUS\2008\geconverteerde data/POLISBUS 2008V1.dta" ///
, keep(match master) keepusing(lningld basisuren basisloon aanvbus eindbus) nogen	

* rename variables to identify the correct year
rename lningld earnings2008
rename basisuren hours2008
rename basisloon base_earn2008
rename aanvbus begindate2008
rename eindbus enddate2008

* save the earnings data
save "$posted/earnings2008.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2008
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2008.dta", clear

* generate hourly wage for each job
gen hourwage2008 = base_earn2008/hours2008

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2008==.
collapse (mean) hourwage2008, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2008.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2009
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from POLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Polis\POLISBUS\2009\geconverteerde data/POLISBUS 2009V1.dta" ///
, keep(match master) keepusing(lningld basisuren basisloon aanvbus eindbus) nogen		

* rename variables to identify the correct year
rename lningld earnings2009
rename basisuren hours2009
rename basisloon base_earn2009
rename aanvbus begindate2009
rename eindbus enddate2009

* save the earnings data
save "$posted/earnings2009.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2009
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2009.dta", clear

* generate hourly wage for each job
gen hourwage2009 = base_earn2009/hours2009

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2009==.
collapse (mean) hourwage2009, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2009.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2010
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2010\geconverteerde data\SPOLISBUS 2010V1.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2010
rename sbasisuren hours2010
rename sbasisloon base_earn2010
rename sdatumaanvangiko begindate2010
rename sdatumeindeiko enddate2010

* save the earnings data
save "$posted/earnings2010.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2010
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2010.dta", clear

* generate hourly wage for each job
gen hourwage2010 = base_earn2010/hours2010

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2010==.
collapse (mean) hourwage2010, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2010.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2011
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2011\geconverteerde data\SPOLISBUS 2011V1.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2011
rename sbasisuren hours2011
rename sbasisloon base_earn2011
rename sdatumaanvangiko begindate2011
rename sdatumeindeiko enddate2011

* save the earnings data
save "$posted/earnings2011.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2011
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2011.dta", clear

* generate hourly wage for each job
gen hourwage2011 = base_earn2011/hours2011

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2011==.
collapse (mean) hourwage2011, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2011.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2012
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2012\geconverteerde data\SPOLISBUS 2012V1.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2012
rename sbasisuren hours2012
rename sbasisloon base_earn2012
rename sdatumaanvangiko begindate2012
rename sdatumeindeiko enddate2012

* save the earnings data
save "$posted/earnings2012.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2012
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2012.dta", clear

* generate hourly wage for each job
gen hourwage2012 = base_earn2012/hours2012

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2012==.
collapse (mean) hourwage2012, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2012.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2013
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2013\geconverteerde data\SPOLISBUS 2013V2_new.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2013
rename sbasisuren hours2013
rename sbasisloon base_earn2013
rename sdatumaanvangiko begindate2013
rename sdatumeindeiko enddate2013

* save the earnings data
save "$posted/earnings2013.dta", replace
	
*-------------------------------------------------------------------------------
* Generate hourly wage for 2013
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2013.dta", clear

* generate hourly wage for each job
gen hourwage2013 = base_earn2013/hours2013

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2013==.
collapse (mean) hourwage2013, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2013.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2014
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2014\geconverteerde data\SPOLISBUS 2014V1.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2014
rename sbasisuren hours2014
rename sbasisloon base_earn2014
rename sdatumaanvangiko begindate2014
rename sdatumeindeiko enddate2014
	
* save the earnings data
save "$posted/earnings2014.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2014
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2014.dta", clear

* generate hourly wage for each job
gen hourwage2014 = base_earn2014/hours2014

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2014==.
collapse (mean) hourwage2014, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2014.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2015
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "H:\Andrea\heterog. effects edu\2018-09 comparative paper\00_original_data\SPOLISBUS 2015V3.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2015
rename sbasisuren hours2015
rename sbasisloon base_earn2015
rename sdatumaanvangiko begindate2015
rename sdatumeindeiko enddate2015

* save the earnings data
save "$posted/earnings2015.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2015
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2015.dta", clear

* generate hourly wage for each job
gen hourwage2015 = base_earn2015/hours2015

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2015==.
collapse (mean) hourwage2015, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2015.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2016
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2016\geconverteerde data\SPOLISBUS2016V3.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2016
rename sbasisuren hours2016
rename sbasisloon base_earn2016
rename sdatumaanvangiko begindate2016
rename sdatumeindeiko enddate2016

* save the earnings data
save "$posted/earnings2016.dta", replace
	
*-------------------------------------------------------------------------------
* Generate hourly wage for 2016
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2016.dta", clear

* generate hourly wage for each job
gen hourwage2016 = base_earn2016/hours2016

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2016==.
collapse (mean) hourwage2016, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2016.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2017
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "G:\Spolis\SPOLISBUS\2017\geconverteerde data\SPOLISBUS2017V2.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2017
rename sbasisuren hours2017
rename sbasisloon base_earn2017
rename sdatumaanvangiko begindate2017
rename sdatumeindeiko enddate2017

* save the earnings data
save "$posted/earnings2017.dta", replace

*-------------------------------------------------------------------------------
* Generate hourly wage for 2017
*-------------------------------------------------------------------------------

* use earnings data
use "$posted/earnings2017.dta", clear

* generate hourly wage for each job
gen hourwage2017 = base_earn2017/hours2017

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2017==.
collapse (mean) hourwage2017, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2017.dta", replace

*-------------------------------------------------------------------------------
* prepare earnings 2018
*-------------------------------------------------------------------------------

* use list of all children in VOCL data 
use "$posted/dataprep_rinlist.dta", clear

* merge relevant earnings variables from SPOLISBUS
merge 1:m rinpersoons rinpersoon ///
using "H:\Andrea\heterog. effects edu\2018-09 comparative paper\00_original_data\SPOLISBUS2018V3.DTA" ///
, keep(match master) keepusing(slningld sbasisloon sbasisuren sdatumaanvangiko sdatumeindeiko) 

* rename variables to identify the correct year
rename slningld earnings2018
rename sbasisuren hours2018
rename sbasisloon base_earn2018
rename sdatumaanvangiko begindate2018
rename sdatumeindeiko enddate2018

* save the earnings data
save "$posted/earnings2018.dta", replace
	
*-------------------------------------------------------------------------------
* Generate hourly wage for 2018
*-------------------------------------------------------------------------------

* use earnings data	
use "$posted/earnings2018.dta", clear

* generate hourly wage for each job
gen hourwage2018 = base_earn2018/hours2018

/* average the hourly wages across jobs and months for each individual to
 obtain an average hourly wage for the entire year*/
drop if hourwage2018==.
collapse (mean) hourwage2018, by(rinpersoon rinpersoons)

* save average hourly wage
save "$posted/hourwage2018.dta", replace	
	
*-------------------------------------------------------------------------------
* Merge hourly wage for each year to our data set
*-------------------------------------------------------------------------------

* switch back to our data set
use "$posted/prepdata_withoutearnings.dta", clear
	
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2007.dta", nogen // 2,887 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2008.dta", nogen // 3,100 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2009.dta", nogen // 3,392 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2010.dta", nogen // 3,524 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2011.dta", nogen // 3,664 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2012.dta", nogen // 3,944 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2013.dta", nogen // 4,249 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2014.dta", nogen // 4,509 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2015.dta", nogen // 4,595 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2016.dta", nogen // 4,651 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2017.dta", nogen // 4,640 missing
merge 1:1 rinpersoon rinpersoons using "$posted/hourwage2018.dta", nogen // 4,752 missing
	

********************************************************************************
* HOOGSTEOPLTAB: MERGE HIGHEST EDUCATION OF CHILD FROM THE REGISTER (2006)
********************************************************************************

/* 
We determine which students have obtained a higher education degree by 2006,
the year before we start to measure earnings
*/

merge 1:1 rinpersoon rinpersoons ///
	using "G:\Onderwijs\HOOGSTEOPLTAB\2003\geconverteerde data\120726 HOOGSTEOPLTAB 2003V1.dta" ///
	, keep(match master) nogen
	
/* 11,367 students can be merged, 7,744 cannot be merged (we will later assume
that those who are missing in the HOOSTEOPLTAB do not have a higher education 
degree */
	
********************************************************************************
* Merge VOCL School careers to the main data set
********************************************************************************

/* 
First recode identifier in the school data set as it differs from main data.
Only keep relevant variables in school data set
*/

preserve

	use "$dataDir\VOCL89\vocl89_schoolelementen_1989-2012.dta", replace 

	drop if rinpersoon==.

	tostring rinpersoon, replace

	keep rinpersoon rinpersoons ondel* exres* klas*

	save "$posted\vocl_school_careers.dta", replace

restore

* Merge school data to our main data set
merge 1:1 rinpersoons rinpersoon using "$posted/vocl_school_careers.dta" ///
	, keep(match master) nogen

// 1,880 individuals have missing data on their later school career
	
********************************************************************************
* merge reference data for the study programme numbers from the register
********************************************************************************

clonevar oplnr = oplnrhb
merge m:1 oplnr using "$dataDir\oplref.dta" ///
	, keep(match master) nogen
	
	
save "$02_posted\1_vocl_merged.dta", replace
log close
