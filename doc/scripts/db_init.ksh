#!/usr/bin/ksh93
#######################################################################################
#
#  File name		: db_init.ksh
#
#  Description	: Recover Informix database
#  Phase I
#    1. Install Informix Software/Recover from File system backup
#    2. Environment configuration: $. ./ids115.env systestdb/ipdb
#    2. Configuration file: 
#       $INFORMIXDIR/etc/ONCONFIG, $INFROMIXDIR/etc/SQLHOSTS, /etc/SERVICES
#       Should be very careful and do it only you have no other choice: oninit -i
#    3. DBSpaces and Chunks from onstat -d
#       touch chunks;chown informix:informix *; chmod 660 *
#       onspaces -c -d datadbs1 -p ... -o 0 -s 1000000
#       onspaces -a -d datadbs1 -p ... -o 0 -s 1000000
#
#       onparams  for logic logs creation
#       onspaces -c -t -d tempdbs1 -p ... -o 0 -s 1000000
#       
#  Phase II  
#	1. create database ip_systest and tables using SQL_db_table
#	2. load data to tables by table using loadTable.ksh
#	3. create procedure using SQL_procedure
#	4. create view, index, constraint and trigger 
#				     
#
#  Author		: Liru Chen
#
#  Date        : 2015-05-15
#                
########################################################################################
set -x
set -v

# environment
currentDate=$(date +%Y%m%d)
workDir=/login/lchen/tools/db/informix
#DATABASE=sysmaster@systestdb
DATABASESVR=systestdb


# SQL for DB
SQL_db_table=$workDir/etc/db_tables.sql
SQL_procedure=$workDir/etc/db_procedures.sql
SQL_view=$workDir/etc/db_views.sql
SQL_index=$workDir/etc/db_indexes.sql
SQL_constraint=$workDir/etc/db_constraints.sql
SQL_trigger=$workDir/etc/db_triggers.sql

#setup Database environment
. /login/lchen/ids115.env $DATABASESVR

#dbaccess - $SQL_db_table		#comment this when DB & tables already created 
# {cd $workDir/bin; nohup $workDir/bin/loadTable.ksh & }	#comment this when table data load completed
#dbaccess - $SQL_procedure		#comment this when Procedures already created
#dbaccess - $SQL_view			#comment this when Views already created
#dbaccess - $SQL_index			#comment this when Indexs already created
#dbaccess - $SQL_constraint		#comment this when Constraints already created
#dbaccess - $SQL_trigger		#comment this when Triggers already created

exit 0