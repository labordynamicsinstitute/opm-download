/* $Id$ */
/* $URL$ */
/* layout for  OPM CSV data */

%macro l_opm_37(infile=);
    infile "&infile." 
	MISSOVER
	lrecl=37  ;
       informat AGYSUB $4. ;
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
       informat EMPLOYMENT 1. ;
       informat SALARY 6. ;
       informat LOS 5.2 ;

       format AGYSUB $4. ;
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
       format EMPLOYMENT best12. ;
       format SALARY best12. ;
       format LOS best12. ;
    input
                AGYSUB 1-4
                LOC 5-6
                OCC 7-10
                PATCO 11
                PPGRD 12-16
                GSEGRD 17-18
                SALLVL 19
                WORKSCH 20
                TOA 21-22
                GENDER 23
                AGELVL 24
                LOSLVL 25
                EMPLOYMENT 26
                SALARY 27-32
                LOS 33-37
    ;

	label
                AGYSUB = "Agency (including sub-agency)"
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
                EMPLOYMENT = "Employment - constant=1" 
                SALARY = "Average salary"
                LOS = "Average length of service"
	;
%mend;

