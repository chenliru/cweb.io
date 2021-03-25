set -v
set -x

#cd $1
ls | while read name
do
        echo "transfer completed." > $name.token
done

