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
MAILNOTICE="lchen@livingstonintl.com"

#AWS's Parameter 
CURDATE=$(date +%Y%m%d)
AWSDATE=${1-$CURDATE}

#kill aws processes if any
awsprocesskill () {

	ps -ef|grep -v grep|grep aws|while read owner pid ppid etc
	do
		kill -9 $pid
	done

}

#Clean expired file types like *log after @days, under directories listed
awsbkup () {

	AWSTMPDIR=/recyclebox/AWS/temp
	AWSERRDIR=/recyclebox/AWS/parsererror/${AWSDATE}
	[[ ! -d $AWSERRDIR ]] && mkdir -p $AWSERRDIR
	
	CLEARSTAGE="/recyclebox/AWS/clears"		#Also including this directory in CLEARDIR
	CLEARDIR="
		/dmqjtmp/rcp/stage/AWSOutput@"icc,vax"@5
		/dmqjtmp/rcp/stage/iccdatauploadOutput@"DataFile"@5
		/dmqjtmp/rcp/stage/ICCBillingUploadOutput@"DataFile"@5
		/dmqjtmp/rcp/stage/ICCSetExpiryDatesOutput@"DataFile"@5
		/insight/local/scripts/VaxParser/VaxParserLogs@"log"@5
		/recyclebox/AWS/uploadfail/done@"ALL"@5
		${CLEARSTAGE}@"ALL"@7
		"
	[[ ! -d $CLEARSTAGE ]] && mkdir -p $CLEARSTAGE

	cd $CLEARSTAGE
	
	for directory in $CLEARDIR
	do
		location=$(echo "${directory}@"|cut -f1 -d@)
		types=$(echo "${directory}@"|cut -f2 -d@|tr , " ")
		days=$(echo "${directory}@"|cut -f3 -d@)

		[[ ! -d $location || $days == "" ]] && {
			echo "$location NOT EXIST and/or Clear Day is 0"
			continue
		}
		
		bkupname=$(echo $location|sed "s/\//./g")

		for type in $types
		do
			
			if [[ $location == $CLEARSTAGE ]]
			then
				if [[ $type == ALL ]]
				then
					find $location -mtime +$days -exec rm -f {} \;
				else
					find $location -name "*${type}*" -mtime +$days -exec rm -f {} \;
				fi

			else
				#Backup by filename and filetype
				if [[ $type == ALL ]]
				then
					find $location -mtime +$days -print > tmplist
				
					tar -cvf ${bkupname}.${CURDATE}.tar -L tmplist
					[[ -e ${bkupname}.${CURDATE}.tar ]] && gzip -f ${bkupname}.${CURDATE}.tar
				
					#then, delete 
					find $location -mtime +$days -exec rm -f {} \;
				else
					find $location -name "*${type}*" -mtime +$days -print > tmplist
				
					tar -cvf ${bkupname}.${CURDATE}.tar -L tmplist
					[[ -e ${bkupname}.${CURDATE}.tar ]] && gzip -f ${bkupname}.${CURDATE}.tar
				
					#then, delete 
					find $location -name "*${type}*" -mtime +$days -exec rm -f {} \;
				fi			

			fi
			
		done

	done

	#backup all logs, sql files, key files if errors during query informix db
	cd $AWSTMPDIR
	grep -i error $AWSTMPDIR/MISSED*.out
	[[ $? -eq 0 ]] && {
		mail -s "VAX Errors in SQL MISSED*.out" "$MAILALERT" < /dev/null
		[[ ! -d $AWSERRDIR ]] && mkdir -p $AWSERRDIR
		cp $AWSTMPDIR/MISSED*.out $AWSERRDIR
		cp $AWSTMPDIR/*.sql $AWSERRDIR
		cp $AWSINDIR/keydone/*.txt $AWSERRDIR
	}

	find $AWSTMPDIR -name "*.error" -size +0 -print|
	while read errorfile
	do
		mail -s "VAX Failed key of $errorfile" "$MAILALERT" < $errorfile
		[[ ! -d $AWSERRDIR ]] && mkdir -p $AWSERRDIR
		cp $errorfile $AWSERRDIR
	done
	
}

#send out failed data/key files if any
awsload () {

	AWSRUNDIR=/insight/local/scripts/VaxParser/tools
	AWSPRIVATEKY=$AWSRUNDIR/.ssh/Privatekey
	
	AWSFAILDIR=/recyclebox/AWS/uploadfail

	AWSOUTBASE=/dmqjtmp/rcp/stage/AWSOutput
	AWSOUTDIR=$AWSOUTBASE/output
	
	AWSREMOTE="ingest@a0alpcdhcan01.lii01.livun.com"
	AWSREMOTEDATA="/opt/ingest/informix/data/${AWSDATE}"
	AWSREMOTEKEY="/opt/ingest/informix/key/${AWSDATE}"
	AWSREMOTEVAX="/opt/ingest/informix/locusvax/${AWSDATE}"

	#Setup DIRECTORY on AWS side
	ssh -i $AWSPRIVATEKY $AWSREMOTE \
	"[[ ! -d $AWSREMOTEDATA ]] && mkdir -p $AWSREMOTEDATA"
	ssh -i $AWSPRIVATEKY $AWSREMOTE \
	"[[ ! -d $$AWSREMOTEKEY ]] && mkdir -p $AWSREMOTEKEY"
	ssh -i $AWSPRIVATEKY $AWSREMOTE \
	"[[ ! -d $AWSREMOTEVAX ]] && mkdir -p $AWSREMOTEVAX"

	#Start transfer data files and data token files from $AWSOUTDIR to AWS
	cd $AWSOUTDIR
	scp -i $AWSPRIVATEKY $AWSOUTDIR/* $AWSREMOTE:$AWSREMOTEDATA
	if [[ $? -ne 0 ]]
	then
		mail -s "VAX incremental data upload failed" "$MAILALERT" < /dev/null

		[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
		cp $AWSOUTDIR/* $AWSFAILDIR
		mail -s "VAX upload failed incremental data copied to $AWSFAILDIR" "$MAILALERT" < /dev/null

	else
		mail -s "VAX incremental data upload completed" "$MAILNOTICE" < /dev/null
	fi

	$VAXPARSERRUNDIR/datatoken.sh

	scp -i $AWSPRIVATEKY $AWSOUTDIR/*.token $AWSREMOTE:$AWSREMOTEDATA
	if [[ $? -ne 0 ]]
	then

		mail -s "VAX incremental data token upload failed" "$MAILALERT" < /dev/null

		[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
		cp $AWSOUTDIR/*.token $AWSFAILDIR
		mail -s "VAX upload failed incremental data token copied to $AWSFAILDIR" "$MAILALERT" < /dev/null

	else
		mail -s "VAX incremental data token upload completed" "$MAILNOTICE" < /dev/null	
	fi


}

#clean up all running directories/token file for awslocus.ksh and awscoda.sh
awscleanup () {
	
	VAXPARSERINDIR=/dmqjtmp/vaxparser
	VAXPARSERPROCESSEDDIR=/dmqjtmp/vaxparserprocessed
	
	AWSTMPDIR=/recyclebox/AWS/temp

	AWSOUTBASE=/dmqjtmp/rcp/stage/AWSOutput
	AWSOUTDIR=$AWSOUTBASE/output

	AWSINDIR=/dmqjtmp/rcp/stage/VaxParserOutput

	AWSRUNDIR=/insight/local/scripts/VaxParser/tools	

	#Clean vax parser running directory
	[[ -d $VAXPARSERINDIR ]] && {

		rm -f $VAXPARSERINDIR/*.vax
	}
	
	#clean vax parser running directory
	[[ -d $VAXPARSERPROCESSEDDIR ]] && {

		rm -f $VAXPARSERPROCESSEDDIR/*.vax
		rm -f $VAXPARSERPROCESSEDDIR/*.vaxtoken
	}
	
	#Clean $AWSTMPDIR
	[[ -d $AWSTMPDIR ]] && {

		rm -f $AWSTMPDIR/*.tmp
		rm -f $AWSTMPDIR/*.tmp1
		rm -f $AWSTMPDIR/*.tmp2
		rm -f $AWSTMPDIR/*.dbaccess
		rm -f $AWSTMPDIR/*.vax4sql
		rm -f $AWSTMPDIR/*.unload
		rm -f $AWSTMPDIR/MISSED*.out
		rm -f $AWSTMPDIR/*.sql
		rm -f $AWSTMPDIR/*.error
	}

	#Clean $AWSOUTBASE
	[[ -d $AWSOUTBASE ]] && {

		rm -f $AWSOUTBASE/*done.*
		rm -f $AWSOUTBASE/*current.*
	}
	
	#Clean $AWSOUTDIR
	[[ -d $AWSOUTDIR ]] && {

		rm -f $AWSOUTDIR/*.token
		rm -f $AWSOUTDIR/*.??????????????
	}
	
	#Clean $AWSINDIR/keydone
	[[ -d $AWSINDIR ]] && {

		rm -f $AWSINDIR/keydone/*.txt
		rm -f $AWSINDIR/keydone/*.txt.token
	}
	
	#release process token lock
	[[ -e $AWSRUNDIR/run.token ]] && rm -f $AWSRUNDIR/run.token

}

#Start main
awsprocesskill

awsbkup
awsload

awscleanup

##VAX Data files, copied by runner*.ksh from /dmqjtmp/rcp/
#VAXDIR=/dmqjtmp/rcp/stage/done
#VAXDIR=/dmqjtmp/rcp/stage/done;[[ -d $VAXDIR ]] && rm -f $VAXDIR/*.vax;

exit 0
