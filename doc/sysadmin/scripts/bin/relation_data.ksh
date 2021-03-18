#!/bin/ksh93
###########################################################################
#  Script modified from AWS Project for B3 purge by branch# and date
#
#  Author : Liru Chen
#  Date: 2017-08-22
###########################################################################
set -v
set -x

DATETIME=$(date +%Y%m%d%H%M)

BASE=/dbbkup
BIN=$BASE/bin
TMP=$BASE/tmp
ETC=$BASE/etc
LOG=$BASE/log

DATADIR=${ETC}/data
SQLDIR=${ETC}/sql

[[ ! -d ${BIN} ]] && mkdir -p ${BIN}
[[ ! -d ${LOG} ]] && mkdir -p ${LOG}
[[ ! -d ${DATADIR} ]] && mkdir -p ${DATADIR}
[[ ! -d ${SQLDIR} ]] && mkdir -p ${SQLDIR}

[[ ! -d ${DATADIR}/${DATETIME} ]] && mkdir ${DATADIR}/${DATETIME}
[[ ! -d ${SQLDIR}/${DATETIME} ]] && mkdir ${SQLDIR}/${DATETIME}

mv ${DATADIR}/unload.* ${DATADIR}/${DATETIME}
mv ${SQLDIR}/*.sql ${SQLDIR}/${DATETIME}
			
PATH=$BASE/bin:$PATH
export PATH
export TERMINAL=$(tty)

RED="\033[0;31m"
NORM="\033[0m"

#INFORMIX DYNAMIC SERVER
if [[ $(hostname) = "ifx01" ]]
then
	IDSENV="/home/informix/ids115.env"
	IDSSERVER="ipdb"
	IDSDB="ip_0p"
elif [[ $(hostname) = "ipdev" ]]
then 
	IDSENV="/login/infown/ids115.env"
	IDSSERVER="systestdb"
	IDSDB="ip_systest"
fi

#Define tables and the foreign keys between them, Format:
#
#	roottable,roottable@select_critial_column_statement
#
#	Parent_Table,Child_Table@Foreign_Key_column,Foreign_Key_column,...
#   ......
#

TABLE_KEY=${ETC}/table_key
	
. $IDSENV $IDSSERVER

func_dbaccess () {
	if [[ -f $1 ]]
	then
		dbaccess $IDSDB $1
	else
		echo "$1" | dbaccess $IDSDB 
	fi
}

#This is a recursive algorithm:
#
#function call itself, find all related tables after each function return,
#function will not call itself (ends cycling) when "${prtable} = ${chtable}" ,that is the root table
#
#Set function local variable in KSH:
#
# - use "function" to set function "func_clause", 
# - and use "typeset" to set function specified local variable "prtable" & "chtable"
#
function func_clause {
	tables=$(grep "$1,@" ${TABLE_KEY}|cut -f1 -d"@"|tr -d ' ')
	
	typeset prtable=$(echo "${tables},"|cut -f1 -d",")
	typeset chtable=$(echo "${tables},"|cut -f2 -d",")
	
	#both parent table and child table must exist, and name cannot be empty
	[[ ${prtable} = "" || ${chtable} = ""  ]] && exit 2	
	
	##When recursive forward
	echo "Tables: ${tables}; Parent: ${prtable} Child: ${chtable}"

	#Check recursive continue condition, it will stop calling itself...
	if [[ ${prtable} = ${chtable} ]]
	then
		fromclause="FROM "
		whereclause="WHERE ($(grep "$1,@" ${TABLE_KEY}|cut -f2 -d"~"))"
	else
		func_clause ${prtable}
	fi

	##When recursive return
	
	#2-building from clause, function parameters $1 will be kept for each recursive call
	keys=$(grep "$1,@" ${TABLE_KEY}|cut -f2 -d"@"|tr -d ' ')
	fromclause="${fromclause} ${chtable},"
	
	#3-building where clause
	nums=1
	key=$(echo ${keys}|cut -f1 -d",")
	
	until [[ ${key} = "" ]] 
	do
		[[ ${prtable} != ${chtable} ]] && whereclause="${whereclause}
AND ${prtable}.${key} = ${chtable}.${key}"
				
		((nums=nums+1))
		key=$(echo ${keys}|cut -f${nums} -d",")
	done
}

func_sql () {
[[ ${ACTION} = "UNLOAD" ]] && {
echo "UNLOAD TO ${DATADIR}/unload.$1.$2
SELECT $1.*
${fromclause%,} 
${whereclause}
;" > ${SQLDIR}/unload.$1.$2.sql	
#${string%substring}, Strip shortest match of $substring, that is "," , from back of $string
}

[[ ${ACTION} = "LOAD" ]] && {
echo "LOAD FROM ${DATADIR}/unload.$1.$2
INSERT INTO $1
;" > ${SQLDIR}/load.$1.$2.sql
}

[[ ${ACTION} = "PURGE" ]] && {
echo "DELETE FROM $1
WHERE ${chdwhereclause%,}
IN (
SELECT ${prselectclause%,}
${fromclause%,}
${whereclause}
)
;" > ${SQLDIR}/delete.$1.$2.sql
#${string%substring}, Strip shortest match of $substring, that is "," , from back of $string
}

}

#This is a recursive algorithm:
#
#Start from root table
#function will not call itself(stop), when no child table(s)
#
#1 - loading sequence: from parent table(root table) to child table(s), code in When recursive forward
#2 - unloading and delete sequence: from child talbe(s) to parent table(s), code in When recursive return
#
function func_data {
	typeset prtable=$1
	typeset chtable=$(grep "^$1," ${TABLE_KEY}|cut -f1 -d"@"|cut -f2 -d","|tr -d ' ')
	
	##When recursive forward
	[[ ${ACTION} = "LOAD" ]] && {
		#find ${SQLDIR} -name "load.${prtable}.*.sql" -print|
		for loadsql in ${SQLDIR}/load.${prtable}.*.sql
		do
			echo "${loadsql}"
			func_dbaccess "${loadsql}"
			func_dbaccess "select count(*) from ${prtable}"
		done	
	}


	#Check recursive continue condition, it will stop calling itself...
	for child in ${chtable}
	do 
		if [[ ${child} != "" && ${child} != ${prtable} ]]
		then
			func_data ${child}
		fi
	done

	##When recursive return
	[[ ${ACTION} = "UNLOAD" ]] && {
		#find ${SQLDIR} -name "unload.${prtable}.*.sql" -print|
		for unloadsql in ${SQLDIR}/unload.${prtable}.*.sql
		do
			echo "${unloadsql}"
			func_dbaccess "${unloadsql}"
			func_dbaccess "select count(*) from ${prtable}"
		done	
	}
	
	[[ ${ACTION} = "PURGE" ]] && {
		#find ${SQLDIR} -name "delete.${prtable}.*.sql" -print|
		for deletesql in ${SQLDIR}/delete.${prtable}.*.sql
		do
			echo "${deletesql}"
			func_dbaccess "${deletesql}"
			func_dbaccess "select count(*) from ${prtable}"
		done
	}
	
}

#Prepare SQL for related tables
func_table_sql () {
	tabnum=1
	
	grep -v "^$" $TABLE_KEY|
	while read table_key
	do
		prtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f1 -d","|tr -d ' ')
		chtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f2 -d","|tr -d ' ')

		#1-building unload and loading SQL
		func_clause ${chtable}
		ACTION=UNLOAD;func_sql ${chtable} ${tabnum}
		ACTION=LOAD;func_sql ${chtable} ${tabnum}

		#2-building delete SQL
		keys=$(echo ${table_key}|cut -f2 -d"@"|tr -d ' '),
		
		nums=1
		key=$(echo "${keys}"|cut -f1 -d",")
		chdwhereclause=""
		prselectclause=""

		until [[ ${key} = "" ]] 
		do
			chdwhereclause="${chtable}.${key},${chdwhereclause}"
			prselectclause="${prtable}.${key},${prselectclause}"
				
			((nums=nums+1))
			key=$(echo "${keys}"|cut -f${nums} -d",")
		done
	
		func_clause ${prtable}		
		ACTION=PURGE;func_sql ${chtable} ${tabnum}
			
		((tabnum=tabnum+1))
	done
}

func_table_sql

func_table_data () {

	grep -v "^$" $TABLE_KEY|
	while read table_key
	do
		prtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f1 -d","|tr -d ' ')
		chtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f2 -d","|tr -d ' ')

		if [[ ${prtable} = ${chtable} && ${chtable} != "" ]]
		then
			ACTION=UNLOAD;func_data ${chtable} 1> ${LOG}/b3archive.log 2>&1
			grep -i err ${LOG}/b3archive.log
			[[ $? = 0 ]] && {
				echo "Download error"
				exit 2
			}
			
			while true
			do
	print "
	Choose 1 : Load the data you downloaded
	Choose 2 : Purge the data you downloaded
	Choose 3 : Exit
	"
				read opt
				echo opt: $opt
				
				case $opt in
					1)	ACTION=LOAD;;
					2)	ACTION=PURGE;;
					3)	ACTION=NONE;exit 3;;
					*)	ACTION=NONE;echo "${RED} your choose?... ${NORM}";;
				esac

				echo "Your ACTION: $ACTION ${chtable}, you have 10 seconds to press ^c"
				sleep 10
				
				func_data ${chtable} 1> ${LOG}/b3purge.log 2>&1
				grep -i err ${LOG}/b3purge.log
				[[ $? = 0 ]] && {
					echo "Load and/or Purge error"
					exit 2
				}
			done < $TERMINAL
		fi
	done
}

func_table_data

exit 0
