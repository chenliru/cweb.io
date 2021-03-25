#!/bin/ksh93
###########################################################################
#  Script modified from AWS Project for B3 purge by branch# and date
#
#  Author : Liru Chen
#  Date: 2017-08-22
###########################################################################
#set -v
#set -x

DATETIME=$(date +%Y%m%d%H%M)

#[[ -z ${BASE} ]] && BASE=/dbbkup
[[ -z ${BASE} ]] && exit 1
BIN=$BASE/bin
TMP=$BASE/tmp

DATADIR=${TMP}/data
SQLDIR=${TMP}/sql
LOGDIR=${TMP}/log

[[ ! -d ${DATADIR} ]] && mkdir -p ${DATADIR}
[[ ! -d ${SQLDIR} ]] && mkdir -p ${SQLDIR}
[[ ! -d ${LOGDIR} ]] && mkdir -p ${LOGDIR}

[[ ! -d ${DATADIR}/${DATETIME} ]] && mkdir ${DATADIR}/${DATETIME}
[[ ! -d ${SQLDIR}/${DATETIME} ]] && mkdir ${SQLDIR}/${DATETIME}
[[ ! -d ${LOGDIR}/${DATETIME} ]] && mkdir ${LOGDIR}/${DATETIME}

mv ${DATADIR}/exp.* ${DATADIR}/${DATETIME} > ${LOGDIR}/mv.tmp 2>&1
mv ${SQLDIR}/*.sql ${SQLDIR}/${DATETIME} >> ${LOGDIR}/mv.tmp 2>&1
mv ${LOGDIR}/*.token ${LOGDIR}/${DATETIME} >> ${LOGDIR}/mv.tmp 2>&1
mv ${LOGDIR}/*.log ${LOGDIR}/${DATETIME} >> ${LOGDIR}/mv.tmp 2>&1
			 
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

[[ -z ${TABLE_KEY} ]] && exit 1
	
. $IDSENV $IDSSERVER

_dbaccess () {
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
# - use "function" to set function "_clause", 
# - and use "typeset" to set function specified local variable "prtable" & "chtable"
#
function _clause {
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
		whereclause="$(grep ^WHERE ${TABLE_KEY})"
	else
		_clause ${prtable}
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

_statement () {

[[ $1 = "expimp" ]] && {
echo "UNLOAD TO ${DATADIR}/exp.$2.$3
SELECT $2.*
${fromclause%,} 
${whereclause}
;" > ${SQLDIR}/exp.$2.$3.sql
#${string%substring}, Strip shortest match of $substring, that is "," , from back of $string

echo "LOAD FROM ${DATADIR}/exp.$2.$3
INSERT INTO $2
;" > ${SQLDIR}/imp.$2.$3.sql
}

[[ $1 = "del" ]] && {
echo "DELETE FROM $2
WHERE ${chdwhereclause%,}
IN (
SELECT ${prselectclause%,}
${fromclause%,}
${whereclause}
)
;" > ${SQLDIR}/del.$2.$3.sql
#${string%substring}, Strip shortest match of $substring, that is "," , from back of $string
}

}

#Prepare SQL for all tables listed in TABLE_KEY
_sql () {
	tabnum=1
	
	grep -v "^$" $TABLE_KEY|grep -v ^WHERE|
	while read table_key
	do
		prtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f1 -d","|tr -d ' ')
		chtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f2 -d","|tr -d ' ')

		#1-building export and import SQL
		_clause ${chtable}

		_statement expimp ${chtable} ${tabnum}

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
	
		_clause ${prtable}		

		_statement del ${chtable} ${tabnum}
			
		((tabnum=tabnum+1))
	done
}

_sql > ${LOGDIR}/SQL.log 2>&1

#This is a recursive algorithm:
#
#Start from root table
#function will not call itself(stop), when no child table(s)
#
#1 - loading sequence: from parent table(root table) to child table(s), code in When recursive forward
#2 - unloading and delete sequence: from child talbe(s) to parent table(s), code in When recursive return
#
function _data {
	typeset prtable=$1
	typeset chtable=$(grep "^$1," ${TABLE_KEY}|cut -f1 -d"@"|cut -f2 -d","|tr -d ' ')
	
	##When recursive forward
	[[ ${ACTION} = "IMPORT" ]] && {
		for impsql in ${SQLDIR}/imp.${prtable}.*.sql
		do
			echo "${impsql}"
			_dbaccess "${impsql}"
			_dbaccess "select count(*) from ${prtable}"
		done	
	}


	#Check recursive continue condition, it will stop calling itself...
	for child in ${chtable}
	do 
		if [[ ${child} != "" && ${child} != ${prtable} ]]
		then
			_data ${child}
		fi
	done

	##When recursive return
	[[ ${ACTION} = "EXPORT" ]] && {
		for expsql in ${SQLDIR}/exp.${prtable}.*.sql
		do
			echo "${expsql}"
			_dbaccess "${expsql}"
			_dbaccess "select count(*) from ${prtable}"
		done	
	}
	
	[[ ${ACTION} = "DELETE" ]] && {
		for delsql in ${SQLDIR}/del.${prtable}.*.sql
		do
			echo "${delsql}"
			_dbaccess "${delsql}"
			_dbaccess "select count(*) from ${prtable}"
		done
	}
	
}

_main () {
grep -v "^$" $TABLE_KEY|grep -v ^WHERE|
while read table_key
do
	prtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f1 -d","|tr -d ' ')
	chtable=$(echo ${table_key}|cut -f1 -d"@"|cut -f2 -d","|tr -d ' ')

	if [[ ${prtable} = ${chtable} && ${chtable} != "" ]]
	then

while true
do
	
print "
Choose 1 : Export ${chtable} all related data
Choose 2 : Import ${chtable} all related data
Choose 3 : Delete ${chtable} all related data
Choose 4 : Exit
"
				
		read opt?"Input your choice:  " < $TERMINAL
		echo "\n"				
		read confirm?"Your choice is $opt,  Are you sure (Y/N) ?  " < $TERMINAL
		[[ ${confirm} = [yY] || ${confirm} = [yY]es ]] && {
				
			case $opt in
				1)	ACTION=EXPORT
					if [[ -e ${LOGDIR}/EXPORT.${chtable}.token ]]
					then
						echo "\n${RED}You already export all ${chtable} related data ${NORM}"
						continue
					fi
					;;
				2)	ACTION=IMPORT
					if [[ -e ${LOGDIR}/IMPORT.${chtable}.token ]]
					then
						echo "\n${RED}You already import all ${chtable} related data ${NORM}"
						continue
					elif [[ ! -e ${LOGDIR}/EXPORT.${chtable}.token ]]
					then
						echo "\n${RED}You must export all ${chtable} related data firstly ${NORM}"
						continue
					elif [[ ! -e ${LOGDIR}/DELETE.${chtable}.token ]]
					then
						echo "\n${RED}You must delete all ${chtable} related data before you can import ${NORM}"
						continue
					fi
					;;
				3)	ACTION=DELETE
					if [[ -e ${LOGDIR}/DELETE.${chtable}.token ]]
					then
						echo "\n${RED}You already delete all ${chtable} related data ${NORM}"
						continue
					elif [[ ! -e ${LOGDIR}/EXPORT.${chtable}.token ]]
					then
						echo "\n${RED}You must export all ${chtable} related data firstly ${NORM}"
						continue
					fi
					;;
				4)	break;;
				*)	ACTION=NONE
					echo "${RED}Enter choose must be 1,2,3,4 ${NORM}"
					continue
					;;
			esac
			
			touch ${LOGDIR}/${ACTION}.${chtable}.token
			_data ${chtable} 1> ${LOGDIR}/${ACTION}.${chtable}.log 2>&1

			grep -i err ${LOGDIR}/${ACTION}.${chtable}.log
			rc=$?
			if [[ ${rc} = 0 ]]
			then
				echo "${ACTION} start on ${chtable} error"
				rm -f ${LOGDIR}/${ACTION}.${chtable}.token
				exit 2
			fi
			
			[[ ${ACTION} = "DELETE" ]] && rm -f ${LOGDIR}/IMPORT.${chtable}.token
			[[ ${ACTION} = "IMPORT" ]] && rm -f ${LOGDIR}/DELETE.${chtable}.token
			
		}

done 

	fi

done 

}

_main

exit 0
