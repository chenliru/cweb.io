#!/bin/ksh93
#######################################################################
# Manual tool to retrieve inremental data using SQL
#----------------------------------------------------------------------
# 
# Author : Liru Chen
# Licensed Materials - Property of LIRU; All Rights Reserved 2015-2019
#######################################################################
#
# 1. manualy COPY Source SQL from AWS to /recyclebox/AWS/${AWSDATE} 
# 2. modify runall.sh, including the day, change script to rundatasql
# 3. run runall as lchen:
#    - Process these SQLs (using dbaccess)
#    - Change dbaccess output to unload format (using Perl)
#    - The inremental data is in /recyclebox/AWS/${AWSDATE}
#
set -v 
set -x

ps -ef|grep -v grep|grep aws
[[ $? -eq 0 ]] && exit

AWSDATE=$1
# AWSDATE=20151031
# AWSDATE=$(date +%Y%m%d)
AWSTIME=$(date +%Y%m%d%H%M%S)

AWSRUNDIR=/home/lchen/tools

#Parameters needed by shlib
AWSOUTBASE=/recyclebox/AWS
AWSOUTDIR=$AWSOUTBASE/${AWSDATE}
AWSTMPDIR=$AWSOUTBASE/tmp
[[ ! -d $AWSTMPDIR ]] && mkdir -p $AWSTMPDIR
[[ ! -d $AWSOUTDIR ]] && mkdir -p $AWSOUTDIR

export AWSBKUPDIR AWSINDIR AWSOUTDIR AWSRUNDIR AWSTMPDIR 

#Start generate incremental data
cd $AWSTMPDIR
rm -f *

cd $AWSRUNDIR

find ${AWSOUTDIR} -name *.sql -print|
while read current_time_sql
do
	./shlib awsdbaccess ${current_time_sql} 
done

find ${AWSTMPDIR} -name *.dbaccess -print|
while read current_time_dbaccess_out
do
	./shlib awsoutput ${current_time_dbaccess_out}
done

exit 0
