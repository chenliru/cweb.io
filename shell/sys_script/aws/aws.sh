#!/bin/ksh93
###########################################################################
#  AWS Project
#
#  Author : Liru Chen
#  Date: 2015-09-22
###########################################################################
##Date & Time
current_date=$(date +%Y%m%d)
current_time=$(date +%Y%m%d%H%M%S)

BASE=/insight/local/scripts/VaxParser/tools
BIN=$BASE/bin
TMP=$BASE/tmp
ETC=$BASE/etc
LOG=$BASE/log
[[ ! -d ${LOG} ]] && mkdir -p ${LOG}
[[ ! -d ${TMP} ]] && mkdir -p ${TMP}
[[ ! -d ${ETC} ]] && mkdir -p ${ETC}
[[ ! -d ${BIN} ]] && mkdir -p ${BIN}
export BASE BIN TMP ETC LOG

#INFORMIX DYNAMIC SERVER
IDSENV="/home/informix/ids115.env"
IDSSERVER="ipdb"
IDSDB="ip_0p"

export IDSENV IDSSERVER IDSDB

PATH=$BASE/bin:$PATH
export PATH

#AWS running environment
AWSB3="	b3b,b3@b3iid,
		containers,b3@b3iid,
		status_history,b3@b3iid,status,
		b3_subheader,b3@b3iid,
		b3_line,b3_subheader@b3subiid,
		b3_line_comment,b3_line@b3lineiid,
		b3_recap_details,b3_line@b3lineiid,
	"

. $IDSENV ${IDSSERVER}

tcolumn () {

	tcolumn_db=$1
	tcolumn_table=$2
	
	echo "select colname from systables,syscolumns
		where tabname like '${tcolumn_table}'
		and systables.tabid=syscolumns.tabid
		order by colno" | dbaccess ${tcolumn_db} |
		grep colname | grep -v "^$"

}

#Build AWS SELECT CLAUSE ( as globle variable ${select_clause} ) based on the all the columns of the table 
awscolums () {

	awscolums_table_name=$(echo $1|tr A-Z a-z)
	
	awscolums_server=${IDSSERVER}
	awscolums_database=${IDSDB}
	
	first_column="Y"
	select_clause=""

	tcolumn ${awscolums_database} ${awscolums_table_name} |
	while read column columnname
	do
		if [[ ${first_column} == "Y" ]]
		then
			select_clause="SELECT ${awscolums_table_name}.${columnname},'~'"
			first_column="N"
		else
			select_clause="${select_clause},${awscolums_table_name}.${columnname},'~'"
		fi
	done

}

#Prepare SQL by reading each record provided by VAXFilesParser output, call txt2sql.pl
awssql_obsolete () {
	
	awssql_input_key=$1
	echo "" >> ${awssql_input_key}		#add one more line to the end of input key files

	last_table_name=""	

	integer single_table_key=$(sort ${awssql_input_key}|uniq|cut -f1 -d"~"|uniq|grep -v "^$"|wc -l)
	
	#The command first compares adjacent lines and then removes the second and succeeding 
	#duplications of a line. Duplicated lines must be adjacent. (Before issuing the uniq 
	#command, use the sort command to make all duplicate lines adjacent)
	sort ${awssql_input_key} | uniq |
	while read awssql_record_line
	do

		awssql_table_name=$(echo "${awssql_record_line}~"|cut -f1 -d"~"|tr A-Z a-z)
		[[ ${awssql_table_name} == "" ]] && continue	#empty line

		awssql_table_condition=$(echo "${awssql_record_line}~"|cut -f2- -d"~")
		[[ ${awssql_table_condition} == "" ]] && {
			echo " ${awssql_input_key} wrong input key format"
			return		#wrong input key format
		}
		
		awssql_table_vax=${AWSTMPDIR}/${awssql_table_name}.${current_time}.vax4sql
		awssql_table_sql=${AWSTMPDIR}/${awssql_table_name}.${current_time}.sql
	
		[[ ${last_table_name} != ${awssql_table_name} ]] && {
			last_table_name=${awssql_table_name}

			sort ${awssql_input_key} | uniq | grep -i "^${awssql_table_name}~" > ${awssql_table_vax}
			
			txt2sql.pl ${awssql_table_vax} > ${awssql_table_sql}.tmp

			awscolums ${awssql_table_name}

			#Substitute with sed
			sed 's/^SELECT_CLAUSE.*/'"${select_clause}"'/g' \
			${awssql_table_sql}.tmp > ${awssql_table_sql}
			
			[[ ${single_table_key} -eq 1 ]] && break
			
		}

		
	done

}

#Prepare SQL by reading each record provided by VAXFilesParser output, call txt2sql.pl
awssql () {
	
	awssql_input_key=$1
	echo "" >> ${awssql_input_key}		#add one more line to the end of input key files

	table_names=$(sort ${awssql_input_key}|uniq|cut -f1 -d"~"|uniq|grep -v "^$"|tr A-Z a-z)
	
	for table_name in $table_names
	do
		awssql_table_vax=${AWSTMPDIR}/${table_name}.${current_time}.vax4sql
		awssql_table_sql=${AWSTMPDIR}/${table_name}.${current_time}.sql	
		
		#The command first compares adjacent lines and then removes the second and succeeding 
		#duplications of a line. Duplicated lines must be adjacent. (Before issuing the uniq 
		#command, use the sort command to make all duplicate lines adjacent)
		sort ${awssql_input_key} | uniq | grep -i "^${table_name}~" > ${awssql_table_vax}
		
		echo "" >> ${awssql_table_vax}		#add one more line to the end of vax key files
		
		txt2sql.pl ${awssql_table_vax} > ${awssql_table_sql}.tmp

		awscolums ${table_name}

		#Substitute with sed
		sed 's/^SELECT_CLAUSE.*/'"${select_clause}"'/g' \
		${awssql_table_sql}.tmp > ${awssql_table_sql}
	
	done

}

#pass arguments to sed, append $2 to a line with pattern $1 in file $3
seda () {
sed '
/'"$1"'/ a\
'"$2"'
' $3
}

#pass arguments to sed, insert a line $2 with pattern $1 in file $3
sedi () {
sed '
/'"$1"'/ i\
'"$2"'
' $3
}

#Prepare SQL for B3 related tables
awsb3 () {
	
	last_table_name=""

	for awsb3_table in ${AWSB3}
	do
		awsb3_tablename=$(echo "${awsb3_table}@"|cut -f1 -d"@"|tr A-Z a-z)
		
		#tablename is uppercase
		awsb3_tone=$(echo "${awsb3_tablename},"|cut -f1 -d",")
		awsb3_ttwo=$(echo "${awsb3_tablename},"|cut -f2 -d",")
		
		#Return if no b3 parent table exist
		[[ ! -e ${AWSTMPDIR}/${awsb3_ttwo}.${current_time}.sql ]] && return

		[[ ${last_table_name} != ${awsb3_tone} ]] && {
			last_table_name=${awsb3_tone}
			awscolums ${awsb3_tone}
		}

		#Substitute strings with sed
		sed 's/^SELECT.*/'"${select_clause}"'/g' \
			${AWSTMPDIR}/${awsb3_ttwo}.${current_time}.sql \
			> ${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp1
		
		#The special character "&" corresponds to the pattern found: "^FROM.*"
		#and append: , '"${awsb3_tone}"' to the and of "^FROM.*"
		sed 's/^FROM.*/&,'"${awsb3_tone}"'/g' \
			"${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp1" \
			> "${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp2"
			
		cp "${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp2" \
			"${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp1"
				
		awsb3_column=$(echo "${awsb3_table}@"|cut -f2 -d"@")
		
		integer b3_column_num=1
		while true
		do
			awsb3_column_name=$(echo "${awsb3_column},"|cut -f${b3_column_num} -d",")
			[[ ${awsb3_column_name} == "" ]] && {
				cp "${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp1" \
					"${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql"
				break
			}
			
			awsb3_char=";"
			awsb3_string="AND ${awsb3_tone}.${awsb3_column_name} = ${awsb3_ttwo}.${awsb3_column_name}"
			awsb3_file="${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp1"
			
			sedi "${awsb3_char}" "${awsb3_string}" "${awsb3_file}" \
				> "${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp2"
				
			cp "${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp2" \
				"${AWSTMPDIR}/${awsb3_tone}.${current_time}.sql.tmp1"
	
		b3_column_num=b3_column_num+1
		done
	
	done
}

#run SQL generated by awssql() and awsb3()
awsdbaccess () {

	awsdbaccess_sql_file=$1
	
	awsdbaccess_dbaccess_out=${AWSTMPDIR}/$(basename ${awsdbaccess_sql_file} .sql).dbaccess
	
	#Set isolation to dirty read
	sed '1 i\
'"set isolation to dirty read;"'' ${awsdbaccess_sql_file} > ${AWSTMPDIR}/run.sql
	
	echo "START$(basename ${awsdbaccess_sql_file})\n"
	dbaccess ${IDSDB} ${AWSTMPDIR}/run.sql > ${awsdbaccess_dbaccess_out}
	echo "STOP$(basename ${awsdbaccess_sql_file})\n"

}

#change dbaccess output to load/unload output format
awsoutput () {

	awsoutput_dbaccess_out=$1
	
	awsoutput_unload_out=${AWSTMPDIR}/$(basename ${awsoutput_dbaccess_out} .dbaccess).unload
	
	awsoutput_output=${AWSOUTDIR}/$(basename ${awsoutput_dbaccess_out} .dbaccess)
	
	#egrep -v "constant.*constant"  | uniq |
	echo "\n" >> ${awsoutput_dbaccess_out}
	col2rows.pl ${awsoutput_dbaccess_out} > ${awsoutput_unload_out}
		
	#Remove blank lines
	#grep -v "^$" ${awsoutput_unload_out} > ${awsoutput_output}
	sort ${awsoutput_unload_out}|uniq|grep -v "^$" |egrep -v "constant.*constant" > ${awsoutput_output}
	
}

#Process all VAXFilesParser output files under ${AWSINDIR}

find ${AWSINDIR} -name *.txt -print|
while read vax_out_put
do
	current_time=$(date +%Y%m%d%H%M%S)
	
	awssql ${vax_out_put}
	awsb3
	
	find ${AWSTMPDIR} -name *.${current_time}.sql -print|
	while read current_time_sql
	do
		awsdbaccess ${current_time_sql}
	done
	
	find ${AWSTMPDIR} -name *.${current_time}.dbaccess -print|
	while read current_time_dbaccess_out
	do
		awsoutput ${current_time_dbaccess_out}
	done
	
	mv ${vax_out_put} ${AWSINDIR}/keydone
	
	sleep 1	
	
done

exit 0
