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

proc format;
value quartr
	1-3 = "1"
	4-6 = "2"
	7-9 = "3"
	10-12 = "4";
run;

%macro agg(type=acc);

%if ( "&type." = "acc" ) %then %let ltype=accessions;
%if ( "&type." = "sep" ) %then %let ltype=separations;

data opmpu_work/view=opmpu_work;
	set OUTPUTS.opmpu_us_&type.(where=(loc2 not in ( "FC"
	/*, "AQ", "CQ", "GQ", "MQ", "RQ", "VQ" */ )));
	length exclusion 3;
	month=efdate-int(efdate/100)*100;
	exclusion = ( dept_subcode in ("DD", "AR", "AF", "NV") 
			or agysub in ("DJ02","DJ06","DJ15","HSAD","TR40","TRAC","TRAD"));
	rename loc2 = state;
run;

proc summary data=opmpu_work;
class  exclusion state dept_subcode year month;
var count salary;
format month quartr.;
output out=OUTPUTS.opmpu_us_aggregated_&type.
	(label="OPM &ltype..,  DD exclusions"
	 rename=(count=&ltype. month=quarter)
	) sum=;
run;

/* add labels */

data OUTPUTS.opmpu_us_aggregated_&type.;
	set OUTPUTS.opmpu_us_aggregated_&type.;
	label &ltype = "&ltype. during quarter"
              salary     = "Salaries of separating employees"
	;
run;


/* export */
proc export data=OUTPUTS.opmpu_us_aggregated_&type.
    dbms=stata
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_aggregated_&type..dta"
	replace;
run;

proc export data=OUTPUTS.opmpu_us_aggregated_&type.
    dbms=csv
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_aggregated_&type..csv"
	replace;
run;
%mend;


%agg(type=acc);
%agg(type=sep);
