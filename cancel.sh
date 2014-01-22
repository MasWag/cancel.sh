#!/bin/bash

SED=sed

touch `dirname $0`/cancel.cache

#if [ $# -gt 0 ] && [ $1 == '-v' ] ; then VERBOSE=( exit 1 );else VERBOSE=( exit 0);fi

curl -s http://www.is.s.u-tokyo.ac.jp/no-lec.php | awk 'BEGIN{a=0}/<\/tbody>/{exit}a&&/<\/?t/{print}/<tbody>/{a=1}' | tr '\n' ' ' | $SED -e 's/[[:blank:]]//g' | $SED -e 's/<tr><td>//g;s:</td><td>:,:g;s:</td></tr>:\n:g' | nkf  > `dirname $0`/tmp.csv

for key in $(cat `dirname $0`/search.list) ; do
    echo $key;#fi
    line=$(grep "$key" `dirname $0`/tmp.csv)
    for line2 in $line ; do
        if [ $(grep -c "$line2" `dirname $0`/cancel.cache) -eq 0 ] && [[ ! $line2 =~ ^$ ]]; then
	        echo "$line2" >> `dirname $0`/cancel.cache;
	        name=$(echo $line2 | awk -F "," '{print $3 "休講" }' )
	        place=$(echo $line2 |awk -F "," '{print $5 }' )
	        d=$(echo $line2 | awk -F "," '{print $1 }' )
	        class=${d#*)};
	        month=$(echo $d | sed -e 's:月.*$::g')
	        date=$(echo $d | sed -e 's:日.*$::g;s:^.*月::g')
	        if [ $month -ge `date +"%m"` ] ; then 
	            year=`date +"%Y"`;
	        else
	            year=$((`date +"%Y"` + 1));
	        fi
#	        ruby `dirname $0`/add_schedule.rb $name $place $year $month $date $class
	        echo $name $place $year $month $date $class ;
        fi
    done
done
