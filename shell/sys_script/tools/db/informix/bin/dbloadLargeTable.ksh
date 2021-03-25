#!/bin/ksh 
#=========================================================================== 
# filename:dbload.sh 
# Function: Upload large datafile (over Millions records) into informix table 
#
# Address Buffer overflow problem of load utility: 
#    load from loadfile.txt insert into tablename; 
#
# Sytax:
#   input: nameDB nameTable dataFile 
# 
#=========================================================================== 

#set -x
errLog=/login/lchen/informix/errdbload.log

if [ $# -ne 3 ];then 
cat < < EOF 
 Usage: $0 nameDB nameTable dataFile 

 nameDB: Database name 
 nameTable: Table name 
 dataFile: TXT Data File 
EOF 

exit 1 

fi 

nameDB="$1"  
nameTable="$2"  
dataFile="$3" 

if [ ! -f "$dataFile" ];then 
echo " <ERROR>DataFile[$dataFile] does not exit!" | tee -a $errLog 
exit 1 
fi 

tmpStr0=`echo $dataFile | sed "s/\//_/g"` 

dbload nameDB nameTable dataFile

exit 0

