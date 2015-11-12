/* $Id$ */
/* $URL$ */
/* Aggregate quarterly OPM data */
/* to EHF standards, including appropriate exclusions */
/* LEHD for now excludes some departments - they are flagged here */

/* we want to aggregate in several different ways:
   - by state/dept/year/quarter (comparable to QCEW)
   - by state/dept(non-excluded)/year/quarter (comparable to internal OPM)
*/

%include "config.sas"/source2;

data opmpu_work/view=opmpu_work;
	set OUTPUTS.opmpu_us(where=(loc2 ne "FC"));
	length exclusion 3;
	exclusion = ( dept_subcode in ("DD", "AR", "AF", "NV") 
			or agysub in ("DJ02","DJ06","DJ15","HSAD","TR40","TRAC","TRAD"));
	rename loc2 = state;
run;

proc summary data=opmpu_work;
class state dept_subcode year quarter;
var employment salary;
output out=OUTPUTS.opmpu_us_qcew_comparable(label="Comparable to QCEW - no exclusions") sum=;
run;

proc freq data=opmpu_work;
table year*quarter/missing;
run;

proc summary data=opmpu_work;
class  exclusion state dept_subcode year quarter;
var employment salary;
output out=OUTPUTS.opmpu_us_lehd_comparable(label="Comparable to LEHD - DD exclusions") sum=;
run;

/* add labels */
data OUTPUTS.opmpu_us_qcew_comparable;
	set OUTPUTS.opmpu_us_qcew_comparable;
	label employment = "End-of-quarter employment"
              salary     = "Salaries of end-of-quarter employees"
	;
run;

data OUTPUTS.opmpu_us_lehd_comparable;
	set OUTPUTS.opmpu_us_lehd_comparable;
	label employment = "End-of-quarter employment"
              salary     = "Salaries of end-of-quarter employees"
	;
run;


/* export */
proc export data=OUTPUTS.opmpu_us_lehd_comparable
    dbms=stata
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_lehd_comparable.dta"
	replace;
run;

proc export data=OUTPUTS.opmpu_us_lehd_comparable
    dbms=csv
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_lehd_comparable.csv"
	replace;
run;

