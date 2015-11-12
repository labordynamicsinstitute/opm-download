/* $Id$ */
/* $URL$ */
/* Read-in of the formats that go with the OPM data */

/* raw data files are in each ZIP file */
/* they have to be transformed into UNIX format */
/* formats will have the same name as the input file, minus the DT */

%include "config.sas"/source2;

%macro unzip_2_work(infile=,file=);
%local workdir;
%let workdir=%sysfunc(pathname(WORK));
x unzip -ao ../../raw/opm/&infile. &file. -d &workdir.;
%mend;


%macro readin_agy(input=,infile=FS_Employment_Dec2010.zip,outlib=WORK,old=no,append=yes);
%let workdir=%sysfunc(pathname(WORK));

%if ( "&old" = "yes" ) %then %do;
/* prior to 2009, files were fixed-width - formats were different */
%if ( "&input." = "" ) %then %let input=agysub;
%let rawdata=T&input.;
%let length1=4;
%let length2=45;
%let pos1=1;
%let pos2=%eval(&pos1.+&length1.);
%let pos1b=%eval(&pos2.-1);
%let pos2b=%eval(&pos2.+&length2.-1);
%unzip_2_work(file=&rawdata..txt,infile=&infile.);
/* read the raw file in */

  data &rawdata.;
    infile "&workdir./&rawdata..txt" 
	MISSOVER
	lrecl=%eval(&length1.+&length2.);
	length agysubt $ 118 agysub $ 4
	       agy $ 2 
	;
       informat agysub $&length1.. ;
       informat agysubt $&length2.. ;
	input agysub &pos1.-&pos1b. agysubt &pos2.-&pos2b.;
	/* these are for conformity with the more complete post-2009 formats */
	agy=substr(agysub,1,2);
	
run;

%end;

%else %do;
%if ( "&input." = "" ) %then %let input=agy;
%let rawdata=DT&input.;
%unzip_2_work(file=&rawdata..txt,infile=&infile.);
/* read the raw file in */
/*PROC IMPORT OUT= WORK.&rawdata. 
            DATAFILE= "&workdir./&rawdata..txt" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=800;  /* this solves a problem with some of the files */
data &rawdata. ;
	infile "&workdir./&rawdata..txt" delimiter=',' 
	MISSOVER 
	DSD lrecl=32767 firstobs=2;
	length 
		agysubt $ 118 
		agysub $ 4
	       	agy $ 2 
		agytypt $ 52
		agyt $ 90
	;
       informat agysub $4. ;
       informat agysubt $118. ;
	input agytyp agytypt $ agy $ agyt $ agysub $ agysubt $;

RUN;
%end; /* end else do condition */





proc print data=&rawdata.;
title2 "Processing &infile ";
run;

%if ( "&old" = "no" ) %then %do;
/* this is so that we have a list of departments only to merge onto older files */
proc sort data=&rawdata.(keep=agy agyt agytyp agytypt ) nodupkey out=dept_lookup;
by agy;
run;

proc append base=all_dept_lookup
	    data=dept_lookup;
run;
/* first step: unique by name and code */
proc sort data=all_dept_lookup nodupkey;
by agy agyt;
run;
/* second ste: unique by code only */
proc sort data=all_dept_lookup nodupkey dupout=dept_name_changes;
by agy;
run;
proc print data=dept_name_changes;
title2 "Departments that changed names - CAUTION!";
run;


%end; /* end old=no condition */
%else %do;
/* older files do not have the department names */
proc sort data=&rawdata;
by agy;
run;

data &rawdata;
	merge &rawdata.(in=a)
	      all_dept_lookup(in=b);
	by agy;
	if a;
	run;
%end; /* end older processing */

/* now do the real processing */

data &rawdata.;
	set &rawdata.(
	rename=(agy  = dept_subcode
	       agysub = deptagency
	       agyt = dept_full
		)
	)
	;
	length agency_auxiliary source_file $ 200;
        agency_subcode=substr(deptagency,3,2);
	agency_auxiliary=substr(agysubt,6,length(agysubt)-5);
	if agytyp ne 1 then dept_full="BLANK";
	source_file = "&infile.";
	label 
	source_file = "Filename from OPM public use files";
run;
proc contents data=&rawdata;
title2 "Contents of file: &infile. as read in ";
run;


%if ( "&append" = "yes" ) %then %do;

proc sort data=&rawdata. nodupkey;
by deptagency;
run;

proc append base=&outlib..opm_us_departments
	    data=&rawdata.;
run;

%end; /* end append condition */


%mend;
/*==============================================================================*/


/* prior to 2009, files were fixed-width - formats were different */
%macro readin_fixed_fmts(fmt=,infile=FS_Employment_Sept1999.zip,outfmtlib=WORK,input=,reducfmt=,outfmt=,
		length1=,length2=);
/* these are simple fixed field files - field 1 and 2 are all there is to it. 
   the macro call should specify the starting positions of each field */

%if ( "&input." = "" ) %then %let input=&fmt.;
%let rawdata=T&input.;
/* this is used to for reverse mapping */
%if ( "&reducfmt." = "" ) %then %do;
	%let reducfmt=&fmt.t;
	%let outfmt=&fmt.;
%end;
%else %do;
	/* for these, we redefine the outfmt name */
	%if ( "&outfmt." = "" ) %then %let outfmt=r&fmt.;	
%end;

%let pos1=1;
%let pos2=%eval(&pos1.+&length1.);
%let pos1b=%eval(&pos2.-1);
%let pos2b=%eval(&pos2.+&length2.-1);

%let workdir=%sysfunc(pathname(WORK));

%unzip_2_work(file=&rawdata..txt,infile=&infile.);
  data &rawdata.;
    infile "&workdir./&rawdata..txt" 
	MISSOVER
	lrecl=%eval(&length1.+&length2.);
       informat &fmt. $&length1.. ;
       informat &reducfmt. $&length2.. ;
	input &fmt. &pos1.-&pos1b. &reducfmt. &pos2.-&pos2b.;
run;

%create_format(rawdata=&rawdata.,fmt=&fmt.,reducfmt=&reducfmt.,outfmtlib=&outfmtlib.);

%mend;
/*==============================================================================*/

/* here we want to combine the subagencies */
/* we leverage the existing macros */
/* we first create the older Subagency format, then create the newer ones */
/* we then have two raw input files to the proc format: Tagysub and DTagysub */
/* these we combine, and re-create the final, combined format */
*readin_fixed_fmts(fmt=agysub,outfmtlib=opmfmt,length1=4,length2=45);

%readin_agy(infile=FS_Employment_Dec2013.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Sept2013.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Jun2013.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Mar2013.zip,outlib=WORK);

%readin_agy(infile=FS_Employment_Dec2012.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Sept2012.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Jun2012.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Mar2012.zip,outlib=WORK);

%readin_agy(infile=FS_Employment_Dec2011.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Sept2011.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Jun2011.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Mar2011.zip,outlib=WORK);

%readin_agy(infile=FS_Employment_Dec2010.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Sept2010.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Jun2010.zip,outlib=WORK);
%readin_agy(infile=FS_Employment_Mar2010.zip,outlib=WORK);

%readin_agy(infile=FS_Employment_Dec2009.zip,outlib=WORK);
/* from here, fixed format */
%readin_agy(infile=FS_Employment_Sept2009.zip,outlib=WORK,old=yes);

%readin_agy(infile=FS_Employment_Jun2009.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Mar2009.zip,outlib=WORK,old=yes);

%readin_agy(infile=FS_Employment_Dec2008.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Sept2008.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Jun2008.zip,outlib=WORK,old=yes,input=agesub);
%readin_agy(infile=FS_Employment_Mar2008.zip,outlib=WORK,old=yes);

%readin_agy(infile=FS_Employment_Dec2007.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Sept2007.zip,outlib=WORK,old=yes);

%readin_agy(infile=FS_Employment_Sept2006.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Sept2005.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Sept2004.zip,outlib=WORK,old=yes);
%readin_agy(infile=FS_Employment_Sept2003.zip,outlib=WORK,old=yes);


/* unduplicate: we keep the latest version */
proc sort data=WORK.opm_us_departments nodupkey;
by deptagency dept_full agency_auxiliary descending source_file;
run;

proc sort data=WORK.opm_us_departments nodupkey out=OUTPUTS.opm_us_departments;
by deptagency dept_full agency_auxiliary ;
run;


proc print data=OUTPUTS.opm_us_departments;
run;
