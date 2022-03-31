libname clean '/home/u59469373/Data Preperation and Handling/BAN110/Project';

/* Data Import  */
proc import datafile="/home/u59469373/Data Preperation and Handling/BAN110/Project/master2.csv" 
out=clean.suicideRates 
dbms=CSV replace;
guessingrows=max;
run;

proc print data=clean.suiciderates(obs=50);
run;

proc print data=clean.suiciderates(obs=50);
where country = "Antigua and Barbuda";
run;



/* Check and correct errors when necessary for both Categorical and Numerical - Aakash */
proc contents data=clean.suiciderates varnum;
run;

/* Column type conversion*/
data clean.suicideRates;
set clean.suicideRates;

instant = _n_;

gdp_for_year_dollars1 = input(gdp_for_year_dollars,comma15.);
drop gdp_for_year_dollars;
rename gdp_for_year_dollars1 = gdp_for_year_dollars;
run;

proc print data=clean.suiciderates(obs=50);
run;



/* For each categorical variable - List of Values and their Freq Table plus missing values */
proc freq data=clean.suiciderates;
tables _character_ / missing nocum;
run;

/* For each Numerical variables */
proc means data=clean.suiciderates n min max mean nmiss q1 q3 range;
run;
proc univariate data=clean.suiciderates;
run;

/* 
proc report data=clean.suiciderates;
run;
*/

/* Check for missing values  & Treat missing values  - Bhakti */

/*List of numeric attributes:*/
Proc means data=clean.suicideRates n nmiss;
run;


/* Missing Values */
title "Checking Missing Values";
 proc format;
 value $Count_Missing ' ' = 'Missing'
 other = 'Notmissing';
 value Count_Missing . = 'Missing'
 other = 'Notmissing';
 run;
 proc freq data=clean.suiciderates;
 tables _character_ / nocum missing;
 format _character_ $Count_Missing.;
 tables _numeric_ / nocum missing;
 format _numeric_ Count_Missing.;
 run;


data clean.testMissing;
set clean.suiciderates;
retain _HDI_for_Year;
if not missing(HDI_for_Year) then _HDI_for_Year=HDI_for_Year;
else HDI_for_Year=_HDI_for_Year;
drop _HDI_for_Year;
run;

/*
data clean.suicideRates2;
set clean.suicideRates;
if missing(HDI_for_year) then do HDI_for_year= 'missing';
end;
run;
*/

PROC SORT data=clean.suiciderates;
by country year ;
run;

/* Examining missing values: */

title HDI_for_year;
proc freq data=clean.suiciderates;
table HDI_for_Year;
run;


proc univariate data=clean.suiciderates PLOT;
VAR HDI_for_year;
run;

data clean.suiciderates1;
set clean.suiciderates;
HDI_for_year = input( HDI_for_year,best12.);
run;

proc contents data=clean.suiciderates1;
run;

/*
proc hpimpute data=clean.suiciderates1 out=clean.suiciderates_imputed;
input HDI_for_year;
impute HDI_for_year / method=pmedian;
run;



data clean.suiciderates2(drop= M_HDI_for_year IM_HDI_for_year);
Merge clean.suiciderates1 clean.suiciderates_imputed;
run;



data clean.suiciderates;
x=Country*5;
run;

*/
/* Imputing Missing Values */
data clean.suiciderates1_fin;
   update clean.suiciderates (obs=0) clean.suiciderates;
   by country;
   output;
run;

data clean.suicideRates;
set clean.suiciderates1_fin;
if missing(HDI_for_year) then do HDI_for_year= 0;
end;
run;

 proc freq data=clean.suiciderates;
 tables _character_ / nocum missing;
 format _character_ $Count_Missing.;
 tables _numeric_ / nocum missing;
 format _numeric_ Count_Missing.;
 run;

title "Dataset after Imputing the missing values";
proc print data=clean.suiciderates(obs=5);
*where year=2006;
run;

/*  Create one or more derived variables or combine values of a categorical variable. & Detect and remove outliers - Chin Hooi */
/*  */

/*Rename column name to remove space and other symbol 
data clean.suicideRates;
set clean.suicideRates;
rename
'suicides/100k pop'n=suicidesPer100k_pop
'country-year'n=country_year
'HDI for year'n=HDI_for_year
' gdp_for_year ($) 'n=gdp_for_year_dollars
'gdp_per_capita ($)'n=gdp_per_capita_dollars
;
instant = _n_;
run;
*/

/*
proc contents data = clean.suicideRates;
run;
*/


/* 1. Variable: Year */

proc sgplot data=clean.suicideRates;
	histogram year;
	density year;
run;

proc sgplot data=clean.suicideRates;
	vbox year;
run;

title"Q1 Q3 and  Interquartile range of year";

proc means data=clean.suicideRates Q1 Q3 Qrange;
	var year;
	output out=clean.year Q1=
	Q3=
	QRange= / autoname;
run;


proc print data = clean.year;
run;

title"Outliers of year based on the interquantile range method";

data _null_;
	file print;
	set clean.suicideRates(keep=instant year);

	if _n_=1 then
		set clean.year;

	if year le year_Q1 - 1.5*year_QRange and not missing(year) 
		or year ge year_Q3 + 1.5*year_QRange then
			put "Possible Outlier for instant " instant "value of year is " 
			year ;
run;

/* no outliers for variable year */


/* 2. Variable: population */

proc sgplot data=clean.suicideRates;
	histogram population;
	density population;
run;

proc sgplot data=clean.suicideRates;
	vbox population;
run;

title"Q1 Q3 and  Interquartile range of population";

proc means data=clean.suicideRates Q1 Q3 Qrange;
	var population;
	output out=clean.population Q1=
	Q3=
	QRange= / autoname;
run;

proc print data = clean.population;
run;

title"Outliers of population based on the interquantile range method";

data _null_;
	file print;
	set clean.suicideRates(keep=instant population);

	if _n_=1 then
		set clean.population;

	if population le population_Q1 - 1.5*population_QRange and not missing(population) 
		or population ge population_Q3 + 1.5*population_QRange then
			put "Possible Outlier for instant " instant "value of population is " 
			population ;
run;

/* to check total of outliers for population  */


data clean.population;
set clean.population;
n=1;
run;

data clean.suicideRates;
set clean.suicideRates;
n=1;
run;

data clean.outliersPopulation; merge clean.suicideRates(in =d1)  clean.population(in =d2)  ;
by n;
if d1 =1 and d2 =1;
keep  instant population population_Q1 population_Q3 population_QRange;
run;


data clean.outliersPopulation;
set clean.outliersPopulation;

	retain below_Q1 above_Q3 ;
	if population >= (population_Q3 + 1.5*population_QRange) then do;
		above_Q3 = 1;

	end;
	else above_Q3 = 0;
	
	if population <= (population_Q1 - 1.5*population_QRange) then do;
	below_Q1 = 1;

	end;
	else below_Q1 = 0;

	if missing(above_Q3) then above_Q3 = 0;
		if missing(below_Q1) then below_Q1 = 0;

run;

title "Total outliers for population ";
proc means data=clean.outliersPopulation sum;
var above_Q3 below_Q1;
run;


/* remove outliers for individual and check for distribution change */
data clean.OutliersRm_population;
	file print;
	set clean.suicideRates(keep=instant population);

	if _n_=1 then
		set clean.population;

	if population le population_Q1 - 1.5*population_QRange and not missing(population) 
	or population ge population_Q3 + 1.5*population_QRange then
			delete;
run;

proc print data=clean.OutliersRm_population (obs=10);
run;

title "Historgram of population after change";
proc sgplot data=clean.OutliersRm_population;
	histogram population;
	density population;
run;

title "Historgram of population before change";
proc sgplot data=clean.suicideRates;
	histogram population;
	density population;
run;



/* 3. Variable: suicidesPer100k_pop */

proc sgplot data=clean.suicideRates;
	histogram suicidesPer100k_pop;
	density suicidesPer100k_pop;
run;

proc sgplot data=clean.suicideRates;
	vbox suicidesPer100k_pop;
run;

title"Q1 Q3 and  Interquartile range of suicidesPer100k_pop";

proc means data=clean.suicideRates Q1 Q3 Qrange;
	var suicidesPer100k_pop;
	output out=clean.suicidesPer100k_pop Q1=
	Q3=
	QRange= / autoname;
run;

proc print data = clean.suicidesPer100k_pop;
run;

title"Outliers of suicidesPer100k_pop based on the interquantile range method";

data _null_;
	file print;
	set clean.suicideRates(keep=instant suicidesPer100k_pop);

	if _n_=1 then
		set clean.suicidesPer100k_pop;

	if suicidesPer100k_pop le suicidesPer100k_pop_Q1 - 1.5*suicidesPer100k_pop_QRange and not missing(suicidesPer100k_pop) 
		or suicidesPer100k_pop ge suicidesPer100k_pop_Q3 + 1.5*suicidesPer100k_pop_QRange then
			put "Possible Outlier for instant " instant "value of suicidesPer100k_pop is " 
			suicidesPer100k_pop ;
run;



/* to check total of outliers for suicudeper100  */
data clean.suicidesPer100k_pop;
set clean.suicidesPer100k_pop;
n=1;
run;

data clean.suicideRates;
set clean.suicideRates;
n=1;
run;

data clean.outliersuicideper100; merge clean.suicideRates(in =d1)  clean.suicidesPer100k_pop(in =d2)  ;
by n;
if d1 =1 and d2 =1;
keep  instant suicidesPer100k_pop suicidesPer100k_pop_Q1 suicidesPer100k_pop_Q3 suicidesPer100k_pop_QRange;
run;


data clean.outliersuicideper100;
set clean.outliersuicideper100;

	retain below_Q1 above_Q3 ;
	if suicidesPer100k_pop >= (suicidesPer100k_pop_Q3 + 1.5*suicidesPer100k_pop_QRange) then do;
		above_Q3 = 1;

	end;
	else above_Q3 = 0;
	
	if suicidesPer100k_pop <= (suicidesPer100k_pop_Q1 - 1.5*suicidesPer100k_pop_QRange) then do;
	below_Q1 = 1;

	end;
	else below_Q1 = 0;

	if missing(above_Q3) then above_Q3 = 0;
		if missing(below_Q1) then below_Q1 = 0;

run;

title "Total outliers for suicidesPer100k_pop ";
proc means data=clean.outliersuicideper100 sum;
var above_Q3 below_Q1;
run;

/* remove outliers for individual and check for distribution change */
data clean.OutliersRm_suicidesPer100;
	file print;
	set clean.suicideRates(keep=instant suicidesPer100k_pop);

	if _n_=1 then
		set clean.suicidesPer100k_pop;

	if suicidesPer100k_pop le suicidesPer100k_pop_Q1 - 1.5*suicidesPer100k_pop_QRange and not missing(suicidesPer100k_pop) 
	or suicidesPer100k_pop ge suicidesPer100k_pop_Q3 + 1.5*suicidesPer100k_pop_QRange then
			delete;
run;

proc print data=clean.OutliersRm_suicidesPer100 (obs=10);
run;

title "Historgram of suicidesPer100k_pop after change";
proc sgplot data=clean.OutliersRm_suicidesPer100;
	histogram suicidesPer100k_pop;
	density suicidesPer100k_pop;
run;

title "Historgram of suicidesPer100k_pop before change";
proc sgplot data=clean.suicideRates;
	histogram suicidesPer100k_pop;
	density suicidesPer100k_pop;
run;



/* 4. Variable:  gdp_per_capita_dollars */

proc sgplot data=clean.suicideRates;
	histogram gdp_per_capita_dollars;
	density gdp_per_capita_dollars;
run;

proc sgplot data=clean.suicideRates;
	vbox gdp_per_capita_dollars;
run;

title"Q1 Q3 and  Interquartile range of gdp_per_capita_dollars";

proc means data=clean.suicideRates Q1 Q3 Qrange;
	var gdp_per_capita_dollars;
	output out=clean.gdp_per_capita_dollars Q1=
	Q3=
	QRange= / autoname;
run;

data clean.gdp_per_capita_dollars;
set clean.gdp_per_capita_dollars;
lower = gdp_per_capita_dollars_Q1 - 1.5*gdp_per_capita_dollars_QRange;
upper = gdp_per_capita_dollars_Q3 + 1.5*gdp_per_capita_dollars_QRange;
run;

proc print data = clean.gdp_per_capita_dollars;
run;


title"Outliers of gdp_per_capita_dollars based on the interquantile range method";

data _null_;
	file print;
	set clean.suicideRates(keep=instant gdp_per_capita_dollars);

	if _n_=1 then
		set clean.gdp_per_capita_dollars;

	if gdp_per_capita_dollars le gdp_per_capita_dollars_Q1 - 1.5*gdp_per_capita_dollars_QRange and not missing(gdp_per_capita_dollars) 
		or gdp_per_capita_dollars ge gdp_per_capita_dollars_Q3 + 1.5*gdp_per_capita_dollars_QRange then
			put "Possible Outlier for instant " instant "value of gdp_per_capita_dollars is " 
			gdp_per_capita_dollars ;
run;


/* to check total of outliers for gdp_per_capita_dollars  */
data clean.gdp_per_capita_dollars;
set clean.gdp_per_capita_dollars;
n=1;
run;

data clean.suicideRates;
set clean.suicideRates;
n=1;
run;

data clean.outlierGDPcapital; merge clean.suicideRates(in =d1)  clean.gdp_per_capita_dollars(in =d2)  ;
by n;
if d1 =1 and d2 =1;
keep  instant gdp_per_capita_dollars gdp_per_capita_dollars_Q1 gdp_per_capita_dollars_Q3 gdp_per_capita_dollars_QRange;
run;


data clean.outlierGDPcapital;
set clean.outlierGDPcapital;

	retain below_Q1 above_Q3 ;
	if gdp_per_capita_dollars >= (gdp_per_capita_dollars_Q3 + 1.5*gdp_per_capita_dollars_QRange) then do;
		above_Q3 = 1;

	end;
	else above_Q3 = 0;
	
	if gdp_per_capita_dollars <= (gdp_per_capita_dollars_Q1 - 1.5*gdp_per_capita_dollars_QRange) then do;
	below_Q1 = 1;

	end;
	else below_Q1 = 0;

	if missing(above_Q3) then above_Q3 = 0;
		if missing(below_Q1) then below_Q1 = 0;

run;

title "Total outliers for gdp_per_capita_dollars ";
proc means data=clean.outlierGDPcapital sum;
var above_Q3 below_Q1;
run;

/* remove outliers for individual and check for distribution change */
data clean.OutliersRm_gdpcapital;
	file print;
	set clean.suicideRates(keep=instant gdp_per_capita_dollars);

	if _n_=1 then
		set clean.gdp_per_capita_dollars;

	if gdp_per_capita_dollars le gdp_per_capita_dollars_Q1 - 1.5*gdp_per_capita_dollars_QRange and not missing(gdp_per_capita_dollars) or gdp_per_capita_dollars ge 
		gdp_per_capita_dollars_Q3 + 1.5*gdp_per_capita_dollars_QRange then
			delete;
run;

proc print data=clean.OutliersRm_gdpcapital (obs=10);
run;

title "Historgram of gdp_per_capita_dollars after change";
proc sgplot data=clean.OutliersRm_gdpcapital;
	histogram gdp_per_capita_dollars;
	density gdp_per_capita_dollars;
run;

title "Historgram of gdp_per_capita_dollars before change";
proc sgplot data=clean.suicideRates;
	histogram gdp_per_capita_dollars;
	density gdp_per_capita_dollars;
run;




/* 5. Variable:  gdp_for_year_dollars */

proc sgplot data=clean.suicideRates;
	histogram gdp_for_year_dollars;
	density gdp_for_year_dollars;
run;

proc sgplot data=clean.suicideRates;
	vbox gdp_for_year_dollars;
run;

title"Q1 Q3 and  Interquartile range of gdp_for_year_dollars";

proc means data=clean.suicideRates Q1 Q3 Qrange;
	var gdp_for_year_dollars;
	output out=clean.gdp_for_year_dollars Q1=
	Q3=
	QRange= / autoname;
run;

data clean.gdp_for_year_dollars;
set clean.gdp_for_year_dollars;
lower = gdp_for_year_dollars_Q1 - 1.5*gdp_for_year_dollars_QRange;
upper = gdp_for_year_dollars_Q3 + 1.5*gdp_for_year_dollars_QRange;
run;

proc print data = clean.gdp_for_year_dollars;
run;


title"Outliers of gdp_for_year_dollars based on the interquantile range method";

data _null_;
	file print;
	set clean.suicideRates(keep=instant gdp_for_year_dollars);

	if _n_=1 then
		set clean.gdp_for_year_dollars;

	if gdp_for_year_dollars le gdp_for_year_dollars_Q1 - 1.5*gdp_for_year_dollars_QRange and not missing(gdp_for_year_dollars) 
		or gdp_for_year_dollars ge gdp_for_year_dollars_Q3 + 1.5*gdp_for_year_dollars_QRange then
			put "Possible Outlier for instant " instant "value of gdp_for_year_dollars is " 
			gdp_for_year_dollars ;
run;


/* to check total of outliers for gdp_for_year_dollars  */
data clean.gdp_for_year_dollars;
set clean.gdp_for_year_dollars;
n=1;
run;

data clean.suicideRates;
set clean.suicideRates;
n=1;
run;

data clean.outlierGDPyear; merge clean.suicideRates(in =d1)  clean.gdp_for_year_dollars(in =d2)  ;
by n;
if d1 =1 and d2 =1;
keep  instant gdp_for_year_dollars gdp_for_year_dollars_Q1 gdp_for_year_dollars_Q3 gdp_for_year_dollars_QRange;
run;


data clean.outlierGDPyear;
set clean.outlierGDPyear;

	retain below_Q1 above_Q3 ;
	if gdp_for_year_dollars >= (gdp_for_year_dollars_Q3 + 1.5*gdp_for_year_dollars_QRange) then do;
		above_Q3 = 1;

	end;
	else above_Q3 = 0;
	
	if gdp_for_year_dollars <= (gdp_for_year_dollars_Q1 - 1.5*gdp_for_year_dollars_QRange) then do;
	below_Q1 = 1;

	end;
	else below_Q1 = 0;

	if missing(above_Q3) then above_Q3 = 0;
		if missing(below_Q1) then below_Q1 = 0;

run;

title "Total outliers for gdp_for_year_dollars ";
proc means data=clean.outlierGDPyear sum;
var above_Q3 below_Q1;
run;

/* remove outliers for individual and check for distribution change */
data clean.OutliersRm_gdpyear;
	file print;
	set clean.suicideRates(keep=instant gdp_for_year_dollars);

	if _n_=1 then
		set clean.gdp_for_year_dollars;

	if gdp_for_year_dollars le gdp_for_year_dollars_Q1 - 1.5*gdp_for_year_dollars_QRange and not missing(gdp_for_year_dollars) 
	or gdp_for_year_dollars ge 
		gdp_for_year_dollars_Q3 + 1.5*gdp_for_year_dollars_QRange then
			delete;
run;

proc print data=clean.OutliersRm_gdpyear (obs=10);
run;

title "Historgram of gdp_for_year_dollars after change";
proc sgplot data=clean.OutliersRm_gdpyear;
	histogram gdp_for_year_dollars;
	density gdp_for_year_dollars;
run;

title "Historgram of gdp_for_year_dollars before change";
proc sgplot data=clean.suicideRates;
	histogram gdp_for_year_dollars;
	density gdp_for_year_dollars;
run;


/* Since distribution remain similar after removing outliers, it's safe to remove all those outliers  */


proc sort data = clean.OutliersRm_population(keep = instant);
by instant;
run;

proc sort data = clean.OutliersRm_suicidesper100(keep = instant);
by instant;
run;

proc sort data = clean.OutliersRm_gdpcapital(keep = instant);
by instant;
run;

proc sort data = clean.OutliersRm_gdpyear(keep = instant);
by instant;
run;

data clean.suicide_final_OutliersRm;
   merge clean.suicideRates (in=d0) clean.OutliersRm_population (in=d1) clean.OutliersRm_suicidesper100 (in=d2) clean.OutliersRm_gdpcapital (in=d3) clean.OutliersRm_gdpyear (in=d4) ;
   by instant;
   if d1=1 and d2=1 and d3=1 and d4=1; 
   drop n;
run;

/* Rename column name to remove space and other symbol 

data clean.suicideRates;
set clean.suicideRates;
rename
'suicides/100k pop'n=suicidesPer100k_pop
'country-year'n=country_year
'HDI for year'n=HDI_for_year
' gdp_for_year ($) 'n=gdp_for_year_dollars
'gdp_per_capita ($)'n=gdp_per_capita_dollars
;
run; */


proc contents data=clean.suicide_final_OutliersRm;
run;


proc print data=clean.suicide_final_OutliersRm (obs=5);
run;

proc means data=clean.suicide_final_OutliersRm n mean stddev min max nmiss;
run;

proc univariate data=clean.suicide_final_OutliersRm;
ppplot;
run;

/* Graphical method: 1.2. Theory-driven Plots: P-P and Q-Q plots
The probability-probability plot (P-P plot or percent plot) compares an empirical 
cumulative distribution function of a variable with a specific theoretical cumulative 
distribution function (e.g., the standard normal distribution function).

The quantile-quantile plot (Q-Q plot) compares ordered values of a variable with quantiles 
of a specific theoretical distribution (i.e., the normal distribution). 
If two distributions match, the points on the plot will form a linear pattern 
passing through the origin with a unit slope.*/


proc univariate data=clean.suicide_final_OutliersRm;
ppplot;
qqplot;
run;

proc univariate data=clean.suicide_final_OutliersRm plots;
run;

proc univariate data=clean.suicide_final_OutliersRm normal plot;
run;


/* Numerical method: 2.1. Descriptive stats:
Skewness: Skewness is based pm the third standardized moment that measures 
the degree of symmetry of a probability distribution. 
If skewness is greater than zero, the distribution is skewed to the right, 
having more observations on the left.*/



/* Except year everything is right skewed */





/* Transformations */
Data clean.suiciderates_transformed; 
SET clean.suicide_final_OutliersRm;
 log_suicides_no = log(suicides_no+1);
 log_population = log(population);
 log_suicidesPer100k_pop = log(suicidesPer100k_pop+1);
 log_gdp_per_capita_dollars = log(gdp_per_capita_dollars);
 root4_suicides_no = (suicides_no+1) ** 0.25;
 root4_population = (population) ** 0.25;
 root4_suicidesPer100k_pop = (suicidesPer100k_pop+1) ** 0.25;
 root4_gdp_per_capita_dollars = (gdp_per_capita_dollars) ** 0.25;
RUN;


ODS select TestsForNormality Plots;
PROC UNIVARIATE DATA = clean.suiciderates_transformed NORMAL PLOT; 
 RUN;
ODS select All;


proc univariate data=clean.suiciderates_transformed;
ppplot;
qqplot;
run;



/* Transformations */
Data clean.suiciderates_transformed; 
SET clean.suicide_final_OutliersRm;
 log_suicides_no = log(suicides_no+1);
 log_suicidesPer100k_pop = log(suicidesPer100k_pop+1);
 root4_suicides_no = (suicides_no+1) ** 0.25;
 root4_suicidesPer100k_pop = (suicidesPer100k_pop+1) ** 0.25;
RUN;

proc means data=clean.suicide_final_OutliersRm min;
var suicides_no suicidesPer100k_pop;
run;

proc univariate data=clean.suiciderates_transformed;
ppplot;
run;
