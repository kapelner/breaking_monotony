* ---------------
* Regressions
* ---------------


* #################
* Quantity all
* TABLE 3--> tab:quantity_main
* #################
if (1) {
estimates clear

reg induced meaning shredded india if tag_wid, robust
estadd beta
estimates store model1

reg induced meaning shredded india sex i.(age_grp tod dow) if tag_wid, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model2

reg did2 meaning shredded india if tag_wid, robust
estadd beta
estimates store model3

reg did2 meaning shredded india sex i.(age_grp tod dow) if tag_wid, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model4

reg did5  meaning shredded india if tag_wid, robust
estadd beta
estimates store model5

reg did5 meaning shredded india sex i.(age_grp tod dow) if tag_wid, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model6

* tab:quantity_main
esttab model1 model2 model3 model4 model5 model6 using "../output/tab_quantity_main.tex", cells(b(star fmt(3)) se(par fmt(3))) starlevels(* .05 ** .01 *** .001) stats(ageVars todVars dowVars N r2,fmt(2)) keep(meaning shredded india sex *age_grp _cons) style(tex) replace addnotes("* .05 ** .01 *** .001" "This table shows the main treatment effects for the full sample. Columns 1, 3 and 5 only include treatments and country. Columns 2, 4, and 6 control for gender, age categories, time of day, and day of week.")
*"
estimates clear
	
}


* #################
* Quantity by country
* NOT IN PAPER
* tab:quantity_bycountry
* #################
if (1) {
estimates clear

reg induced meaning shredded sex i.(age_grp tod dow) if tag_wid & india == 0, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model1

reg did2 meaning shredded sex i.(age_grp tod dow) if tag_wid & india == 0, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model2

reg did5 meaning shredded sex i.(age_grp tod dow) if tag_wid & india == 0, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model3


reg induced meaning shredded sex i.(age_grp tod dow) if tag_wid & india == 1, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model4

reg did2 meaning shredded sex i.(age_grp tod dow) if tag_wid & india == 1, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model5

reg did5 meaning shredded sex i.(age_grp tod dow) if tag_wid & india == 1, robust
estadd beta
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model6

* tab:quantity_bycountry
esttab model1 model2 model3 model4 model5 model6 using "../output/tab_quantity_bycountry.tex", cells(b(star fmt(3)) se(par fmt(3))) starlevels(* .05 ** .01 *** .001) stats(ageVars todVars dowVars N r2,fmt(2)) keep(meaning shredded sex *age_grp _cons) style(tex) replace addnotes("* .05 ** .01 *** .001" "Cols 1 through 3 show US, 4 through 6 show India. All models control for gender, age categories, time of day, and day of week.")
*"
estimates clear
	
}

* ###############
* Quality (Combined and by country)
* TABLE 4 --> tab:quality_regs_2
* Additional code for sensitivity (not in paper) quality_regs_5
* ###############

* Quality and instruction following by treatment
if (1) {
estimates clear
replace qual_rec_2=qual_rec_2/100
reg qual_rec_2 meaning shredded india, robust cluster(wid)
estadd beta
estimates store model1

reg qual_rec_2 meaning shredded india sex img6to10 img11plus i.(image_name age_grp tod dow), robust cluster(wid)
estadd beta
testparm i.image_name
estadd scalar imgVars = r(p)
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model2

reg qual_rec_2 meaning shredded if india == 0, robust cluster(wid)
estadd beta
estimates store model3

reg qual_rec_2 meaning shredded sex img6to10 img11plus i.(image_name age_grp tod dow) if india == 0, robust cluster(wid)
estadd beta
testparm i.image_name
estadd scalar imgVars = r(p)
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model4

reg qual_rec_2 meaning shredded if india == 1, robust cluster(wid)
estadd beta
estimates store model5

reg qual_rec_2 meaning shredded sex img6to10 img11plus i.(image_name age_grp tod dow) if india == 1, robust cluster(wid)
estadd beta

testparm i.image_name
estadd scalar imgVars = r(p)
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model6

* tab:quality_regs
esttab model1 model2 model3 model4 model5 model6 using "../output/tab_quality_regs_2.tex", cells(b(star fmt(3)) se(par fmt(3))) starlevels(* .05 ** .01 *** .001) stats(imgVars ageVars todVars dowVars N r2,fmt(2)) keep(meaning shredded india sex img6to10 img11plus *age_grp _cons) style(tex) replace addnotes("* .05 ** .01 *** .001" "Columns 1 and 2 include both countries, 3 and 4 only the US and 5 and 6 only India. Columns 1, 3 and 5 only include treatments and country. Columns 2, 4, and 6 control for num of image and particular image, gender, age categories, time of day, and day of week.")
*"
estimates clear

replace qual_rec_5=qual_rec_5/100
reg qual_rec_5 meaning shredded india, robust cluster(wid)
estadd beta
estimates store model1

reg qual_rec_5 meaning shredded india sex img6to10 img11plus i.(image_name age_grp tod dow), robust cluster(wid)
estadd beta
testparm i.image_name
estadd scalar imgVars = r(p)
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model2

reg qual_rec_5 meaning shredded if india == 0, robust cluster(wid)
estadd beta
estimates store model3

reg qual_rec_5 meaning shredded sex img6to10 img11plus i.(image_name age_grp tod dow) if india == 0, robust cluster(wid)
estadd beta
testparm i.image_name
estadd scalar imgVars = r(p)
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model4

reg qual_rec_5 meaning shredded if india == 1, robust cluster(wid)
estadd beta
estimates store model5

reg qual_rec_5 meaning shredded sex img6to10 img11plus i.(image_name age_grp tod dow) if india == 1, robust cluster(wid)
estadd beta

testparm i.image_name
estadd scalar imgVars = r(p)
testparm i.age_grp
estadd scalar ageVars = r(p)
testparm i.tod
estadd scalar todVars = r(p)
testparm i.dow
estadd scalar dowVars = r(p)
estimates store model6

* tab:quality_regs
esttab model1 model2 model3 model4 model5 model6 using "../output/tab_quality_regs_5.tex", cells(b(star fmt(3)) se(par fmt(3))) starlevels(* .05 ** .01 *** .001) stats(imgVars ageVars todVars dowVars N r2,fmt(2)) keep(meaning shredded india sex img6to10 img11plus *age_grp _cons) style(tex) replace addnotes("* .05 ** .01 *** .001" "Columns 1 and 2 include both countries, 3 and 4 only the US and 5 and 6 only India. Columns 1, 3 and 5 only include treatments and country. Columns 2, 4, and 6 control for num of image and particular image, gender, age categories, time of day, and day of week.")
*"
estimates clear
}


* #############
* Survey
* tab:surveyresults
* #############
if (1) {
	est clear
	foreach var in meaningful_level purpose_level enjoyment_level accomplishment_level recognition_level {
		reg `var' meaning meaning_IND shredded shredded_IND india sex if tag_wid
		eststo
	}
	
	* tab:surveyresults
	esttab using "../output/tab_surveyresults.tex", cells(b(star fmt(3)) se(par fmt(3))) starlevels(* .05 ** .01 *** .001) stats(N r2,fmt(2)) keep(meaning meaning_IND shredded shredded_IND india sex _cons) style(tex) mlabels("Meaningful" "Purpose" "Enjoyment" "Accomplishment" "Recognition") replace addnotes("* .05 ** .01 *** .001" "Shows how survey responses differed by treatment, country, gender.")
	*"
	est clear
}


* ########################
* APPENDIX TABLES
* ########################
if (1) {	
* Following instructions matters
	if (1) {
		reg qual_rec_2 used_1st used_last used_allzoom deleted_pts india sex img6to10 img11plus i.(image_name age_grp tod dow), robust cluster(wid)
		estadd beta
		estadd local age = "yes"	
		estadd local image = "yes"	
		estadd local tod_dow = "yes"	
		estimates store model1

		areg qual_rec_2 used_1st used_last used_allzoom deleted_pts img6to10 img11plus i.image_name, robust cluster(wid) absorb(wid)
		estadd beta
		estadd local FE = "yes"
		estimates store model2
		
		reg std_qual_rec_5 used_1st used_last used_allzoom deleted_pts india sex img6to10 img11plus i.(image_name age_grp tod dow), robust cluster(wid)
		estadd beta
		estadd local age = "yes"	
		estadd local image = "yes"	
		estadd local tod_dow = "yes"	
		estimates store model3

		areg std_qual_rec_5 used_1st used_last used_allzoom deleted_pts img6to10 img11plus i.image_name, robust cluster(wid) absorb(wid)
		estadd beta
		estadd local FE = "yes"	
		estimates store model4

		reg std_qual_avgdist used_1st used_last used_allzoom deleted_pts india sex img6to10 img11plus i.(image_name age_grp tod dow), robust cluster(wid)
		estadd beta
		estadd local age = "yes"	
		estadd local image = "yes"	
		estadd local tod_dow = "yes"	
		estimates store model5

		areg std_qual_avgdist used_1st used_last used_allzoom deleted_pts img6to10 img11plus i.image_name, robust cluster(wid) absorb(wid)
		estadd beta
		estimates store model6
		estadd local FE = "yes"	
		
		* tab:qualpredictors
		* Note: This is not included
		esttab model1 model2 model3 model4 model5 model6 using "../output/QualityPredictors.tex", mlabels("Recall 2" "Recall 2" "Recall 5" "Recall 5" "Avg Dist" "Avg Dist") cells(b(star fmt(3)) se(par fmt(3))) starlevels(* .05 ** .01 *** .001) stats(age image tod_dow FE N r2,fmt(2)) keep(used_1stzoom used_lastzoom used_allzoom deleted_pts img6to10 img11plus india sex) style(tex) replace addnotes("* .05 ** .01 *** .001" "Here was see how user behavior predicts various quality measures. Columns 2, 4, and 6 include fixed effects.")
		*"
		estimates clear
	}

}


