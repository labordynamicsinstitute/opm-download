/* $Id$ */
/* $URL$ */
/* concatenate quarterly OPM data */


%include "config.sas"/source2;

%macro concat(outname=opmpu_us,type=acc,inputs=yearly);

data files;
   keep sasname;
   rc=filename("mydir","%sysfunc(pathname(&inputs.))");
   did=dopen("mydir");
   if did > 0 then do;
     /* get number of files in the directory */
     numfiles=dnum(did);
     /* cycle through the files */
     do i = 1 to numfiles;
	name=dread(did,i);
        if substr(name,1,12)="opmpu_us_&type." 
	   and scan(name,2,'.')="sas7bdat" then do;
		sasname=trim(left(scan(name,1,'.')));
		output;
	end; /* end condition */
      end; /* end i loop */
   did=dclose(did);
   end; /* end did condition */
run;

proc sort data=files;
by sasname;
run;

proc print data=files;
run;

data _null_;
	set files;
	     	call execute("proc append base=&outname._&type.");
		call execute("  data=&inputs.."||sasname);
		call execute("; run;");
run;

proc sort data=&outname._&type. out=OUTPUTS.&outname._&type.;
by year ;
run;

proc freq data=OUTPUTS.&outname._&type.;
title "OPM PU &type.. by year ";
table year;
run;

%mend;
%concat(type=acc,inputs=yearly);
%concat(type=sep,inputs=yearly);
