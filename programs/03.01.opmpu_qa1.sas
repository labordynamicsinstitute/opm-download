/* $Id$ */
/* $URL$ */
/* Read-in the quarterly OPM data */

/* raw data files are in each ZIP file */
/* they have to be transformed into UNIX format */

%macro opmpu_qa1(quarter=,year=,infmtlib=WORK,outputs=OUTPUTS);
options fmtsearch=(&infmtlib.);

title "Analysis of suppressed jobs: OPMPU &year.Q&quarter.";

data analysis/view=analysis;
	set OUTPUTS.opmpu_us_&year.q&quarter.;
	where loctyp='1' and gender ne 'Z';
	flag_suppressed=(loc='US');
	/* prepare regression */
	log_salary=log(salary);
	pptyp=put(ppgrd,$rpptyp.);
run;

proc means data=analysis;
class flag_suppressed;
var salary los;
run;

proc freq data=analysis;
table 	agelvl*flag_suppressed 
	gender*flag_suppressed 
    	PPGRD*flag_suppressed
	TOA*flag_suppressed
	;
format agelvl $agelvl. gender $gender. ppgrd $rpptyp.
run;

proc glm data=analysis order=freq;
class gender agelvl pptyp year;
model log_salary = agelvl gender pptyp flag_suppressed 
	 /solution ss3;
run;


%mend;


libname opmfmt "../../clean/opm/extra";
libname outputs "../../clean/opm/quarterly";

%opmpu_qa1(quarter=4,year=2010,infmtlib=opmfmt);

