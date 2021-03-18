#!/usr/bin/ksh93
#######################################################################################
#
#  Filename    : unloadTable.ksh
#
#  Author      : Liru Chen
#
#  Date        : 2015-04-10
#                
########################################################################################
set -x
set -v

# tableName
tableList=/archbkup/log/loadtables
unloadDir=/archbkup/log
DATABASE=ip_0p@ipdb

tableNames=($(cat $tableList))
currentDate=$(date +%Y%m%d)

#setup Database environment
. /home/lchen/ids115.env $DATABASE

if [[ $1 == "data" ]]
then
	#download tables
	integer summ=${#tableNames[@]}
	integer i=0

	while (( i < summ ))
	do 
		echo "
		UNLOAD TO $unloadDir/${tableNames[$i]}.$currentDate
		SELECT * FROM ${tableNames[$i]}" |
		$INFORMIXDIR/bin/dbaccess $DATABASE

	i=i+1
	done

else
	#get table names
	echo "
	select tabname,nrows from systables " |
	$INFORMIXDIR/bin/dbaccess $DATABASE > $tableList

fi

exit 0



