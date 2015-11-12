/* $Id$ */
/* $URL$ */
/* Export aggregate OPM data series */

%include "config.sas"/source2;

proc export data=OUTPUTS.opmpu_us_imputed
    dbms=stata
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_imputed.dta"
	replace;
run;

proc export data=OUTPUTS.opmpu_us_imputed
    dbms=csv
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us_imputed.csv"
	replace;
run;
