#!/bin/ksh
#####################################################
# The script will remove all the files older than
# 2 days under /netins directory
# Author: Bob Chong
# Date: Nov 1, 2001
##################################################### 

# cleanup "t" files and "link" files in /netins
/usr/bin/find /netins -name "t[0-9]*.txt" -type f -mtime +1 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find /netins -type l -mtime +1 -exec rm -f {} \; > /dev/null 2>&1

exit 0

