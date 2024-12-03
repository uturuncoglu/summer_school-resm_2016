#!/bin/bash
# example : ./patch.sh day2/src/roms-r809 day3/src/ocn/roms-r809 diff_r809.patch
diff -Naur -X exclude.pats $1 $2 >& $3
cat $3 | grep "+++"
