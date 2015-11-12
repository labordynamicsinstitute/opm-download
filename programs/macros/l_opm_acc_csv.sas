/* $Id$ */
/* $URL$ */
/* layout for  OPM CSV data */

%macro l_opm_acc_csv(infile=,type=acc);
    infile "&infile." 
	delimiter = ',' 
	MISSOVER
 	DSD 
	lrecl=32767 
	firstobs=2 ;
       informat AGYSUB $4. ;
       informat EFDATE 6. ;
       informat LOC $2. ;
       informat AGELVL $1. ;
       informat GENDER $1. ;
       informat GSEGRD $2. ;
       informat LOSLVL $1. ;
       informat OCC $4. ;
       informat PATCO $1. ;
       informat PPGRD $5. ;
       informat SALLVL $1. ;
       informat TOA $2. ;
       informat WORKSCH $1. ;
       informat COUNT 1. ;
       informat SALARY best32. ;
       informat LOS best32. ;
       informat %upcase(&type.) $2. ;

       format AGYSUB $4. ;
       format %upcase(&type.) $2. ;
       format LOC $2. ;
       format AGELVL $1. ;
       format GENDER $1. ;
       format GSEGRD $2. ;
       format LOSLVL $1. ;
       format OCC $4. ;
       format PATCO $1. ;
       format PPGRD $5. ;
       format SALLVL $1. ;
       format TOA $2. ;
       format WORKSCH $1. ;
       format COUNT 1. ;
       format SALARY best12. ;
       format LOS best12. ;
    input
	AGYSUB $
                %upcase(&type.) $
                EFDATE 
                AGELVL $
                GENDER $
                GSEGRD
                LOSLVL $
                LOC $
                OCC $
                PATCO $
                PPGRD $
                SALLVL $
                TOA $
                WORKSCH $
                COUNT
                SALARY
                LOS 
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

