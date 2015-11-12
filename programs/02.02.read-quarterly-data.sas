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

%loop(2013,layout=csv2,end=2);
%loop(2012,layout=csv2);
%loop(2011);
%loop(2010);

/* ======== probably no need to touch these ====================*/
%readin_data(year=2009,quarter=4,infmtlib=OPMFMT,outputs=QUARTRLY);
/* up until Dec 2009, layout was fixed-width 37 */
%readin_data(year=2009,quarter=3,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);
%readin_data(year=2009,quarter=2,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);
%readin_data(year=2009,quarter=1,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);

%readin_data(year=2008,quarter=4,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);
%readin_data(year=2008,quarter=3,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);
%readin_data(year=2008,quarter=2,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);
%readin_data(year=2008,quarter=1,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);

%readin_data(year=2007,quarter=4,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);

/* The september ones go back to 1998 */
%macro loop(start=1998,end=2007);
%do i = &start. %to &end.;
%readin_data(year=&i.,quarter=3,infmtlib=OPMFMT,outputs=QUARTRLY,layout=37);
%end;
%mend;


%loop;


