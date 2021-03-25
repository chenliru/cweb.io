
echo "Run reorgchk for SYSTEM table started @ `date`\n"

db2 -v "connect to icmnlsdb user db2inst1 using db2iu82"

db2 -v "reorgchk update statistics on table system" > ./xtabsys.log 2>&1

db2 -v "connect reset"

echo "Run reorgchk for SYSTEM table finished @ `date`\n"

exit 0

