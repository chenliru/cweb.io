#!/bin/ksh93
###############################################################################
#  Prepare the raw devices or files that you used for storage after the level-0 
#  backup are available. 
#
#  All the chunks information is collected with:
# `onstat -D ` and stored in file $TOOLSDIR/db/informix/etc/CHUNK.$instnace
#
#  Author : Liru Chen
#  Date: 2013-03-26
################################################################################
#set -v
#set -x

if [[ $# != 1 ]]
then
	echo $"Usage: $0 informix_instance"
	exit 1
fi


if [[ $USER != root ]]
then
	echo "You should be root user"
	exit 2
fi

chunkfile=$TOOLSDIR/db/informix/etc/CHUNK.$1

grep -v "BACKUP DEVICE" $chunkfile| while read chunkname
do
	[[ -f $chunkname ]] || {
		[[ -d $(dirname $chunkname) ]] || ( mkdir -p $(dirname $chunkname) )
		touch $chunkname
	}

	chown -R informix:informix $(dirname $chunk_name)
	chmod 660 $chunk_name

done 

