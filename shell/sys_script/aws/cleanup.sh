#!/bin/ksh93
#########################################################################
# SHELL SCRIPTS TOOLS LIBRARY
#----------------------------------------------------------------------
# 1. re-send failed data/key files (today or $1) for network/aws reasons
# 2. clean up exipired data files 
#
# Author : Liru Chen
# Licensed Materials ; All Rights Reserved 2015-2019
#########################################################################
set -v 
set -x

MAILALERT="lchen@livingstonintl.com"
MAILLIST="aixsupport@livingstonintl.com"

#AWS's Parameter 
CURDATE=$(date +%Y%m%d)
AWSDATE=${1-$CURDATE}

AWSRUNDIR=/insight/local/scripts/VaxParser/tools
#AWSFAILDIR=/recyclebox/AWS/uploadfail/${AWSDATE}
AWSFAILDIR=/recyclebox/AWS/uploadfail
#AWSERRDIR=/recyclebox/AWS/parsererror/${AWSDATE}

#duplicated VAX Data files, copied by runner*.ksh from /dmqjtmp/rcp/
VAXDIR=/dmqjtmp/rcp/stage/done

#Clean expired file types like *log after @days, under directories listed
CLEARSTAGE="/recyclebox/AWS/clears"		#Also including this directory in CLEARDIR
CLEARDIR="
	/dmqjtmp/rcp/stage/AWSOutput@"icc,vax"@3
	/dmqjtmp/rcp/stage/iccdatauploadOutput@"DataFile"@3
	/dmqjtmp/rcp/stage/ICCBillingUploadOutput@"DataFile"@3
	/dmqjtmp/rcp/stage/ICCSetExpiryDatesOutput@"DataFile"@3
	/insight/local/scripts/VaxParser/VaxParserLogs@"log"@3
	/recyclebox/AWS/uploadfail/done@"ALL"@3
	${CLEARSTAGE}@"ALL"@7
	"
[[ ! -d ${CLEARSTAGE} ]] && mkdir -p ${CLEARSTAGE}
export CLEARDIR CLEARSTAGE

#remote AWS host
AWSREMOTE="ingest@a0almcdhcan01.dev.liiaws.net"
AWSREMOTEDATA="/opt/ingest/informix/data/${AWSDATE}"
AWSREMOTEKEY="/opt/ingest/informix/key/${AWSDATE}"
AWSREMOTEVAX="/opt/ingest/informix/locusvax/${AWSDATE}"

AWSPRIVATEKY=$AWSRUNDIR/.ssh/Privatekey

clears () {
	clear_dirs=${CLEARDIR}
	clear_stage=${CLEARSTAGE}

	cd ${clear_stage}
	
	for clear_dir in ${clear_dirs}
	do
		clear_location=$(echo "${clear_dir}@"|cut -f1 -d@)
		clear_types=$(echo "${clear_dir}@"|cut -f2 -d@|tr , " ")
		clear_day=$(echo "${clear_dir}@"|cut -f3 -d@)

		[[ ! -d ${clear_location} || ${clear_day} == "" ]] && {
			echo "${clear_location} NOT EXIST and/or Clear Day is 0"
			continue
		}
		
		bkupname=$(echo ${clear_location}| sed "s/\//./g")

		for clear_type in ${clear_types}
		do
			
			if [[ ${clear_location} == ${clear_stage} ]]
			then
				if [[ ${clear_type} == ALL ]]
				then
					find ${clear_location} -mtime +${clear_day} -exec rm -f {} \;
				else
					find ${clear_location} -name "*${clear_type}*" -mtime +${clear_day} -exec rm -f {} \;
				fi

			else

				#Backup by filename
				if [[ ${clear_type} == ALL ]]
				then
					find ${clear_location} -mtime +${clear_day} -print > tmplist
				
					tar -cvf ${bkupname}.${CURDATE}.tar -L tmplist
					[[ -e ${bkupname}.${CURDATE}.tar ]] && gzip -f ${bkupname}.${CURDATE}.tar
				
					#then, delete 
					find ${clear_location} -mtime +${clear_day} -exec rm -f {} \;
				else
					find ${clear_location} -name "*${clear_type}*" -mtime +${clear_day} -print > tmplist
				
					tar -cvf ${bkupname}.${CURDATE}.tar -L tmplist
					[[ -e ${bkupname}.${CURDATE}.tar ]] && gzip -f ${bkupname}.${CURDATE}.tar
				
					#then, delete 
					find ${clear_location} -name "*${clear_type}*" -mtime +${clear_day} -exec rm -f {} \;
				fi			

			fi
			
		done

	done
}

#send out failed data/key files if any
if [[ ! -d $AWSFAILDIR ]]
then
	mail -s " $AWSFAILDIR DIRECTORY NOT EXIT" "$MAILALERT" < /dev/null
else

	#empty=$(ls $AWSFAILDIR|wc -l)
	empty=$(ls -p $AWSFAILDIR|grep -v / |wc -l)
	if [[ $empty -eq 0 ]]
	then
		mail -s " No failed-loading data under $AWSFAILDIR DIRECTORY" "$MAILALERT" < /dev/null
	else
		ssh -i $AWSPRIVATEKY $AWSREMOTE \
		"[[ ! -d $AWSREMOTEDATA ]] && mkdir -p $AWSREMOTEDATA"

		ssh -i $AWSPRIVATEKY $AWSREMOTE \
		"[[ ! -d $$AWSREMOTEKEY ]] && mkdir -p $AWSREMOTEKEY"

		ssh -i $AWSPRIVATEKY $AWSREMOTE \
		"[[ ! -d $AWSREMOTEVAX ]] && mkdir -p $AWSREMOTEVAX"

		cd $AWSFAILDIR
		scp -i $AWSPRIVATEKY $AWSFAILDIR/*txt* $AWSREMOTE:$AWSREMOTEKEY
		if [[ $? -ne 0 ]]
		then
			mail -s "Final AWS incremental key+token upload failed" "$MAILALERT" < /dev/null
		else
			mail -s "Final AWS incremental key+token upload completed" "$MAILALERT" < /dev/null
			mv $AWSFAILDIR/*txt* $AWSFAILDIR/../done
		fi

		cd $AWSFAILDIR
		scp -i $AWSPRIVATEKY $AWSFAILDIR/* $AWSREMOTE:$AWSREMOTEDATA
		if [[ $? -ne 0 ]]
		then
			mail -s "Final AWS incremental data+token upload failed" "$MAILALERT" < /dev/null
		else
			mail -s "Final AWS incremental data+token upload completed" "$MAILALERT" < /dev/null
			mv $AWSFAILDIR/* $AWSFAILDIR/../done
		fi
	
	fi
	
fi


#check token
if [[ -e ${AWSRUNDIR}/run.token ]]
then
	mail -s "AWS loading NOT completed, Please contact AIX Support" "$MAILLIST" < /dev/null
	exit 1
else
	rm -f $VAXDIR/*.vax
	mail -s "AWS loading completed ${CURDATE}" "$MAILLIST" < /dev/null
fi

#Start clean up
clears

exit 0

