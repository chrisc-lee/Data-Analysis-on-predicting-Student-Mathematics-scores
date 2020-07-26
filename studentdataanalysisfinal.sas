/*Import for the original raw data for use in model selection process*/
proc import datafile= "student-mat.csv" 
			out=student
			dbms=CSV 
			replace;
     		getnames=YES;
     		datarow=2;
run;
/*Import of the data to change to encode dummy variables and use for regression analysis*/
data studentfile;
infile 'student-mat.csv' dlm="," firstobs=2;
input school$ sex$ age address$ famsize$ Pstatus$ Medu Fedu Mjob$ Fjob$ reason$ guardian$ traveltime studytime failures schoolsup$ famsup$ paid$ activities$ nursery$ higher$ internet$ romantic$ famrel freetime goout Dalc Walc health absences G1$ G2$ G3;
run;
data student1;
set studentfile;
/*Create dummy variables for mother's education, mother's job, has a romantic partner, goes out, and has free time*/
if Medu = 0 then Medu_0 = 1; 
    else Medu_0 = 0;
  if Medu = 1 then Medu_1 = 1; 
    else Medu_1 = 0;
  if Medu = 2 then Medu_2 = 1; 
    else Medu_2 = 0;
  if Medu = 3 then Medu_3 = 1; 
    else Medu_3 = 0;
  if Medu = 4 then Medu_4 = 1; 
    else Medu_4 = 0;
if Mjob = '"at_home' then Mjob_at_home = 1; 
    else Mjob_at_home = 0;
  if Mjob = '"health"' then Mjob_health = 1; 
    else Mjob_health = 0;
  if Mjob = '"other"' then Mjob_other = 1; 
    else Mjob_other = 0;
  if Mjob = '"service' then Mjob_services = 1; 
    else Mjob_services = 0;
  if Mjob = '"teacher' then Mjob_teacher = 1; 
    else Mjob_teacher = 0;
if romantic = '"no"' then romantic_no = 1; 
    else romantic_no = 0;
  if romantic = '"yes"' then romantic_yes = 1; 
    else romantic_yes = 0;
if goout = 1 then goout_1 = 1; 
    else goout_1 = 0;
  if goout = 2 then goout_2 = 1; 
    else goout_2 = 0;
  if goout = 3 then goout_3 = 1; 
    else goout_3 = 0;
  if goout = 4 then goout_4 = 1; 
    else goout_4 = 0;
  if goout = 5 then goout_5 = 1; 
    else goout_5 = 0;
if freetime = 1 then freetime_1 = 1; 
    else freetime_1 = 0;
  if freetime = 2 then freetime_2 = 1; 
    else freetime_2 = 0;
  if freetime = 3 then freetime_3 = 1; 
    else freetime_3 = 0;
  if freetime = 4 then freetime_4 = 1; 
    else freetime_4 = 0;
  if freetime = 5 then freetime_5 = 1; 
    else freetime_5 = 0;
/*Remove elements 136, 141, 169, 260, 300 because they were determined to be outliers*/
if _n_ eq 136 then delete;
if _n_ eq 141 then delete;
if _n_ eq 169 then delete;
if _n_ eq 260 then delete;
if _n_ eq 300 then delete;
run;
/*print out the raw data*/
proc print data = student;
run;
/*print out the data after removing outliers*/
proc print data = student1;
run;
/*Utilized glmselect procedure to perform stepwise regression. Chose this method over using proc stepwise since this method would allow for a way to not have to manually encode all the dummy variables pre-model selection*/
proc glmselect data=student;
	class school sex age address famsize Pstatus Medu Fedu Mjob Fjob reason guardian traveltime studytime schoolsup famsup paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health;
	model G3 = school sex age address famsize Pstatus Medu Fedu Mjob Fjob reason guardian traveltime studytime failures schoolsup famsup paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health absences / selection=stepwise(select=SL SLE=0.05 SLS=0.05);
run;
/*Checked enitre model*/
proc glm data=student  plots=all;
	class school sex age address famsize Pstatus Medu Fedu Mjob Fjob reason guardian traveltime studytime schoolsup famsup paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health;
	model G3 = school sex age address famsize Pstatus Medu Fedu Mjob Fjob reason guardian traveltime studytime failures schoolsup famsup paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health absences;
run;
/*Checked resulting model suggested by glmselect stepwise regression procedure*/
proc glm data=student  plots=all;
	class school sex age address famsize Pstatus Medu Fedu Mjob Fjob reason guardian traveltime studytime schoolsup famsup paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health;
	model G3 = Medu Mjob failures romantic freetime goout / solution p clm cli clparm alpha=0.05;
run;
/*Resulting selected model using reg procedore to perform analysis. Chose alpha = 0.05 for all analyses*/
proc reg data=student1;
 	model G3 = Medu_1 Medu_2 Medu_3 Medu_4 Mjob_health Mjob_other Mjob_services Mjob_teacher failures romantic_yes freetime_2 freetime_3 freetime_4 freetime_5 goout_2 goout_3 goout_4 goout_5 / lackfit dw dwprob vif p clm cli clb alpha=0.05 r partial;
run;
/*Used corr procedure to check for multlicollinearity*/
proc corr data=student1;
	var Medu_1 Medu_2 Medu_3 Medu_4 Mjob_health Mjob_other Mjob_services Mjob_teacher failures romantic_yes freetime_2 freetime_3 freetime_4 freetime_5 goout_2 goout_3 goout_4 goout_5;
run;


