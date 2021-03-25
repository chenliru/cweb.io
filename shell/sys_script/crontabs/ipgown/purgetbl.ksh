#!/usr/bin/ksh
#######################################################################
# The script will create a SQL file to purge "t" tables and "t" records
# older than 2 days. And it will remove the tables and rows.
# Author: Bob Chong
# Date: Nov 1, 2001
########################################################################

umask 0000

INFORMIXDIR=/usr/apps/inf/ver115UC3
INFORMIXSERVER="ipdb"
PATH=$INFORMIXDIR/bin:$PATH
export INFORMIXDIR INFORMIXSERVER PATH

local_dir=/home/ipgown/purgebds
job_file=/home/ipgown/purgebds/joblist.txt
sql_file=/home/ipgown/purgebds/purgetbl.sql
out_file=/home/ipgown/purgebds/outlist.txt
cd $local_dir

$INFORMIXDIR/bin/dbaccess ip_0p@ipdb  - << EOF > $job_file 2>&1 
select "#JOB#", tabname[1,20], tabid 
from systables 
where tabname matches 't[0-9][0-9][0-9][0-9]*'
  and (today - created) > 1
order by tabname;
EOF

grep '\#JOB\#' $job_file | while read JOB BATCH_ID TABID; 
do
    echo "drop table $BATCH_ID;" >> $sql_file
    echo "delete from srch_crit_batch where tablename=\""$BATCH_ID"\";" >> $sql_file
    echo "delete from bat_info where qms_id=\""$BATCH_ID"\";" >> $sql_file
done

if [[ -a $sql_file ]]
then 
$INFORMIXDIR/bin/dbaccess ip_0p@ipdb < $sql_file > $out_file 2>&1

#rm $sql_file
#rm $out_file
fi

#rm $job_file

exit 0
