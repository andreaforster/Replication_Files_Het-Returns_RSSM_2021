********************************************************************************
* Study: Heterogeneous Returns to Higher Education
* Data: VOCL 1989, various SSD data sets
* This Dofile: Master dofile with all analyses carried out for the study
********************************************************************************

* Description

/* This dofile summarizes all analyses including robustness checks that were 
carried out for the paper: ``Who Benefits Most from College? Dimensions of 
Selection and Heterogeneous Returns to Higher Education in the United States 
and the Netherlands''*/


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
* Main analysis
********************************************************************************

do "$dofiles/1_hte_vocl_dataprep.do"
do "$dofiles/2_hte_vocl_prepvar.do"
do "$dofiles/3_hte_vocl_sample.do"
do "$dofiles/4_hte_vocl_propensity.do"
do "$dofiles/5_hte_vocl_reshape.do"
do "$dofiles/6_hte_vocl_onedim.do"
do "$dofiles/7_hte_vocl_twodim.do"


********************************************************************************
* Robustness check: interactions with higher order polynominals and bins
********************************************************************************

do "$dofiles/8_hte_vocl_onedim_robust_polynomial.do"
do "$dofiles/8_hte_vocl_twodim_robust_polynomial.do"

********************************************************************************
* Robustness check: Determine college degree at age 28 instead of a single wave
********************************************************************************

/* MAKES MORE SENSE IN NLSY WHERE WE HAVE A LARGER AGE SPANN OF THE STUDENTS 
BUT HERE WE ARE DEALING WITH A COHORT FROM THE SAME SCHOOL CLASS, 
SO THEY ALSO SHOULD BE TREATED THE SAME FOR WHEN OBTAINING A TERTIARY DEGEREE.
THEREFORE, NOT CARRIED OUT HERE */










