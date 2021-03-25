#!/bin/bash
date

. /home/dev.liiaws.net/lchen/.bash_profile_gtmdb

sqlplus dbadmin/gtmlab11%%00@gtmlab89 <<EOF
spool count.log
@count.sql
spool off
exit
EOF

