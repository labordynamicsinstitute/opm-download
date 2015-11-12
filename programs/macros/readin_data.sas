/* $Id$ */
/* $URL$ */
/* Read-in the quarterly OPM data */

/* raw data files are in each ZIP file */
/* they have to be transformed into UNIX format */
/* formats will have the same name as the input file, minus the DT */


%macro readin_data(quarter=,year=,infmtlib=WORK,outputs=OUTPUTS,layout=csv);
%if ( "&quarter." = "1" ) %then %let month=Mar;
%if ( "&quarter." = "2" ) %then %let month=Jun;
%if ( "&quarter." = "3" ) %then %let month=Sept;
%if ( "&quarter." = "4" ) %then %let month=Dec;

/* if we are called with a year less than 2007, print
   an error message and exit */

%if ( &year. < 2007 ) %then %do;
	%put %upcase(info)::: Prior to 2007, only September data is available;
%end;
%if ( &year. < 1998 ) %then %do;
        %put %upcase(error)::: Not tested for data prior to 1998;
	%put %upcase(error)::: No such data available as of the original creation date;
	%put %upcase(error)::: of this program.;

	data _null_;
	call execute('endsas;');
	run;
%end;

title "Processing OPM data for &year.Q&quarter. (&month.&year)";

%let infile=FS_Employment_&month.&year..zip;
%if ( &year. >= 2010 ) or ( &year. = 2009 and "&month." = "Dec") %then 
	%let rawfile=FACTDATA_%upcase(&month.)&year..TXT;
%else %let rawfile=FACTDATA_&month.&year..TXT;
%if ( &year. >= 2010 and "&month." = "Sept") %then %let rawfile=FACTDATA_SEP&year..TXT;
options fmtsearch=(&infmtlib.);

%let workdir=%sysfunc(pathname(WORK));

x unzip -ao ../../raw/opm/&infile. &rawfile. -d &workdir.;

  data &outputs..opmpu_us_&year.q&quarter.;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    %l_opm_&layout.(infile=&workdir./&rawfile.); 

	/* generated variables */
	length dept_subcode loc2 $ 2 loctyp $ 1 year 3 quarter 3;
	dept_subcode=substr(agysub,1,2);
	loctyp=put(loc,$rloc.);
	year=&year.;
	quarter=&quarter.;
	if loctyp in ( '1','2') then loc2=loc;
	else loc2 = 'FC';
	label
		dept_subcode = "Department"
		loc2 = "US States + foreign collapsed (FC)"
		loctyp = "Location type (US, territories, foreign)"
		year = "Year"
		quarter = "Quarter (OPM has last month of quarter)"
	;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
    run;

proc means;
proc contents;
run;

proc summary sum;
class loc2;
var employment;
format loc2 $loc.;
output out=opm_state sum=;
run;

proc print data=opm_state;
title2 "Tabulation of employment by State and Foreign Country";
run;


%mend;

