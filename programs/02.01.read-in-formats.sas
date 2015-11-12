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


%macro readin_fmts(fmt=,infile=FS_Employment_Dec2010.zip,outfmtlib=WORK,input=,reducfmt=,outfmt=);


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

%readin_fmts(fmt=agelvl,outfmtlib=opmfmt);
%readin_fmts(fmt=gender,outfmtlib=opmfmt);
%readin_fmts(fmt=loslvl,outfmtlib=opmfmt);
%readin_fmts(fmt=patco,outfmtlib=opmfmt);
%readin_fmts(fmt=sallvl,outfmtlib=opmfmt);

/* format inputs with 4 variables */

%readin_fmts(fmt=toa,outfmtlib=opmfmt,input=toa);
%readin_fmts(fmt=toatyp,outfmtlib=opmfmt,input=toa);

%readin_fmts(fmt=wstyp,outfmtlib=opmfmt,input=wrksch);
%readin_fmts(fmt=worksch,outfmtlib=opmfmt,input=wrksch);

%readin_fmts(fmt=loc,outfmtlib=opmfmt,input=loc);
%readin_fmts(fmt=loctyp,outfmtlib=opmfmt,input=loc);

%readin_fmts(fmt=occ,outfmtlib=opmfmt,input=occ);
%readin_fmts(fmt=occfam,outfmtlib=opmfmt,input=occ);
%readin_fmts(fmt=occtyp,outfmtlib=opmfmt,input=occ);

%readin_fmts(fmt=agy,outfmtlib=opmfmt,input=agy);
%readin_fmts(fmt=agytyp,outfmtlib=opmfmt,input=agy);

%readin_fmts(fmt=pptyp,outfmtlib=opmfmt,input=ppgrd);
%readin_fmts(fmt=ppgroup,outfmtlib=opmfmt,input=ppgrd);
%readin_fmts(fmt=payplan,outfmtlib=opmfmt,input=ppgrd);

/* create reducing/mapping formats */
/* they are prefaced by a 'r' */

/* map locations to US/foreign : rloc */
%readin_fmts(fmt=loc,reducfmt=loctyp,outfmtlib=opmfmt,input=loc);

/* map subagencies to agencies : ragysub */
%readin_fmts(fmt=agysub,reducfmt=agy,outfmtlib=opmfmt,input=agy);
/* map agencies to agency types : ragy */
%readin_fmts(fmt=agy,reducfmt=agytyp,outfmtlib=opmfmt,input=agy);

/* map occupations to occupation families : rocc */
%readin_fmts(fmt=occ,reducfmt=occfam,outfmtlib=opmfmt,input=occ);
/* map occupations to white/blue-collar : rocctyp */
%readin_fmts(fmt=occ,reducfmt=occtyp,outfmtlib=opmfmt,input=occ,outfmt=rocctyp);

/* map payplans to higher categories : rppgrd */
%readin_fmts(fmt=ppgrd,reducfmt=payplan,outfmtlib=opmfmt,input=ppgrd);
%readin_fmts(fmt=ppgrd,reducfmt=pptyp,outfmtlib=opmfmt,input=ppgrd,outfmt=rpptyp);

/* older formats */
%readin_fixed_fmts(fmt=stcntry,outfmtlib=opmfmt,length1=2,length2=43);

/* here we want to combine the subagencies */
/* we leverage the existing macros */
/* we first create the older Subagency format, then create the newer ones */
/* we then have two raw input files to the proc format: Tagysub and DTagysub */
/* these we combine, and re-create the final, combined format */
%readin_fixed_fmts(fmt=agysub,outfmtlib=opmfmt,length1=4,length2=45);
%readin_fmts(fmt=agysub,outfmtlib=opmfmt,input=agy);

%let outfmtlib=opmfmt;

data complete_agysub;
	merge Tagysub(in=a)
	      DTagy(in=b)
	;
	by start;
	_merge = a+2*b;
run;
proc freq data=complete_agysub;
title2 "Agencies in past and present ";
table _merge;
run;

proc print data=complete_agysub;
run;



proc format 
	library=&outfmtlib.
	cntlin=complete_agysub;
run;

