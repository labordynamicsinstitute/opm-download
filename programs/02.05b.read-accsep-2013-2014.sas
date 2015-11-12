/* $Id$ */
/* $URL$ */
/* Read-in the quarterly OPM data */

/* raw data files are in each ZIP file */
/* they have to be transformed into UNIX format */
/* formats will have the same name as the input file, minus the DT */

%include "config.sas"/source2;

%macro readin_data(accsep=accessions,year=,infmtlib=WORK,outputs=OUTPUTS,layout=csv);

/* if we are called with a year less than 2007, print
   an error message and exit */

%if ( &year. < 2005 ) %then %do;
        %put %upcase(error)::: No data available prior to 2005;
	%put %upcase(error)::: No such data available as of the original creation date;
	%put %upcase(error)::: of this program.;

	data _null_;
	call execute('endsas;');
	run;
%end;

title "Processing OPM &accsep. data for FY&year.";

%let infile=FS_&accsep._fy&year..zip;
%if ( "&accsep." = "accessions" ) %then %do;
	%let rawfile=ACCDATA_fy&year..TXT;
	%let accseptype=acc;
	%end;
%if ( "&accsep." = "separations" ) %then %do;
	%let rawfile=SEPDATA_fy&year..TXT;
	%let accseptype=sep;
	%end;

%if ( &year. > 2009 ) %then %let rawfile=%upcase(&rawfile.);

options fmtsearch=(&infmtlib.);

%let workdir=%sysfunc(pathname(WORK));

x unzip -ao ../../raw/opm/&infile. &rawfile. -d &workdir.;

  data &outputs..opmpu_us_&accsep._FY&year.;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    %l_opm_&layout.(infile=&workdir./&rawfile.,type=&accseptype.); 

	/* generated variables */
	length dept_subcode loc2 $ 2 loctyp $ 1 year 3 ;
	dept_subcode=substr(agysub,1,2);
	loctyp=put(loc,$rloc.);
	year=&year.;
	if loctyp in ( '1','2') then loc2=loc;
	else loc2 = 'FC';
	label
		dept_subcode = "Department"
		loc2 = "US States + foreign collapsed (FC)"
		loctyp = "Location type (US, territories, foreign)"
		year = "Year"

	;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
    run;

proc means;
proc contents;
run;

proc summary sum;
class loc2;
var count;
format loc2 $loc.;
output out=opm_state sum=;
run;

proc print data=opm_state;
title2 "Tabulation of &accsep. by State and Foreign Country";
run;


%mend;
%readin_data(accsep=accessions,year=2013,infmtlib=OPMFMT,outputs=YEARLY,layout=acc_csv);
%readin_data(accsep=accessions,year=2014,infmtlib=OPMFMT,outputs=YEARLY,layout=acc_csv);

/* now do separations */
%readin_data(accsep=separations,year=2013,infmtlib=OPMFMT,outputs=YEARLY,layout=acc_csv);
%readin_data(accsep=separations,year=2014,infmtlib=OPMFMT,outputs=YEARLY,layout=acc_csv);

