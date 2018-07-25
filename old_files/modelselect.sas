data raw;
	set 'H:\\SAS\474\Stat574ProjectData.sas7bdat';
run;
proc univariate data=raw4;
	histogram tuitionfee02_tf tuitionfee03_tf total_student_aid_per_student research01_fasb acad_supp_per_student 
		stud_serv_per_student inst_supp_per_student inst_cost_per_student
		tuition_share_indistrict tuition_share_instate tuition_share_outofstate tuition_avg;
run;
proc freq data=raw4;
	tables enrollment control census_region iclevel research;
run;
data raw2;
	set raw;
	if control = 3 then DELETE;
	if iclevel = 3 then DELETE;
run;
data raw3;
	set raw2;
	/*if tuitionfee02_tf > 4000 then DELETE;
	if tuitionfee02_tf < -2000 then DELETE;
	if tuitionfee03_tf > 4500 then DELETE;
	if tuitionfee03_tf < -4500 then DELETE;*/
	if new_tuition_avg < -9000 then DELETE;
	if new_tuition_avg > 12000 then DELETE;
	if total_student_aid_per_student > 2000 then DELETE;
	if total_student_aid_per_student < -1500 then DELETE;
	if acad_supp_per_student > 2250 then DELETE;
	if acad_supp_per_student < -2250 then DELETE;
	if stud_serv_per_student > 1200 then DELETE;
	if stud_serv_per_student < -1200 then DELETE;
	if inst_supp_per_student > 1000 then DELETE;
	if inst_supp_per_student < -1000 then DELETE;
	if inst_cost_per_student > 2500 then DELETE;
	if inst_cost_per_student < -2500 then DELETE;
	/*if tuition_avg < -1400 then DELETE;
	if tuition_avg > 3000 then DELETE;*/
run;
data raw4;
	set raw3;
	if research01_fasb > 0 then research = 1;
	else if research01_fasb = 0 then research = 0;
	else research = -1;
	if census_region = 4 then census4 = 1;
	else census4=0;
	if census_region = 3 then census3 = 1;
	else census3=0;
	if research = 1 then research1 = 1;
	else research1 = 0;
	if research = -1 then researchN1 = 1;
	else researchN1 = 0;
run;
/*proc standard data=raw4 mean = 0 std=1 out=raw5;
	var tuitionfee02_tf tuitionfee03_tf total_student_aid_per_student;
run;*/
/*Binomial wiht link logit*/
proc logistic data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control research census3 census4 new_tuition_avg
		total_student_aid_per_student acad_supp_per_student stud_serv_per_student inst_supp_per_student
		inst_cost_per_student/ selection = backward slstay = 0.1;
run;
/*Binomial with Link Probit - Step 1*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control research census3 census4 new_tuition_avg 
		total_student_aid_per_student acad_supp_per_student stud_serv_per_student inst_supp_per_student
		inst_cost_per_student/dist=binomial link=probit;
run;
/* Step 2 - Remove stud_serv_per_student */
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control research census3 census4 new_tuition_avg 
		total_student_aid_per_student acad_supp_per_student inst_supp_per_student
		inst_cost_per_student/dist=binomial link=probit;
run;
/* Step 3 - Remove acad_supp_per_student */
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control research census3 census4 new_tuition_avg 
		total_student_aid_per_student inst_supp_per_student
		inst_cost_per_student/dist=binomial link=probit;
run;
/* Step 4 - Remove inst_cost_per_student */
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control research census3 census4 new_tuition_avg 
		total_student_aid_per_student inst_supp_per_student
		/dist=binomial link=probit;
run;
/* For alpha = 0.10 */
/* Step 5 - Remove control */
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel research census3 census4 new_tuition_avg 
		total_student_aid_per_student inst_supp_per_student
		/dist=binomial link=probit;
run;

/*Eliminate NONE*/
/*Binomial with Link Indentity - Step 1*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg 
		total_student_aid_per_student acad_supp_per_student stud_serv_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=binomial link=identity;
run;
/*Eliminate stud_serv_per_student*/
/*Binomial with Link Indentity - Step 2*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg 
		total_student_aid_per_student acad_supp_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=binomial link=identity;
run;
/*Eliminate acad_supp_per_student*/
/*Binomial with Link Indentity - Step 3*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg 
		total_student_aid_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=binomial link=identity;
run;
/*Eliminate inst_cost_per_student*/
/*Binomial with Link Indentity - Step 4*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg 
		total_student_aid_per_student inst_supp_per_student
		/ dist=binomial link=identity;
run;

/*Eliminate NONE*/
/*Normal with Identity Link aka LSR - Step 1*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student acad_supp_per_student stud_serv_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=normal link=identity;
run;
/*Eliminate stud_serv_per_student*/
/*Normal with Identity Link aka LSR - Step 2*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student acad_supp_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=normal link=identity;
run;
/*Eliminate acad_supp_per_student*/
/*Normal with Identity Link aka LSR - Step 3*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=normal link=identity;
run;
/*Eliminate inst_cost_per_student*/
/*Normal with Identity Link aka LSR - Step 4*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=normal link=identity;
run;
/*For alpha = 0.10*/
/*Eliminate control*/
/*Normal with Identity Link aka LSR - Step 5*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=normal link=identity;
run;

/*Eliminate NONE*/
/*Poisson with Log Link - Step 1*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student acad_supp_per_student stud_serv_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=poisson link=log;
run;
/*Eliminate stud_serv_per_student*/
/*Poisson with Log Link - Step 2*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student acad_supp_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=poisson link=log;
run;
/*Eliminate acad_supp_per_student*/
/*Poisson with Log Link - Step 3*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=poisson link=log;
run;
/*Eliminate inst_cost_per_student*/
/*Poisson with Log Link - Step 4*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref)  control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=poisson link=log;
run;
/*Eliminate control*/
/*Poisson with Log Link - Step 5*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=poisson link=log;
run;
/*Eliminate research = 1*/
/*Poisson with Log Link - Step 6*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref);
	model enrollment = iclevel census3 census4 researchN1 new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=poisson link=log;
run;
/*For alpha = 0.10*/
/*Eliminate research = -1*/
/*Poisson with Log Link - Step 7*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref);
	model enrollment = iclevel census3 census4 new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=poisson link=log;
run;
/*Eliminate total_student_aid_per_student*/
/*Poisson with Log Link - Step 8*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref);
	model enrollment = iclevel census3 census4 new_tuition_avg
		inst_supp_per_student
		/ dist=poisson link=log;
run;

/*Eliminate NONE*/
/*Negative Binomial with Log Link - Step 1*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student acad_supp_per_student stud_serv_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=negbin link=log;
run;
/*Eliminate stud_serv_per_student*/
/*Negative Binomial with Log Link - Step 2*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student acad_supp_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=negbin link=log;
run;
/*Eliminate acad_supp_per_student*/
/*Negative Binomial with Log Link - Step 3*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		inst_cost_per_student
		/ dist=negbin link=log;
run;
/*Eliminate inst_cost_per_student*/
/*Negative Binomial with Log Link - Step 4*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) control (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel control census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=negbin link=log;
run;
/*Eliminate control*/
/*Negative Binomial with Log Link - Step 5*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref) research (ref='0' param=ref);
	model enrollment = iclevel census3 census4 research new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=negbin link=log;
run;
/*Eliminate research = 1*/
/*Negative Binomial with Log Link - Step 6*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref);
	model enrollment = iclevel census3 census4 researchN1 new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=negbin link=log;
run;
/*For alpha = 0.10*/
/*Eliminate research = -1*/
/*Negative Binomial with Log Link - Step 7*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref);
	model enrollment = iclevel census3 census4 new_tuition_avg
		total_student_aid_per_student inst_supp_per_student
		/ dist=negbin link=log;
run;
/*Eliminate total_student_aid_per_student*/
/*Negative Binomial with Log Link - Step 8*/
proc genmod data=raw4 DESCENDING;
	class iclevel (ref='1' param=ref);
	model enrollment = iclevel census3 census4 new_tuition_avg
		inst_supp_per_student
		/ dist=negbin link=log;
run;
