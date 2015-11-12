/* $Id$ */
/* $URL$ */
/* Compare aggregated OPM data to QCEW data */

%include "config.sas"/source2;

data exclude(keep=agysub loc where=(LOC='US')) 
	all(keep=agysub year quarter employment loc);
	set OUTPUTS.opmpu_us;
run;

proc sort data=exclude(keep=agysub) nodupkey;
by agysub;
run;

/* list them out */
data exclude;
	set exclude;
	length agency_fmt $ 80;
	agency_fmt=put(agysub,$agysub.);
run;

proc print data=exclude;
run;


proc sort data=all;
by agysub year quarter loc;
run;

data all_merged;
	merge all(in=a)
		exclude(in=b)
	;
	by agysub;
if a and b;
run;

proc freq data=all_merged;
table agysub * loc;
run;

proc summary data=all_merged;
class agysub loc year quarter;
var employment;
output out=summ_agysub sum=;
run;

proc print data=summ_agysub;
run;

proc print data=summ_agysub(where=(year=2009 and quarter=4));
title "Typical year: 2009Q4";
run;

data _null_;
	set summ_agysub(where=(year=2009 and quarter=4 and _type_=15));
        by agysub loc;
	if _n_ = 1 then do;
	put 'Agency & DC area & Other US\\';
	end;
	if first.loc then do;
	put agysub @6 _freq_ @;
	end;
	if last.loc then do;
	put '& ' _freq_ @40 '\\';
	end;
run;


