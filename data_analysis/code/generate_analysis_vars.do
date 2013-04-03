* ------------------
* Generate variables for regressions(eg. interactions)
* ------------------

* Country interacted with treatment
gen meaning_IND=meaning*india
gen shredded_IND=shredded*india

* Country interacted with covariates
gen sex_IND=sex*india

* Quantities
gen did2=num_imgs>=2 if tag_wid
gen did5=num_imgs>=5 if tag_wid
gen did10=num_imgs>=10 if tag_wid

* Standardize quality metrics
foreach var of varlist qual_rec* qual_avgdist {
	quietly sum `var'
	gen std_`var' = (`var'-r(mean))/r(sd)
}

* Person-specific quality
egen qual_rec_2_by_person=mean(qual_rec_2), by(wid)
egen qual_rec_5_by_person=mean(qual_rec_5), by(wid)

* Zooming and carefulness
gen onezoom= (used_1stzoom | used_lastzoom)

gen very_careful=.
replace very_careful=1 if is_image==1 & used_allzoom==1 & deleted_pts==1
replace very_careful=0 if is_image==1 & very_careful==.

* Experience labeling
gen experience=.
replace experience=1 if inrange(img_order,1,5)
replace experience=2 if inrange(img_order,6,10)
replace experience=3 if img_order>=11
cap label drop experience
label define experience 1 "1_1-5" 2 "2_6-10" 3 "3_11+"
label values experience experience

gen img1to5=experience==1
gen img6to10=experience==2
gen img11plus=experience==3

* Image order squared
gen img_order2=img_order^2

* Speed labeling
gen speed_secs=secs_to_label
gen speed_secs2=speed_secs^2
