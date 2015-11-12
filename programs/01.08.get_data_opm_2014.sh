#!/bin/bash
# $Id$ 
# $URL$
cd ../../raw/opm
cat > _tmp.csv << EOF
http://www.opm.gov/Data/Files/410/e8b6db73-a3f4-4c96-a141-479343e239c8.zip,Employment,Jun2015
http://www.opm.gov/Data/Files/400/07efa0ae-79ce-4b1b-a627-2f6eff56b6ef.zip,Employment,Mar2015
http://www.opm.gov/Data/Files/397/a7b2c51d-5c6b-4a73-beb4-01d5ef8564ad.zip,Employment,Dec2014
http://www.opm.gov/Data/Files/387/0fef14f2-5729-4efb-b459-fcb2f764d826.zip,sep,2014
http://www.opm.gov/Data/Files/386/4465aa1a-61df-4484-a648-5e9680aefa08.zip,acc,2014
http://www.opm.gov/Data/Files/381/02a57da4-18f3-4a06-9506-52749207cadf.zip,Employment,Sept2014
http://www.opm.gov/Data/Files/371/1f77e351-ae1f-4121-8631-eb5f959ca1cc.zip,Employment,Jun2014
http://www.opm.gov/Data/Files/347/d2376df8-82d0-4850-9e4b-6872649c800e.zip,Employment,Mar2014
http://www.opm.gov/Data/Files/340/94dcf7d8-6f7a-41f0-88d6-24b1044c2590.zip,Employment,Dec2013
EOF
# now process the file
cat _tmp.csv | awk -F, ' { print "firefox --new-window " $1 }' > _tmp.sh
sed 's/,sep,/,separations_fy,/; s/,acc,/,accessions_fy,/; s/,Employment,/,Employment_,/' _tmp.csv |\
awk -F, ' { print "arg=" $1 ";mv $(basename $arg) FS_" $2 $3 ".zip" } '  > _tmp2.sh
# now execute it
#. _tmp.sh 
