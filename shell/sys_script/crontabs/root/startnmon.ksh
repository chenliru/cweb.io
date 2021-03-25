#!/bin/ksh

date
cd /insight/nmon
nmon -f -t -r ifx01 -s900 -c90

exit 0

