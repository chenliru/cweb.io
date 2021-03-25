/home/lchen/tools/shlib tunload b3_line
mail -s "b3_line unload complete" lchen@livingstonintl.com < /dev/null
sleep 10
/home/lchen/tools/shlib tput b3_line
mail -s "b3_line sent complete" lchen@livingstonintl.com < /dev/null

