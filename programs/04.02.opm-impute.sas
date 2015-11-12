/* $Id$ */
/* $URL$ */
/* Fragment - to be included in 14_ehf.sas */
/* Prepares OPMPU for use in the controltotals */
/* Aggregates the data to the equivalent level of the QCEW, 
   and fills in missing quarter on a very simplistic model based
   on ratios */

%include "config.sas"/source2;


libname INTERWRK (work);

%let opm_start_year=1998;
%let opm_start_quarter=3;
%let opm_end_year=2010;
%let opm_end_quarter=4;


/* create additional variables */
data opmpu_work/view=opmpu_work;
	set OUTPUTS.opmpu_us(where=(loc2 ne "FC"));
  exclusion=0;
  /* exclusions */
  if agysub in ( 'DJ02', 'DJ06', 'DJ15', 'HSAD', 'TR40', 'TRAC', 'TRAD')
     then exclusion =1;
  /* These are temporary exclusions! */
  if substr(agysub,1,2) in ('DD','AR','AF','NV') then exclusion =1;
  ownership_code='1';
  rename loc2=state;
  qtime=%qtime(year,quarter,location=datastep);
run;


/* subset the QCEW data */
proc sort data=QCEW.bls_us_state(where=(/*leg_state="&stfips" and*/ aggregation_level='51') 
     rename=( emp_month1=bls_emp_month1 total_wage=bls_total_wage)) 
	out=bls_step1;
  by state year quarter ownership_code; /* NORWO307 */
run;

/* summarize the data */
proc summary data=opmpu_work
      (/*rename=(loc2=state)
       where=(leg_state="&stfips.") */
	)
	 nway;
class state qtime ownership_code exclusion;
var employment salary;
output out=INTERWRK.ehf_opmtotals_14 sum=opmpu_emp_month1 opmpu_total_wage;
run;

/* adjust the timing - OPM is for end-of-quarter Q (30th of third month)
   whereas QCEW is +12 for (Q+1) month1, or -18 for Q month3. We choose the closer 
   one, also to conform to LEHD usage 
*/

data INTERWRK.ehf_opmtotals_14(sortedby=state year quarter);
	set INTERWRK.ehf_opmtotals_14;
	qtime=qtime+1;
	year=%inv_qtime(qtime,year,datastep);
	quarter=%inv_qtime(qtime,quarter,datastep);
	label
		employment = "Beginning of quarter employment (adjusted timing)"
	        salary = "Salaries of beginning-of-quarter employment"
	;
run;


/* make the impute */
data OUTPUTS.opmpu_us_imputed ;
	merge INTERWRK.ehf_opmtotals_14(where=(exclusion=0)) 
              bls_step1(in=b where=(ownership_code='1') 
                        keep=state year quarter ownership_code bls_emp_month1 bls_total_wage);
	by state year quarter ;
        if b;
	length flag_opmpu_imputed 3;
	retain lag_ratio_emp lag_ratio_wage;

	flag_opmpu_imputed=0;
	drop lag_:;

	if first.state then do;
		lag_ratio_emp = .;
		lag_ratio_wage= .;
	end;
	if bls_emp_month1 > 0 and opmpu_emp_month1 ne . 
	   then ratio_emp_month1=opmpu_emp_month1/bls_emp_month1;
        if bls_total_wage > 0 and opmpu_total_wage ne . 
	   then ratio_total_wage=opmpu_total_wage/bls_total_wage;

	/* fill in missing */
	/* lag the ratio */

	if ratio_emp_month1=. then ratio_emp_month1=lag_ratio_emp;
	else lag_ratio_emp=ratio_emp_month1;
	if ratio_total_wage=. then ratio_total_wage=lag_ratio_wage;
	else lag_ratio_wage=ratio_total_wage;

	/* now, if opmpu_emp_month1 and/or opmpu_total_wage is missing,
           we use the ratio to the QCEW data to impute OPM data 
	   */

	if opmpu_emp_month1 = . and ratio_emp_month1 ne . 
	   then do;
	      flag_opmpu_imputed=flag_opmpu_imputed+1;
	      opmpu_emp_month1=bls_emp_month1 * ratio_emp_month1;
	   end;

	 
	if opmpu_total_wage = . and ratio_total_wage ne . 
	   then do;
	      flag_opmpu_imputed=flag_opmpu_imputed+2;
	      opmpu_total_wage=bls_total_wage * ratio_total_wage;
	   end;

run;

/* diagnostics, for testing only */
proc print data=OUTPUTS.opmpu_us_imputed;
run;



