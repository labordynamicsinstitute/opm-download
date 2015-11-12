/* $Id$ */
/* $URL$ */
/* layout for  OPM CSV data */

%macro l_opm_acc_45(infile=,type=acc);
    infile "&infile." 
	MISSOVER
	lrecl=45  ;
       informat AGYSUB $4. ;
       informat %upcase(&type.) $2.;
       informat EFDATE 6.;
       informat AGELVL $1. ;
       informat GENDER $1. ;
       informat GSEGRD $2. ;
       informat LOSLVL $1. ;
       informat LOC $2. ;
       informat OCC $4. ;
       informat PATCO $1. ;
       informat PPGRD $5. ;
       informat SALLVL $1. ;
       informat TOA $2. ;
       informat WORKSCH $1. ;
       informat COUNT 1. ;
       informat SALARY 6. ;
       informat LOS 5.2 ;

    input
                AGYSUB 1-4
                %upcase(&type.) 5-6
                EFDATE 7-12
                LOC 13-14
                OCC 15-18
                PATCO 19
                PPGRD 20-24
                GSEGRD 25-26
                SALLVL 27
                WORKSCH 28
                TOA 29-30
                GENDER 31
                AGELVL 32
                LOSLVL 33
                COUNT 34
                SALARY 35-40
                LOS 41-45
    ;

	label
                AGYSUB = "Agency (including sub-agency)"
%if ( "&type." = "acc" ) %then %do;
		ACC    = "Accession type"
	        EFDATE = "Date (month) of accession"
%end;
%if ( "&type." = "sep" ) %then %do;
		SEP    = "Separation type"
	        EFDATE = "Date (month) of separation"
%end;
                LOC = "Location code"
                AGELVL = "Age (intervals)"
                GENDER = "Gender M/F"
                GSEGRD = "General Schedule and Equivalent Grade"
                LOSLVL = "Length of service levels"
                OCC = "Occupation"
                PATCO = "Occupation Category"
                PPGRD = "Pay plan and grade"
                SALLVL = "Salary level"
                TOA = "Type of appointment"
                WORKSCH = "Work schedule"
		COUNT = "Constant =1 "
                SALARY = "Average salary"
                LOS = "Average length of service"
	;
%mend;

