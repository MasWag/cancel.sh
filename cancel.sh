#!/bin/bash

SED=sed

touch `dirname $0`/cancel.cache

if [ $# -gt 0 ] && [ $1 == '-v' ] ; then VERBOSE=( exit 1 );else VERBOSE=( exit 0);fi

curl -s http://www.c.u-tokyo.ac.jp/zenki/classes/cancel/index.html | grep '</\?t[rd].*' | tr -d ',\t\n' | $SED -e 's:/tr>:/tr>\n:g'| $SED -e 's/<[^>]*>/,/g' | $SED -e 's/[[:blank:]]//g;s/,,*/,/g'| $SED -e 's/^,//g;s/,$//g' | awk -F "," '{
if( NF == 4) for ( t = 3 ; t >=1 ; t-- ) { $(t+3)=$t; $t = L[t];}
else for ( t = 3 ; t >=1 ; t-- ) L[t]=$t;
print;
}' | tr ' ' ',' > `dirname $0`/tmp.csv

for key in $(cat `dirname $0`/search.list) ; do
    if $VERBOSE ; then echo $key;fi
    line=$(grep "$key" `dirname $0`/tmp.csv)
    for line2 in $line ; do
        if [ $(grep -c "$line2" `dirname $0`/cancel.cache) -eq 0 ] && [[ ! $line2 =~ ^$ ]]; then
	        echo "$line2" >> `dirname $0`/cancel.cache;
	        name=$(echo $line2 | awk -F "," '{print $4 "休講" }' )
 	        name2=$(echo $line2 | awk -F "," '{print "明日の" $4 "は休講です." }' )
 	        name3=$(echo $line2 | awk -F "," '{print "今日の" $4 "は休講です." }' )
	        place=$(echo $line2 |awk -F "," '{print $6 }' )
	        d=$(echo $line2 | awk -F "," '{print $1 }' )
	        class=$(echo $line2 | awk -F "," '{print $3 }' )
	        month=$(echo $d | sed -e 's:月.*$::g')
	        date=$(echo $d | sed -e 's:日.*$::g;s:^.*月::g')
	        if [ $month -ge `date +"%m"` ] ; then 
	            year=`date +"%Y"`;
	        else
	            year=$((`date +"%Y"` + 1));
	        fi
	        ruby `dirname $0`/add_schedule.rb $name $place $year $month $date $class
                ruby `dirname $0`/add_schedule.rb $name2 $place $year $month $(($date - 1)) 3
 	        ruby `dirname $0`/add_schedule.rb $name3 $place $year $month $date 1 -10
	        if $VERBOSE ; then echo $name $place $year $month $date $class ; fi
        fi
    done
done
