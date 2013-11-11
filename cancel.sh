#!/bin/sh

touch `dirname $0`/cancel.cache

rm `dirname $0`/index.html

wget http://www.c.u-tokyo.ac.jp/zenki/classes/cancel/index.html

grep '</\?t.*' `dirname $0`/index.html | tr '\n\t' ' '|sed -e 's:/tr>:/tr>\n:g'| sed -e 's/<[^>]*>/,/g' | sed -e 's/[[:blank:]]*//g;s/,,*/,/g'|sed -e 's/^,//g;s/,$//g' >`dirname $0`/tmp.csv

awk -F "," '{
if( NF == 4)
{
$7=$4;
$6=$3;
$5 = $2;
$4 = $1;
$3 = L3;
$2 = L2;
$1 = L1;
}
else
{
L3 = $3;
L2 = $2;
L1 = $1;
}
print;
}' `dirname $0`/tmp.csv |sed -e 's/ /,/g' > `dirname $0`/tmp
mv  `dirname $0`/tmp `dirname $0`/tmp.csv

for key in $(cat `dirname $0`/search.list) ; do
echo $key
    line=$(grep "$key" `dirname $0`/tmp.csv)
    for line2 in $line ; do
        if [ $(grep -c "$line2" `dirname $0`/cancel.cache) -eq 0 ] && [[ ! $line2 =~ ^$ ]]; then
	        echo "$line2" >> `dirname $0`/cancel.cache;
	        name=$(echo $line2 | awk -F "," '{print $4 "休講" }' )
	        place=$(echo $line2 |awk -F "," '{print $6 }' )
	        d=$(echo $line2 | awk -F "," '{print $1 }' )
	        class=$(echo $line2 | awk -F "," '{print $3 }' )
	        month=$(echo $d | sed -e 's:月.*$::g')
	        date=$(echo $d | sed -e 's:日.*$::g;s:^.*月::g')
	        if [ $month -ge 4 ] ; then 
	            year=2013;
	        else
	            year=2014;
	        fi
	        ruby `dirname $0`/add_schedule.rb $name $place $year $month $date $class
	        echo $name $place $year $month $date $class
        fi
    done
done
