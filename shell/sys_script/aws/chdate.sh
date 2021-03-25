ls -l 20151031| awk '{print $9}' > name1
sed 's/20151101/20151031/g' name1 > name2
paste name1 name2 > name3
sed 's/^/mv /g' name3 > name4

