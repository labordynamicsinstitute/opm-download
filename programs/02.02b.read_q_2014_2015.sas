/* $Id$ */
/* $URL$ */
/* Read-in the quarterly OPM data */

/* raw data files are in each ZIP file */
/* they have to be transformed into UNIX format */
/* formats will have the same name as the input file, minus the DT */

%include "config.sas"/source2;


%macro loop(year,start=1,end=4,layout=csv);
%do q = &start. %to &end.;
%readin_data(year=&year.,quarter=&q.,infmtlib=OPMFMT,outputs=QUARTRLY,layout=&layout.);
%end;
%mend;

%loop(2013,layout=csv2,start=4);
%loop(2014,layout=csv2);
%loop(2015,layout=csv2);


