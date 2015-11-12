/* $Id$ */
/* $URL$ */
/* Compare aggregated OPM data to QCEW data - export to Stata */

%include "config.sas"/source2;



proc export data=INTERWRK.opm_opm
    dbms=stata
    outfile="&interwrk./opm_opm.dta"
	replace;
run;

proc export data=INTERWRK.opm_qcew
    dbms=stata
    outfile="&interwrk./opm_qcew.dta"
	replace;
run;
proc export data=INTERWRK.opmx_qcew
    dbms=stata
    outfile="&interwrk./opmx_qcew.dta"
	replace;
run;
