/* $Id$ */
/* $URL$ */
/* Compare aggregated OPM data to QCEW data */

%include "config.sas"/source2;

libname INPUTS (OUTPUTS,QCEW);


proc contents data=INPUTS.bls_us_state;
run;

proc summary data=INPUTS.bls_us_state(where=(ownership_code='1' and aggregation_level='51'));
class year quarter;
var emp_month1 emp_month3;
output out=bls_summary sum=;
run;

proc print data=bls_summary;
title "BLS summary where=(ownership_code='1' and aggregation_level='51')";
run;
title;

/* Test 1 : comparison to QCEW, no exclusions */

%macro qa_test_opm1(compare=INPUTS.opmpu_us_qcew_comparable,condition=,title=Comparison OPM to QCEW without any exclusions,outname=);

data bls(rename=(emp_month1=bls_emp_month1 emp_month3=bls_emp_month3 total_wage=bls_total_wage)
                 keep=state state_name year quarter emp_month1 emp_month3 total_wage yr_qtr ownership_code);
 
	length year 3;
	set INPUTS.bls_us_state
		(where=(ownership_code='1' and aggregation_level='51'));
      length  state_name $2 yr_qtr $6;

      state_name=fipstate(input(state,2.));
      yr_qtr= put(year,4.) || ":" || put(quarter,1.);
   run;

proc sort data=bls;
by state year quarter;
run;

data blsplus1(rename=(bls_emp_month1=bls_emp_month1_p1 bls_total_wage=bls_total_wage_p1));
	set bls;
	drop bls_emp_month3;
      qtime=%qtime(year,quarter,location=datastep);
	qtime=qtime-1;
	year=%inv_qtime(qtime,year,datastep);
	quarter=%inv_qtime(qtime,quarter,datastep);
*        yr_qtr= put(year,4.) || ":" || put(quarter,1.);
	label bls_emp_month1 = "BLS Employment month1 from next quarter"
	      bls_total_wage = "BLS total wages from next quarter"
	;
run;
proc print data=blsplus1(obs=50);
run;

data opm(rename=(employment=opm_e ));
	set &compare.
	    (where=(&condition.)) /* grab aggregates by state year quarter */
		;
      yr_qtr= put(year,4.) || ":" || put(quarter,1.);
      opm_total_wage=salary/4;
	label opm_total_wage="Estimated total quarterly wages";
run;

proc sort data=opm;
by state year quarter;
run;

data INTERWRK.&outname.;
	merge
		opm(in=a)
		bls(in=b)
		blsplus1(in=c keep=state year quarter bls_emp_month1_p1 bls_total_wage_p1)
	;
	by state year quarter;
	_merge=a+2*b+4*c;
	/* compute ratios */
	opm_e_qcew_b = opm_e/bls_emp_month1;
	opm_e_qcew_b_p1 = opm_e/bls_emp_month1_p1;
	opm_e_qcew_e = opm_e/bls_emp_month3;
	opm_w_qcew_w = opm_total_wage/bls_total_wage;

	label
	opm_e_qcew_b = "Ratio of OPM E vs QCEW B (emp_month1)"
	opm_e_qcew_b_p1 = "Ratio of OPM E vs QCEW B (emp_month1,q+1)"
	opm_e_qcew_e = "Ratio of OPM E vs QCEW E (emp_month3)"
	opm_w_qcew_w = "Ratio of OPM W vs QCEW W (total wages)"
	;
run;

proc freq data=INTERWRK.&outname.;
title "&title.";
table yr_qtr * _merge;
run;

proc means data=INTERWRK.&outname.(where=(_merge=7));
run;
%mend;

%qa_test_opm1(compare=INPUTS.opmpu_us_qcew_comparable,condition=_type_=11,title=Comparison OPM to QCEW without any exclusions,outname=opm_qcew);

/* reuse some of the files above, to do the comparison of Excluded employment vs. total OPM employment */
/* now assess the time variation in the exclusion */
%let compare=INPUTS.opmpu_us_lehd_comparable;
%let condition=_type_=27 and exclusion = 1;
%let title=Comparison OPM excluded to Overall OPM;
%let outname=opm_opm;

data opm_excluded(rename=(employment=opm_e_excluded ));
	set &compare.
	    (where=(&condition.)) /* grab aggregates by state year quarter */
		;
      yr_qtr= put(year,4.) || ":" || put(quarter,1.);
      opm_excluded_total_wage=salary/4;
	label opm_excluded_total_wage="Estimated total quarterly wages";
      keep yr_qtr state year quarter opm_excluded_total_wage employment;
run;

proc sort data=opm_excluded;
by state year quarter;
run;

data INTERWRK.&outname.;
	merge
		opm(in=a)
		opm_excluded(in=b)
	;
	by state year quarter;
	_merge=a+2*b;
	/* compute ratios */
	opm_ex_e = opm_e_excluded/opm_e;
	opm_ex_w = opm_excluded_total_wage/opm_total_wage;

	label
	opm_ex_e = "Ratio of OPM Excluded vs total OPM E"
	opm_ex_w = "Ratio of OPM Excluded W vs OPM W"
	;
run;

proc freq data=INTERWRK.&outname.;
title "&title.";
table yr_qtr * _merge;
run;

proc summary data=INTERWRK.&outname.
	(where=(substr(state,2,1) ~= 'Q' and state not in ('US')));
class state;
var opm_ex_e;
output out=INTERWRK.&outname._stats mean=mean_opm_ex_e std=std_opm_ex_e
	 min=min_opm_ex_e max=max_opm_ex_e
	 p10=p10_opm_ex_e p90=p90_opm_ex_e;
run;

proc means data=INTERWRK.&outname.(where=(_merge=3));
run;
/* compute the typical min-max */
data INTERWRK.&outname._stats;
set  INTERWRK.&outname._stats;
r9010_opm_ex_e = p90_opm_ex_e - p10_opm_ex_e;
minmax_opm_ex_e= max_opm_ex_e - min_opm_ex_e;
run;


proc print data=INTERWRK.&outname._stats;
run;

proc means data=INTERWRK.&outname._stats(where=(_type_ =1 ));
run;


/* now do the comparison OPM with exclusions to BLS */
%qa_test_opm1(compare=INPUTS.opmpu_us_lehd_comparable,condition=_type_=27 and exclusion = 0,
title=Comparison OPM with exclusions to QCEW,outname=opmx_qcew);

