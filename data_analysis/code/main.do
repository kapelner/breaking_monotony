* ***************************
* Do file for analysis
* Run within the "code" folder
* ***************************
* These files create all of the tables and figures in the paper. Comments within the do file identify each of the tables.
* Note: Some additional tables/graphs are also outputted as sensitivities that do not appear in the paper

* Download some supplemental STATA commands
	* ssc install outtable
	* net install st0085_1.pkg


* BEGIN
*********
set more off
* Create log

cap log close
set logtype text
log using "../logs/analysis.txt", replace


* Open main data file
use "../data/alldata.dta", clear

do "generate_analysis_vars.do"

save "../data/alldata_analysis_ready.dta", replace

* Summary statistic and other non-regression tables
do "tables.do"

* Regressions, figures and graphs
do "regressions.do"
do "figs_graphs.do"

log close
