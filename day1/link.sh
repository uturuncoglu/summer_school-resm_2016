#!/bin/bash

idir='/RS/users/du001/workshop/day1/output'

mkdir RegCM
cd RegCM

lst=`ls -al $idir/*.nc | grep -e "ATM" -e "SRF" -e "RAD" | awk '{print $9}'`
for i in $lst
do 
  ofile=${i/MED50_/}
  ofile=`echo $ofile | awk -F/ '{print $NF}'`
  rm -f $ofile
  ln -s $i $ofile
done

cd -
