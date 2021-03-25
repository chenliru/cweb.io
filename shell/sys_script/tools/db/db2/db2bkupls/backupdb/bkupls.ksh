#!/bin/ksh

# setup db2 environment
if [ -f /home/db2inst1/sqllib/db2profile ]; then
   . /home/db2inst1/sqllib/db2profile
fi

# backup db ls
db2 backup db icmnlsdb online compress include logs

exit 0

