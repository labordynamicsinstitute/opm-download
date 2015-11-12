#!/bin/bash
# $Id$ 
# $URL$
# for reference:
wget -O opm_data_gov.html http://www.data.gov/catalog/raw/category/0/agency/0/filter/opm/type//sort//page/1/count/100#data
# for actual download
cd ../../raw/opm
for arg in Jun Dec Sept Mar
 do 
  for year in 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
   do 
     wget -O FS_Employment_${arg}${year}.zip \
          http://www.opm.gov/data/FedScope/FS_Employment_${arg}${year}.zip
   done
done
echo "Check for zero content files"

