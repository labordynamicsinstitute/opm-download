/* $Id$ */
/* $URL$ */
/* layout for  OPM CSV data */
/* From Sept 2013 to - */

%macro l_opm_csv3(infile=);
    infile "&infile." 
	delimiter = ',' 
	MISSOVER
 	DSD 
	lrecl=32767 
	firstobs=2 ;
       informat AGYSUB $4. ;
       informat LOC $2. ;
       informat AGELVL $1. ;
       informat	EDLVL		$2.;
       informat GENDER $1. ;
       informat GSEGRD $2. ;
       informat LOSLVL $1. ;
       informat OCC $4. ;
       informat PATCO $1. ;
       informat PPGRD $5. ;
       informat SALLVL $1. ;
       informat	STEMOCC		$4.;
       informat	SUPERVIS	$1.;
       informat TOA $2. ;
       informat WORKSCH $1. ;
       informat	WORKSTAT	$1.;
       informat DATECODE $6. ;
       informat EMPLOYMENT best32. ;
       informat SALARY best32. ;
       informat LOS best32. ;

       format AGYSUB $4. ;
       format LOC $2. ;
       format AGELVL $1. ;
       FORMAT		EDLVL		$2.;
       format GENDER $1. ;
       format GSEGRD $2. ;
       format LOSLVL $1. ;
       format OCC $4. ;
       format PATCO $1. ;
       format PPGRD $5. ;
       format SALLVL $1. ;
       FORMAT		STEMOCC		$4.;
       FORMAT		SUPERVIS	$1.;
       format TOA $2. ;
       format WORKSCH $1. ;
       FORMAT		WORKSTAT	$1.;
       format DATECODE $6.;
       format EMPLOYMENT best12. ;
       format SALARY best12. ;
       format LOS best12. ;
    input
AGYSUB
LOC
AGELVL
EDLVL
GENDER
GSEGRD
LOSLVL
OCC
PATCO
PPGRD
SALLVL
STEMOCC
SUPERVIS
TOA
WORKSCH
WORKSTAT
DATECODE
EMPLOYMENT 	
SALARY 		
LOS;
    ;

	label
                AGYSUB = "Agency (including sub-agency)"
                LOC = "Location code"
                AGELVL = "Age (intervals)"
		EDLVL = "Education level"
                GENDER = "Gender M/F"
                GSEGRD = "General Schedule and Equivalent Grade"
                LOSLVL = "Length of service levels"
                OCC = "Occupation"
                PATCO = "Occupation Category"
                PPGRD = "Pay plan and grade"
                SALLVL = "Salary level"
	        STEMOCC = "STEM Occupations"
	        SUPERVIS = "Supervisory status"
                TOA = "Type of appointment"
                WORKSCH = "Work schedule"
                WORKSTAT = "Work status"
                DATECODE = "Date code"
                EMPLOYMENT = "Employment - constant=1" 
                SALARY = "Average salary"
                LOS = "Average length of service"
	;
	drop DATECODE;
%mend;

