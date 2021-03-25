#!/bin/ksh93
set -x
set -v

remotepwd=$(dirname $0)

filename=$remotepwd/myTab.run

IFS=,;grep ^$(hostname) $filename|
while read hostname user script sudoer runtime
do
	echo $hostname $user $script $sudoer $runtime
	
	pathname=$(echo $script|awk '{print $1}')
	name=$(basename $pathname)
	out=$name.out
		
	[[ $sudoer == "sudoer" ]] && {
		if [[ -e $pathname && ! -x $pathname ]];then su -l $user -c "chmod a+x $pathname";fi
		su -l $user -c "$script 1>$remotepwd/$out$runtime 2>&1"
	}
	
	[[ $sudoer == "nosudoer" ]] && {
		if [[ -e $pathname && ! -x $pathname ]];then chmod a+x $pathname;fi
		$script 1>$remotepwd/$out$runtime 2>&1
	}
	
done

