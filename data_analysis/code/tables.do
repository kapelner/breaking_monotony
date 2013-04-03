* -----------------------------
* Tables
* -----------------------------

*########################
* Table with basic summary stats
* TABLE 1 -->
* tab:summary_stats
*########################
if (1) {
* Create columns (indicated by "_grp_" variable)
gen _grp_1= (trt==2 & tag_wid==1)
gen _grp_2= (trt==1 & tag_wid==1)
gen _grp_3= (trt==0 & tag_wid==1)
gen _grp_4= (country==0 & tag_wid==1)
gen _grp_5= (country==1 & tag_wid==1)

loc num_cols = 5
loc num_rows = 15

mat table_summ_stats = J(`num_rows',`num_cols',.)

* Create new variables for table
gen num_imgs_ifnon0 = num_imgs if num_imgs > 0 


forvalues c = 1/`num_cols' {
	* Variables used in summary statistics
	* --------
	* Quantity variables: num_imgs_ifnon0, induced, did2, did5
	* Quality variables: qual_rec2, qual_rec5
	* Demographics: sex, age
	* Other: hourly wage, meaningful level
	
	* -------------------
	* Quantity variables
	* -------------------

	* Induced to work
	quietly sum induced if (_grp_`c'==1) 
	mat table_summ_stats[1,`c'] = round(r(mean),.001)

	* num_imgs_ifnon0
	quietly sum num_imgs_ifnon0 if (_grp_`c'==1) 
	mat table_summ_stats[2,`c'] = round(r(mean),.001)
	mat table_summ_stats[3,`c'] = round(r(sd),.001)

	* Labeled 2 or more images
	quietly sum did2 if (_grp_`c'==1) 
	mat table_summ_stats[4,`c'] = round(r(mean),.001)

	* Labeled 5 or more images
	quietly sum did5 if (_grp_`c'==1) 
	mat table_summ_stats[5,`c'] = round(r(mean),.001)

	* -------------------
	* Quality variables
	* -------------------

	* Recall at 5 pixels
	quietly sum qual_rec_5_by_person if (_grp_`c'==1)
	mat table_summ_stats[6,`c'] = round(r(mean)/100,.001)
	mat table_summ_stats[7,`c'] = round(r(sd)/100,.001)
	
	* Recall at 2 pixels
	quietly sum qual_rec_2_by_person if (_grp_`c'==1) 
	mat table_summ_stats[8,`c'] = round(r(mean)/100,.001)
	mat table_summ_stats[9,`c'] = round(r(sd)/100,.001)
	
	* -------------------
	* Demographics
	* -------------------

	* Gender
	quietly sum sex if (_grp_`c'==1)
	mat table_summ_stats[10,`c'] = round(r(mean),.001)

	* Age
	quietly sum age if (_grp_`c'==1) 
	mat table_summ_stats[11,`c'] = round(r(mean),.1)
	mat table_summ_stats[12,`c'] = round(r(sd),.1)
	

	* -------------------
	* Other
	* -------------------

	quietly sum meaningful_level if (_grp_`c'==1) 
	mat table_summ_stats[13,`c'] = round(r(mean),.01)
	mat table_summ_stats[14,`c'] = round(r(sd),.01)

	* N
	quietly sum wid if (_grp_`c'==1)
	mat table_summ_stats[15,`c'] = r(N)
}

mat rownames table_summ_stats= "PctInduced" "ImgsifNon0" "ImgsifNon0-sd" "Did2" "Did5" "Rec5" "Rec5-sd"  "Rec2" "Rec2-sd" "Gender" "Age" "Age-sd" "SurveyMeaning" "SurveyMeaning-sd" "Ntot"
mat colnames table_summ_stats= Shredded ZeroContext Meaning USonly INonly

mat list table_summ_stats
	
* Export summary statistics table
* TABLE 1--> tab:summary_stats
outtable using "../output/tab_summary_stats", mat(table_summ_stats) asis replace caption("Summary statistics, by country and treatment") clabel("tab:summary_stats")
}	
		
* Induced to work
* -----------------
tab trt country if tag_wid
table trt country if tag_wid, c(mean induced) format(%10.3f) col

* Table for percent "induced to work" by trt and country
* tab:sumstats_induced
if (1) {
mat InducedByGroup=(.,.,.\.,.,.\.,.,.)

quietly sum induced if trt==0 & country==0 & tag_wid==1
mat InducedByGroup[1,1]=round(r(mean),.001)
quietly sum induced if trt==1 & country==0 & tag_wid==1
mat InducedByGroup[2,1]=round(r(mean),.001)
quietly sum induced if trt==2 & country==0 & tag_wid==1
mat InducedByGroup[3,1]=round(r(mean),.001)

quietly sum induced if trt==0 & country==1 & tag_wid==1
mat InducedByGroup[1,2]=round(r(mean),.001)
quietly sum induced if trt==1 & country==1 & tag_wid==1
mat InducedByGroup[2,2]=round(r(mean),.001)
quietly sum induced if trt==2 & country==1 & tag_wid==1
mat InducedByGroup[3,2]=round(r(mean),.001)

quietly sum induced if trt==0 & tag_wid==1
mat InducedByGroup[1,3]=round(r(mean),.001)
quietly sum induced if trt==1 & tag_wid==1
mat InducedByGroup[2,3]=round(r(mean),.001)
quietly sum induced if trt==2 & tag_wid==1
mat InducedByGroup[3,3]=round(r(mean),.001)

mat rownames InducedByGroup= ZeroContext Meaning Shredded
mat colnames InducedByGroup= US India Total

* tab:sumstats_induced
outtable using "../output/InducedByGroup", mat(InducedByGroup) asis replace caption("Mean Percent Induced, by country and treatment") clabel("InducedByGroup")

}

	
* Number of images
* -----------------
	* Overall
	table trt country if tag_wid, c(mean num_imgs) format(%10.2f) col

	* Table for number of images by trt and country
	* tab:sumstats_numimgs
	if (1) {
	mat ImgsByGroup=(.,.,.\.,.,.\.,.,.)

	quietly sum num_imgs if trt==0 & country==0 & tag_wid==1
	mat ImgsByGroup[1,1]=round(r(mean),.1)
	quietly sum num_imgs if trt==1 & country==0 & tag_wid==1
	mat ImgsByGroup[2,1]=round(r(mean),.1)
	quietly sum num_imgs if trt==2 & country==0 & tag_wid==1
	mat ImgsByGroup[3,1]=round(r(mean),.1)

	quietly sum num_imgs if trt==0 & country==1 & tag_wid==1
	mat ImgsByGroup[1,2]=round(r(mean),.1)
	quietly sum num_imgs if trt==1 & country==1 & tag_wid==1
	mat ImgsByGroup[2,2]=round(r(mean),.1)
	quietly sum num_imgs if trt==2 & country==1 & tag_wid==1
	mat ImgsByGroup[3,2]=round(r(mean),.1)

	quietly sum num_imgs if trt==0 & tag_wid==1
	mat ImgsByGroup[1,3]=round(r(mean),.1)
	quietly sum num_imgs if trt==1 & tag_wid==1
	mat ImgsByGroup[2,3]=round(r(mean),.1)
	quietly sum num_imgs if trt==2 & tag_wid==1
	mat ImgsByGroup[3,3]=round(r(mean),.1)

	mat rownames ImgsByGroup= ZeroContext Meaning Shredded
	mat colnames ImgsByGroup= US India Total
	
	* tab:sumstats_numimgs
	outtable using "../output/ImgsByGroup", mat(ImgsByGroup) asis replace caption("Mean Total Images, by country and treatment") clabel("ImgsByGroup")
	}	
	
	* COP
	table trt country if tag_wid, c(mean num_imgs) format(%10.2f) col

	* Table for number of images (COP) by trt and country
	* tab:sumstats_numimgsCOP
	if (1) {
	mat ImgsByGroup_COP=(.,.,.\.,.,.\.,.,.)

	quietly sum num_imgs if trt==0 & country==0 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[1,1]=round(r(mean),.1)
	quietly sum num_imgs if trt==1 & country==0 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[2,1]=round(r(mean),.1)
	quietly sum num_imgs if trt==2 & country==0 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[3,1]=round(r(mean),.1)

	quietly sum num_imgs if trt==0 & country==1 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[1,2]=round(r(mean),.1)
	quietly sum num_imgs if trt==1 & country==1 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[2,2]=round(r(mean),.1)
	quietly sum num_imgs if trt==2 & country==1 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[3,2]=round(r(mean),.1)

	quietly sum num_imgs if trt==0 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[1,3]=round(r(mean),.1)
	quietly sum num_imgs if trt==1 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[2,3]=round(r(mean),.1)
	quietly sum num_imgs if trt==2 & tag_wid==1 & induced==1
	mat ImgsByGroup_COP[3,3]=round(r(mean),.1)

	mat rownames ImgsByGroup_COP= ZeroContext Meaning Shredded
	mat colnames ImgsByGroup_COP= US India Total

	* tab:sumstats_numimgsCOP
	outtable using "../output/ImgsByGroup_COP", mat(ImgsByGroup_COP) asis replace caption("Mean Total Images (COP), by country and treatment") clabel("ImgsByGroup_COP")
	}		


* Quality of images
* ------------------

	* Overall
	table trt country if tag_wid, c(mean qual_rec_2) format(%10.2f) col

	* Table for quality (rec2) by trt and country
	* tab:sumstats_qual
	if (1) {
	mat QualByGroup=(.,.,.\.,.,.\.,.,.)

	quietly sum qual_rec_2 if trt==0 & country==0 & tag_wid==1
	mat QualByGroup[1,1]=round(r(mean),.1)
	quietly sum qual_rec_2 if trt==1 & country==0 & tag_wid==1
	mat QualByGroup[2,1]=round(r(mean),.1)
	quietly sum qual_rec_2 if trt==2 & country==0 & tag_wid==1
	mat QualByGroup[3,1]=round(r(mean),.1)

	quietly sum qual_rec_2 if trt==0 & country==1 & tag_wid==1
	mat QualByGroup[1,2]=round(r(mean),.1)
	quietly sum qual_rec_2 if trt==1 & country==1 & tag_wid==1
	mat QualByGroup[2,2]=round(r(mean),.1)
	quietly sum qual_rec_2 if trt==2 & country==1 & tag_wid==1
	mat QualByGroup[3,2]=round(r(mean),.1)

	quietly sum qual_rec_2 if trt==0 & tag_wid==1
	mat QualByGroup[1,3]=round(r(mean),.1)
	quietly sum qual_rec_2 if trt==1 & tag_wid==1
	mat QualByGroup[2,3]=round(r(mean),.1)
	quietly sum qual_rec_2 if trt==2 & tag_wid==1
	mat QualByGroup[3,3]=round(r(mean),.1)

	mat rownames QualByGroup= ZeroContext Meaning Shredded
	mat colnames QualByGroup= US India Total
	
	* tab:sumstats_qual
	outtable using "../output/QualByGroup", mat(QualByGroup) asis replace caption("Mean Quality (rec2), by country and treatment") clabel("QualByGroup")
	}	
	
