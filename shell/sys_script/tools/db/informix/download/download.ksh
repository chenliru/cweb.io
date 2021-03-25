#!/bin/ksh93
# Start archive database on ifx01, and prepare the Monthly data unload SQL files for client
set -x
set -v

. /home/lchen/ids115.env ardb

#Identify database based on data archive year and month
#This function need to be modified when database ip_arch01@ardb reused
b3_archive_db () {
	year=$1
	month=$2

	if [[ $year -eq 2008 ]]
	then
		if [[ $month -le 10 ]]
		then
			return 1	#arch_db=ip_arch01@ardb
		else
			return 2	#arch_db=ip_arch02@ardb
		fi

	elif [[ $year -eq 2009 ]]
	then
		return 2		#arch_db=ip_arch02@ardb

	elif [[ $year -eq 2010 ]]; then
		if [[ $month -le 04 ]]; then
			return 2		#arch_db=ip_arch02@ardb
		else
			return 3		#arch_db=ip_arch03@ardb
		fi

	elif [[ $year -eq 2011 ]]
	then
		if [[ $month -le 10 ]]
		then
			return 3		#arch_db=ip_arch03@ardb
		else
			return 4		#arch_db=ip_arch04@ardb
		fi

	elif [[ $year -eq 2012 ]]
	then
		return 4		#arch_db=ip_arch04@ardb

	elif [[ $year -eq 2013 ]]
	then
		if [[ $month -le 04 ]]
		then
			return 4		#arch_db=ip_arch04@ardb
		else
			return 5		#arch_db=ip_arch05@ardb
		fi
		
	elif [[ $year -eq 2014 ]]
	then
		if [[ $month -le 10 ]]
		then
			return 5		#arch_db=ip_arch05@ardb
		else
			return 1		#arch_db=ip_arch01@ardb
		fi

	elif [[ $year -eq 2015 ]]
	then
		return 1		#arch_db=ip_arch01@ardb
		
	fi
}

string_replace () {
	name=$1
	origin=$2
	target=$3

	tmpDir=/home/lchen/tools/tmp
	[[ -d $tmpDir ]] || mkdir -p $tmpDir

	find $1 -xdev -ls | awk '{print $11}' | while read filename
	do
		file $filename | egrep "shell|commands|text"
		[[ $? -eq 0 ]] && {
			grep $origin $filename
			[[ $? -eq 0 ]] && {
				cp $filename $tmpDir
				slashorigin=$(echo $origin | sed "s/\//\\\\\//g")
				slashtarget=$(echo $target | sed "s/\//\\\\\//g")
				sed "s/$slashorigin/$slashtarget/g" \
					$tmpDir/`basename $filename` > $filename
				}
			}
	   
	 done
}

cd /home/lchen/tools/db/informix/download

client_number=$1

integer year_start=$2
integer year_end=$3

integer month_start=$4
integer month_end=$5

integer year=$year_start
month=(00 01 02 03 04 05 06 07 08 09 10 11 12)

if [[ $year_start -eq $year_end ]]; then
	integer i=month_start
	while (( i <= month_end ))
	do
		b3_archive_db $year ${month[i]}
		arch_db=ip_arch0$?@ardb
			
		cp -p CLIENT_SAMPLE.sql $client_number.sql
		string_replace $client_number.sql "DATABASE" "$arch_db"
		string_replace $client_number.sql "CLINETNO" "$client_number"
		string_replace $client_number.sql "YEAR" "$year"
		string_replace $client_number.sql "MONTH" "${month[i]}"
		
		dbaccess - $client_number.sql
		i=i+1
	done
else
	while (( year < year_end ))
	do

		if [[ $year -eq $year_start ]]; then
			integer i=month_start
			while (( i <= 12 ))
			do
				b3_archive_db $year ${month[i]}
				arch_db=ip_arch0$?@ardb
				
				cp -p CLIENT_SAMPLE.sql $client_number.sql
				string_replace $client_number.sql "DATABASE" "$arch_db"
				string_replace $client_number.sql "CLINETNO" "$client_number"
				string_replace $client_number.sql "YEAR" "$year"
				string_replace $client_number.sql "MONTH" "${month[i]}"
			
				dbaccess - $client_number.sql
				i=i+1
			done
		fi
		
		year=year+1
		if [[ $year -eq $year_end ]]; then
			integer j=1
			while (( j <= month_end ))
			do
				b3_archive_db $year ${month[j]}
				arch_db=ip_arch0$?@ardb
				
				cp -p CLIENT_SAMPLE.sql $client_number.sql
				string_replace $client_number.sql "DATABASE" "$arch_db"
				string_replace $client_number.sql "CLINETNO" "$client_number"
				string_replace $client_number.sql "YEAR" "$year"
				string_replace $client_number.sql "MONTH" "${month[j]}"
				
				dbaccess - $client_number.sql
				j=j+1
			done
		else
			for k in 1 2 3 4 5 6 7 8 9 10 11 12
			do
				b3_archive_db $year ${month[k]}
				arch_db=ip_arch0$?@ardb
				
				cp -p CLIENT_SAMPLE.sql $client_number.sql
				string_replace $client_number.sql "DATABASE" "$arch_db"
				string_replace $client_number.sql "CLINETNO" "$client_number"
				string_replace $client_number.sql "YEAR" "$year"
				string_replace $client_number.sql "MONTH" "${month[k]}"
			
				dbaccess - $client_number.sql
			done
		fi
	done
fi
	
cat entry.head *.tmp > oldshipment$client_number

