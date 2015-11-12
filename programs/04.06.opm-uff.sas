/* $Id$ */
/* $URL$ */
/* Aggregate quarterly OPM data to UFF like file */
/* LEHD for now excludes some departments - they are flagged here */


%include "config.sas"/source2;

/* we want to combine the opmpu_us and the accessions and separations 
   at the agysub/state/year/quarter level */

/* subsequently, we also want to have a LEHD-comparable state/year/quarter 
   level, i.e., for all OPM minus the exclusions */

%let sortorder=exclusion state agysub year quarter;

%macro agg(type=acc);

%if ( "&type." = "acc" ) %then %let ltype=accessions;
%if ( "&type." = "sep" ) %then %let ltype=separations;

data opmpu_work/view=opmpu_work;
	set OUTPUTS.opmpu_us_&type.(where=(loc2 not in ( "FC"
	/*, "AQ", "CQ", "GQ", "MQ", "RQ", "VQ" */ )));
	month=efdate-int(efdate/100)*100;
	quarter=int((month-1)/3)+1;
	rename loc2 = state;
	length exclusion quarter 3;
	exclusion = ( dept_subcode in ("DD", "AR", "AF", "NV") 
			or agysub in ("DJ02","DJ06","DJ15","HSAD","TR40","TRAC","TRAD"));

run;
proc freq data=opmpu_work;
table month;
run;

proc summary data=opmpu_work;
class &sortorder.;
var count salary;
output out=opmpu_us_uff_&type.
	(label="OPM &ltype..,  no exclusions"
	 rename=(count=&ltype. )
	) sum=;
run;

/* add labels */

data opmpu_us_uff_&type.;
	set opmpu_us_uff_&type.;
	label &ltype = "&ltype. during quarter"
              salary     = "Salaries of separating employees"
	;
run;

proc freq;
table quarter;
run;

%mend;
%agg(type=acc);
%agg(type=sep);

/* now do the same for employment */
data opmpu_work/view=opmpu_work;
	set OUTPUTS.opmpu_us(where=(loc2 ne "FC"));
	rename loc2 = state;
	length exclusion 3;
	exclusion = ( dept_subcode in ("DD", "AR", "AF", "NV") 
			or agysub in ("DJ02","DJ06","DJ15","HSAD","TR40","TRAC","TRAD"));
run;

proc summary data=opmpu_work;
class &sortorder.;
var employment salary;
output out=opmpu_us_uff(label="Comparable to LEHD - DD exclusions") sum=;
run;

/* now we have e, s, a. Generate b, and bring all together */
data opmpu_work_p1/view=opmpu_work_p1;
	set OUTPUTS.opmpu_us(where=(loc2 ne "FC"));
	rename loc2 = state;
	length exclusion 3;
	exclusion = ( dept_subcode in ("DD", "AR", "AF", "NV") 
			or agysub in ("DJ02","DJ06","DJ15","HSAD","TR40","TRAC","TRAD"));
	qtime=%qtime(year,quarter,location=datastep);
	qtime=qtime+1;
	year=%inv_qtime(qtime,year,datastep);
	quarter=%inv_qtime(qtime,quarter,datastep);
run;

proc summary data=opmpu_work_p1;
class &sortorder.;
var employment salary;
output out=opmpu_p1(label="Comparable to LEHD - DD exclusions"
		        rename=(employment=b salary=w0)) sum=;
run;

proc freq;
table quarter;
run;

/* sort all files by _type_ state agysub year quarter */

%macro mysort(file);
proc sort data=&file.;
by _type_ &sortorder.;
run;
%mend;
%mysort(opmpu_p1);
%mysort(opmpu_us_uff);
%mysort(opmpu_us_uff_acc);
%mysort(opmpu_us_uff_sep);

/* bring them all together */
/* list of types */
/*
    exclusion        agysub	    quarter
_type_       state            year
============================================
1					1
2				1	
3				1	1
4			1		
5			1		1
6			1	1	
7			1	1	1
8		1			
9		1			1
10		1		1	
11		1		1	1
12		1	1		
13		1	1		1
14		1	1	1	
15		1	1	1	1
16	1				
17	1				1
18	1			1	
19	1			1	1
20	1		1		
21	1		1		1
22	1		1	1	
23	1		1	1	1
24	1	1			
25	1	1			1
26	1	1		1	
27	1	1		1	1
28	1	1	1		
29	1	1	1		1
30	1	1	1	1	
31	1	1	1	1	1
-------------------------------------------
*/


data OUTPUTS.opmpu_us_uff(compress=yes);
	merge opmpu_p1(in=ina)
              opmpu_us_uff(in=inb rename=(employment=e salary=w2))
	      opmpu_us_uff_acc(in=c rename=(accessions=a salary=wa))
	      opmpu_us_uff_sep(in=d rename=(separations=s salary=ws))
	;
	by _type_ &sortorder.;
/* select only the interesting types */
	if year=. and quarter ne . then delete; /* 1,5,9,13,17,21,25,29 */

	array flows(2) a s;
	array rates(2) ar sr;
	ebar=(e+b)/2;
	do i = 1 to 2;
		/* due to the way this is tabulated,
                   if an agency had no separations in a quarter,
                   it has missing data, not zeros. this handles that.*/
		if ebar ne . and flows(i)=. then flows(i)=0;
		/* compute the rates */
		rates(i)=flows(i)/ebar; 
	end;
	drop _freq_ i;
	label _type_ = "Defined by &sortorder."
	      	ar = "Accession rate"
		sr = "Separation rate"
		ebar = "Average employment (b+e)/2"
		year = "Year"
		quarter="Quarter"
		e = "End-of-quarter employment (last pay period)"
		b = "Beginning-of-quarter employment (==e(t-1))"
		w0 = "Total payroll of beginning-of-period employees"
		w2 = "Total payroll of end-of-period employees"
		wa = "Total payroll of accessions"
		ws = "Total payroll of separations"
		exclusion = "Flags entities not included by LEHD OPM computations";

	/* we could in principle also compute full-quarter measures, using 
           the Length-of-service as a proxy for tenure */
run;


proc freq;
table year*quarter/missing;
run;


/* export */
proc export data=OUTPUTS.opmpu_us_uff
    dbms=stata
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_uff.dta"
	replace;
run;

proc export data=OUTPUTS.opmpu_us_uff
    dbms=csv
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_uff.csv"
	replace;
run;
