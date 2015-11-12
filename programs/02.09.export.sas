/* $Id: 02.09.export.sas 188 2011-09-02 03:04:47Z vilhu001 $ */
/* $URL: https://repository.vrdc.cornell.edu/VRDC/data/programs/opm/02.09.export.sas $ */
/* Export aggregate OPM data series */

%include "config.sas"/source2;

proc export data=OUTPUTS.opmpu_us
    dbms=stata
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us.dta"
	replace;
run;

proc export data=OUTPUTS.opmpu_us
    dbms=csv
    outfile="%sysfunc(pathname(OUTPUTS))/opmpu_us.csv"
	replace;
run;
