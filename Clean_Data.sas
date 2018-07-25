/*/ Change the file path to where ever you save all your SAS Files./*/
libname project5 '/folders/myfolders/tuition_study';
/*/ Change the filepath to where ever you saved the 'delta_public_00_12.sas7bdat'
file.  It took about 2 1/2 minutes to load the whole data set. /*/
data raw;
  set '/folders/myfolders/tuition_study/delta_public_00_12.sas7bdat';
run;
/*/ Create any custom variables here/*/
data raw01;
	set raw;
	total_student_aid_per_student = grant07/fte_count;
	research_per_student = research01_fasb/fte_count;
	public_ser_per_student = pubserv01_fasb/fte_count;
	acad_supp_per_student = acadsupp01_fasb/fte_count;
	stud_serv_per_student = studserv01_fasb/fte_count;
	inst_supp_per_student = instsupp01_fasb/fte_count;
	oper_cost_per_student = opermain01_fasb/fte_count; 
	inst_cost_per_student = instruction01_fasb/fte_count;
	total_cost_per_student = total01/fte_count;
	new_tuition_avg = tuition03/fte_count;
	/*tuition_share_indistrict = (tuitionfee01_tf * fall_cohort_num_indistrict); 
	tuition_share_instate = (tuitionfee02_tf * fall_cohort_num_instate); 
	tuition_share_outofstate = (tuitionfee03_tf * fall_cohort_num_outofstate);
	tuition_avg = (tuition_share_indistrict + tuition_share_instate + tuition_share_outofstate) 
		/ (fall_cohort_num_indistrict + fall_cohort_num_instate + fall_cohort_num_outofstate);*/
run;
/*/ put any CATEGORICAL variables you want in the final data set here/*/
data cataupdate;
	set raw01;
	keep unitid census_region control iclevel;
run;
/*/ sorts the cataupdate data set by unitid for later when we add the categorical variables back into the dataset/*/
proc sort data=cataupdate;
	by unitid;
run;
/*/ Change the variables in the KEEP statement to change the variables in the dataset./*/
data step2012;
	set raw01;
	IF matched_n_02_12_11 = 0 THEN DELETE;
	IF academicyear ^= 2012 THEN DELETE; 
	keep unitid academicyear instname fte_count 
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
/*/ Change the variables in the KEEP statement to change the variables in the dataset./*/
data step2011;
	set raw01;
	IF matched_n_02_12_11 = 0 THEN DELETE;
	IF academicyear ^= 2011 THEN DELETE;
	keep unitid academicyear instname fte_count 
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
data step2010;
	set raw01;
	IF matched_n_02_12_11 = 0 THEN DELETE;
	IF academicyear ^= 2010 THEN DELETE;
	keep unitid academicyear instname fte_count 
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
/*/ Make research 0 if missing /*/
data step2012A;
	set step2012;
	IF research01_fasb = . then research01_fasb = 0;
run;
data step2011A;
	set step2011;
	IF research01_fasb = . then research01_fasb = 0;
run;
data step2010A;
	set step2010;
	IF research01_fasb = . then research01_fasb = 0;
run;
/*/ next three data steps deletes any row with a missing data value/*/
data step2012B;
	set step2012A;
	if nmiss(of _numeric_) + cmiss(of _character_) > 0 then delete;
run;
data step2011B;
	set step2011A;
	if nmiss(of _numeric_) + cmiss(of _character_) > 0 then delete;
run;
data step2010B;
	set step2010A;
	if nmiss(of _numeric_) + cmiss(of _character_) > 0 then delete;
run;
/*/ next three proc sort steps sorts the corresponding steps by unit id for the proc compare step/*/
proc sort data=step2010B;
	by unitid;
run;
proc sort data=step2011B;
	by unitid;
run;
proc sort data=step2012B;
	by unitid;
run;
/*/ This steps takes all of our variables (even categorical variables) and finds the difference between the year 2012
and 2011 (2012 - 2011).  It takes the results and puts them in a data set called "diff".  We will fix the categorical 
variables later in the program/*/
proc compare base=step2010B compare=step2011B
	out=diff1011 outdif outbase outcomp noprint;
	id unitid;
run;
proc compare base=step2011B compare=step2012B
	out=diff1112 outdif outbase outcomp noprint;
	id unitid;
run;

/*/ Sets a variable Kill equal to one if the institution names changed from 2011 to 2012/*/
data step21011;
	set diff1011;
	if _TYPE_ = "DIF" and instname ^= ".................................................................................................." 
	then kill=1;
	else kill=0;
run;
data step21112;
	set diff1112;
	if _TYPE_ = "DIF" and instname ^= ".................................................................................................." 
	then kill=1;
	else kill=0;
run;
/*/ Deletes any institution where the name changed from 2011 to 2012/*/
data step31011;
	set step21011;
	if kill=1 then DELETE;
run;
data step31112;
	set step21112;
	if kill=1 then DELETE;
run;
/*/ Only keeps the differences between 2011 and 2012/*/
data step41011;
	set step31011;
	if _TYPE_^= "DIF" then DELETE;
run;
data step41112;
	set step31112;
	if _TYPE_^= "DIF" then DELETE;
run;
/*/ Change the variables in the KEEP statement to change the variables in the dataset./*/
data step51011;
	set step41011;
	keep unitid fte_count 
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
data step51112;
	set step41112;
	keep unitid fte_count 
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
/*/This step fixes the categorical variables that got messed up with the proc compare.  Note: it adds back in all the
institutions, which get deleted in the next step/*/
data step61011;
	update step51011 cataupdate;
	by unitid;
run;
data step61112;
	update step51112 cataupdate;
	by unitid;
run;
/*/ Deletes all the institutions that got added back in by step 6/*/
data step71011;
	set step61011;
	if nmiss(of _numeric_) > 0 then delete;
run;
data step71112;
	set step61112;
	if nmiss(of _numeric_) > 0 then delete;
run;
/*/ makes enrollment a categorical variable (=1 if enrollment increased, =0 if there are no changes or decrease)/*/
data step81112;
	set step71112;
	if fte_count > 0 then enrollment = 1;
	else enrollment = 0;
	keep unitid enrollment;
run;
data step81011;
	set step71011;
	keep unitid 
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
data stat574projectdata;
	merge step81011 step81112;
	by unitid;
	if nmiss(of _numeric_) > 0 then delete;
run;
data check;
	set raw01;
	if unitid ^= "434751" then DELETE;
	keep unitid fte_count instname academicyear
		new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
/*/ Saves a copy of the final data set in the library specified in the very first line so you don't have to run
this program every time you want to work with the data/*/
proc copy inlib=work outlib=project5;
  select stat574projectdata;
run;
/*/ Change the variables in the histogram statement to change the variables in the dataset.
This gets us our summary statistics and histograms of our variables/*/
proc univariate data=stat574projectdata;
   histogram new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region enrollment iclevel;
run;

proc freq data=stat574projectdata;
	tables enrollment control census_region iclevel;
run;
proc corr data=stat574projectdata outp=corr;
	var enrollment new_tuition_avg total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student control census_region iclevel;
run;
