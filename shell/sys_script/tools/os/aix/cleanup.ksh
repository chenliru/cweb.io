#!/bin/ksh
#
#
set -x
date

find /tsmha1/preschedule -name "db2*bkup*06*" -type f -mtime +2 -exec /usr/bin/rm -f {} \; \
 >> /home/lchen/admin/log/cleanupLog/cleanup.log 2>&1

cat /dev/null > /usr/IBMHttpServer/logs/access_log
cat /dev/null > /usr/IBMHttpServer/logs/error_log

exit 0

