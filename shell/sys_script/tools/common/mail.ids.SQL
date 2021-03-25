#!/bin/ksh
###############################################################
# Description: The best way to know the activity of Livingston 
#              Production informix database is to collect the 
#              SQL statements when Insight data-loading 
#              application(./tcl) running.
#
# Author : Liru Chen
# Version : 1.0; date: 2012-03-05
#
################################################################
set -v
set -x

if [[ $# -lt 1 ]]; then
    echo " USAGE: mail.ids.SQL informix_instance"
    echo " "
    #exit 2
fi

. ~/tools.profile

instance=${1-$IDSSERVER}
tempfile=$TMPDIR/tmp.$(basename $0)
##################################################################
# Program : ids.traceSQL
# Purpose : Script to collect the active SQL of informix.
##################################################################
tcl=`ps -ef | grep -v grep | grep ./tcl | wc -l`
icc=`ps -ef | grep -v grep | grep "1       ifx01" | wc -l`
if [[ $tcl -eq 0 ]] && [[ $icc -eq 0 ]]; then
exit 1
fi

ids.trace.SQL $instance  > $tempfile

mail -s " System `hostname` informix SQL Log " $SYSADMEMAIL < $tempfile

rm -f $tempfile

###############
# end
###############

