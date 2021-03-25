#!/usr/bin/ksh
#Save cron jobs for everybody 

cd /insight/local/crontabs 
cp -p /var/spool/cron/crontabs/* .


