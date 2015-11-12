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


%macro readin_fmts(fmt=,infile=FS_accessions_fy2010.zip,outfmtlib=WORK,input=,reducfmt=,outfmt=);


%if ( "&input." = "" ) %then %let input=&fmt.;
%let rawdata=DT&input.;
/* this is used to for reverse mapping */
%if ( "&reducfmt." = "" ) %then %do;
	%let reducfmt=&fmt.t;
	%let outfmt=&fmt.;
%end;
%else %do;
	/* for these, we redefine the outfmt name */
	%if ( "&outfmt." = "" ) %then %let outfmt=r&fmt.;	
%end;

%let workdir=%sysfunc(pathname(WORK));

%unzip_2_work(file=&rawdata..txt,infile=&infile.);
PROC IMPORT OUT= WORK.&rawdata. 
            DATAFILE= "&workdir./&rawdata..txt" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=800;  /* this solves a problem with some of the files */

RUN;
%create_format(rawdata=&rawdata.,fmt=&fmt.,reducfmt=&reducfmt.,outfmtlib=&outfmtlib.);

%mend;
/*==============================================================================*/
/* does the actual format creation */
%macro create_format(rawdata=,fmt=,reducfmt=,outfmtlib=);

proc print data=&rawdata.;
title2 "Processing FMT=&fmt. - input file ";
run;

data &rawdata.;
	set &rawdata.;
	rename &fmt.  = start
	       &reducfmt. = label
	;
	fmtname = "&outfmt.";
	type="C";
run;

proc sort data=&rawdata. nodupkey;
by start;
run;

proc format 
	library=&outfmtlib.
	cntlin=&rawdata.;
run;
%mend;
/*==============================================================================*/


/* prior to 2009, files were fixed-width - formats were different */
%macro readin_fixed_fmts(fmt=,infile=FS_accessions_fy2009.zip,outfmtlib=WORK,input=,reducfmt=,outfmt=,
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
/* most formats were already read in earlier */
%readin_fmts(fmt=acc,outfmtlib=opmfmt);
%readin_fmts(fmt=sep,infile=FS_separations_fy2010.zip,outfmtlib=opmfmt);

/* older formats */
%readin_fixed_fmts(fmt=acc,outfmtlib=opmfmt,length1=2,length2=48);
%readin_fixed_fmts(fmt=sep,infile=FS_separations_fy2009.zip,outfmtlib=opmfmt,length1=2,length2=48);


