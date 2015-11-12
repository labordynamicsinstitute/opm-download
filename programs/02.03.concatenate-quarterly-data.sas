/* $Id$ */
/* $URL$ */
/* concatenate quarterly OPM data */


%include "config.sas"/source2;
%let outname=opmpu_us;
%let inputs=quartrly;

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
        if substr(name,1,9)="opmpu_us_" and substr(name,14,1)="q"
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
	     	call execute("proc append base=&outname.");
		call execute("  data=&inputs.."||sasname);
		call execute("; run;");
run;

proc sort data=&outname. out=OUTPUTS.&outname.;
by year quarter;
run;

proc freq data=OUTPUTS.&outname.;
title "OPM PU by year and quarter";
table year*quarter;
run;

